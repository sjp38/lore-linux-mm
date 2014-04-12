Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 77F6C6B00A0
	for <linux-mm@kvack.org>; Sat, 12 Apr 2014 17:03:59 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id cm18so6679412qab.32
        for <linux-mm@kvack.org>; Sat, 12 Apr 2014 14:03:59 -0700 (PDT)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id d8si4949696qao.230.2014.04.12.14.03.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 12 Apr 2014 14:03:58 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id j7so6558683qaq.22
        for <linux-mm@kvack.org>; Sat, 12 Apr 2014 14:03:58 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 2/2] swap: use separate priority list for available swap_infos
Date: Sat, 12 Apr 2014 17:00:54 -0400
Message-Id: <1397336454-13855-3-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
References: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
 <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Dan Streetman <ddstreet@ieee.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Originally get_swap_page() started iterating through the singly-linked
list of swap_info_structs using swap_list.next or highest_priority_index,
which both were intended to point to the highest priority active swap
target that was not full.  The previous patch in this series changed the
singly-linked list to a doubly-linked list, and removed the logic to start
at the highest priority non-full entry; it starts scanning at the highest
priority entry each time, even if the entry is full.

Add a new list, also priority ordered, to track only swap_info_structs
that are available, i.e. active and not full.  Use a new spinlock so that
entries can be added/removed outside of get_swap_page; that wasn't possible
previously because the main list is protected by swap_lock, which can't be
taken when holding a swap_info_struct->lock because of locking order.
The get_swap_page() logic now does not need to hold the swap_lock, and it
iterates only through swap_info_structs that are available.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>


---
 include/linux/swap.h |   1 +
 mm/swapfile.c        | 128 ++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 87 insertions(+), 42 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 96662d8..d9263db 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -214,6 +214,7 @@ struct percpu_cluster {
 struct swap_info_struct {
 	unsigned long	flags;		/* SWP_USED etc: see above */
 	signed short	prio;		/* swap priority of this type */
+	struct list_head prio_list;	/* entry in priority list */
 	struct list_head list;		/* entry in swap list */
 	signed char	type;		/* strange name for an index */
 	unsigned int	max;		/* extent of the swap_map */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index b958645..3c38461 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -57,9 +57,13 @@ static const char Unused_file[] = "Unused swap file entry ";
 static const char Bad_offset[] = "Bad swap offset entry ";
 static const char Unused_offset[] = "Unused swap offset entry ";
 
-/* all active swap_info */
+/* all active swap_info; protected with swap_lock */
 LIST_HEAD(swap_list_head);
 
+/* all available (active, not full) swap_info, priority ordered */
+static LIST_HEAD(prio_head);
+static DEFINE_SPINLOCK(prio_lock);
+
 struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
 static DEFINE_MUTEX(swapon_mutex);
@@ -73,6 +77,27 @@ static inline unsigned char swap_count(unsigned char ent)
 	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
 }
 
+/*
+ * add, in priority order, swap_info (p)->(le) list_head to list (lh)
+ * this list-generic function is needed because both swap_list_head
+ * and prio_head need to be priority ordered:
+ * swap_list_head in swapoff to adjust lower negative prio swap_infos
+ * prio_list in get_swap_page to scan highest prio swap_info first
+ */
+#define swap_info_list_add(p, lh, le) do {			\
+	struct swap_info_struct *_si;				\
+	BUG_ON(!list_empty(&(p)->le));				\
+	list_for_each_entry(_si, (lh), le) {			\
+		if ((p)->prio >= _si->prio) {			\
+			list_add_tail(&(p)->le, &_si->le);	\
+			break;					\
+		}						\
+	}							\
+	/* lh empty, or p lowest prio */			\
+	if (list_empty(&(p)->le))				\
+		list_add_tail(&(p)->le, (lh));			\
+} while (0)
+
 /* returns 1 if swap entry is freed */
 static int
 __try_to_reclaim_swap(struct swap_info_struct *si, unsigned long offset)
@@ -591,6 +616,9 @@ checks:
 	if (si->inuse_pages == si->pages) {
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
+		spin_lock(&prio_lock);
+		list_del_init(&si->prio_list);
+		spin_unlock(&prio_lock);
 	}
 	si->swap_map[offset] = usage;
 	inc_cluster_info_page(si, si->cluster_info, offset);
@@ -642,53 +670,68 @@ swp_entry_t get_swap_page(void)
 {
 	struct swap_info_struct *si, *next;
 	pgoff_t offset;
-	struct list_head *tmp;
 
-	spin_lock(&swap_lock);
 	if (atomic_long_read(&nr_swap_pages) <= 0)
 		goto noswap;
 	atomic_long_dec(&nr_swap_pages);
 
-	list_for_each(tmp, &swap_list_head) {
-		si = list_entry(tmp, typeof(*si), list);
-		spin_lock(&si->lock);
-		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
-			spin_unlock(&si->lock);
-			continue;
-		}
-
+	spin_lock(&prio_lock);
+start_over:
+	list_for_each_entry_safe(si, next, &prio_head, prio_list) {
 		/*
-		 * rotate the current swap_info that we're going to use
+		 * rotate the current swap_info that we're checking
 		 * to after any other swap_info that have the same prio,
 		 * so that all equal-priority swap_info get used equally
 		 */
-		next = si;
-		list_for_each_entry_continue(next, &swap_list_head, list) {
-			if (si->prio != next->prio)
+		struct swap_info_struct *eq_prio = si;
+		list_for_each_entry_continue(eq_prio, &prio_head, prio_list) {
+			if (si->prio != eq_prio->prio)
 				break;
-			list_rotate_left(&si->list);
-			next = si;
+			list_rotate_left(&si->prio_list);
+			eq_prio = si;
+		}
+		spin_unlock(&prio_lock);
+		spin_lock(&si->lock);
+		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
+			spin_lock(&prio_lock);
+			if (list_empty(&si->prio_list)) {
+				spin_unlock(&si->lock);
+				goto nextsi;
+			}
+			WARN(!si->highest_bit,
+			     "swap_info %d in list but !highest_bit\n",
+			     si->type);
+			WARN(!(si->flags & SWP_WRITEOK),
+			     "swap_info %d in list but !SWP_WRITEOK\n",
+			     si->type);
+			list_del_init(&si->prio_list);
+			spin_unlock(&si->lock);
+			goto nextsi;
 		}
 
-		spin_unlock(&swap_lock);
 		/* This is called for allocating swap entry for cache */
 		offset = scan_swap_map(si, SWAP_HAS_CACHE);
 		spin_unlock(&si->lock);
 		if (offset)
 			return swp_entry(si->type, offset);
-		spin_lock(&swap_lock);
+		printk(KERN_DEBUG "scan_swap_map of si %d failed to find offset\n",
+		       si->type);
+		spin_lock(&prio_lock);
+nextsi:
 		/*
-		 * shouldn't really have got here, but for some reason the
-		 * scan_swap_map came back empty for this swap_info.
-		 * Since we dropped the swap_lock, there may now be
-		 * non-full higher prio swap_infos; let's start over.
+		 * shouldn't really have got here.  either si was
+		 * in the prio_head list but was full or !writeok, or
+		 * scan_swap_map came back empty.  Since we dropped
+		 * the prio_lock, the prio_head list may have been
+		 * modified; so if next is still in the prio_head
+		 * list then try it, otherwise start over.
 		 */
-		tmp = &swap_list_head;
+		if (list_empty(&next->prio_list))
+			goto start_over;
 	}
 
 	atomic_long_inc(&nr_swap_pages);
 noswap:
-	spin_unlock(&swap_lock);
 	return (swp_entry_t) {0};
 }
 
@@ -791,8 +834,17 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 		dec_cluster_info_page(p, p->cluster_info, offset);
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
-		if (offset > p->highest_bit)
+		if (offset > p->highest_bit) {
+			bool was_full = !p->highest_bit;
 			p->highest_bit = offset;
+			if (was_full && (p->flags & SWP_WRITEOK)) {
+				spin_lock(&prio_lock);
+				if (list_empty(&p->prio_list))
+					swap_info_list_add(p, &prio_head,
+							   prio_list);
+				spin_unlock(&prio_lock);
+			}
+		}
 		atomic_long_inc(&nr_swap_pages);
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
@@ -1727,8 +1779,6 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				struct swap_cluster_info *cluster_info)
 {
-	struct swap_info_struct *si;
-
 	if (prio >= 0)
 		p->prio = prio;
 	else
@@ -1740,20 +1790,10 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	total_swap_pages += p->pages;
 
 	assert_spin_locked(&swap_lock);
-	BUG_ON(!list_empty(&p->list));
-	/* insert into swap list: */
-	list_for_each_entry(si, &swap_list_head, list) {
-		if (p->prio >= si->prio) {
-			list_add_tail(&p->list, &si->list);
-			return;
-		}
-	}
-	/*
-	 * this covers two cases:
-	 * 1) p->prio is less than all existing prio
-	 * 2) the swap list is empty
-	 */
-	list_add_tail(&p->list, &swap_list_head);
+	swap_info_list_add(p, &swap_list_head, list);
+	spin_lock(&prio_lock);
+	swap_info_list_add(p, &prio_head, prio_list);
+	spin_unlock(&prio_lock);
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
@@ -1827,6 +1867,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		spin_unlock(&swap_lock);
 		goto out_dput;
 	}
+	spin_lock(&prio_lock);
+	list_del_init(&p->prio_list);
+	spin_unlock(&prio_lock);
 	spin_lock(&p->lock);
 	if (p->prio < 0) {
 		struct swap_info_struct *si = p;
@@ -2101,6 +2144,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 	}
 	INIT_LIST_HEAD(&p->first_swap_extent.list);
 	INIT_LIST_HEAD(&p->list);
+	INIT_LIST_HEAD(&p->prio_list);
 	p->flags = SWP_USED;
 	spin_unlock(&swap_lock);
 	spin_lock_init(&p->lock);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
