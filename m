Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0509D6B0281
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:33 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id l16-v6so9320504ybe.11
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:33 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 26si1367760qtd.119.2018.04.04.12.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:30 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 71/79] mm: add struct address_space to set_page_dirty()
Date: Wed,  4 Apr 2018 15:18:23 -0400
Message-Id: <20180404191831.5378-34-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For the holy crusade to stop relying on struct page mapping field, add
struct address_space to set_page_dirty() arguments.

<---------------------------------------------------------------------
@@
identifier I1;
type T1;
@@
int
-set_page_dirty(T1 I1)
+set_page_dirty(struct address_space *_mapping, T1 I1)
{...}

@@
type T1;
@@
int
-set_page_dirty(T1)
+set_page_dirty(struct address_space *, T1)
;

@@
identifier I1;
type T1;
@@
int
-set_page_dirty(T1 I1)
+set_page_dirty(struct address_space *, T1)
;

@@
expression E1;
@@
-set_page_dirty(E1)
+set_page_dirty(NULL, E1)
--------------------------------------------------------------------->

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |  2 +-
 drivers/gpu/drm/drm_gem.c                          |  2 +-
 drivers/gpu/drm/i915/i915_gem.c                    |  6 ++---
 drivers/gpu/drm/i915/i915_gem_fence_reg.c          |  2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            |  2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c                |  2 +-
 drivers/gpu/drm/ttm/ttm_tt.c                       |  2 +-
 drivers/infiniband/core/umem_odp.c                 |  2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c            |  2 +-
 drivers/mtd/devices/block2mtd.c                    |  4 +--
 drivers/platform/goldfish/goldfish_pipe.c          |  2 +-
 drivers/sbus/char/oradax.c                         |  2 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  4 +--
 .../interface/vchiq_arm/vchiq_2835_arm.c           |  2 +-
 fs/9p/vfs_addr.c                                   |  2 +-
 fs/afs/write.c                                     |  2 +-
 fs/btrfs/extent_io.c                               |  2 +-
 fs/btrfs/file.c                                    |  2 +-
 fs/btrfs/inode.c                                   |  6 ++---
 fs/btrfs/ioctl.c                                   |  2 +-
 fs/btrfs/relocation.c                              |  2 +-
 fs/buffer.c                                        |  6 ++---
 fs/ceph/addr.c                                     |  4 +--
 fs/cifs/file.c                                     |  4 +--
 fs/exofs/dir.c                                     |  2 +-
 fs/exofs/inode.c                                   |  4 +--
 fs/f2fs/checkpoint.c                               |  4 +--
 fs/f2fs/data.c                                     |  6 ++---
 fs/f2fs/dir.c                                      | 10 ++++----
 fs/f2fs/file.c                                     | 10 ++++----
 fs/f2fs/gc.c                                       |  6 ++---
 fs/f2fs/inline.c                                   | 18 ++++++-------
 fs/f2fs/inode.c                                    |  6 ++---
 fs/f2fs/node.c                                     | 20 +++++++--------
 fs/f2fs/node.h                                     |  2 +-
 fs/f2fs/recovery.c                                 |  2 +-
 fs/f2fs/segment.c                                  | 12 ++++-----
 fs/f2fs/xattr.c                                    |  6 ++---
 fs/fuse/file.c                                     |  2 +-
 fs/gfs2/file.c                                     |  2 +-
 fs/hfs/bnode.c                                     | 12 ++++-----
 fs/hfs/btree.c                                     |  6 ++---
 fs/hfsplus/bitmap.c                                |  8 +++---
 fs/hfsplus/bnode.c                                 | 30 +++++++++++-----------
 fs/hfsplus/btree.c                                 |  6 ++---
 fs/hfsplus/xattr.c                                 |  2 +-
 fs/iomap.c                                         |  2 +-
 fs/jfs/jfs_metapage.c                              |  4 +--
 fs/libfs.c                                         |  2 +-
 fs/nfs/direct.c                                    |  2 +-
 fs/ntfs/attrib.c                                   |  8 +++---
 fs/ntfs/bitmap.c                                   |  4 +--
 fs/ntfs/file.c                                     |  2 +-
 fs/ntfs/lcnalloc.c                                 |  4 +--
 fs/ntfs/mft.c                                      |  4 +--
 fs/ntfs/usnjrnl.c                                  |  2 +-
 fs/udf/file.c                                      |  2 +-
 fs/ufs/inode.c                                     |  2 +-
 include/linux/mm.h                                 |  2 +-
 mm/filemap.c                                       |  2 +-
 mm/gup.c                                           |  2 +-
 mm/huge_memory.c                                   |  2 +-
 mm/hugetlb.c                                       |  2 +-
 mm/khugepaged.c                                    |  2 +-
 mm/ksm.c                                           |  2 +-
 mm/memory.c                                        |  4 +--
 mm/page-writeback.c                                |  6 ++---
 mm/page_io.c                                       |  6 ++---
 mm/rmap.c                                          |  2 +-
 mm/shmem.c                                         | 18 ++++++-------
 mm/swap_state.c                                    |  2 +-
 mm/truncate.c                                      |  2 +-
 net/rds/ib_rdma.c                                  |  2 +-
 net/rds/rdma.c                                     |  4 +--
 75 files changed, 172 insertions(+), 172 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index e4bb435e614b..9602a7dfbc7b 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -769,7 +769,7 @@ void amdgpu_ttm_tt_mark_user_pages(struct ttm_tt *ttm)
 			continue;
 
 		if (!(gtt->userflags & AMDGPU_GEM_USERPTR_READONLY))
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 
 		mark_page_accessed(page);
 	}
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 01f8d9481211..b0ef6cd6ce7a 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -607,7 +607,7 @@ void drm_gem_put_pages(struct drm_gem_object *obj, struct page **pages,
 
 	for (i = 0; i < npages; i++) {
 		if (dirty)
-			set_page_dirty(pages[i]);
+			set_page_dirty(NULL, pages[i]);
 
 		if (accessed)
 			mark_page_accessed(pages[i]);
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 6ff5d655c202..4ad397254c42 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -288,7 +288,7 @@ i915_gem_object_put_pages_phys(struct drm_i915_gem_object *obj,
 			memcpy(dst, vaddr, PAGE_SIZE);
 			kunmap_atomic(dst);
 
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			if (obj->mm.madv == I915_MADV_WILLNEED)
 				mark_page_accessed(page);
 			put_page(page);
@@ -2279,7 +2279,7 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 
 	for_each_sgt_page(page, sgt_iter, pages) {
 		if (obj->mm.dirty)
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 
 		if (obj->mm.madv == I915_MADV_WILLNEED)
 			mark_page_accessed(page);
@@ -5788,7 +5788,7 @@ i915_gem_object_get_dirty_page(struct drm_i915_gem_object *obj,
 
 	page = i915_gem_object_get_page(obj, n);
 	if (!obj->mm.dirty)
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 
 	return page;
 }
diff --git a/drivers/gpu/drm/i915/i915_gem_fence_reg.c b/drivers/gpu/drm/i915/i915_gem_fence_reg.c
index 012250f25255..e9a75a3d588c 100644
--- a/drivers/gpu/drm/i915/i915_gem_fence_reg.c
+++ b/drivers/gpu/drm/i915/i915_gem_fence_reg.c
@@ -760,7 +760,7 @@ i915_gem_object_do_bit_17_swizzle(struct drm_i915_gem_object *obj,
 		char new_bit_17 = page_to_phys(page) >> 17;
 		if ((new_bit_17 & 0x1) != (test_bit(i, obj->bit_17) != 0)) {
 			i915_gem_swizzle_page(page);
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 		}
 		i++;
 	}
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 382a77a1097e..9d29b00055d7 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -685,7 +685,7 @@ i915_gem_userptr_put_pages(struct drm_i915_gem_object *obj,
 
 	for_each_sgt_page(page, sgt_iter, pages) {
 		if (obj->mm.dirty)
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 
 		mark_page_accessed(page);
 		put_page(page);
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index a0a839bc39bf..a7f156941448 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -621,7 +621,7 @@ static void radeon_ttm_tt_unpin_userptr(struct ttm_tt *ttm)
 	for_each_sg_page(ttm->sg->sgl, &sg_iter, ttm->sg->nents, 0) {
 		struct page *page = sg_page_iter_page(&sg_iter);
 		if (!(gtt->userflags & RADEON_GEM_USERPTR_READONLY))
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 
 		mark_page_accessed(page);
 		put_page(page);
diff --git a/drivers/gpu/drm/ttm/ttm_tt.c b/drivers/gpu/drm/ttm/ttm_tt.c
index 5a046a3c543a..3138fc73c06d 100644
--- a/drivers/gpu/drm/ttm/ttm_tt.c
+++ b/drivers/gpu/drm/ttm/ttm_tt.c
@@ -359,7 +359,7 @@ int ttm_tt_swapout(struct ttm_tt *ttm, struct file *persistent_swap_storage)
 			goto out_err;
 		}
 		copy_highpage(to_page, from_page);
-		set_page_dirty(to_page);
+		set_page_dirty(NULL, to_page);
 		mark_page_accessed(to_page);
 		put_page(to_page);
 	}
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 2aadf5813a40..6a8077cbfc61 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -774,7 +774,7 @@ void ib_umem_odp_unmap_dma_pages(struct ib_umem *umem, u64 virt,
 				 * continuing and allowing the page mapping to
 				 * be removed.
 				 */
-				set_page_dirty(head_page);
+				set_page_dirty(NULL, head_page);
 			}
 			/* on demand pinning support */
 			if (!umem->context->invalidate_range)
diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index 0339538c182d..4b1374ae5375 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -643,7 +643,7 @@ static void qp_release_pages(struct page **pages,
 
 	for (i = 0; i < num_pages; i++) {
 		if (dirty)
-			set_page_dirty(pages[i]);
+			set_page_dirty(NULL, pages[i]);
 
 		put_page(pages[i]);
 		pages[i] = NULL;
diff --git a/drivers/mtd/devices/block2mtd.c b/drivers/mtd/devices/block2mtd.c
index 62fd6905c648..1581a00cf770 100644
--- a/drivers/mtd/devices/block2mtd.c
+++ b/drivers/mtd/devices/block2mtd.c
@@ -69,7 +69,7 @@ static int _block2mtd_erase(struct block2mtd_dev *dev, loff_t to, size_t len)
 			if (*p != -1UL) {
 				lock_page(page);
 				memset(page_address(page), 0xff, PAGE_SIZE);
-				set_page_dirty(page);
+				set_page_dirty(NULL, page);
 				unlock_page(page);
 				balance_dirty_pages_ratelimited(mapping);
 				break;
@@ -160,7 +160,7 @@ static int _block2mtd_write(struct block2mtd_dev *dev, const u_char *buf,
 		if (memcmp(page_address(page)+offset, buf, cpylen)) {
 			lock_page(page);
 			memcpy(page_address(page) + offset, buf, cpylen);
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			unlock_page(page);
 			balance_dirty_pages_ratelimited(mapping);
 		}
diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index 3e32a4c14d5f..91b9a2045697 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -338,7 +338,7 @@ static void release_user_pages(struct page **pages, int pages_count,
 
 	for (i = 0; i < pages_count; i++) {
 		if (!is_write && consumed_size > 0)
-			set_page_dirty(pages[i]);
+			set_page_dirty(NULL, pages[i]);
 		put_page(pages[i]);
 	}
 }
diff --git a/drivers/sbus/char/oradax.c b/drivers/sbus/char/oradax.c
index 03dc04739225..43798fa51061 100644
--- a/drivers/sbus/char/oradax.c
+++ b/drivers/sbus/char/oradax.c
@@ -423,7 +423,7 @@ static void dax_unlock_pages(struct dax_ctx *ctx, int ccb_index, int nelem)
 			if (p) {
 				dax_dbg("freeing page %p", p);
 				if (j == OUT)
-					set_page_dirty(p);
+					set_page_dirty(NULL, p);
 				put_page(p);
 				ctx->pages[i][j] = NULL;
 			}
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 366ba0afbd0e..969f4dad2f82 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -237,7 +237,7 @@ ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 			 * cl_io_submit()->...->vvp_page_prep_write().
 			 */
 			if (rw == WRITE)
-				set_page_dirty(vmpage);
+				set_page_dirty(NULL, vmpage);
 
 			if (rw == READ) {
 				/* do not issue the page for read, since it
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index aaa06ba38b4c..301fd4d10499 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -797,7 +797,7 @@ static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
 	struct page *vmpage = page->cp_vmpage;
 
 	SetPageUptodate(vmpage);
-	set_page_dirty(vmpage);
+	set_page_dirty(NULL, vmpage);
 
 	cl_page_disown(env, io, page);
 
@@ -1055,7 +1055,7 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
 				    struct cl_page *page)
 {
-	set_page_dirty(page->cp_vmpage);
+	set_page_dirty(NULL, page->cp_vmpage);
 }
 
 static int vvp_io_fault_start(const struct lu_env *env,
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
index b59ef14890aa..1846ae06ce50 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
@@ -636,7 +636,7 @@ free_pagelist(struct vchiq_pagelist_info *pagelistinfo,
 		unsigned int i;
 
 		for (i = 0; i < num_pages; i++)
-			set_page_dirty(pages[i]);
+			set_page_dirty(NULL, pages[i]);
 	}
 
 	cleanup_pagelistinfo(pagelistinfo);
diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 1f4d49e7f811..835bd52f6215 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -342,7 +342,7 @@ static int v9fs_write_end(struct file *filp, struct address_space *mapping,
 		inode_add_bytes(inode, last_pos - inode->i_size);
 		i_size_write(inode, last_pos);
 	}
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 out:
 	unlock_page(page);
 	put_page(page);
diff --git a/fs/afs/write.c b/fs/afs/write.c
index 9c5bdad0bd72..20d5a3388012 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -203,7 +203,7 @@ int afs_write_end(struct file *file, struct address_space *mapping,
 		SetPageUptodate(page);
 	}
 
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	if (PageDirty(page))
 		_debug("dirtied");
 	ret = copied;
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 3c145b353873..5b12578ca5fb 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -5198,7 +5198,7 @@ int set_extent_buffer_dirty(struct extent_buffer *eb)
 	WARN_ON(!test_bit(EXTENT_BUFFER_TREE_REF, &eb->bflags));
 
 	for (i = 0; i < num_pages; i++)
-		set_page_dirty(eb->pages[i]);
+		set_page_dirty(NULL, eb->pages[i]);
 	return was_dirty;
 }
 
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 989735cd751c..2630be84bdca 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -574,7 +574,7 @@ int btrfs_dirty_pages(struct inode *inode, struct page **pages,
 		struct page *p = pages[i];
 		SetPageUptodate(p);
 		ClearPageChecked(p);
-		set_page_dirty(p);
+		set_page_dirty(NULL, p);
 	}
 
 	/*
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 968640312537..e6fdd6095579 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -2134,7 +2134,7 @@ static void btrfs_writepage_fixup_worker(struct btrfs_work *work)
 	}
 
 	ClearPageChecked(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	btrfs_delalloc_release_extents(BTRFS_I(inode), PAGE_SIZE);
 out:
 	unlock_extent_cached(&BTRFS_I(inode)->io_tree, page_start, page_end,
@@ -4869,7 +4869,7 @@ int btrfs_truncate_block(struct inode *inode, loff_t from, loff_t len,
 		kunmap(page);
 	}
 	ClearPageChecked(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	unlock_extent_cached(io_tree, block_start, block_end, &cached_state);
 
 out_unlock:
@@ -9090,7 +9090,7 @@ int btrfs_page_mkwrite(struct vm_fault *vmf)
 		kunmap(page);
 	}
 	ClearPageChecked(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	SetPageUptodate(page);
 
 	BTRFS_I(inode)->last_trans = fs_info->generation;
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index c57e9ce8204d..3ec8d50799ff 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -1211,7 +1211,7 @@ static int cluster_pages_for_defrag(struct inode *inode,
 		clear_page_dirty_for_io(pages[i]);
 		ClearPageChecked(pages[i]);
 		set_page_extent_mapped(pages[i]);
-		set_page_dirty(pages[i]);
+		set_page_dirty(NULL, pages[i]);
 		unlock_page(pages[i]);
 		put_page(pages[i]);
 	}
diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
index 6a530c59b519..454c1dd523ea 100644
--- a/fs/btrfs/relocation.c
+++ b/fs/btrfs/relocation.c
@@ -3284,7 +3284,7 @@ static int relocate_file_extent_cluster(struct inode *inode,
 			goto out;
 
 		}
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 
 		unlock_extent(&BTRFS_I(inode)->io_tree,
 			      page_start, page_end);
diff --git a/fs/buffer.c b/fs/buffer.c
index 24872b077269..343b8b3837e7 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2517,7 +2517,7 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	if (unlikely(ret < 0))
 		goto out_unlock;
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	wait_for_stable_page(page);
 	return 0;
 out_unlock:
@@ -2724,7 +2724,7 @@ int nobh_write_end(struct file *file, struct address_space *mapping,
 					copied, page, fsdata);
 
 	SetPageUptodate(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	if (pos+copied > inode->i_size) {
 		i_size_write(inode, pos+copied);
 		mark_inode_dirty(inode);
@@ -2861,7 +2861,7 @@ int nobh_truncate_page(struct address_space *mapping,
 			goto has_buffers;
 	}
 	zero_user(page, offset, length);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	err = 0;
 
 unlock:
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index c274d8a32479..8497c198e76e 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1382,7 +1382,7 @@ static int ceph_write_end(struct file *file, struct address_space *mapping,
 	if (pos+copied > i_size_read(inode))
 		check_cap = ceph_inode_set_size(inode, pos+copied);
 
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 out:
 	unlock_page(page);
@@ -1595,7 +1595,7 @@ static int ceph_page_mkwrite(struct vm_fault *vmf)
 		ret = ceph_update_writeable_page(vma->vm_file, off, len, page);
 		if (ret >= 0) {
 			/* success.  we'll keep the page locked. */
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			ret = VM_FAULT_LOCKED;
 		}
 	} while (ret == -EAGAIN);
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 017fe16ae993..d460feb43595 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -2297,7 +2297,7 @@ static int cifs_write_end(struct file *file, struct address_space *mapping,
 	} else {
 		rc = copied;
 		pos += copied;
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 	}
 
 	if (rc > 0) {
@@ -3220,7 +3220,7 @@ collect_uncached_read_data(struct cifs_aio_ctx *ctx)
 
 	for (i = 0; i < ctx->npages; i++) {
 		if (ctx->should_dirty)
-			set_page_dirty(ctx->bv[i].bv_page);
+			set_page_dirty(NULL, ctx->bv[i].bv_page);
 		put_page(ctx->bv[i].bv_page);
 	}
 
diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index f0138674c1ed..e07ec3f0dfc3 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -70,7 +70,7 @@ static int exofs_commit_chunk(struct page *page, loff_t pos, unsigned len)
 		i_size_write(dir, pos+len);
 		mark_inode_dirty(dir);
 	}
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 	if (IS_DIRSYNC(dir))
 		err = write_one_page(page);
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 54d6b7dbd4e7..137f1d8c13e8 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -832,7 +832,7 @@ static int exofs_writepages(struct address_space *mapping,
 			struct page *page = pcol.pages[i];
 
 			end_page_writeback(page);
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			unlock_page(page);
 		}
 	}
@@ -931,7 +931,7 @@ static int exofs_write_end(struct file *file, struct address_space *mapping,
 		i_size_write(inode, last_pos);
 		mark_inode_dirty(inode);
 	}
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 out:
 	unlock_page(page);
 	put_page(page);
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index b218fcacd395..d859c5682a1e 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -708,7 +708,7 @@ static void write_orphan_inodes(struct f2fs_sb_info *sbi, block_t start_blk)
 			orphan_blk->blk_addr = cpu_to_le16(index);
 			orphan_blk->blk_count = cpu_to_le16(orphan_blocks);
 			orphan_blk->entry_count = cpu_to_le32(nentries);
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			f2fs_put_page(page, 1);
 			index++;
 			nentries = 0;
@@ -720,7 +720,7 @@ static void write_orphan_inodes(struct f2fs_sb_info *sbi, block_t start_blk)
 		orphan_blk->blk_addr = cpu_to_le16(index);
 		orphan_blk->blk_count = cpu_to_le16(orphan_blocks);
 		orphan_blk->entry_count = cpu_to_le32(nentries);
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		f2fs_put_page(page, 1);
 	}
 }
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index c1a8dd623444..4e6894169d0e 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -540,7 +540,7 @@ void set_data_blkaddr(struct dnode_of_data *dn)
 {
 	f2fs_wait_on_page_writeback(dn->node_page, NODE, true);
 	__set_data_blkaddr(dn);
-	if (set_page_dirty(dn->node_page))
+	if (set_page_dirty(NULL, dn->node_page))
 		dn->node_changed = true;
 }
 
@@ -580,7 +580,7 @@ int reserve_new_blocks(struct dnode_of_data *dn, blkcnt_t count)
 		}
 	}
 
-	if (set_page_dirty(dn->node_page))
+	if (set_page_dirty(NULL, dn->node_page))
 		dn->node_changed = true;
 	return 0;
 }
@@ -2261,7 +2261,7 @@ static int f2fs_write_end(struct file *file,
 	if (!copied)
 		goto unlock_out;
 
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 	if (pos + copied > i_size_read(inode))
 		f2fs_i_size_write(inode, pos + copied);
diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index f00b5ed8c011..a6d560f57933 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -303,7 +303,7 @@ void f2fs_set_link(struct inode *dir, struct f2fs_dir_entry *de,
 	de->ino = cpu_to_le32(inode->i_ino);
 	set_de_type(de, inode->i_mode);
 	f2fs_dentry_kunmap(dir, page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 	dir->i_mtime = dir->i_ctime = current_time(dir);
 	f2fs_mark_inode_dirty_sync(dir, false);
@@ -320,7 +320,7 @@ static void init_dent_inode(const struct qstr *name, struct page *ipage)
 	ri = F2FS_INODE(ipage);
 	ri->i_namelen = cpu_to_le32(name->len);
 	memcpy(ri->i_name, name->name, name->len);
-	set_page_dirty(ipage);
+	set_page_dirty(NULL, ipage);
 }
 
 void do_make_empty_dir(struct inode *inode, struct inode *parent,
@@ -357,7 +357,7 @@ static int make_empty_dir(struct inode *inode,
 
 	kunmap_atomic(dentry_blk);
 
-	set_page_dirty(dentry_page);
+	set_page_dirty(NULL, dentry_page);
 	f2fs_put_page(dentry_page, 1);
 	return 0;
 }
@@ -576,7 +576,7 @@ int f2fs_add_regular_entry(struct inode *dir, const struct qstr *new_name,
 	make_dentry_ptr_block(NULL, &d, dentry_blk);
 	f2fs_update_dentry(ino, mode, &d, new_name, dentry_hash, bit_pos);
 
-	set_page_dirty(dentry_page);
+	set_page_dirty(NULL, dentry_page);
 
 	if (inode) {
 		f2fs_i_pino_write(inode, dir->i_ino);
@@ -731,7 +731,7 @@ void f2fs_delete_entry(struct f2fs_dir_entry *dentry, struct page *page,
 			NR_DENTRY_IN_BLOCK,
 			0);
 	kunmap(page); /* kunmap - pair of f2fs_find_entry */
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 	dir->i_ctime = dir->i_mtime = current_time(dir);
 	f2fs_mark_inode_dirty_sync(dir, false);
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 5e9ac31240bb..d4f253a4cb3c 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -99,7 +99,7 @@ static int f2fs_vm_page_mkwrite(struct vm_fault *vmf)
 		offset = i_size_read(inode) & ~PAGE_MASK;
 		zero_user_segment(page, offset, PAGE_SIZE);
 	}
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	if (!PageUptodate(page))
 		SetPageUptodate(page);
 
@@ -561,7 +561,7 @@ static int truncate_partial_data_page(struct inode *inode, u64 from,
 	/* An encrypted inode should have a key and truncate the last page. */
 	f2fs_bug_on(F2FS_I_SB(inode), cache_only && f2fs_encrypted_inode(inode));
 	if (!cache_only)
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 	f2fs_put_page(page, 1);
 	return 0;
 }
@@ -855,7 +855,7 @@ static int fill_zero(struct inode *inode, pgoff_t index,
 
 	f2fs_wait_on_page_writeback(page, DATA, true);
 	zero_user(page, start, len);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	f2fs_put_page(page, 1);
 	return 0;
 }
@@ -1084,7 +1084,7 @@ static int __clone_blkaddrs(struct inode *src_inode, struct inode *dst_inode,
 				return PTR_ERR(pdst);
 			}
 			f2fs_copy_page(psrc, pdst);
-			set_page_dirty(pdst);
+			set_page_dirty(NULL, pdst);
 			f2fs_put_page(pdst, 1);
 			f2fs_put_page(psrc, 1);
 
@@ -2205,7 +2205,7 @@ static int f2fs_defragment_range(struct f2fs_sb_info *sbi,
 				goto clear_out;
 			}
 
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			f2fs_put_page(page, 1);
 
 			idx++;
diff --git a/fs/f2fs/gc.c b/fs/f2fs/gc.c
index aa720cc44509..86e387af01ac 100644
--- a/fs/f2fs/gc.c
+++ b/fs/f2fs/gc.c
@@ -678,7 +678,7 @@ static void move_data_block(struct inode *inode, block_t bidx,
 		goto put_page_out;
 	}
 
-	set_page_dirty(fio.encrypted_page);
+	set_page_dirty(NULL, fio.encrypted_page);
 	f2fs_wait_on_page_writeback(fio.encrypted_page, DATA, true);
 	if (clear_page_dirty_for_io(fio.encrypted_page))
 		dec_page_count(fio.sbi, F2FS_DIRTY_META);
@@ -739,7 +739,7 @@ static void move_data_page(struct inode *inode, block_t bidx, int gc_type,
 	if (gc_type == BG_GC) {
 		if (PageWriteback(page))
 			goto out;
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		set_cold_data(page);
 	} else {
 		struct f2fs_io_info fio = {
@@ -759,7 +759,7 @@ static void move_data_page(struct inode *inode, block_t bidx, int gc_type,
 		int err;
 
 retry:
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		f2fs_wait_on_page_writeback(page, DATA, true);
 		if (clear_page_dirty_for_io(page)) {
 			inode_dec_dirty_pages(inode);
diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
index 90e38d8ea688..b25425068168 100644
--- a/fs/f2fs/inline.c
+++ b/fs/f2fs/inline.c
@@ -75,7 +75,7 @@ void truncate_inline_inode(struct inode *inode, struct page *ipage, u64 from)
 
 	f2fs_wait_on_page_writeback(ipage, NODE, true);
 	memset(addr + from, 0, MAX_INLINE_DATA(inode) - from);
-	set_page_dirty(ipage);
+	set_page_dirty(NULL, ipage);
 
 	if (from == 0)
 		clear_inode_flag(inode, FI_DATA_EXIST);
@@ -132,7 +132,7 @@ int f2fs_convert_inline_page(struct dnode_of_data *dn, struct page *page)
 	f2fs_bug_on(F2FS_P_SB(page), PageWriteback(page));
 
 	read_inline_data(page, dn->inode_page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 	/* clear dirty state */
 	dirty = clear_page_dirty_for_io(page);
@@ -224,7 +224,7 @@ int f2fs_write_inline_data(struct inode *inode, struct page *page)
 	dst_addr = inline_data_addr(inode, dn.inode_page);
 	memcpy(dst_addr, src_addr, MAX_INLINE_DATA(inode));
 	kunmap_atomic(src_addr);
-	set_page_dirty(dn.inode_page);
+	set_page_dirty(NULL, dn.inode_page);
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	radix_tree_tag_clear(&mapping->page_tree, page_index(page),
@@ -272,7 +272,7 @@ bool recover_inline_data(struct inode *inode, struct page *npage)
 		set_inode_flag(inode, FI_INLINE_DATA);
 		set_inode_flag(inode, FI_DATA_EXIST);
 
-		set_page_dirty(ipage);
+		set_page_dirty(NULL, ipage);
 		f2fs_put_page(ipage, 1);
 		return true;
 	}
@@ -334,7 +334,7 @@ int make_empty_inline_dir(struct inode *inode, struct inode *parent,
 	make_dentry_ptr_inline(inode, &d, inline_dentry);
 	do_make_empty_dir(inode, parent, &d);
 
-	set_page_dirty(ipage);
+	set_page_dirty(NULL, ipage);
 
 	/* update i_size to MAX_INLINE_DATA */
 	if (i_size_read(inode) < MAX_INLINE_DATA(inode))
@@ -389,7 +389,7 @@ static int f2fs_move_inline_dirents(struct inode *dir, struct page *ipage,
 	kunmap_atomic(dentry_blk);
 	if (!PageUptodate(page))
 		SetPageUptodate(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 	/* clear inline dir and flag after data writeback */
 	truncate_inline_inode(dir, ipage, 0);
@@ -485,7 +485,7 @@ static int f2fs_move_rehashed_dirents(struct inode *dir, struct page *ipage,
 	memcpy(inline_dentry, backup_dentry, MAX_INLINE_DATA(dir));
 	f2fs_i_depth_write(dir, 0);
 	f2fs_i_size_write(dir, MAX_INLINE_DATA(dir));
-	set_page_dirty(ipage);
+	set_page_dirty(NULL, ipage);
 	f2fs_put_page(ipage, 1);
 
 	kfree(backup_dentry);
@@ -546,7 +546,7 @@ int f2fs_add_inline_entry(struct inode *dir, const struct qstr *new_name,
 	name_hash = f2fs_dentry_hash(new_name, NULL);
 	f2fs_update_dentry(ino, mode, &d, new_name, name_hash, bit_pos);
 
-	set_page_dirty(ipage);
+	set_page_dirty(NULL, ipage);
 
 	/* we don't need to mark_inode_dirty now */
 	if (inode) {
@@ -582,7 +582,7 @@ void f2fs_delete_inline_entry(struct f2fs_dir_entry *dentry, struct page *page,
 	for (i = 0; i < slots; i++)
 		__clear_bit_le(bit_pos + i, d.bitmap);
 
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	f2fs_put_page(page, 1);
 
 	dir->i_ctime = dir->i_mtime = current_time(dir);
diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
index 205add3d0f3a..920de42398f9 100644
--- a/fs/f2fs/inode.c
+++ b/fs/f2fs/inode.c
@@ -107,7 +107,7 @@ static void __recover_inline_status(struct inode *inode, struct page *ipage)
 
 			set_inode_flag(inode, FI_DATA_EXIST);
 			set_raw_inline(inode, F2FS_INODE(ipage));
-			set_page_dirty(ipage);
+			set_page_dirty(NULL, ipage);
 			return;
 		}
 	}
@@ -231,7 +231,7 @@ static int do_read_inode(struct inode *inode)
 	fi->i_dir_level = ri->i_dir_level;
 
 	if (f2fs_init_extent_tree(inode, &ri->i_ext))
-		set_page_dirty(node_page);
+		set_page_dirty(NULL, node_page);
 
 	get_inline_info(inode, ri);
 
@@ -375,7 +375,7 @@ void update_inode(struct inode *inode, struct page *node_page)
 	struct extent_tree *et = F2FS_I(inode)->extent_tree;
 
 	f2fs_wait_on_page_writeback(node_page, NODE, true);
-	set_page_dirty(node_page);
+	set_page_dirty(NULL, node_page);
 
 	f2fs_inode_synced(inode);
 
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 67737885cad5..e4e5798e9271 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -130,7 +130,7 @@ static struct page *get_next_nat_page(struct f2fs_sb_info *sbi, nid_t nid)
 	src_addr = page_address(src_page);
 	dst_addr = page_address(dst_page);
 	memcpy(dst_addr, src_addr, PAGE_SIZE);
-	set_page_dirty(dst_page);
+	set_page_dirty(NULL, dst_page);
 	f2fs_put_page(src_page, 1);
 
 	set_to_next_nat(nm_i, nid);
@@ -966,7 +966,7 @@ int truncate_inode_blocks(struct inode *inode, pgoff_t from)
 			BUG_ON(page->mapping != NODE_MAPPING(sbi));
 			f2fs_wait_on_page_writeback(page, NODE, true);
 			ri->i_nid[offset[0] - NODE_DIR1_BLOCK] = 0;
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			unlock_page(page);
 		}
 		offset[1] = 0;
@@ -1079,7 +1079,7 @@ struct page *new_node_page(struct dnode_of_data *dn, unsigned int ofs)
 	set_cold_node(dn->inode, page);
 	if (!PageUptodate(page))
 		SetPageUptodate(page);
-	if (set_page_dirty(page))
+	if (set_page_dirty(NULL, page))
 		dn->node_changed = true;
 
 	if (f2fs_has_xattr_block(ofs))
@@ -1253,7 +1253,7 @@ static void flush_inline_data(struct f2fs_sb_info *sbi, nid_t ino)
 	inode_dec_dirty_pages(inode);
 	remove_dirty_inode(inode);
 	if (ret)
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 page_out:
 	f2fs_put_page(page, 1);
 iput_out:
@@ -1412,7 +1412,7 @@ void move_node_page(struct page *node_page, int gc_type)
 			.for_reclaim = 0,
 		};
 
-		set_page_dirty(node_page);
+		set_page_dirty(NULL, node_page);
 		f2fs_wait_on_page_writeback(node_page, NODE, true);
 
 		f2fs_bug_on(F2FS_P_SB(node_page), PageWriteback(node_page));
@@ -1426,7 +1426,7 @@ void move_node_page(struct page *node_page, int gc_type)
 	} else {
 		/* set page dirty and write it */
 		if (!PageWriteback(node_page))
-			set_page_dirty(node_page);
+			set_page_dirty(NULL, node_page);
 	}
 out_page:
 	unlock_page(node_page);
@@ -1514,7 +1514,7 @@ int fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 				}
 				/*  may be written by other thread */
 				if (!PageDirty(page))
-					set_page_dirty(page);
+					set_page_dirty(NULL, page);
 			}
 
 			if (!clear_page_dirty_for_io(page))
@@ -1550,7 +1550,7 @@ int fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 					ino, last_page->index);
 		lock_page(last_page);
 		f2fs_wait_on_page_writeback(last_page, NODE, true);
-		set_page_dirty(last_page);
+		set_page_dirty(NULL, last_page);
 		unlock_page(last_page);
 		goto retry;
 	}
@@ -2263,7 +2263,7 @@ int recover_xattr_data(struct inode *inode, struct page *page)
 	/* 3: update and set xattr node page dirty */
 	memcpy(F2FS_NODE(xpage), F2FS_NODE(page), VALID_XATTR_BLOCK_SIZE);
 
-	set_page_dirty(xpage);
+	set_page_dirty(NULL, xpage);
 	f2fs_put_page(xpage, 1);
 
 	return 0;
@@ -2324,7 +2324,7 @@ int recover_inode_page(struct f2fs_sb_info *sbi, struct page *page)
 		WARN_ON(1);
 	set_node_addr(sbi, &new_ni, NEW_ADDR, false);
 	inc_valid_inode_count(sbi);
-	set_page_dirty(ipage);
+	set_page_dirty(NULL, ipage);
 	f2fs_put_page(ipage, 1);
 	return 0;
 }
diff --git a/fs/f2fs/node.h b/fs/f2fs/node.h
index 081ef0d672bf..6945269e35ae 100644
--- a/fs/f2fs/node.h
+++ b/fs/f2fs/node.h
@@ -364,7 +364,7 @@ static inline int set_nid(struct page *p, int off, nid_t nid, bool i)
 		rn->i.i_nid[off - NODE_DIR1_BLOCK] = cpu_to_le32(nid);
 	else
 		rn->in.nid[off] = cpu_to_le32(nid);
-	return set_page_dirty(p);
+	return set_page_dirty(NULL, p);
 }
 
 static inline nid_t get_nid(struct page *p, int off, bool i)
diff --git a/fs/f2fs/recovery.c b/fs/f2fs/recovery.c
index 337f3363f48f..d29eb2bda530 100644
--- a/fs/f2fs/recovery.c
+++ b/fs/f2fs/recovery.c
@@ -529,7 +529,7 @@ static int do_recover_data(struct f2fs_sb_info *sbi, struct inode *inode,
 	copy_node_footer(dn.node_page, page);
 	fill_node_footer(dn.node_page, dn.nid, ni.ino,
 					ofs_of_node(page), false);
-	set_page_dirty(dn.node_page);
+	set_page_dirty(NULL, dn.node_page);
 err:
 	f2fs_put_dnode(&dn);
 out:
diff --git a/fs/f2fs/segment.c b/fs/f2fs/segment.c
index b16a8e6625aa..e188e241e4c2 100644
--- a/fs/f2fs/segment.c
+++ b/fs/f2fs/segment.c
@@ -367,7 +367,7 @@ static int __commit_inmem_pages(struct inode *inode,
 		if (page->mapping == inode->i_mapping) {
 			trace_f2fs_commit_inmem_page(page, INMEM);
 
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			f2fs_wait_on_page_writeback(page, DATA, true);
 			if (clear_page_dirty_for_io(page)) {
 				inode_dec_dirty_pages(inode);
@@ -2002,7 +2002,7 @@ void update_meta_page(struct f2fs_sb_info *sbi, void *src, block_t blk_addr)
 	struct page *page = grab_meta_page(sbi, blk_addr);
 
 	memcpy(page_address(page), src, PAGE_SIZE);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	f2fs_put_page(page, 1);
 }
 
@@ -2033,7 +2033,7 @@ static void write_current_sum_page(struct f2fs_sb_info *sbi,
 
 	mutex_unlock(&curseg->curseg_mutex);
 
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	f2fs_put_page(page, 1);
 }
 
@@ -3041,13 +3041,13 @@ static void write_compacted_summaries(struct f2fs_sb_info *sbi, block_t blkaddr)
 							SUM_FOOTER_SIZE)
 				continue;
 
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			f2fs_put_page(page, 1);
 			page = NULL;
 		}
 	}
 	if (page) {
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		f2fs_put_page(page, 1);
 	}
 }
@@ -3119,7 +3119,7 @@ static struct page *get_next_sit_page(struct f2fs_sb_info *sbi,
 	page = grab_meta_page(sbi, dst_off);
 	seg_info_to_sit_page(sbi, page, start);
 
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	set_to_next_sit(sit_i, start);
 
 	return page;
diff --git a/fs/f2fs/xattr.c b/fs/f2fs/xattr.c
index ae2dfa709f5d..9532139fa223 100644
--- a/fs/f2fs/xattr.c
+++ b/fs/f2fs/xattr.c
@@ -424,7 +424,7 @@ static inline int write_all_xattrs(struct inode *inode, __u32 hsize,
 				return err;
 			}
 			memcpy(inline_addr, txattr_addr, inline_size);
-			set_page_dirty(ipage ? ipage : in_page);
+			set_page_dirty(NULL, ipage ? ipage : in_page);
 			goto in_page_out;
 		}
 	}
@@ -457,8 +457,8 @@ static inline int write_all_xattrs(struct inode *inode, __u32 hsize,
 	memcpy(xattr_addr, txattr_addr + inline_size, VALID_XATTR_BLOCK_SIZE);
 
 	if (inline_size)
-		set_page_dirty(ipage ? ipage : in_page);
-	set_page_dirty(xpage);
+		set_page_dirty(NULL, ipage ? ipage : in_page);
+	set_page_dirty(NULL, xpage);
 
 	f2fs_put_page(xpage, 1);
 in_page_out:
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index e63be7831f4d..8a4a84f3657a 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2007,7 +2007,7 @@ static int fuse_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	fuse_write_update_size(inode, pos + copied);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 unlock:
 	unlock_page(page);
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 2c4584deb077..bcb75335c711 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -488,7 +488,7 @@ static int gfs2_page_mkwrite(struct vm_fault *vmf)
 out_uninit:
 	gfs2_holder_uninit(&gh);
 	if (ret == 0) {
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		wait_for_stable_page(page);
 	}
 out:
diff --git a/fs/hfs/bnode.c b/fs/hfs/bnode.c
index b63a4df7327b..9de3a2f9796d 100644
--- a/fs/hfs/bnode.c
+++ b/fs/hfs/bnode.c
@@ -67,7 +67,7 @@ void hfs_bnode_write(struct hfs_bnode *node, void *buf, int off, int len)
 
 	memcpy(kmap(page) + off, buf, len);
 	kunmap(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 }
 
 void hfs_bnode_write_u16(struct hfs_bnode *node, int off, u16 data)
@@ -92,7 +92,7 @@ void hfs_bnode_clear(struct hfs_bnode *node, int off, int len)
 
 	memset(kmap(page) + off, 0, len);
 	kunmap(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 }
 
 void hfs_bnode_copy(struct hfs_bnode *dst_node, int dst,
@@ -111,7 +111,7 @@ void hfs_bnode_copy(struct hfs_bnode *dst_node, int dst,
 	memcpy(kmap(dst_page) + dst, kmap(src_page) + src, len);
 	kunmap(src_page);
 	kunmap(dst_page);
-	set_page_dirty(dst_page);
+	set_page_dirty(NULL, dst_page);
 }
 
 void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
@@ -128,7 +128,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 	ptr = kmap(page);
 	memmove(ptr + dst, ptr + src, len);
 	kunmap(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 }
 
 void hfs_bnode_dump(struct hfs_bnode *node)
@@ -427,11 +427,11 @@ struct hfs_bnode *hfs_bnode_create(struct hfs_btree *tree, u32 num)
 	pagep = node->page;
 	memset(kmap(*pagep) + node->page_offset, 0,
 	       min((int)PAGE_SIZE, (int)tree->node_size));
-	set_page_dirty(*pagep);
+	set_page_dirty(NULL, *pagep);
 	kunmap(*pagep);
 	for (i = 1; i < tree->pages_per_bnode; i++) {
 		memset(kmap(*++pagep), 0, PAGE_SIZE);
-		set_page_dirty(*pagep);
+		set_page_dirty(NULL, *pagep);
 		kunmap(*pagep);
 	}
 	clear_bit(HFS_BNODE_NEW, &node->flags);
diff --git a/fs/hfs/btree.c b/fs/hfs/btree.c
index 374b5688e29e..91e7bdb5ecbb 100644
--- a/fs/hfs/btree.c
+++ b/fs/hfs/btree.c
@@ -181,7 +181,7 @@ void hfs_btree_write(struct hfs_btree *tree)
 	head->depth = cpu_to_be16(tree->depth);
 
 	kunmap(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	hfs_bnode_put(node);
 }
 
@@ -271,7 +271,7 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 					if (!(byte & m)) {
 						idx += i;
 						data[off] |= m;
-						set_page_dirty(*pagep);
+						set_page_dirty(NULL, *pagep);
 						kunmap(*pagep);
 						tree->free_nodes--;
 						mark_inode_dirty(tree->inode);
@@ -362,7 +362,7 @@ void hfs_bmap_free(struct hfs_bnode *node)
 		return;
 	}
 	data[off] = byte & ~m;
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	kunmap(page);
 	hfs_bnode_put(node);
 	tree->free_nodes++;
diff --git a/fs/hfsplus/bitmap.c b/fs/hfsplus/bitmap.c
index cebce0cfe340..f9685c1a207d 100644
--- a/fs/hfsplus/bitmap.c
+++ b/fs/hfsplus/bitmap.c
@@ -126,7 +126,7 @@ int hfsplus_block_allocate(struct super_block *sb, u32 size,
 			*curr++ = cpu_to_be32(0xffffffff);
 			len -= 32;
 		}
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		kunmap(page);
 		offset += PAGE_CACHE_BITS;
 		page = read_mapping_page(mapping, offset / PAGE_CACHE_BITS,
@@ -150,7 +150,7 @@ int hfsplus_block_allocate(struct super_block *sb, u32 size,
 	}
 done:
 	*curr = cpu_to_be32(n);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	kunmap(page);
 	*max = offset + (curr - pptr) * 32 + i - start;
 	sbi->free_blocks -= *max;
@@ -214,7 +214,7 @@ int hfsplus_block_free(struct super_block *sb, u32 offset, u32 count)
 		}
 		if (!count)
 			break;
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		kunmap(page);
 		page = read_mapping_page(mapping, ++pnr, NULL);
 		if (IS_ERR(page))
@@ -230,7 +230,7 @@ int hfsplus_block_free(struct super_block *sb, u32 offset, u32 count)
 		*curr &= cpu_to_be32(mask);
 	}
 out:
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	kunmap(page);
 	sbi->free_blocks += len;
 	hfsplus_mark_mdb_dirty(sb);
diff --git a/fs/hfsplus/bnode.c b/fs/hfsplus/bnode.c
index 177fae4e6581..8531709f667e 100644
--- a/fs/hfsplus/bnode.c
+++ b/fs/hfsplus/bnode.c
@@ -83,14 +83,14 @@ void hfs_bnode_write(struct hfs_bnode *node, void *buf, int off, int len)
 
 	l = min_t(int, len, PAGE_SIZE - off);
 	memcpy(kmap(*pagep) + off, buf, l);
-	set_page_dirty(*pagep);
+	set_page_dirty(NULL, *pagep);
 	kunmap(*pagep);
 
 	while ((len -= l) != 0) {
 		buf += l;
 		l = min_t(int, len, PAGE_SIZE);
 		memcpy(kmap(*++pagep), buf, l);
-		set_page_dirty(*pagep);
+		set_page_dirty(NULL, *pagep);
 		kunmap(*pagep);
 	}
 }
@@ -113,13 +113,13 @@ void hfs_bnode_clear(struct hfs_bnode *node, int off, int len)
 
 	l = min_t(int, len, PAGE_SIZE - off);
 	memset(kmap(*pagep) + off, 0, l);
-	set_page_dirty(*pagep);
+	set_page_dirty(NULL, *pagep);
 	kunmap(*pagep);
 
 	while ((len -= l) != 0) {
 		l = min_t(int, len, PAGE_SIZE);
 		memset(kmap(*++pagep), 0, l);
-		set_page_dirty(*pagep);
+		set_page_dirty(NULL, *pagep);
 		kunmap(*pagep);
 	}
 }
@@ -144,14 +144,14 @@ void hfs_bnode_copy(struct hfs_bnode *dst_node, int dst,
 		l = min_t(int, len, PAGE_SIZE - src);
 		memcpy(kmap(*dst_page) + src, kmap(*src_page) + src, l);
 		kunmap(*src_page);
-		set_page_dirty(*dst_page);
+		set_page_dirty(NULL, *dst_page);
 		kunmap(*dst_page);
 
 		while ((len -= l) != 0) {
 			l = min_t(int, len, PAGE_SIZE);
 			memcpy(kmap(*++dst_page), kmap(*++src_page), l);
 			kunmap(*src_page);
-			set_page_dirty(*dst_page);
+			set_page_dirty(NULL, *dst_page);
 			kunmap(*dst_page);
 		}
 	} else {
@@ -172,7 +172,7 @@ void hfs_bnode_copy(struct hfs_bnode *dst_node, int dst,
 			l = min(len, l);
 			memcpy(dst_ptr, src_ptr, l);
 			kunmap(*src_page);
-			set_page_dirty(*dst_page);
+			set_page_dirty(NULL, *dst_page);
 			kunmap(*dst_page);
 			if (!dst)
 				dst_page++;
@@ -204,7 +204,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 			while (src < len) {
 				memmove(kmap(*dst_page), kmap(*src_page), src);
 				kunmap(*src_page);
-				set_page_dirty(*dst_page);
+				set_page_dirty(NULL, *dst_page);
 				kunmap(*dst_page);
 				len -= src;
 				src = PAGE_SIZE;
@@ -215,7 +215,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 			memmove(kmap(*dst_page) + src,
 				kmap(*src_page) + src, len);
 			kunmap(*src_page);
-			set_page_dirty(*dst_page);
+			set_page_dirty(NULL, *dst_page);
 			kunmap(*dst_page);
 		} else {
 			void *src_ptr, *dst_ptr;
@@ -235,7 +235,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 				l = min(len, l);
 				memmove(dst_ptr - l, src_ptr - l, l);
 				kunmap(*src_page);
-				set_page_dirty(*dst_page);
+				set_page_dirty(NULL, *dst_page);
 				kunmap(*dst_page);
 				if (dst == PAGE_SIZE)
 					dst_page--;
@@ -254,7 +254,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 			memmove(kmap(*dst_page) + src,
 				kmap(*src_page) + src, l);
 			kunmap(*src_page);
-			set_page_dirty(*dst_page);
+			set_page_dirty(NULL, *dst_page);
 			kunmap(*dst_page);
 
 			while ((len -= l) != 0) {
@@ -262,7 +262,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 				memmove(kmap(*++dst_page),
 					kmap(*++src_page), l);
 				kunmap(*src_page);
-				set_page_dirty(*dst_page);
+				set_page_dirty(NULL, *dst_page);
 				kunmap(*dst_page);
 			}
 		} else {
@@ -284,7 +284,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 				l = min(len, l);
 				memmove(dst_ptr, src_ptr, l);
 				kunmap(*src_page);
-				set_page_dirty(*dst_page);
+				set_page_dirty(NULL, *dst_page);
 				kunmap(*dst_page);
 				if (!dst)
 					dst_page++;
@@ -595,11 +595,11 @@ struct hfs_bnode *hfs_bnode_create(struct hfs_btree *tree, u32 num)
 	pagep = node->page;
 	memset(kmap(*pagep) + node->page_offset, 0,
 	       min_t(int, PAGE_SIZE, tree->node_size));
-	set_page_dirty(*pagep);
+	set_page_dirty(NULL, *pagep);
 	kunmap(*pagep);
 	for (i = 1; i < tree->pages_per_bnode; i++) {
 		memset(kmap(*++pagep), 0, PAGE_SIZE);
-		set_page_dirty(*pagep);
+		set_page_dirty(NULL, *pagep);
 		kunmap(*pagep);
 	}
 	clear_bit(HFS_BNODE_NEW, &node->flags);
diff --git a/fs/hfsplus/btree.c b/fs/hfsplus/btree.c
index de14b2b6881b..985123b314eb 100644
--- a/fs/hfsplus/btree.c
+++ b/fs/hfsplus/btree.c
@@ -304,7 +304,7 @@ int hfs_btree_write(struct hfs_btree *tree)
 	head->depth = cpu_to_be16(tree->depth);
 
 	kunmap(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	hfs_bnode_put(node);
 	return 0;
 }
@@ -394,7 +394,7 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 					if (!(byte & m)) {
 						idx += i;
 						data[off] |= m;
-						set_page_dirty(*pagep);
+						set_page_dirty(NULL, *pagep);
 						kunmap(*pagep);
 						tree->free_nodes--;
 						mark_inode_dirty(tree->inode);
@@ -490,7 +490,7 @@ void hfs_bmap_free(struct hfs_bnode *node)
 		return;
 	}
 	data[off] = byte & ~m;
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	kunmap(page);
 	hfs_bnode_put(node);
 	tree->free_nodes++;
diff --git a/fs/hfsplus/xattr.c b/fs/hfsplus/xattr.c
index e538b758c448..c00a14bf43d0 100644
--- a/fs/hfsplus/xattr.c
+++ b/fs/hfsplus/xattr.c
@@ -235,7 +235,7 @@ static int hfsplus_create_attributes_file(struct super_block *sb)
 			min_t(size_t, PAGE_SIZE, node_size - written));
 		kunmap_atomic(kaddr);
 
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		put_page(page);
 	}
 
diff --git a/fs/iomap.c b/fs/iomap.c
index 557d990c26ea..dd86d5ca6fe5 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -477,7 +477,7 @@ int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops)
 		length -= ret;
 	}
 
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	wait_for_stable_page(page);
 	return VM_FAULT_LOCKED;
 out_unlock:
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
index 9071b4077108..84060e65e102 100644
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -718,7 +718,7 @@ void force_metapage(struct metapage *mp)
 	clear_bit(META_sync, &mp->flag);
 	get_page(page);
 	lock_page(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	if (write_one_page(page))
 		jfs_error(mp->sb, "write_one_page() failed\n");
 	clear_bit(META_forcewrite, &mp->flag);
@@ -762,7 +762,7 @@ void release_metapage(struct metapage * mp)
 	}
 
 	if (test_bit(META_dirty, &mp->flag)) {
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		if (test_bit(META_sync, &mp->flag)) {
 			clear_bit(META_sync, &mp->flag);
 			if (write_one_page(page))
diff --git a/fs/libfs.c b/fs/libfs.c
index 585ef1f37d54..360a64a454ab 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -494,7 +494,7 @@ int simple_write_end(struct file *file, struct address_space *mapping,
 	if (last_pos > inode->i_size)
 		i_size_write(inode, last_pos);
 
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	unlock_page(page);
 	put_page(page);
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index b752f5d8d5f4..58bdf005b877 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -413,7 +413,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 		struct page *page = req->wb_page;
 
 		if (!PageCompound(page) && bytes < hdr->good_bytes)
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 		bytes += req->wb_bytes;
 		nfs_list_remove_request(req);
 		nfs_release_request(req);
diff --git a/fs/ntfs/attrib.c b/fs/ntfs/attrib.c
index 44a39a099b54..5b4f444fd080 100644
--- a/fs/ntfs/attrib.c
+++ b/fs/ntfs/attrib.c
@@ -1746,7 +1746,7 @@ int ntfs_attr_make_non_resident(ntfs_inode *ni, const u32 data_size)
 	unmap_mft_record(base_ni);
 	up_write(&ni->runlist.lock);
 	if (page) {
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		unlock_page(page);
 		put_page(page);
 	}
@@ -2543,7 +2543,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		memset(kaddr + start_ofs, val, size - start_ofs);
 		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		put_page(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
@@ -2582,7 +2582,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		 * Set the page and all its buffers dirty and mark the inode
 		 * dirty, too.  The VM will write the page later on.
 		 */
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		/* Finally unlock and release the page. */
 		unlock_page(page);
 		put_page(page);
@@ -2601,7 +2601,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		memset(kaddr, val, end_ofs);
 		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		put_page(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
diff --git a/fs/ntfs/bitmap.c b/fs/ntfs/bitmap.c
index ec130c588d2b..ee92820b7b8a 100644
--- a/fs/ntfs/bitmap.c
+++ b/fs/ntfs/bitmap.c
@@ -122,7 +122,7 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 
 		/* Update @index and get the next page. */
 		flush_dcache_page(page);
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		ntfs_unmap_page(page);
 		page = ntfs_map_page(mapping, ++index);
 		if (IS_ERR(page))
@@ -158,7 +158,7 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 done:
 	/* We are done.  Unmap the page and return success. */
 	flush_dcache_page(page);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	ntfs_unmap_page(page);
 	ntfs_debug("Done.");
 	return 0;
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index bf07c0ca127e..c551defedaab 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -247,7 +247,7 @@ static int ntfs_attr_extend_initialized(ntfs_inode *ni, const s64 new_init_size)
 			ni->initialized_size = new_init_size;
 		write_unlock_irqrestore(&ni->size_lock, flags);
 		/* Set the page dirty so it gets written out. */
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		put_page(page);
 		/*
 		 * Play nice with the vm and the rest of the system.  This is
diff --git a/fs/ntfs/lcnalloc.c b/fs/ntfs/lcnalloc.c
index 27a24a42f712..50a568f77a25 100644
--- a/fs/ntfs/lcnalloc.c
+++ b/fs/ntfs/lcnalloc.c
@@ -277,7 +277,7 @@ runlist_element *ntfs_cluster_alloc(ntfs_volume *vol, const VCN start_vcn,
 			if (need_writeback) {
 				ntfs_debug("Marking page dirty.");
 				flush_dcache_page(page);
-				set_page_dirty(page);
+				set_page_dirty(NULL, page);
 				need_writeback = 0;
 			}
 			ntfs_unmap_page(page);
@@ -745,7 +745,7 @@ switch_to_data1_zone:		search_zone = 2;
 		if (need_writeback) {
 			ntfs_debug("Marking page dirty.");
 			flush_dcache_page(page);
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			need_writeback = 0;
 		}
 		ntfs_unmap_page(page);
diff --git a/fs/ntfs/mft.c b/fs/ntfs/mft.c
index 2831f495a674..52757378b39d 100644
--- a/fs/ntfs/mft.c
+++ b/fs/ntfs/mft.c
@@ -1217,7 +1217,7 @@ static int ntfs_mft_bitmap_find_and_alloc_free_rec_nolock(ntfs_volume *vol,
 					}
 					*byte |= 1 << b;
 					flush_dcache_page(page);
-					set_page_dirty(page);
+					set_page_dirty(NULL, page);
 					ntfs_unmap_page(page);
 					ntfs_debug("Done.  (Found and "
 							"allocated mft record "
@@ -1342,7 +1342,7 @@ static int ntfs_mft_bitmap_extend_allocation_nolock(ntfs_volume *vol)
 		/* Next cluster is free, allocate it. */
 		*b |= tb;
 		flush_dcache_page(page);
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		up_write(&vol->lcnbmp_lock);
 		ntfs_unmap_page(page);
 		/* Update the mft bitmap runlist. */
diff --git a/fs/ntfs/usnjrnl.c b/fs/ntfs/usnjrnl.c
index b2bc0d55b036..3f35649fc3f6 100644
--- a/fs/ntfs/usnjrnl.c
+++ b/fs/ntfs/usnjrnl.c
@@ -72,7 +72,7 @@ bool ntfs_stamp_usnjrnl(ntfs_volume *vol)
 				cpu_to_sle64(i_size_read(vol->usnjrnl_j_ino));
 		uh->journal_id = stamp;
 		flush_dcache_page(page);
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		ntfs_unmap_page(page);
 		/* Set the flag so we do not have to do it again on remount. */
 		NVolSetUsnJrnlStamped(vol);
diff --git a/fs/udf/file.c b/fs/udf/file.c
index 0f6a1de6b272..413f09b17136 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -122,7 +122,7 @@ static int udf_adinicb_write_end(struct file *file, struct address_space *mappin
 	loff_t last_pos = pos + copied;
 	if (last_pos > inode->i_size)
 		i_size_write(inode, last_pos);
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	unlock_page(page);
 	put_page(page);
 	return copied;
diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index c96630059d9e..abe8d36be626 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -1096,7 +1096,7 @@ static int ufs_alloc_lastblock(struct inode *inode, loff_t size)
 		*/
 	       set_buffer_uptodate(bh);
 	       mark_buffer_dirty(NULL, bh);
-	       set_page_dirty(lastpage);
+	       set_page_dirty(NULL, lastpage);
        }
 
        if (lastfrag >= UFS_IND_FRAGMENT) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1793b2e4f6b1..da847c874f9f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1463,7 +1463,7 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
 void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb);
-int set_page_dirty(struct page *page);
+int set_page_dirty(struct address_space *, struct page *);
 int set_page_dirty_lock(struct page *page);
 void __cancel_dirty_page(struct page *page);
 static inline void cancel_dirty_page(struct page *page)
diff --git a/mm/filemap.c b/mm/filemap.c
index a41c7cfb6351..c1ee7431bc4d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2717,7 +2717,7 @@ int filemap_page_mkwrite(struct vm_fault *vmf)
 	 * progress, we are guaranteed that writeback during freezing will
 	 * see the dirty page and writeprotect it again.
 	 */
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	wait_for_stable_page(page);
 out:
 	sb_end_pagefault(inode->i_sb);
diff --git a/mm/gup.c b/mm/gup.c
index 6afae32571ca..5b9cee21d9dd 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -164,7 +164,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 		/*
 		 * pte_mkyoung() would be more correct here, but atomic care
 		 * is needed to avoid losing the dirty bit: it is easier to use
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5a68730eebd6..9d628ab218ce 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2892,7 +2892,7 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 	pmdval = *pvmw->pmd;
 	pmdp_invalidate(vma, address, pvmw->pmd);
 	if (pmd_dirty(pmdval))
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 	entry = make_migration_entry(page, pmd_write(pmdval));
 	pmdswp = swp_entry_to_pmd(entry);
 	if (pmd_soft_dirty(pmdval))
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 976bbc5646fe..b4595b509d6e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3387,7 +3387,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
 		tlb_remove_huge_tlb_entry(h, tlb, ptep, address);
 		if (huge_pte_dirty(pte))
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 
 		hugetlb_count_sub(pages_per_huge_page(h), mm);
 		page_remove_rmap(page, true);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index e42568284e06..ccd5da4e855f 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1513,7 +1513,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		retract_page_tables(mapping, start);
 
 		/* Everything is ready, let's unfreeze the new_page */
-		set_page_dirty(new_page);
+		set_page_dirty(NULL, new_page);
 		SetPageUptodate(new_page);
 		page_ref_unfreeze(new_page, HPAGE_PMD_NR);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
diff --git a/mm/ksm.c b/mm/ksm.c
index 293721f5da70..1c16a4309c1d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1061,7 +1061,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 			goto out_unlock;
 		}
 		if (pte_dirty(entry))
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 
 		if (pte_protnone(entry))
 			entry = pte_mkclean(pte_clear_savedwrite(entry));
diff --git a/mm/memory.c b/mm/memory.c
index 6ffd76528e7b..22906aab3922 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1327,7 +1327,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			if (!PageAnon(page)) {
 				if (pte_dirty(ptent)) {
 					force_flush = 1;
-					set_page_dirty(page);
+					set_page_dirty(NULL, page);
 				}
 				if (pte_young(ptent) &&
 				    likely(!(vma->vm_flags & VM_SEQ_READ)))
@@ -2400,7 +2400,7 @@ static void fault_dirty_shared_page(struct vm_area_struct *vma,
 	bool dirtied;
 	bool page_mkwrite = vma->vm_ops && vma->vm_ops->page_mkwrite;
 
-	dirtied = set_page_dirty(page);
+	dirtied = set_page_dirty(NULL, page);
 	VM_BUG_ON_PAGE(PageAnon(page), page);
 	/*
 	 * Take a local copy of the address_space - page.mapping may be zeroed
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ed9424f84715..d8856be8cc70 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2548,7 +2548,7 @@ EXPORT_SYMBOL(redirty_page_for_writepage);
  * If the mapping doesn't provide a set_page_dirty a_op, then
  * just fall through and assume that it wants buffer_heads.
  */
-int set_page_dirty(struct page *page)
+int set_page_dirty(struct address_space *_mapping, struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 
@@ -2599,7 +2599,7 @@ int set_page_dirty_lock(struct page *page)
 	int ret;
 
 	lock_page(page);
-	ret = set_page_dirty(page);
+	ret = set_page_dirty(NULL, page);
 	unlock_page(page);
 	return ret;
 }
@@ -2693,7 +2693,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * threads doing their things.
 		 */
 		if (page_mkclean(page))
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 		/*
 		 * We carefully synchronise fault handlers against
 		 * installing a dirty pte and marking the page dirty
diff --git a/mm/page_io.c b/mm/page_io.c
index b4a4c52bb4e9..5afc8b8a6b97 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -62,7 +62,7 @@ void end_swap_bio_write(struct bio *bio)
 		 *
 		 * Also clear PG_reclaim to avoid rotate_reclaimable_page()
 		 */
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		pr_alert("Write-error on swap-device (%u:%u:%llu)\n",
 			 MAJOR(bio_dev(bio)), MINOR(bio_dev(bio)),
 			 (unsigned long long)bio->bi_iter.bi_sector);
@@ -329,7 +329,7 @@ int __swap_writepage(struct address_space *mapping, struct page *page,
 			 * the normal direct-to-bio case as it could
 			 * be temporary.
 			 */
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			ClearPageReclaim(page);
 			pr_err_ratelimited("Write error on dio swapfile (%llu)\n",
 					   page_file_offset(page));
@@ -348,7 +348,7 @@ int __swap_writepage(struct address_space *mapping, struct page *page,
 	ret = 0;
 	bio = get_swap_bio(GFP_NOIO, page, end_write_func);
 	if (bio == NULL) {
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		unlock_page(page);
 		ret = -ENOMEM;
 		goto out;
diff --git a/mm/rmap.c b/mm/rmap.c
index 47db27f8049e..822a3a0cd51c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1465,7 +1465,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 		/* Move the dirty bit to the page. Now the pte is gone. */
 		if (pte_dirty(pteval))
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 
 		/* Update high watermark before we lower rss */
 		update_hiwater_rss(mm);
diff --git a/mm/shmem.c b/mm/shmem.c
index 7f3168d547c8..cb09fea4a9ce 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -874,7 +874,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				partial_end = 0;
 			}
 			zero_user_segment(page, partial_start, top);
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			unlock_page(page);
 			put_page(page);
 		}
@@ -884,7 +884,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		shmem_getpage(inode, end, &page, SGP_READ);
 		if (page) {
 			zero_user_segment(page, 0, partial_end);
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			unlock_page(page);
 			put_page(page);
 		}
@@ -1189,7 +1189,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 		 * only does trylock page: if we raced, best clean up here.
 		 */
 		delete_from_swap_cache(*pagep);
-		set_page_dirty(*pagep);
+		set_page_dirty(NULL, *pagep);
 		if (!error) {
 			spin_lock_irq(&info->lock);
 			info->swapped--;
@@ -1364,7 +1364,7 @@ static int shmem_writepage(struct address_space *_mapping, struct page *page,
 free_swap:
 	put_swap_page(page, swap);
 redirty:
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	if (wbc->for_reclaim)
 		return AOP_WRITEPAGE_ACTIVATE;	/* Return with page locked */
 	unlock_page(page);
@@ -1738,7 +1738,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 			mark_page_accessed(page);
 
 		delete_from_swap_cache(page);
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		swap_free(swap);
 
 	} else {
@@ -2416,7 +2416,7 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 		}
 		SetPageUptodate(head);
 	}
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	unlock_page(page);
 	put_page(page);
 
@@ -2469,7 +2469,7 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		}
 		if (page) {
 			if (sgp == SGP_CACHE)
-				set_page_dirty(page);
+				set_page_dirty(NULL, page);
 			unlock_page(page);
 		}
 
@@ -2970,7 +2970,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		 * than free the pages we are allocating (and SGP_CACHE pages
 		 * might still be clean: we now need to mark those dirty too).
 		 */
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		unlock_page(page);
 		put_page(page);
 		cond_resched();
@@ -3271,7 +3271,7 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		inode->i_op = &shmem_symlink_inode_operations;
 		memcpy(page_address(page), symname, len);
 		SetPageUptodate(page);
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 		unlock_page(page);
 		put_page(page);
 	}
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 40a2437e3c34..3fede4bc753e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -249,7 +249,7 @@ int add_to_swap(struct page *page)
 	 * is swap in later. Always setting the dirty bit for the page solves
 	 * the problem.
 	 */
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 
 	return 1;
 
diff --git a/mm/truncate.c b/mm/truncate.c
index 57d4d0948f40..78d907008367 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -874,7 +874,7 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 	 * is needed.
 	 */
 	if (page_mkclean(page))
-		set_page_dirty(page);
+		set_page_dirty(NULL, page);
 	unlock_page(page);
 	put_page(page);
 }
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index e678699268a2..91b2cb759bf9 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -252,7 +252,7 @@ void __rds_ib_teardown_mr(struct rds_ib_mr *ibmr)
 			/* FIXME we need a way to tell a r/w MR
 			 * from a r/o MR */
 			WARN_ON(!page->mapping && irqs_disabled());
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 			put_page(page);
 		}
 		kfree(ibmr->sg);
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 634cfcb7bba6..0bc9839c2c01 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -461,7 +461,7 @@ void rds_rdma_free_op(struct rm_rdma_op *ro)
 		 * to local memory */
 		if (!ro->op_write) {
 			WARN_ON(!page->mapping && irqs_disabled());
-			set_page_dirty(page);
+			set_page_dirty(NULL, page);
 		}
 		put_page(page);
 	}
@@ -478,7 +478,7 @@ void rds_atomic_free_op(struct rm_atomic_op *ao)
 	/* Mark page dirty if it was possibly modified, which
 	 * is the case for a RDMA_READ which copies from remote
 	 * to local memory */
-	set_page_dirty(page);
+	set_page_dirty(NULL, page);
 	put_page(page);
 
 	kfree(ao->op_notifier);
-- 
2.14.3
