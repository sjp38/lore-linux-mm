Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 420EFC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E36C9213F2
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="F3FutycM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E36C9213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE5848E000D; Tue, 25 Jun 2019 10:38:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C488F8E000B; Tue, 25 Jun 2019 10:38:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A74948E000D; Tue, 25 Jun 2019 10:38:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3C68E000B
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:38:12 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w22so2794364pgc.20
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:38:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7Nw8nB685y+6LL8lV2B7CzUbhlE0EkQRUBSQFuFoZsU=;
        b=r1vYw5XxdA1revt4O/otMd/KnugM+hGoCl5Ax30MePbxr0OlmtqNneMaZGhKEjcEiJ
         WMtXGPSdGfq8DxKP+g/9m8Po31mWJGeforoeHt0w2fENZzlTor7fn2nkmLKztIOWJPDy
         owIpuimqTjKNLnrIfT0p9QJwDEgUcSs5glEIYhCHYL4ggVzaXBE1vgTS5KIpYISYIvDf
         PDn6Hcnkv1UcUhYncel1V49IMiDYFLdQW9zSJ1ceKs7fTij6P0aZkK0L/n6jSaOR0k32
         glcmqgJNfN62cfilp2HqV2RCPIUP8mdxLqfDOPtIHlklUOMqNhet8tHeh/Ga6w4m17vu
         f/hA==
X-Gm-Message-State: APjAAAVsFF2SIdgDkZRIU0LeggqSH8a7AxWExbWpN+D7nV5QZgakJOiy
	Du6PlqYLv4JIFO4wlotgeySScmNv9kvSVkd370/e1hBYvKmr5aXLS0tUhVNqGR8Jm7th3mjHxnk
	5rXftGU1fuAR5pifWSngIb+/g5eryzlipkAasAUGG7jL3gDcRDeRkbgXfKbmuUYY=
X-Received: by 2002:a17:902:8f93:: with SMTP id z19mr67341937plo.97.1561473491985;
        Tue, 25 Jun 2019 07:38:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPEIbG+KZDfL/PQeJ5bLxrSfX1/FAMr/OIlalJzhqy4TNhebZcYmctxD0Y9AZSDGNBCwgW
X-Received: by 2002:a17:902:8f93:: with SMTP id z19mr67341808plo.97.1561473490568;
        Tue, 25 Jun 2019 07:38:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473490; cv=none;
        d=google.com; s=arc-20160816;
        b=Nu+tlx4m8Wx6pvbbh7LKAn//sD66/apWIoSXCKOJ+694kjpgNovL23rRnFDPHFLP1i
         tKxSLdCmXzXhlUVGtJfrn51tNWnfMUrpsLLJyWGf5hEO0fLBEUr3WEr7/g7WEJ6XlIzk
         3ZiIL5l/uGXfAjCimYkV5nMomNPgOfqIL1Cvu30Qz4BQnZJYOB1ViIqwrPCAdMynBKld
         Ss4SclCNzYMC07xm4/VmGLbjBdhlTt8FIz9MGwBfTNFVNnc7tiX4YHYCLKBH/uoTsTG6
         Xizs+3aVEEfXBY6cW4ICkblw5NuUzL1EW5FpXd2AbZSdA9p99IHvRdZVOflK17vikzzq
         zSHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7Nw8nB685y+6LL8lV2B7CzUbhlE0EkQRUBSQFuFoZsU=;
        b=bo0c1BVXXPgUFiT+coUIjVquZUYyKAg/KLcDInlslOdRfkplialBN448Df8UVqcfZS
         5XyBRpW6u+ofOyX67BCd5tGqq2oozhnT+Cwk0+nxy6+ZS16gfL9CyKOf70ZGhBEiFrhy
         DvSSuLQUXq8jVPXVrcieK0eXXXEvdvcMdh4hcZae+OmqRnLovckLne9P4ysKY5oeQIg6
         w2USbwNwWHeEN7ETUARGds0fRtPucPMNw+aGQUP+haOuKsdjB8ZxxzabWxlP7rEX731n
         dga0KGhAGGPl4Oz0oVRz0qh7SthqbGmLMfZPbQk2H8lq3YM9pPFLUpauv2/4QD06O8Ms
         Ac/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=F3FutycM;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k1si3102140pjt.70.2019.06.25.07.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:38:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=F3FutycM;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=7Nw8nB685y+6LL8lV2B7CzUbhlE0EkQRUBSQFuFoZsU=; b=F3FutycMquHOrZwEo5Hnp322WX
	fqzMvokVNVRzLB78DDnSqYuk+SrJZBcnXDtKGd440OdqADtXmgaqppIxd/mAjimCV/kEc+J+QKKp3
	vvJowGT3P3zBSrvH7uE/Xwlkme2oGngihWHwjaGrhqfqky7B3VBf6Ftl6j8zjKphGtVEKag5f+EfG
	GMm3GpVKOxv0RZ5UWe3hPFE0uALmLpOMokws/zVIihukxy8JGCpPg2YU+ORzLsQJKbrBQ3yxn87KE
	hyAbFL81krptwJXtt7ZWqGB+S05j4f+Is17FuWAxf5lgaoSoIwQ/bINlV1YOGUywljUt+625GCdYC
	oeZErBYw==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfma1-00082h-Dc; Tue, 25 Jun 2019 14:37:54 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 11/16] mm: reorder code blocks in gup.c
Date: Tue, 25 Jun 2019 16:37:10 +0200
Message-Id: <20190625143715.1689-12-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190625143715.1689-1-hch@lst.de>
References: <20190625143715.1689-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This moves the actually exported functions towards the end of the file,
and reorders some functions to be in more logical blocks as a
preparation for moving various stubs inline into the main functionality
using IS_ENABLED().

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 410 +++++++++++++++++++++++++++----------------------------
 1 file changed, 205 insertions(+), 205 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 7328890ad8d3..b29249581672 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1100,86 +1100,6 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	return pages_done;
 }
 
-/*
- * We can leverage the VM_FAULT_RETRY functionality in the page fault
- * paths better by using either get_user_pages_locked() or
- * get_user_pages_unlocked().
- *
- * get_user_pages_locked() is suitable to replace the form:
- *
- *      down_read(&mm->mmap_sem);
- *      do_something()
- *      get_user_pages(tsk, mm, ..., pages, NULL);
- *      up_read(&mm->mmap_sem);
- *
- *  to:
- *
- *      int locked = 1;
- *      down_read(&mm->mmap_sem);
- *      do_something()
- *      get_user_pages_locked(tsk, mm, ..., pages, &locked);
- *      if (locked)
- *          up_read(&mm->mmap_sem);
- */
-long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-			   unsigned int gup_flags, struct page **pages,
-			   int *locked)
-{
-	/*
-	 * FIXME: Current FOLL_LONGTERM behavior is incompatible with
-	 * FAULT_FLAG_ALLOW_RETRY because of the FS DAX check requirement on
-	 * vmas.  As there are no users of this flag in this call we simply
-	 * disallow this option for now.
-	 */
-	if (WARN_ON_ONCE(gup_flags & FOLL_LONGTERM))
-		return -EINVAL;
-
-	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, NULL, locked,
-				       gup_flags | FOLL_TOUCH);
-}
-EXPORT_SYMBOL(get_user_pages_locked);
-
-/*
- * get_user_pages_unlocked() is suitable to replace the form:
- *
- *      down_read(&mm->mmap_sem);
- *      get_user_pages(tsk, mm, ..., pages, NULL);
- *      up_read(&mm->mmap_sem);
- *
- *  with:
- *
- *      get_user_pages_unlocked(tsk, mm, ..., pages);
- *
- * It is functionally equivalent to get_user_pages_fast so
- * get_user_pages_fast should be used instead if specific gup_flags
- * (e.g. FOLL_FORCE) are not required.
- */
-long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
-			     struct page **pages, unsigned int gup_flags)
-{
-	struct mm_struct *mm = current->mm;
-	int locked = 1;
-	long ret;
-
-	/*
-	 * FIXME: Current FOLL_LONGTERM behavior is incompatible with
-	 * FAULT_FLAG_ALLOW_RETRY because of the FS DAX check requirement on
-	 * vmas.  As there are no users of this flag in this call we simply
-	 * disallow this option for now.
-	 */
-	if (WARN_ON_ONCE(gup_flags & FOLL_LONGTERM))
-		return -EINVAL;
-
-	down_read(&mm->mmap_sem);
-	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
-				      &locked, gup_flags | FOLL_TOUCH);
-	if (locked)
-		up_read(&mm->mmap_sem);
-	return ret;
-}
-EXPORT_SYMBOL(get_user_pages_unlocked);
-
 /*
  * get_user_pages_remote() - pin user pages in memory
  * @tsk:	the task_struct to use for page fault accounting, or
@@ -1256,6 +1176,153 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages_remote);
 
+/**
+ * populate_vma_page_range() -  populate a range of pages in the vma.
+ * @vma:   target vma
+ * @start: start address
+ * @end:   end address
+ * @nonblocking:
+ *
+ * This takes care of mlocking the pages too if VM_LOCKED is set.
+ *
+ * return 0 on success, negative error code on error.
+ *
+ * vma->vm_mm->mmap_sem must be held.
+ *
+ * If @nonblocking is NULL, it may be held for read or write and will
+ * be unperturbed.
+ *
+ * If @nonblocking is non-NULL, it must held for read only and may be
+ * released.  If it's released, *@nonblocking will be set to 0.
+ */
+long populate_vma_page_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end, int *nonblocking)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long nr_pages = (end - start) / PAGE_SIZE;
+	int gup_flags;
+
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(end   & ~PAGE_MASK);
+	VM_BUG_ON_VMA(start < vma->vm_start, vma);
+	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
+	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+
+	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
+	if (vma->vm_flags & VM_LOCKONFAULT)
+		gup_flags &= ~FOLL_POPULATE;
+	/*
+	 * We want to touch writable mappings with a write fault in order
+	 * to break COW, except for shared mappings because these don't COW
+	 * and we would not want to dirty them for nothing.
+	 */
+	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
+		gup_flags |= FOLL_WRITE;
+
+	/*
+	 * We want mlock to succeed for regions that have any permissions
+	 * other than PROT_NONE.
+	 */
+	if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
+		gup_flags |= FOLL_FORCE;
+
+	/*
+	 * We made sure addr is within a VMA, so the following will
+	 * not result in a stack expansion that recurses back here.
+	 */
+	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
+				NULL, NULL, nonblocking);
+}
+
+/*
+ * __mm_populate - populate and/or mlock pages within a range of address space.
+ *
+ * This is used to implement mlock() and the MAP_POPULATE / MAP_LOCKED mmap
+ * flags. VMAs must be already marked with the desired vm_flags, and
+ * mmap_sem must not be held.
+ */
+int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long end, nstart, nend;
+	struct vm_area_struct *vma = NULL;
+	int locked = 0;
+	long ret = 0;
+
+	end = start + len;
+
+	for (nstart = start; nstart < end; nstart = nend) {
+		/*
+		 * We want to fault in pages for [nstart; end) address range.
+		 * Find first corresponding VMA.
+		 */
+		if (!locked) {
+			locked = 1;
+			down_read(&mm->mmap_sem);
+			vma = find_vma(mm, nstart);
+		} else if (nstart >= vma->vm_end)
+			vma = vma->vm_next;
+		if (!vma || vma->vm_start >= end)
+			break;
+		/*
+		 * Set [nstart; nend) to intersection of desired address
+		 * range with the first VMA. Also, skip undesirable VMA types.
+		 */
+		nend = min(end, vma->vm_end);
+		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
+			continue;
+		if (nstart < vma->vm_start)
+			nstart = vma->vm_start;
+		/*
+		 * Now fault in a range of pages. populate_vma_page_range()
+		 * double checks the vma flags, so that it won't mlock pages
+		 * if the vma was already munlocked.
+		 */
+		ret = populate_vma_page_range(vma, nstart, nend, &locked);
+		if (ret < 0) {
+			if (ignore_errors) {
+				ret = 0;
+				continue;	/* continue at next VMA */
+			}
+			break;
+		}
+		nend = nstart + ret * PAGE_SIZE;
+		ret = 0;
+	}
+	if (locked)
+		up_read(&mm->mmap_sem);
+	return ret;	/* 0 or negative error code */
+}
+
+/**
+ * get_dump_page() - pin user page in memory while writing it to core dump
+ * @addr: user address
+ *
+ * Returns struct page pointer of user page pinned for dump,
+ * to be freed afterwards by put_page().
+ *
+ * Returns NULL on any kind of failure - a hole must then be inserted into
+ * the corefile, to preserve alignment with its headers; and also returns
+ * NULL wherever the ZERO_PAGE, or an anonymous pte_none, has been found -
+ * allowing a hole to be left in the corefile to save diskspace.
+ *
+ * Called without mmap_sem, but after all other threads have been killed.
+ */
+#ifdef CONFIG_ELF_CORE
+struct page *get_dump_page(unsigned long addr)
+{
+	struct vm_area_struct *vma;
+	struct page *page;
+
+	if (__get_user_pages(current, current->mm, addr, 1,
+			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
+			     NULL) < 1)
+		return NULL;
+	flush_cache_page(vma, addr, page_to_pfn(page));
+	return page;
+}
+#endif /* CONFIG_ELF_CORE */
+
 #if defined(CONFIG_FS_DAX) || defined (CONFIG_CMA)
 static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
 {
@@ -1503,152 +1570,85 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 }
 EXPORT_SYMBOL(get_user_pages);
 
-/**
- * populate_vma_page_range() -  populate a range of pages in the vma.
- * @vma:   target vma
- * @start: start address
- * @end:   end address
- * @nonblocking:
- *
- * This takes care of mlocking the pages too if VM_LOCKED is set.
+/*
+ * We can leverage the VM_FAULT_RETRY functionality in the page fault
+ * paths better by using either get_user_pages_locked() or
+ * get_user_pages_unlocked().
  *
- * return 0 on success, negative error code on error.
+ * get_user_pages_locked() is suitable to replace the form:
  *
- * vma->vm_mm->mmap_sem must be held.
+ *      down_read(&mm->mmap_sem);
+ *      do_something()
+ *      get_user_pages(tsk, mm, ..., pages, NULL);
+ *      up_read(&mm->mmap_sem);
  *
- * If @nonblocking is NULL, it may be held for read or write and will
- * be unperturbed.
+ *  to:
  *
- * If @nonblocking is non-NULL, it must held for read only and may be
- * released.  If it's released, *@nonblocking will be set to 0.
+ *      int locked = 1;
+ *      down_read(&mm->mmap_sem);
+ *      do_something()
+ *      get_user_pages_locked(tsk, mm, ..., pages, &locked);
+ *      if (locked)
+ *          up_read(&mm->mmap_sem);
  */
-long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking)
+long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
+			   unsigned int gup_flags, struct page **pages,
+			   int *locked)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	unsigned long nr_pages = (end - start) / PAGE_SIZE;
-	int gup_flags;
-
-	VM_BUG_ON(start & ~PAGE_MASK);
-	VM_BUG_ON(end   & ~PAGE_MASK);
-	VM_BUG_ON_VMA(start < vma->vm_start, vma);
-	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
-
-	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
-	if (vma->vm_flags & VM_LOCKONFAULT)
-		gup_flags &= ~FOLL_POPULATE;
-	/*
-	 * We want to touch writable mappings with a write fault in order
-	 * to break COW, except for shared mappings because these don't COW
-	 * and we would not want to dirty them for nothing.
-	 */
-	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
-		gup_flags |= FOLL_WRITE;
-
 	/*
-	 * We want mlock to succeed for regions that have any permissions
-	 * other than PROT_NONE.
+	 * FIXME: Current FOLL_LONGTERM behavior is incompatible with
+	 * FAULT_FLAG_ALLOW_RETRY because of the FS DAX check requirement on
+	 * vmas.  As there are no users of this flag in this call we simply
+	 * disallow this option for now.
 	 */
-	if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
-		gup_flags |= FOLL_FORCE;
+	if (WARN_ON_ONCE(gup_flags & FOLL_LONGTERM))
+		return -EINVAL;
 
-	/*
-	 * We made sure addr is within a VMA, so the following will
-	 * not result in a stack expansion that recurses back here.
-	 */
-	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+	return __get_user_pages_locked(current, current->mm, start, nr_pages,
+				       pages, NULL, locked,
+				       gup_flags | FOLL_TOUCH);
 }
+EXPORT_SYMBOL(get_user_pages_locked);
 
 /*
- * __mm_populate - populate and/or mlock pages within a range of address space.
+ * get_user_pages_unlocked() is suitable to replace the form:
  *
- * This is used to implement mlock() and the MAP_POPULATE / MAP_LOCKED mmap
- * flags. VMAs must be already marked with the desired vm_flags, and
- * mmap_sem must not be held.
+ *      down_read(&mm->mmap_sem);
+ *      get_user_pages(tsk, mm, ..., pages, NULL);
+ *      up_read(&mm->mmap_sem);
+ *
+ *  with:
+ *
+ *      get_user_pages_unlocked(tsk, mm, ..., pages);
+ *
+ * It is functionally equivalent to get_user_pages_fast so
+ * get_user_pages_fast should be used instead if specific gup_flags
+ * (e.g. FOLL_FORCE) are not required.
  */
-int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
+long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
+			     struct page **pages, unsigned int gup_flags)
 {
 	struct mm_struct *mm = current->mm;
-	unsigned long end, nstart, nend;
-	struct vm_area_struct *vma = NULL;
-	int locked = 0;
-	long ret = 0;
+	int locked = 1;
+	long ret;
 
-	end = start + len;
+	/*
+	 * FIXME: Current FOLL_LONGTERM behavior is incompatible with
+	 * FAULT_FLAG_ALLOW_RETRY because of the FS DAX check requirement on
+	 * vmas.  As there are no users of this flag in this call we simply
+	 * disallow this option for now.
+	 */
+	if (WARN_ON_ONCE(gup_flags & FOLL_LONGTERM))
+		return -EINVAL;
 
-	for (nstart = start; nstart < end; nstart = nend) {
-		/*
-		 * We want to fault in pages for [nstart; end) address range.
-		 * Find first corresponding VMA.
-		 */
-		if (!locked) {
-			locked = 1;
-			down_read(&mm->mmap_sem);
-			vma = find_vma(mm, nstart);
-		} else if (nstart >= vma->vm_end)
-			vma = vma->vm_next;
-		if (!vma || vma->vm_start >= end)
-			break;
-		/*
-		 * Set [nstart; nend) to intersection of desired address
-		 * range with the first VMA. Also, skip undesirable VMA types.
-		 */
-		nend = min(end, vma->vm_end);
-		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
-			continue;
-		if (nstart < vma->vm_start)
-			nstart = vma->vm_start;
-		/*
-		 * Now fault in a range of pages. populate_vma_page_range()
-		 * double checks the vma flags, so that it won't mlock pages
-		 * if the vma was already munlocked.
-		 */
-		ret = populate_vma_page_range(vma, nstart, nend, &locked);
-		if (ret < 0) {
-			if (ignore_errors) {
-				ret = 0;
-				continue;	/* continue at next VMA */
-			}
-			break;
-		}
-		nend = nstart + ret * PAGE_SIZE;
-		ret = 0;
-	}
+	down_read(&mm->mmap_sem);
+	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
+				      &locked, gup_flags | FOLL_TOUCH);
 	if (locked)
 		up_read(&mm->mmap_sem);
-	return ret;	/* 0 or negative error code */
-}
-
-/**
- * get_dump_page() - pin user page in memory while writing it to core dump
- * @addr: user address
- *
- * Returns struct page pointer of user page pinned for dump,
- * to be freed afterwards by put_page().
- *
- * Returns NULL on any kind of failure - a hole must then be inserted into
- * the corefile, to preserve alignment with its headers; and also returns
- * NULL wherever the ZERO_PAGE, or an anonymous pte_none, has been found -
- * allowing a hole to be left in the corefile to save diskspace.
- *
- * Called without mmap_sem, but after all other threads have been killed.
- */
-#ifdef CONFIG_ELF_CORE
-struct page *get_dump_page(unsigned long addr)
-{
-	struct vm_area_struct *vma;
-	struct page *page;
-
-	if (__get_user_pages(current, current->mm, addr, 1,
-			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
-			     NULL) < 1)
-		return NULL;
-	flush_cache_page(vma, addr, page_to_pfn(page));
-	return page;
+	return ret;
 }
-#endif /* CONFIG_ELF_CORE */
+EXPORT_SYMBOL(get_user_pages_unlocked);
 
 /*
  * Fast GUP
-- 
2.20.1

