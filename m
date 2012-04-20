Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 89B926B00EB
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 17:49:27 -0400 (EDT)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 2/6] mm: frontswap: core swap subsystem hooks and headers
Date: Fri, 20 Apr 2012 17:44:11 -0400
Message-Id: <1334958255-6612-3-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
References: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, aarcange@redhat.com, dhowells@redhat.com, riel@redhat.com, JBeulich@novell.com
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <matthew@wil.cx>, Chris Mason <chris.mason@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

From: Dan Magenheimer <dan.magenheimer@oracle.com>

This patch, 2of4, contains the changes to the core swap subsystem.
This includes:

(1) makes available core swap data structures (swap_lock, swap_list and
swap_info) that are needed by frontswap.c but we don't need to expose them
to the dozens of files that include swap.h so we create a new swapfile.h
just to extern-ify these and modify their declarations to non-static

(2) adds frontswap-related elements to swap_info_struct.  Frontswap_map
points to vzalloc'ed one-bit-per-swap-page metadata that indicates
whether the swap page is in frontswap or in the device and frontswap_pages
counts how many pages are in frontswap.

(3) adds hooks in the swap subsystem and extends try_to_unuse so that
frontswap_shrink can do a "partial swapoff".

Note that a failed frontswap_map allocation is safe... failure is noted
by lack of "FS" in the subsequent printk.

---

[v14: rebase to 3.4-rc2]
[v10: no change]
[v9: akpm@linux-foundation.org: mark some statics __read_mostly]
[v9: akpm@linux-foundation.org: add clarifying comments]
[v9: akpm@linux-foundation.org: no need to loop repeating try_to_unuse]
[v9: error27@gmail.com: remove superfluous check for NULL]
[v8: rebase to 3.0-rc4]
[v8: kamezawa.hiroyu@jp.fujitsu.com: change counter to atomic_t to avoid races]
[v8: kamezawa.hiroyu@jp.fujitsu.com: comment to clarify informational counters]
[v7: rebase to 3.0-rc3]
[v7: JBeulich@novell.com: add new swap struct elements only if config'd]
[v6: rebase to 3.0-rc1]
[v6: lliubbo@gmail.com: fix null pointer deref if vzalloc fails]
[v6: konrad.wilk@oracl.com: various checks and code clarifications/comments]
[v5: no change from v4]
[v4: rebase to 2.6.39]
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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
[v11: Rebased, fixed mm/swapfile.c context change]
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 include/linux/swap.h     |    4 +++
 include/linux/swapfile.h |   13 +++++++++++
 mm/page_io.c             |   12 ++++++++++
 mm/swapfile.c            |   54 ++++++++++++++++++++++++++++++++++-----------
 4 files changed, 70 insertions(+), 13 deletions(-)
 create mode 100644 include/linux/swapfile.h

diff --git a/include/linux/swap.h b/include/linux/swap.h
index b1fd5c7..50a55e2 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -197,6 +197,10 @@ struct swap_info_struct {
 	struct block_device *bdev;	/* swap device or bdev of swap file */
 	struct file *swap_file;		/* seldom referenced */
 	unsigned int old_block_size;	/* seldom referenced */
+#ifdef CONFIG_FRONTSWAP
+	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
+	atomic_t frontswap_pages;	/* frontswap pages in-use counter */
+#endif
 };
 
 struct swap_list_t {
diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
new file mode 100644
index 0000000..e282624
--- /dev/null
+++ b/include/linux/swapfile.h
@@ -0,0 +1,13 @@
+#ifndef _LINUX_SWAPFILE_H
+#define _LINUX_SWAPFILE_H
+
+/*
+ * these were static in swapfile.c but frontswap.c needs them and we don't
+ * want to expose them to the dozens of source files that include swap.h
+ */
+extern spinlock_t swap_lock;
+extern struct swap_list_t swap_list;
+extern struct swap_info_struct *swap_info[];
+extern int try_to_unuse(unsigned int, bool, unsigned long);
+
+#endif /* _LINUX_SWAPFILE_H */
diff --git a/mm/page_io.c b/mm/page_io.c
index dc76b4d..651a912 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -18,6 +18,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/frontswap.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags,
@@ -98,6 +99,12 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
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
diff --git a/mm/swapfile.c b/mm/swapfile.c
index fafc26d..9c7be87 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -31,6 +31,8 @@
 #include <linux/memcontrol.h>
 #include <linux/poll.h>
 #include <linux/oom.h>
+#include <linux/frontswap.h>
+#include <linux/swapfile.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -42,7 +44,7 @@ static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
 static void free_swap_count_continuations(struct swap_info_struct *);
 static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 
-static DEFINE_SPINLOCK(swap_lock);
+DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 long nr_swap_pages;
 long total_swap_pages;
@@ -53,9 +55,9 @@ static const char Unused_file[] = "Unused swap file entry ";
 static const char Bad_offset[] = "Bad swap offset entry ";
 static const char Unused_offset[] = "Unused swap offset entry ";
 
-static struct swap_list_t swap_list = {-1, -1};
+struct swap_list_t swap_list = {-1, -1};
 
-static struct swap_info_struct *swap_info[MAX_SWAPFILES];
+struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
 static DEFINE_MUTEX(swapon_mutex);
 
@@ -556,6 +558,7 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 			swap_list.next = p->type;
 		nr_swap_pages++;
 		p->inuse_pages--;
+		frontswap_invalidate_page(p->type, offset);
 		if ((p->flags & SWP_BLKDEV) &&
 				disk->fops->swap_slot_free_notify)
 			disk->fops->swap_slot_free_notify(p->bdev, offset);
@@ -1016,11 +1019,12 @@ static int unuse_mm(struct mm_struct *mm,
 }
 
 /*
- * Scan swap_map from current position to next entry still in use.
+ * Scan swap_map (or frontswap_map if frontswap parameter is true)
+ * from current position to next entry still in use.
  * Recycle to start on reaching the end, returning 0 when empty.
  */
 static unsigned int find_next_to_unuse(struct swap_info_struct *si,
-					unsigned int prev)
+					unsigned int prev, bool frontswap)
 {
 	unsigned int max = si->max;
 	unsigned int i = prev;
@@ -1046,6 +1050,12 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
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
@@ -1057,8 +1067,12 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
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
@@ -1091,7 +1105,7 @@ static int try_to_unuse(unsigned int type)
 	 * one pass through swap_map is enough, but not necessarily:
 	 * there are races when an instance of an entry might be missed.
 	 */
-	while ((i = find_next_to_unuse(si, i)) != 0) {
+	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		if (signal_pending(current)) {
 			retval = -EINTR;
 			break;
@@ -1258,6 +1272,10 @@ static int try_to_unuse(unsigned int type)
 		 * interactive performance.
 		 */
 		cond_resched();
+		if (frontswap && pages_to_unuse > 0) {
+			if (!--pages_to_unuse)
+				break;
+		}
 	}
 
 	mmput(start_mm);
@@ -1517,7 +1535,8 @@ bad_bmap:
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
-				unsigned char *swap_map)
+				unsigned char *swap_map,
+				unsigned long *frontswap_map)
 {
 	int i, prev;
 
@@ -1527,6 +1546,7 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
+	frontswap_map_set(p, frontswap_map);
 	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += p->pages;
 	total_swap_pages += p->pages;
@@ -1543,6 +1563,7 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 		swap_list.head = swap_list.next = p->type;
 	else
 		swap_info[prev]->next = p->type;
+	frontswap_init(p->type);
 	spin_unlock(&swap_lock);
 }
 
@@ -1616,7 +1637,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	spin_unlock(&swap_lock);
 
 	oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
-	err = try_to_unuse(type);
+	err = try_to_unuse(type, false, 0); /* force all pages to be unused */
 	compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX, oom_score_adj);
 
 	if (err) {
@@ -1627,7 +1648,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		 * sys_swapoff for this swap_info_struct at this point.
 		 */
 		/* re-insert swap space back into swap_list */
-		enable_swap_info(p, p->prio, p->swap_map);
+		enable_swap_info(p, p->prio, p->swap_map, frontswap_map_get(p));
 		goto out_dput;
 	}
 
@@ -1653,9 +1674,11 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	frontswap_invalidate_area(type);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	vfree(frontswap_map_get(p));
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
 
@@ -2019,6 +2042,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	sector_t span;
 	unsigned long maxpages;
 	unsigned char *swap_map = NULL;
+	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
 
@@ -2102,6 +2126,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		error = nr_extents;
 		goto bad_swap;
 	}
+	/* frontswap enabled? set up bit-per-page map for frontswap */
+	if (frontswap_enabled)
+		frontswap_map = vzalloc(maxpages / sizeof(long));
 
 	if (p->bdev) {
 		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
@@ -2117,14 +2144,15 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
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
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
