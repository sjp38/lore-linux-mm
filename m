Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 970E0C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:42:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 161D221743
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:42:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GNao5LJH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 161D221743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB6136B027A; Thu,  8 Aug 2019 11:42:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6F056B027D; Thu,  8 Aug 2019 11:42:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 992186B027D; Thu,  8 Aug 2019 11:42:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43DB16B027A
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:42:56 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g126so11396420pgc.22
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:42:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VcGjmX1qrm2pv2Y8gs86g+aKF46uF3ebLMWFIWNhYeU=;
        b=MP4n1DmfM03VnRbum4tCDLBcnvuUO5WUNhMpsP/lSZaua57KJuWmmpsIO0RC7HFppm
         gfS/vN00IOALGrpdFYOesIi5CigJpPl1T/ZWWk9M94knW98VyrLChlJokPOUM309/XgD
         SuS4C2vGTU4FeViclfzmF1nnec1fxBZUUjzEjAmPzFXRKFq96h8zfXV/7MD2DnYhLcpI
         7vbE8HBfcYiGkeMQJPDAg1xh/w2AYWuqLefmsAPI6QWjCss184pBjQvWRq44BmTgAMaw
         Kn0XgsDhpa6tT44MK+eX0SXgERhOirg+WIBz7moL72EMBSkXDMtygtq4cgDRCva1LBXO
         w1LA==
X-Gm-Message-State: APjAAAX9EiN6trAv+2GRzQ093YmT6FLbQ4dq6EHQdXxibrHpiLo20RLX
	QYtq9VvAVBzuizfOZxHOG83HeXC100kFVj9EoNmL+m5r2alvoB3iPyWw9jvLdf25CZ/J8sHFjSL
	qiYI1cJGciLvnE4A9Oqpd1a32WjJQX+sfnAqj8ozu0o/itahsJfIiPkz0adnIp4A=
X-Received: by 2002:a17:90a:3ac2:: with SMTP id b60mr4789167pjc.74.1565278975795;
        Thu, 08 Aug 2019 08:42:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrcWs0gWcPIhttfjsaePTjpyNH3ZdoBTva+/OHfaAAhmsUvyVJh7SDLvrBRgPoB9nX+h8u
X-Received: by 2002:a17:90a:3ac2:: with SMTP id b60mr4788970pjc.74.1565278972526;
        Thu, 08 Aug 2019 08:42:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278972; cv=none;
        d=google.com; s=arc-20160816;
        b=pkf52W7imeBzgN8DOUsm1ozzUqNJiRwRxHFwWdU9Q/uS97r8ppiCyyOb0Ddhe1Ty3o
         0M62Xwq9Vi7WG2I3e5M8hydu9dhXm3g3gxpHsIcejIxtzfqaUArQZ7n7kR4XRVCUeXeV
         6dTwao7+WRekO/1npl7Wt5wE89FcCEMU/SzzzhqYf7EKG7/m4Mu7z6Y9mUbwPqQOF5Bh
         loLNXfA0SxuzbayXGNd86Mm/tU0doei7H/49fB074xZoBZmnpWxI8y0eYWQgUG73uZvW
         0p8wRItrUuf6vp16TezO0ZCErbuZZA9WGzGGAuixSG/lFiK1FWFnMoH4Mc61PvwTuvMy
         TBiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VcGjmX1qrm2pv2Y8gs86g+aKF46uF3ebLMWFIWNhYeU=;
        b=mnzI6iBPgQAmL/VRypmYIo54X8gZBv584X5U9HqcMaU8uVnc4unpRfzdQXjDzPyRBp
         qLipVoX61tb0UetQIuj4AWJ6rn0BY+mTQ9e4WkJ1RKuZyREXzGNsBmsjguO9bbBXZM0w
         L+/3uHDJ2DVhQg8qmtOO+yzhZaOP3j+QelrC6TeMsWcIjzDbEV4DBGlFdnWrNFov7HCG
         g8iGa1NVhVhVB+f2Fic2KB9rointAtKhAhWZ/RFoPVJy/PVzRV5Ta9uYaek/gB9+AuJP
         BHxgeTNsP8u+xwepmSea9gJA5Xg60yZTz5TsWFLkX+H988eqhjBxKRXk0bLeu8a2VH80
         q50A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GNao5LJH;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q2si49500365plh.59.2019.08.08.08.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:42:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GNao5LJH;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=VcGjmX1qrm2pv2Y8gs86g+aKF46uF3ebLMWFIWNhYeU=; b=GNao5LJHNqCkItol8P8qZ7R2Vp
	0/v0J8+X0NpzwwSxhxRN9ztzNq3arr5iW9PFAM1t45+Q0BWL9QTl8U1A7OpF0d25OhCGvoKInXw8t
	mERCBTSp4lJl36tRtiG4/glW94+/7MtbEMKzcuMVleiMgwrT8vcFMuUbAG9PWwcYdN+r7+Nc1AwJN
	A0uvBxAiCNwdgsxmCyB/oQIZueWJU3IPJ8oGX4J/2ZpQRHc73IJXHGheDHJcQSdwV2WgcxYiPZAN5
	k6PsvytLf7/5QM0qmo2h6LeqzfazdRh7yihS9XeLCwkJFpKv9oGHfbKpnf5Ws0Us/4aehQScB/Fe1
	z5ETLmFw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkYx-0008Uk-Nt; Thu, 08 Aug 2019 15:42:48 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?Thomas=20Hellstr=C3=B6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] pagewalk: seperate function pointers from iterator data
Date: Thu,  8 Aug 2019 18:42:39 +0300
Message-Id: <20190808154240.9384-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808154240.9384-1-hch@lst.de>
References: <20190808154240.9384-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
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
---
 arch/openrisc/kernel/dma.c              |  22 +++--
 arch/powerpc/mm/book3s64/subpage_prot.c |  10 +-
 arch/s390/mm/gmap.c                     |  33 +++----
 fs/proc/task_mmu.c                      |  74 +++++++--------
 include/linux/pagewalk.h                |  64 +++++++------
 mm/hmm.c                                |  40 +++-----
 mm/madvise.c                            |  41 +++-----
 mm/memcontrol.c                         |  23 +++--
 mm/mempolicy.c                          |  15 ++-
 mm/migrate.c                            |  15 ++-
 mm/mincore.c                            |  15 ++-
 mm/mprotect.c                           |  24 ++---
 mm/pagewalk.c                           | 118 ++++++++++++++----------
 13 files changed, 245 insertions(+), 249 deletions(-)

diff --git a/arch/openrisc/kernel/dma.c b/arch/openrisc/kernel/dma.c
index c7812e6effa2..4d5b8bd1d795 100644
--- a/arch/openrisc/kernel/dma.c
+++ b/arch/openrisc/kernel/dma.c
@@ -44,6 +44,10 @@ page_set_nocache(pte_t *pte, unsigned long addr,
 	return 0;
 }
 
+static const struct mm_walk_ops set_nocache_walk_ops = {
+	.pte_entry		= page_set_nocache,
+};
+
 static int
 page_clear_nocache(pte_t *pte, unsigned long addr,
 		   unsigned long next, struct mm_walk *walk)
@@ -59,6 +63,10 @@ page_clear_nocache(pte_t *pte, unsigned long addr,
 	return 0;
 }
 
+static const struct mm_walk_ops clear_nocache_walk_ops = {
+	.pte_entry		= page_clear_nocache,
+};
+
 /*
  * Alloc "coherent" memory, which for OpenRISC means simply uncached.
  *
@@ -81,10 +89,6 @@ arch_dma_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 {
 	unsigned long va;
 	void *page;
-	struct mm_walk walk = {
-		.pte_entry = page_set_nocache,
-		.mm = &init_mm
-	};
 
 	page = alloc_pages_exact(size, gfp | __GFP_ZERO);
 	if (!page)
@@ -99,7 +103,8 @@ arch_dma_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 	 * We need to iterate through the pages, clearing the dcache for
 	 * them and setting the cache-inhibit bit.
 	 */
-	if (walk_page_range(va, va + size, &walk)) {
+	if (walk_page_range(&init_mm, va, va + size, &set_nocache_walk_ops,
+			NULL)) {
 		free_pages_exact(page, size);
 		return NULL;
 	}
@@ -112,13 +117,10 @@ arch_dma_free(struct device *dev, size_t size, void *vaddr,
 		dma_addr_t dma_handle, unsigned long attrs)
 {
 	unsigned long va = (unsigned long)vaddr;
-	struct mm_walk walk = {
-		.pte_entry = page_clear_nocache,
-		.mm = &init_mm
-	};
 
 	/* walk_page_range shouldn't be able to fail here */
-	WARN_ON(walk_page_range(va, va + size, &walk));
+	WARN_ON(walk_page_range(&init_mm, va, va + size,
+			&clear_nocache_walk_ops, NULL));
 
 	free_pages_exact(vaddr, size);
 }
diff --git a/arch/powerpc/mm/book3s64/subpage_prot.c b/arch/powerpc/mm/book3s64/subpage_prot.c
index 236f0a861ecc..2ef24a53f4c9 100644
--- a/arch/powerpc/mm/book3s64/subpage_prot.c
+++ b/arch/powerpc/mm/book3s64/subpage_prot.c
@@ -139,14 +139,14 @@ static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 
+static const struct mm_walk_ops subpage_walk_ops = {
+	.pmd_entry	= subpage_walk_pmd_entry,
+};
+
 static void subpage_mark_vma_nohuge(struct mm_struct *mm, unsigned long addr,
 				    unsigned long len)
 {
 	struct vm_area_struct *vma;
-	struct mm_walk subpage_proto_walk = {
-		.mm = mm,
-		.pmd_entry = subpage_walk_pmd_entry,
-	};
 
 	/*
 	 * We don't try too hard, we just mark all the vma in that range
@@ -163,7 +163,7 @@ static void subpage_mark_vma_nohuge(struct mm_struct *mm, unsigned long addr,
 		if (vma->vm_start >= (addr + len))
 			break;
 		vma->vm_flags |= VM_NOHUGEPAGE;
-		walk_page_vma(vma, &subpage_proto_walk);
+		walk_page_vma(vma, &subpage_walk_ops, NULL);
 		vma = vma->vm_next;
 	}
 }
diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index cf80feae970d..bd78d504fdad 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -2521,13 +2521,9 @@ static int __zap_zero_pages(pmd_t *pmd, unsigned long start,
 	return 0;
 }
 
-static inline void zap_zero_pages(struct mm_struct *mm)
-{
-	struct mm_walk walk = { .pmd_entry = __zap_zero_pages };
-
-	walk.mm = mm;
-	walk_page_range(0, TASK_SIZE, &walk);
-}
+static const struct mm_walk_ops zap_zero_walk_ops = {
+	.pmd_entry	= __zap_zero_pages,
+};
 
 /*
  * switch on pgstes for its userspace process (for kvm)
@@ -2546,7 +2542,7 @@ int s390_enable_sie(void)
 	mm->context.has_pgste = 1;
 	/* split thp mappings and disable thp for future mappings */
 	thp_split_mm(mm);
-	zap_zero_pages(mm);
+	walk_page_range(mm, 0, TASK_SIZE, &zap_zero_walk_ops, NULL);
 	up_write(&mm->mmap_sem);
 	return 0;
 }
@@ -2589,12 +2585,13 @@ static int __s390_enable_skey_hugetlb(pte_t *pte, unsigned long addr,
 	return 0;
 }
 
+static const struct mm_walk_ops enable_skey_walk_ops = {
+	.hugetlb_entry		= __s390_enable_skey_hugetlb,
+	.pte_entry		= __s390_enable_skey_pte,
+};
+
 int s390_enable_skey(void)
 {
-	struct mm_walk walk = {
-		.hugetlb_entry = __s390_enable_skey_hugetlb,
-		.pte_entry = __s390_enable_skey_pte,
-	};
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	int rc = 0;
@@ -2614,8 +2611,7 @@ int s390_enable_skey(void)
 	}
 	mm->def_flags &= ~VM_MERGEABLE;
 
-	walk.mm = mm;
-	walk_page_range(0, TASK_SIZE, &walk);
+	walk_page_range(mm, 0, TASK_SIZE, &enable_skey_walk_ops, NULL);
 
 out_up:
 	up_write(&mm->mmap_sem);
@@ -2633,13 +2629,14 @@ static int __s390_reset_cmma(pte_t *pte, unsigned long addr,
 	return 0;
 }
 
+static const struct mm_walk_ops reset_cmma_walk_ops = {
+	.pte_entry		= __s390_reset_cmma,
+};
+
 void s390_reset_cmma(struct mm_struct *mm)
 {
-	struct mm_walk walk = { .pte_entry = __s390_reset_cmma };
-
 	down_write(&mm->mmap_sem);
-	walk.mm = mm;
-	walk_page_range(0, TASK_SIZE, &walk);
+	walk_page_range(mm, 0, TASK_SIZE, &reset_cmma_walk_ops, NULL);
 	up_write(&mm->mmap_sem);
 }
 EXPORT_SYMBOL_GPL(s390_reset_cmma);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8857da830b86..bdf65d5ba38b 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -729,21 +729,24 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
 	}
 	return 0;
 }
+#else
+#define smaps_hugetlb_range	NULL
 #endif /* HUGETLB_PAGE */
 
+static const struct mm_walk_ops smaps_walk_ops = {
+	.pmd_entry		= smaps_pte_range,
+	.hugetlb_entry		= smaps_hugetlb_range,
+};
+
+static const struct mm_walk_ops smaps_shmem_walk_ops = {
+	.pmd_entry		= smaps_pte_range,
+	.hugetlb_entry		= smaps_hugetlb_range,
+	.pte_hole		= smaps_pte_hole,
+};
+
 static void smap_gather_stats(struct vm_area_struct *vma,
 			     struct mem_size_stats *mss)
 {
-	struct mm_walk smaps_walk = {
-		.pmd_entry = smaps_pte_range,
-#ifdef CONFIG_HUGETLB_PAGE
-		.hugetlb_entry = smaps_hugetlb_range,
-#endif
-		.mm = vma->vm_mm,
-	};
-
-	smaps_walk.private = mss;
-
 #ifdef CONFIG_SHMEM
 	/* In case of smaps_rollup, reset the value from previous vma */
 	mss->check_shmem_swap = false;
@@ -765,12 +768,13 @@ static void smap_gather_stats(struct vm_area_struct *vma,
 			mss->swap += shmem_swapped;
 		} else {
 			mss->check_shmem_swap = true;
-			smaps_walk.pte_hole = smaps_pte_hole;
+			walk_page_vma(vma, &smaps_shmem_walk_ops, mss);
+			return;
 		}
 	}
 #endif
 	/* mmap_sem is held in m_start */
-	walk_page_vma(vma, &smaps_walk);
+	walk_page_vma(vma, &smaps_walk_ops, mss);
 }
 
 #define SEQ_PUT_DEC(str, val) \
@@ -1118,6 +1122,11 @@ static int clear_refs_test_walk(unsigned long start, unsigned long end,
 	return 0;
 }
 
+static const struct mm_walk_ops clear_refs_walk_ops = {
+	.pmd_entry		= clear_refs_pte_range,
+	.test_walk		= clear_refs_test_walk,
+};
+
 static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				size_t count, loff_t *ppos)
 {
@@ -1151,12 +1160,6 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		struct clear_refs_private cp = {
 			.type = type,
 		};
-		struct mm_walk clear_refs_walk = {
-			.pmd_entry = clear_refs_pte_range,
-			.test_walk = clear_refs_test_walk,
-			.mm = mm,
-			.private = &cp,
-		};
 
 		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
 			if (down_write_killable(&mm->mmap_sem)) {
@@ -1217,7 +1220,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 						0, NULL, mm, 0, -1UL);
 			mmu_notifier_invalidate_range_start(&range);
 		}
-		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
+		walk_page_range(mm, 0, mm->highest_vm_end, &clear_refs_walk_ops,
+				&cp);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(&range);
 		tlb_finish_mmu(&tlb, 0, -1);
@@ -1489,8 +1493,16 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
 
 	return err;
 }
+#else
+#define pagemap_hugetlb_range	NULL
 #endif /* HUGETLB_PAGE */
 
+static const struct mm_walk_ops pagemap_ops = {
+	.pmd_entry	= pagemap_pmd_range,
+	.pte_hole	= pagemap_pte_hole,
+	.hugetlb_entry	= pagemap_hugetlb_range,
+};
+
 /*
  * /proc/pid/pagemap - an array mapping virtual pages to pfns
  *
@@ -1522,7 +1534,6 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 {
 	struct mm_struct *mm = file->private_data;
 	struct pagemapread pm;
-	struct mm_walk pagemap_walk = {};
 	unsigned long src;
 	unsigned long svpfn;
 	unsigned long start_vaddr;
@@ -1550,14 +1561,6 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!pm.buffer)
 		goto out_mm;
 
-	pagemap_walk.pmd_entry = pagemap_pmd_range;
-	pagemap_walk.pte_hole = pagemap_pte_hole;
-#ifdef CONFIG_HUGETLB_PAGE
-	pagemap_walk.hugetlb_entry = pagemap_hugetlb_range;
-#endif
-	pagemap_walk.mm = mm;
-	pagemap_walk.private = &pm;
-
 	src = *ppos;
 	svpfn = src / PM_ENTRY_BYTES;
 	start_vaddr = svpfn << PAGE_SHIFT;
@@ -1586,7 +1589,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		ret = down_read_killable(&mm->mmap_sem);
 		if (ret)
 			goto out_free;
-		ret = walk_page_range(start_vaddr, end, &pagemap_walk);
+		ret = walk_page_range(mm, start_vaddr, end, &pagemap_ops, &pm);
 		up_read(&mm->mmap_sem);
 		start_vaddr = end;
 
@@ -1798,6 +1801,11 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 }
 #endif
 
+static const struct mm_walk_ops show_numa_ops = {
+	.hugetlb_entry = gather_hugetlb_stats,
+	.pmd_entry = gather_pte_stats,
+};
+
 /*
  * Display pages allocated per node and memory policy via /proc.
  */
@@ -1809,12 +1817,6 @@ static int show_numa_map(struct seq_file *m, void *v)
 	struct numa_maps *md = &numa_priv->md;
 	struct file *file = vma->vm_file;
 	struct mm_struct *mm = vma->vm_mm;
-	struct mm_walk walk = {
-		.hugetlb_entry = gather_hugetlb_stats,
-		.pmd_entry = gather_pte_stats,
-		.private = md,
-		.mm = mm,
-	};
 	struct mempolicy *pol;
 	char buffer[64];
 	int nid;
@@ -1848,7 +1850,7 @@ static int show_numa_map(struct seq_file *m, void *v)
 		seq_puts(m, " huge");
 
 	/* mmap_sem is held by m_start */
-	walk_page_vma(vma, &walk);
+	walk_page_vma(vma, &show_numa_ops, md);
 
 	if (!md->pages)
 		goto out;
diff --git a/include/linux/pagewalk.h b/include/linux/pagewalk.h
index df278a94086d..bddd9759bab9 100644
--- a/include/linux/pagewalk.h
+++ b/include/linux/pagewalk.h
@@ -4,31 +4,28 @@
 
 #include <linux/mm.h>
 
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
- * @mm:        mm_struct representing the target process of page table walk
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
 
-int walk_page_range(unsigned long addr, unsigned long end,
-		struct mm_walk *walk);
-int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
+int walk_page_range(struct mm_struct *mm, unsigned long start,
+		unsigned long end, const struct mm_walk_ops *ops,
+		void *private);
+int walk_page_vma(struct vm_area_struct *vma, const struct mm_walk_ops *ops,
+		void *private);
 
 #endif /* _LINUX_PAGEWALK_H */
diff --git a/mm/hmm.c b/mm/hmm.c
index 909b846c11d4..37933f886dbe 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -941,6 +941,13 @@ void hmm_range_unregister(struct hmm_range *range)
 }
 EXPORT_SYMBOL(hmm_range_unregister);
 
+static const struct mm_walk_ops hmm_walk_ops = {
+	.pud_entry	= hmm_vma_walk_pud,
+	.pmd_entry	= hmm_vma_walk_pmd,
+	.pte_hole	= hmm_vma_walk_hole,
+	.hugetlb_entry	= hmm_vma_walk_hugetlb_entry,
+};
+
 /*
  * hmm_range_snapshot() - snapshot CPU page table for a range
  * @range: range
@@ -961,7 +968,6 @@ long hmm_range_snapshot(struct hmm_range *range)
 	struct hmm_vma_walk hmm_vma_walk;
 	struct hmm *hmm = range->hmm;
 	struct vm_area_struct *vma;
-	struct mm_walk mm_walk;
 
 	lockdep_assert_held(&hmm->mm->mmap_sem);
 	do {
@@ -999,20 +1005,10 @@ long hmm_range_snapshot(struct hmm_range *range)
 		hmm_vma_walk.last = start;
 		hmm_vma_walk.fault = false;
 		hmm_vma_walk.range = range;
-		mm_walk.private = &hmm_vma_walk;
-		end = min(range->end, vma->vm_end);
 
-		mm_walk.vma = vma;
-		mm_walk.mm = vma->vm_mm;
-		mm_walk.pte_entry = NULL;
-		mm_walk.test_walk = NULL;
-		mm_walk.hugetlb_entry = NULL;
-		mm_walk.pud_entry = hmm_vma_walk_pud;
-		mm_walk.pmd_entry = hmm_vma_walk_pmd;
-		mm_walk.pte_hole = hmm_vma_walk_hole;
-		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
-
-		walk_page_range(start, end, &mm_walk);
+		end = min(range->end, vma->vm_end);
+		walk_page_range(vma->vm_mm, start, end, &hmm_walk_ops,
+				&hmm_vma_walk);
 		start = end;
 	} while (start < range->end);
 
@@ -1055,7 +1051,6 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	struct hmm_vma_walk hmm_vma_walk;
 	struct hmm *hmm = range->hmm;
 	struct vm_area_struct *vma;
-	struct mm_walk mm_walk;
 	int ret;
 
 	lockdep_assert_held(&hmm->mm->mmap_sem);
@@ -1096,21 +1091,14 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 		hmm_vma_walk.fault = true;
 		hmm_vma_walk.block = block;
 		hmm_vma_walk.range = range;
-		mm_walk.private = &hmm_vma_walk;
 		end = min(range->end, vma->vm_end);
 
-		mm_walk.vma = vma;
-		mm_walk.mm = vma->vm_mm;
-		mm_walk.pte_entry = NULL;
-		mm_walk.test_walk = NULL;
-		mm_walk.hugetlb_entry = NULL;
-		mm_walk.pud_entry = hmm_vma_walk_pud;
-		mm_walk.pmd_entry = hmm_vma_walk_pmd;
-		mm_walk.pte_hole = hmm_vma_walk_hole;
-		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
+		walk_page_range(vma->vm_mm, start, end, &hmm_walk_ops,
+				&hmm_vma_walk);
 
 		do {
-			ret = walk_page_range(start, end, &mm_walk);
+			ret = walk_page_range(vma->vm_mm, start, end,
+					&hmm_walk_ops, &hmm_vma_walk);
 			start = hmm_vma_walk.last;
 
 			/* Keep trying while the range is valid. */
diff --git a/mm/madvise.c b/mm/madvise.c
index 80a78bb16782..afe2b015ea58 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -226,19 +226,9 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 	return 0;
 }
 
-static void force_swapin_readahead(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end)
-{
-	struct mm_walk walk = {
-		.mm = vma->vm_mm,
-		.pmd_entry = swapin_walk_pmd_entry,
-		.private = vma,
-	};
-
-	walk_page_range(start, end, &walk);
-
-	lru_add_drain();	/* Push any new pages onto the LRU now */
-}
+static const struct mm_walk_ops swapin_walk_ops = {
+	.pmd_entry		= swapin_walk_pmd_entry,
+};
 
 static void force_shm_swapin_readahead(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end,
@@ -280,7 +270,8 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	*prev = vma;
 #ifdef CONFIG_SWAP
 	if (!file) {
-		force_swapin_readahead(vma, start, end);
+		walk_page_range(vma->vm_mm, start, end, &swapin_walk_ops, vma);
+		lru_add_drain(); /* Push any new pages onto the LRU now */
 		return 0;
 	}
 
@@ -441,20 +432,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 
-static void madvise_free_page_range(struct mmu_gather *tlb,
-			     struct vm_area_struct *vma,
-			     unsigned long addr, unsigned long end)
-{
-	struct mm_walk free_walk = {
-		.pmd_entry = madvise_free_pte_range,
-		.mm = vma->vm_mm,
-		.private = tlb,
-	};
-
-	tlb_start_vma(tlb, vma);
-	walk_page_range(addr, end, &free_walk);
-	tlb_end_vma(tlb, vma);
-}
+static const struct mm_walk_ops madvise_free_walk_ops = {
+	.pmd_entry		= madvise_free_pte_range,
+};
 
 static int madvise_free_single_vma(struct vm_area_struct *vma,
 			unsigned long start_addr, unsigned long end_addr)
@@ -481,7 +461,10 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 	update_hiwater_rss(mm);
 
 	mmu_notifier_invalidate_range_start(&range);
-	madvise_free_page_range(&tlb, vma, range.start, range.end);
+	tlb_start_vma(&tlb, vma);
+	walk_page_range(vma->vm_mm, range.start, range.end,
+			&madvise_free_walk_ops, &tlb);
+	tlb_end_vma(&tlb, vma);
 	mmu_notifier_invalidate_range_end(&range);
 	tlb_finish_mmu(&tlb, range.start, range.end);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ee01175e56d4..5d159f9391ff 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5244,17 +5244,16 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	return 0;
 }
 
+static const struct mm_walk_ops precharge_walk_ops = {
+	.pmd_entry	= mem_cgroup_count_precharge_pte_range,
+};
+
 static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 {
 	unsigned long precharge;
 
-	struct mm_walk mem_cgroup_count_precharge_walk = {
-		.pmd_entry = mem_cgroup_count_precharge_pte_range,
-		.mm = mm,
-	};
 	down_read(&mm->mmap_sem);
-	walk_page_range(0, mm->highest_vm_end,
-			&mem_cgroup_count_precharge_walk);
+	walk_page_range(mm, 0, mm->highest_vm_end, &precharge_walk_ops, NULL);
 	up_read(&mm->mmap_sem);
 
 	precharge = mc.precharge;
@@ -5523,13 +5522,12 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	return ret;
 }
 
+static const struct mm_walk_ops charge_walk_ops = {
+	.pmd_entry	= mem_cgroup_move_charge_pte_range,
+};
+
 static void mem_cgroup_move_charge(void)
 {
-	struct mm_walk mem_cgroup_move_charge_walk = {
-		.pmd_entry = mem_cgroup_move_charge_pte_range,
-		.mm = mc.mm,
-	};
-
 	lru_add_drain_all();
 	/*
 	 * Signal lock_page_memcg() to take the memcg's move_lock
@@ -5555,7 +5553,8 @@ static void mem_cgroup_move_charge(void)
 	 * When we have consumed all precharges and failed in doing
 	 * additional charge, the page walk just aborts.
 	 */
-	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk);
+	walk_page_range(mc.mm, 0, mc.mm->highest_vm_end, &charge_walk_ops,
+			NULL);
 
 	up_read(&mc.mm->mmap_sem);
 	atomic_dec(&mc.from->moving_account);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1ee6b6f49431..6712bceae213 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -634,6 +634,12 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 	return 1;
 }
 
+static const struct mm_walk_ops queue_pages_walk_ops = {
+	.hugetlb_entry		= queue_pages_hugetlb,
+	.pmd_entry		= queue_pages_pte_range,
+	.test_walk		= queue_pages_test_walk,
+};
+
 /*
  * Walk through page tables and collect pages to be migrated.
  *
@@ -652,15 +658,8 @@ queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		.nmask = nodes,
 		.prev = NULL,
 	};
-	struct mm_walk queue_pages_walk = {
-		.hugetlb_entry = queue_pages_hugetlb,
-		.pmd_entry = queue_pages_pte_range,
-		.test_walk = queue_pages_test_walk,
-		.mm = mm,
-		.private = &qp,
-	};
 
-	return walk_page_range(start, end, &queue_pages_walk);
+	return walk_page_range(mm, start, end, &queue_pages_walk_ops, &qp);
 }
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index 019c426c6ef7..75de4378dfcd 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2330,6 +2330,11 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 	return 0;
 }
 
+static const struct mm_walk_ops migrate_vma_walk_ops = {
+	.pmd_entry		= migrate_vma_collect_pmd,
+	.pte_hole		= migrate_vma_collect_hole,
+};
+
 /*
  * migrate_vma_collect() - collect pages over a range of virtual addresses
  * @migrate: migrate struct containing all migration information
@@ -2341,19 +2346,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 static void migrate_vma_collect(struct migrate_vma *migrate)
 {
 	struct mmu_notifier_range range;
-	struct mm_walk mm_walk = {
-		.pmd_entry = migrate_vma_collect_pmd,
-		.pte_hole = migrate_vma_collect_hole,
-		.vma = migrate->vma,
-		.mm = migrate->vma->vm_mm,
-		.private = migrate,
-	};
 
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm_walk.mm,
 				migrate->start,
 				migrate->end);
 	mmu_notifier_invalidate_range_start(&range);
-	walk_page_range(migrate->start, migrate->end, &mm_walk);
+	walk_page_range(migrate->vma->vm_mm, migrate->start, migrate->end,
+			&migrate_vma_walk_ops, migrate);
 	mmu_notifier_invalidate_range_end(&range);
 
 	migrate->end = migrate->start + (migrate->npages << PAGE_SHIFT);
diff --git a/mm/mincore.c b/mm/mincore.c
index 3b051b6ab3fe..f9a9dbe8cd33 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -193,6 +193,12 @@ static inline bool can_do_mincore(struct vm_area_struct *vma)
 		inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
 }
 
+static const struct mm_walk_ops mincore_walk_ops = {
+	.pmd_entry		= mincore_pte_range,
+	.pte_hole		= mincore_unmapped_range,
+	.hugetlb_entry		= mincore_hugetlb,
+};
+
 /*
  * Do a chunk of "sys_mincore()". We've already checked
  * all the arguments, we hold the mmap semaphore: we should
@@ -203,12 +209,6 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	struct vm_area_struct *vma;
 	unsigned long end;
 	int err;
-	struct mm_walk mincore_walk = {
-		.pmd_entry = mincore_pte_range,
-		.pte_hole = mincore_unmapped_range,
-		.hugetlb_entry = mincore_hugetlb,
-		.private = vec,
-	};
 
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
@@ -219,8 +219,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 		memset(vec, 1, pages);
 		return pages;
 	}
-	mincore_walk.mm = vma->vm_mm;
-	err = walk_page_range(addr, end, &mincore_walk);
+	err = walk_page_range(vma->vm_mm, addr, end, &mincore_walk_ops, vec);
 	if (err < 0)
 		return err;
 	return (end - addr) >> PAGE_SHIFT;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index cc73318dbc25..675e5d34a507 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -329,20 +329,11 @@ static int prot_none_test(unsigned long addr, unsigned long next,
 	return 0;
 }
 
-static int prot_none_walk(struct vm_area_struct *vma, unsigned long start,
-			   unsigned long end, unsigned long newflags)
-{
-	pgprot_t new_pgprot = vm_get_page_prot(newflags);
-	struct mm_walk prot_none_walk = {
-		.pte_entry = prot_none_pte_entry,
-		.hugetlb_entry = prot_none_hugetlb_entry,
-		.test_walk = prot_none_test,
-		.mm = current->mm,
-		.private = &new_pgprot,
-	};
-
-	return walk_page_range(start, end, &prot_none_walk);
-}
+static const struct mm_walk_ops prot_none_walk_ops = {
+	.pte_entry		= prot_none_pte_entry,
+	.hugetlb_entry		= prot_none_hugetlb_entry,
+	.test_walk		= prot_none_test,
+};
 
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
@@ -369,7 +360,10 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	if (arch_has_pfn_modify_check() &&
 	    (vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) &&
 	    (newflags & (VM_READ|VM_WRITE|VM_EXEC)) == 0) {
-		error = prot_none_walk(vma, start, end, newflags);
+		pgprot_t new_pgprot = vm_get_page_prot(newflags);
+
+		error = walk_page_range(current->mm, start, end,
+				&prot_none_walk_ops, &new_pgprot);
 		if (error)
 			return error;
 	}
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 8a92a961a2ee..28510fc0dde1 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -9,10 +9,11 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 {
 	pte_t *pte;
 	int err = 0;
+	const struct mm_walk_ops *ops = walk->ops;
 
 	pte = pte_offset_map(pmd, addr);
 	for (;;) {
-		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
+		err = ops->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
 		if (err)
 		       break;
 		addr += PAGE_SIZE;
@@ -30,6 +31,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 {
 	pmd_t *pmd;
 	unsigned long next;
+	const struct mm_walk_ops *ops = walk->ops;
 	int err = 0;
 
 	pmd = pmd_offset(pud, addr);
@@ -37,8 +39,8 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 again:
 		next = pmd_addr_end(addr, end);
 		if (pmd_none(*pmd) || !walk->vma) {
-			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+			if (ops->pte_hole)
+				err = ops->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
@@ -47,8 +49,8 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		 * This implies that each ->pmd_entry() handler
 		 * needs to know about pmd_trans_huge() pmds
 		 */
-		if (walk->pmd_entry)
-			err = walk->pmd_entry(pmd, addr, next, walk);
+		if (ops->pmd_entry)
+			err = ops->pmd_entry(pmd, addr, next, walk);
 		if (err)
 			break;
 
@@ -56,7 +58,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		 * Check this here so we only break down trans_huge
 		 * pages when we _need_ to
 		 */
-		if (!walk->pte_entry)
+		if (!ops->pte_entry)
 			continue;
 
 		split_huge_pmd(walk->vma, pmd, addr);
@@ -75,6 +77,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 {
 	pud_t *pud;
 	unsigned long next;
+	const struct mm_walk_ops *ops = walk->ops;
 	int err = 0;
 
 	pud = pud_offset(p4d, addr);
@@ -82,18 +85,18 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
  again:
 		next = pud_addr_end(addr, end);
 		if (pud_none(*pud) || !walk->vma) {
-			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+			if (ops->pte_hole)
+				err = ops->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
 		}
 
-		if (walk->pud_entry) {
+		if (ops->pud_entry) {
 			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
 
 			if (ptl) {
-				err = walk->pud_entry(pud, addr, next, walk);
+				err = ops->pud_entry(pud, addr, next, walk);
 				spin_unlock(ptl);
 				if (err)
 					break;
@@ -105,7 +108,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 		if (pud_none(*pud))
 			goto again;
 
-		if (walk->pmd_entry || walk->pte_entry)
+		if (ops->pmd_entry || ops->pte_entry)
 			err = walk_pmd_range(pud, addr, next, walk);
 		if (err)
 			break;
@@ -119,19 +122,20 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 {
 	p4d_t *p4d;
 	unsigned long next;
+	const struct mm_walk_ops *ops = walk->ops;
 	int err = 0;
 
 	p4d = p4d_offset(pgd, addr);
 	do {
 		next = p4d_addr_end(addr, end);
 		if (p4d_none_or_clear_bad(p4d)) {
-			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+			if (ops->pte_hole)
+				err = ops->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
+		if (ops->pmd_entry || ops->pte_entry)
 			err = walk_pud_range(p4d, addr, next, walk);
 		if (err)
 			break;
@@ -145,19 +149,20 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 {
 	pgd_t *pgd;
 	unsigned long next;
+	const struct mm_walk_ops *ops = walk->ops;
 	int err = 0;
 
 	pgd = pgd_offset(walk->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd)) {
-			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+			if (ops->pte_hole)
+				err = ops->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
+		if (ops->pmd_entry || ops->pte_entry)
 			err = walk_p4d_range(pgd, addr, next, walk);
 		if (err)
 			break;
@@ -183,6 +188,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 	unsigned long hmask = huge_page_mask(h);
 	unsigned long sz = huge_page_size(h);
 	pte_t *pte;
+	const struct mm_walk_ops *ops = walk->ops;
 	int err = 0;
 
 	do {
@@ -190,9 +196,9 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 		pte = huge_pte_offset(walk->mm, addr & hmask, sz);
 
 		if (pte)
-			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
-		else if (walk->pte_hole)
-			err = walk->pte_hole(addr, next, walk);
+			err = ops->hugetlb_entry(pte, hmask, addr, next, walk);
+		else if (ops->pte_hole)
+			err = ops->pte_hole(addr, next, walk);
 
 		if (err)
 			break;
@@ -220,9 +226,10 @@ static int walk_page_test(unsigned long start, unsigned long end,
 			struct mm_walk *walk)
 {
 	struct vm_area_struct *vma = walk->vma;
+	const struct mm_walk_ops *ops = walk->ops;
 
-	if (walk->test_walk)
-		return walk->test_walk(start, end, walk);
+	if (ops->test_walk)
+		return ops->test_walk(start, end, walk);
 
 	/*
 	 * vma(VM_PFNMAP) doesn't have any valid struct pages behind VM_PFNMAP
@@ -234,8 +241,8 @@ static int walk_page_test(unsigned long start, unsigned long end,
 	 */
 	if (vma->vm_flags & VM_PFNMAP) {
 		int err = 1;
-		if (walk->pte_hole)
-			err = walk->pte_hole(start, end, walk);
+		if (ops->pte_hole)
+			err = ops->pte_hole(start, end, walk);
 		return err ? err : 1;
 	}
 	return 0;
@@ -248,7 +255,8 @@ static int __walk_page_range(unsigned long start, unsigned long end,
 	struct vm_area_struct *vma = walk->vma;
 
 	if (vma && is_vm_hugetlb_page(vma)) {
-		if (walk->hugetlb_entry)
+		const struct mm_walk_ops *ops = walk->ops;
+		if (ops->hugetlb_entry)
 			err = walk_hugetlb_range(start, end, walk);
 	} else
 		err = walk_pgd_range(start, end, walk);
@@ -258,11 +266,13 @@ static int __walk_page_range(unsigned long start, unsigned long end,
 
 /**
  * walk_page_range - walk page table with caller specific callbacks
- * @start: start address of the virtual address range
- * @end: end address of the virtual address range
- * @walk: mm_walk structure defining the callbacks and the target address space
+ * @mm:		mm_struct representing the target process of page table walk
+ * @start:	start address of the virtual address range
+ * @end:	end address of the virtual address range
+ * @ops:	operation to call during the walk
+ * @private:	private data for callbacks' usage
  *
- * Recursively walk the page table tree of the process represented by @walk->mm
+ * Recursively walk the page table tree of the process represented by @mm
  * within the virtual address range [@start, @end). During walking, we can do
  * some caller-specific works for each entry, by setting up pmd_entry(),
  * pte_entry(), and/or hugetlb_entry(). If you don't set up for some of these
@@ -283,42 +293,48 @@ static int __walk_page_range(unsigned long start, unsigned long end,
  *
  * struct mm_walk keeps current values of some common data like vma and pmd,
  * which are useful for the access from callbacks. If you want to pass some
- * caller-specific data to callbacks, @walk->private should be helpful.
+ * caller-specific data to callbacks, @private should be helpful.
  *
  * Locking:
  *   Callers of walk_page_range() and walk_page_vma() should hold
  *   @walk->mm->mmap_sem, because these function traverse vma list and/or
  *   access to vma's data.
  */
-int walk_page_range(unsigned long start, unsigned long end,
-		    struct mm_walk *walk)
+int walk_page_range(struct mm_struct *mm, unsigned long start,
+		unsigned long end, const struct mm_walk_ops *ops,
+		void *private)
 {
 	int err = 0;
 	unsigned long next;
 	struct vm_area_struct *vma;
+	struct mm_walk walk = {
+		.ops		= ops,
+		.mm		= mm,
+		.private	= private,
+	};
 
 	if (start >= end)
 		return -EINVAL;
 
-	if (!walk->mm)
+	if (!walk.mm)
 		return -EINVAL;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
+	VM_BUG_ON_MM(!rwsem_is_locked(&walk.mm->mmap_sem), walk.mm);
 
-	vma = find_vma(walk->mm, start);
+	vma = find_vma(walk.mm, start);
 	do {
 		if (!vma) { /* after the last vma */
-			walk->vma = NULL;
+			walk.vma = NULL;
 			next = end;
 		} else if (start < vma->vm_start) { /* outside vma */
-			walk->vma = NULL;
+			walk.vma = NULL;
 			next = min(end, vma->vm_start);
 		} else { /* inside vma */
-			walk->vma = vma;
+			walk.vma = vma;
 			next = min(end, vma->vm_end);
 			vma = vma->vm_next;
 
-			err = walk_page_test(start, next, walk);
+			err = walk_page_test(start, next, &walk);
 			if (err > 0) {
 				/*
 				 * positive return values are purely for
@@ -331,28 +347,34 @@ int walk_page_range(unsigned long start, unsigned long end,
 			if (err < 0)
 				break;
 		}
-		if (walk->vma || walk->pte_hole)
-			err = __walk_page_range(start, next, walk);
+		if (walk.vma || walk.ops->pte_hole)
+			err = __walk_page_range(start, next, &walk);
 		if (err)
 			break;
 	} while (start = next, start < end);
 	return err;
 }
 
-int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
+int walk_page_vma(struct vm_area_struct *vma, const struct mm_walk_ops *ops,
+		void *private)
 {
+	struct mm_walk walk = {
+		.ops		= ops,
+		.mm		= vma->vm_mm,
+		.vma		= vma,
+		.private	= private,
+	};
 	int err;
 
-	if (!walk->mm)
+	if (!walk.mm)
 		return -EINVAL;
 
-	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
-	VM_BUG_ON(!vma);
-	walk->vma = vma;
-	err = walk_page_test(vma->vm_start, vma->vm_end, walk);
+	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+
+	err = walk_page_test(vma->vm_start, vma->vm_end, &walk);
 	if (err > 0)
 		return 0;
 	if (err < 0)
 		return err;
-	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
+	return __walk_page_range(vma->vm_start, vma->vm_end, &walk);
 }
-- 
2.20.1

