Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29380C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 06:43:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD8FE20896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 06:43:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="xW5/H8GC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD8FE20896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 755DC6B0006; Wed, 12 Jun 2019 02:43:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 705B16B0007; Wed, 12 Jun 2019 02:43:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57EED6B0008; Wed, 12 Jun 2019 02:43:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC8E06B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:43:23 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id a25so2394444lfl.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 23:43:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3Sclql3dvSZFf/V+1y7l8v94/Rp4TDjyKr6qABVkiR4=;
        b=Nsc+OWtHFoZ6gRv4hHhx7+lsEFmCc6w0Ofvx3fIxW8cJB+ucO0xjzEoCXfipFl5Le/
         fKrV+vSvYh54HHdykO6eMKYpyYreLFuq0Ss2VVWvHDTvb2wNH7kwKysALR7VzIl+RJKq
         6Gv7Vdl9XbF/MZe4WcCe+cnWg5MNl18N7j1wMcwY4QNRxHa9SevOmG2x8cba86w5In76
         Qy0i/5keZhpPgJICJDgVGQUx0vNu/s2qRCFwx/PwhcQnTxlRWdPO2V3zAVF/iQfB3tci
         eA8LO5SpsQ6eDClbzs1KXTBGkZcyWG8SNK/Lc6YgpXa2MhEtQl2qkHgbsIwHOiQSZ/xK
         wPag==
X-Gm-Message-State: APjAAAVE95WEeW4Te2Gt9bUoFiVh4LxWy2W3BWDYjdo3pwxLTV1GEkBr
	D0rCF8R14es11J0rCD64uHUf4HtOC7IcXHzQCDvxWet/wXVKQlwdjw5Oumr3WE6HHEFgzPfZW6T
	RX9nihg/NevmQ1OGmcRVZcGgh48ftxEa5+nIFj5XdM+lsmT3Fh9ROQcOGTUegQbgDAw==
X-Received: by 2002:a2e:3807:: with SMTP id f7mr3069761lja.87.1560321803300;
        Tue, 11 Jun 2019 23:43:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6LlQhbb1s/P7dTZpUMEhMRQOuJfzE8SNKeCEG2ffcPwY/aumAipcEOAwTfOJS4rgkOTlY
X-Received: by 2002:a2e:3807:: with SMTP id f7mr3069686lja.87.1560321801805;
        Tue, 11 Jun 2019 23:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560321801; cv=none;
        d=google.com; s=arc-20160816;
        b=mfs75GvZFSHs2rfMwsJDKZnDiiLSIzHHRbn7SyO0/m0WCuL+F3dob7nTGNIL+i9BSV
         4qrLx7mmZzWObTtCHmPuR02DfF/X6HXPch1iVYNUlcB/ja9or5ytCPtxhynt50KF3l8v
         EHHRrDxPTLwtvb6g60KsX4AJYl6F5DEwP1CDO2Q9PRUPW4FpXoTUiWGnbBfaBvoJ0gVg
         IXwiTFt538VZKEHMzSSTauk/h8Di3EdfSLPd8cVHC+DmDmU0ZlIeJplP7L6kgWiLyZ5+
         3mVSTVezLtTFMip8XwP3RLVdFmMme9KJJevwp7HCkt/FETBAfaEgKU8A1uSMblz6zpVT
         sAeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3Sclql3dvSZFf/V+1y7l8v94/Rp4TDjyKr6qABVkiR4=;
        b=vU6aX7ujINWzc1FyCoWUavxjhyCPBU/v+TKvZ1tiH8Fy0170S3IMtl47Br2CUhbjNK
         vLfZTj7navGAsMLKBdF7ht6aoMEXbAYvQ0Drvql7bP/ZUNQaMG27Jl+RdyDFrko8jqeZ
         Ee0IHmIak524bsihTQc9M765apeqC+RlUhEUw2UEzSvB6fyd78Q4rEfgzIXyzf4Mw0Ls
         FSR+B7mRfwGJgayVwtt8vpJMWwPCGdxLxpMSc5Uk287CQ+m+l4oRvSCv+3evQfH6ee1w
         lM0iYGgJe9ITQHvSoRJZKo6NLq8F60OKalYe3vXvFR8TePoVn+2afLPCKjpOMvD7ICRi
         1vjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b="xW5/H8GC";
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from pio-pvt-msa3.bahnhof.se (pio-pvt-msa3.bahnhof.se. [79.136.2.42])
        by mx.google.com with ESMTPS id v3si15247541ljk.209.2019.06.11.23.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 23:43:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) client-ip=79.136.2.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b="xW5/H8GC";
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTP id 3950B3F885;
	Wed, 12 Jun 2019 08:43:11 +0200 (CEST)
Authentication-Results: pio-pvt-msa3.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=xW5/H8GC;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa3.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa3.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tFDl-1s-1ixU; Wed, 12 Jun 2019 08:42:56 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTPA id 79E453F6E1;
	Wed, 12 Jun 2019 08:42:55 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 139DB361C0E;
	Wed, 12 Jun 2019 08:42:55 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560321775;
	bh=MG0HfLcgqDRwxcPIDolCLkQDrfh6DF2qVfbCiXX/p4A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=xW5/H8GCfVeh6cQAEEKnLJFmOV0O0Slb48mjCJa2lxw3Iu2m4KMvS3rtq8csRyscV
	 55f/lFIA3PEHvLk7d6Jrj5sCcyrIYdUYKFPSJ984jBrHfoKecQO8V5AeDaG8M0Gik4
	 5I9de2G+27EiihhanIg/8YAWRMJHefWimrSHPJVM=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	nadav.amit@gmail.com,
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
Subject: [PATCH v5 2/9] mm: Add an apply_to_pfn_range interface
Date: Wed, 12 Jun 2019 08:42:36 +0200
Message-Id: <20190612064243.55340-3-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190612064243.55340-1-thellstrom@vmwopensource.org>
References: <20190612064243.55340-1-thellstrom@vmwopensource.org>
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

