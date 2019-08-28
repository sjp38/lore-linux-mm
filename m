Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0CFCC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:42:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41F332064A
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:42:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nQifeTpn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41F332064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E546F6B000E; Wed, 28 Aug 2019 10:42:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E074F6B0010; Wed, 28 Aug 2019 10:42:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C57136B0269; Wed, 28 Aug 2019 10:42:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0095.hostedemail.com [216.40.44.95])
	by kanga.kvack.org (Postfix) with ESMTP id 903A16B000E
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:42:53 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 29408181AC9AE
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:42:53 +0000 (UTC)
X-FDA: 75872103426.02.swim13_362566e0b614c
X-HE-Tag: swim13_362566e0b614c
X-Filterd-Recvd-Size: 39945
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:42:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=fQpZHi+0z011qDiVUw4N3lwCrCbPtI4NsOYWVayxfgA=; b=nQifeTpnTVLznv3C1CPX1gdPlj
	8D72RVN66fLrNFk6GJFm9XUwSo/il4lH4eOFm+RqbA92dFY2BxhYNZDHboVKGdXgMUJlL2OC0miaR
	F+qudr6U6Q0ufYvMXvz5cpBxjx3solML+/GNn++5pbSEpwM+7vnDuqw+if8EYMf6bXh7AbKufue73
	B5oYU9Alp4F+009lY4AoPp4otFdGFN5Bzh2Apti425o0Dm7jTtbE3EW9SbDckMot6BBIGGfuF1WW6
	A83dz692joJafJm4fXzHN28ccpZziYGG11jtfNCH8P6y7dF7GPtrgPDUomm8cv5gNHshtx+7F4QhN
	VrVGT/ow==;
Received: from [2001:4bb8:180:3f4c:863:2ead:e9d4:da9f] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i2ynr-0003zE-CY; Wed, 28 Aug 2019 14:20:04 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?Thomas=20Hellstr=C3=B6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Thomas Hellstrom <thellstrom@vmware.com>
Subject: [PATCH 2/3] pagewalk: separate function pointers from iterator data
Date: Wed, 28 Aug 2019 16:19:54 +0200
Message-Id: <20190828141955.22210-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190828141955.22210-1-hch@lst.de>
References: <20190828141955.22210-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm_walk structure currently mixed data and code.  Split out the
operations vectors into a new mm_walk_ops structure, and while we
are changing the API also declare the mm_walk structure inside the
walk_page_range and walk_page_vma functions.

Based on patch from Linus Torvalds.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Steven Price <steven.price@arm.com>
---
 arch/openrisc/kernel/dma.c              |  22 +++--
 arch/powerpc/mm/book3s64/subpage_prot.c |  10 +-
 arch/s390/mm/gmap.c                     |  33 +++----
 fs/proc/task_mmu.c                      |  78 ++++++++-------
 include/linux/pagewalk.h                |  64 +++++++-----
 mm/hmm.c                                |  23 +++--
 mm/madvise.c                            |  41 +++-----
 mm/memcontrol.c                         |  23 +++--
 mm/mempolicy.c                          |  15 ++-
 mm/migrate.c                            |  23 +++--
 mm/mincore.c                            |  15 ++-
 mm/mprotect.c                           |  24 ++---
 mm/pagewalk.c                           | 124 ++++++++++++++----------
 13 files changed, 251 insertions(+), 244 deletions(-)

diff --git a/arch/openrisc/kernel/dma.c b/arch/openrisc/kernel/dma.c
index c7812e6effa2..4d5b8bd1d795 100644
--- a/arch/openrisc/kernel/dma.c
+++ b/arch/openrisc/kernel/dma.c
@@ -44,6 +44,10 @@ page_set_nocache(pte_t *pte, unsigned long addr,
 	return 0;
 }
=20
+static const struct mm_walk_ops set_nocache_walk_ops =3D {
+	.pte_entry		=3D page_set_nocache,
+};
+
 static int
 page_clear_nocache(pte_t *pte, unsigned long addr,
 		   unsigned long next, struct mm_walk *walk)
@@ -59,6 +63,10 @@ page_clear_nocache(pte_t *pte, unsigned long addr,
 	return 0;
 }
=20
+static const struct mm_walk_ops clear_nocache_walk_ops =3D {
+	.pte_entry		=3D page_clear_nocache,
+};
+
 /*
  * Alloc "coherent" memory, which for OpenRISC means simply uncached.
  *
@@ -81,10 +89,6 @@ arch_dma_alloc(struct device *dev, size_t size, dma_ad=
dr_t *dma_handle,
 {
 	unsigned long va;
 	void *page;
-	struct mm_walk walk =3D {
-		.pte_entry =3D page_set_nocache,
-		.mm =3D &init_mm
-	};
=20
 	page =3D alloc_pages_exact(size, gfp | __GFP_ZERO);
 	if (!page)
@@ -99,7 +103,8 @@ arch_dma_alloc(struct device *dev, size_t size, dma_ad=
dr_t *dma_handle,
 	 * We need to iterate through the pages, clearing the dcache for
 	 * them and setting the cache-inhibit bit.
 	 */
-	if (walk_page_range(va, va + size, &walk)) {
+	if (walk_page_range(&init_mm, va, va + size, &set_nocache_walk_ops,
+			NULL)) {
 		free_pages_exact(page, size);
 		return NULL;
 	}
@@ -112,13 +117,10 @@ arch_dma_free(struct device *dev, size_t size, void=
 *vaddr,
 		dma_addr_t dma_handle, unsigned long attrs)
 {
 	unsigned long va =3D (unsigned long)vaddr;
-	struct mm_walk walk =3D {
-		.pte_entry =3D page_clear_nocache,
-		.mm =3D &init_mm
-	};
=20
 	/* walk_page_range shouldn't be able to fail here */
-	WARN_ON(walk_page_range(va, va + size, &walk));
+	WARN_ON(walk_page_range(&init_mm, va, va + size,
+			&clear_nocache_walk_ops, NULL));
=20
 	free_pages_exact(vaddr, size);
 }
diff --git a/arch/powerpc/mm/book3s64/subpage_prot.c b/arch/powerpc/mm/bo=
ok3s64/subpage_prot.c
index 236f0a861ecc..2ef24a53f4c9 100644
--- a/arch/powerpc/mm/book3s64/subpage_prot.c
+++ b/arch/powerpc/mm/book3s64/subpage_prot.c
@@ -139,14 +139,14 @@ static int subpage_walk_pmd_entry(pmd_t *pmd, unsig=
ned long addr,
 	return 0;
 }
=20
+static const struct mm_walk_ops subpage_walk_ops =3D {
+	.pmd_entry	=3D subpage_walk_pmd_entry,
+};
+
 static void subpage_mark_vma_nohuge(struct mm_struct *mm, unsigned long =
addr,
 				    unsigned long len)
 {
 	struct vm_area_struct *vma;
-	struct mm_walk subpage_proto_walk =3D {
-		.mm =3D mm,
-		.pmd_entry =3D subpage_walk_pmd_entry,
-	};
=20
 	/*
 	 * We don't try too hard, we just mark all the vma in that range
@@ -163,7 +163,7 @@ static void subpage_mark_vma_nohuge(struct mm_struct =
*mm, unsigned long addr,
 		if (vma->vm_start >=3D (addr + len))
 			break;
 		vma->vm_flags |=3D VM_NOHUGEPAGE;
-		walk_page_vma(vma, &subpage_proto_walk);
+		walk_page_vma(vma, &subpage_walk_ops, NULL);
 		vma =3D vma->vm_next;
 	}
 }
diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index cf80feae970d..bd78d504fdad 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -2521,13 +2521,9 @@ static int __zap_zero_pages(pmd_t *pmd, unsigned l=
ong start,
 	return 0;
 }
=20
-static inline void zap_zero_pages(struct mm_struct *mm)
-{
-	struct mm_walk walk =3D { .pmd_entry =3D __zap_zero_pages };
-
-	walk.mm =3D mm;
-	walk_page_range(0, TASK_SIZE, &walk);
-}
+static const struct mm_walk_ops zap_zero_walk_ops =3D {
+	.pmd_entry	=3D __zap_zero_pages,
+};
=20
 /*
  * switch on pgstes for its userspace process (for kvm)
@@ -2546,7 +2542,7 @@ int s390_enable_sie(void)
 	mm->context.has_pgste =3D 1;
 	/* split thp mappings and disable thp for future mappings */
 	thp_split_mm(mm);
-	zap_zero_pages(mm);
+	walk_page_range(mm, 0, TASK_SIZE, &zap_zero_walk_ops, NULL);
 	up_write(&mm->mmap_sem);
 	return 0;
 }
@@ -2589,12 +2585,13 @@ static int __s390_enable_skey_hugetlb(pte_t *pte,=
 unsigned long addr,
 	return 0;
 }
=20
+static const struct mm_walk_ops enable_skey_walk_ops =3D {
+	.hugetlb_entry		=3D __s390_enable_skey_hugetlb,
+	.pte_entry		=3D __s390_enable_skey_pte,
+};
+
 int s390_enable_skey(void)
 {
-	struct mm_walk walk =3D {
-		.hugetlb_entry =3D __s390_enable_skey_hugetlb,
-		.pte_entry =3D __s390_enable_skey_pte,
-	};
 	struct mm_struct *mm =3D current->mm;
 	struct vm_area_struct *vma;
 	int rc =3D 0;
@@ -2614,8 +2611,7 @@ int s390_enable_skey(void)
 	}
 	mm->def_flags &=3D ~VM_MERGEABLE;
=20
-	walk.mm =3D mm;
-	walk_page_range(0, TASK_SIZE, &walk);
+	walk_page_range(mm, 0, TASK_SIZE, &enable_skey_walk_ops, NULL);
=20
 out_up:
 	up_write(&mm->mmap_sem);
@@ -2633,13 +2629,14 @@ static int __s390_reset_cmma(pte_t *pte, unsigned=
 long addr,
 	return 0;
 }
=20
+static const struct mm_walk_ops reset_cmma_walk_ops =3D {
+	.pte_entry		=3D __s390_reset_cmma,
+};
+
 void s390_reset_cmma(struct mm_struct *mm)
 {
-	struct mm_walk walk =3D { .pte_entry =3D __s390_reset_cmma };
-
 	down_write(&mm->mmap_sem);
-	walk.mm =3D mm;
-	walk_page_range(0, TASK_SIZE, &walk);
+	walk_page_range(mm, 0, TASK_SIZE, &reset_cmma_walk_ops, NULL);
 	up_write(&mm->mmap_sem);
 }
 EXPORT_SYMBOL_GPL(s390_reset_cmma);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8857da830b86..bf43d1d60059 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -513,7 +513,9 @@ static int smaps_pte_hole(unsigned long addr, unsigne=
d long end,
=20
 	return 0;
 }
-#endif
+#else
+#define smaps_pte_hole		NULL
+#endif /* CONFIG_SHMEM */
=20
 static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 		struct mm_walk *walk)
@@ -729,21 +731,24 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned=
 long hmask,
 	}
 	return 0;
 }
+#else
+#define smaps_hugetlb_range	NULL
 #endif /* HUGETLB_PAGE */
=20
+static const struct mm_walk_ops smaps_walk_ops =3D {
+	.pmd_entry		=3D smaps_pte_range,
+	.hugetlb_entry		=3D smaps_hugetlb_range,
+};
+
+static const struct mm_walk_ops smaps_shmem_walk_ops =3D {
+	.pmd_entry		=3D smaps_pte_range,
+	.hugetlb_entry		=3D smaps_hugetlb_range,
+	.pte_hole		=3D smaps_pte_hole,
+};
+
 static void smap_gather_stats(struct vm_area_struct *vma,
 			     struct mem_size_stats *mss)
 {
-	struct mm_walk smaps_walk =3D {
-		.pmd_entry =3D smaps_pte_range,
-#ifdef CONFIG_HUGETLB_PAGE
-		.hugetlb_entry =3D smaps_hugetlb_range,
-#endif
-		.mm =3D vma->vm_mm,
-	};
-
-	smaps_walk.private =3D mss;
-
 #ifdef CONFIG_SHMEM
 	/* In case of smaps_rollup, reset the value from previous vma */
 	mss->check_shmem_swap =3D false;
@@ -765,12 +770,13 @@ static void smap_gather_stats(struct vm_area_struct=
 *vma,
 			mss->swap +=3D shmem_swapped;
 		} else {
 			mss->check_shmem_swap =3D true;
-			smaps_walk.pte_hole =3D smaps_pte_hole;
+			walk_page_vma(vma, &smaps_shmem_walk_ops, mss);
+			return;
 		}
 	}
 #endif
 	/* mmap_sem is held in m_start */
-	walk_page_vma(vma, &smaps_walk);
+	walk_page_vma(vma, &smaps_walk_ops, mss);
 }
=20
 #define SEQ_PUT_DEC(str, val) \
@@ -1118,6 +1124,11 @@ static int clear_refs_test_walk(unsigned long star=
t, unsigned long end,
 	return 0;
 }
=20
+static const struct mm_walk_ops clear_refs_walk_ops =3D {
+	.pmd_entry		=3D clear_refs_pte_range,
+	.test_walk		=3D clear_refs_test_walk,
+};
+
 static ssize_t clear_refs_write(struct file *file, const char __user *bu=
f,
 				size_t count, loff_t *ppos)
 {
@@ -1151,12 +1162,6 @@ static ssize_t clear_refs_write(struct file *file,=
 const char __user *buf,
 		struct clear_refs_private cp =3D {
 			.type =3D type,
 		};
-		struct mm_walk clear_refs_walk =3D {
-			.pmd_entry =3D clear_refs_pte_range,
-			.test_walk =3D clear_refs_test_walk,
-			.mm =3D mm,
-			.private =3D &cp,
-		};
=20
 		if (type =3D=3D CLEAR_REFS_MM_HIWATER_RSS) {
 			if (down_write_killable(&mm->mmap_sem)) {
@@ -1217,7 +1222,8 @@ static ssize_t clear_refs_write(struct file *file, =
const char __user *buf,
 						0, NULL, mm, 0, -1UL);
 			mmu_notifier_invalidate_range_start(&range);
 		}
-		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
+		walk_page_range(mm, 0, mm->highest_vm_end, &clear_refs_walk_ops,
+				&cp);
 		if (type =3D=3D CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(&range);
 		tlb_finish_mmu(&tlb, 0, -1);
@@ -1489,8 +1495,16 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsi=
gned long hmask,
=20
 	return err;
 }
+#else
+#define pagemap_hugetlb_range	NULL
 #endif /* HUGETLB_PAGE */
=20
+static const struct mm_walk_ops pagemap_ops =3D {
+	.pmd_entry	=3D pagemap_pmd_range,
+	.pte_hole	=3D pagemap_pte_hole,
+	.hugetlb_entry	=3D pagemap_hugetlb_range,
+};
+
 /*
  * /proc/pid/pagemap - an array mapping virtual pages to pfns
  *
@@ -1522,7 +1536,6 @@ static ssize_t pagemap_read(struct file *file, char=
 __user *buf,
 {
 	struct mm_struct *mm =3D file->private_data;
 	struct pagemapread pm;
-	struct mm_walk pagemap_walk =3D {};
 	unsigned long src;
 	unsigned long svpfn;
 	unsigned long start_vaddr;
@@ -1550,14 +1563,6 @@ static ssize_t pagemap_read(struct file *file, cha=
r __user *buf,
 	if (!pm.buffer)
 		goto out_mm;
=20
-	pagemap_walk.pmd_entry =3D pagemap_pmd_range;
-	pagemap_walk.pte_hole =3D pagemap_pte_hole;
-#ifdef CONFIG_HUGETLB_PAGE
-	pagemap_walk.hugetlb_entry =3D pagemap_hugetlb_range;
-#endif
-	pagemap_walk.mm =3D mm;
-	pagemap_walk.private =3D &pm;
-
 	src =3D *ppos;
 	svpfn =3D src / PM_ENTRY_BYTES;
 	start_vaddr =3D svpfn << PAGE_SHIFT;
@@ -1586,7 +1591,7 @@ static ssize_t pagemap_read(struct file *file, char=
 __user *buf,
 		ret =3D down_read_killable(&mm->mmap_sem);
 		if (ret)
 			goto out_free;
-		ret =3D walk_page_range(start_vaddr, end, &pagemap_walk);
+		ret =3D walk_page_range(mm, start_vaddr, end, &pagemap_ops, &pm);
 		up_read(&mm->mmap_sem);
 		start_vaddr =3D end;
=20
@@ -1798,6 +1803,11 @@ static int gather_hugetlb_stats(pte_t *pte, unsign=
ed long hmask,
 }
 #endif
=20
+static const struct mm_walk_ops show_numa_ops =3D {
+	.hugetlb_entry =3D gather_hugetlb_stats,
+	.pmd_entry =3D gather_pte_stats,
+};
+
 /*
  * Display pages allocated per node and memory policy via /proc.
  */
@@ -1809,12 +1819,6 @@ static int show_numa_map(struct seq_file *m, void =
*v)
 	struct numa_maps *md =3D &numa_priv->md;
 	struct file *file =3D vma->vm_file;
 	struct mm_struct *mm =3D vma->vm_mm;
-	struct mm_walk walk =3D {
-		.hugetlb_entry =3D gather_hugetlb_stats,
-		.pmd_entry =3D gather_pte_stats,
-		.private =3D md,
-		.mm =3D mm,
-	};
 	struct mempolicy *pol;
 	char buffer[64];
 	int nid;
@@ -1848,7 +1852,7 @@ static int show_numa_map(struct seq_file *m, void *=
v)
 		seq_puts(m, " huge");
=20
 	/* mmap_sem is held by m_start */
-	walk_page_vma(vma, &walk);
+	walk_page_vma(vma, &show_numa_ops, md);
=20
 	if (!md->pages)
 		goto out;
diff --git a/include/linux/pagewalk.h b/include/linux/pagewalk.h
index df278a94086d..bddd9759bab9 100644
--- a/include/linux/pagewalk.h
+++ b/include/linux/pagewalk.h
@@ -4,31 +4,28 @@
=20
 #include <linux/mm.h>
=20
+struct mm_walk;
+
 /**
- * mm_walk - callbacks for walk_page_range
- * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
- *	       this handler should only handle pud_trans_huge() puds.
- *	       the pmd_entry or pte_entry callbacks will be used for
- *	       regular PUDs.
- * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
- *	       this handler is required to be able to handle
- *	       pmd_trans_huge() pmds.  They may simply choose to
- *	       split_huge_page() instead of handling it explicitly.
- * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
- * @pte_hole: if set, called for each hole at all levels
- * @hugetlb_entry: if set, called for each hugetlb entry
- * @test_walk: caller specific callback function to determine whether
- *             we walk over the current vma or not. Returning 0
- *             value means "do page table walk over the current vma,"
- *             and a negative one means "abort current page table walk
- *             right now." 1 means "skip the current vma."
- * @mm:        mm_struct representing the target process of page table w=
alk
- * @vma:       vma currently walked (NULL if walking outside vmas)
- * @private:   private data for callbacks' usage
- *
- * (see the comment on walk_page_range() for more details)
+ * mm_walk_ops - callbacks for walk_page_range
+ * @pud_entry:		if set, called for each non-empty PUD (2nd-level) entry
+ *			this handler should only handle pud_trans_huge() puds.
+ *			the pmd_entry or pte_entry callbacks will be used for
+ *			regular PUDs.
+ * @pmd_entry:		if set, called for each non-empty PMD (3rd-level) entry
+ *			this handler is required to be able to handle
+ *			pmd_trans_huge() pmds.  They may simply choose to
+ *			split_huge_page() instead of handling it explicitly.
+ * @pte_entry:		if set, called for each non-empty PTE (4th-level) entry
+ * @pte_hole:		if set, called for each hole at all levels
+ * @hugetlb_entry:	if set, called for each hugetlb entry
+ * @test_walk:		caller specific callback function to determine whether
+ *			we walk over the current vma or not. Returning 0 means
+ *			"do page table walk over the current vma", returning
+ *			a negative value means "abort current page table walk
+ *			right now" and returning 1 means "skip the current vma"
  */
-struct mm_walk {
+struct mm_walk_ops {
 	int (*pud_entry)(pud_t *pud, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
@@ -42,13 +39,28 @@ struct mm_walk {
 			     struct mm_walk *walk);
 	int (*test_walk)(unsigned long addr, unsigned long next,
 			struct mm_walk *walk);
+};
+
+/**
+ * mm_walk - walk_page_range data
+ * @ops:	operation to call during the walk
+ * @mm:		mm_struct representing the target process of page table walk
+ * @vma:	vma currently walked (NULL if walking outside vmas)
+ * @private:	private data for callbacks' usage
+ *
+ * (see the comment on walk_page_range() for more details)
+ */
+struct mm_walk {
+	const struct mm_walk_ops *ops;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	void *private;
 };
=20
-int walk_page_range(unsigned long addr, unsigned long end,
-		struct mm_walk *walk);
-int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
+int walk_page_range(struct mm_struct *mm, unsigned long start,
+		unsigned long end, const struct mm_walk_ops *ops,
+		void *private);
+int walk_page_vma(struct vm_area_struct *vma, const struct mm_walk_ops *=
ops,
+		void *private);
=20
 #endif /* _LINUX_PAGEWALK_H */
diff --git a/mm/hmm.c b/mm/hmm.c
index 26916ff6c8df..902f5fa6bf93 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -852,6 +852,13 @@ void hmm_range_unregister(struct hmm_range *range)
 }
 EXPORT_SYMBOL(hmm_range_unregister);
=20
+static const struct mm_walk_ops hmm_walk_ops =3D {
+	.pud_entry	=3D hmm_vma_walk_pud,
+	.pmd_entry	=3D hmm_vma_walk_pmd,
+	.pte_hole	=3D hmm_vma_walk_hole,
+	.hugetlb_entry	=3D hmm_vma_walk_hugetlb_entry,
+};
+
 /**
  * hmm_range_fault - try to fault some address in a virtual address rang=
e
  * @range:	range being faulted
@@ -887,7 +894,6 @@ long hmm_range_fault(struct hmm_range *range, unsigne=
d int flags)
 	struct hmm_vma_walk hmm_vma_walk;
 	struct hmm *hmm =3D range->hmm;
 	struct vm_area_struct *vma;
-	struct mm_walk mm_walk;
 	int ret;
=20
 	lockdep_assert_held(&hmm->mmu_notifier.mm->mmap_sem);
@@ -916,21 +922,14 @@ long hmm_range_fault(struct hmm_range *range, unsig=
ned int flags)
 		hmm_vma_walk.last =3D start;
 		hmm_vma_walk.flags =3D flags;
 		hmm_vma_walk.range =3D range;
-		mm_walk.private =3D &hmm_vma_walk;
 		end =3D min(range->end, vma->vm_end);
=20
-		mm_walk.vma =3D vma;
-		mm_walk.mm =3D vma->vm_mm;
-		mm_walk.pte_entry =3D NULL;
-		mm_walk.test_walk =3D NULL;
-		mm_walk.hugetlb_entry =3D NULL;
-		mm_walk.pud_entry =3D hmm_vma_walk_pud;
-		mm_walk.pmd_entry =3D hmm_vma_walk_pmd;
-		mm_walk.pte_hole =3D hmm_vma_walk_hole;
-		mm_walk.hugetlb_entry =3D hmm_vma_walk_hugetlb_entry;
+		walk_page_range(vma->vm_mm, start, end, &hmm_walk_ops,
+				&hmm_vma_walk);
=20
 		do {
-			ret =3D walk_page_range(start, end, &mm_walk);
+			ret =3D walk_page_range(vma->vm_mm, start, end,
+					&hmm_walk_ops, &hmm_vma_walk);
 			start =3D hmm_vma_walk.last;
=20
 			/* Keep trying while the range is valid. */
diff --git a/mm/madvise.c b/mm/madvise.c
index 80a78bb16782..afe2b015ea58 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -226,19 +226,9 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigne=
d long start,
 	return 0;
 }
=20
-static void force_swapin_readahead(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end)
-{
-	struct mm_walk walk =3D {
-		.mm =3D vma->vm_mm,
-		.pmd_entry =3D swapin_walk_pmd_entry,
-		.private =3D vma,
-	};
-
-	walk_page_range(start, end, &walk);
-
-	lru_add_drain();	/* Push any new pages onto the LRU now */
-}
+static const struct mm_walk_ops swapin_walk_ops =3D {
+	.pmd_entry		=3D swapin_walk_pmd_entry,
+};
=20
 static void force_shm_swapin_readahead(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end,
@@ -280,7 +270,8 @@ static long madvise_willneed(struct vm_area_struct *v=
ma,
 	*prev =3D vma;
 #ifdef CONFIG_SWAP
 	if (!file) {
-		force_swapin_readahead(vma, start, end);
+		walk_page_range(vma->vm_mm, start, end, &swapin_walk_ops, vma);
+		lru_add_drain(); /* Push any new pages onto the LRU now */
 		return 0;
 	}
=20
@@ -441,20 +432,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsign=
ed long addr,
 	return 0;
 }
=20
-static void madvise_free_page_range(struct mmu_gather *tlb,
-			     struct vm_area_struct *vma,
-			     unsigned long addr, unsigned long end)
-{
-	struct mm_walk free_walk =3D {
-		.pmd_entry =3D madvise_free_pte_range,
-		.mm =3D vma->vm_mm,
-		.private =3D tlb,
-	};
-
-	tlb_start_vma(tlb, vma);
-	walk_page_range(addr, end, &free_walk);
-	tlb_end_vma(tlb, vma);
-}
+static const struct mm_walk_ops madvise_free_walk_ops =3D {
+	.pmd_entry		=3D madvise_free_pte_range,
+};
=20
 static int madvise_free_single_vma(struct vm_area_struct *vma,
 			unsigned long start_addr, unsigned long end_addr)
@@ -481,7 +461,10 @@ static int madvise_free_single_vma(struct vm_area_st=
ruct *vma,
 	update_hiwater_rss(mm);
=20
 	mmu_notifier_invalidate_range_start(&range);
-	madvise_free_page_range(&tlb, vma, range.start, range.end);
+	tlb_start_vma(&tlb, vma);
+	walk_page_range(vma->vm_mm, range.start, range.end,
+			&madvise_free_walk_ops, &tlb);
+	tlb_end_vma(&tlb, vma);
 	mmu_notifier_invalidate_range_end(&range);
 	tlb_finish_mmu(&tlb, range.start, range.end);
=20
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4c3af5d71ab1..9b2516a76be2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5283,17 +5283,16 @@ static int mem_cgroup_count_precharge_pte_range(p=
md_t *pmd,
 	return 0;
 }
=20
+static const struct mm_walk_ops precharge_walk_ops =3D {
+	.pmd_entry	=3D mem_cgroup_count_precharge_pte_range,
+};
+
 static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 {
 	unsigned long precharge;
=20
-	struct mm_walk mem_cgroup_count_precharge_walk =3D {
-		.pmd_entry =3D mem_cgroup_count_precharge_pte_range,
-		.mm =3D mm,
-	};
 	down_read(&mm->mmap_sem);
-	walk_page_range(0, mm->highest_vm_end,
-			&mem_cgroup_count_precharge_walk);
+	walk_page_range(mm, 0, mm->highest_vm_end, &precharge_walk_ops, NULL);
 	up_read(&mm->mmap_sem);
=20
 	precharge =3D mc.precharge;
@@ -5562,13 +5561,12 @@ static int mem_cgroup_move_charge_pte_range(pmd_t=
 *pmd,
 	return ret;
 }
=20
+static const struct mm_walk_ops charge_walk_ops =3D {
+	.pmd_entry	=3D mem_cgroup_move_charge_pte_range,
+};
+
 static void mem_cgroup_move_charge(void)
 {
-	struct mm_walk mem_cgroup_move_charge_walk =3D {
-		.pmd_entry =3D mem_cgroup_move_charge_pte_range,
-		.mm =3D mc.mm,
-	};
-
 	lru_add_drain_all();
 	/*
 	 * Signal lock_page_memcg() to take the memcg's move_lock
@@ -5594,7 +5592,8 @@ static void mem_cgroup_move_charge(void)
 	 * When we have consumed all precharges and failed in doing
 	 * additional charge, the page walk just aborts.
 	 */
-	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk)=
;
+	walk_page_range(mc.mm, 0, mc.mm->highest_vm_end, &charge_walk_ops,
+			NULL);
=20
 	up_read(&mc.mm->mmap_sem);
 	atomic_dec(&mc.from->moving_account);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 3a96def1e796..f000771558d8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -655,6 +655,12 @@ static int queue_pages_test_walk(unsigned long start=
, unsigned long end,
 	return 1;
 }
=20
+static const struct mm_walk_ops queue_pages_walk_ops =3D {
+	.hugetlb_entry		=3D queue_pages_hugetlb,
+	.pmd_entry		=3D queue_pages_pte_range,
+	.test_walk		=3D queue_pages_test_walk,
+};
+
 /*
  * Walk through page tables and collect pages to be migrated.
  *
@@ -679,15 +685,8 @@ queue_pages_range(struct mm_struct *mm, unsigned lon=
g start, unsigned long end,
 		.nmask =3D nodes,
 		.prev =3D NULL,
 	};
-	struct mm_walk queue_pages_walk =3D {
-		.hugetlb_entry =3D queue_pages_hugetlb,
-		.pmd_entry =3D queue_pages_pte_range,
-		.test_walk =3D queue_pages_test_walk,
-		.mm =3D mm,
-		.private =3D &qp,
-	};
=20
-	return walk_page_range(start, end, &queue_pages_walk);
+	return walk_page_range(mm, start, end, &queue_pages_walk_ops, &qp);
 }
=20
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index c9c73a35aca7..9f4ed4e985c1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2320,6 +2320,11 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 	return 0;
 }
=20
+static const struct mm_walk_ops migrate_vma_walk_ops =3D {
+	.pmd_entry		=3D migrate_vma_collect_pmd,
+	.pte_hole		=3D migrate_vma_collect_hole,
+};
+
 /*
  * migrate_vma_collect() - collect pages over a range of virtual address=
es
  * @migrate: migrate struct containing all migration information
@@ -2331,21 +2336,15 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 static void migrate_vma_collect(struct migrate_vma *migrate)
 {
 	struct mmu_notifier_range range;
-	struct mm_walk mm_walk =3D {
-		.pmd_entry =3D migrate_vma_collect_pmd,
-		.pte_hole =3D migrate_vma_collect_hole,
-		.vma =3D migrate->vma,
-		.mm =3D migrate->vma->vm_mm,
-		.private =3D migrate,
-	};
=20
-	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm_walk.mm,
-				migrate->start,
-				migrate->end);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL,
+			migrate->vma->vm_mm, migrate->start, migrate->end);
 	mmu_notifier_invalidate_range_start(&range);
-	walk_page_range(migrate->start, migrate->end, &mm_walk);
-	mmu_notifier_invalidate_range_end(&range);
=20
+	walk_page_range(migrate->vma->vm_mm, migrate->start, migrate->end,
+			&migrate_vma_walk_ops, migrate);
+
+	mmu_notifier_invalidate_range_end(&range);
 	migrate->end =3D migrate->start + (migrate->npages << PAGE_SHIFT);
 }
=20
diff --git a/mm/mincore.c b/mm/mincore.c
index 3b051b6ab3fe..f9a9dbe8cd33 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -193,6 +193,12 @@ static inline bool can_do_mincore(struct vm_area_str=
uct *vma)
 		inode_permission(file_inode(vma->vm_file), MAY_WRITE) =3D=3D 0;
 }
=20
+static const struct mm_walk_ops mincore_walk_ops =3D {
+	.pmd_entry		=3D mincore_pte_range,
+	.pte_hole		=3D mincore_unmapped_range,
+	.hugetlb_entry		=3D mincore_hugetlb,
+};
+
 /*
  * Do a chunk of "sys_mincore()". We've already checked
  * all the arguments, we hold the mmap semaphore: we should
@@ -203,12 +209,6 @@ static long do_mincore(unsigned long addr, unsigned =
long pages, unsigned char *v
 	struct vm_area_struct *vma;
 	unsigned long end;
 	int err;
-	struct mm_walk mincore_walk =3D {
-		.pmd_entry =3D mincore_pte_range,
-		.pte_hole =3D mincore_unmapped_range,
-		.hugetlb_entry =3D mincore_hugetlb,
-		.private =3D vec,
-	};
=20
 	vma =3D find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
@@ -219,8 +219,7 @@ static long do_mincore(unsigned long addr, unsigned l=
ong pages, unsigned char *v
 		memset(vec, 1, pages);
 		return pages;
 	}
-	mincore_walk.mm =3D vma->vm_mm;
-	err =3D walk_page_range(addr, end, &mincore_walk);
+	err =3D walk_page_range(vma->vm_mm, addr, end, &mincore_walk_ops, vec);
 	if (err < 0)
 		return err;
 	return (end - addr) >> PAGE_SHIFT;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index cc73318dbc25..675e5d34a507 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -329,20 +329,11 @@ static int prot_none_test(unsigned long addr, unsig=
ned long next,
 	return 0;
 }
=20
-static int prot_none_walk(struct vm_area_struct *vma, unsigned long star=
t,
-			   unsigned long end, unsigned long newflags)
-{
-	pgprot_t new_pgprot =3D vm_get_page_prot(newflags);
-	struct mm_walk prot_none_walk =3D {
-		.pte_entry =3D prot_none_pte_entry,
-		.hugetlb_entry =3D prot_none_hugetlb_entry,
-		.test_walk =3D prot_none_test,
-		.mm =3D current->mm,
-		.private =3D &new_pgprot,
-	};
-
-	return walk_page_range(start, end, &prot_none_walk);
-}
+static const struct mm_walk_ops prot_none_walk_ops =3D {
+	.pte_entry		=3D prot_none_pte_entry,
+	.hugetlb_entry		=3D prot_none_hugetlb_entry,
+	.test_walk		=3D prot_none_test,
+};
=20
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev=
,
@@ -369,7 +360,10 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm=
_area_struct **pprev,
 	if (arch_has_pfn_modify_check() &&
 	    (vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) &&
 	    (newflags & (VM_READ|VM_WRITE|VM_EXEC)) =3D=3D 0) {
-		error =3D prot_none_walk(vma, start, end, newflags);
+		pgprot_t new_pgprot =3D vm_get_page_prot(newflags);
+
+		error =3D walk_page_range(current->mm, start, end,
+				&prot_none_walk_ops, &new_pgprot);
 		if (error)
 			return error;
 	}
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 8a92a961a2ee..b8762b673a3d 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -9,10 +9,11 @@ static int walk_pte_range(pmd_t *pmd, unsigned long add=
r, unsigned long end,
 {
 	pte_t *pte;
 	int err =3D 0;
+	const struct mm_walk_ops *ops =3D walk->ops;
=20
 	pte =3D pte_offset_map(pmd, addr);
 	for (;;) {
-		err =3D walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
+		err =3D ops->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
 		if (err)
 		       break;
 		addr +=3D PAGE_SIZE;
@@ -30,6 +31,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long add=
r, unsigned long end,
 {
 	pmd_t *pmd;
 	unsigned long next;
+	const struct mm_walk_ops *ops =3D walk->ops;
 	int err =3D 0;
=20
 	pmd =3D pmd_offset(pud, addr);
@@ -37,8 +39,8 @@ static int walk_pmd_range(pud_t *pud, unsigned long add=
r, unsigned long end,
 again:
 		next =3D pmd_addr_end(addr, end);
 		if (pmd_none(*pmd) || !walk->vma) {
-			if (walk->pte_hole)
-				err =3D walk->pte_hole(addr, next, walk);
+			if (ops->pte_hole)
+				err =3D ops->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
@@ -47,8 +49,8 @@ static int walk_pmd_range(pud_t *pud, unsigned long add=
r, unsigned long end,
 		 * This implies that each ->pmd_entry() handler
 		 * needs to know about pmd_trans_huge() pmds
 		 */
-		if (walk->pmd_entry)
-			err =3D walk->pmd_entry(pmd, addr, next, walk);
+		if (ops->pmd_entry)
+			err =3D ops->pmd_entry(pmd, addr, next, walk);
 		if (err)
 			break;
=20
@@ -56,7 +58,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long add=
r, unsigned long end,
 		 * Check this here so we only break down trans_huge
 		 * pages when we _need_ to
 		 */
-		if (!walk->pte_entry)
+		if (!ops->pte_entry)
 			continue;
=20
 		split_huge_pmd(walk->vma, pmd, addr);
@@ -75,6 +77,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long add=
r, unsigned long end,
 {
 	pud_t *pud;
 	unsigned long next;
+	const struct mm_walk_ops *ops =3D walk->ops;
 	int err =3D 0;
=20
 	pud =3D pud_offset(p4d, addr);
@@ -82,18 +85,18 @@ static int walk_pud_range(p4d_t *p4d, unsigned long a=
ddr, unsigned long end,
  again:
 		next =3D pud_addr_end(addr, end);
 		if (pud_none(*pud) || !walk->vma) {
-			if (walk->pte_hole)
-				err =3D walk->pte_hole(addr, next, walk);
+			if (ops->pte_hole)
+				err =3D ops->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
 		}
=20
-		if (walk->pud_entry) {
+		if (ops->pud_entry) {
 			spinlock_t *ptl =3D pud_trans_huge_lock(pud, walk->vma);
=20
 			if (ptl) {
-				err =3D walk->pud_entry(pud, addr, next, walk);
+				err =3D ops->pud_entry(pud, addr, next, walk);
 				spin_unlock(ptl);
 				if (err)
 					break;
@@ -105,7 +108,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long a=
ddr, unsigned long end,
 		if (pud_none(*pud))
 			goto again;
=20
-		if (walk->pmd_entry || walk->pte_entry)
+		if (ops->pmd_entry || ops->pte_entry)
 			err =3D walk_pmd_range(pud, addr, next, walk);
 		if (err)
 			break;
@@ -119,19 +122,20 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long=
 addr, unsigned long end,
 {
 	p4d_t *p4d;
 	unsigned long next;
+	const struct mm_walk_ops *ops =3D walk->ops;
 	int err =3D 0;
=20
 	p4d =3D p4d_offset(pgd, addr);
 	do {
 		next =3D p4d_addr_end(addr, end);
 		if (p4d_none_or_clear_bad(p4d)) {
-			if (walk->pte_hole)
-				err =3D walk->pte_hole(addr, next, walk);
+			if (ops->pte_hole)
+				err =3D ops->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
+		if (ops->pmd_entry || ops->pte_entry)
 			err =3D walk_pud_range(p4d, addr, next, walk);
 		if (err)
 			break;
@@ -145,19 +149,20 @@ static int walk_pgd_range(unsigned long addr, unsig=
ned long end,
 {
 	pgd_t *pgd;
 	unsigned long next;
+	const struct mm_walk_ops *ops =3D walk->ops;
 	int err =3D 0;
=20
 	pgd =3D pgd_offset(walk->mm, addr);
 	do {
 		next =3D pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd)) {
-			if (walk->pte_hole)
-				err =3D walk->pte_hole(addr, next, walk);
+			if (ops->pte_hole)
+				err =3D ops->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
+		if (ops->pmd_entry || ops->pte_entry)
 			err =3D walk_p4d_range(pgd, addr, next, walk);
 		if (err)
 			break;
@@ -183,6 +188,7 @@ static int walk_hugetlb_range(unsigned long addr, uns=
igned long end,
 	unsigned long hmask =3D huge_page_mask(h);
 	unsigned long sz =3D huge_page_size(h);
 	pte_t *pte;
+	const struct mm_walk_ops *ops =3D walk->ops;
 	int err =3D 0;
=20
 	do {
@@ -190,9 +196,9 @@ static int walk_hugetlb_range(unsigned long addr, uns=
igned long end,
 		pte =3D huge_pte_offset(walk->mm, addr & hmask, sz);
=20
 		if (pte)
-			err =3D walk->hugetlb_entry(pte, hmask, addr, next, walk);
-		else if (walk->pte_hole)
-			err =3D walk->pte_hole(addr, next, walk);
+			err =3D ops->hugetlb_entry(pte, hmask, addr, next, walk);
+		else if (ops->pte_hole)
+			err =3D ops->pte_hole(addr, next, walk);
=20
 		if (err)
 			break;
@@ -220,9 +226,10 @@ static int walk_page_test(unsigned long start, unsig=
ned long end,
 			struct mm_walk *walk)
 {
 	struct vm_area_struct *vma =3D walk->vma;
+	const struct mm_walk_ops *ops =3D walk->ops;
=20
-	if (walk->test_walk)
-		return walk->test_walk(start, end, walk);
+	if (ops->test_walk)
+		return ops->test_walk(start, end, walk);
=20
 	/*
 	 * vma(VM_PFNMAP) doesn't have any valid struct pages behind VM_PFNMAP
@@ -234,8 +241,8 @@ static int walk_page_test(unsigned long start, unsign=
ed long end,
 	 */
 	if (vma->vm_flags & VM_PFNMAP) {
 		int err =3D 1;
-		if (walk->pte_hole)
-			err =3D walk->pte_hole(start, end, walk);
+		if (ops->pte_hole)
+			err =3D ops->pte_hole(start, end, walk);
 		return err ? err : 1;
 	}
 	return 0;
@@ -248,7 +255,7 @@ static int __walk_page_range(unsigned long start, uns=
igned long end,
 	struct vm_area_struct *vma =3D walk->vma;
=20
 	if (vma && is_vm_hugetlb_page(vma)) {
-		if (walk->hugetlb_entry)
+		if (walk->ops->hugetlb_entry)
 			err =3D walk_hugetlb_range(start, end, walk);
 	} else
 		err =3D walk_pgd_range(start, end, walk);
@@ -258,11 +265,13 @@ static int __walk_page_range(unsigned long start, u=
nsigned long end,
=20
 /**
  * walk_page_range - walk page table with caller specific callbacks
- * @start: start address of the virtual address range
- * @end: end address of the virtual address range
- * @walk: mm_walk structure defining the callbacks and the target addres=
s space
+ * @mm:		mm_struct representing the target process of page table walk
+ * @start:	start address of the virtual address range
+ * @end:	end address of the virtual address range
+ * @ops:	operation to call during the walk
+ * @private:	private data for callbacks' usage
  *
- * Recursively walk the page table tree of the process represented by @w=
alk->mm
+ * Recursively walk the page table tree of the process represented by @m=
m
  * within the virtual address range [@start, @end). During walking, we c=
an do
  * some caller-specific works for each entry, by setting up pmd_entry(),
  * pte_entry(), and/or hugetlb_entry(). If you don't set up for some of =
these
@@ -278,47 +287,52 @@ static int __walk_page_range(unsigned long start, u=
nsigned long end,
  *
  * Before starting to walk page table, some callers want to check whethe=
r
  * they really want to walk over the current vma, typically by checking
- * its vm_flags. walk_page_test() and @walk->test_walk() are used for th=
is
+ * its vm_flags. walk_page_test() and @ops->test_walk() are used for thi=
s
  * purpose.
  *
  * struct mm_walk keeps current values of some common data like vma and =
pmd,
  * which are useful for the access from callbacks. If you want to pass s=
ome
- * caller-specific data to callbacks, @walk->private should be helpful.
+ * caller-specific data to callbacks, @private should be helpful.
  *
  * Locking:
- *   Callers of walk_page_range() and walk_page_vma() should hold
- *   @walk->mm->mmap_sem, because these function traverse vma list and/o=
r
- *   access to vma's data.
+ *   Callers of walk_page_range() and walk_page_vma() should hold @mm->m=
map_sem,
+ *   because these function traverse vma list and/or access to vma's dat=
a.
  */
-int walk_page_range(unsigned long start, unsigned long end,
-		    struct mm_walk *walk)
+int walk_page_range(struct mm_struct *mm, unsigned long start,
+		unsigned long end, const struct mm_walk_ops *ops,
+		void *private)
 {
 	int err =3D 0;
 	unsigned long next;
 	struct vm_area_struct *vma;
+	struct mm_walk walk =3D {
+		.ops		=3D ops,
+		.mm		=3D mm,
+		.private	=3D private,
+	};
=20
 	if (start >=3D end)
 		return -EINVAL;
=20
-	if (!walk->mm)
+	if (!walk.mm)
 		return -EINVAL;
=20
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
+	VM_BUG_ON_MM(!rwsem_is_locked(&walk.mm->mmap_sem), walk.mm);
=20
-	vma =3D find_vma(walk->mm, start);
+	vma =3D find_vma(walk.mm, start);
 	do {
 		if (!vma) { /* after the last vma */
-			walk->vma =3D NULL;
+			walk.vma =3D NULL;
 			next =3D end;
 		} else if (start < vma->vm_start) { /* outside vma */
-			walk->vma =3D NULL;
+			walk.vma =3D NULL;
 			next =3D min(end, vma->vm_start);
 		} else { /* inside vma */
-			walk->vma =3D vma;
+			walk.vma =3D vma;
 			next =3D min(end, vma->vm_end);
 			vma =3D vma->vm_next;
=20
-			err =3D walk_page_test(start, next, walk);
+			err =3D walk_page_test(start, next, &walk);
 			if (err > 0) {
 				/*
 				 * positive return values are purely for
@@ -331,28 +345,34 @@ int walk_page_range(unsigned long start, unsigned l=
ong end,
 			if (err < 0)
 				break;
 		}
-		if (walk->vma || walk->pte_hole)
-			err =3D __walk_page_range(start, next, walk);
+		if (walk.vma || walk.ops->pte_hole)
+			err =3D __walk_page_range(start, next, &walk);
 		if (err)
 			break;
 	} while (start =3D next, start < end);
 	return err;
 }
=20
-int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
+int walk_page_vma(struct vm_area_struct *vma, const struct mm_walk_ops *=
ops,
+		void *private)
 {
+	struct mm_walk walk =3D {
+		.ops		=3D ops,
+		.mm		=3D vma->vm_mm,
+		.vma		=3D vma,
+		.private	=3D private,
+	};
 	int err;
=20
-	if (!walk->mm)
+	if (!walk.mm)
 		return -EINVAL;
=20
-	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
-	VM_BUG_ON(!vma);
-	walk->vma =3D vma;
-	err =3D walk_page_test(vma->vm_start, vma->vm_end, walk);
+	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+
+	err =3D walk_page_test(vma->vm_start, vma->vm_end, &walk);
 	if (err > 0)
 		return 0;
 	if (err < 0)
 		return err;
-	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
+	return __walk_page_range(vma->vm_start, vma->vm_end, &walk);
 }
--=20
2.20.1


