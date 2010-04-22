Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C8DEC6B0205
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:44:34 -0400 (EDT)
Date: Thu, 22 Apr 2010 06:43:49 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Frontswap [PATCH 3/4] (was Transcendent Memory): add hooks in swap
	subsystem
Message-ID: <20100422134349.GA3062@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Frontswap [PATCH 3/4] (was Transcendent Memory): add hooks in swap subsystem

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 page_io.c                                |   12 ++++
 swap.c                                   |    4 +
 swapfile.c                               |   58 +++++++++++++++++----
 3 files changed, 65 insertions(+), 9 deletions(-)

--- linux-2.6.34-rc5/mm/swapfile.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-frontswap/mm/swapfile.c	2010-04-21 09:37:03.000000000 -0600
@@ -35,13 +35,15 @@
 #include <asm/tlbflush.h>
 #include <linux/swapops.h>
 #include <linux/page_cgroup.h>
+#include <linux/frontswap.h>
+#include <linux/swapfile.h>
 
 static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
 				 unsigned char);
 static void free_swap_count_continuations(struct swap_info_struct *);
 static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 
-static DEFINE_SPINLOCK(swap_lock);
+DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 long nr_swap_pages;
 long total_swap_pages;
@@ -52,9 +54,9 @@ static const char Unused_file[] = "Unuse
 static const char Bad_offset[] = "Bad swap offset entry ";
 static const char Unused_offset[] = "Unused swap offset entry ";
 
-static struct swap_list_t swap_list = {-1, -1};
+struct swap_list_t swap_list = {-1, -1};
 
-static struct swap_info_struct *swap_info[MAX_SWAPFILES];
+struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
 static DEFINE_MUTEX(swapon_mutex);
 
@@ -583,6 +585,7 @@ static unsigned char swap_entry_free(str
 			swap_list.next = p->type;
 		nr_swap_pages++;
 		p->inuse_pages--;
+		frontswap_flush_page(p->type, offset);
 	}
 
 	return usage;
@@ -1025,7 +1028,7 @@ static int unuse_mm(struct mm_struct *mm
  * Recycle to start on reaching the end, returning 0 when empty.
  */
 static unsigned int find_next_to_unuse(struct swap_info_struct *si,
-					unsigned int prev)
+				unsigned int prev, bool frontswap)
 {
 	unsigned int max = si->max;
 	unsigned int i = prev;
@@ -1051,6 +1054,12 @@ static unsigned int find_next_to_unuse(s
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
@@ -1062,8 +1071,12 @@ static unsigned int find_next_to_unuse(s
  * We completely avoid races by reading each swap page in advance,
  * and then search for the process using it.  All the necessary
  * page table adjustments can then be made atomically.
+ *
+ * if the boolean frontswap is true, only unuse pages_to_unuse pages;
+ * pages_to_unuse==0 means all pages
  */
-static int try_to_unuse(unsigned int type)
+int try_to_unuse(unsigned int type, bool frontswap,
+		unsigned long pages_to_unuse)
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
@@ -1096,7 +1109,7 @@ static int try_to_unuse(unsigned int typ
 	 * one pass through swap_map is enough, but not necessarily:
 	 * there are races when an instance of an entry might be missed.
 	 */
-	while ((i = find_next_to_unuse(si, i)) != 0) {
+	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		if (signal_pending(current)) {
 			retval = -EINTR;
 			break;
@@ -1263,6 +1276,10 @@ static int try_to_unuse(unsigned int typ
 		 * interactive performance.
 		 */
 		cond_resched();
+		if (frontswap && pages_to_unuse > 0) {
+			if (!--pages_to_unuse)
+				break;
+		}
 	}
 
 	mmput(start_mm);
@@ -1588,7 +1605,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	spin_unlock(&swap_lock);
 
 	current->flags |= PF_OOM_ORIGIN;
-	err = try_to_unuse(type);
+	err = try_to_unuse(type, false, 0);
 	current->flags &= ~PF_OOM_ORIGIN;
 
 	if (err) {
@@ -1640,9 +1657,12 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	frontswap_flush_area(type);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	if (p->frontswap_map)
+		vfree(p->frontswap_map);
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
 
@@ -1798,6 +1818,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 	unsigned long maxpages;
 	unsigned long swapfilepages;
 	unsigned char *swap_map = NULL;
+	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
 	int did_down = 0;
@@ -2019,6 +2040,13 @@ SYSCALL_DEFINE2(swapon, const char __use
 		goto bad_swap;
 	}
 
+	/* frontswap enabled? set up bit-per-page map for frontswap */
+	if (frontswap_ops) {
+		frontswap_map = vmalloc(maxpages / sizeof(long));
+		if (frontswap_map)
+			memset(frontswap_map, 0, maxpages / sizeof(long));
+	}
+
 	if (p->bdev) {
 		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 			p->flags |= SWP_SOLIDSTATE;
@@ -2036,16 +2064,18 @@ SYSCALL_DEFINE2(swapon, const char __use
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
+	p->frontswap_map = frontswap_map;
 	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += nr_good_pages;
 	total_swap_pages += nr_good_pages;
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
-			"Priority:%d extents:%d across:%lluk %s%s\n",
+			"Priority:%d extents:%d across:%lluk %s%s%s\n",
 		nr_good_pages<<(PAGE_SHIFT-10), name, p->prio,
 		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
 		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
-		(p->flags & SWP_DISCARDABLE) ? "D" : "");
+		(p->flags & SWP_DISCARDABLE) ? "D" : "",
+		(p->frontswap_map) ? "FS" : "");
 
 	/* insert swap space into swap_list: */
 	prev = -1;
@@ -2243,6 +2273,10 @@ int valid_swaphandles(swp_entry_t entry,
 		base++;
 
 	spin_lock(&swap_lock);
+	if (frontswap_test(si, target)) {
+		spin_unlock(&swap_lock);
+		return 0;
+	}
 	if (end > si->max)	/* don't go beyond end of map */
 		end = si->max;
 
@@ -2253,6 +2287,9 @@ int valid_swaphandles(swp_entry_t entry,
 			break;
 		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
 			break;
+		/* Don't read in frontswap pages */
+		if (frontswap_test(si, toff))
+			break;
 	}
 	/* Count contiguous allocated slots below our target */
 	for (toff = target; --toff >= base; nr_pages++) {
@@ -2261,6 +2298,9 @@ int valid_swaphandles(swp_entry_t entry,
 			break;
 		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
 			break;
+		/* Don't read in frontswap pages */
+		if (frontswap_test(si, toff))
+			break;
 	}
 	spin_unlock(&swap_lock);
 
--- linux-2.6.34-rc5/mm/swap.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-frontswap/mm/swap.c	2010-04-21 09:34:44.000000000 -0600
@@ -31,6 +31,7 @@
 #include <linux/backing-dev.h>
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
+#include <linux/frontswap.h>
 
 #include "internal.h"
 
@@ -501,6 +502,9 @@ void __init swap_setup(void)
 
 #ifdef CONFIG_SWAP
 	bdi_init(swapper_space.backing_dev_info);
+
+	if (frontswap_ops)
+		frontswap_init();
 #endif
 
 	/* Use a smaller cluster for small-memory machines */
--- linux-2.6.34-rc5/mm/page_io.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-frontswap/mm/page_io.c	2010-04-21 08:59:49.000000000 -0600
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
+	if (frontswap_put_page(page) == 1) {
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
+	if (frontswap_get_page(page) == 1) {
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
