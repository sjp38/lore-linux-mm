Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 260746B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:03:05 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so5537174pde.20
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:03:03 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id x3si10752802pbf.301.2014.01.27.02.03.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:03:02 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0200EIF190RK70@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:03:00 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 1/8] mm/swap: add some comments for swap flag/lock usage
Date: Mon, 27 Jan 2014 18:01:31 +0800
Message-id: <000601cf1b46$f5c65430$e152fc90$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Seth Jennings' <sjennings@variantweb.net>, 'Heesub Shin' <heesub.shin@samsung.com>, mguzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

The swap flag/lock usage in swapfile.c is lack of clarity
and readability, some comments are not correct in other files.

Add some comments to try to make it more clear and readable.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 include/linux/blkdev.h |    4 ++-
 mm/rmap.c              |    2 +-
 mm/swapfile.c          |   66 +++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 67 insertions(+), 5 deletions(-)

diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 1b135d4..fa11ef6 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1575,7 +1575,9 @@ struct block_device_operations {
 	void (*unlock_native_capacity) (struct gendisk *);
 	int (*revalidate_disk) (struct gendisk *);
 	int (*getgeo)(struct block_device *, struct hd_geometry *);
-	/* this callback is with swap_lock and sometimes page table lock held */
+	/* this callback is with swap_info_struct.lock
+	 * and sometimes page table lock held
+	 */
 	void (*swap_slot_free_notify) (struct block_device *, unsigned long);
 	struct module *owner;
 };
diff --git a/mm/rmap.c b/mm/rmap.c
index d9d4231..1d31ba7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -27,7 +27,7 @@
  *         anon_vma->rwsem
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
- *             swap_lock (in swap_duplicate, swap_info_get)
+ *             swap_info_struct.lock (in swap_duplicate, swap_info_get)
  *               mmlist_lock (in mmput, drain_mmlist and others)
  *               mapping->private_lock (in __set_page_dirty_buffers)
  *               inode->i_lock (in set_page_dirty's __mark_inode_dirty)
diff --git a/mm/swapfile.c b/mm/swapfile.c
index c6c13b05..0a623a9 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -45,6 +45,56 @@ static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
 static void free_swap_count_continuations(struct swap_info_struct *);
 static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 
+
+/*
+ * swap_info_struct is allocated into swap_info[MAX_SWAPFILES] free slot
+ * and never freed, so we can access it without NULL point reference worry.
+ * swap_list strings all *live* swap_info_structs according to their descending
+ * priority.
+ * To indicate the states of swap_info_struct, we use two of
+ * swap_info_struct.flags bits:
+ *
+ * SWP_USED, !SWP_WRITEOK
+ *        It is used for a swapfile while cann't write to it. Just a momentary
+ *        state. swapon or swapoff call is now happening on it. It will turn to
+ *        one of the following two states after swapon or swapoff call.
+ * SWP_USED, SWP_WRITEOK
+ *        It is ok to write to this swapfile. This is the conventional state
+ *        after a successful swapon.
+ * !SWP_USED, !SWP_WRITEOK
+ *        It is an idle swap_info_struct without a corresponding swapfile.
+ *        This is the state after a successful swapoff
+ * !SWP_USED, SWP_WRITEOK
+ *        It is an impossible state, should never happen
+ *
+ * swapon set SWP_USED firstly to mark swap_info[] slot in-used, then
+ * prepare the swapfile recources, set SWP_WRITEOK until all work finished.
+ * swapoff clear SWP_WRITEOK firstly to prevent new swap_entry allocation
+ * from this swapfile, clear SWP_USED at last when all recources freed.
+ *
+ * There are 3 locks to protect race condition when accessing swap_info_struct
+ * swap_lock
+ *        A global lock which protects the global swap_info[] and swap_list.
+ *        It should be hold firstly when change or iterative access these data,
+ *        such as swapon, swapoff and get_swap_page
+ * swap_info_struct.lock
+ *        Each swap_info_struct has its own lock to protect its data which are
+ *        used when allocate or free swap_entry, such as swap_map, cluster_info
+ *        lowest_bit, highest_bit etc.
+ * swapon_mutex
+ *        A global mutex which protects the race condition among swapon,
+ *        swapoff, swap_start, and frontswap_register_ops.
+ *
+ * What calls for special attention is that to change swap_info_struct.flags
+ * (SWP_USED, SWP_WRITEOK), we should hold swap_lock because we
+ * need to iterate access swap_info[] to locate the target swap_info_struct.
+ * Other bits of swap_info_struct.flags is set once before swapfile enabled,
+ * or is set/clear under swap_info_struct.lock
+ *
+ * Consider of performance, we can read data fields without lock as we never
+ * free swap_info_struct, see individual function comments.
+ *
+ */
 DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 atomic_long_t nr_swap_pages;
@@ -1053,6 +1103,8 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 /*
  * Get the (PAGE_SIZE) block corresponding to given offset on the swapdev
  * corresponding to given index in swap_info (swap type).
+ *
+ * TODO: protect race condition with swapoff
  */
 sector_t swapdev_block(int type, pgoff_t offset)
 {
@@ -1308,10 +1360,10 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
 	unsigned char count;
 
 	/*
-	 * No need for swap_lock here: we're just looking
+	 * No need for si->lock here: we're just looking
 	 * for whether an entry is in use, not modifying it; false
 	 * hits are okay, and sys_swapoff() has already prevented new
-	 * allocations from this area (while holding swap_lock).
+	 * allocations from this area (while holding si->lock).
 	 */
 	for (;;) {
 		if (++i >= max) {
@@ -1627,6 +1679,8 @@ static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
 
 /*
  * Returns the page offset into bdev for the specified page's swap entry.
+ * protected by page_lock against try_to_unuse(), don't worry about race
+ * condition with swapoff
  */
 sector_t map_swap_page(struct page *page, struct block_device **bdev)
 {
@@ -1982,6 +2036,12 @@ static void *swap_start(struct seq_file *swap, loff_t *pos)
 	int type;
 	loff_t l = *pos;
 
+	/*
+	 * Consider of performance and reschedule, don't hold swap_lock
+	 * or swap_info_struct.lock, we only read data fields not write them.
+	 * The only rare race condition is with swapon/swapoff which change
+	 * global swap_info[], use swapon_mutex to mutex this situation.
+	 */
 	mutex_lock(&swapon_mutex);
 
 	if (!l)
@@ -2842,7 +2902,7 @@ outer:
  * into, carry if so, or else fail until a new continuation page is allocated;
  * when the original swap_map count is decremented from 0 with continuation,
  * borrow from the continuation and report whether it still holds more.
- * Called while __swap_duplicate() or swap_entry_free() holds swap_lock.
+ * Called while __swap_duplicate() or swap_entry_free() holds si->lock.
  */
 static bool swap_count_continued(struct swap_info_struct *si,
 				 pgoff_t offset, unsigned char count)
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
