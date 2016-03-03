Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 124AE6B025A
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:50:51 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id bj10so13001915pad.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:50:51 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id y1si64985278pfi.229.2016.03.03.02.50.50
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 02:50:50 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [RFC qemu 4/4] migration: filter out guest's free pages in ram bulk stage
Date: Thu,  3 Mar 2016 18:44:28 +0800
Message-Id: <1457001868-15949-5-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org
Cc: mst@redhat.com, akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com, Liang Li <liang.z.li@intel.com>

Get the free pages information through virtio and filter out the free
pages in the ram bulk stage. This can significantly reduce the total
live migration time as well as network traffic.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 migration/ram.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 46 insertions(+), 6 deletions(-)

diff --git a/migration/ram.c b/migration/ram.c
index ee2547d..819553b 100644
--- a/migration/ram.c
+++ b/migration/ram.c
@@ -40,6 +40,7 @@
 #include "trace.h"
 #include "exec/ram_addr.h"
 #include "qemu/rcu_queue.h"
+#include "sysemu/balloon.h"
 
 #ifdef DEBUG_MIGRATION_RAM
 #define DPRINTF(fmt, ...) \
@@ -241,6 +242,7 @@ static struct BitmapRcu {
     struct rcu_head rcu;
     /* Main migration bitmap */
     unsigned long *bmap;
+    unsigned long *free_pages_bmap;
     /* bitmap of pages that haven't been sent even once
      * only maintained and used in postcopy at the moment
      * where it's used to send the dirtymap at the start
@@ -561,12 +563,7 @@ ram_addr_t migration_bitmap_find_dirty(RAMBlock *rb,
     unsigned long next;
 
     bitmap = atomic_rcu_read(&migration_bitmap_rcu)->bmap;
-    if (ram_bulk_stage && nr > base) {
-        next = nr + 1;
-    } else {
-        next = find_next_bit(bitmap, size, nr);
-    }
-
+    next = find_next_bit(bitmap, size, nr);
     *ram_addr_abs = next << TARGET_PAGE_BITS;
     return (next - base) << TARGET_PAGE_BITS;
 }
@@ -1415,6 +1412,9 @@ void free_xbzrle_decoded_buf(void)
 static void migration_bitmap_free(struct BitmapRcu *bmap)
 {
     g_free(bmap->bmap);
+    if (balloon_free_pages_support()) {
+        g_free(bmap->free_pages_bmap);
+    }
     g_free(bmap->unsentmap);
     g_free(bmap);
 }
@@ -1873,6 +1873,28 @@ err:
     return ret;
 }
 
+static void filter_out_guest_free_pages(unsigned long *free_pages_bmap)
+{
+    RAMBlock *block;
+    DirtyMemoryBlocks *blocks;
+    unsigned long end, page;
+
+    blocks = atomic_rcu_read(&ram_list.dirty_memory[DIRTY_MEMORY_MIGRATION]);
+    block = QLIST_FIRST_RCU(&ram_list.blocks);
+    end = TARGET_PAGE_ALIGN(block->offset +
+                            block->used_length) >> TARGET_PAGE_BITS;
+    page = block->offset >> TARGET_PAGE_BITS;
+
+    while (page < end) {
+        unsigned long idx = page / DIRTY_MEMORY_BLOCK_SIZE;
+        unsigned long offset = page % DIRTY_MEMORY_BLOCK_SIZE;
+        unsigned long num = MIN(end - page, DIRTY_MEMORY_BLOCK_SIZE - offset);
+        unsigned long *p = free_pages_bmap + BIT_WORD(page);
+
+        slow_bitmap_complement(blocks->blocks[idx], p, num);
+        page += num;
+    }
+}
 
 /* Each of ram_save_setup, ram_save_iterate and ram_save_complete has
  * long-running RCU critical section.  When rcu-reclaims in the code
@@ -1884,6 +1906,7 @@ static int ram_save_setup(QEMUFile *f, void *opaque)
 {
     RAMBlock *block;
     int64_t ram_bitmap_pages; /* Size of bitmap in pages, including gaps */
+    uint64_t free_pages_count = 0;
 
     dirty_rate_high_cnt = 0;
     bitmap_sync_count = 0;
@@ -1931,6 +1954,9 @@ static int ram_save_setup(QEMUFile *f, void *opaque)
     ram_bitmap_pages = last_ram_offset() >> TARGET_PAGE_BITS;
     migration_bitmap_rcu = g_new0(struct BitmapRcu, 1);
     migration_bitmap_rcu->bmap = bitmap_new(ram_bitmap_pages);
+    if (balloon_free_pages_support()) {
+        migration_bitmap_rcu->free_pages_bmap = bitmap_new(ram_bitmap_pages);
+    }
 
     if (migrate_postcopy_ram()) {
         migration_bitmap_rcu->unsentmap = bitmap_new(ram_bitmap_pages);
@@ -1945,6 +1971,20 @@ static int ram_save_setup(QEMUFile *f, void *opaque)
                                             DIRTY_MEMORY_MIGRATION);
     }
     memory_global_dirty_log_start();
+
+    if (balloon_free_pages_support() &&
+        balloon_get_free_pages(migration_bitmap_rcu->free_pages_bmap,
+                               &free_pages_count) == 0) {
+        qemu_mutex_unlock_iothread();
+        while (balloon_get_free_pages(migration_bitmap_rcu->free_pages_bmap,
+                                      &free_pages_count) == 0) {
+            usleep(1000);
+        }
+        qemu_mutex_lock_iothread();
+
+        filter_out_guest_free_pages(migration_bitmap_rcu->free_pages_bmap);
+    }
+
     migration_bitmap_sync();
     qemu_mutex_unlock_ramlist();
     qemu_mutex_unlock_iothread();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
