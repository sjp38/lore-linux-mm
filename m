Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C36016B0253
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 10:43:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so32781835pfb.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:43:47 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id k74si14386555pfb.30.2016.04.19.07.43.46
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 07:43:46 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel 1/2] mm: add the related functions to build the free page bitmap
Date: Tue, 19 Apr 2016 22:34:33 +0800
Message-Id: <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com, Liang Li <liang.z.li@intel.com>

The free page bitmap will be sent to QEMU through virtio interface
and used for live migration optimization.
Drop the cache before building the free page bitmap can get more
free pages. Whether dropping the cache is decided by user.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 fs/drop_caches.c   | 22 ++++++++++++++--------
 include/linux/fs.h |  1 +
 mm/page_alloc.c    | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+), 8 deletions(-)

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index d72d52b..f488086 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -50,14 +50,8 @@ int drop_caches_sysctl_handler(struct ctl_table *table, int write,
 	if (write) {
 		static int stfu;
 
-		if (sysctl_drop_caches & 1) {
-			iterate_supers(drop_pagecache_sb, NULL);
-			count_vm_event(DROP_PAGECACHE);
-		}
-		if (sysctl_drop_caches & 2) {
-			drop_slab();
-			count_vm_event(DROP_SLAB);
-		}
+		drop_cache(sysctl_drop_caches);
+
 		if (!stfu) {
 			pr_info("%s (%d): drop_caches: %d\n",
 				current->comm, task_pid_nr(current),
@@ -67,3 +61,15 @@ int drop_caches_sysctl_handler(struct ctl_table *table, int write,
 	}
 	return 0;
 }
+
+void drop_cache(int drop_ctl)
+{
+	if (drop_ctl & 1) {
+		iterate_supers(drop_pagecache_sb, NULL);
+		count_vm_event(DROP_PAGECACHE);
+	}
+	if (drop_ctl & 2) {
+		drop_slab();
+		count_vm_event(DROP_SLAB);
+	}
+}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 70e61b5..b8a0bc0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2864,6 +2864,7 @@ extern void drop_super(struct super_block *sb);
 extern void iterate_supers(void (*)(struct super_block *, void *), void *);
 extern void iterate_supers_type(struct file_system_type *,
 			        void (*)(struct super_block *, void *), void *);
+extern void drop_cache(int drop_ctl);
 
 extern int dcache_dir_open(struct inode *, struct file *);
 extern int dcache_dir_close(struct inode *, struct file *);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d..4799983 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -63,6 +63,7 @@
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
+#include <linux/fs.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -4029,6 +4030,51 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+static void mark_free_pages_bitmap(struct zone *zone,
+		unsigned long *bitmap, unsigned long len)
+{
+	unsigned long pfn, flags, i, limit;
+	unsigned int order, t;
+	struct list_head *curr;
+
+	if (zone_is_empty(zone))
+		return;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	limit = min(len, max_pfn);
+	for_each_migratetype_order(order, t) {
+		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+			pfn = page_to_pfn(list_entry(curr, struct page, lru));
+			for (i = 0; i < (1UL << order); i++) {
+				if ((pfn + i) < limit)
+					set_bit_le(pfn + i, bitmap);
+				else
+					break;
+			}
+		}
+	}
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
+unsigned long get_max_pfn(void)
+{
+	return max_pfn;
+}
+EXPORT_SYMBOL(get_max_pfn);
+
+void get_free_pages(unsigned long *bitmap, unsigned long len, int drop)
+{
+	struct zone *zone;
+
+	drop_cache(drop);
+
+	for_each_populated_zone(zone)
+		mark_free_pages_bitmap(zone, bitmap, len);
+}
+EXPORT_SYMBOL(get_free_pages);
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
