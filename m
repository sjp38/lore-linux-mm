Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE7F6B016C
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 10:59:08 -0400 (EDT)
Date: Tue, 23 Aug 2011 07:58:35 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Subject: [PATCH V7 3/4] mm: frontswap: add swap hooks and extend
	try_to_unuse
Message-ID: <20110823145835.GA23222@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V7 3/4] mm: frontswap: add swap hooks and extend try_to_unuse

This third patch of four in the frontswap series adds hooks in the swap
subsystem and extends try_to_unuse so that frontswap_shrink can do a
"partial swapoff".  Also, declarations for the extern-ified swap variables
in the first patch are declared.

Note that failed frontswap_map allocation is safe... failure is noted
by lack of "FS" in the subsequent printk.

[v7: rebase to 3.0-rc3]
[v7: JBeulich@novell.com: use new static inlines, no-ops if not config'd]
[v6: rebase to 3.1-rc1]
[v6: lliubbo@gmail.com: use vzalloc]
[v5: accidentally posted stale code for v4 that failed to compile :-(]
[v4: rebase to 2.6.39]
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
Acked-by: Jan Beulich <JBeulich@novell.com>
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Chris Mason <chris.mason@oracle.com>
Cc: Rik Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

--- linux/mm/swapfile.c	2011-08-08 08:19:26.336684746 -0600
+++ frontswap/mm/swapfile.c	2011-08-23 08:21:15.301998803 -0600
@@ -32,6 +32,8 @@
 #include <linux/memcontrol.h>
 #include <linux/poll.h>
 #include <linux/oom.h>
+#include <linux/frontswap.h>
+#include <linux/swapfile.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -43,7 +45,7 @@ static bool swap_count_continued(struct 
 static void free_swap_count_continuations(struct swap_info_struct *);
 static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 
-static DEFINE_SPINLOCK(swap_lock);
+DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 long nr_swap_pages;
 long total_swap_pages;
@@ -54,9 +56,9 @@ static const char Unused_file[] = "Unuse
 static const char Bad_offset[] = "Bad swap offset entry ";
 static const char Unused_offset[] = "Unused swap offset entry ";
 
-static struct swap_list_t swap_list = {-1, -1};
+struct swap_list_t swap_list = {-1, -1};
 
-static struct swap_info_struct *swap_info[MAX_SWAPFILES];
+struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
 static DEFINE_MUTEX(swapon_mutex);
 
@@ -557,6 +559,7 @@ static unsigned char swap_entry_free(str
 			swap_list.next = p->type;
 		nr_swap_pages++;
 		p->inuse_pages--;
+		frontswap_flush_page(p->type, offset);
 		if ((p->flags & SWP_BLKDEV) &&
 				disk->fops->swap_slot_free_notify)
 			disk->fops->swap_slot_free_notify(p->bdev, offset);
@@ -1022,7 +1025,7 @@ static int unuse_mm(struct mm_struct *mm
  * Recycle to start on reaching the end, returning 0 when empty.
  */
 static unsigned int find_next_to_unuse(struct swap_info_struct *si,
-					unsigned int prev)
+					unsigned int prev, bool frontswap)
 {
 	unsigned int max = si->max;
 	unsigned int i = prev;
@@ -1048,6 +1051,12 @@ static unsigned int find_next_to_unuse(s
 			prev = 0;
 			i = 1;
 		}
+		if (frontswap) {
+			if (frontswap_test(si, i))
+				break;
+			else
+				continue;
+		}
 		count = si->swap_map[i];
 		if (count && swap_count(count) != SWAP_MAP_BAD)
 			break;
@@ -1059,8 +1068,12 @@ static unsigned int find_next_to_unuse(s
  * We completely avoid races by reading each swap page in advance,
  * and then search for the process using it.  All the necessary
  * page table adjustments can then be made atomically.
+ *
+ * if the boolean frontswap is true, only unuse pages_to_unuse pages;
+ * pages_to_unuse==0 means all pages; ignored if frontswap is false
  */
-static int try_to_unuse(unsigned int type)
+int try_to_unuse(unsigned int type, bool frontswap,
+		 unsigned long pages_to_unuse)
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
@@ -1093,7 +1106,7 @@ static int try_to_unuse(unsigned int typ
 	 * one pass through swap_map is enough, but not necessarily:
 	 * there are races when an instance of an entry might be missed.
 	 */
-	while ((i = find_next_to_unuse(si, i)) != 0) {
+	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		if (signal_pending(current)) {
 			retval = -EINTR;
 			break;
@@ -1260,6 +1273,10 @@ static int try_to_unuse(unsigned int typ
 		 * interactive performance.
 		 */
 		cond_resched();
+		if (frontswap && pages_to_unuse > 0) {
+			if (!--pages_to_unuse)
+				break;
+		}
 	}
 
 	mmput(start_mm);
@@ -1519,7 +1536,8 @@ bad_bmap:
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
-				unsigned char *swap_map)
+				unsigned char *swap_map,
+				unsigned long *frontswap_map)
 {
 	int i, prev;
 
@@ -1529,6 +1547,7 @@ static void enable_swap_info(struct swap
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
+	frontswap_map_set(p, frontswap_map);
 	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += p->pages;
 	total_swap_pages += p->pages;
@@ -1545,6 +1564,7 @@ static void enable_swap_info(struct swap
 		swap_list.head = swap_list.next = p->type;
 	else
 		swap_info[prev]->next = p->type;
+	frontswap_init(p->type);
 	spin_unlock(&swap_lock);
 }
 
@@ -1616,7 +1636,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	spin_unlock(&swap_lock);
 
 	oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
-	err = try_to_unuse(type);
+	err = try_to_unuse(type, false, 0); /* force all pages to be unused */
 	test_set_oom_score_adj(oom_score_adj);
 
 	if (err) {
@@ -1627,7 +1647,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
 		 * sys_swapoff for this swap_info_struct at this point.
 		 */
 		/* re-insert swap space back into swap_list */
-		enable_swap_info(p, p->prio, p->swap_map);
+		enable_swap_info(p, p->prio, p->swap_map, frontswap_map_get(p));
 		goto out_dput;
 	}
 
@@ -1653,9 +1673,11 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	frontswap_flush_area(type);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	vfree(frontswap_map_get(p));
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
 
@@ -2019,6 +2041,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 	sector_t span;
 	unsigned long maxpages;
 	unsigned char *swap_map = NULL;
+	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
 
@@ -2099,6 +2122,9 @@ SYSCALL_DEFINE2(swapon, const char __use
 		error = nr_extents;
 		goto bad_swap;
 	}
+	/* frontswap enabled? set up bit-per-page map for frontswap */
+	if (frontswap_enabled)
+		frontswap_map = vzalloc(maxpages / sizeof(long));
 
 	if (p->bdev) {
 		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
@@ -2114,14 +2140,15 @@ SYSCALL_DEFINE2(swapon, const char __use
 	if (swap_flags & SWAP_FLAG_PREFER)
 		prio =
 		  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
-	enable_swap_info(p, prio, swap_map);
+	enable_swap_info(p, prio, swap_map, frontswap_map);
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
-			"Priority:%d extents:%d across:%lluk %s%s\n",
+			"Priority:%d extents:%d across:%lluk %s%s%s\n",
 		p->pages<<(PAGE_SHIFT-10), name, p->prio,
 		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
 		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
-		(p->flags & SWP_DISCARDABLE) ? "D" : "");
+		(p->flags & SWP_DISCARDABLE) ? "D" : "",
+		(frontswap_map) ? "FS" : "");
 
 	mutex_unlock(&swapon_mutex);
 	atomic_inc(&proc_poll_event);
@@ -2312,6 +2339,10 @@ int valid_swaphandles(swp_entry_t entry,
 		base++;
 
 	spin_lock(&swap_lock);
+	if (frontswap_test(si, target)) {
+		spin_unlock(&swap_lock);
+		return 0;
+	}
 	if (end > si->max)	/* don't go beyond end of map */
 		end = si->max;
 
@@ -2322,6 +2353,9 @@ int valid_swaphandles(swp_entry_t entry,
 			break;
 		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
 			break;
+		/* Don't read in frontswap pages */
+		if (frontswap_test(si, toff))
+			break;
 	}
 	/* Count contiguous allocated slots below our target */
 	for (toff = target; --toff >= base; nr_pages++) {
@@ -2330,6 +2364,9 @@ int valid_swaphandles(swp_entry_t entry,
 			break;
 		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
 			break;
+		/* Don't read in frontswap pages */
+		if (frontswap_test(si, toff))
+			break;
 	}
 	spin_unlock(&swap_lock);
 
--- linux/mm/page_io.c	2011-07-20 14:50:42.395999221 -0600
+++ frontswap/mm/page_io.c	2011-08-23 08:20:09.778810690 -0600
@@ -18,6 +18,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/frontswap.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags,
@@ -98,6 +99,12 @@ int swap_writepage(struct page *page, st
 		unlock_page(page);
 		goto out;
 	}
+	if (frontswap_put_page(page) == 0) {
+		set_page_writeback(page);
+		unlock_page(page);
+		end_page_writeback(page);
+		goto out;
+	}
 	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
 	if (bio == NULL) {
 		set_page_dirty(page);
@@ -122,6 +129,11 @@ int swap_readpage(struct page *page)
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageUptodate(page));
+	if (frontswap_get_page(page) == 0) {
+		SetPageUptodate(page);
+		unlock_page(page);
+		goto out;
+	}
 	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
 		unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
