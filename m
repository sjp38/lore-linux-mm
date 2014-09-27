Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE7E6B003B
	for <linux-mm@kvack.org>; Sat, 27 Sep 2014 15:15:44 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id ty20so3553090lab.26
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 12:15:43 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id p7si12122474lbr.56.2014.09.27.12.15.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 27 Sep 2014 12:15:42 -0700 (PDT)
Received: by mail-la0-f45.google.com with SMTP id q1so4464169lam.4
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 12:15:42 -0700 (PDT)
Subject: [PATCH v3 3/4] mm/balloon_compaction: add vmstat counters and
 kpageflags bit
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Sep 2014 23:15:23 +0400
Message-ID: <20140927191522.13738.70854.stgit@zurg>
In-Reply-To: <20140927183403.13738.22121.stgit@zurg>
References: <20140927183403.13738.22121.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>

From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>

Always mark pages with PageBalloon even if balloon compaction is
disabled and expose this mark in /proc/kpageflags as KPF_BALLOON.

Also this patch adds three counters into /proc/vmstat: "balloon_inflate",
"balloon_deflate" and "balloon_migrate". They accumulate balloon activity.
Current size of balloon is (balloon_inflate - balloon_deflate) pages.

All generic balloon code now gathered under option CONFIG_MEMORY_BALLOON.
It should be selected by ballooning driver which wants use this feature.
Currently virtio-balloon is the only user.

Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/virtio/Kconfig                 |    1 +
 drivers/virtio/virtio_balloon.c        |    1 +
 fs/proc/page.c                         |    3 +++
 include/linux/balloon_compaction.h     |    2 ++
 include/linux/vm_event_item.h          |    7 +++++++
 include/uapi/linux/kernel-page-flags.h |    1 +
 mm/Kconfig                             |    7 ++++++-
 mm/Makefile                            |    3 ++-
 mm/balloon_compaction.c                |    2 ++
 mm/vmstat.c                            |   12 +++++++++++-
 tools/vm/page-types.c                  |    1 +
 11 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
index c6683f2..00b2286 100644
--- a/drivers/virtio/Kconfig
+++ b/drivers/virtio/Kconfig
@@ -25,6 +25,7 @@ config VIRTIO_PCI
 config VIRTIO_BALLOON
 	tristate "Virtio balloon driver"
 	depends on VIRTIO
+	select MEMORY_BALLOON
 	---help---
 	 This driver supports increasing and decreasing the amount
 	 of memory within a KVM guest.
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 2bad7f9..f893148 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -396,6 +396,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	spin_lock_irqsave(&vb_dev_info->pages_lock, flags);
 	balloon_page_insert(vb_dev_info, newpage);
 	vb_dev_info->isolated_pages--;
+	__count_vm_event(BALLOON_MIGRATE);
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
 	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
 	set_page_pfns(vb->pfns, newpage);
diff --git a/fs/proc/page.c b/fs/proc/page.c
index e647c55..1e3187d 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -133,6 +133,9 @@ u64 stable_page_flags(struct page *page)
 	if (PageBuddy(page))
 		u |= 1 << KPF_BUDDY;
 
+	if (PageBalloon(page))
+		u |= 1 << KPF_BALLOON;
+
 	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
 
 	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index bc3d298..9b0a15d 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -166,11 +166,13 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
 static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 				       struct page *page)
 {
+	__SetPageBalloon(page);
 	list_add(&page->lru, &balloon->pages);
 }
 
 static inline void balloon_page_delete(struct page *page)
 {
+	__ClearPageBalloon(page);
 	list_del(&page->lru);
 }
 
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index ced9234..730334c 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -72,6 +72,13 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
+#ifdef CONFIG_MEMORY_BALLOON
+		BALLOON_INFLATE,
+		BALLOON_DEFLATE,
+#ifdef CONFIG_BALLOON_COMPACTION
+		BALLOON_MIGRATE,
+#endif
+#endif
 #ifdef CONFIG_DEBUG_TLBFLUSH
 #ifdef CONFIG_SMP
 		NR_TLB_REMOTE_FLUSH,	/* cpu tried to flush others' tlbs */
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index 5116a0e..2f96d23 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -31,6 +31,7 @@
 
 #define KPF_KSM			21
 #define KPF_THP			22
+#define KPF_BALLOON		23
 
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 886db21..83250e4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -228,11 +228,16 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 	boolean
 
 #
+# support for memory balloon
+config MEMORY_BALLOON
+	boolean
+
+#
 # support for memory balloon compaction
 config BALLOON_COMPACTION
 	bool "Allow for balloon memory compaction/migration"
 	def_bool y
-	depends on COMPACTION && VIRTIO_BALLOON
+	depends on COMPACTION && MEMORY_BALLOON
 	help
 	  Memory fragmentation introduced by ballooning might reduce
 	  significantly the number of 2MB contiguous memory blocks that can be
diff --git a/mm/Makefile b/mm/Makefile
index 7b77050..e88d9b9 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o balloon_compaction.o vmacache.o \
+			   compaction.o vmacache.o \
 			   interval_tree.o list_lru.o workingset.o \
 			   iov_iter.o debug.o $(mmu-y)
 
@@ -68,3 +68,4 @@ obj-$(CONFIG_ZBUD)	+= zbud.o
 obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
+obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 3afdabd..b3cbe19 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -36,6 +36,7 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
 	BUG_ON(!trylock_page(page));
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 	balloon_page_insert(b_dev_info, page);
+	__count_vm_event(BALLOON_INFLATE);
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 	unlock_page(page);
 	return page;
@@ -74,6 +75,7 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 			}
 			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 			balloon_page_delete(page);
+			__count_vm_event(BALLOON_DEFLATE);
 			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 			unlock_page(page);
 			dequeued_page = true;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c53a50a..5da8834 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -751,7 +751,7 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 					TEXT_FOR_HIGHMEM(xx) xx "_movable",
 
 const char * const vmstat_text[] = {
-	/* Zoned VM counters */
+	/* enum zone_stat_item countes */
 	"nr_free_pages",
 	"nr_alloc_batch",
 	"nr_inactive_anon",
@@ -794,10 +794,13 @@ const char * const vmstat_text[] = {
 	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
+
+	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
 	"nr_dirty_background_threshold",
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
+	/* enum vm_event_item counters */
 	"pgpgin",
 	"pgpgout",
 	"pswpin",
@@ -876,6 +879,13 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 #endif
+#ifdef CONFIG_MEMORY_BALLOON
+	"balloon_inflate",
+	"balloon_deflate",
+#ifdef CONFIG_BALLOON_COMPACTION
+	"balloon_migrate",
+#endif
+#endif /* CONFIG_MEMORY_BALLOON */
 #ifdef CONFIG_DEBUG_TLBFLUSH
 #ifdef CONFIG_SMP
 	"nr_tlb_remote_flush",
diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index c4d6d2e..264fbc2 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -132,6 +132,7 @@ static const char * const page_flag_names[] = {
 	[KPF_NOPAGE]		= "n:nopage",
 	[KPF_KSM]		= "x:ksm",
 	[KPF_THP]		= "t:thp",
+	[KPF_BALLOON]		= "o:balloon",
 
 	[KPF_RESERVED]		= "r:reserved",
 	[KPF_MLOCKED]		= "m:mlocked",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
