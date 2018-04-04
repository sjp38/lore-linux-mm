Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 495646B027F
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:32 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m15so15341185qke.16
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j23si3954986qtl.73.2018.04.04.12.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:31 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 72/79] mm: add struct address_space to set_page_dirty_lock()
Date: Wed,  4 Apr 2018 15:18:24 -0400
Message-Id: <20180404191831.5378-35-jglisse@redhat.com>
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
struct address_space to set_page_dirty_lock() arguments.

<---------------------------------------------------------------------
@@
identifier I1;
type T1;
@@
int
-set_page_dirty_lock(T1 I1)
+set_page_dirty_lock(struct address_space *_mapping, T1 I1)
{...}

@@
type T1;
@@
int
-set_page_dirty_lock(T1)
+set_page_dirty_lock(struct address_space *, T1)
;

@@
identifier I1;
type T1;
@@
int
-set_page_dirty_lock(T1 I1)
+set_page_dirty_lock(struct address_space *, T1)
;

@@
expression E1;
@@
-set_page_dirty_lock(E1)
+set_page_dirty_lock(NULL, E1)
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
 arch/cris/arch-v32/drivers/cryptocop.c                | 2 +-
 arch/powerpc/kvm/book3s_64_mmu_radix.c                | 2 +-
 arch/powerpc/kvm/e500_mmu.c                           | 3 ++-
 arch/s390/kvm/interrupt.c                             | 4 ++--
 arch/x86/kvm/svm.c                                    | 2 +-
 block/bio.c                                           | 4 ++--
 drivers/gpu/drm/exynos/exynos_drm_g2d.c               | 2 +-
 drivers/infiniband/core/umem.c                        | 2 +-
 drivers/infiniband/hw/hfi1/user_pages.c               | 2 +-
 drivers/infiniband/hw/qib/qib_user_pages.c            | 2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c              | 2 +-
 drivers/media/common/videobuf2/videobuf2-dma-contig.c | 2 +-
 drivers/media/common/videobuf2/videobuf2-dma-sg.c     | 2 +-
 drivers/media/common/videobuf2/videobuf2-vmalloc.c    | 2 +-
 drivers/misc/genwqe/card_utils.c                      | 2 +-
 drivers/staging/lustre/lustre/llite/rw26.c            | 2 +-
 drivers/vhost/vhost.c                                 | 2 +-
 fs/block_dev.c                                        | 2 +-
 fs/direct-io.c                                        | 2 +-
 fs/fuse/dev.c                                         | 2 +-
 fs/fuse/file.c                                        | 2 +-
 include/linux/mm.h                                    | 2 +-
 mm/memory.c                                           | 2 +-
 mm/page-writeback.c                                   | 2 +-
 mm/process_vm_access.c                                | 2 +-
 net/ceph/pagevec.c                                    | 2 +-
 26 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/arch/cris/arch-v32/drivers/cryptocop.c b/arch/cris/arch-v32/drivers/cryptocop.c
index a3c353472a8c..5cb42555c90b 100644
--- a/arch/cris/arch-v32/drivers/cryptocop.c
+++ b/arch/cris/arch-v32/drivers/cryptocop.c
@@ -2930,7 +2930,7 @@ static int cryptocop_ioctl_process(struct inode *inode, struct file *filp, unsig
 	for (i = 0; i < nooutpages; i++){
 		int spdl_err;
 		/* Mark output pages dirty. */
-		spdl_err = set_page_dirty_lock(outpages[i]);
+		spdl_err = set_page_dirty_lock(NULL, outpages[i]);
 		DEBUG(if (spdl_err < 0)printk("cryptocop_ioctl_process: set_page_dirty_lock returned %d\n", spdl_err));
 	}
 	for (i = 0; i < nooutpages; i++){
diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index 5cb4e4687107..8daefabe650e 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -482,7 +482,7 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 
 	if (page) {
 		if (!ret && (pgflags & _PAGE_WRITE))
-			set_page_dirty_lock(page);
+			set_page_dirty_lock(NULL, page);
 		put_page(page);
 	}
 
diff --git a/arch/powerpc/kvm/e500_mmu.c b/arch/powerpc/kvm/e500_mmu.c
index ddbf8f0284c0..364ee7a5b268 100644
--- a/arch/powerpc/kvm/e500_mmu.c
+++ b/arch/powerpc/kvm/e500_mmu.c
@@ -556,7 +556,8 @@ static void free_gtlb(struct kvmppc_vcpu_e500 *vcpu_e500)
 					  PAGE_SIZE)));
 
 		for (i = 0; i < vcpu_e500->num_shared_tlb_pages; i++) {
-			set_page_dirty_lock(vcpu_e500->shared_tlb_pages[i]);
+			set_page_dirty_lock(NULL,
+					    vcpu_e500->shared_tlb_pages[i]);
 			put_page(vcpu_e500->shared_tlb_pages[i]);
 		}
 
diff --git a/arch/s390/kvm/interrupt.c b/arch/s390/kvm/interrupt.c
index b04616b57a94..6db8d4f5c74f 100644
--- a/arch/s390/kvm/interrupt.c
+++ b/arch/s390/kvm/interrupt.c
@@ -2616,7 +2616,7 @@ static int adapter_indicators_set(struct kvm *kvm,
 	set_bit(bit, map);
 	idx = srcu_read_lock(&kvm->srcu);
 	mark_page_dirty(kvm, info->guest_addr >> PAGE_SHIFT);
-	set_page_dirty_lock(info->page);
+	set_page_dirty_lock(NULL, info->page);
 	info = get_map_info(adapter, adapter_int->summary_addr);
 	if (!info) {
 		srcu_read_unlock(&kvm->srcu, idx);
@@ -2627,7 +2627,7 @@ static int adapter_indicators_set(struct kvm *kvm,
 			  adapter->swap);
 	summary_set = test_and_set_bit(bit, map);
 	mark_page_dirty(kvm, info->guest_addr >> PAGE_SHIFT);
-	set_page_dirty_lock(info->page);
+	set_page_dirty_lock(NULL, info->page);
 	srcu_read_unlock(&kvm->srcu, idx);
 	return summary_set ? 0 : 1;
 }
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index be9c839e2c89..f26f1ce478ab 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -6271,7 +6271,7 @@ static int sev_launch_update_data(struct kvm *kvm, struct kvm_sev_cmd *argp)
 e_unpin:
 	/* content of memory is updated, mark pages dirty */
 	for (i = 0; i < npages; i++) {
-		set_page_dirty_lock(inpages[i]);
+		set_page_dirty_lock(NULL, inpages[i]);
 		mark_page_accessed(inpages[i]);
 	}
 	/* unlock the user pages */
diff --git a/block/bio.c b/block/bio.c
index e1708db48258..28cd15314235 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1376,7 +1376,7 @@ static void __bio_unmap_user(struct bio *bio)
 	 */
 	bio_for_each_segment_all(bvec, bio, i) {
 		if (bio_data_dir(bio) == READ)
-			set_page_dirty_lock(bvec->bv_page);
+			set_page_dirty_lock(NULL, bvec->bv_page);
 
 		put_page(bvec->bv_page);
 	}
@@ -1581,7 +1581,7 @@ void bio_set_pages_dirty(struct bio *bio)
 		struct page *page = bvec->bv_page;
 
 		if (page && !PageCompound(page))
-			set_page_dirty_lock(page);
+			set_page_dirty_lock(NULL, page);
 	}
 }
 
diff --git a/drivers/gpu/drm/exynos/exynos_drm_g2d.c b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
index f68ef1b3a28c..28480c603f7b 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_g2d.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
@@ -406,7 +406,7 @@ static void g2d_userptr_put_dma_addr(struct drm_device *drm_dev,
 		int i;
 
 		for (i = 0; i < frame_vector_count(g2d_userptr->vec); i++)
-			set_page_dirty_lock(pages[i]);
+			set_page_dirty_lock(NULL, pages[i]);
 	}
 	put_vaddr_frames(g2d_userptr->vec);
 	frame_vector_destroy(g2d_userptr->vec);
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 9a4e899d94b3..e0d776983a46 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -59,7 +59,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
 
 		page = sg_page(sg);
 		if (!PageDirty(page) && umem->writable && dirty)
-			set_page_dirty_lock(page);
+			set_page_dirty_lock(NULL, page);
 		put_page(page);
 	}
 
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index e341e6dcc388..98d11ee5853a 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -125,7 +125,7 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 
 	for (i = 0; i < npages; i++) {
 		if (dirty)
-			set_page_dirty_lock(p[i]);
+			set_page_dirty_lock(NULL, p[i]);
 		put_page(p[i]);
 	}
 
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index ce83ba9a12ef..39273c68bd54 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -44,7 +44,7 @@ static void __qib_release_user_pages(struct page **p, size_t num_pages,
 
 	for (i = 0; i < num_pages; i++) {
 		if (dirty)
-			set_page_dirty_lock(p[i]);
+			set_page_dirty_lock(NULL, p[i]);
 		put_page(p[i]);
 	}
 }
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 4381c0a9a873..5bab9930cf89 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -89,7 +89,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
 			page = sg_page(sg);
 			pa = sg_phys(sg);
 			if (dirty)
-				set_page_dirty_lock(page);
+				set_page_dirty_lock(NULL, page);
 			put_page(page);
 			usnic_dbg("pa: %pa\n", &pa);
 		}
diff --git a/drivers/media/common/videobuf2/videobuf2-dma-contig.c b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
index f1178f6f434d..0628ed526e80 100644
--- a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
+++ b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
@@ -437,7 +437,7 @@ static void vb2_dc_put_userptr(void *buf_priv)
 		if (buf->dma_dir == DMA_FROM_DEVICE ||
 		    buf->dma_dir == DMA_BIDIRECTIONAL)
 			for (i = 0; i < frame_vector_count(buf->vec); i++)
-				set_page_dirty_lock(pages[i]);
+				set_page_dirty_lock(NULL, pages[i]);
 		sg_free_table(sgt);
 		kfree(sgt);
 	}
diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
index 753ed3138dcc..ed63b47e0cfa 100644
--- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
+++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
@@ -295,7 +295,7 @@ static void vb2_dma_sg_put_userptr(void *buf_priv)
 	if (buf->dma_dir == DMA_FROM_DEVICE ||
 	    buf->dma_dir == DMA_BIDIRECTIONAL)
 		while (--i >= 0)
-			set_page_dirty_lock(buf->pages[i]);
+			set_page_dirty_lock(NULL, buf->pages[i]);
 	vb2_destroy_framevec(buf->vec);
 	kfree(buf);
 }
diff --git a/drivers/media/common/videobuf2/videobuf2-vmalloc.c b/drivers/media/common/videobuf2/videobuf2-vmalloc.c
index 3a7c80cd1a17..300179a028f9 100644
--- a/drivers/media/common/videobuf2/videobuf2-vmalloc.c
+++ b/drivers/media/common/videobuf2/videobuf2-vmalloc.c
@@ -141,7 +141,7 @@ static void vb2_vmalloc_put_userptr(void *buf_priv)
 		if (buf->dma_dir == DMA_FROM_DEVICE ||
 		    buf->dma_dir == DMA_BIDIRECTIONAL)
 			for (i = 0; i < n_pages; i++)
-				set_page_dirty_lock(pages[i]);
+				set_page_dirty_lock(NULL, pages[i]);
 	} else {
 		iounmap((__force void __iomem *)buf->vaddr);
 	}
diff --git a/drivers/misc/genwqe/card_utils.c b/drivers/misc/genwqe/card_utils.c
index 8f2e6442d88b..09e16bb00412 100644
--- a/drivers/misc/genwqe/card_utils.c
+++ b/drivers/misc/genwqe/card_utils.c
@@ -540,7 +540,7 @@ static int genwqe_free_user_pages(struct page **page_list,
 	for (i = 0; i < nr_pages; i++) {
 		if (page_list[i] != NULL) {
 			if (dirty)
-				set_page_dirty_lock(page_list[i]);
+				set_page_dirty_lock(NULL, page_list[i]);
 			put_page(page_list[i]);
 		}
 	}
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 969f4dad2f82..e5d8a91c3dda 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -168,7 +168,7 @@ static void ll_free_user_pages(struct page **pages, int npages, int do_dirty)
 
 	for (i = 0; i < npages; i++) {
 		if (do_dirty)
-			set_page_dirty_lock(pages[i]);
+			set_page_dirty_lock(NULL, pages[i]);
 		put_page(pages[i]);
 	}
 	kvfree(pages);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 1b3e8d2d5c8b..d1f3eaec0f49 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1656,7 +1656,7 @@ static int set_bit_to_user(int nr, void __user *addr)
 	base = kmap_atomic(page);
 	set_bit(bit, base);
 	kunmap_atomic(base);
-	set_page_dirty_lock(page);
+	set_page_dirty_lock(NULL, page);
 	put_page(page);
 	return 0;
 }
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 50752935681e..bae849d647d0 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -244,7 +244,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 
 	bio_for_each_segment_all(bvec, &bio, i) {
 		if (should_dirty && !PageCompound(bvec->bv_page))
-			set_page_dirty_lock(bvec->bv_page);
+			set_page_dirty_lock(NULL, bvec->bv_page);
 		put_page(bvec->bv_page);
 	}
 
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 1357ef563893..d9a634e239e0 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -557,7 +557,7 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
 
 			if (dio->op == REQ_OP_READ && !PageCompound(page) &&
 					dio->should_dirty)
-				set_page_dirty_lock(page);
+				set_page_dirty_lock(NULL, page);
 			put_page(page);
 		}
 		bio_put(bio);
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 5d06384c2cae..c7baaa15a072 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -707,7 +707,7 @@ static void fuse_copy_finish(struct fuse_copy_state *cs)
 	} else if (cs->pg) {
 		if (cs->write) {
 			flush_dcache_page(cs->pg);
-			set_page_dirty_lock(cs->pg);
+			set_page_dirty_lock(NULL, cs->pg);
 		}
 		put_page(cs->pg);
 	}
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 8a4a84f3657a..011c56abc772 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -533,7 +533,7 @@ static void fuse_release_user_pages(struct fuse_req *req, bool should_dirty)
 	for (i = 0; i < req->num_pages; i++) {
 		struct page *page = req->pages[i];
 		if (should_dirty)
-			set_page_dirty_lock(page);
+			set_page_dirty_lock(NULL, page);
 		put_page(page);
 	}
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index da847c874f9f..a8d4a859d6ad 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1464,7 +1464,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb);
 int set_page_dirty(struct address_space *, struct page *);
-int set_page_dirty_lock(struct page *page);
+int set_page_dirty_lock(struct address_space *, struct page *);
 void __cancel_dirty_page(struct page *page);
 static inline void cancel_dirty_page(struct page *page)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 22906aab3922..20443ebf9c42 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4466,7 +4466,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 			if (write) {
 				copy_to_user_page(vma, page, addr,
 						  maddr + offset, buf, bytes);
-				set_page_dirty_lock(page);
+				set_page_dirty_lock(NULL, page);
 			} else {
 				copy_from_user_page(vma, page, addr,
 						    buf, maddr + offset, bytes);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d8856be8cc70..eaa6c23ba752 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2594,7 +2594,7 @@ EXPORT_SYMBOL(set_page_dirty);
  *
  * In other cases, the page should be locked before running set_page_dirty().
  */
-int set_page_dirty_lock(struct page *page)
+int set_page_dirty_lock(struct address_space *_mapping, struct page *page)
 {
 	int ret;
 
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index a447092d4635..5a8ffa34c9e7 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -48,7 +48,7 @@ static int process_vm_rw_pages(struct page **pages,
 
 		if (vm_write) {
 			copied = copy_page_from_iter(page, offset, copy, iter);
-			set_page_dirty_lock(page);
+			set_page_dirty_lock(NULL, page);
 		} else {
 			copied = copy_page_to_iter(page, offset, copy, iter);
 		}
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index a3d0adc828e6..67ef02363a16 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -49,7 +49,7 @@ void ceph_put_page_vector(struct page **pages, int num_pages, bool dirty)
 
 	for (i = 0; i < num_pages; i++) {
 		if (dirty)
-			set_page_dirty_lock(pages[i]);
+			set_page_dirty_lock(NULL, pages[i]);
 		put_page(pages[i]);
 	}
 	kvfree(pages);
-- 
2.14.3
