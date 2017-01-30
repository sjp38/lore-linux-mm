Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C86466B0069
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 04:49:57 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jz4so60382395wjb.5
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:49:57 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x4si12681071wmx.113.2017.01.30.01.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 01:49:55 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id r18so4750167wmd.3
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:49:55 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/9] mm: introduce kv[mz]alloc helpers
Date: Mon, 30 Jan 2017 10:49:32 +0100
Message-Id: <20170130094940.13546-2-mhocko@kernel.org>
In-Reply-To: <20170130094940.13546-1-mhocko@kernel.org>
References: <20170130094940.13546-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>

From: Michal Hocko <mhocko@suse.com>

Using kmalloc with the vmalloc fallback for larger allocations is a
common pattern in the kernel code. Yet we do not have any common helper
for that and so users have invented their own helpers. Some of them are
really creative when doing so. Let's just add kv[mz]alloc and make sure
it is implemented properly. This implementation makes sure to not make
a large memory pressure for > PAGE_SZE requests (__GFP_NORETRY) and also
to not warn about allocation failures. This also rules out the OOM
killer as the vmalloc is a more approapriate fallback than a disruptive
user visible action.

This patch also changes some existing users and removes helpers which
are specific for them. In some cases this is not possible (e.g.
ext4_kvmalloc, libcfs_kvzalloc) because those seems to be
broken and require GFP_NO{FS,IO} context which is not vmalloc compatible
in general (note that the page table allocation is GFP_KERNEL). Those
need to be fixed separately.

While we are at it, document that __vmalloc{_node} about unsupported
gfp mask because there seems to be a lot of confusion out there.
kvmalloc_node will warn about GFP_KERNEL incompatible (which are not
superset) flags to catch new abusers. Existing ones would have to die
slowly.

Changes since v3
- add __GFP_HIGHMEM for the vmalloc fallback
- document gfp_mask in __vmalloc_node
- change ipc_alloc to use the library kvmalloc
- __aa_kvmalloc doesn't rely on GFP_NOIO anymore so we can drop and
use the library kvmalloc directly

Changes since v2
- s@WARN_ON@WARN_ON_ONCE@ as per Vlastimil
- do not fallback to vmalloc for size = PAGE_SIZE as per Vlastimil

Changes since v1
- define __vmalloc_node_flags for CONFIG_MMU=n

Cc: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Andreas Dilger <adilger@dilger.ca> # ext4 part
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/kvm/lapic.c              |  4 ++--
 arch/x86/kvm/page_track.c         |  4 ++--
 arch/x86/kvm/x86.c                |  4 ++--
 drivers/md/dm-stats.c             |  7 +-----
 fs/ext4/mballoc.c                 |  2 +-
 fs/ext4/super.c                   |  4 ++--
 fs/f2fs/f2fs.h                    | 20 -----------------
 fs/f2fs/file.c                    |  4 ++--
 fs/f2fs/segment.c                 | 14 ++++++------
 fs/seq_file.c                     | 16 +-------------
 include/linux/kvm_host.h          |  2 --
 include/linux/mm.h                | 14 ++++++++++++
 include/linux/vmalloc.h           |  1 +
 ipc/util.c                        |  7 +-----
 mm/nommu.c                        |  5 +++++
 mm/util.c                         | 45 +++++++++++++++++++++++++++++++++++++++
 mm/vmalloc.c                      |  9 +++++++-
 security/apparmor/apparmorfs.c    |  2 +-
 security/apparmor/include/lib.h   | 11 ----------
 security/apparmor/lib.c           | 30 --------------------------
 security/apparmor/match.c         |  2 +-
 security/apparmor/policy_unpack.c |  2 +-
 virt/kvm/kvm_main.c               | 18 +++-------------
 23 files changed, 100 insertions(+), 127 deletions(-)

diff --git a/arch/x86/kvm/lapic.c b/arch/x86/kvm/lapic.c
index 33b799fd3a6e..42562348bed2 100644
--- a/arch/x86/kvm/lapic.c
+++ b/arch/x86/kvm/lapic.c
@@ -177,8 +177,8 @@ static void recalculate_apic_map(struct kvm *kvm)
 		if (kvm_apic_present(vcpu))
 			max_id = max(max_id, kvm_x2apic_id(vcpu->arch.apic));
 
-	new = kvm_kvzalloc(sizeof(struct kvm_apic_map) +
-	                   sizeof(struct kvm_lapic *) * ((u64)max_id + 1));
+	new = kvzalloc(sizeof(struct kvm_apic_map) +
+	                   sizeof(struct kvm_lapic *) * ((u64)max_id + 1), GFP_KERNEL);
 
 	if (!new)
 		goto out;
diff --git a/arch/x86/kvm/page_track.c b/arch/x86/kvm/page_track.c
index 4a1c13eaa518..d46663e655b0 100644
--- a/arch/x86/kvm/page_track.c
+++ b/arch/x86/kvm/page_track.c
@@ -38,8 +38,8 @@ int kvm_page_track_create_memslot(struct kvm_memory_slot *slot,
 	int  i;
 
 	for (i = 0; i < KVM_PAGE_TRACK_MAX; i++) {
-		slot->arch.gfn_track[i] = kvm_kvzalloc(npages *
-					    sizeof(*slot->arch.gfn_track[i]));
+		slot->arch.gfn_track[i] = kvzalloc(npages *
+					    sizeof(*slot->arch.gfn_track[i]), GFP_KERNEL);
 		if (!slot->arch.gfn_track[i])
 			goto track_free;
 	}
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 313f2cecbc57..07b0d17df9ea 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8121,13 +8121,13 @@ int kvm_arch_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
 				      slot->base_gfn, level) + 1;
 
 		slot->arch.rmap[i] =
-			kvm_kvzalloc(lpages * sizeof(*slot->arch.rmap[i]));
+			kvzalloc(lpages * sizeof(*slot->arch.rmap[i]), GFP_KERNEL);
 		if (!slot->arch.rmap[i])
 			goto out_free;
 		if (i == 0)
 			continue;
 
-		linfo = kvm_kvzalloc(lpages * sizeof(*linfo));
+		linfo = kvzalloc(lpages * sizeof(*linfo), GFP_KERNEL);
 		if (!linfo)
 			goto out_free;
 
diff --git a/drivers/md/dm-stats.c b/drivers/md/dm-stats.c
index 38b05f23b96c..674f9a1686f7 100644
--- a/drivers/md/dm-stats.c
+++ b/drivers/md/dm-stats.c
@@ -146,12 +146,7 @@ static void *dm_kvzalloc(size_t alloc_size, int node)
 	if (!claim_shared_memory(alloc_size))
 		return NULL;
 
-	if (alloc_size <= KMALLOC_MAX_SIZE) {
-		p = kzalloc_node(alloc_size, GFP_KERNEL | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN, node);
-		if (p)
-			return p;
-	}
-	p = vzalloc_node(alloc_size, node);
+	p = kvzalloc_node(alloc_size, GFP_KERNEL | __GFP_NOMEMALLOC, node);
 	if (p)
 		return p;
 
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index d9fd184b049e..31a761dd76f5 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -2381,7 +2381,7 @@ int ext4_mb_alloc_groupinfo(struct super_block *sb, ext4_group_t ngroups)
 		return 0;
 
 	size = roundup_pow_of_two(sizeof(*sbi->s_group_info) * size);
-	new_groupinfo = ext4_kvzalloc(size, GFP_KERNEL);
+	new_groupinfo = kvzalloc(size, GFP_KERNEL);
 	if (!new_groupinfo) {
 		ext4_msg(sb, KERN_ERR, "can't allocate buddy meta group");
 		return -ENOMEM;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 9d15a6293124..e3f1ff04a85f 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -2110,7 +2110,7 @@ int ext4_alloc_flex_bg_array(struct super_block *sb, ext4_group_t ngroup)
 		return 0;
 
 	size = roundup_pow_of_two(size * sizeof(struct flex_groups));
-	new_groups = ext4_kvzalloc(size, GFP_KERNEL);
+	new_groups = kvzalloc(size, GFP_KERNEL);
 	if (!new_groups) {
 		ext4_msg(sb, KERN_ERR, "not enough memory for %d flex groups",
 			 size / (int) sizeof(struct flex_groups));
@@ -3844,7 +3844,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 			goto failed_mount;
 		}
 	}
-	sbi->s_group_desc = ext4_kvmalloc(db_count *
+	sbi->s_group_desc = kvmalloc(db_count *
 					  sizeof(struct buffer_head *),
 					  GFP_KERNEL);
 	if (sbi->s_group_desc == NULL) {
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 4cce13d0a1a4..83dc25025277 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1935,26 +1935,6 @@ static inline void *f2fs_kmalloc(struct f2fs_sb_info *sbi,
 	return kmalloc(size, flags);
 }
 
-static inline void *f2fs_kvmalloc(size_t size, gfp_t flags)
-{
-	void *ret;
-
-	ret = kmalloc(size, flags | __GFP_NOWARN);
-	if (!ret)
-		ret = __vmalloc(size, flags, PAGE_KERNEL);
-	return ret;
-}
-
-static inline void *f2fs_kvzalloc(size_t size, gfp_t flags)
-{
-	void *ret;
-
-	ret = kzalloc(size, flags | __GFP_NOWARN);
-	if (!ret)
-		ret = __vmalloc(size, flags | __GFP_ZERO, PAGE_KERNEL);
-	return ret;
-}
-
 #define get_inode_mode(i) \
 	((is_inode_flag_set(i, FI_ACL_MODE)) ? \
 	 (F2FS_I(i)->i_acl_mode) : ((i)->i_mode))
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 2752bcf98f95..82ca8c038ecf 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -1014,11 +1014,11 @@ static int __exchange_data_block(struct inode *src_inode,
 	while (len) {
 		olen = min((pgoff_t)4 * ADDRS_PER_BLOCK, len);
 
-		src_blkaddr = f2fs_kvzalloc(sizeof(block_t) * olen, GFP_KERNEL);
+		src_blkaddr = kvzalloc(sizeof(block_t) * olen, GFP_KERNEL);
 		if (!src_blkaddr)
 			return -ENOMEM;
 
-		do_replace = f2fs_kvzalloc(sizeof(int) * olen, GFP_KERNEL);
+		do_replace = kvzalloc(sizeof(int) * olen, GFP_KERNEL);
 		if (!do_replace) {
 			kvfree(src_blkaddr);
 			return -ENOMEM;
diff --git a/fs/f2fs/segment.c b/fs/f2fs/segment.c
index fb57ab9f6aa6..127d875a79f7 100644
--- a/fs/f2fs/segment.c
+++ b/fs/f2fs/segment.c
@@ -2351,13 +2351,13 @@ static int build_sit_info(struct f2fs_sb_info *sbi)
 
 	SM_I(sbi)->sit_info = sit_i;
 
-	sit_i->sentries = f2fs_kvzalloc(MAIN_SEGS(sbi) *
+	sit_i->sentries = kvzalloc(MAIN_SEGS(sbi) *
 					sizeof(struct seg_entry), GFP_KERNEL);
 	if (!sit_i->sentries)
 		return -ENOMEM;
 
 	bitmap_size = f2fs_bitmap_size(MAIN_SEGS(sbi));
-	sit_i->dirty_sentries_bitmap = f2fs_kvzalloc(bitmap_size, GFP_KERNEL);
+	sit_i->dirty_sentries_bitmap = kvzalloc(bitmap_size, GFP_KERNEL);
 	if (!sit_i->dirty_sentries_bitmap)
 		return -ENOMEM;
 
@@ -2390,7 +2390,7 @@ static int build_sit_info(struct f2fs_sb_info *sbi)
 		return -ENOMEM;
 
 	if (sbi->segs_per_sec > 1) {
-		sit_i->sec_entries = f2fs_kvzalloc(MAIN_SECS(sbi) *
+		sit_i->sec_entries = kvzalloc(MAIN_SECS(sbi) *
 					sizeof(struct sec_entry), GFP_KERNEL);
 		if (!sit_i->sec_entries)
 			return -ENOMEM;
@@ -2441,12 +2441,12 @@ static int build_free_segmap(struct f2fs_sb_info *sbi)
 	SM_I(sbi)->free_info = free_i;
 
 	bitmap_size = f2fs_bitmap_size(MAIN_SEGS(sbi));
-	free_i->free_segmap = f2fs_kvmalloc(bitmap_size, GFP_KERNEL);
+	free_i->free_segmap = kvmalloc(bitmap_size, GFP_KERNEL);
 	if (!free_i->free_segmap)
 		return -ENOMEM;
 
 	sec_bitmap_size = f2fs_bitmap_size(MAIN_SECS(sbi));
-	free_i->free_secmap = f2fs_kvmalloc(sec_bitmap_size, GFP_KERNEL);
+	free_i->free_secmap = kvmalloc(sec_bitmap_size, GFP_KERNEL);
 	if (!free_i->free_secmap)
 		return -ENOMEM;
 
@@ -2614,7 +2614,7 @@ static int init_victim_secmap(struct f2fs_sb_info *sbi)
 	struct dirty_seglist_info *dirty_i = DIRTY_I(sbi);
 	unsigned int bitmap_size = f2fs_bitmap_size(MAIN_SECS(sbi));
 
-	dirty_i->victim_secmap = f2fs_kvzalloc(bitmap_size, GFP_KERNEL);
+	dirty_i->victim_secmap = kvzalloc(bitmap_size, GFP_KERNEL);
 	if (!dirty_i->victim_secmap)
 		return -ENOMEM;
 	return 0;
@@ -2636,7 +2636,7 @@ static int build_dirty_segmap(struct f2fs_sb_info *sbi)
 	bitmap_size = f2fs_bitmap_size(MAIN_SEGS(sbi));
 
 	for (i = 0; i < NR_DIRTY_TYPE; i++) {
-		dirty_i->dirty_segmap[i] = f2fs_kvzalloc(bitmap_size, GFP_KERNEL);
+		dirty_i->dirty_segmap[i] = kvzalloc(bitmap_size, GFP_KERNEL);
 		if (!dirty_i->dirty_segmap[i])
 			return -ENOMEM;
 	}
diff --git a/fs/seq_file.c b/fs/seq_file.c
index ca69fb99e41a..dc7c2be963ed 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -25,21 +25,7 @@ static void seq_set_overflow(struct seq_file *m)
 
 static void *seq_buf_alloc(unsigned long size)
 {
-	void *buf;
-	gfp_t gfp = GFP_KERNEL;
-
-	/*
-	 * For high order allocations, use __GFP_NORETRY to avoid oom-killing -
-	 * it's better to fall back to vmalloc() than to kill things.  For small
-	 * allocations, just use GFP_KERNEL which will oom kill, thus no need
-	 * for vmalloc fallback.
-	 */
-	if (size > PAGE_SIZE)
-		gfp |= __GFP_NORETRY | __GFP_NOWARN;
-	buf = kmalloc(size, gfp);
-	if (!buf && size > PAGE_SIZE)
-		buf = vmalloc(size);
-	return buf;
+	return kvmalloc(size, GFP_KERNEL);
 }
 
 /**
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 1c5190dab2c1..00e6f93d1ee0 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -768,8 +768,6 @@ void kvm_arch_check_processor_compat(void *rtn);
 int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu);
 int kvm_arch_vcpu_should_kick(struct kvm_vcpu *vcpu);
 
-void *kvm_kvzalloc(unsigned long size);
-
 #ifndef __KVM_HAVE_ARCH_VM_ALLOC
 static inline struct kvm *kvm_arch_alloc_vm(void)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a6b9ab0945c4..0d9fdc0a2a7b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -498,6 +498,20 @@ static inline int is_vmalloc_or_module_addr(const void *x)
 }
 #endif
 
+extern void *kvmalloc_node(size_t size, gfp_t flags, int node);
+static inline void *kvmalloc(size_t size, gfp_t flags)
+{
+	return kvmalloc_node(size, flags, NUMA_NO_NODE);
+}
+static inline void *kvzalloc_node(size_t size, gfp_t flags, int node)
+{
+	return kvmalloc_node(size, flags | __GFP_ZERO, node);
+}
+static inline void *kvzalloc(size_t size, gfp_t flags)
+{
+	return kvmalloc(size, flags | __GFP_ZERO);
+}
+
 extern void kvfree(const void *addr);
 
 static inline atomic_t *compound_mapcount_ptr(struct page *page)
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index d68edffbf142..46991ad3ddd5 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -80,6 +80,7 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller);
+extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
 
 extern void vfree(const void *addr);
 extern void vfree_atomic(const void *addr);
diff --git a/ipc/util.c b/ipc/util.c
index 798cad18dd87..74c2adc62086 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -403,12 +403,7 @@ void ipc_rmid(struct ipc_ids *ids, struct kern_ipc_perm *ipcp)
  */
 void *ipc_alloc(int size)
 {
-	void *out;
-	if (size > PAGE_SIZE)
-		out = vmalloc(size);
-	else
-		out = kmalloc(size, GFP_KERNEL);
-	return out;
+	return kvmalloc(size, GFP_KERNEL);
 }
 
 /**
diff --git a/mm/nommu.c b/mm/nommu.c
index 215c62296028..bee76e6cd4e5 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -236,6 +236,11 @@ void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 }
 EXPORT_SYMBOL(__vmalloc);
 
+void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags)
+{
+	return __vmalloc(size, flags, PAGE_KERNEL);
+}
+
 void *vmalloc_user(unsigned long size)
 {
 	void *ret;
diff --git a/mm/util.c b/mm/util.c
index 3cb2164f4099..ef72e2554edb 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -324,6 +324,51 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_mmap);
 
+/**
+ * kvmalloc_node - attempt to allocate physically contiguous memory, but upon
+ * failure, fall back to non-contiguous (vmalloc) allocation.
+ * @size: size of the request.
+ * @flags: gfp mask for the allocation - must be compatible (superset) with GFP_KERNEL.
+ * @node: numa node to allocate from
+ *
+ * Uses kmalloc to get the memory but if the allocation fails then falls back
+ * to the vmalloc allocator. Use kvfree for freeing the memory.
+ *
+ * Reclaim modifiers - __GFP_NORETRY, __GFP_REPEAT and __GFP_NOFAIL are not supported
+ *
+ * Any use of gfp flags outside of GFP_KERNEL should be consulted with mm people.
+ */
+void *kvmalloc_node(size_t size, gfp_t flags, int node)
+{
+	gfp_t kmalloc_flags = flags;
+	void *ret;
+
+	/*
+	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
+	 * so the given set of flags has to be compatible.
+	 */
+	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
+
+	/*
+	 * Make sure that larger requests are not too disruptive - no OOM
+	 * killer and no allocation failure warnings as we have a fallback
+	 */
+	if (size > PAGE_SIZE)
+		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
+
+	ret = kmalloc_node(size, kmalloc_flags, node);
+
+	/*
+	 * It doesn't really make sense to fallback to vmalloc for sub page
+	 * requests
+	 */
+	if (ret || size <= PAGE_SIZE)
+		return ret;
+
+	return __vmalloc_node_flags(size, node, flags | __GFP_HIGHMEM);
+}
+EXPORT_SYMBOL(kvmalloc_node);
+
 void kvfree(const void *addr)
 {
 	if (is_vmalloc_addr(addr))
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d89034a393f2..6c1aa2c68887 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1741,6 +1741,13 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
  *	Allocate enough pages to cover @size from the page level
  *	allocator with @gfp_mask flags.  Map them into contiguous
  *	kernel virtual space, using a pagetable protection of @prot.
+ *
+ *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_REPEAT
+ *	and __GFP_NOFAIL are not supported
+ *
+ *	Any use of gfp flags outside of GFP_KERNEL should be consulted
+ *	with mm people.
+ *
  */
 static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
@@ -1757,7 +1764,7 @@ void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 }
 EXPORT_SYMBOL(__vmalloc);
 
-static inline void *__vmalloc_node_flags(unsigned long size,
+void *__vmalloc_node_flags(unsigned long size,
 					int node, gfp_t flags)
 {
 	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
diff --git a/security/apparmor/apparmorfs.c b/security/apparmor/apparmorfs.c
index 41073f70eb41..be0b49897a67 100644
--- a/security/apparmor/apparmorfs.c
+++ b/security/apparmor/apparmorfs.c
@@ -98,7 +98,7 @@ static struct aa_loaddata *aa_simple_write_to_buffer(const char __user *userbuf,
 		return ERR_PTR(-ESPIPE);
 
 	/* freed by caller to simple_write_to_buffer */
-	data = kvmalloc(sizeof(*data) + alloc_size);
+	data = kvmalloc(sizeof(*data) + alloc_size, GFP_KERNEL);
 	if (data == NULL)
 		return ERR_PTR(-ENOMEM);
 	kref_init(&data->count);
diff --git a/security/apparmor/include/lib.h b/security/apparmor/include/lib.h
index 65ff492a9807..75733baa6702 100644
--- a/security/apparmor/include/lib.h
+++ b/security/apparmor/include/lib.h
@@ -64,17 +64,6 @@ char *aa_split_fqname(char *args, char **ns_name);
 const char *aa_splitn_fqname(const char *fqname, size_t n, const char **ns_name,
 			     size_t *ns_len);
 void aa_info_message(const char *str);
-void *__aa_kvmalloc(size_t size, gfp_t flags);
-
-static inline void *kvmalloc(size_t size)
-{
-	return __aa_kvmalloc(size, 0);
-}
-
-static inline void *kvzalloc(size_t size)
-{
-	return __aa_kvmalloc(size, __GFP_ZERO);
-}
 
 /**
  * aa_strneq - compare null terminated @str to a non null terminated substring
diff --git a/security/apparmor/lib.c b/security/apparmor/lib.c
index 66475bda6f72..1a13494bc7c7 100644
--- a/security/apparmor/lib.c
+++ b/security/apparmor/lib.c
@@ -129,36 +129,6 @@ void aa_info_message(const char *str)
 }
 
 /**
- * __aa_kvmalloc - do allocation preferring kmalloc but falling back to vmalloc
- * @size: how many bytes of memory are required
- * @flags: the type of memory to allocate (see kmalloc).
- *
- * Return: allocated buffer or NULL if failed
- *
- * It is possible that policy being loaded from the user is larger than
- * what can be allocated by kmalloc, in those cases fall back to vmalloc.
- */
-void *__aa_kvmalloc(size_t size, gfp_t flags)
-{
-	void *buffer = NULL;
-
-	if (size == 0)
-		return NULL;
-
-	/* do not attempt kmalloc if we need more than 16 pages at once */
-	if (size <= (16*PAGE_SIZE))
-		buffer = kmalloc(size, flags | GFP_KERNEL | __GFP_NORETRY |
-				 __GFP_NOWARN);
-	if (!buffer) {
-		if (flags & __GFP_ZERO)
-			buffer = vzalloc(size);
-		else
-			buffer = vmalloc(size);
-	}
-	return buffer;
-}
-
-/**
  * aa_policy_init - initialize a policy structure
  * @policy: policy to initialize  (NOT NULL)
  * @prefix: prefix name if any is required.  (MAYBE NULL)
diff --git a/security/apparmor/match.c b/security/apparmor/match.c
index eb0efef746f5..960c913381e2 100644
--- a/security/apparmor/match.c
+++ b/security/apparmor/match.c
@@ -88,7 +88,7 @@ static struct table_header *unpack_table(char *blob, size_t bsize)
 	if (bsize < tsize)
 		goto out;
 
-	table = kvzalloc(tsize);
+	table = kvzalloc(tsize, GFP_KERNEL);
 	if (table) {
 		table->td_id = th.td_id;
 		table->td_flags = th.td_flags;
diff --git a/security/apparmor/policy_unpack.c b/security/apparmor/policy_unpack.c
index 2e37c9c26bbd..f3422a91353c 100644
--- a/security/apparmor/policy_unpack.c
+++ b/security/apparmor/policy_unpack.c
@@ -487,7 +487,7 @@ static bool unpack_rlimits(struct aa_ext *e, struct aa_profile *profile)
 
 static void *kvmemdup(const void *src, size_t len)
 {
-	void *p = kvmalloc(len);
+	void *p = kvmalloc(len, GFP_KERNEL);
 
 	if (p)
 		memcpy(p, src, len);
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index dcd1c12940e6..795c8269ef63 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -502,7 +502,7 @@ static struct kvm_memslots *kvm_alloc_memslots(void)
 	int i;
 	struct kvm_memslots *slots;
 
-	slots = kvm_kvzalloc(sizeof(struct kvm_memslots));
+	slots = kvzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);
 	if (!slots)
 		return NULL;
 
@@ -685,18 +685,6 @@ static struct kvm *kvm_create_vm(unsigned long type)
 	return ERR_PTR(r);
 }
 
-/*
- * Avoid using vmalloc for a small buffer.
- * Should not be used when the size is statically known.
- */
-void *kvm_kvzalloc(unsigned long size)
-{
-	if (size > PAGE_SIZE)
-		return vzalloc(size);
-	else
-		return kzalloc(size, GFP_KERNEL);
-}
-
 static void kvm_destroy_devices(struct kvm *kvm)
 {
 	struct kvm_device *dev, *tmp;
@@ -775,7 +763,7 @@ static int kvm_create_dirty_bitmap(struct kvm_memory_slot *memslot)
 {
 	unsigned long dirty_bytes = 2 * kvm_dirty_bitmap_bytes(memslot);
 
-	memslot->dirty_bitmap = kvm_kvzalloc(dirty_bytes);
+	memslot->dirty_bitmap = kvzalloc(dirty_bytes, GFP_KERNEL);
 	if (!memslot->dirty_bitmap)
 		return -ENOMEM;
 
@@ -995,7 +983,7 @@ int __kvm_set_memory_region(struct kvm *kvm,
 			goto out_free;
 	}
 
-	slots = kvm_kvzalloc(sizeof(struct kvm_memslots));
+	slots = kvzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);
 	if (!slots)
 		goto out_free;
 	memcpy(slots, __kvm_memslots(kvm, as_id), sizeof(struct kvm_memslots));
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
