Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFF0FC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E80D208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="b+MzHMUQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E80D208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC2CC6B0006; Wed, 14 Aug 2019 03:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7A1B6B0007; Wed, 14 Aug 2019 03:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEE7D6B0008; Wed, 14 Aug 2019 03:59:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id A07536B0006
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 03:59:42 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5ACB32C8B
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:42 +0000 (UTC)
X-FDA: 75820284204.27.work66_549e9536a8d45
X-HE-Tag: work66_549e9536a8d45
X-Filterd-Recvd-Size: 30067
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Go3ivFT762jDsG9LuzJRrEjuX4MNRycowFCEpdrDMsM=; b=b+MzHMUQi2Uf1C1oBuidJqC1q2
	YIW7zGncCOKaMI5JLZkSTBARnYww+0OmQ7AdAAZeKYiQpMGl215hneDAFP0Ttk2J56XogyEMttwvw
	yfFJ9cKguPz+z49JxvLNpq+WU1MeHllvK2u3u+ftcgXfe5XM1zU98sAAFkTEwC1CkdX/l5gzh0Fwx
	kFTG25LaJCKFnNhDU3uvxS7e8/mOgp6fwWPKSHQc42AQ/a2RWgbaKMwy2F2HqDgrJbICKy8q6y34O
	1onhQV92dQAQAP0CKakwhv5LxOdEVLTrJArLe1XxMY3GYujSLUlZnOOlzE1RLv5qHI14z8rd9GGAr
	N6G+ucuw==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hxoBy-0007wt-0f; Wed, 14 Aug 2019 07:59:34 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 01/10] mm: turn migrate_vma upside down
Date: Wed, 14 Aug 2019 09:59:19 +0200
Message-Id: <20190814075928.23766-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190814075928.23766-1-hch@lst.de>
References: <20190814075928.23766-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There isn't any good reason to pass callbacks to migrate_vma.  Instead
we can just export the three steps done by this function to drivers and
let them sequence the operation without callbacks.  This removes a lot
of boilerplate code as-is, and will allow the drivers to drastically
improve code flow and error handling further on.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 Documentation/vm/hmm.rst               |  55 +-----
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 122 +++++++------
 include/linux/migrate.h                | 118 ++----------
 mm/migrate.c                           | 244 +++++++++++--------------
 4 files changed, 195 insertions(+), 344 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index e63c11f7e0e0..4f81c77059e3 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -339,58 +339,9 @@ Migration to and from device memory
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 Because the CPU cannot access device memory, migration must use the devi=
ce DMA
-engine to perform copy from and to device memory. For this we need a new
-migration helper::
-
- int migrate_vma(const struct migrate_vma_ops *ops,
-                 struct vm_area_struct *vma,
-                 unsigned long mentries,
-                 unsigned long start,
-                 unsigned long end,
-                 unsigned long *src,
-                 unsigned long *dst,
-                 void *private);
-
-Unlike other migration functions it works on a range of virtual address,=
 there
-are two reasons for that. First, device DMA copy has a high setup overhe=
ad cost
-and thus batching multiple pages is needed as otherwise the migration ov=
erhead
-makes the whole exercise pointless. The second reason is because the
-migration might be for a range of addresses the device is actively acces=
sing.
-
-The migrate_vma_ops struct defines two callbacks. First one (alloc_and_c=
opy())
-controls destination memory allocation and copy operation. Second one is=
 there
-to allow the device driver to perform cleanup operations after migration=
::
-
- struct migrate_vma_ops {
-     void (*alloc_and_copy)(struct vm_area_struct *vma,
-                            const unsigned long *src,
-                            unsigned long *dst,
-                            unsigned long start,
-                            unsigned long end,
-                            void *private);
-     void (*finalize_and_map)(struct vm_area_struct *vma,
-                              const unsigned long *src,
-                              const unsigned long *dst,
-                              unsigned long start,
-                              unsigned long end,
-                              void *private);
- };
-
-It is important to stress that these migration helpers allow for holes i=
n the
-virtual address range. Some pages in the range might not be migrated for=
 all
-the usual reasons (page is pinned, page is locked, ...). This helper doe=
s not
-fail but just skips over those pages.
-
-The alloc_and_copy() might decide to not migrate all pages in the
-range (for reasons under the callback control). For those, the callback =
just
-has to leave the corresponding dst entry empty.
-
-Finally, the migration of the struct page might fail (for file backed pa=
ge) for
-various reasons (failure to freeze reference, or update page cache, ...)=
. If
-that happens, then the finalize_and_map() can catch any pages that were =
not
-migrated. Note those pages were still copied to a new page and thus we w=
asted
-bandwidth but this is considered as a rare event and a price that we are
-willing to pay to keep all the code simpler.
+engine to perform copy from and to device memory. For this we need a new=
 to
+use migrate_vma_setup(), migrate_vma_pages(), and migrate_vma_finalize()
+helpers.
=20
=20
 Memory cgroup (memcg) and rss accounting
diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nou=
veau/nouveau_dmem.c
index 345c63cb752a..38416798abd4 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -131,9 +131,8 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_stru=
ct *vma,
 				  unsigned long *dst_pfns,
 				  unsigned long start,
 				  unsigned long end,
-				  void *private)
+				  struct nouveau_dmem_fault *fault)
 {
-	struct nouveau_dmem_fault *fault =3D private;
 	struct nouveau_drm *drm =3D fault->drm;
 	struct device *dev =3D drm->dev->dev;
 	unsigned long addr, i, npages =3D 0;
@@ -230,14 +229,9 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_str=
uct *vma,
 	}
 }
=20
-void nouveau_dmem_fault_finalize_and_map(struct vm_area_struct *vma,
-					 const unsigned long *src_pfns,
-					 const unsigned long *dst_pfns,
-					 unsigned long start,
-					 unsigned long end,
-					 void *private)
+static void
+nouveau_dmem_fault_finalize_and_map(struct nouveau_dmem_fault *fault)
 {
-	struct nouveau_dmem_fault *fault =3D private;
 	struct nouveau_drm *drm =3D fault->drm;
=20
 	if (fault->fence) {
@@ -257,29 +251,35 @@ void nouveau_dmem_fault_finalize_and_map(struct vm_=
area_struct *vma,
 	kfree(fault->dma);
 }
=20
-static const struct migrate_vma_ops nouveau_dmem_fault_migrate_ops =3D {
-	.alloc_and_copy		=3D nouveau_dmem_fault_alloc_and_copy,
-	.finalize_and_map	=3D nouveau_dmem_fault_finalize_and_map,
-};
-
 static vm_fault_t nouveau_dmem_migrate_to_ram(struct vm_fault *vmf)
 {
 	struct nouveau_dmem *dmem =3D page_to_dmem(vmf->page);
 	unsigned long src[1] =3D {0}, dst[1] =3D {0};
+	struct migrate_vma args =3D {
+		.vma		=3D vmf->vma,
+		.start		=3D vmf->address,
+		.end		=3D vmf->address + PAGE_SIZE,
+		.src		=3D src,
+		.dst		=3D dst,
+	};
 	struct nouveau_dmem_fault fault =3D { .drm =3D dmem->drm };
-	int ret;
=20
 	/*
 	 * FIXME what we really want is to find some heuristic to migrate more
 	 * than just one page on CPU fault. When such fault happens it is very
 	 * likely that more surrounding page will CPU fault too.
 	 */
-	ret =3D migrate_vma(&nouveau_dmem_fault_migrate_ops, vmf->vma,
-			vmf->address, vmf->address + PAGE_SIZE,
-			src, dst, &fault);
-	if (ret)
+	if (migrate_vma_setup(&args) < 0)
 		return VM_FAULT_SIGBUS;
+	if (!args.cpages)
+		return 0;
+
+	nouveau_dmem_fault_alloc_and_copy(args.vma, src, dst, args.start,
+			args.end, &fault);
+	migrate_vma_pages(&args);
+	nouveau_dmem_fault_finalize_and_map(&fault);
=20
+	migrate_vma_finalize(&args);
 	if (dst[0] =3D=3D MIGRATE_PFN_ERROR)
 		return VM_FAULT_SIGBUS;
=20
@@ -648,9 +648,8 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_st=
ruct *vma,
 				    unsigned long *dst_pfns,
 				    unsigned long start,
 				    unsigned long end,
-				    void *private)
+				    struct nouveau_migrate *migrate)
 {
-	struct nouveau_migrate *migrate =3D private;
 	struct nouveau_drm *drm =3D migrate->drm;
 	struct device *dev =3D drm->dev->dev;
 	unsigned long addr, i, npages =3D 0;
@@ -747,14 +746,9 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_s=
truct *vma,
 	}
 }
=20
-void nouveau_dmem_migrate_finalize_and_map(struct vm_area_struct *vma,
-					   const unsigned long *src_pfns,
-					   const unsigned long *dst_pfns,
-					   unsigned long start,
-					   unsigned long end,
-					   void *private)
+static void
+nouveau_dmem_migrate_finalize_and_map(struct nouveau_migrate *migrate)
 {
-	struct nouveau_migrate *migrate =3D private;
 	struct nouveau_drm *drm =3D migrate->drm;
=20
 	if (migrate->fence) {
@@ -779,10 +773,15 @@ void nouveau_dmem_migrate_finalize_and_map(struct v=
m_area_struct *vma,
 	 */
 }
=20
-static const struct migrate_vma_ops nouveau_dmem_migrate_ops =3D {
-	.alloc_and_copy		=3D nouveau_dmem_migrate_alloc_and_copy,
-	.finalize_and_map	=3D nouveau_dmem_migrate_finalize_and_map,
-};
+static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
+		struct nouveau_migrate *migrate)
+{
+	nouveau_dmem_migrate_alloc_and_copy(args->vma, args->src, args->dst,
+			args->start, args->end, migrate);
+	migrate_vma_pages(args);
+	nouveau_dmem_migrate_finalize_and_map(migrate);
+	migrate_vma_finalize(args);
+}
=20
 int
 nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
@@ -790,40 +789,45 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
 			 unsigned long start,
 			 unsigned long end)
 {
-	unsigned long *src_pfns, *dst_pfns, npages;
-	struct nouveau_migrate migrate =3D {0};
-	unsigned long i, c, max;
-	int ret =3D 0;
-
-	npages =3D (end - start) >> PAGE_SHIFT;
-	max =3D min(SG_MAX_SINGLE_ALLOC, npages);
-	src_pfns =3D kzalloc(sizeof(long) * max, GFP_KERNEL);
-	if (src_pfns =3D=3D NULL)
-		return -ENOMEM;
-	dst_pfns =3D kzalloc(sizeof(long) * max, GFP_KERNEL);
-	if (dst_pfns =3D=3D NULL) {
-		kfree(src_pfns);
-		return -ENOMEM;
-	}
+	unsigned long npages =3D (end - start) >> PAGE_SHIFT;
+	unsigned long max =3D min(SG_MAX_SINGLE_ALLOC, npages);
+	struct migrate_vma args =3D {
+		.vma		=3D vma,
+		.start		=3D start,
+	};
+	struct nouveau_migrate migrate =3D {
+		.drm		=3D drm,
+		.vma		=3D vma,
+		.npages		=3D npages,
+	};
+	unsigned long c, i;
+	int ret =3D -ENOMEM;
+
+	args.src =3D kzalloc(sizeof(long) * max, GFP_KERNEL);
+	if (!args.src)
+		goto out;
+	args.dst =3D kzalloc(sizeof(long) * max, GFP_KERNEL);
+	if (!args.dst)
+		goto out_free_src;
=20
-	migrate.drm =3D drm;
-	migrate.vma =3D vma;
-	migrate.npages =3D npages;
 	for (i =3D 0; i < npages; i +=3D c) {
-		unsigned long next;
-
 		c =3D min(SG_MAX_SINGLE_ALLOC, npages);
-		next =3D start + (c << PAGE_SHIFT);
-		ret =3D migrate_vma(&nouveau_dmem_migrate_ops, vma, start,
-				  next, src_pfns, dst_pfns, &migrate);
+		args.end =3D start + (c << PAGE_SHIFT);
+		ret =3D migrate_vma_setup(&args);
 		if (ret)
-			goto out;
-		start =3D next;
+			goto out_free_dst;
+
+		if (args.cpages)
+			nouveau_dmem_migrate_chunk(&args, &migrate);
+		args.start =3D args.end;
 	}
=20
+	ret =3D 0;
+out_free_dst:
+	kfree(args.dst);
+out_free_src:
+	kfree(args.src);
 out:
-	kfree(dst_pfns);
-	kfree(src_pfns);
 	return ret;
 }
=20
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 7f04754c7f2b..18156d379ebf 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -182,107 +182,27 @@ static inline unsigned long migrate_pfn(unsigned l=
ong pfn)
 	return (pfn << MIGRATE_PFN_SHIFT) | MIGRATE_PFN_VALID;
 }
=20
-/*
- * struct migrate_vma_ops - migrate operation callback
- *
- * @alloc_and_copy: alloc destination memory and copy source memory to i=
t
- * @finalize_and_map: allow caller to map the successfully migrated page=
s
- *
- *
- * The alloc_and_copy() callback happens once all source pages have been=
 locked,
- * unmapped and checked (checked whether pinned or not). All pages that =
can be
- * migrated will have an entry in the src array set with the pfn value o=
f the
- * page and with the MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag set =
(other
- * flags might be set but should be ignored by the callback).
- *
- * The alloc_and_copy() callback can then allocate destination memory an=
d copy
- * source memory to it for all those entries (ie with MIGRATE_PFN_VALID =
and
- * MIGRATE_PFN_MIGRATE flag set). Once these are allocated and copied, t=
he
- * callback must update each corresponding entry in the dst array with t=
he pfn
- * value of the destination page and with the MIGRATE_PFN_VALID and
- * MIGRATE_PFN_LOCKED flags set (destination pages must have their struc=
t pages
- * locked, via lock_page()).
- *
- * At this point the alloc_and_copy() callback is done and returns.
- *
- * Note that the callback does not have to migrate all the pages that ar=
e
- * marked with MIGRATE_PFN_MIGRATE flag in src array unless this is a mi=
gration
- * from device memory to system memory (ie the MIGRATE_PFN_DEVICE flag i=
s also
- * set in the src array entry). If the device driver cannot migrate a de=
vice
- * page back to system memory, then it must set the corresponding dst ar=
ray
- * entry to MIGRATE_PFN_ERROR. This will trigger a SIGBUS if CPU tries t=
o
- * access any of the virtual addresses originally backed by this page. B=
ecause
- * a SIGBUS is such a severe result for the userspace process, the devic=
e
- * driver should avoid setting MIGRATE_PFN_ERROR unless it is really in =
an
- * unrecoverable state.
- *
- * For empty entry inside CPU page table (pte_none() or pmd_none() is tr=
ue) we
- * do set MIGRATE_PFN_MIGRATE flag inside the corresponding source array=
 thus
- * allowing device driver to allocate device memory for those unback vir=
tual
- * address. For this the device driver simply have to allocate device me=
mory
- * and properly set the destination entry like for regular migration. No=
te that
- * this can still fails and thus inside the device driver must check if =
the
- * migration was successful for those entry inside the finalize_and_map(=
)
- * callback just like for regular migration.
- *
- * THE alloc_and_copy() CALLBACK MUST NOT CHANGE ANY OF THE SRC ARRAY EN=
TRIES
- * OR BAD THINGS WILL HAPPEN !
- *
- *
- * The finalize_and_map() callback happens after struct page migration f=
rom
- * source to destination (destination struct pages are the struct pages =
for the
- * memory allocated by the alloc_and_copy() callback).  Migration can fa=
il, and
- * thus the finalize_and_map() allows the driver to inspect which pages =
were
- * successfully migrated, and which were not. Successfully migrated page=
s will
- * have the MIGRATE_PFN_MIGRATE flag set for their src array entry.
- *
- * It is safe to update device page table from within the finalize_and_m=
ap()
- * callback because both destination and source page are still locked, a=
nd the
- * mmap_sem is held in read mode (hence no one can unmap the range being
- * migrated).
- *
- * Once callback is done cleaning up things and updating its page table =
(if it
- * chose to do so, this is not an obligation) then it returns. At this p=
oint,
- * the HMM core will finish up the final steps, and the migration is com=
plete.
- *
- * THE finalize_and_map() CALLBACK MUST NOT CHANGE ANY OF THE SRC OR DST=
 ARRAY
- * ENTRIES OR BAD THINGS WILL HAPPEN !
- */
-struct migrate_vma_ops {
-	void (*alloc_and_copy)(struct vm_area_struct *vma,
-			       const unsigned long *src,
-			       unsigned long *dst,
-			       unsigned long start,
-			       unsigned long end,
-			       void *private);
-	void (*finalize_and_map)(struct vm_area_struct *vma,
-				 const unsigned long *src,
-				 const unsigned long *dst,
-				 unsigned long start,
-				 unsigned long end,
-				 void *private);
+struct migrate_vma {
+	struct vm_area_struct	*vma;
+	/*
+	 * Both src and dst array must be big enough for
+	 * (end - start) >> PAGE_SHIFT entries.
+	 *
+	 * The src array must not be modified by the caller after
+	 * migrate_vma_setup(), and must not change the dst array after
+	 * migrate_vma_pages() returns.
+	 */
+	unsigned long		*dst;
+	unsigned long		*src;
+	unsigned long		cpages;
+	unsigned long		npages;
+	unsigned long		start;
+	unsigned long		end;
 };
=20
-#if defined(CONFIG_MIGRATE_VMA_HELPER)
-int migrate_vma(const struct migrate_vma_ops *ops,
-		struct vm_area_struct *vma,
-		unsigned long start,
-		unsigned long end,
-		unsigned long *src,
-		unsigned long *dst,
-		void *private);
-#else
-static inline int migrate_vma(const struct migrate_vma_ops *ops,
-			      struct vm_area_struct *vma,
-			      unsigned long start,
-			      unsigned long end,
-			      unsigned long *src,
-			      unsigned long *dst,
-			      void *private)
-{
-	return -EINVAL;
-}
-#endif /* IS_ENABLED(CONFIG_MIGRATE_VMA_HELPER) */
+int migrate_vma_setup(struct migrate_vma *args);
+void migrate_vma_pages(struct migrate_vma *migrate);
+void migrate_vma_finalize(struct migrate_vma *migrate);
=20
 #endif /* CONFIG_MIGRATION */
=20
diff --git a/mm/migrate.c b/mm/migrate.c
index 8992741f10aa..e2565374d330 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2118,16 +2118,6 @@ int migrate_misplaced_transhuge_page(struct mm_str=
uct *mm,
 #endif /* CONFIG_NUMA */
=20
 #if defined(CONFIG_MIGRATE_VMA_HELPER)
-struct migrate_vma {
-	struct vm_area_struct	*vma;
-	unsigned long		*dst;
-	unsigned long		*src;
-	unsigned long		cpages;
-	unsigned long		npages;
-	unsigned long		start;
-	unsigned long		end;
-};
-
 static int migrate_vma_collect_hole(unsigned long start,
 				    unsigned long end,
 				    struct mm_walk *walk)
@@ -2578,6 +2568,110 @@ static void migrate_vma_unmap(struct migrate_vma =
*migrate)
 	}
 }
=20
+/**
+ * migrate_vma_setup() - prepare to migrate a range of memory
+ * @args: contains the vma, start, and and pfns arrays for the migration
+ *
+ * Returns: negative errno on failures, 0 when 0 or more pages were migr=
ated
+ * without an error.
+ *
+ * Prepare to migrate a range of memory virtual address range by collect=
ing all
+ * the pages backing each virtual address in the range, saving them insi=
de the
+ * src array.  Then lock those pages and unmap them. Once the pages are =
locked
+ * and unmapped, check whether each page is pinned or not.  Pages that a=
ren't
+ * pinned have the MIGRATE_PFN_MIGRATE flag set (by this function) in th=
e
+ * corresponding src array entry.  Then restores any pages that are pinn=
ed, by
+ * remapping and unlocking those pages.
+ *
+ * The caller should then allocate destination memory and copy source me=
mory to
+ * it for all those entries (ie with MIGRATE_PFN_VALID and MIGRATE_PFN_M=
IGRATE
+ * flag set).  Once these are allocated and copied, the caller must upda=
te each
+ * corresponding entry in the dst array with the pfn value of the destin=
ation
+ * page and with the MIGRATE_PFN_VALID and MIGRATE_PFN_LOCKED flags set
+ * (destination pages must have their struct pages locked, via lock_page=
()).
+ *
+ * Note that the caller does not have to migrate all the pages that are =
marked
+ * with MIGRATE_PFN_MIGRATE flag in src array unless this is a migration=
 from
+ * device memory to system memory.  If the caller cannot migrate a devic=
e page
+ * back to system memory, then it must return VM_FAULT_SIGBUS, which has=
 severe
+ * consequences for the userspace process, so it must be avoided if at a=
ll
+ * possible.
+ *
+ * For empty entries inside CPU page table (pte_none() or pmd_none() is =
true) we
+ * do set MIGRATE_PFN_MIGRATE flag inside the corresponding source array=
 thus
+ * allowing the caller to allocate device memory for those unback virtua=
l
+ * address.  For this the caller simply has to allocate device memory an=
d
+ * properly set the destination entry like for regular migration.  Note =
that
+ * this can still fails and thus inside the device driver must check if =
the
+ * migration was successful for those entries after calling migrate_vma_=
pages()
+ * just like for regular migration.
+ *
+ * After that, the callers must call migrate_vma_pages() to go over each=
 entry
+ * in the src array that has the MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRA=
TE flag
+ * set. If the corresponding entry in dst array has MIGRATE_PFN_VALID fl=
ag set,
+ * then migrate_vma_pages() to migrate struct page information from the =
source
+ * struct page to the destination struct page.  If it fails to migrate t=
he
+ * struct page information, then it clears the MIGRATE_PFN_MIGRATE flag =
in the
+ * src array.
+ *
+ * At this point all successfully migrated pages have an entry in the sr=
c
+ * array with MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag set and the=
 dst
+ * array entry with MIGRATE_PFN_VALID flag set.
+ *
+ * Once migrate_vma_pages() returns the caller may inspect which pages w=
ere
+ * successfully migrated, and which were not.  Successfully migrated pag=
es will
+ * have the MIGRATE_PFN_MIGRATE flag set for their src array entry.
+ *
+ * It is safe to update device page table from within the finalize_and_m=
ap()
+ * callback because both destination and source page are still locked, a=
nd the
+ * mmap_sem is held in read mode (hence no one can unmap the range being
+ * migrated).
+ *
+ * Once the caller is done cleaning up things and updating its page tabl=
e (if it
+ * chose to do so, this is not an obligation) it finally calls
+ * migrate_vma_finalize() to update the CPU page table to point to new p=
ages
+ * for successfully migrated pages or otherwise restore the CPU page tab=
le to
+ * point to the original source pages.
+ */
+int migrate_vma_setup(struct migrate_vma *args)
+{
+	long nr_pages =3D (args->end - args->start) >> PAGE_SHIFT;
+
+	args->start &=3D PAGE_MASK;
+	args->end &=3D PAGE_MASK;
+	if (!args->vma || is_vm_hugetlb_page(args->vma) ||
+	    (args->vma->vm_flags & VM_SPECIAL) || vma_is_dax(args->vma))
+		return -EINVAL;
+	if (nr_pages <=3D 0)
+		return -EINVAL;
+	if (args->start < args->vma->vm_start ||
+	    args->start >=3D args->vma->vm_end)
+		return -EINVAL;
+	if (args->end <=3D args->vma->vm_start || args->end > args->vma->vm_end=
)
+		return -EINVAL;
+	if (!args->src || !args->dst)
+		return -EINVAL;
+
+	memset(args->src, 0, sizeof(*args->src) * nr_pages);
+	args->cpages =3D 0;
+	args->npages =3D 0;
+
+	migrate_vma_collect(args);
+	if (args->cpages)
+		migrate_vma_prepare(args);
+	if (args->cpages)
+		migrate_vma_unmap(args);
+
+	/*
+	 * At this point pages are locked and unmapped, and thus they have
+	 * stable content and can safely be copied to destination memory that
+	 * is allocated by the drivers.
+	 */
+	return 0;
+
+}
+EXPORT_SYMBOL(migrate_vma_setup);
+
 static void migrate_vma_insert_page(struct migrate_vma *migrate,
 				    unsigned long addr,
 				    struct page *page,
@@ -2709,7 +2803,7 @@ static void migrate_vma_insert_page(struct migrate_=
vma *migrate,
 	*src &=3D ~MIGRATE_PFN_MIGRATE;
 }
=20
-/*
+/**
  * migrate_vma_pages() - migrate meta-data from src page to dst page
  * @migrate: migrate struct containing all migration information
  *
@@ -2717,7 +2811,7 @@ static void migrate_vma_insert_page(struct migrate_=
vma *migrate,
  * struct page. This effectively finishes the migration from source page=
 to the
  * destination page.
  */
-static void migrate_vma_pages(struct migrate_vma *migrate)
+void migrate_vma_pages(struct migrate_vma *migrate)
 {
 	const unsigned long npages =3D migrate->npages;
 	const unsigned long start =3D migrate->start;
@@ -2791,8 +2885,9 @@ static void migrate_vma_pages(struct migrate_vma *m=
igrate)
 	if (notified)
 		mmu_notifier_invalidate_range_only_end(&range);
 }
+EXPORT_SYMBOL(migrate_vma_pages);
=20
-/*
+/**
  * migrate_vma_finalize() - restore CPU page table entry
  * @migrate: migrate struct containing all migration information
  *
@@ -2803,7 +2898,7 @@ static void migrate_vma_pages(struct migrate_vma *m=
igrate)
  * This also unlocks the pages and puts them back on the lru, or drops t=
he extra
  * refcount, for device pages.
  */
-static void migrate_vma_finalize(struct migrate_vma *migrate)
+void migrate_vma_finalize(struct migrate_vma *migrate)
 {
 	const unsigned long npages =3D migrate->npages;
 	unsigned long i;
@@ -2846,124 +2941,5 @@ static void migrate_vma_finalize(struct migrate_v=
ma *migrate)
 		}
 	}
 }
-
-/*
- * migrate_vma() - migrate a range of memory inside vma
- *
- * @ops: migration callback for allocating destination memory and copyin=
g
- * @vma: virtual memory area containing the range to be migrated
- * @start: start address of the range to migrate (inclusive)
- * @end: end address of the range to migrate (exclusive)
- * @src: array of hmm_pfn_t containing source pfns
- * @dst: array of hmm_pfn_t containing destination pfns
- * @private: pointer passed back to each of the callback
- * Returns: 0 on success, error code otherwise
- *
- * This function tries to migrate a range of memory virtual address rang=
e, using
- * callbacks to allocate and copy memory from source to destination. Fir=
st it
- * collects all the pages backing each virtual address in the range, sav=
ing this
- * inside the src array. Then it locks those pages and unmaps them. Once=
 the pages
- * are locked and unmapped, it checks whether each page is pinned or not=
. Pages
- * that aren't pinned have the MIGRATE_PFN_MIGRATE flag set (by this fun=
ction)
- * in the corresponding src array entry. It then restores any pages that=
 are
- * pinned, by remapping and unlocking those pages.
- *
- * At this point it calls the alloc_and_copy() callback. For documentati=
on on
- * what is expected from that callback, see struct migrate_vma_ops comme=
nts in
- * include/linux/migrate.h
- *
- * After the alloc_and_copy() callback, this function goes over each ent=
ry in
- * the src array that has the MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE =
flag
- * set. If the corresponding entry in dst array has MIGRATE_PFN_VALID fl=
ag set,
- * then the function tries to migrate struct page information from the s=
ource
- * struct page to the destination struct page. If it fails to migrate th=
e struct
- * page information, then it clears the MIGRATE_PFN_MIGRATE flag in the =
src
- * array.
- *
- * At this point all successfully migrated pages have an entry in the sr=
c
- * array with MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag set and the=
 dst
- * array entry with MIGRATE_PFN_VALID flag set.
- *
- * It then calls the finalize_and_map() callback. See comments for "stru=
ct
- * migrate_vma_ops", in include/linux/migrate.h for details about
- * finalize_and_map() behavior.
- *
- * After the finalize_and_map() callback, for successfully migrated page=
s, this
- * function updates the CPU page table to point to new pages, otherwise =
it
- * restores the CPU page table to point to the original source pages.
- *
- * Function returns 0 after the above steps, even if no pages were migra=
ted
- * (The function only returns an error if any of the arguments are inval=
id.)
- *
- * Both src and dst array must be big enough for (end - start) >> PAGE_S=
HIFT
- * unsigned long entries.
- */
-int migrate_vma(const struct migrate_vma_ops *ops,
-		struct vm_area_struct *vma,
-		unsigned long start,
-		unsigned long end,
-		unsigned long *src,
-		unsigned long *dst,
-		void *private)
-{
-	struct migrate_vma migrate;
-
-	/* Sanity check the arguments */
-	start &=3D PAGE_MASK;
-	end &=3D PAGE_MASK;
-	if (!vma || is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
-			vma_is_dax(vma))
-		return -EINVAL;
-	if (start < vma->vm_start || start >=3D vma->vm_end)
-		return -EINVAL;
-	if (end <=3D vma->vm_start || end > vma->vm_end)
-		return -EINVAL;
-	if (!ops || !src || !dst || start >=3D end)
-		return -EINVAL;
-
-	memset(src, 0, sizeof(*src) * ((end - start) >> PAGE_SHIFT));
-	migrate.src =3D src;
-	migrate.dst =3D dst;
-	migrate.start =3D start;
-	migrate.npages =3D 0;
-	migrate.cpages =3D 0;
-	migrate.end =3D end;
-	migrate.vma =3D vma;
-
-	/* Collect, and try to unmap source pages */
-	migrate_vma_collect(&migrate);
-	if (!migrate.cpages)
-		return 0;
-
-	/* Lock and isolate page */
-	migrate_vma_prepare(&migrate);
-	if (!migrate.cpages)
-		return 0;
-
-	/* Unmap pages */
-	migrate_vma_unmap(&migrate);
-	if (!migrate.cpages)
-		return 0;
-
-	/*
-	 * At this point pages are locked and unmapped, and thus they have
-	 * stable content and can safely be copied to destination memory that
-	 * is allocated by the callback.
-	 *
-	 * Note that migration can fail in migrate_vma_struct_page() for each
-	 * individual page.
-	 */
-	ops->alloc_and_copy(vma, src, dst, start, end, private);
-
-	/* This does the real migration of struct page */
-	migrate_vma_pages(&migrate);
-
-	ops->finalize_and_map(vma, src, dst, start, end, private);
-
-	/* Unlock and remap pages */
-	migrate_vma_finalize(&migrate);
-
-	return 0;
-}
-EXPORT_SYMBOL(migrate_vma);
+EXPORT_SYMBOL(migrate_vma_finalize);
 #endif /* defined(MIGRATE_VMA_HELPER) */
--=20
2.20.1


