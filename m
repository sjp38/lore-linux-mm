Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00006C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:23:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5C472184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:23:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5C472184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C8AD6B0006; Wed, 20 Mar 2019 11:23:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 351526B0007; Wed, 20 Mar 2019 11:23:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EEE66B0008; Wed, 20 Mar 2019 11:23:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D01A06B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:23:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t5so2832649pfh.18
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:23:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=y8htJanxmbFoZO20cRMOpqM+VW4C4SEBRSZ+uu5QWy8=;
        b=pr+RRkEcnnTDY3soE3CS1024SYb15J6bKcnbmIGfUdlZgh5ZJbIkUUYYMMTLca1hiN
         zIkorzWXF8Zrn4j3ncsHIpALjisNzByXZpgCYUHGAZC0OW3mDoy1DZKSJIXiCJWSTCQz
         xbziCE6A9QIFtOIHuwf/BTxmVAr1NntdiN1KCICAJ1uyPErYQrp6WdL+RXOQTt9oi2ja
         AtpcTADs8Q0GB5zswzLE0K/hQbulWx7pXz4fSJBflByuyLa/u5tOjO0Fghw1Jz1+b89l
         ZYK7yapzRMJTtNRDrsCgkCt8EprXWo79Hqn7hkqF5oAQFHi1k40a+1QqdC58kzpkenS8
         5eRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUQVjx55tvRtoE39lOEXE7gM9cWNT+7Hup4dg//XCcL4o1z57+/
	tT6RqHwi8jZFoMH+fl1cfL8cjwu3O3kZVPCgNqR5GbFf/g3D2PtRKjsWpln/dy/7DE4uW9Xkds2
	UkuUEAyjoLT1pirMmW4a/6pZnDF47sKjQsPsdW/yUeBFkPgSyfaT4c6c8KgP4n33Nfg==
X-Received: by 2002:aa7:8117:: with SMTP id b23mr8872983pfi.2.1553095431342;
        Wed, 20 Mar 2019 08:23:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwRudKGtckNKnATbOIUApz7bmdGt4swBE30NsStMJucjBB2wz3TmnxiDPXr9CNpwlLCjYM
X-Received: by 2002:aa7:8117:: with SMTP id b23mr8872835pfi.2.1553095429649;
        Wed, 20 Mar 2019 08:23:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553095429; cv=none;
        d=google.com; s=arc-20160816;
        b=WK2yXT7lF8/ffOm5l2xzzs7it61VPC5LPKabIDl1NAghEPgnG/PZqnO863YPYr3D6P
         e0JF8ntZdQQvVSRzEZJY6tr8NMkg2UKKwyyy0EVR30Wm6N/QsrqNogzGk4Q93yvp2e6S
         rIxK1/5zXci5YfuQUidL14rYS6P1fFcf2yn4lDuEEC3XveOAPRIGlBu8baMpAPJ/ngMo
         L0tqRCVOB9gCw3aRcGnS8GUmXdoCx+DYF+NkS/jAUoqHOCn6iHS1QQ1YaEDq6uv37FrZ
         0xF/MZ+TUG25BcvYCvdpKTptCe6ioMDiXoJKT2ObPEx3f8UO2HodVIVLHbwRBY3V+3Eh
         83qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=y8htJanxmbFoZO20cRMOpqM+VW4C4SEBRSZ+uu5QWy8=;
        b=Gyz5MaLrnZ5cL6R98hBlkeIVMCQo25IVZQJIoDq7FQDHlkgKWJ7+DtrGzoOYPgbVfW
         LSWS6ZzeqoAkxlQQojwNQDKwR9DFdlY2LGIDW+4Zy3rtcFZEt9fIS/UOy0NZX3P4mgEU
         3A8OuDxU1GjT9oHk4H9L9HQL0TnvXh/ZmIW7q8TXdahoeMZkxFXwMi3ROzJWPQSjAGnV
         ZYjCUr2K2lNWxy3WqSSmm28bJcGbgAXLyDbxbujq3j1KQxijMk9BqG94FgWEmglXp/wN
         TOy8j6adlsUBWD8eBjhAsJwnyiJGtzoRdcP+NdH+mmStqlGJFwGHdzjyE55ACCB/z4lD
         tCxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id 31si2115987pld.6.2019.03.20.08.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Mar 2019 08:23:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 20 Mar 2019 08:23:44 -0700
Received: from fedoratest.localdomain (unknown [10.30.24.114])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id A0C374199D;
	Wed, 20 Mar 2019 08:23:45 -0700 (PDT)
From: Thomas Hellstrom <thellstrom@vmware.com>
To: <dri-devel@lists.freedesktop.org>
CC: <linux-graphics-maintainer@vmware.com>, Thomas Hellstrom
	<thellstrom@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew
 Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Peter
 Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>, Minchan Kim
	<minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying
	<ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: [RFC PATCH 2/3] mm: Add an apply_to_pfn_range interface
Date: Wed, 20 Mar 2019 16:23:14 +0100
Message-ID: <20190320152315.82758-3-thellstrom@vmware.com>
X-Mailer: git-send-email 2.19.0.rc1
In-Reply-To: <20190320152315.82758-1-thellstrom@vmware.com>
References: <20190320152315.82758-1-thellstrom@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Received-SPF: None (EX13-EDG-OU-001.vmware.com: thellstrom@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is basically apply_to_page_range with added functionality:
Allocating missing parts of the page table becomes optional, which
means that the function can be guaranteed not to error if allocation
is disabled. Also passing of the closure struct and callback function
becomes different and more in line with how things are done elsewhere.

Finally we keep apply_to_page_range as a wrapper around apply_to_pfn_range

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
---
 include/linux/mm.h |  10 ++++
 mm/memory.c        | 121 +++++++++++++++++++++++++++++++++------------
 2 files changed, 99 insertions(+), 32 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..b7dd4ddd6efb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2632,6 +2632,16 @@ typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
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
index dcd80313cf10..0feb7191c2d2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1938,18 +1938,17 @@ int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long
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
 
@@ -1960,86 +1959,103 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
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
+ *
+ * Returns: Zero on success. If the provided function returns a non-zero status,
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
@@ -2049,16 +2065,57 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
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
+EXPORT_SYMBOL_GPL(apply_to_pfn_range);
+
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
2.19.0.rc1

