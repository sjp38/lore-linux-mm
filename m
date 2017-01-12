Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B34106B025E
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:37:26 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id l2so5400686wml.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:37:26 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v24si7569463wra.157.2017.01.12.07.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 07:37:25 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id r144so4520120wme.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:37:25 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
Date: Thu, 12 Jan 2017 16:37:12 +0100
Message-Id: <20170112153717.28943-2-mhocko@kernel.org>
In-Reply-To: <20170112153717.28943-1-mhocko@kernel.org>
References: <20170112153717.28943-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>

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
ext4_kvmalloc, libcfs_kvzalloc, __aa_kvmalloc) because those seems to be
broken and require GFP_NO{FS,IO} context which is not vmalloc compatible
in general (note that the page table allocation is GFP_KERNEL). Those
need to be fixed separately.

apparmor has already claimed kv[mz]alloc so remove those and use
__aa_kvmalloc instead to prevent from the naming clashes.

Changes since v3
- add ipc_alloc

Changes since v2
- s@WARN_ON@WARN_ON_ONCE@ as per Vlastimil
- do not fallback to vmalloc for size = PAGE_SIZE as per Vlastimil

Changes since v1
- define __vmalloc_node_flags for CONFIG_MMU=n

Cc: Anatoly Stepanov <astepanov@cloudlinux.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Reviewed-by: Andreas Dilger <adilger@dilger.ca> # ext4 part
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/kvm/lapic.c                 |  4 ++--
 arch/x86/kvm/page_track.c            |  4 ++--
 arch/x86/kvm/x86.c                   |  4 ++--
 drivers/md/dm-stats.c                |  7 +-----
 fs/ext4/mballoc.c                    |  2 +-
 fs/ext4/super.c                      |  4 ++--
 fs/f2fs/f2fs.h                       | 20 -----------------
 fs/f2fs/file.c                       |  4 ++--
 fs/f2fs/segment.c                    | 14 ++++++------
 fs/seq_file.c                        | 16 +-------------
 include/linux/kvm_host.h             |  2 --
 include/linux/mm.h                   | 14 ++++++++++++
 include/linux/vmalloc.h              |  1 +
 ipc/util.c                           |  7 +-----
 mm/nommu.c                           |  5 +++++
 mm/util.c                            | 42 ++++++++++++++++++++++++++++++++++++
 mm/vmalloc.c                         |  2 +-
 security/apparmor/apparmorfs.c       |  2 +-
 security/apparmor/include/apparmor.h | 10 ---------
 security/apparmor/match.c            |  2 +-
 virt/kvm/kvm_main.c                  | 18 +++-------------
 21 files changed, 89 insertions(+), 95 deletions(-)

diff --git a/arch/x86/kvm/lapic.c b/arch/x86/kvm/lapic.c
index 5fe290c1b7d8..daf114c3b8ad 100644
--- a/arch/x86/kvm/lapic.c
+++ b/arch/x86/kvm/lapic.c
@@ -167,8 +167,8 @@ static void recalculate_apic_map(struct kvm *kvm)
 		if (kvm_apic_present(vcpu))
 			max_id = max(max_id, kvm_apic_id(vcpu->arch.apic));
 
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
index 51ccfe08e32f..ba55bc338f25 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8082,13 +8082,13 @@ int kvm_arch_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
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
index 66845a08a87a..c65fe19a2a4f 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -2116,7 +2116,7 @@ int ext4_alloc_flex_bg_array(struct super_block *sb, ext4_group_t ngroup)
 		return 0;
 
 	size = roundup_pow_of_two(size * sizeof(struct flex_groups));
-	new_groups = ext4_kvzalloc(size, GFP_KERNEL);
+	new_groups = kvzalloc(size, GFP_KERNEL);
 	if (!new_groups) {
 		ext4_msg(sb, KERN_ERR, "not enough memory for %d flex groups",
 			 size / (int) sizeof(struct flex_groups));
@@ -3850,7 +3850,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 			goto failed_mount;
 		}
 	}
-	sbi->s_group_desc = ext4_kvmalloc(db_count *
+	sbi->s_group_desc = kvmalloc(db_count *
 					  sizeof(struct buffer_head *),
 					  GFP_KERNEL);
 	if (sbi->s_group_desc == NULL) {
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 2da8c3aa0ce5..4130df0a8e64 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1929,26 +1929,6 @@ static inline void *f2fs_kmalloc(struct f2fs_sb_info *sbi,
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
index 49f10dce817d..fb2e0c156135 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -1013,11 +1013,11 @@ static int __exchange_data_block(struct inode *src_inode,
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
index 0738f48293cc..c50c883bfc1a 100644
--- a/fs/f2fs/segment.c
+++ b/fs/f2fs/segment.c
@@ -2286,13 +2286,13 @@ static int build_sit_info(struct f2fs_sb_info *sbi)
 
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
 
@@ -2318,7 +2318,7 @@ static int build_sit_info(struct f2fs_sb_info *sbi)
 		return -ENOMEM;
 
 	if (sbi->segs_per_sec > 1) {
-		sit_i->sec_entries = f2fs_kvzalloc(MAIN_SECS(sbi) *
+		sit_i->sec_entries = kvzalloc(MAIN_SECS(sbi) *
 					sizeof(struct sec_entry), GFP_KERNEL);
 		if (!sit_i->sec_entries)
 			return -ENOMEM;
@@ -2364,12 +2364,12 @@ static int build_free_segmap(struct f2fs_sb_info *sbi)
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
 
@@ -2537,7 +2537,7 @@ static int init_victim_secmap(struct f2fs_sb_info *sbi)
 	struct dirty_seglist_info *dirty_i = DIRTY_I(sbi);
 	unsigned int bitmap_size = f2fs_bitmap_size(MAIN_SECS(sbi));
 
-	dirty_i->victim_secmap = f2fs_kvzalloc(bitmap_size, GFP_KERNEL);
+	dirty_i->victim_secmap = kvzalloc(bitmap_size, GFP_KERNEL);
 	if (!dirty_i->victim_secmap)
 		return -ENOMEM;
 	return 0;
@@ -2559,7 +2559,7 @@ static int build_dirty_segmap(struct f2fs_sb_info *sbi)
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
index fe6b4036664a..55fd570c3e1e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -484,6 +484,20 @@ static inline int is_vmalloc_or_module_addr(const void *x)
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
index 24f9f5f39145..f1927890f75e 100644
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
index 3cb2164f4099..7e0c240b5760 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -324,6 +324,48 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_mmap);
 
+/**
+ * kvmalloc_node - allocate contiguous memory from SLAB with vmalloc fallback
+ * @size: size of the request.
+ * @flags: gfp mask for the allocation - must be compatible (superset) with GFP_KERNEL.
+ * @node: numa node to allocate from
+ *
+ * Uses kmalloc to get the memory but if the allocation fails then falls back
+ * to the vmalloc allocator. Use kvfree for freeing the memory.
+ *
+ * Reclaim modifiers - __GFP_NORETRY, __GFP_REPEAT and __GFP_NOFAIL are not supported
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
+	return __vmalloc_node_flags(size, node, flags);
+}
+EXPORT_SYMBOL(kvmalloc_node);
+
 void kvfree(const void *addr)
 {
 	if (is_vmalloc_addr(addr))
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3ca82d44edd3..1039b1230889 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1757,7 +1757,7 @@ void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 }
 EXPORT_SYMBOL(__vmalloc);
 
-static inline void *__vmalloc_node_flags(unsigned long size,
+void *__vmalloc_node_flags(unsigned long size,
 					int node, gfp_t flags)
 {
 	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
diff --git a/security/apparmor/apparmorfs.c b/security/apparmor/apparmorfs.c
index 5923d5665209..83789a03379f 100644
--- a/security/apparmor/apparmorfs.c
+++ b/security/apparmor/apparmorfs.c
@@ -100,7 +100,7 @@ static char *aa_simple_write_to_buffer(int op, const char __user *userbuf,
 		return ERR_PTR(-EACCES);
 
 	/* freed by caller to simple_write_to_buffer */
-	data = kvmalloc(alloc_size);
+	data = __aa_kvmalloc(alloc_size, 0);
 	if (data == NULL)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/security/apparmor/include/apparmor.h b/security/apparmor/include/apparmor.h
index 5d721e990876..c88fb0ebc756 100644
--- a/security/apparmor/include/apparmor.h
+++ b/security/apparmor/include/apparmor.h
@@ -68,16 +68,6 @@ char *aa_split_fqname(char *args, char **ns_name);
 void aa_info_message(const char *str);
 void *__aa_kvmalloc(size_t size, gfp_t flags);
 
-static inline void *kvmalloc(size_t size)
-{
-	return __aa_kvmalloc(size, 0);
-}
-
-static inline void *kvzalloc(size_t size)
-{
-	return __aa_kvmalloc(size, __GFP_ZERO);
-}
-
 /* returns 0 if kref not incremented */
 static inline int kref_get_not0(struct kref *kref)
 {
diff --git a/security/apparmor/match.c b/security/apparmor/match.c
index 3f900fcca8fb..55f6ae0067a3 100644
--- a/security/apparmor/match.c
+++ b/security/apparmor/match.c
@@ -61,7 +61,7 @@ static struct table_header *unpack_table(char *blob, size_t bsize)
 	if (bsize < tsize)
 		goto out;
 
-	table = kvzalloc(tsize);
+	table = __aa_kvmalloc(tsize, __GFP_ZERO);
 	if (table) {
 		table->td_id = th.td_id;
 		table->td_flags = th.td_flags;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 482612b4e496..dbfe0e79232d 100644
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
