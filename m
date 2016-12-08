Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E407F6B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 05:33:19 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so94432056wjc.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 02:33:19 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id dk11si28657689wjd.116.2016.12.08.02.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 02:33:18 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id a20so2643478wme.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 02:33:18 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm: introduce kv[mz]alloc helpers
Date: Thu,  8 Dec 2016 11:33:00 +0100
Message-Id: <20161208103300.23217-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org

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

Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: dm-devel@redhat.com
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: kvm@vger.kernel.org
Cc: linux-ext4@vger.kernel.org
Cc: linux-f2fs-devel@lists.sourceforge.net
Cc: linux-security-module@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this has been brought up during [1] discussion. I think we are long overdue
with kvmalloc helpers provided by the core mm code. There are so many users
out there. This patch doesn't try to convert all existing users. I have just
tried to identified those who have invented their own helpers. There are many
others who are openconding that. This is something for a coccinelle script to
automate.

While looking into this I have encountered many (as noted in the
changelog) users who are broken. Especially GFP_NOFS users which might
go down the vmalloc path are worrying. Those need to be fixed but that
is out of scope of this patch. I have simply left them in the place. A proper
fix for them is to not use GFP_NOFS and rather move over to a scope gfp_nofs
api [2]. This will take quite some time though.

One thing I haven't considered in this patch - but I can if there is a demand -
is that the current callers of kv[mz]alloc cannot really override GFP_NORETRY
for larger requests. This flag is implicit. I can imagine some users would
rather prefer to retry hard before falling back to vmalloc though. There doesn't
seem to be any such user in the tree right now AFAICS. vhost_kvzalloc
used __GFP_REPEAT but git history doesn't show any sign there would be a strong
reason for that. I might be wrong here. If that is the case then it is not a problem
to do

	/*
	 * Make sure that larger requests are not too disruptive as long as
	 * the caller doesn't insist by giving __GFP_REPEAT. No OOM
	 * killer and no allocation failure warnings as we have a fallback
	 * is done by default.
	 */
	if (size > PAGE_SZE) {
		kmalloc_flags |= __GFP_NOWARN;

		if (!(flags & __GFP_REPEAT))
			flags |= __GFP_NORETRY;
	}

[1] http://lkml.kernel.org/r/1480554981-195198-1-git-send-email-astepanov@cloudlinux.com
[2] http://lkml.kernel.org/r/1461671772-1269-1-git-send-email-mhocko@kernel.org

 arch/x86/kvm/lapic.c                 |  4 ++--
 arch/x86/kvm/page_track.c            |  4 ++--
 arch/x86/kvm/x86.c                   |  4 ++--
 drivers/md/dm-stats.c                |  7 +------
 drivers/vhost/vhost.c                | 15 +++-----------
 fs/ext4/mballoc.c                    |  2 +-
 fs/ext4/super.c                      |  4 ++--
 fs/f2fs/f2fs.h                       | 20 ------------------
 fs/f2fs/file.c                       |  4 ++--
 fs/f2fs/segment.c                    | 14 ++++++-------
 fs/seq_file.c                        | 16 +--------------
 include/linux/kvm_host.h             |  2 --
 include/linux/mm.h                   | 14 +++++++++++++
 include/linux/vmalloc.h              |  1 +
 mm/util.c                            | 40 ++++++++++++++++++++++++++++++++++++
 mm/vmalloc.c                         |  2 +-
 security/apparmor/apparmorfs.c       |  2 +-
 security/apparmor/include/apparmor.h | 10 ---------
 security/apparmor/match.c            |  2 +-
 virt/kvm/kvm_main.c                  | 18 +++-------------
 20 files changed, 84 insertions(+), 101 deletions(-)

diff --git a/arch/x86/kvm/lapic.c b/arch/x86/kvm/lapic.c
index b62c85229711..465e5ff4c304 100644
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
index b431539c3714..dd71626c1335 100644
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
index 699f8726539a..e3ea3fff5470 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7945,13 +7945,13 @@ int kvm_arch_create_memslot(struct kvm *kvm, struct kvm_memory_slot *slot,
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
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c6f2d89c0e97..c6dc9ea7c99e 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -514,18 +514,9 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 }
 EXPORT_SYMBOL_GPL(vhost_dev_set_owner);
 
-static void *vhost_kvzalloc(unsigned long size)
-{
-	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
-
-	if (!n)
-		n = vzalloc(size);
-	return n;
-}
-
 struct vhost_umem *vhost_dev_reset_owner_prepare(void)
 {
-	return vhost_kvzalloc(sizeof(struct vhost_umem));
+	return kvzalloc(sizeof(struct vhost_umem), GFP_KERNEL);
 }
 EXPORT_SYMBOL_GPL(vhost_dev_reset_owner_prepare);
 
@@ -1189,7 +1180,7 @@ EXPORT_SYMBOL_GPL(vhost_vq_access_ok);
 
 static struct vhost_umem *vhost_umem_alloc(void)
 {
-	struct vhost_umem *umem = vhost_kvzalloc(sizeof(*umem));
+	struct vhost_umem *umem = kvzalloc(sizeof(*umem), GFP_KERNEL);
 
 	if (!umem)
 		return NULL;
@@ -1215,7 +1206,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 		return -EOPNOTSUPP;
 	if (mem.nregions > max_mem_regions)
 		return -E2BIG;
-	newmem = vhost_kvzalloc(size + mem.nregions * sizeof(*m->regions));
+	newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);
 	if (!newmem)
 		return -ENOMEM;
 
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index f418f55c2bbe..bc1ef808ba89 100644
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
index 3ec8708989ca..981fd6ff9e47 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -2093,7 +2093,7 @@ int ext4_alloc_flex_bg_array(struct super_block *sb, ext4_group_t ngroup)
 		return 0;
 
 	size = roundup_pow_of_two(size * sizeof(struct flex_groups));
-	new_groups = ext4_kvzalloc(size, GFP_KERNEL);
+	new_groups = kvzalloc(size, GFP_KERNEL);
 	if (!new_groups) {
 		ext4_msg(sb, KERN_ERR, "not enough memory for %d flex groups",
 			 size / (int) sizeof(struct flex_groups));
@@ -3752,7 +3752,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 			(EXT4_MAX_BLOCK_FILE_PHYS / EXT4_BLOCKS_PER_GROUP(sb)));
 	db_count = (sbi->s_groups_count + EXT4_DESC_PER_BLOCK(sb) - 1) /
 		   EXT4_DESC_PER_BLOCK(sb);
-	sbi->s_group_desc = ext4_kvmalloc(db_count *
+	sbi->s_group_desc = kvmalloc(db_count *
 					  sizeof(struct buffer_head *),
 					  GFP_KERNEL);
 	if (sbi->s_group_desc == NULL) {
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 14f5fe2b841e..4e8109bd660c 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1836,26 +1836,6 @@ static inline void *f2fs_kmalloc(size_t size, gfp_t flags)
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
index 28f4f4cbb8d8..1ea6c209fc6f 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -1011,11 +1011,11 @@ static int __exchange_data_block(struct inode *src_inode,
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
index a46296f57b02..f21cbf8ed1f6 100644
--- a/fs/f2fs/segment.c
+++ b/fs/f2fs/segment.c
@@ -2112,13 +2112,13 @@ static int build_sit_info(struct f2fs_sb_info *sbi)
 
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
 
@@ -2140,7 +2140,7 @@ static int build_sit_info(struct f2fs_sb_info *sbi)
 		return -ENOMEM;
 
 	if (sbi->segs_per_sec > 1) {
-		sit_i->sec_entries = f2fs_kvzalloc(MAIN_SECS(sbi) *
+		sit_i->sec_entries = kvzalloc(MAIN_SECS(sbi) *
 					sizeof(struct sec_entry), GFP_KERNEL);
 		if (!sit_i->sec_entries)
 			return -ENOMEM;
@@ -2186,12 +2186,12 @@ static int build_free_segmap(struct f2fs_sb_info *sbi)
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
 
@@ -2337,7 +2337,7 @@ static int init_victim_secmap(struct f2fs_sb_info *sbi)
 	struct dirty_seglist_info *dirty_i = DIRTY_I(sbi);
 	unsigned int bitmap_size = f2fs_bitmap_size(MAIN_SECS(sbi));
 
-	dirty_i->victim_secmap = f2fs_kvzalloc(bitmap_size, GFP_KERNEL);
+	dirty_i->victim_secmap = kvzalloc(bitmap_size, GFP_KERNEL);
 	if (!dirty_i->victim_secmap)
 		return -ENOMEM;
 	return 0;
@@ -2359,7 +2359,7 @@ static int build_dirty_segmap(struct f2fs_sb_info *sbi)
 	bitmap_size = f2fs_bitmap_size(MAIN_SEGS(sbi));
 
 	for (i = 0; i < NR_DIRTY_TYPE; i++) {
-		dirty_i->dirty_segmap[i] = f2fs_kvzalloc(bitmap_size, GFP_KERNEL);
+		dirty_i->dirty_segmap[i] = kvzalloc(bitmap_size, GFP_KERNEL);
 		if (!dirty_i->dirty_segmap[i])
 			return -ENOMEM;
 	}
diff --git a/fs/seq_file.c b/fs/seq_file.c
index 368bfb92b115..023d92dfffa9 100644
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
index 9c28b4d4c90b..793343fc1676 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -757,8 +757,6 @@ void kvm_arch_check_processor_compat(void *rtn);
 int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu);
 int kvm_arch_vcpu_should_kick(struct kvm_vcpu *vcpu);
 
-void *kvm_kvzalloc(unsigned long size);
-
 #ifndef __KVM_HAVE_ARCH_VM_ALLOC
 static inline struct kvm *kvm_arch_alloc_vm(void)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ccbd1274903d..86de65ecd02f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -497,6 +497,20 @@ static inline int is_vmalloc_or_module_addr(const void *x)
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
index 3d9d786a943c..b4f044f7d988 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -80,6 +80,7 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller);
+extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
 
 extern void vfree(const void *addr);
 
diff --git a/mm/util.c b/mm/util.c
index 4c685bde5ebc..57b1d1037a50 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -322,6 +322,46 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_mmap);
 
+/**
+ * kvmalloc_node - allocate contiguous memory from SLAB with vmalloc fallback
+ * @size: size of the request.
+ * @flags: gfp mask for the allocation - must be compatible with GFP_KERNEL.
+ * @node: numa node to allocate from
+ *
+ * Uses kmalloc to get the memory but if the allocation fails then falls back
+ * to the vmalloc allocator. Use kvfree for freeing the memory.
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
+	WARN_ON((flags & GFP_KERNEL) != GFP_KERNEL);
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
+	if (ret || size < PAGE_SIZE)
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
index 719ced371028..46652ed8b159 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1703,7 +1703,7 @@ void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 }
 EXPORT_SYMBOL(__vmalloc);
 
-static inline void *__vmalloc_node_flags(unsigned long size,
+void *__vmalloc_node_flags(unsigned long size,
 					int node, gfp_t flags)
 {
 	return __vmalloc_node(size, 1, flags, PAGE_KERNEL,
diff --git a/security/apparmor/apparmorfs.c b/security/apparmor/apparmorfs.c
index 729e595119ed..93d7293b8cb5 100644
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
index 9cadc637dbcb..34e96d69e32a 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -499,7 +499,7 @@ static struct kvm_memslots *kvm_alloc_memslots(void)
 	int i;
 	struct kvm_memslots *slots;
 
-	slots = kvm_kvzalloc(sizeof(struct kvm_memslots));
+	slots = kvzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);
 	if (!slots)
 		return NULL;
 
@@ -680,18 +680,6 @@ static struct kvm *kvm_create_vm(unsigned long type)
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
@@ -770,7 +758,7 @@ static int kvm_create_dirty_bitmap(struct kvm_memory_slot *memslot)
 {
 	unsigned long dirty_bytes = 2 * kvm_dirty_bitmap_bytes(memslot);
 
-	memslot->dirty_bitmap = kvm_kvzalloc(dirty_bytes);
+	memslot->dirty_bitmap = kvzalloc(dirty_bytes, GFP_KERNEL);
 	if (!memslot->dirty_bitmap)
 		return -ENOMEM;
 
@@ -990,7 +978,7 @@ int __kvm_set_memory_region(struct kvm *kvm,
 			goto out_free;
 	}
 
-	slots = kvm_kvzalloc(sizeof(struct kvm_memslots));
+	slots = kvzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);
 	if (!slots)
 		goto out_free;
 	memcpy(slots, __kvm_memslots(kvm, as_id), sizeof(struct kvm_memslots));
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
