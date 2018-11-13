Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F06F6B0281
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:33:33 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id z13-v6so7406873pgv.18
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:33:33 -0800 (PST)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id z189-v6si20942735pfz.32.2018.11.12.22.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 22:33:30 -0800 (PST)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v5 3/4] mm: convert totalram_pages and totalhigh_pages variables to atomic
Date: Tue, 13 Nov 2018 12:03:09 +0530
Message-Id: <1542090790-21750-4-git-send-email-arunks@codeaurora.org>
In-Reply-To: <1542090790-21750-1-git-send-email-arunks@codeaurora.org>
References: <1542090790-21750-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org, willy@infradead.org, Arun KS <arunks@codeaurora.org>

totalram_pages and totalhigh_pages are made static inline function.

Main motivation was that managed_page_count_lock handling was
complicating things. It was discussed in lenght here,
https://lore.kernel.org/patchwork/patch/995739/#1181785
So it seemes better to remove the lock and convert variables
to atomic, with preventing poteintial store-to-read tearing as
a bonus.

Suggested-by: Michal Hocko <mhocko@suse.com>
Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Arun KS <arunks@codeaurora.org>
Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
coccinelle script to make most of the changes,

@@
declarer name EXPORT_SYMBOL;
symbol totalram_pages;
expression e;
@@
(
EXPORT_SYMBOL(totalram_pages);
|
- totalram_pages = e
+ totalram_pages_set(e)
|
- totalram_pages += e
+ totalram_pages_add(e)
|
- totalram_pages++
+ totalram_pages_inc()
|
- totalram_pages--
+ totalram_pages_dec()
|
- totalram_pages
+ totalram_pages()
)

@@
symbol totalhigh_pages;
expression e;
@@
(
EXPORT_SYMBOL(totalhigh_pages);
|
- totalhigh_pages = e
+ totalhigh_pages_set(e)
|
- totalhigh_pages += e
+ totalhigh_pages_add(e)
|
- totalhigh_pages++
+ totalhigh_pages_inc()
|
- totalhigh_pages--
+ totalhigh_pages_dec()
|
- totalhigh_pages
+ totalhigh_pages()
)

Manaually apply all changes of following files,

include/linux/highmem.h
include/linux/mm.h
include/linux/swap.h
mm/highmem.c

and for mm/page_alloc.c mannualy apply only below changes,

 #include <linux/stddef.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/swap.h>
 #include <linux/interrupt.h>
 #include <linux/pagemap.h>

 /* Protect totalram_pages and zone->managed_pages */
 static DEFINE_SPINLOCK(managed_page_count_lock);

-unsigned long totalram_pages __read_mostly;
+atomic_long_t _totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 unsigned long totalcma_pages __read_mostly;
---

 arch/csky/mm/init.c                           |  4 ++--
 arch/powerpc/platforms/pseries/cmm.c          | 10 +++++-----
 arch/s390/mm/init.c                           |  2 +-
 arch/um/kernel/mem.c                          |  2 +-
 arch/x86/kernel/cpu/microcode/core.c          |  2 +-
 drivers/char/agp/backend.c                    |  4 ++--
 drivers/gpu/drm/i915/i915_gem.c               |  2 +-
 drivers/gpu/drm/i915/selftests/i915_gem_gtt.c |  4 ++--
 drivers/hv/hv_balloon.c                       |  2 +-
 drivers/md/dm-bufio.c                         |  2 +-
 drivers/md/dm-crypt.c                         |  2 +-
 drivers/md/dm-integrity.c                     |  2 +-
 drivers/md/dm-stats.c                         |  2 +-
 drivers/media/platform/mtk-vpu/mtk_vpu.c      |  2 +-
 drivers/misc/vmw_balloon.c                    |  2 +-
 drivers/parisc/ccio-dma.c                     |  4 ++--
 drivers/parisc/sba_iommu.c                    |  4 ++--
 drivers/staging/android/ion/ion_system_heap.c |  2 +-
 drivers/xen/xen-selfballoon.c                 |  6 +++---
 fs/ceph/super.h                               |  2 +-
 fs/file_table.c                               |  2 +-
 fs/fuse/inode.c                               |  2 +-
 fs/nfs/write.c                                |  2 +-
 fs/nfsd/nfscache.c                            |  2 +-
 fs/ntfs/malloc.h                              |  2 +-
 fs/proc/base.c                                |  2 +-
 include/linux/highmem.h                       | 28 +++++++++++++++++++++++++--
 include/linux/mm.h                            | 27 +++++++++++++++++++++++++-
 include/linux/swap.h                          |  1 -
 kernel/fork.c                                 |  2 +-
 kernel/kexec_core.c                           |  2 +-
 kernel/power/snapshot.c                       |  2 +-
 mm/highmem.c                                  |  5 ++---
 mm/huge_memory.c                              |  2 +-
 mm/kasan/quarantine.c                         |  2 +-
 mm/memblock.c                                 |  4 ++--
 mm/mm_init.c                                  |  2 +-
 mm/oom_kill.c                                 |  2 +-
 mm/page_alloc.c                               | 20 ++++++++++---------
 mm/shmem.c                                    |  8 ++++----
 mm/slab.c                                     |  2 +-
 mm/swap.c                                     |  2 +-
 mm/util.c                                     |  2 +-
 mm/vmalloc.c                                  |  4 ++--
 mm/workingset.c                               |  2 +-
 mm/zswap.c                                    |  4 ++--
 net/dccp/proto.c                              |  2 +-
 net/decnet/dn_route.c                         |  2 +-
 net/ipv4/tcp_metrics.c                        |  2 +-
 net/netfilter/nf_conntrack_core.c             |  2 +-
 net/netfilter/xt_hashlimit.c                  |  2 +-
 net/sctp/protocol.c                           |  2 +-
 security/integrity/ima/ima_kexec.c            |  2 +-
 53 files changed, 130 insertions(+), 81 deletions(-)

diff --git a/arch/csky/mm/init.c b/arch/csky/mm/init.c
index dc07c07..66e5970 100644
--- a/arch/csky/mm/init.c
+++ b/arch/csky/mm/init.c
@@ -71,7 +71,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 		ClearPageReserved(virt_to_page(start));
 		init_page_count(virt_to_page(start));
 		free_page(start);
-		totalram_pages++;
+		totalram_pages_inc();
 	}
 }
 #endif
@@ -88,7 +88,7 @@ void free_initmem(void)
 		ClearPageReserved(virt_to_page(addr));
 		init_page_count(virt_to_page(addr));
 		free_page(addr);
-		totalram_pages++;
+		totalram_pages_inc();
 		addr += PAGE_SIZE;
 	}
 
diff --git a/arch/powerpc/platforms/pseries/cmm.c b/arch/powerpc/platforms/pseries/cmm.c
index 25427a4..e8d63a6 100644
--- a/arch/powerpc/platforms/pseries/cmm.c
+++ b/arch/powerpc/platforms/pseries/cmm.c
@@ -208,7 +208,7 @@ static long cmm_alloc_pages(long nr)
 
 		pa->page[pa->index++] = addr;
 		loaned_pages++;
-		totalram_pages--;
+		totalram_pages_dec();
 		spin_unlock(&cmm_lock);
 		nr--;
 	}
@@ -247,7 +247,7 @@ static long cmm_free_pages(long nr)
 		free_page(addr);
 		loaned_pages--;
 		nr--;
-		totalram_pages++;
+		totalram_pages_inc();
 	}
 	spin_unlock(&cmm_lock);
 	cmm_dbg("End request with %ld pages unfulfilled\n", nr);
@@ -291,7 +291,7 @@ static void cmm_get_mpp(void)
 	int rc;
 	struct hvcall_mpp_data mpp_data;
 	signed long active_pages_target, page_loan_request, target;
-	signed long total_pages = totalram_pages + loaned_pages;
+	signed long total_pages = totalram_pages() + loaned_pages;
 	signed long min_mem_pages = (min_mem_mb * 1024 * 1024) / PAGE_SIZE;
 
 	rc = h_get_mpp(&mpp_data);
@@ -322,7 +322,7 @@ static void cmm_get_mpp(void)
 
 	cmm_dbg("delta = %ld, loaned = %lu, target = %lu, oom = %lu, totalram = %lu\n",
 		page_loan_request, loaned_pages, loaned_pages_target,
-		oom_freed_pages, totalram_pages);
+		oom_freed_pages, totalram_pages());
 }
 
 static struct notifier_block cmm_oom_nb = {
@@ -581,7 +581,7 @@ static int cmm_mem_going_offline(void *arg)
 			free_page(pa_curr->page[idx]);
 			freed++;
 			loaned_pages--;
-			totalram_pages++;
+			totalram_pages_inc();
 			pa_curr->page[idx] = pa_last->page[--pa_last->index];
 			if (pa_last->index == 0) {
 				if (pa_curr == pa_last)
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 76d0708..5038819 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -59,7 +59,7 @@ static void __init setup_zero_pages(void)
 	order = 7;
 
 	/* Limit number of empty zero pages for small memory sizes */
-	while (order > 2 && (totalram_pages >> 10) < (1UL << order))
+	while (order > 2 && (totalram_pages() >> 10) < (1UL << order))
 		order--;
 
 	empty_zero_page = __get_free_pages(GFP_KERNEL | __GFP_ZERO, order);
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 2da2096..8d21a83 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -51,7 +51,7 @@ void __init mem_init(void)
 
 	/* this will put all low memory onto the freelists */
 	memblock_free_all();
-	max_low_pfn = totalram_pages;
+	max_low_pfn = totalram_pages();
 	max_pfn = max_low_pfn;
 	mem_init_print_info(NULL);
 	kmalloc_ok = 1;
diff --git a/arch/x86/kernel/cpu/microcode/core.c b/arch/x86/kernel/cpu/microcode/core.c
index 168fa27..97f9ada 100644
--- a/arch/x86/kernel/cpu/microcode/core.c
+++ b/arch/x86/kernel/cpu/microcode/core.c
@@ -434,7 +434,7 @@ static ssize_t microcode_write(struct file *file, const char __user *buf,
 			       size_t len, loff_t *ppos)
 {
 	ssize_t ret = -EINVAL;
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 
 	if ((len >> PAGE_SHIFT) > nr_pages) {
 		pr_err("too much data (max %ld pages)\n", nr_pages);
diff --git a/drivers/char/agp/backend.c b/drivers/char/agp/backend.c
index 38ffb28..004a3ce 100644
--- a/drivers/char/agp/backend.c
+++ b/drivers/char/agp/backend.c
@@ -115,9 +115,9 @@ static int agp_find_max(void)
 	long memory, index, result;
 
 #if PAGE_SHIFT < 20
-	memory = totalram_pages >> (20 - PAGE_SHIFT);
+	memory = totalram_pages() >> (20 - PAGE_SHIFT);
 #else
-	memory = totalram_pages << (PAGE_SHIFT - 20);
+	memory = totalram_pages() << (PAGE_SHIFT - 20);
 #endif
 	index = 1;
 
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 0c8aa57..6ed0e75 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2539,7 +2539,7 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 	 * If there's no chance of allocating enough pages for the whole
 	 * object, bail early.
 	 */
-	if (page_count > totalram_pages)
+	if (page_count > totalram_pages())
 		return -ENOMEM;
 
 	st = kmalloc(sizeof(*st), GFP_KERNEL);
diff --git a/drivers/gpu/drm/i915/selftests/i915_gem_gtt.c b/drivers/gpu/drm/i915/selftests/i915_gem_gtt.c
index 127d815..ec01f51 100644
--- a/drivers/gpu/drm/i915/selftests/i915_gem_gtt.c
+++ b/drivers/gpu/drm/i915/selftests/i915_gem_gtt.c
@@ -170,7 +170,7 @@ static int igt_ppgtt_alloc(void *arg)
 	 * This should ensure that we do not run into the oomkiller during
 	 * the test and take down the machine wilfully.
 	 */
-	limit = totalram_pages << PAGE_SHIFT;
+	limit = totalram_pages() << PAGE_SHIFT;
 	limit = min(ppgtt->vm.total, limit);
 
 	/* Check we can allocate the entire range */
@@ -1244,7 +1244,7 @@ static int exercise_mock(struct drm_i915_private *i915,
 				     u64 hole_start, u64 hole_end,
 				     unsigned long end_time))
 {
-	const u64 limit = totalram_pages << PAGE_SHIFT;
+	const u64 limit = totalram_pages() << PAGE_SHIFT;
 	struct i915_gem_context *ctx;
 	struct i915_hw_ppgtt *ppgtt;
 	IGT_TIMEOUT(end_time);
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index f3e7da9..5301fef 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -1090,7 +1090,7 @@ static void process_info(struct hv_dynmem_device *dm, struct dm_info_msg *msg)
 static unsigned long compute_balloon_floor(void)
 {
 	unsigned long min_pages;
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 #define MB2PAGES(mb) ((mb) << (20 - PAGE_SHIFT))
 	/* Simple continuous piecewiese linear function:
 	 *  max MiB -> min MiB  gradient
diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index dc385b7..8b0b628 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -1887,7 +1887,7 @@ static int __init dm_bufio_init(void)
 	dm_bufio_allocated_vmalloc = 0;
 	dm_bufio_current_allocated = 0;
 
-	mem = (__u64)mult_frac(totalram_pages - totalhigh_pages,
+	mem = (__u64)mult_frac(totalram_pages() - totalhigh_pages(),
 			       DM_BUFIO_MEMORY_PERCENT, 100) << PAGE_SHIFT;
 
 	if (mem > ULONG_MAX)
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index b8eec51..f3f2ac0 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -2158,7 +2158,7 @@ static int crypt_wipe_key(struct crypt_config *cc)
 
 static void crypt_calculate_pages_per_client(void)
 {
-	unsigned long pages = (totalram_pages - totalhigh_pages) * DM_CRYPT_MEMORY_PERCENT / 100;
+	unsigned long pages = (totalram_pages() - totalhigh_pages()) * DM_CRYPT_MEMORY_PERCENT / 100;
 
 	if (!dm_crypt_clients_n)
 		return;
diff --git a/drivers/md/dm-integrity.c b/drivers/md/dm-integrity.c
index bb3096b..c12fa01 100644
--- a/drivers/md/dm-integrity.c
+++ b/drivers/md/dm-integrity.c
@@ -2843,7 +2843,7 @@ static int create_journal(struct dm_integrity_c *ic, char **error)
 	journal_pages = roundup((__u64)ic->journal_sections * ic->journal_section_sectors,
 				PAGE_SIZE >> SECTOR_SHIFT) >> (PAGE_SHIFT - SECTOR_SHIFT);
 	journal_desc_size = journal_pages * sizeof(struct page_list);
-	if (journal_pages >= totalram_pages - totalhigh_pages || journal_desc_size > ULONG_MAX) {
+	if (journal_pages >= totalram_pages() - totalhigh_pages() || journal_desc_size > ULONG_MAX) {
 		*error = "Journal doesn't fit into memory";
 		r = -ENOMEM;
 		goto bad;
diff --git a/drivers/md/dm-stats.c b/drivers/md/dm-stats.c
index 21de30b..45b92a3 100644
--- a/drivers/md/dm-stats.c
+++ b/drivers/md/dm-stats.c
@@ -85,7 +85,7 @@ static bool __check_shared_memory(size_t alloc_size)
 	a = shared_memory_amount + alloc_size;
 	if (a < shared_memory_amount)
 		return false;
-	if (a >> PAGE_SHIFT > totalram_pages / DM_STATS_MEMORY_FACTOR)
+	if (a >> PAGE_SHIFT > totalram_pages() / DM_STATS_MEMORY_FACTOR)
 		return false;
 #ifdef CONFIG_MMU
 	if (a > (VMALLOC_END - VMALLOC_START) / DM_STATS_VMALLOC_FACTOR)
diff --git a/drivers/media/platform/mtk-vpu/mtk_vpu.c b/drivers/media/platform/mtk-vpu/mtk_vpu.c
index 616f78b..b660249 100644
--- a/drivers/media/platform/mtk-vpu/mtk_vpu.c
+++ b/drivers/media/platform/mtk-vpu/mtk_vpu.c
@@ -855,7 +855,7 @@ static int mtk_vpu_probe(struct platform_device *pdev)
 	/* Set PTCM to 96K and DTCM to 32K */
 	vpu_cfg_writel(vpu, 0x2, VPU_TCM_CFG);
 
-	vpu->enable_4GB = !!(totalram_pages > (SZ_2G >> PAGE_SHIFT));
+	vpu->enable_4GB = !!(totalram_pages() > (SZ_2G >> PAGE_SHIFT));
 	dev_info(dev, "4GB mode %u\n", vpu->enable_4GB);
 
 	if (vpu->enable_4GB) {
diff --git a/drivers/misc/vmw_balloon.c b/drivers/misc/vmw_balloon.c
index 9b0b3fa..e6126a4 100644
--- a/drivers/misc/vmw_balloon.c
+++ b/drivers/misc/vmw_balloon.c
@@ -570,7 +570,7 @@ static int vmballoon_send_get_target(struct vmballoon *b)
 	unsigned long status;
 	unsigned long limit;
 
-	limit = totalram_pages;
+	limit = totalram_pages();
 
 	/* Ensure limit fits in 32-bits */
 	if (limit != (u32)limit)
diff --git a/drivers/parisc/ccio-dma.c b/drivers/parisc/ccio-dma.c
index 701a7d6..358e380 100644
--- a/drivers/parisc/ccio-dma.c
+++ b/drivers/parisc/ccio-dma.c
@@ -1251,7 +1251,7 @@ void __init ccio_cujo20_fixup(struct parisc_device *cujo, u32 iovp)
 	** Hot-Plug/Removal of PCI cards. (aka PCI OLARD).
 	*/
 
-	iova_space_size = (u32) (totalram_pages / count_parisc_driver(&ccio_driver));
+	iova_space_size = (u32) (totalram_pages() / count_parisc_driver(&ccio_driver));
 
 	/* limit IOVA space size to 1MB-1GB */
 
@@ -1290,7 +1290,7 @@ void __init ccio_cujo20_fixup(struct parisc_device *cujo, u32 iovp)
 
 	DBG_INIT("%s() hpa 0x%p mem %luMB IOV %dMB (%d bits)\n",
 			__func__, ioc->ioc_regs,
-			(unsigned long) totalram_pages >> (20 - PAGE_SHIFT),
+			(unsigned long) totalram_pages() >> (20 - PAGE_SHIFT),
 			iova_space_size>>20,
 			iov_order + PAGE_SHIFT);
 
diff --git a/drivers/parisc/sba_iommu.c b/drivers/parisc/sba_iommu.c
index c1e599a..e065594 100644
--- a/drivers/parisc/sba_iommu.c
+++ b/drivers/parisc/sba_iommu.c
@@ -1414,7 +1414,7 @@ static int setup_ibase_imask_callback(struct device *dev, void *data)
 	** for DMA hints - ergo only 30 bits max.
 	*/
 
-	iova_space_size = (u32) (totalram_pages/global_ioc_cnt);
+	iova_space_size = (u32) (totalram_pages()/global_ioc_cnt);
 
 	/* limit IOVA space size to 1MB-1GB */
 	if (iova_space_size < (1 << (20 - PAGE_SHIFT))) {
@@ -1439,7 +1439,7 @@ static int setup_ibase_imask_callback(struct device *dev, void *data)
 	DBG_INIT("%s() hpa 0x%lx mem %ldMB IOV %dMB (%d bits)\n",
 			__func__,
 			ioc->ioc_hpa,
-			(unsigned long) totalram_pages >> (20 - PAGE_SHIFT),
+			(unsigned long) totalram_pages() >> (20 - PAGE_SHIFT),
 			iova_space_size>>20,
 			iov_order + PAGE_SHIFT);
 
diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
index 548bb02..6cb0eeb 100644
--- a/drivers/staging/android/ion/ion_system_heap.c
+++ b/drivers/staging/android/ion/ion_system_heap.c
@@ -110,7 +110,7 @@ static int ion_system_heap_allocate(struct ion_heap *heap,
 	unsigned long size_remaining = PAGE_ALIGN(size);
 	unsigned int max_order = orders[0];
 
-	if (size / PAGE_SIZE > totalram_pages / 2)
+	if (size / PAGE_SIZE > totalram_pages() / 2)
 		return -ENOMEM;
 
 	INIT_LIST_HEAD(&pages);
diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index 5165aa8..246f612 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -189,7 +189,7 @@ static void selfballoon_process(struct work_struct *work)
 	bool reset_timer = false;
 
 	if (xen_selfballooning_enabled) {
-		cur_pages = totalram_pages;
+		cur_pages = totalram_pages();
 		tgt_pages = cur_pages; /* default is no change */
 		goal_pages = vm_memory_committed() +
 				totalreserve_pages +
@@ -227,7 +227,7 @@ static void selfballoon_process(struct work_struct *work)
 		if (tgt_pages < floor_pages)
 			tgt_pages = floor_pages;
 		balloon_set_new_target(tgt_pages +
-			balloon_stats.current_pages - totalram_pages);
+			balloon_stats.current_pages - totalram_pages());
 		reset_timer = true;
 	}
 #ifdef CONFIG_FRONTSWAP
@@ -569,7 +569,7 @@ int xen_selfballoon_init(bool use_selfballooning, bool use_frontswap_selfshrink)
 	 * much more reliably and response faster in some cases.
 	 */
 	if (!selfballoon_reserved_mb) {
-		reserve_pages = totalram_pages / 10;
+		reserve_pages = totalram_pages() / 10;
 		selfballoon_reserved_mb = PAGES2MB(reserve_pages);
 	}
 	schedule_delayed_work(&selfballoon_worker, selfballoon_interval * HZ);
diff --git a/fs/ceph/super.h b/fs/ceph/super.h
index c005a54..9a2d861 100644
--- a/fs/ceph/super.h
+++ b/fs/ceph/super.h
@@ -808,7 +808,7 @@ static inline int default_congestion_kb(void)
 	 * This allows larger machines to have larger/more transfers.
 	 * Limit the default to 256M
 	 */
-	congestion_kb = (16*int_sqrt(totalram_pages)) << (PAGE_SHIFT-10);
+	congestion_kb = (16*int_sqrt(totalram_pages())) << (PAGE_SHIFT-10);
 	if (congestion_kb > 256*1024)
 		congestion_kb = 256*1024;
 
diff --git a/fs/file_table.c b/fs/file_table.c
index b6e9587..5679e7f 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -380,7 +380,7 @@ void __init files_init(void)
 void __init files_maxfiles_init(void)
 {
 	unsigned long n;
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 	unsigned long memreserve = (nr_pages - nr_free_pages()) * 3/2;
 
 	memreserve = min(memreserve, nr_pages - 1);
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 0b94b23..2121e71 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -824,7 +824,7 @@ static struct dentry *fuse_get_parent(struct dentry *child)
 static void sanitize_global_limit(unsigned *limit)
 {
 	if (*limit == 0)
-		*limit = ((totalram_pages << PAGE_SHIFT) >> 13) /
+		*limit = ((totalram_pages() << PAGE_SHIFT) >> 13) /
 			 sizeof(struct fuse_req);
 
 	if (*limit >= 1 << 16)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 586726a..4f15665 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -2121,7 +2121,7 @@ int __init nfs_init_writepagecache(void)
 	 * This allows larger machines to have larger/more transfers.
 	 * Limit the default to 256M
 	 */
-	nfs_congestion_kb = (16*int_sqrt(totalram_pages)) << (PAGE_SHIFT-10);
+	nfs_congestion_kb = (16*int_sqrt(totalram_pages())) << (PAGE_SHIFT-10);
 	if (nfs_congestion_kb > 256*1024)
 		nfs_congestion_kb = 256*1024;
 
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index e2fe0e9..da52b59 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -99,7 +99,7 @@ static unsigned long nfsd_reply_cache_scan(struct shrinker *shrink,
 nfsd_cache_size_limit(void)
 {
 	unsigned int limit;
-	unsigned long low_pages = totalram_pages - totalhigh_pages;
+	unsigned long low_pages = totalram_pages() - totalhigh_pages();
 
 	limit = (16 * int_sqrt(low_pages)) << (PAGE_SHIFT-10);
 	return min_t(unsigned int, limit, 256*1024);
diff --git a/fs/ntfs/malloc.h b/fs/ntfs/malloc.h
index ab172e5..5becc8a 100644
--- a/fs/ntfs/malloc.h
+++ b/fs/ntfs/malloc.h
@@ -47,7 +47,7 @@ static inline void *__ntfs_malloc(unsigned long size, gfp_t gfp_mask)
 		return kmalloc(PAGE_SIZE, gfp_mask & ~__GFP_HIGHMEM);
 		/* return (void *)__get_free_page(gfp_mask); */
 	}
-	if (likely((size >> PAGE_SHIFT) < totalram_pages))
+	if (likely((size >> PAGE_SHIFT) < totalram_pages()))
 		return __vmalloc(size, gfp_mask, PAGE_KERNEL);
 	return NULL;
 }
diff --git a/fs/proc/base.c b/fs/proc/base.c
index ce34654..d7fd1ca 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -530,7 +530,7 @@ static ssize_t lstats_write(struct file *file, const char __user *buf,
 static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
 			  struct pid *pid, struct task_struct *task)
 {
-	unsigned long totalpages = totalram_pages + total_swap_pages;
+	unsigned long totalpages = totalram_pages() + total_swap_pages;
 	unsigned long points = 0;
 
 	points = oom_badness(task, NULL, NULL, totalpages) *
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 0690679..cea3a01 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -36,7 +36,31 @@ static inline void invalidate_kernel_vmap_range(void *vaddr, int size)
 
 /* declarations for linux/mm/highmem.c */
 unsigned int nr_free_highpages(void);
-extern unsigned long totalhigh_pages;
+extern atomic_long_t _totalhigh_pages;
+static inline unsigned long totalhigh_pages(void)
+{
+	return (unsigned long)atomic_long_read(&_totalhigh_pages);
+}
+
+static inline void totalhigh_pages_inc(void)
+{
+       atomic_long_inc(&_totalhigh_pages);
+}
+
+static inline void totalhigh_pages_dec(void)
+{
+       atomic_long_dec(&_totalhigh_pages);
+}
+
+static inline void totalhigh_pages_add(long count)
+{
+       atomic_long_add(count, &_totalhigh_pages);
+}
+
+static inline void totalhigh_pages_set(long val)
+{
+       atomic_long_set(&_totalhigh_pages, val);
+}
 
 void kmap_flush_unused(void);
 
@@ -51,7 +75,7 @@ static inline struct page *kmap_to_page(void *addr)
 	return virt_to_page(addr);
 }
 
-#define totalhigh_pages 0UL
+static inline unsigned long totalhigh_pages(void) { return 0UL; }
 
 #ifndef ARCH_HAS_KMAP
 static inline void *kmap(struct page *page)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de9..72e7b1a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -48,7 +48,32 @@ static inline void set_max_mapnr(unsigned long limit)
 static inline void set_max_mapnr(unsigned long limit) { }
 #endif
 
-extern unsigned long totalram_pages;
+extern atomic_long_t _totalram_pages;
+static inline unsigned long totalram_pages(void)
+{
+       return (unsigned long)atomic_long_read(&_totalram_pages);
+}
+
+static inline void totalram_pages_inc(void)
+{
+       atomic_long_inc(&_totalram_pages);
+}
+
+static inline void totalram_pages_dec(void)
+{
+       atomic_long_dec(&_totalram_pages);
+}
+
+static inline void totalram_pages_add(long count)
+{
+       atomic_long_add(count, &_totalram_pages);
+}
+
+static inline void totalram_pages_set(long val)
+{
+       atomic_long_set(&_totalram_pages, val);
+}
+
 extern void * high_memory;
 extern int page_cluster;
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index d8a07a4..ea66108 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -308,7 +308,6 @@ struct vma_swap_readahead {
 } while (0)
 
 /* linux/mm/page_alloc.c */
-extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
 extern unsigned long nr_free_buffer_pages(void);
 extern unsigned long nr_free_pagecache_pages(void);
diff --git a/kernel/fork.c b/kernel/fork.c
index 58422c5..f73287c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -739,7 +739,7 @@ void __init __weak arch_task_cache_init(void) { }
 static void set_max_threads(unsigned int max_threads_suggested)
 {
 	u64 threads;
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 
 	/*
 	 * The number of threads shall be limited such that the thread
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 7e967ca..d714044 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -152,7 +152,7 @@ int sanity_check_segment_list(struct kimage *image)
 	int i;
 	unsigned long nr_segments = image->nr_segments;
 	unsigned long total_pages = 0;
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 
 	/*
 	 * Verify we have good destination addresses.  The caller is
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index b0308a2..640b203 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -105,7 +105,7 @@ void __init hibernate_reserved_size_init(void)
 
 void __init hibernate_image_size_init(void)
 {
-	image_size = ((totalram_pages * 2) / 5) * PAGE_SIZE;
+	image_size = ((totalram_pages() * 2) / 5) * PAGE_SIZE;
 }
 
 /*
diff --git a/mm/highmem.c b/mm/highmem.c
index 59db322..107b10f 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -105,9 +105,8 @@ static inline wait_queue_head_t *get_pkmap_wait_queue_head(unsigned int color)
 }
 #endif
 
-unsigned long totalhigh_pages __read_mostly;
-EXPORT_SYMBOL(totalhigh_pages);
-
+atomic_long_t _totalhigh_pages __read_mostly;
+EXPORT_SYMBOL(_totalhigh_pages);
 
 EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55478ab..6e88f72 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -420,7 +420,7 @@ static int __init hugepage_init(void)
 	 * where the extra memory used could hurt more than TLB overhead
 	 * is likely to save.  The admin can still enable it through /sys.
 	 */
-	if (totalram_pages < (512 << (20 - PAGE_SHIFT))) {
+	if (totalram_pages() < (512 << (20 - PAGE_SHIFT))) {
 		transparent_hugepage_flags = 0;
 		return 0;
 	}
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index b209dba..5835c0f 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -236,7 +236,7 @@ void quarantine_reduce(void)
 	 * Update quarantine size in case of hotplug. Allocate a fraction of
 	 * the installed memory to quarantine minus per-cpu queue limits.
 	 */
-	total_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
+	total_size = (totalram_pages() << PAGE_SHIFT) /
 		QUARANTINE_FRACTION;
 	percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
 	new_quarantine_size = (total_size < percpu_quarantines) ?
diff --git a/mm/memblock.c b/mm/memblock.c
index bbd82ab..2aa1598 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1576,7 +1576,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 
 	for (; cursor < end; cursor++) {
 		memblock_free_pages(pfn_to_page(cursor), cursor, 0);
-		totalram_pages++;
+		totalram_pages_inc();
 	}
 }
 
@@ -1978,7 +1978,7 @@ unsigned long __init memblock_free_all(void)
 	reset_all_zones_managed_pages();
 
 	pages = free_low_memory_core_early();
-	totalram_pages += pages;
+	totalram_pages_add(pages);
 
 	return pages;
 }
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 6838a53..3391710 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -146,7 +146,7 @@ static void __meminit mm_compute_batch(void)
 	s32 batch = max_t(s32, nr*2, 32);
 
 	/* batch size set to 0.4% of (total memory/#cpus), or max int32 */
-	memsized_batch = min_t(u64, (totalram_pages/nr)/256, 0x7fffffff);
+	memsized_batch = min_t(u64, (totalram_pages()/nr)/256, 0x7fffffff);
 
 	vm_committed_as_batch = max_t(s32, memsized_batch, batch);
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6589f60..21d4877 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -269,7 +269,7 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	}
 
 	/* Default to all available memory */
-	oc->totalpages = totalram_pages + total_swap_pages;
+	oc->totalpages = totalram_pages() + total_swap_pages;
 
 	if (!IS_ENABLED(CONFIG_NUMA))
 		return CONSTRAINT_NONE;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 22e6645..f8b64cc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -16,6 +16,7 @@
 
 #include <linux/stddef.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/swap.h>
 #include <linux/interrupt.h>
 #include <linux/pagemap.h>
@@ -124,7 +125,8 @@
 /* Protect totalram_pages and zone->managed_pages */
 static DEFINE_SPINLOCK(managed_page_count_lock);
 
-unsigned long totalram_pages __read_mostly;
+atomic_long_t _totalram_pages __read_mostly;
+EXPORT_SYMBOL(_totalram_pages);
 unsigned long totalreserve_pages __read_mostly;
 unsigned long totalcma_pages __read_mostly;
 
@@ -4748,11 +4750,11 @@ long si_mem_available(void)
 
 void si_meminfo(struct sysinfo *val)
 {
-	val->totalram = totalram_pages;
+	val->totalram = totalram_pages();
 	val->sharedram = global_node_page_state(NR_SHMEM);
 	val->freeram = global_zone_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
-	val->totalhigh = totalhigh_pages;
+	val->totalhigh = totalhigh_pages();
 	val->freehigh = nr_free_highpages();
 	val->mem_unit = PAGE_SIZE;
 }
@@ -7065,10 +7067,10 @@ void adjust_managed_page_count(struct page *page, long count)
 {
 	spin_lock(&managed_page_count_lock);
 	atomic_long_add(count, &page_zone(page)->managed_pages);
-	totalram_pages += count;
+	totalram_pages_add(count);
 #ifdef CONFIG_HIGHMEM
 	if (PageHighMem(page))
-		totalhigh_pages += count;
+		totalhigh_pages_add(count);
 #endif
 	spin_unlock(&managed_page_count_lock);
 }
@@ -7111,9 +7113,9 @@ unsigned long free_reserved_area(void *start, void *end, int poison, char *s)
 void free_highmem_page(struct page *page)
 {
 	__free_reserved_page(page);
-	totalram_pages++;
+	totalram_pages_inc();
 	atomic_long_inc(&page_zone(page)->managed_pages);
-	totalhigh_pages++;
+	totalhigh_pages_inc();
 }
 #endif
 
@@ -7162,10 +7164,10 @@ void __init mem_init_print_info(const char *str)
 		physpages << (PAGE_SHIFT - 10),
 		codesize >> 10, datasize >> 10, rosize >> 10,
 		(init_data_size + init_code_size) >> 10, bss_size >> 10,
-		(physpages - totalram_pages - totalcma_pages) << (PAGE_SHIFT - 10),
+		(physpages - totalram_pages() - totalcma_pages) << (PAGE_SHIFT - 10),
 		totalcma_pages << (PAGE_SHIFT - 10),
 #ifdef	CONFIG_HIGHMEM
-		totalhigh_pages << (PAGE_SHIFT - 10),
+		totalhigh_pages() << (PAGE_SHIFT - 10),
 #endif
 		str ? ", " : "", str ? str : "");
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index ccc08ea..14c7e5e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -109,13 +109,13 @@ struct shmem_falloc {
 #ifdef CONFIG_TMPFS
 static unsigned long shmem_default_max_blocks(void)
 {
-	return totalram_pages / 2;
+	return totalram_pages() / 2;
 }
 
 static unsigned long shmem_default_max_inodes(void)
 {
-	unsigned long nr_pages = totalram_pages;
-	return min(nr_pages - totalhigh_pages, nr_pages / 2);
+	unsigned long nr_pages = totalram_pages();
+	return min(nr_pages - totalhigh_pages(), nr_pages / 2);
 }
 #endif
 
@@ -3275,7 +3275,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			size = memparse(value,&rest);
 			if (*rest == '%') {
 				size <<= PAGE_SHIFT;
-				size *= totalram_pages;
+				size *= totalram_pages();
 				do_div(size, 100);
 				rest++;
 			}
diff --git a/mm/slab.c b/mm/slab.c
index 2a5654b..bc3de2f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1248,7 +1248,7 @@ void __init kmem_cache_init(void)
 	 * page orders on machines with more than 32MB of memory if
 	 * not overridden on the command line.
 	 */
-	if (!slab_max_order_set && totalram_pages > (32 << 20) >> PAGE_SHIFT)
+	if (!slab_max_order_set && totalram_pages() > (32 << 20) >> PAGE_SHIFT)
 		slab_max_order = SLAB_MAX_ORDER_HI;
 
 	/* Bootstrap is tricky, because several objects are allocated
diff --git a/mm/swap.c b/mm/swap.c
index aa48371..a87bd4c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -1023,7 +1023,7 @@ unsigned pagevec_lookup_range_nr_tag(struct pagevec *pvec,
  */
 void __init swap_setup(void)
 {
-	unsigned long megs = totalram_pages >> (20 - PAGE_SHIFT);
+	unsigned long megs = totalram_pages() >> (20 - PAGE_SHIFT);
 
 	/* Use a smaller cluster for small-memory machines */
 	if (megs < 16)
diff --git a/mm/util.c b/mm/util.c
index 8bf08b5..4df23d6 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -593,7 +593,7 @@ unsigned long vm_commit_limit(void)
 	if (sysctl_overcommit_kbytes)
 		allowed = sysctl_overcommit_kbytes >> (PAGE_SHIFT - 10);
 	else
-		allowed = ((totalram_pages - hugetlb_total_pages())
+		allowed = ((totalram_pages() - hugetlb_total_pages())
 			   * sysctl_overcommit_ratio / 100);
 	allowed += total_swap_pages;
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 97d4b25..871e41c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1634,7 +1634,7 @@ void *vmap(struct page **pages, unsigned int count,
 
 	might_sleep();
 
-	if (count > totalram_pages)
+	if (count > totalram_pages())
 		return NULL;
 
 	size = (unsigned long)count << PAGE_SHIFT;
@@ -1739,7 +1739,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	unsigned long real_size = size;
 
 	size = PAGE_ALIGN(size);
-	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
+	if (!size || (size >> PAGE_SHIFT) > totalram_pages())
 		goto fail;
 
 	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED |
diff --git a/mm/workingset.c b/mm/workingset.c
index d46f8c9..dcb994f 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -549,7 +549,7 @@ static int __init workingset_init(void)
 	 * double the initial memory by using totalram_pages as-is.
 	 */
 	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
-	max_order = fls_long(totalram_pages - 1);
+	max_order = fls_long(totalram_pages() - 1);
 	if (max_order > timestamp_bits)
 		bucket_order = max_order - timestamp_bits;
 	pr_info("workingset: timestamp_bits=%d max_order=%d bucket_order=%u\n",
diff --git a/mm/zswap.c b/mm/zswap.c
index cd91fd9..a4e4d36 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -219,8 +219,8 @@ struct zswap_tree {
 
 static bool zswap_is_full(void)
 {
-	return totalram_pages * zswap_max_pool_percent / 100 <
-		DIV_ROUND_UP(zswap_pool_total_size, PAGE_SIZE);
+	return totalram_pages() * zswap_max_pool_percent / 100 <
+			DIV_ROUND_UP(zswap_pool_total_size, PAGE_SIZE);
 }
 
 static void zswap_update_total_size(void)
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 4687960..8b47f94 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1131,7 +1131,7 @@ static inline void dccp_mib_exit(void)
 static int __init dccp_init(void)
 {
 	unsigned long goal;
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 	int ehash_order, bhash_order, i;
 	int rc;
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 1c002c0..950613e 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1866,7 +1866,7 @@ void __init dn_route_init(void)
 	dn_route_timer.expires = jiffies + decnet_dst_gc_interval * HZ;
 	add_timer(&dn_route_timer);
 
-	goal = totalram_pages >> (26 - PAGE_SHIFT);
+	goal = totalram_pages() >> (26 - PAGE_SHIFT);
 
 	for(order = 0; (1UL << order) < goal; order++)
 		/* NOTHING */;
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 03b51cd..b467a7c 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1000,7 +1000,7 @@ static int __net_init tcp_net_metrics_init(struct net *net)
 
 	slots = tcpmhash_entries;
 	if (!slots) {
-		if (totalram_pages >= 128 * 1024)
+		if (totalram_pages() >= 128 * 1024)
 			slots = 16 * 1024;
 		else
 			slots = 8 * 1024;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0480866..2764218 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -2251,7 +2251,7 @@ static __always_inline unsigned int total_extension_size(void)
 
 int nf_conntrack_init_start(void)
 {
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 	int max_factor = 8;
 	int ret = -ENOMEM;
 	int i;
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 9e7f9a3..ee828c3 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -274,7 +274,7 @@ static int htable_create(struct net *net, struct hashlimit_cfg3 *cfg,
 	struct xt_hashlimit_htable *hinfo;
 	const struct seq_operations *ops;
 	unsigned int size, i;
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 	int ret;
 
 	if (cfg->size) {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index a5b2418..d5878ae 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1368,7 +1368,7 @@ static __init int sctp_init(void)
 	int status = -EINVAL;
 	unsigned long goal;
 	unsigned long limit;
-	unsigned long nr_pages = totalram_pages;
+	unsigned long nr_pages = totalram_pages();
 	int max_share;
 	int order;
 	int num_entries;
diff --git a/security/integrity/ima/ima_kexec.c b/security/integrity/ima/ima_kexec.c
index 16bd187..d6f3280 100644
--- a/security/integrity/ima/ima_kexec.c
+++ b/security/integrity/ima/ima_kexec.c
@@ -106,7 +106,7 @@ void ima_add_kexec_buffer(struct kimage *image)
 		kexec_segment_size = ALIGN(ima_get_binary_runtime_size() +
 					   PAGE_SIZE / 2, PAGE_SIZE);
 	if ((kexec_segment_size == ULONG_MAX) ||
-	    ((kexec_segment_size >> PAGE_SHIFT) > totalram_pages / 2)) {
+	    ((kexec_segment_size >> PAGE_SHIFT) > totalram_pages() / 2)) {
 		pr_err("Binary measurement list too large.\n");
 		return;
 	}
-- 
1.9.1
