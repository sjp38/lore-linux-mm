Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id A28BA6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:38:54 -0400 (EDT)
Received: by mail-yk0-f170.google.com with SMTP id 10so6185766ykt.1
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:38:54 -0700 (PDT)
Received: from mail-yh0-x22b.google.com (mail-yh0-x22b.google.com [2607:f8b0:4002:c01::22b])
        by mx.google.com with ESMTPS id g26si16654888yhb.110.2014.05.12.09.38.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 09:38:54 -0700 (PDT)
Received: by mail-yh0-f43.google.com with SMTP id v1so1906577yhn.16
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:38:54 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv2 1/4] swap: change swap_info singly-linked list to list_head
Date: Mon, 12 May 2014 12:38:17 -0400
Message-Id: <1399912700-30100-2-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1399912700-30100-1-git-send-email-ddstreet@ieee.org>
References: <1399057350-16300-1-git-send-email-ddstreet@ieee.org>
 <1399912700-30100-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Dan Streetman <ddstreet@ieee.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>

Replace the singly-linked list tracking active, i.e. swapon'ed,
swap_info_struct entries with a doubly-linked list using struct list_heads.
Simplify the logic iterating and manipulating the list of entries,
especially get_swap_page(), by using standard list_head functions,
and removing the highest priority iteration logic.

The change fixes the bug:
https://lkml.org/lkml/2014/2/13/181
in which different priority swap entries after the highest priority entry
are incorrectly used equally in pairs.  The swap behavior is now as
advertised, i.e. different priority swap entries are used in order, and
equal priority swap targets are used concurrently.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Shaohua Li <shli@fusionio.com>

---

This is only a resend, this patch isn't changed in this patch set.
Previous is at https://lkml.org/lkml/2014/5/2/489

 include/linux/swap.h     |   7 +-
 include/linux/swapfile.h |   2 +-
 mm/frontswap.c           |  13 ++--
 mm/swapfile.c            | 171 ++++++++++++++++++++---------------------------
 4 files changed, 78 insertions(+), 115 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 5a14b92..8bb85d6 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -214,8 +214,8 @@ struct percpu_cluster {
 struct swap_info_struct {
 	unsigned long	flags;		/* SWP_USED etc: see above */
 	signed short	prio;		/* swap priority of this type */
+	struct list_head list;		/* entry in swap list */
 	signed char	type;		/* strange name for an index */
-	signed char	next;		/* next type on the swap list */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
 	struct swap_cluster_info *cluster_info; /* cluster info. Only for SSD */
@@ -255,11 +255,6 @@ struct swap_info_struct {
 	struct swap_cluster_info discard_cluster_tail; /* list tail of discard clusters */
 };
 
-struct swap_list_t {
-	int head;	/* head of priority-ordered swapfile list */
-	int next;	/* swapfile to be used next */
-};
-
 /* linux/mm/workingset.c */
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
index e282624..2eab382 100644
--- a/include/linux/swapfile.h
+++ b/include/linux/swapfile.h
@@ -6,7 +6,7 @@
  * want to expose them to the dozens of source files that include swap.h
  */
 extern spinlock_t swap_lock;
-extern struct swap_list_t swap_list;
+extern struct list_head swap_list_head;
 extern struct swap_info_struct *swap_info[];
 extern int try_to_unuse(unsigned int, bool, unsigned long);
 
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 1b24bdc..fae1160 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -327,15 +327,12 @@ EXPORT_SYMBOL(__frontswap_invalidate_area);
 
 static unsigned long __frontswap_curr_pages(void)
 {
-	int type;
 	unsigned long totalpages = 0;
 	struct swap_info_struct *si = NULL;
 
 	assert_spin_locked(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = si->next) {
-		si = swap_info[type];
+	list_for_each_entry(si, &swap_list_head, list)
 		totalpages += atomic_read(&si->frontswap_pages);
-	}
 	return totalpages;
 }
 
@@ -347,11 +344,9 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
 	int si_frontswap_pages;
 	unsigned long total_pages_to_unuse = total;
 	unsigned long pages = 0, pages_to_unuse = 0;
-	int type;
 
 	assert_spin_locked(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = si->next) {
-		si = swap_info[type];
+	list_for_each_entry(si, &swap_list_head, list) {
 		si_frontswap_pages = atomic_read(&si->frontswap_pages);
 		if (total_pages_to_unuse < si_frontswap_pages) {
 			pages = pages_to_unuse = total_pages_to_unuse;
@@ -366,7 +361,7 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
 		}
 		vm_unacct_memory(pages);
 		*unused = pages_to_unuse;
-		*swapid = type;
+		*swapid = si->type;
 		ret = 0;
 		break;
 	}
@@ -413,7 +408,7 @@ void frontswap_shrink(unsigned long target_pages)
 	/*
 	 * we don't want to hold swap_lock while doing a very
 	 * lengthy try_to_unuse, but swap_list may change
-	 * so restart scan from swap_list.head each time
+	 * so restart scan from swap_list_head each time
 	 */
 	spin_lock(&swap_lock);
 	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4a7f7e6..6c95a8c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -51,14 +51,17 @@ atomic_long_t nr_swap_pages;
 /* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
 long total_swap_pages;
 static int least_priority;
-static atomic_t highest_priority_index = ATOMIC_INIT(-1);
 
 static const char Bad_file[] = "Bad swap file entry ";
 static const char Unused_file[] = "Unused swap file entry ";
 static const char Bad_offset[] = "Bad swap offset entry ";
 static const char Unused_offset[] = "Unused swap offset entry ";
 
-struct swap_list_t swap_list = {-1, -1};
+/*
+ * all active swap_info_structs
+ * protected with swap_lock, and ordered by priority.
+ */
+LIST_HEAD(swap_list_head);
 
 struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
@@ -640,66 +643,54 @@ no_page:
 
 swp_entry_t get_swap_page(void)
 {
-	struct swap_info_struct *si;
+	struct swap_info_struct *si, *next;
 	pgoff_t offset;
-	int type, next;
-	int wrapped = 0;
-	int hp_index;
+	struct list_head *tmp;
 
 	spin_lock(&swap_lock);
 	if (atomic_long_read(&nr_swap_pages) <= 0)
 		goto noswap;
 	atomic_long_dec(&nr_swap_pages);
 
-	for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
-		hp_index = atomic_xchg(&highest_priority_index, -1);
-		/*
-		 * highest_priority_index records current highest priority swap
-		 * type which just frees swap entries. If its priority is
-		 * higher than that of swap_list.next swap type, we use it.  It
-		 * isn't protected by swap_lock, so it can be an invalid value
-		 * if the corresponding swap type is swapoff. We double check
-		 * the flags here. It's even possible the swap type is swapoff
-		 * and swapon again and its priority is changed. In such rare
-		 * case, low prority swap type might be used, but eventually
-		 * high priority swap will be used after several rounds of
-		 * swap.
-		 */
-		if (hp_index != -1 && hp_index != type &&
-		    swap_info[type]->prio < swap_info[hp_index]->prio &&
-		    (swap_info[hp_index]->flags & SWP_WRITEOK)) {
-			type = hp_index;
-			swap_list.next = type;
-		}
-
-		si = swap_info[type];
-		next = si->next;
-		if (next < 0 ||
-		    (!wrapped && si->prio != swap_info[next]->prio)) {
-			next = swap_list.head;
-			wrapped++;
-		}
-
+	list_for_each(tmp, &swap_list_head) {
+		si = list_entry(tmp, typeof(*si), list);
 		spin_lock(&si->lock);
-		if (!si->highest_bit) {
-			spin_unlock(&si->lock);
-			continue;
-		}
-		if (!(si->flags & SWP_WRITEOK)) {
+		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
 			spin_unlock(&si->lock);
 			continue;
 		}
 
-		swap_list.next = next;
+		/*
+		 * rotate the current swap_info that we're going to use
+		 * to after any other swap_info that have the same prio,
+		 * so that all equal-priority swap_info get used equally
+		 */
+		next = si;
+		list_for_each_entry_continue(next, &swap_list_head, list) {
+			if (si->prio != next->prio)
+				break;
+			list_rotate_left(&si->list);
+			next = si;
+		}
 
 		spin_unlock(&swap_lock);
 		/* This is called for allocating swap entry for cache */
 		offset = scan_swap_map(si, SWAP_HAS_CACHE);
 		spin_unlock(&si->lock);
 		if (offset)
-			return swp_entry(type, offset);
+			return swp_entry(si->type, offset);
 		spin_lock(&swap_lock);
-		next = swap_list.next;
+		/*
+		 * if we got here, it's likely that si was almost full before,
+		 * and since scan_swap_map() can drop the si->lock, multiple
+		 * callers probably all tried to get a page from the same si
+		 * and it filled up before we could get one.  So we need to
+		 * try again.  Since we dropped the swap_lock, there may now
+		 * be non-full higher priority swap_infos, and this si may have
+		 * even been removed from the list (although very unlikely).
+		 * Let's start over.
+		 */
+		tmp = &swap_list_head;
 	}
 
 	atomic_long_inc(&nr_swap_pages);
@@ -766,27 +757,6 @@ out:
 	return NULL;
 }
 
-/*
- * This swap type frees swap entry, check if it is the highest priority swap
- * type which just frees swap entry. get_swap_page() uses
- * highest_priority_index to search highest priority swap type. The
- * swap_info_struct.lock can't protect us if there are multiple swap types
- * active, so we use atomic_cmpxchg.
- */
-static void set_highest_priority_index(int type)
-{
-	int old_hp_index, new_hp_index;
-
-	do {
-		old_hp_index = atomic_read(&highest_priority_index);
-		if (old_hp_index != -1 &&
-			swap_info[old_hp_index]->prio >= swap_info[type]->prio)
-			break;
-		new_hp_index = type;
-	} while (atomic_cmpxchg(&highest_priority_index,
-		old_hp_index, new_hp_index) != old_hp_index);
-}
-
 static unsigned char swap_entry_free(struct swap_info_struct *p,
 				     swp_entry_t entry, unsigned char usage)
 {
@@ -830,7 +800,6 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
 			p->highest_bit = offset;
-		set_highest_priority_index(p->type);
 		atomic_long_inc(&nr_swap_pages);
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
@@ -1765,7 +1734,7 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				struct swap_cluster_info *cluster_info)
 {
-	int i, prev;
+	struct swap_info_struct *si;
 
 	if (prio >= 0)
 		p->prio = prio;
@@ -1777,18 +1746,28 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	atomic_long_add(p->pages, &nr_swap_pages);
 	total_swap_pages += p->pages;
 
-	/* insert swap space into swap_list: */
-	prev = -1;
-	for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
-		if (p->prio >= swap_info[i]->prio)
-			break;
-		prev = i;
+	assert_spin_locked(&swap_lock);
+	BUG_ON(!list_empty(&p->list));
+	/*
+	 * insert into swap list; the list is in priority order,
+	 * so that get_swap_page() can get a page from the highest
+	 * priority swap_info_struct with available page(s), and
+	 * swapoff can adjust the auto-assigned (i.e. negative) prio
+	 * values for any lower-priority swap_info_structs when
+	 * removing a negative-prio swap_info_struct
+	 */
+	list_for_each_entry(si, &swap_list_head, list) {
+		if (p->prio >= si->prio) {
+			list_add_tail(&p->list, &si->list);
+			return;
+		}
 	}
-	p->next = i;
-	if (prev < 0)
-		swap_list.head = swap_list.next = p->type;
-	else
-		swap_info[prev]->next = p->type;
+	/*
+	 * this covers two cases:
+	 * 1) p->prio is less than all existing prio
+	 * 2) the swap list is empty
+	 */
+	list_add_tail(&p->list, &swap_list_head);
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
@@ -1823,8 +1802,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	struct address_space *mapping;
 	struct inode *inode;
 	struct filename *pathname;
-	int i, type, prev;
-	int err;
+	int err, found = 0;
 	unsigned int old_block_size;
 
 	if (!capable(CAP_SYS_ADMIN))
@@ -1842,17 +1820,16 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		goto out;
 
 	mapping = victim->f_mapping;
-	prev = -1;
 	spin_lock(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = swap_info[type]->next) {
-		p = swap_info[type];
+	list_for_each_entry(p, &swap_list_head, list) {
 		if (p->flags & SWP_WRITEOK) {
-			if (p->swap_file->f_mapping == mapping)
+			if (p->swap_file->f_mapping == mapping) {
+				found = 1;
 				break;
+			}
 		}
-		prev = type;
 	}
-	if (type < 0) {
+	if (!found) {
 		err = -EINVAL;
 		spin_unlock(&swap_lock);
 		goto out_dput;
@@ -1864,20 +1841,16 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		spin_unlock(&swap_lock);
 		goto out_dput;
 	}
-	if (prev < 0)
-		swap_list.head = p->next;
-	else
-		swap_info[prev]->next = p->next;
-	if (type == swap_list.next) {
-		/* just pick something that's safe... */
-		swap_list.next = swap_list.head;
-	}
 	spin_lock(&p->lock);
 	if (p->prio < 0) {
-		for (i = p->next; i >= 0; i = swap_info[i]->next)
-			swap_info[i]->prio = p->prio--;
+		struct swap_info_struct *si = p;
+
+		list_for_each_entry_continue(si, &swap_list_head, list) {
+			si->prio++;
+		}
 		least_priority++;
 	}
+	list_del_init(&p->list);
 	atomic_long_sub(p->pages, &nr_swap_pages);
 	total_swap_pages -= p->pages;
 	p->flags &= ~SWP_WRITEOK;
@@ -1885,7 +1858,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	spin_unlock(&swap_lock);
 
 	set_current_oom_origin();
-	err = try_to_unuse(type, false, 0); /* force all pages to be unused */
+	err = try_to_unuse(p->type, false, 0); /* force unuse all pages */
 	clear_current_oom_origin();
 
 	if (err) {
@@ -1926,7 +1899,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	frontswap_map = frontswap_map_get(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
-	frontswap_invalidate_area(type);
+	frontswap_invalidate_area(p->type);
 	frontswap_map_set(p, NULL);
 	mutex_unlock(&swapon_mutex);
 	free_percpu(p->percpu_cluster);
@@ -1935,7 +1908,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	vfree(cluster_info);
 	vfree(frontswap_map);
 	/* Destroy swap account information */
-	swap_cgroup_swapoff(type);
+	swap_cgroup_swapoff(p->type);
 
 	inode = mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
@@ -2142,8 +2115,8 @@ static struct swap_info_struct *alloc_swap_info(void)
 		 */
 	}
 	INIT_LIST_HEAD(&p->first_swap_extent.list);
+	INIT_LIST_HEAD(&p->list);
 	p->flags = SWP_USED;
-	p->next = -1;
 	spin_unlock(&swap_lock);
 	spin_lock_init(&p->lock);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
