Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A208FC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:38:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5918221743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:38:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fjQXRT7z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5918221743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0AB96B0010; Fri,  9 Aug 2019 15:38:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBB766B0266; Fri,  9 Aug 2019 15:38:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD1AF6B0269; Fri,  9 Aug 2019 15:38:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6B706B0010
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 15:38:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so62013447pfo.22
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 12:38:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MDH32Eb2EsVoWN0MXbMYjrn01uIbGH76CPmS0+EJY+0=;
        b=OeLeA0dX9sWweALDHBvxe4dC2t1Y7SqGRGl8OLYg6qpcc3IUY5UQQe5mQ+YpG1woza
         yuCQOIBcRkZoLm3/Gzv/Mc3xW15AB6X6IaBEdnnDCI/PrvrvokPVOyLxYx3zrjdB1jtX
         e0Prg6EjN6PKjMeMjY4i8k4rbm68rwNcXmmajrR40j8T7YFaxpxSyHPz6mxp8P01vM19
         VshHJ9WgweZ1Hw6WtbOD4cErGWhavspkKOLa7rW5sx2ehgbeuEs06Yu14D6w5xYBvKie
         fs8P3e1mjWl/IvWPHWJolPaBVESLKETiu5utQusjIxAtNN0d/TqQsIYF5aO7s3yloKsw
         jx+Q==
X-Gm-Message-State: APjAAAVWZSsB9MOfwlum41EsvBRiACBC3iOGAOQgfk/9VtD9nf3boPT3
	8lMaaExbhquunUQdBuGKyY2ERZGGDJo8kLFLxzAc+LbL4dDaS6qhyVJu9AJ5vW3VH/MyImd4VO2
	wKdFnP2jR8vLO3o53HHCY3vVdAg/kVTg2dkmPbyiDLvf1SjXuPoph1khhEXn4++TRIQ==
X-Received: by 2002:a17:902:461:: with SMTP id 88mr10441510ple.296.1565379530260;
        Fri, 09 Aug 2019 12:38:50 -0700 (PDT)
X-Received: by 2002:a17:902:461:: with SMTP id 88mr10441452ple.296.1565379529043;
        Fri, 09 Aug 2019 12:38:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565379529; cv=none;
        d=google.com; s=arc-20160816;
        b=LzPZ8Berx9cx+dLL7G6UpUGUhiymKxjIxJqGROp5D5fSlCMQON3+k5fmiofCMcKfXX
         yo2r2bQgMXSopx0FJUesi9vTqNJajAoP8Pagsf11c07hks7xbru+AkiwyEDxf7d5yYi7
         8SyUFib5n6ujVDK0MN56X8at997VsoHZQKnMCgWW/rKS3lgMUVYUG459nNyl/fcyK6jM
         6YxiSNw5nSpeBQgzGuNjRpJF/UvYnwoOOjGNZdlHxOWdzapaTRAgHTsvPmbRQ9c5pd1+
         Uk1jSJXBouFn9xWjzjB39VuE49CChRNCfTiWQLbD7QKJ50xnVLyeJIESaeqYp9qYGJZn
         dTyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MDH32Eb2EsVoWN0MXbMYjrn01uIbGH76CPmS0+EJY+0=;
        b=ccDBuwcAbHG0j2fD0p8MJYvq49sPk43zLzBrcLWABz4pHvcdMxfNiC+s2ewjrrEbci
         soULESkWXlWfABrVf817LD7dsVIwo94AuC1uSel7TZGT4Y4ikTbM+LcYJ0CnIaMldFZG
         o+yLoH6TmLfI8s8tNWEoXIuhX0r4tbEcO2ksOV26PhF6zL6AA09qGHdJOTdsy9So4hgP
         ObYz8GJS30nCLa8fE1tMaAU3HKYnk7gPtmEuvPhQ9c4OqUSH8WxhBmBxNqe0XhURt/L5
         cgAx4X3ZpW+QXty4LprPWluKQpDnt5wiSzpGi0A/qnubqJY9/uzZ1agtGTtNKpa7mV0w
         Y+Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fjQXRT7z;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m32sor2866950pld.32.2019.08.09.12.38.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 12:38:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fjQXRT7z;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MDH32Eb2EsVoWN0MXbMYjrn01uIbGH76CPmS0+EJY+0=;
        b=fjQXRT7z3HfU8sTIV2yuaYj8PzDfGZROgaWp60jM+JnihJ/kyzGTHWmQ/bXjnIClJ0
         MmZsUieE092o9umktbwoDdAy12cOUCUSJLSU8MTTvm55NhiFCs2tkPFrOe0r7fh1iACs
         3HmicxUyY+G1p2B6DXDkxaEolJdR5OH07iCOGGGvfCP/6mXfKtTuAorj9GHI+IgLEXwo
         Udg3/eW66XNeabPwgXx8Z4YOXfx/DFqIdUNVpwnMl9UOZM/2kgP9Q5qv9tdYD4NyXdRl
         dI8+Wtr85OxiVjhzmdzR2ceGZCQUnjXGcVtt7B1Z8i2hFeHESNwPSIct77ERN66HRVnQ
         Tp3g==
X-Google-Smtp-Source: APXvYqyQyjzHxcq7DVq0p2fNrfoKRrky/xSKCs2lWY5RLOGbch07vObsvJo6EpCvoynHs6HcvKmu+w==
X-Received: by 2002:a17:902:f095:: with SMTP id go21mr20967082plb.58.1565379528726;
        Fri, 09 Aug 2019 12:38:48 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([2401:4900:277d:9fe5:c098:ab6c:e50:f58c])
        by smtp.gmail.com with ESMTPSA id j1sm131433484pgl.12.2019.08.09.12.38.47
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Aug 2019 12:38:48 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: jhubbard@nvidia.com,
	gregkh@linuxfoundation.org,
	sivanich@sgi.com,
	arnd@arndb.de
Cc: ira.weiny@intel.com,
	jglisse@redhat.com,
	william.kucharski@oracle.com,
	hch@lst.de,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [Linux-kernel-mentees][PATCH v5 1/1] sgi-gru: Remove *pte_lookup functions, Convert to get_user_page*()
Date: Sat, 10 Aug 2019 01:08:17 +0530
Message-Id: <1565379497-29266-2-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1565379497-29266-1-git-send-email-linux.bhar@gmail.com>
References: <1565379497-29266-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

As part of this conversion, the *pte_lookup functions can be removed and
be easily replaced with get_user_pages_fast() functions. In the case of
atomic lookup, __get_user_pages_fast() is used, because it does not fall
back to the slow path: get_user_pages(). get_user_pages_fast(), on the other
hand, first calls __get_user_pages_fast(), but then falls back to the
slow path if __get_user_pages_fast() fails.

Also: remove unnecessary CONFIG_HUGETLB ifdefs.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: William Kucharski <william.kucharski@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel-mentees@lists.linuxfoundation.org
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
This is a fold of the 3 patches in the v2 patch series.
The review tags were given to the individual patches.

Changes since v3
	- Used gup flags in get_user_pages_fast rather than
	boolean flags.
Changes since v4
	- Updated changelog according to John Hubbard.
---
 drivers/misc/sgi-gru/grufault.c | 112 +++++++++-------------------------------
 1 file changed, 24 insertions(+), 88 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 4b713a8..304e9c5 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -166,96 +166,20 @@ static void get_clear_fault_map(struct gru_state *gru,
 }
 
 /*
- * Atomic (interrupt context) & non-atomic (user context) functions to
- * convert a vaddr into a physical address. The size of the page
- * is returned in pageshift.
- * 	returns:
- * 		  0 - successful
- * 		< 0 - error code
- * 		  1 - (atomic only) try again in non-atomic context
- */
-static int non_atomic_pte_lookup(struct vm_area_struct *vma,
-				 unsigned long vaddr, int write,
-				 unsigned long *paddr, int *pageshift)
-{
-	struct page *page;
-
-#ifdef CONFIG_HUGETLB_PAGE
-	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift = PAGE_SHIFT;
-#endif
-	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
-		return -EFAULT;
-	*paddr = page_to_phys(page);
-	put_page(page);
-	return 0;
-}
-
-/*
- * atomic_pte_lookup
+ * mmap_sem is already helod on entry to this function. This guarantees
+ * existence of the page tables.
  *
- * Convert a user virtual address to a physical address
  * Only supports Intel large pages (2MB only) on x86_64.
- *	ZZZ - hugepage support is incomplete
- *
- * NOTE: mmap_sem is already held on entry to this function. This
- * guarantees existence of the page tables.
+ *	ZZZ - hugepage support is incomplete.
  */
-static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
-	int write, unsigned long *paddr, int *pageshift)
-{
-	pgd_t *pgdp;
-	p4d_t *p4dp;
-	pud_t *pudp;
-	pmd_t *pmdp;
-	pte_t pte;
-
-	pgdp = pgd_offset(vma->vm_mm, vaddr);
-	if (unlikely(pgd_none(*pgdp)))
-		goto err;
-
-	p4dp = p4d_offset(pgdp, vaddr);
-	if (unlikely(p4d_none(*p4dp)))
-		goto err;
-
-	pudp = pud_offset(p4dp, vaddr);
-	if (unlikely(pud_none(*pudp)))
-		goto err;
-
-	pmdp = pmd_offset(pudp, vaddr);
-	if (unlikely(pmd_none(*pmdp)))
-		goto err;
-#ifdef CONFIG_X86_64
-	if (unlikely(pmd_large(*pmdp)))
-		pte = *(pte_t *) pmdp;
-	else
-#endif
-		pte = *pte_offset_kernel(pmdp, vaddr);
-
-	if (unlikely(!pte_present(pte) ||
-		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
-		return 1;
-
-	*paddr = pte_pfn(pte) << PAGE_SHIFT;
-#ifdef CONFIG_HUGETLB_PAGE
-	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift = PAGE_SHIFT;
-#endif
-	return 0;
-
-err:
-	return 1;
-}
-
 static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 		    int write, int atomic, unsigned long *gpa, int *pageshift)
 {
 	struct mm_struct *mm = gts->ts_mm;
 	struct vm_area_struct *vma;
 	unsigned long paddr;
-	int ret, ps;
+	int ret;
+	struct page *page;
 
 	vma = find_vma(mm, vaddr);
 	if (!vma)
@@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 
 	/*
 	 * Atomic lookup is faster & usually works even if called in non-atomic
-	 * context.
+	 * context. get_user_pages_fast does atomic lookup before falling back to
+	 * slow gup.
 	 */
 	rmb();	/* Must/check ms_range_active before loading PTEs */
-	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
-	if (ret) {
-		if (atomic)
+	if (atomic) {
+		ret = __get_user_pages_fast(vaddr, 1, write, &page);
+		if (!ret)
 			goto upm;
-		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
+	} else {
+		ret = get_user_pages_fast(vaddr, 1, write ? FOLL_WRITE : 0, &page);
+		if (!ret)
 			goto inval;
 	}
+
+	paddr = page_to_phys(page);
+	put_user_page(page);
+
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		*pageshift = HPAGE_SHIFT;
+	else
+		*pageshift = PAGE_SHIFT;
+
 	if (is_gru_paddr(paddr))
 		goto inval;
-	paddr = paddr & ~((1UL << ps) - 1);
+	paddr = paddr & ~((1UL << *pageshift) - 1);
 	*gpa = uv_soc_phys_ram_to_gpa(paddr);
-	*pageshift = ps;
+
 	return VTOP_SUCCESS;
 
 inval:
-- 
2.7.4

