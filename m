Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 44F9E6B025A
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:50:52 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fi3so11060544pac.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:50:52 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rq5si42034730pab.126.2016.03.03.02.50.51
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 02:50:51 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [RFC qemu 3/4] migration: not set migration bitmap in setup stage
Date: Thu,  3 Mar 2016 18:44:27 +0800
Message-Id: <1457001868-15949-4-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org
Cc: mst@redhat.com, akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com, Liang Li <liang.z.li@intel.com>

Set ram_list.dirty_memory instead of migration bitmap, the migration
bitmap will be update when doing migration_bitmap_sync().
Set migration_dirty_pages to 0 and it will be updated by
migration_dirty_pages() too.

The following patch is based on this change.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 migration/ram.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/migration/ram.c b/migration/ram.c
index 704f6a9..ee2547d 100644
--- a/migration/ram.c
+++ b/migration/ram.c
@@ -1931,19 +1931,19 @@ static int ram_save_setup(QEMUFile *f, void *opaque)
     ram_bitmap_pages = last_ram_offset() >> TARGET_PAGE_BITS;
     migration_bitmap_rcu = g_new0(struct BitmapRcu, 1);
     migration_bitmap_rcu->bmap = bitmap_new(ram_bitmap_pages);
-    bitmap_set(migration_bitmap_rcu->bmap, 0, ram_bitmap_pages);
 
     if (migrate_postcopy_ram()) {
         migration_bitmap_rcu->unsentmap = bitmap_new(ram_bitmap_pages);
         bitmap_set(migration_bitmap_rcu->unsentmap, 0, ram_bitmap_pages);
     }
 
-    /*
-     * Count the total number of pages used by ram blocks not including any
-     * gaps due to alignment or unplugs.
-     */
-    migration_dirty_pages = ram_bytes_total() >> TARGET_PAGE_BITS;
+    migration_dirty_pages = 0;
 
+    QLIST_FOREACH_RCU(block, &ram_list.blocks, next) {
+        cpu_physical_memory_set_dirty_range(block->offset,
+                                            block->used_length,
+                                            DIRTY_MEMORY_MIGRATION);
+    }
     memory_global_dirty_log_start();
     migration_bitmap_sync();
     qemu_mutex_unlock_ramlist();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
