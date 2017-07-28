Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39A246B0508
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:19:16 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c74so175555023iod.4
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:19:16 -0700 (PDT)
Received: from mail-it0-f68.google.com (mail-it0-f68.google.com. [209.85.214.68])
        by mx.google.com with ESMTPS id n101si133210ioo.81.2017.07.28.02.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 02:19:14 -0700 (PDT)
Received: by mail-it0-f68.google.com with SMTP id r9so14351227ita.3
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:19:14 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Date: Fri, 28 Jul 2017 11:19:04 +0200
Message-Id: <20170728091904.14627-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

GFP_TEMPORARY has been introduced by e12ba74d8ff3 ("Group short-lived
and reclaimable kernel allocations") along with __GFP_RECLAIMABLE. It's
primary motivation was to allow users to tell that an allocation is
short lived and so the allocator can try to place such allocations close
together and prevent long term fragmentation. As much as this sounds
like a reasonable semantic it becomes much less clear when to use the
highlevel GFP_TEMPORARY allocation flag. How long is temporary? Can
the context holding that memory sleep? Can it take locks? It seems
there is no good answer for those questions.

The current implementation of GFP_TEMPORARY is basically
GFP_KERNEL | __GFP_RECLAIMABLE which in itself is tricky because
basically none of the existing caller provide a way to reclaim the
allocated memory. So this is rather misleading and hard to evaluate for
any benefits.

I have checked some random users and none of them has added the flag
with a specific justification. I suspect most of them just copied from
other existing users and others just thought it might be a good idea
to use without any measuring. This suggests that GFP_TEMPORARY just
motivates for cargo cult usage without any reasoning.

I believe that our gfp flags are quite complex already and especially
those with highlevel semantic should be clearly defined to prevent from
confusion and abuse. Therefore I propose dropping GFP_TEMPORARY and
replace all existing users to simply use GFP_KERNEL. Please note that
SLAB users with shrinkers will still get __GFP_RECLAIMABLE heuristic
and so they will be placed properly for memory fragmentation prevention.

I can see reasons we might want some gfp flag to reflect shorterm
allocations but I propose starting from a clear semantic definition and
only then add users with proper justification.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
this has been brought up before LSF this year by Matthew [1] and it
turned out that GFP_TEMPORARY really doesn't have a clear semantic.  It
seems to be a heuristic without any measured advantage for most (if
not all) its current users. The follow up discussion has revealed that
opinions on what might be temporary allocation differ a lot between
developers. So rather than trying to tweak existing users into a
semantic which they haven't expected I propose to simply remove the
flag and start from scratch if we really need a semantic for short term
allocations.

[1] http://lkml.kernel.org/r/20170118054945.GD18349@bombadil.infradead.org

 arch/arc/kernel/setup.c                            |  2 +-
 arch/arc/kernel/troubleshoot.c                     |  2 +-
 arch/powerpc/kernel/rtas.c                         |  4 ++--
 arch/powerpc/platforms/pseries/suspend.c           |  2 +-
 drivers/gpu/drm/drm_blend.c                        |  2 +-
 drivers/gpu/drm/drm_dp_dual_mode_helper.c          |  2 +-
 drivers/gpu/drm/drm_scdc_helper.c                  |  2 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c       |  2 +-
 drivers/gpu/drm/i915/i915_gem.c                    |  2 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c         |  6 +++---
 drivers/gpu/drm/i915/i915_gem_gtt.c                |  2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            |  4 ++--
 drivers/gpu/drm/i915/i915_gpu_error.c              |  6 +++---
 drivers/gpu/drm/i915/selftests/i915_random.c       |  2 +-
 drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c | 10 +++++-----
 drivers/gpu/drm/i915/selftests/intel_uncore.c      |  2 +-
 drivers/gpu/drm/lib/drm_random.c                   |  2 +-
 drivers/gpu/drm/msm/msm_gem_submit.c               |  2 +-
 drivers/gpu/drm/selftests/test-drm_mm.c            |  4 ++--
 drivers/misc/cxl/pci.c                             |  2 +-
 drivers/xen/gntalloc.c                             |  2 +-
 fs/coredump.c                                      |  2 +-
 fs/exec.c                                          |  4 ++--
 fs/overlayfs/copy_up.c                             |  2 +-
 fs/overlayfs/dir.c                                 |  2 +-
 fs/overlayfs/namei.c                               |  8 ++++----
 fs/proc/base.c                                     |  8 ++++----
 fs/proc/task_mmu.c                                 |  2 +-
 include/linux/gfp.h                                |  2 --
 include/trace/events/mmflags.h                     |  1 -
 kernel/locking/test-ww_mutex.c                     |  2 +-
 kernel/trace/trace_events_filter.c                 |  2 +-
 lib/string_helpers.c                               |  4 ++--
 mm/shmem.c                                         |  2 +-
 mm/slub.c                                          |  2 +-
 tools/perf/builtin-kmem.c                          |  1 -
 36 files changed, 52 insertions(+), 56 deletions(-)

diff --git a/arch/arc/kernel/setup.c b/arch/arc/kernel/setup.c
index fc8211f338ad..8e80cc2b1efb 100644
--- a/arch/arc/kernel/setup.c
+++ b/arch/arc/kernel/setup.c
@@ -510,7 +510,7 @@ static int show_cpuinfo(struct seq_file *m, void *v)
 		goto done;
 	}
 
-	str = (char *)__get_free_page(GFP_TEMPORARY);
+	str = (char *)__get_free_page(GFP_KERNEL);
 	if (!str)
 		goto done;
 
diff --git a/arch/arc/kernel/troubleshoot.c b/arch/arc/kernel/troubleshoot.c
index f9caf79186d4..5a76b3d3cff4 100644
--- a/arch/arc/kernel/troubleshoot.c
+++ b/arch/arc/kernel/troubleshoot.c
@@ -178,7 +178,7 @@ void show_regs(struct pt_regs *regs)
 	struct callee_regs *cregs;
 	char *buf;
 
-	buf = (char *)__get_free_page(GFP_TEMPORARY);
+	buf = (char *)__get_free_page(GFP_KERNEL);
 	if (!buf)
 		return;
 
diff --git a/arch/powerpc/kernel/rtas.c b/arch/powerpc/kernel/rtas.c
index b8a4987f58cf..90d27dcd0da8 100644
--- a/arch/powerpc/kernel/rtas.c
+++ b/arch/powerpc/kernel/rtas.c
@@ -914,7 +914,7 @@ int rtas_online_cpus_mask(cpumask_var_t cpus)
 	if (ret) {
 		cpumask_var_t tmp_mask;
 
-		if (!alloc_cpumask_var(&tmp_mask, GFP_TEMPORARY))
+		if (!alloc_cpumask_var(&tmp_mask, GFP_KENREL))
 			return ret;
 
 		/* Use tmp_mask to preserve cpus mask from first failure */
@@ -962,7 +962,7 @@ int rtas_ibm_suspend_me(u64 handle)
 		return -EIO;
 	}
 
-	if (!alloc_cpumask_var(&offline_mask, GFP_TEMPORARY))
+	if (!alloc_cpumask_var(&offline_mask, GFP_KERNEL))
 		return -ENOMEM;
 
 	atomic_set(&data.working, 0);
diff --git a/arch/powerpc/platforms/pseries/suspend.c b/arch/powerpc/platforms/pseries/suspend.c
index e76aefae2aa2..89726f07d249 100644
--- a/arch/powerpc/platforms/pseries/suspend.c
+++ b/arch/powerpc/platforms/pseries/suspend.c
@@ -151,7 +151,7 @@ static ssize_t store_hibernate(struct device *dev,
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	if (!alloc_cpumask_var(&offline_mask, GFP_TEMPORARY))
+	if (!alloc_cpumask_var(&offline_mask, GFP_KERNEL))
 		return -ENOMEM;
 
 	stream_id = simple_strtoul(buf, NULL, 16);
diff --git a/drivers/gpu/drm/drm_blend.c b/drivers/gpu/drm/drm_blend.c
index a0d0d6843288..d461d8f27293 100644
--- a/drivers/gpu/drm/drm_blend.c
+++ b/drivers/gpu/drm/drm_blend.c
@@ -318,7 +318,7 @@ static int drm_atomic_helper_crtc_normalize_zpos(struct drm_crtc *crtc,
 	DRM_DEBUG_ATOMIC("[CRTC:%d:%s] calculating normalized zpos values\n",
 			 crtc->base.id, crtc->name);
 
-	states = kmalloc_array(total_planes, sizeof(*states), GFP_TEMPORARY);
+	states = kmalloc_array(total_planes, sizeof(*states), GFP_KERNEL);
 	if (!states)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/drm_dp_dual_mode_helper.c b/drivers/gpu/drm/drm_dp_dual_mode_helper.c
index 80e62f669321..0ef9011a1856 100644
--- a/drivers/gpu/drm/drm_dp_dual_mode_helper.c
+++ b/drivers/gpu/drm/drm_dp_dual_mode_helper.c
@@ -111,7 +111,7 @@ ssize_t drm_dp_dual_mode_write(struct i2c_adapter *adapter,
 	void *data;
 	int ret;
 
-	data = kmalloc(msg.len, GFP_TEMPORARY);
+	data = kmalloc(msg.len, GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/drm_scdc_helper.c b/drivers/gpu/drm/drm_scdc_helper.c
index 3cd96a95736d..8f9b91c430eb 100644
--- a/drivers/gpu/drm/drm_scdc_helper.c
+++ b/drivers/gpu/drm/drm_scdc_helper.c
@@ -102,7 +102,7 @@ ssize_t drm_scdc_write(struct i2c_adapter *adapter, u8 offset,
 	void *data;
 	int err;
 
-	data = kmalloc(1 + size, GFP_TEMPORARY);
+	data = kmalloc(1 + size, GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c b/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
index 1013765274da..623a48bfe6af 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
@@ -37,7 +37,7 @@ static struct etnaviv_gem_submit *submit_create(struct drm_device *dev,
 	struct etnaviv_gem_submit *submit;
 	size_t sz = size_vstruct(nr, sizeof(submit->bos[0]), sizeof(*submit));
 
-	submit = kmalloc(sz, GFP_TEMPORARY | __GFP_NOWARN | __GFP_NORETRY);
+	submit = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
 	if (submit) {
 		submit->dev = dev;
 		submit->gpu = gpu;
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 7652451e7dbe..beb72d63a8c2 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2525,7 +2525,7 @@ static void *i915_gem_object_map(const struct drm_i915_gem_object *obj,
 
 	if (n_pages > ARRAY_SIZE(stack_pages)) {
 		/* Too big for stack -- allocate temporary array instead */
-		pages = drm_malloc_gfp(n_pages, sizeof(*pages), GFP_TEMPORARY);
+		pages = drm_malloc_gfp(n_pages, sizeof(*pages), GFP_KERNEL);
 		if (!pages)
 			return NULL;
 	}
diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
index 9ad13eeed904..ce8f8564059e 100644
--- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
+++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
@@ -81,7 +81,7 @@ eb_create(struct drm_i915_private *i915,
 		unsigned size = args->buffer_count;
 		size *= sizeof(struct i915_vma *);
 		size += sizeof(struct eb_vmas);
-		eb = kmalloc(size, GFP_TEMPORARY | __GFP_NOWARN | __GFP_NORETRY);
+		eb = kmalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
 	}
 
 	if (eb == NULL) {
@@ -92,7 +92,7 @@ eb_create(struct drm_i915_private *i915,
 			count >>= 1;
 		eb = kzalloc(count*sizeof(struct hlist_head) +
 			     sizeof(struct eb_vmas),
-			     GFP_TEMPORARY);
+			     GFP_KERNEL);
 		if (eb == NULL)
 			return eb;
 
@@ -1956,7 +1956,7 @@ i915_gem_execbuffer2(struct drm_device *dev, void *data,
 
 	exec2_list = drm_malloc_gfp(args->buffer_count,
 				    sizeof(*exec2_list),
-				    GFP_TEMPORARY);
+				    GFP_KERNEL);
 	if (exec2_list == NULL) {
 		DRM_DEBUG("Failed to allocate exec list for %d buffers\n",
 			  args->buffer_count);
diff --git a/drivers/gpu/drm/i915/i915_gem_gtt.c b/drivers/gpu/drm/i915/i915_gem_gtt.c
index f1989b8792dd..def3f699b2b6 100644
--- a/drivers/gpu/drm/i915/i915_gem_gtt.c
+++ b/drivers/gpu/drm/i915/i915_gem_gtt.c
@@ -3212,7 +3212,7 @@ intel_rotate_pages(struct intel_rotation_info *rot_info,
 	/* Allocate a temporary list of source pages for random access. */
 	page_addr_list = drm_malloc_gfp(n_pages,
 					sizeof(dma_addr_t),
-					GFP_TEMPORARY);
+					GFP_KERNEL);
 	if (!page_addr_list)
 		return ERR_PTR(ret);
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 58ccf8b8ca1c..824021fe5fb2 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -507,7 +507,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 	ret = -ENOMEM;
 	pinned = 0;
 
-	pvec = drm_malloc_gfp(npages, sizeof(struct page *), GFP_TEMPORARY);
+	pvec = drm_malloc_gfp(npages, sizeof(struct page *), GFP_KERNEL);
 	if (pvec != NULL) {
 		struct mm_struct *mm = obj->userptr.mm->mm;
 		unsigned int flags = 0;
@@ -643,7 +643,7 @@ i915_gem_userptr_get_pages(struct drm_i915_gem_object *obj)
 
 	if (mm == current->mm) {
 		pvec = drm_malloc_gfp(num_pages, sizeof(struct page *),
-				      GFP_TEMPORARY |
+				      GFP_KERNEL |
 				      __GFP_NORETRY |
 				      __GFP_NOWARN);
 		if (pvec) /* defer to worker if malloc fails */
diff --git a/drivers/gpu/drm/i915/i915_gpu_error.c b/drivers/gpu/drm/i915/i915_gpu_error.c
index 8effc59f5cb5..c65e466d062b 100644
--- a/drivers/gpu/drm/i915/i915_gpu_error.c
+++ b/drivers/gpu/drm/i915/i915_gpu_error.c
@@ -782,16 +782,16 @@ int i915_error_state_buf_init(struct drm_i915_error_state_buf *ebuf,
 	 */
 	ebuf->size = count + 1 > PAGE_SIZE ? count + 1 : PAGE_SIZE;
 	ebuf->buf = kmalloc(ebuf->size,
-				GFP_TEMPORARY | __GFP_NORETRY | __GFP_NOWARN);
+				GFP_KERNEL | __GFP_NORETRY | __GFP_NOWARN);
 
 	if (ebuf->buf == NULL) {
 		ebuf->size = PAGE_SIZE;
-		ebuf->buf = kmalloc(ebuf->size, GFP_TEMPORARY);
+		ebuf->buf = kmalloc(ebuf->size, GFP_KERNEL);
 	}
 
 	if (ebuf->buf == NULL) {
 		ebuf->size = 128;
-		ebuf->buf = kmalloc(ebuf->size, GFP_TEMPORARY);
+		ebuf->buf = kmalloc(ebuf->size, GFP_KERNEL);
 	}
 
 	if (ebuf->buf == NULL)
diff --git a/drivers/gpu/drm/i915/selftests/i915_random.c b/drivers/gpu/drm/i915/selftests/i915_random.c
index c17c83c30637..b558e97c63cc 100644
--- a/drivers/gpu/drm/i915/selftests/i915_random.c
+++ b/drivers/gpu/drm/i915/selftests/i915_random.c
@@ -51,7 +51,7 @@ unsigned int *i915_random_order(unsigned int count, struct rnd_state *state)
 {
 	unsigned int *order, i;
 
-	order = kmalloc_array(count, sizeof(*order), GFP_TEMPORARY);
+	order = kmalloc_array(count, sizeof(*order), GFP_KERNEL);
 	if (!order)
 		return order;
 
diff --git a/drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c b/drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c
index 19860a372d90..75aaec02d176 100644
--- a/drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c
+++ b/drivers/gpu/drm/i915/selftests/intel_breadcrumbs.c
@@ -117,12 +117,12 @@ static int igt_random_insert_remove(void *arg)
 
 	mock_engine_reset(engine);
 
-	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_TEMPORARY);
+	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_KERNEL);
 	if (!waiters)
 		goto out_engines;
 
 	bitmap = kcalloc(DIV_ROUND_UP(count, BITS_PER_LONG), sizeof(*bitmap),
-			 GFP_TEMPORARY);
+			 GFP_KERNEL);
 	if (!bitmap)
 		goto out_waiters;
 
@@ -187,12 +187,12 @@ static int igt_insert_complete(void *arg)
 
 	mock_engine_reset(engine);
 
-	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_TEMPORARY);
+	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_KERNEL);
 	if (!waiters)
 		goto out_engines;
 
 	bitmap = kcalloc(DIV_ROUND_UP(count, BITS_PER_LONG), sizeof(*bitmap),
-			 GFP_TEMPORARY);
+			 GFP_KERNEL);
 	if (!bitmap)
 		goto out_waiters;
 
@@ -368,7 +368,7 @@ static int igt_wakeup(void *arg)
 
 	mock_engine_reset(engine);
 
-	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_TEMPORARY);
+	waiters = drm_malloc_gfp(count, sizeof(*waiters), GFP_KERNEL);
 	if (!waiters)
 		goto out_engines;
 
diff --git a/drivers/gpu/drm/i915/selftests/intel_uncore.c b/drivers/gpu/drm/i915/selftests/intel_uncore.c
index 2d0fef2cfca6..3cac22eb47ce 100644
--- a/drivers/gpu/drm/i915/selftests/intel_uncore.c
+++ b/drivers/gpu/drm/i915/selftests/intel_uncore.c
@@ -127,7 +127,7 @@ static int intel_uncore_check_forcewake_domains(struct drm_i915_private *dev_pri
 		return 0;
 
 	valid = kzalloc(BITS_TO_LONGS(FW_RANGE) * sizeof(*valid),
-			GFP_TEMPORARY);
+			GFP_KERNEL);
 	if (!valid)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/lib/drm_random.c b/drivers/gpu/drm/lib/drm_random.c
index 7b12a68c3b54..a78c4b483e8d 100644
--- a/drivers/gpu/drm/lib/drm_random.c
+++ b/drivers/gpu/drm/lib/drm_random.c
@@ -28,7 +28,7 @@ unsigned int *drm_random_order(unsigned int count, struct rnd_state *state)
 {
 	unsigned int *order, i;
 
-	order = kmalloc_array(count, sizeof(*order), GFP_TEMPORARY);
+	order = kmalloc_array(count, sizeof(*order), GFP_KERNEL);
 	if (!order)
 		return order;
 
diff --git a/drivers/gpu/drm/msm/msm_gem_submit.c b/drivers/gpu/drm/msm/msm_gem_submit.c
index 7832e6421d25..1828c40abeb2 100644
--- a/drivers/gpu/drm/msm/msm_gem_submit.c
+++ b/drivers/gpu/drm/msm/msm_gem_submit.c
@@ -37,7 +37,7 @@ static struct msm_gem_submit *submit_create(struct drm_device *dev,
 	int sz = sizeof(*submit) + (nr_bos * sizeof(submit->bos[0])) +
 			(nr_cmds * sizeof(*submit->cmd));
 
-	submit = kmalloc(sz, GFP_TEMPORARY | __GFP_NOWARN | __GFP_NORETRY);
+	submit = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
 	if (!submit)
 		return NULL;
 
diff --git a/drivers/gpu/drm/selftests/test-drm_mm.c b/drivers/gpu/drm/selftests/test-drm_mm.c
index fa356f5dae27..460a750abbfb 100644
--- a/drivers/gpu/drm/selftests/test-drm_mm.c
+++ b/drivers/gpu/drm/selftests/test-drm_mm.c
@@ -1608,7 +1608,7 @@ static int igt_topdown(void *ignored)
 		goto err;
 
 	bitmap = kzalloc(count / BITS_PER_LONG * sizeof(unsigned long),
-			 GFP_TEMPORARY);
+			 GFP_KERNEL);
 	if (!bitmap)
 		goto err_nodes;
 
@@ -1721,7 +1721,7 @@ static int igt_bottomup(void *ignored)
 		goto err;
 
 	bitmap = kzalloc(count / BITS_PER_LONG * sizeof(unsigned long),
-			 GFP_TEMPORARY);
+			 GFP_KERNEL);
 	if (!bitmap)
 		goto err_nodes;
 
diff --git a/drivers/misc/cxl/pci.c b/drivers/misc/cxl/pci.c
index 1eb9859809bf..3b1f7ffd6f38 100644
--- a/drivers/misc/cxl/pci.c
+++ b/drivers/misc/cxl/pci.c
@@ -1266,7 +1266,7 @@ ssize_t cxl_pci_afu_read_err_buffer(struct cxl_afu *afu, char *buf,
 	}
 
 	/* use bounce buffer for copy */
-	tbuf = (void *)__get_free_page(GFP_TEMPORARY);
+	tbuf = (void *)__get_free_page(GFP_KERNEL);
 	if (!tbuf)
 		return -ENOMEM;
 
diff --git a/drivers/xen/gntalloc.c b/drivers/xen/gntalloc.c
index 1bf55a32a4b3..3fa40c723e8e 100644
--- a/drivers/xen/gntalloc.c
+++ b/drivers/xen/gntalloc.c
@@ -294,7 +294,7 @@ static long gntalloc_ioctl_alloc(struct gntalloc_file_private_data *priv,
 		goto out;
 	}
 
-	gref_ids = kcalloc(op.count, sizeof(gref_ids[0]), GFP_TEMPORARY);
+	gref_ids = kcalloc(op.count, sizeof(gref_ids[0]), GFP_KERNEL);
 	if (!gref_ids) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/fs/coredump.c b/fs/coredump.c
index 592683711c64..0eec03696707 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -161,7 +161,7 @@ static int cn_print_exe_file(struct core_name *cn)
 	if (!exe_file)
 		return cn_esc_printf(cn, "%s (path unknown)", current->comm);
 
-	pathbuf = kmalloc(PATH_MAX, GFP_TEMPORARY);
+	pathbuf = kmalloc(PATH_MAX, GFP_KERNEL);
 	if (!pathbuf) {
 		ret = -ENOMEM;
 		goto put_exe_file;
diff --git a/fs/exec.c b/fs/exec.c
index 62175cbcc801..65b4a7b75431 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1737,9 +1737,9 @@ static int do_execveat_common(int fd, struct filename *filename,
 		bprm->filename = filename->name;
 	} else {
 		if (filename->name[0] == '\0')
-			pathbuf = kasprintf(GFP_TEMPORARY, "/dev/fd/%d", fd);
+			pathbuf = kasprintf(GFP_KERNEL, "/dev/fd/%d", fd);
 		else
-			pathbuf = kasprintf(GFP_TEMPORARY, "/dev/fd/%d/%s",
+			pathbuf = kasprintf(GFP_KERNEL, "/dev/fd/%d/%s",
 					    fd, filename->name);
 		if (!pathbuf) {
 			retval = -ENOMEM;
diff --git a/fs/overlayfs/copy_up.c b/fs/overlayfs/copy_up.c
index a2a65120c9d0..f86a6a8c9343 100644
--- a/fs/overlayfs/copy_up.c
+++ b/fs/overlayfs/copy_up.c
@@ -240,7 +240,7 @@ static struct ovl_fh *ovl_encode_fh(struct dentry *lower, uuid_be *uuid)
 	void *buf;
 	int buflen = MAX_HANDLE_SZ;
 
-	buf = kmalloc(buflen, GFP_TEMPORARY);
+	buf = kmalloc(buflen, GFP_KERNEL);
 	if (!buf)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/fs/overlayfs/dir.c b/fs/overlayfs/dir.c
index a63a71656e9b..f0840883085c 100644
--- a/fs/overlayfs/dir.c
+++ b/fs/overlayfs/dir.c
@@ -802,7 +802,7 @@ static char *ovl_get_redirect(struct dentry *dentry, bool samedir)
 		goto out;
 	}
 
-	buf = ret = kmalloc(buflen, GFP_TEMPORARY);
+	buf = ret = kmalloc(buflen, GFP_KERNEL);
 	if (!buf)
 		goto out;
 
diff --git a/fs/overlayfs/namei.c b/fs/overlayfs/namei.c
index f3136c31e72a..8c50ac5869c8 100644
--- a/fs/overlayfs/namei.c
+++ b/fs/overlayfs/namei.c
@@ -38,7 +38,7 @@ static int ovl_check_redirect(struct dentry *dentry, struct ovl_lookup_data *d,
 			return 0;
 		goto fail;
 	}
-	buf = kzalloc(prelen + res + strlen(post) + 1, GFP_TEMPORARY);
+	buf = kzalloc(prelen + res + strlen(post) + 1, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
@@ -106,7 +106,7 @@ static struct dentry *ovl_get_origin(struct dentry *dentry,
 	if (res == 0)
 		return NULL;
 
-	fh  = kzalloc(res, GFP_TEMPORARY);
+	fh  = kzalloc(res, GFP_KERNEL);
 	if (!fh)
 		return ERR_PTR(-ENOMEM);
 
@@ -296,7 +296,7 @@ static int ovl_check_origin(struct dentry *dentry, struct dentry *upperdentry,
 		return PTR_ERR(origin);
 
 	BUG_ON(*stackp || *ctrp);
-	*stackp = kmalloc(sizeof(struct path), GFP_TEMPORARY);
+	*stackp = kmalloc(sizeof(struct path), GFP_KERNEL);
 	if (!*stackp) {
 		dput(origin);
 		return -ENOMEM;
@@ -393,7 +393,7 @@ struct dentry *ovl_lookup(struct inode *dir, struct dentry *dentry,
 	if (!d.stop && poe->numlower) {
 		err = -ENOMEM;
 		stack = kcalloc(ofs->numlower, sizeof(struct path),
-				GFP_TEMPORARY);
+				GFP_KERNEL);
 		if (!stack)
 			goto out_put_upper;
 	}
diff --git a/fs/proc/base.c b/fs/proc/base.c
index f1e1927ccd48..c061d26fdd0b 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -232,7 +232,7 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 		goto out_mmput;
 	}
 
-	page = (char *)__get_free_page(GFP_TEMPORARY);
+	page = (char *)__get_free_page(GFP_KERNEL);
 	if (!page) {
 		rv = -ENOMEM;
 		goto out_mmput;
@@ -813,7 +813,7 @@ static ssize_t mem_rw(struct file *file, char __user *buf,
 	if (!mm)
 		return 0;
 
-	page = (char *)__get_free_page(GFP_TEMPORARY);
+	page = (char *)__get_free_page(GFP_KERNEL);
 	if (!page)
 		return -ENOMEM;
 
@@ -918,7 +918,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	if (!mm || !mm->env_end)
 		return 0;
 
-	page = (char *)__get_free_page(GFP_TEMPORARY);
+	page = (char *)__get_free_page(GFP_KERNEL);
 	if (!page)
 		return -ENOMEM;
 
@@ -1586,7 +1586,7 @@ static const char *proc_pid_get_link(struct dentry *dentry,
 
 static int do_proc_readlink(struct path *path, char __user *buffer, int buflen)
 {
-	char *tmp = (char*)__get_free_page(GFP_TEMPORARY);
+	char *tmp = (char*)__get_free_page(GFP_KERNEL);
 	char *pathname;
 	int len;
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b836fd61ed87..b96e0fde3d73 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1377,7 +1377,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	pm.show_pfn = file_ns_capable(file, &init_user_ns, CAP_SYS_ADMIN);
 
 	pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
-	pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
+	pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_KERNEL);
 	ret = -ENOMEM;
 	if (!pm.buffer)
 		goto out_mm;
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index bcfb9f7c46f5..f780718b7391 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -288,8 +288,6 @@ struct vm_area_struct;
 #define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
 #define GFP_NOIO	(__GFP_RECLAIM)
 #define GFP_NOFS	(__GFP_RECLAIM | __GFP_IO)
-#define GFP_TEMPORARY	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | \
-			 __GFP_RECLAIMABLE)
 #define GFP_USER	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_DMA		__GFP_DMA
 #define GFP_DMA32	__GFP_DMA32
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 8e50d01c645f..51185fcaf19d 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -18,7 +18,6 @@
 	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"},\
 	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
 	{(unsigned long)GFP_USER,		"GFP_USER"},		\
-	{(unsigned long)GFP_TEMPORARY,		"GFP_TEMPORARY"},	\
 	{(unsigned long)GFP_KERNEL_ACCOUNT,	"GFP_KERNEL_ACCOUNT"},	\
 	{(unsigned long)GFP_KERNEL,		"GFP_KERNEL"},		\
 	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
diff --git a/kernel/locking/test-ww_mutex.c b/kernel/locking/test-ww_mutex.c
index 39f56c870051..0e4cd64ad2c0 100644
--- a/kernel/locking/test-ww_mutex.c
+++ b/kernel/locking/test-ww_mutex.c
@@ -362,7 +362,7 @@ static int *get_random_order(int count)
 	int *order;
 	int n, r, tmp;
 
-	order = kmalloc_array(count, sizeof(*order), GFP_TEMPORARY);
+	order = kmalloc_array(count, sizeof(*order), GFP_KERNEL);
 	if (!order)
 		return order;
 
diff --git a/kernel/trace/trace_events_filter.c b/kernel/trace/trace_events_filter.c
index 59a411ff60c7..f760867a4fe6 100644
--- a/kernel/trace/trace_events_filter.c
+++ b/kernel/trace/trace_events_filter.c
@@ -702,7 +702,7 @@ static void append_filter_err(struct filter_parse_state *ps,
 	int pos = ps->lasterr_pos;
 	char *buf, *pbuf;
 
-	buf = (char *)__get_free_page(GFP_TEMPORARY);
+	buf = (char *)__get_free_page(GFP_KERNEL);
 	if (!buf)
 		return;
 
diff --git a/lib/string_helpers.c b/lib/string_helpers.c
index ecaac2c0526f..29c490e5d478 100644
--- a/lib/string_helpers.c
+++ b/lib/string_helpers.c
@@ -576,7 +576,7 @@ char *kstrdup_quotable_cmdline(struct task_struct *task, gfp_t gfp)
 	char *buffer, *quoted;
 	int i, res;
 
-	buffer = kmalloc(PAGE_SIZE, GFP_TEMPORARY);
+	buffer = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buffer)
 		return NULL;
 
@@ -612,7 +612,7 @@ char *kstrdup_quotable_file(struct file *file, gfp_t gfp)
 		return kstrdup("<unknown>", gfp);
 
 	/* We add 11 spaces for ' (deleted)' to be appended */
-	temp = kmalloc(PATH_MAX + 11, GFP_TEMPORARY);
+	temp = kmalloc(PATH_MAX + 11, GFP_KERNEL);
 	if (!temp)
 		return kstrdup("<no_memory>", gfp);
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 8aa4f4195ea3..f11d9d19384b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3648,7 +3648,7 @@ SYSCALL_DEFINE2(memfd_create,
 	if (len > MFD_NAME_MAX_LEN + 1)
 		return -EINVAL;
 
-	name = kmalloc(len + MFD_NAME_PREFIX_LEN, GFP_TEMPORARY);
+	name = kmalloc(len + MFD_NAME_PREFIX_LEN, GFP_KERNEL);
 	if (!name)
 		return -ENOMEM;
 
diff --git a/mm/slub.c b/mm/slub.c
index 481e523bb30d..9caa6bf2e205 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4561,7 +4561,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 	struct kmem_cache_node *n;
 
 	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
-				     GFP_TEMPORARY)) {
+				     GFP_KERNEL)) {
 		kfree(map);
 		return sprintf(buf, "Out of memory\n");
 	}
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index c4222ea452e9..36c768c39626 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -627,7 +627,6 @@ static const struct {
 	{ "GFP_HIGHUSER_MOVABLE",	"HUM" },
 	{ "GFP_HIGHUSER",		"HU" },
 	{ "GFP_USER",			"U" },
-	{ "GFP_TEMPORARY",		"TMP" },
 	{ "GFP_KERNEL_ACCOUNT",		"KAC" },
 	{ "GFP_KERNEL",			"K" },
 	{ "GFP_NOFS",			"NF" },
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
