Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12E9AC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF53720673
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="RyARfwIF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF53720673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 834996B000C; Tue, 11 Jun 2019 08:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D2D86B000A; Tue, 11 Jun 2019 08:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 001AD6B000C; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DBE86B000C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 77so278217ljf.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3Sclql3dvSZFf/V+1y7l8v94/Rp4TDjyKr6qABVkiR4=;
        b=TKvUQwd1iHEJocqPFUX09RII+xV7zJcAeMybXWURmbIvWJM7VXsytJHZC2EKQyaBLz
         BNr5jFPzWZUEvSgb7pSCfm/+8q9TVTVZ2x6Z15osL3rDYfiTOYLZc9o+nSQOBCO2RmZ2
         LpHPSBF++bamzqm+2DUr7wU13j2Bwf7IEDnxYQeNPVfFW16FZYeZihGLKJSefbyjbwBP
         FYLKuZe12P046kKEf7+zz76eF9XB02qQIPXeM6hWNybAyL9Y0m5WmW/wQ/dzdbxWNMuD
         ZgsLcXmQHbSvZSM4jhH95WvO1HdcoogbYgrT0HoOD3rAD6OrQqRII26UF3FjJfk/OVuQ
         TFVQ==
X-Gm-Message-State: APjAAAUAPehHsEGO/Hp6TKr3X4ilRIKLfA4QKXBXDxjOOpnAQniCOGW9
	FlFGPJzXFU04O4zCZJ6YUAANJM1Cge5psnmhpynjyJiGpylRQI17tAPclX/1ZUmadd+Dhu/m4cy
	IlIDgLF89X246lSWrnfChPaEVZJtq4N+93ho+AcqMpboU7kGRg3TFOV32Wq24aWLUIQ==
X-Received: by 2002:a19:6a01:: with SMTP id u1mr35923008lfu.141.1560255930716;
        Tue, 11 Jun 2019 05:25:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfctutclmxsP5Z+/CP7ELukYeOltzi+qHYpX5QmHy2GEYHtL6EqSfNs4UYuOtBNGx/yN7Y
X-Received: by 2002:a19:6a01:: with SMTP id u1mr35922964lfu.141.1560255929605;
        Tue, 11 Jun 2019 05:25:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560255929; cv=none;
        d=google.com; s=arc-20160816;
        b=xg4UNRaW023FTGmBiJYI3JH/PyzFVouNo0aMVs14Faf7NsI7PpEafT6MPdYcLgW+WL
         2RFo6X0dYTn92FqPRa+gtzZBrf++w/jPXX2y8DKN194xQgpG1lH9yD5tC1XvRuCCPRUi
         XT8ox7bbMG8wNuvsztEjS48v0bWWDyP3y8GSgEE/uqiSFqvFggzd9jQM+yogAvh87mD9
         tWic0UNNvrZaCYQ4m3zUxciGKSHVaLKRRs6AlSJzOImor4y3jbxMpH23k7/+KQopUewl
         WxObuLqD8Jm/JoOXr3ZXr+G5NHinSNsgNPAJAhL0D/ENCe/+fctckTb+INv9t5rh4psv
         5oDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3Sclql3dvSZFf/V+1y7l8v94/Rp4TDjyKr6qABVkiR4=;
        b=lSsOriF4WoaIL6fPa3qJxJaCo/yNulab6HsyrENumPUSrO9Lry1COKg8z5C88ndlFC
         oBcvsvtwP3CUf42QEyzaKg0ysV/ZI2qrLsv/uuRKZqJQ8Y5yg+ZW9+JqwPGXNzPGagiC
         zDDDLi3XsfHI2kkGUr45NN9OyLkXJeDHd4z/B1zQad2RVxmRLlQgrB+9y5o6NSyB0mhx
         hliaftMoQuQxZhUMOx9PGEkFAKKZTyFIDguIxNROnZnjjm6A5SroQNTmupXZIhnOUrtB
         EvjRi0aluxKAvZ6WGGpy/2Gocli/pK5Q7jwupApF36Ci/Z1L0zGLPtzXmrsUtrg3oDaH
         TI0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=RyARfwIF;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se (ste-pvt-msa2.bahnhof.se. [213.80.101.71])
        by mx.google.com with ESMTPS id m64si11292107lje.200.2019.06.11.05.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:25:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) client-ip=213.80.101.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=RyARfwIF;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 148373F633;
	Tue, 11 Jun 2019 14:25:24 +0200 (CEST)
Authentication-Results: ste-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=RyARfwIF;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Authentication-Results: ste-ftg-msa2.bahnhof.se (amavisd-new);
	dkim=pass (1024-bit key) header.d=vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (ste-ftg-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CXn9JH6tdl4E; Tue, 11 Jun 2019 14:25:09 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id 8F91C3F566;
	Tue, 11 Jun 2019 14:25:08 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 47F1A3619F7;
	Tue, 11 Jun 2019 14:25:08 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560255908;
	bh=MG0HfLcgqDRwxcPIDolCLkQDrfh6DF2qVfbCiXX/p4A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=RyARfwIFJWOrkzXAOtSGCWJOroGc1STB77+TLw3mEE8m34xj5NYLlh7EeJffzNfQN
	 brhdf7u4OLw5jNY+7WcaqDYY+6rLRmBeY5HuSI/P2Z+HEDoUi9uBB2PAzmYVkR0goB
	 8cwe8pJKQvaUXg1idEnSACT2ivHkZnc1DFEGAUC4=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH v4 2/9] mm: Add an apply_to_pfn_range interface
Date: Tue, 11 Jun 2019 14:24:47 +0200
Message-Id: <20190611122454.3075-3-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611122454.3075-1-thellstrom@vmwopensource.org>
References: <20190611122454.3075-1-thellstrom@vmwopensource.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstrom <thellstrom@vmware.com>

This is basically apply_to_page_range with added functionality:
Allocating missing parts of the page table becomes optional, which
means that the function can be guaranteed not to error if allocation
is disabled. Also passing of the closure struct and callback function
becomes different and more in line with how things are done elsewhere.

Finally we keep apply_to_page_range as a wrapper around apply_to_pfn_range

The reason for not using the page-walk code is that we want to perform
the page-walk on vmas pointing to an address space without requiring the
mmap_sem to be held rather than on vmas belonging to a process with the
mmap_sem held.

Notable changes since RFC:
Don't export apply_to_pfn range.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
---
 include/linux/mm.h |  10 ++++
 mm/memory.c        | 135 ++++++++++++++++++++++++++++++++++-----------
 2 files changed, 113 insertions(+), 32 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..3d06ce2a64af 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2675,6 +2675,16 @@ typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
+struct pfn_range_apply;
+typedef int (*pter_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
+			 struct pfn_range_apply *closure);
+struct pfn_range_apply {
+	struct mm_struct *mm;
+	pter_fn_t ptefn;
+	unsigned int alloc;
+};
+extern int apply_to_pfn_range(struct pfn_range_apply *closure,
+			      unsigned long address, unsigned long size);
 
 #ifdef CONFIG_PAGE_POISONING
 extern bool page_poisoning_enabled(void);
diff --git a/mm/memory.c b/mm/memory.c
index 168f546af1ad..462aa47f8878 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2032,18 +2032,17 @@ int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long
 }
 EXPORT_SYMBOL(vm_iomap_memory);
 
-static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+static int apply_to_pte_range(struct pfn_range_apply *closure, pmd_t *pmd,
+			      unsigned long addr, unsigned long end)
 {
 	pte_t *pte;
 	int err;
 	pgtable_t token;
 	spinlock_t *uninitialized_var(ptl);
 
-	pte = (mm == &init_mm) ?
+	pte = (closure->mm == &init_mm) ?
 		pte_alloc_kernel(pmd, addr) :
-		pte_alloc_map_lock(mm, pmd, addr, &ptl);
+		pte_alloc_map_lock(closure->mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
 
@@ -2054,86 +2053,109 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	token = pmd_pgtable(*pmd);
 
 	do {
-		err = fn(pte++, token, addr, data);
+		err = closure->ptefn(pte++, token, addr, closure);
 		if (err)
 			break;
 	} while (addr += PAGE_SIZE, addr != end);
 
 	arch_leave_lazy_mmu_mode();
 
-	if (mm != &init_mm)
+	if (closure->mm != &init_mm)
 		pte_unmap_unlock(pte-1, ptl);
 	return err;
 }
 
-static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+static int apply_to_pmd_range(struct pfn_range_apply *closure, pud_t *pud,
+			      unsigned long addr, unsigned long end)
 {
 	pmd_t *pmd;
 	unsigned long next;
-	int err;
+	int err = 0;
 
 	BUG_ON(pud_huge(*pud));
 
-	pmd = pmd_alloc(mm, pud, addr);
+	pmd = pmd_alloc(closure->mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;
+
 	do {
 		next = pmd_addr_end(addr, end);
-		err = apply_to_pte_range(mm, pmd, addr, next, fn, data);
+		if (!closure->alloc && pmd_none_or_clear_bad(pmd))
+			continue;
+		err = apply_to_pte_range(closure, pmd, addr, next);
 		if (err)
 			break;
 	} while (pmd++, addr = next, addr != end);
 	return err;
 }
 
-static int apply_to_pud_range(struct mm_struct *mm, p4d_t *p4d,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+static int apply_to_pud_range(struct pfn_range_apply *closure, p4d_t *p4d,
+			      unsigned long addr, unsigned long end)
 {
 	pud_t *pud;
 	unsigned long next;
-	int err;
+	int err = 0;
 
-	pud = pud_alloc(mm, p4d, addr);
+	pud = pud_alloc(closure->mm, p4d, addr);
 	if (!pud)
 		return -ENOMEM;
+
 	do {
 		next = pud_addr_end(addr, end);
-		err = apply_to_pmd_range(mm, pud, addr, next, fn, data);
+		if (!closure->alloc && pud_none_or_clear_bad(pud))
+			continue;
+		err = apply_to_pmd_range(closure, pud, addr, next);
 		if (err)
 			break;
 	} while (pud++, addr = next, addr != end);
 	return err;
 }
 
-static int apply_to_p4d_range(struct mm_struct *mm, pgd_t *pgd,
-				     unsigned long addr, unsigned long end,
-				     pte_fn_t fn, void *data)
+static int apply_to_p4d_range(struct pfn_range_apply *closure, pgd_t *pgd,
+			      unsigned long addr, unsigned long end)
 {
 	p4d_t *p4d;
 	unsigned long next;
-	int err;
+	int err = 0;
 
-	p4d = p4d_alloc(mm, pgd, addr);
+	p4d = p4d_alloc(closure->mm, pgd, addr);
 	if (!p4d)
 		return -ENOMEM;
+
 	do {
 		next = p4d_addr_end(addr, end);
-		err = apply_to_pud_range(mm, p4d, addr, next, fn, data);
+		if (!closure->alloc && p4d_none_or_clear_bad(p4d))
+			continue;
+		err = apply_to_pud_range(closure, p4d, addr, next);
 		if (err)
 			break;
 	} while (p4d++, addr = next, addr != end);
 	return err;
 }
 
-/*
- * Scan a region of virtual memory, filling in page tables as necessary
- * and calling a provided function on each leaf page table.
+/**
+ * apply_to_pfn_range - Scan a region of virtual memory, calling a provided
+ * function on each leaf page table entry
+ * @closure: Details about how to scan and what function to apply
+ * @addr: Start virtual address
+ * @size: Size of the region
+ *
+ * If @closure->alloc is set to 1, the function will fill in the page table
+ * as necessary. Otherwise it will skip non-present parts.
+ * Note: The caller must ensure that the range does not contain huge pages.
+ * The caller must also assure that the proper mmu_notifier functions are
+ * called before and after the call to apply_to_pfn_range.
+ *
+ * WARNING: Do not use this function unless you know exactly what you are
+ * doing. It is lacking support for huge pages and transparent huge pages.
+ *
+ * Return: Zero on success. If the provided function returns a non-zero status,
+ * the page table walk will terminate and that status will be returned.
+ * If @closure->alloc is set to 1, then this function may also return memory
+ * allocation errors arising from allocating page table memory.
  */
-int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
-			unsigned long size, pte_fn_t fn, void *data)
+int apply_to_pfn_range(struct pfn_range_apply *closure,
+		       unsigned long addr, unsigned long size)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -2143,16 +2165,65 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 	if (WARN_ON(addr >= end))
 		return -EINVAL;
 
-	pgd = pgd_offset(mm, addr);
+	pgd = pgd_offset(closure->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = apply_to_p4d_range(mm, pgd, addr, next, fn, data);
+		if (!closure->alloc && pgd_none_or_clear_bad(pgd))
+			continue;
+		err = apply_to_p4d_range(closure, pgd, addr, next);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
 
 	return err;
 }
+
+/**
+ * struct page_range_apply - Closure structure for apply_to_page_range()
+ * @pter: The base closure structure we derive from
+ * @fn: The leaf pte function to call
+ * @data: The leaf pte function closure
+ */
+struct page_range_apply {
+	struct pfn_range_apply pter;
+	pte_fn_t fn;
+	void *data;
+};
+
+/*
+ * Callback wrapper to enable use of apply_to_pfn_range for
+ * the apply_to_page_range interface
+ */
+static int apply_to_page_range_wrapper(pte_t *pte, pgtable_t token,
+				       unsigned long addr,
+				       struct pfn_range_apply *pter)
+{
+	struct page_range_apply *pra =
+		container_of(pter, typeof(*pra), pter);
+
+	return pra->fn(pte, token, addr, pra->data);
+}
+
+/*
+ * Scan a region of virtual memory, filling in page tables as necessary
+ * and calling a provided function on each leaf page table.
+ *
+ * WARNING: Do not use this function unless you know exactly what you are
+ * doing. It is lacking support for huge pages and transparent huge pages.
+ */
+int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
+			unsigned long size, pte_fn_t fn, void *data)
+{
+	struct page_range_apply pra = {
+		.pter = {.mm = mm,
+			 .alloc = 1,
+			 .ptefn = apply_to_page_range_wrapper },
+		.fn = fn,
+		.data = data
+	};
+
+	return apply_to_pfn_range(&pra.pter, addr, size);
+}
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
 /*
-- 
2.20.1

