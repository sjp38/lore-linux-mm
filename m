Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2217B6B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 09:10:28 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y90so1059453wrb.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:10:28 -0800 (PST)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id a60si145285wrc.277.2017.03.07.06.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 06:10:26 -0800 (PST)
Received: by mail-wr0-f193.google.com with SMTP id u108so388145wrb.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:10:25 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
Date: Tue,  7 Mar 2017 15:10:20 +0100
Message-Id: <20170307141020.29107-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__vmalloc* allows users to provide gfp flags for the underlying
allocation. This API is quite popular
$ git grep "=[[:space:]]__vmalloc\|return[[:space:]]*__vmalloc" | wc -l
77

the only problem is that many people are not aware that they really want
to give __GFP_HIGHMEM along with other flags because there is really no
reason to consume precious lowmemory on CONFIG_HIGHMEM systems for pages
which are mapped to the kernel vmalloc space. About half of users don't
use this flag, though. This signals that we make the API unnecessarily
too complex.

This patch simply uses __GFP_HIGHMEM implicitly when allocating pages to
be mapped to the vmalloc space. Current users which add __GFP_HIGHMEM
are simplified and drop the flag.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this has been posted [1] as an RFC before and nobody really screamed
about this. Well, there was only little feedback, to be honest. I still
believe this is an improvement and the implicit __GFP_HIGHMEM will make
the __vmalloc* usage less error prone.

[1] http://lkml.kernel.org/r/20170201140530.1325-1-mhocko@kernel.org

 arch/parisc/kernel/module.c            |  2 +-
 arch/x86/kernel/module.c               |  2 +-
 drivers/block/drbd/drbd_bitmap.c       |  2 +-
 drivers/gpu/drm/etnaviv/etnaviv_dump.c |  4 ++--
 drivers/md/dm-bufio.c                  |  2 +-
 fs/btrfs/free-space-tree.c             |  3 +--
 fs/file.c                              |  2 +-
 fs/xfs/kmem.c                          |  2 +-
 include/drm/drm_mem_util.h             |  9 +++------
 kernel/bpf/core.c                      |  9 +++------
 kernel/bpf/syscall.c                   |  3 +--
 kernel/fork.c                          |  2 +-
 kernel/groups.c                        |  2 +-
 kernel/module.c                        |  2 +-
 mm/kasan/kasan.c                       |  2 +-
 mm/nommu.c                             |  3 +--
 mm/util.c                              |  2 +-
 mm/vmalloc.c                           | 14 +++++++-------
 net/ceph/ceph_common.c                 |  2 +-
 net/netfilter/x_tables.c               |  3 +--
 20 files changed, 31 insertions(+), 41 deletions(-)

diff --git a/arch/parisc/kernel/module.c b/arch/parisc/kernel/module.c
index a0ecdb4abcc8..3d4f5660a2e0 100644
--- a/arch/parisc/kernel/module.c
+++ b/arch/parisc/kernel/module.c
@@ -218,7 +218,7 @@ void *module_alloc(unsigned long size)
 	 * easier than trying to map the text, data, init_text and
 	 * init_data correctly */
 	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
-				    GFP_KERNEL | __GFP_HIGHMEM,
+				    GFP_KERNEL,
 				    PAGE_KERNEL_RWX, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
 }
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index 477ae806c2fa..f67bd3205df7 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -85,7 +85,7 @@ void *module_alloc(unsigned long size)
 
 	p = __vmalloc_node_range(size, MODULE_ALIGN,
 				    MODULES_VADDR + get_module_load_offset(),
-				    MODULES_END, GFP_KERNEL | __GFP_HIGHMEM,
+				    MODULES_END, GFP_KERNEL,
 				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
 	if (p && (kasan_module_alloc(p, size) < 0)) {
diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
index dece26f119d4..a804a4107fbc 100644
--- a/drivers/block/drbd/drbd_bitmap.c
+++ b/drivers/block/drbd/drbd_bitmap.c
@@ -409,7 +409,7 @@ static struct page **bm_realloc_pages(struct drbd_bitmap *b, unsigned long want)
 	new_pages = kzalloc(bytes, GFP_NOIO | __GFP_NOWARN);
 	if (!new_pages) {
 		new_pages = __vmalloc(bytes,
-				GFP_NOIO | __GFP_HIGHMEM | __GFP_ZERO,
+				GFP_NOIO | __GFP_ZERO,
 				PAGE_KERNEL);
 		if (!new_pages)
 			return NULL;
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_dump.c b/drivers/gpu/drm/etnaviv/etnaviv_dump.c
index d019b5e311cc..2d955d7d7b6d 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_dump.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_dump.c
@@ -161,8 +161,8 @@ void etnaviv_core_dump(struct etnaviv_gpu *gpu)
 	file_size += sizeof(*iter.hdr) * n_obj;
 
 	/* Allocate the file in vmalloc memory, it's likely to be big */
-	iter.start = __vmalloc(file_size, GFP_KERNEL | __GFP_HIGHMEM |
-			       __GFP_NOWARN | __GFP_NORETRY, PAGE_KERNEL);
+	iter.start = __vmalloc(file_size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY,
+			       PAGE_KERNEL);
 	if (!iter.start) {
 		dev_warn(gpu->dev, "failed to allocate devcoredump file\n");
 		return;
diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index df4859f6ac6a..c058ae86f51b 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -404,7 +404,7 @@ static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t gfp_mask,
 	if (gfp_mask & __GFP_NORETRY)
 		noio_flag = memalloc_noio_save();
 
-	ptr = __vmalloc(c->block_size, gfp_mask | __GFP_HIGHMEM, PAGE_KERNEL);
+	ptr = __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
 
 	if (gfp_mask & __GFP_NORETRY)
 		memalloc_noio_restore(noio_flag);
diff --git a/fs/btrfs/free-space-tree.c b/fs/btrfs/free-space-tree.c
index dd7fb22a955a..fc0bd8406758 100644
--- a/fs/btrfs/free-space-tree.c
+++ b/fs/btrfs/free-space-tree.c
@@ -167,8 +167,7 @@ static u8 *alloc_bitmap(u32 bitmap_size)
 	if (mem)
 		return mem;
 
-	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_HIGHMEM | __GFP_ZERO,
-			 PAGE_KERNEL);
+	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_ZERO, PAGE_KERNEL);
 }
 
 int convert_free_space_to_bitmaps(struct btrfs_trans_handle *trans,
diff --git a/fs/file.c b/fs/file.c
index ad6f094f2eff..1c2972e3a405 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -42,7 +42,7 @@ static void *alloc_fdmem(size_t size)
 		if (data != NULL)
 			return data;
 	}
-	return __vmalloc(size, GFP_KERNEL_ACCOUNT | __GFP_HIGHMEM, PAGE_KERNEL);
+	return __vmalloc(size, GFP_KERNEL_ACCOUNT, PAGE_KERNEL);
 }
 
 static void __free_fdtable(struct fdtable *fdt)
diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index 6b7b04468aa8..b95f9c41556e 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -85,7 +85,7 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
 		nofs_flag = memalloc_nofs_save();
 
 	lflags = kmem_flags_convert(flags);
-	ptr = __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
+	ptr = __vmalloc(size, lflags | __GFP_ZERO, PAGE_KERNEL);
 
 	if (flags & KM_NOFS)
 		memalloc_nofs_restore(nofs_flag);
diff --git a/include/drm/drm_mem_util.h b/include/drm/drm_mem_util.h
index 70d4e221a3ad..d0f6cf2e5324 100644
--- a/include/drm/drm_mem_util.h
+++ b/include/drm/drm_mem_util.h
@@ -37,8 +37,7 @@ static __inline__ void *drm_calloc_large(size_t nmemb, size_t size)
 	if (size * nmemb <= PAGE_SIZE)
 	    return kcalloc(nmemb, size, GFP_KERNEL);
 
-	return __vmalloc(size * nmemb,
-			 GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
+	return vzalloc(size * nmemb);
 }
 
 /* Modeled after cairo's malloc_ab, it's like calloc but without the zeroing. */
@@ -50,8 +49,7 @@ static __inline__ void *drm_malloc_ab(size_t nmemb, size_t size)
 	if (size * nmemb <= PAGE_SIZE)
 	    return kmalloc(nmemb * size, GFP_KERNEL);
 
-	return __vmalloc(size * nmemb,
-			 GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL);
+	return vmalloc(size * nmemb);
 }
 
 static __inline__ void *drm_malloc_gfp(size_t nmemb, size_t size, gfp_t gfp)
@@ -69,8 +67,7 @@ static __inline__ void *drm_malloc_gfp(size_t nmemb, size_t size, gfp_t gfp)
 			return ptr;
 	}
 
-	return __vmalloc(size * nmemb,
-			 gfp | __GFP_HIGHMEM, PAGE_KERNEL);
+	return __vmalloc(size * nmemb, gfp, PAGE_KERNEL);
 }
 
 static __inline void drm_free_large(void *ptr)
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index f45827e205d3..33b7861b517c 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -76,8 +76,7 @@ void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, uns
 
 struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 {
-	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
-			  gfp_extra_flags;
+	gfp_t gfp_flags = GFP_KERNEL | __GFP_ZERO | gfp_extra_flags;
 	struct bpf_prog_aux *aux;
 	struct bpf_prog *fp;
 
@@ -107,8 +106,7 @@ EXPORT_SYMBOL_GPL(bpf_prog_alloc);
 struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 				  gfp_t gfp_extra_flags)
 {
-	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
-			  gfp_extra_flags;
+	gfp_t gfp_flags = GFP_KERNEL | __GFP_ZERO | gfp_extra_flags;
 	struct bpf_prog *fp;
 	u32 pages, delta;
 	int ret;
@@ -659,8 +657,7 @@ static int bpf_jit_blind_insn(const struct bpf_insn *from,
 static struct bpf_prog *bpf_prog_clone_create(struct bpf_prog *fp_other,
 					      gfp_t gfp_extra_flags)
 {
-	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
-			  gfp_extra_flags;
+	gfp_t gfp_flags = GFP_KERNEL | __GFP_ZERO | gfp_extra_flags;
 	struct bpf_prog *fp;
 
 	fp = __vmalloc(fp_other->pages * PAGE_SIZE, gfp_flags, PAGE_KERNEL);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 7af0dcc5d755..6d3324728738 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -68,8 +68,7 @@ void *bpf_map_area_alloc(size_t size)
 			return area;
 	}
 
-	return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | flags,
-			 PAGE_KERNEL);
+	return __vmalloc(size, GFP_KERNEL | flags, PAGE_KERNEL);
 }
 
 void bpf_map_area_free(void *area)
diff --git a/kernel/fork.c b/kernel/fork.c
index 6c463c80e93d..f7d738bced82 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -202,7 +202,7 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 
 	stack = __vmalloc_node_range(THREAD_SIZE, THREAD_SIZE,
 				     VMALLOC_START, VMALLOC_END,
-				     THREADINFO_GFP | __GFP_HIGHMEM,
+				     THREADINFO_GFP,
 				     PAGE_KERNEL,
 				     0, node, __builtin_return_address(0));
 
diff --git a/kernel/groups.c b/kernel/groups.c
index 8dd7a61b7115..d09727692a2a 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -18,7 +18,7 @@ struct group_info *groups_alloc(int gidsetsize)
 	len = sizeof(struct group_info) + sizeof(kgid_t) * gidsetsize;
 	gi = kmalloc(len, GFP_KERNEL_ACCOUNT|__GFP_NOWARN|__GFP_NORETRY);
 	if (!gi)
-		gi = __vmalloc(len, GFP_KERNEL_ACCOUNT|__GFP_HIGHMEM, PAGE_KERNEL);
+		gi = __vmalloc(len, GFP_KERNEL_ACCOUNT, PAGE_KERNEL);
 	if (!gi)
 		return NULL;
 
diff --git a/kernel/module.c b/kernel/module.c
index 7eba6dea4f41..fa19dea48fc5 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2846,7 +2846,7 @@ static int copy_module_from_user(const void __user *umod, unsigned long len,
 
 	/* Suck in entire file: we'll want most of it. */
 	info->hdr = __vmalloc(info->len,
-			GFP_KERNEL | __GFP_HIGHMEM | __GFP_NOWARN, PAGE_KERNEL);
+			GFP_KERNEL | __GFP_NOWARN, PAGE_KERNEL);
 	if (!info->hdr)
 		return -ENOMEM;
 
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 75d4e8aae286..7a217c2e1088 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -693,7 +693,7 @@ int kasan_module_alloc(void *addr, size_t size)
 
 	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
 			shadow_start + shadow_size,
-			GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
+			GFP_KERNEL | __GFP_ZERO,
 			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
 			__builtin_return_address(0));
 
diff --git a/mm/nommu.c b/mm/nommu.c
index a80411d258fc..fc184f597d59 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -246,8 +246,7 @@ void *vmalloc_user(unsigned long size)
 {
 	void *ret;
 
-	ret = __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
-			PAGE_KERNEL);
+	ret = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	if (ret) {
 		struct vm_area_struct *vma;
 
diff --git a/mm/util.c b/mm/util.c
index 6ed3e49bf1e5..e5b0623df89d 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -382,7 +382,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	if (ret || size <= PAGE_SIZE)
 		return ret;
 
-	return __vmalloc_node_flags(size, node, flags | __GFP_HIGHMEM);
+	return __vmalloc_node_flags(size, node, flags);
 }
 EXPORT_SYMBOL(kvmalloc_node);
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 32979d945766..9fa9274d8f6d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1619,7 +1619,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
-	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
+	const gfp_t alloc_mask = gfp_mask | __GFP_HIGHMEM | __GFP_NOWARN;
 
 	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
@@ -1788,7 +1788,7 @@ void *__vmalloc_node_flags(unsigned long size,
 void *vmalloc(unsigned long size)
 {
 	return __vmalloc_node_flags(size, NUMA_NO_NODE,
-				    GFP_KERNEL | __GFP_HIGHMEM);
+				    GFP_KERNEL);
 }
 EXPORT_SYMBOL(vmalloc);
 
@@ -1805,7 +1805,7 @@ EXPORT_SYMBOL(vmalloc);
 void *vzalloc(unsigned long size)
 {
 	return __vmalloc_node_flags(size, NUMA_NO_NODE,
-				GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
+				GFP_KERNEL | __GFP_ZERO);
 }
 EXPORT_SYMBOL(vzalloc);
 
@@ -1822,7 +1822,7 @@ void *vmalloc_user(unsigned long size)
 	void *ret;
 
 	ret = __vmalloc_node(size, SHMLBA,
-			     GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
+			     GFP_KERNEL | __GFP_ZERO,
 			     PAGE_KERNEL, NUMA_NO_NODE,
 			     __builtin_return_address(0));
 	if (ret) {
@@ -1846,7 +1846,7 @@ EXPORT_SYMBOL(vmalloc_user);
  */
 void *vmalloc_node(unsigned long size, int node)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL,
+	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL,
 					node, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(vmalloc_node);
@@ -1866,7 +1866,7 @@ EXPORT_SYMBOL(vmalloc_node);
 void *vzalloc_node(unsigned long size, int node)
 {
 	return __vmalloc_node_flags(size, node,
-			 GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
+			 GFP_KERNEL | __GFP_ZERO);
 }
 EXPORT_SYMBOL(vzalloc_node);
 
@@ -1888,7 +1888,7 @@ EXPORT_SYMBOL(vzalloc_node);
 
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC,
+	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
 			      NUMA_NO_NODE, __builtin_return_address(0));
 }
 
diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index 464e88599b9d..73d4739fcbe0 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -187,7 +187,7 @@ void *ceph_kvmalloc(size_t size, gfp_t flags)
 			return ptr;
 	}
 
-	return __vmalloc(size, flags | __GFP_HIGHMEM, PAGE_KERNEL);
+	return __vmalloc(size, flags, PAGE_KERNEL);
 }
 
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index d529989f5791..e58ecff638b3 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -998,8 +998,7 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
 	if (sz <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
 		info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
 	if (!info) {
-		info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN |
-				     __GFP_NORETRY | __GFP_HIGHMEM,
+		info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY,
 				 PAGE_KERNEL);
 		if (!info)
 			return NULL;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
