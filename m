Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id D92AA6B003A
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:39:15 -0400 (EDT)
Received: by mail-yk0-f169.google.com with SMTP id 200so6097606ykr.14
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:39:15 -0700 (PDT)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id k94si16693043yhq.32.2014.05.12.09.39.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 09:39:15 -0700 (PDT)
Received: by mail-yh0-f47.google.com with SMTP id z6so6097556yhz.6
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:39:15 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv2 4/4] swap: change swap_list_head to plist, add swap_avail_head
Date: Mon, 12 May 2014 12:38:20 -0400
Message-Id: <1399912700-30100-5-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1399912700-30100-1-git-send-email-ddstreet@ieee.org>
References: <1399057350-16300-1-git-send-email-ddstreet@ieee.org>
 <1399912700-30100-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Dan Streetman <ddstreet@ieee.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

Originally get_swap_page() started iterating through the singly-linked
list of swap_info_structs using swap_list.next or highest_priority_index,
which both were intended to point to the highest priority active swap
target that was not full.  The first patch in this series changed the
singly-linked list to a doubly-linked list, and removed the logic to start
at the highest priority non-full entry; it starts scanning at the highest
priority entry each time, even if the entry is full.

Replace the manually ordered swap_list_head with a plist, swap_active_head.
Add a new plist, swap_avail_head.  The original swap_active_head plist
contains all active swap_info_structs, as before, while the new
swap_avail_head plist contains only swap_info_structs that are active and
available, i.e. not full.  Add a new spinlock, swap_avail_lock, to protect
the swap_avail_head list.

Mel Gorman suggested using plists since they internally handle ordering
the list entries based on priority, which is exactly what swap was doing
manually.  All the ordering code is now removed, and swap_info_struct
entries and simply added to their corresponding plist and automatically
ordered correctly.

Using a new plist for available swap_info_structs simplifies and
optimizes get_swap_page(), which no longer has to iterate over full
swap_info_structs.  Using a new spinlock for swap_avail_head plist
allows each swap_info_struct to add or remove themselves from the
plist when they become full or not-full; previously they could not
do so because the swap_info_struct->lock is held when they change
from full<->not-full, and the swap_lock protecting the main
swap_active_head must be ordered before any swap_info_struct->lock.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Shaohua Li <shli@fusionio.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>

---

Changes since v1 https://lkml.org/lkml/2014/5/2/510
 -add missing spin_unlock(&swap_avail_head) in get_swap_page()
  in total failure case
 -plist_rotate() call changed to plist_requeue()

 include/linux/swap.h     |   3 +-
 include/linux/swapfile.h |   2 +-
 mm/frontswap.c           |   6 +-
 mm/swapfile.c            | 145 +++++++++++++++++++++++++++++------------------
 4 files changed, 97 insertions(+), 59 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8bb85d6..9155bcd 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -214,7 +214,8 @@ struct percpu_cluster {
 struct swap_info_struct {
 	unsigned long	flags;		/* SWP_USED etc: see above */
 	signed short	prio;		/* swap priority of this type */
-	struct list_head list;		/* entry in swap list */
+	struct plist_node list;		/* entry in swap_active_head */
+	struct plist_node avail_list;	/* entry in swap_avail_head */
 	signed char	type;		/* strange name for an index */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
index 2eab382..388293a 100644
--- a/include/linux/swapfile.h
+++ b/include/linux/swapfile.h
@@ -6,7 +6,7 @@
  * want to expose them to the dozens of source files that include swap.h
  */
 extern spinlock_t swap_lock;
-extern struct list_head swap_list_head;
+extern struct plist_head swap_active_head;
 extern struct swap_info_struct *swap_info[];
 extern int try_to_unuse(unsigned int, bool, unsigned long);
 
diff --git a/mm/frontswap.c b/mm/frontswap.c
index fae1160..c30eec5 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -331,7 +331,7 @@ static unsigned long __frontswap_curr_pages(void)
 	struct swap_info_struct *si = NULL;
 
 	assert_spin_locked(&swap_lock);
-	list_for_each_entry(si, &swap_list_head, list)
+	plist_for_each_entry(si, &swap_active_head, list)
 		totalpages += atomic_read(&si->frontswap_pages);
 	return totalpages;
 }
@@ -346,7 +346,7 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
 	unsigned long pages = 0, pages_to_unuse = 0;
 
 	assert_spin_locked(&swap_lock);
-	list_for_each_entry(si, &swap_list_head, list) {
+	plist_for_each_entry(si, &swap_active_head, list) {
 		si_frontswap_pages = atomic_read(&si->frontswap_pages);
 		if (total_pages_to_unuse < si_frontswap_pages) {
 			pages = pages_to_unuse = total_pages_to_unuse;
@@ -408,7 +408,7 @@ void frontswap_shrink(unsigned long target_pages)
 	/*
 	 * we don't want to hold swap_lock while doing a very
 	 * lengthy try_to_unuse, but swap_list may change
-	 * so restart scan from swap_list_head each time
+	 * so restart scan from swap_active_head each time
 	 */
 	spin_lock(&swap_lock);
 	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6c95a8c..beeeef8 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -61,7 +61,22 @@ static const char Unused_offset[] = "Unused swap offset entry ";
  * all active swap_info_structs
  * protected with swap_lock, and ordered by priority.
  */
-LIST_HEAD(swap_list_head);
+PLIST_HEAD(swap_active_head);
+
+/*
+ * all available (active, not full) swap_info_structs
+ * protected with swap_avail_lock, ordered by priority.
+ * This is used by get_swap_page() instead of swap_active_head
+ * because swap_active_head includes all swap_info_structs,
+ * but get_swap_page() doesn't need to look at full ones.
+ * This uses its own lock instead of swap_lock because when a
+ * swap_info_struct changes between not-full/full, it needs to
+ * add/remove itself to/from this list, but the swap_info_struct->lock
+ * is held and the locking order requires swap_lock to be taken
+ * before any swap_info_struct->lock.
+ */
+static PLIST_HEAD(swap_avail_head);
+static DEFINE_SPINLOCK(swap_avail_lock);
 
 struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
@@ -594,6 +609,9 @@ checks:
 	if (si->inuse_pages == si->pages) {
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
+		spin_lock(&swap_avail_lock);
+		plist_del(&si->avail_list, &swap_avail_head);
+		spin_unlock(&swap_avail_lock);
 	}
 	si->swap_map[offset] = usage;
 	inc_cluster_info_page(si, si->cluster_info, offset);
@@ -645,57 +663,63 @@ swp_entry_t get_swap_page(void)
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
+	spin_lock(&swap_avail_lock);
+
+start_over:
+	plist_for_each_entry_safe(si, next, &swap_avail_head, avail_list) {
+		/* requeue si to after same-priority siblings */
+		plist_requeue(&si->avail_list, &swap_avail_head);
+		spin_unlock(&swap_avail_lock);
 		spin_lock(&si->lock);
 		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
+			spin_lock(&swap_avail_lock);
+			if (plist_node_empty(&si->avail_list)) {
+				spin_unlock(&si->lock);
+				goto nextsi;
+			}
+			WARN(!si->highest_bit,
+			     "swap_info %d in list but !highest_bit\n",
+			     si->type);
+			WARN(!(si->flags & SWP_WRITEOK),
+			     "swap_info %d in list but !SWP_WRITEOK\n",
+			     si->type);
+			plist_del(&si->avail_list, &swap_avail_head);
 			spin_unlock(&si->lock);
-			continue;
+			goto nextsi;
 		}
 
-		/*
-		 * rotate the current swap_info that we're going to use
-		 * to after any other swap_info that have the same prio,
-		 * so that all equal-priority swap_info get used equally
-		 */
-		next = si;
-		list_for_each_entry_continue(next, &swap_list_head, list) {
-			if (si->prio != next->prio)
-				break;
-			list_rotate_left(&si->list);
-			next = si;
-		}
-
-		spin_unlock(&swap_lock);
 		/* This is called for allocating swap entry for cache */
 		offset = scan_swap_map(si, SWAP_HAS_CACHE);
 		spin_unlock(&si->lock);
 		if (offset)
 			return swp_entry(si->type, offset);
-		spin_lock(&swap_lock);
+		pr_debug("scan_swap_map of si %d failed to find offset\n",
+		       si->type);
+		spin_lock(&swap_avail_lock);
+nextsi:
 		/*
 		 * if we got here, it's likely that si was almost full before,
 		 * and since scan_swap_map() can drop the si->lock, multiple
 		 * callers probably all tried to get a page from the same si
-		 * and it filled up before we could get one.  So we need to
-		 * try again.  Since we dropped the swap_lock, there may now
-		 * be non-full higher priority swap_infos, and this si may have
-		 * even been removed from the list (although very unlikely).
-		 * Let's start over.
+		 * and it filled up before we could get one; or, the si filled
+		 * up between us dropping swap_avail_lock and taking si->lock.
+		 * Since we dropped the swap_avail_lock, the swap_avail_head
+		 * list may have been modified; so if next is still in the
+		 * swap_avail_head list then try it, otherwise start over.
 		 */
-		tmp = &swap_list_head;
+		if (plist_node_empty(&next->avail_list))
+			goto start_over;
 	}
 
+	spin_unlock(&swap_avail_lock);
+
 	atomic_long_inc(&nr_swap_pages);
 noswap:
-	spin_unlock(&swap_lock);
 	return (swp_entry_t) {0};
 }
 
@@ -798,8 +822,18 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 		dec_cluster_info_page(p, p->cluster_info, offset);
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
-		if (offset > p->highest_bit)
+		if (offset > p->highest_bit) {
+			bool was_full = !p->highest_bit;
 			p->highest_bit = offset;
+			if (was_full && (p->flags & SWP_WRITEOK)) {
+				spin_lock(&swap_avail_lock);
+				WARN_ON(!plist_node_empty(&p->avail_list));
+				if (plist_node_empty(&p->avail_list))
+					plist_add(&p->avail_list,
+						  &swap_avail_head);
+				spin_unlock(&swap_avail_lock);
+			}
+		}
 		atomic_long_inc(&nr_swap_pages);
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
@@ -1734,12 +1768,16 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				struct swap_cluster_info *cluster_info)
 {
-	struct swap_info_struct *si;
-
 	if (prio >= 0)
 		p->prio = prio;
 	else
 		p->prio = --least_priority;
+	/*
+	 * the plist prio is negated because plist ordering is
+	 * low-to-high, while swap ordering is high-to-low
+	 */
+	p->list.prio = -p->prio;
+	p->avail_list.prio = -p->prio;
 	p->swap_map = swap_map;
 	p->cluster_info = cluster_info;
 	p->flags |= SWP_WRITEOK;
@@ -1747,27 +1785,20 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	total_swap_pages += p->pages;
 
 	assert_spin_locked(&swap_lock);
-	BUG_ON(!list_empty(&p->list));
-	/*
-	 * insert into swap list; the list is in priority order,
-	 * so that get_swap_page() can get a page from the highest
-	 * priority swap_info_struct with available page(s), and
-	 * swapoff can adjust the auto-assigned (i.e. negative) prio
-	 * values for any lower-priority swap_info_structs when
-	 * removing a negative-prio swap_info_struct
-	 */
-	list_for_each_entry(si, &swap_list_head, list) {
-		if (p->prio >= si->prio) {
-			list_add_tail(&p->list, &si->list);
-			return;
-		}
-	}
 	/*
-	 * this covers two cases:
-	 * 1) p->prio is less than all existing prio
-	 * 2) the swap list is empty
+	 * both lists are plists, and thus priority ordered.
+	 * swap_active_head needs to be priority ordered for swapoff(),
+	 * which on removal of any swap_info_struct with an auto-assigned
+	 * (i.e. negative) priority increments the auto-assigned priority
+	 * of any lower-priority swap_info_structs.
+	 * swap_avail_head needs to be priority ordered for get_swap_page(),
+	 * which allocates swap pages from the highest available priority
+	 * swap_info_struct.
 	 */
-	list_add_tail(&p->list, &swap_list_head);
+	plist_add(&p->list, &swap_active_head);
+	spin_lock(&swap_avail_lock);
+	plist_add(&p->avail_list, &swap_avail_head);
+	spin_unlock(&swap_avail_lock);
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
@@ -1821,7 +1852,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 
 	mapping = victim->f_mapping;
 	spin_lock(&swap_lock);
-	list_for_each_entry(p, &swap_list_head, list) {
+	plist_for_each_entry(p, &swap_active_head, list) {
 		if (p->flags & SWP_WRITEOK) {
 			if (p->swap_file->f_mapping == mapping) {
 				found = 1;
@@ -1841,16 +1872,21 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		spin_unlock(&swap_lock);
 		goto out_dput;
 	}
+	spin_lock(&swap_avail_lock);
+	plist_del(&p->avail_list, &swap_avail_head);
+	spin_unlock(&swap_avail_lock);
 	spin_lock(&p->lock);
 	if (p->prio < 0) {
 		struct swap_info_struct *si = p;
 
-		list_for_each_entry_continue(si, &swap_list_head, list) {
+		plist_for_each_entry_continue(si, &swap_active_head, list) {
 			si->prio++;
+			si->list.prio--;
+			si->avail_list.prio--;
 		}
 		least_priority++;
 	}
-	list_del_init(&p->list);
+	plist_del(&p->list, &swap_active_head);
 	atomic_long_sub(p->pages, &nr_swap_pages);
 	total_swap_pages -= p->pages;
 	p->flags &= ~SWP_WRITEOK;
@@ -2115,7 +2151,8 @@ static struct swap_info_struct *alloc_swap_info(void)
 		 */
 	}
 	INIT_LIST_HEAD(&p->first_swap_extent.list);
-	INIT_LIST_HEAD(&p->list);
+	plist_node_init(&p->list, 0);
+	plist_node_init(&p->avail_list, 0);
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
