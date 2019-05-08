Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D176C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B11CC21773
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B11CC21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FBAF6B0010; Wed,  8 May 2019 02:17:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D4A06B0266; Wed,  8 May 2019 02:17:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49E006B0269; Wed,  8 May 2019 02:17:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 108486B0010
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:17:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c12so11970008pfb.2
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:17:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=944w9BffmrgL1FZ8NaoinfbTYpUqZJ/dbIn+hhkhMxI=;
        b=n/RvMpiOy2NvhcMJUx8FUUF/CwjOp9XCUzhC2BXjzUkX+SETalHuegcq1QxOHUvnTa
         PKPJmRwsZuex0vS4m66z9VIgDW52hWxhYsBrrbfebK3/6zIjsrTAxiENiQCk8fSOsWSc
         0DTVkKQ4nEf/trqILMmTXJ+OVjwio4yc/qYGTN26LjcO1ZPqQLuUQgcn/FJbd37sQC0H
         kXu9p8nbW55/LCYmuFDCHGw73+o1o5Dkxqmfhpy3hYKGceQupEStIk5qvNhN1p/bbbE9
         cIDYVY96L1okZ9aGw+J+Fpcz0fzT7mG+weOQ/y6N26PwY+en3j8/KL+XPiVKamFGvxsZ
         enFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVV9bNL2j17eUV0GsOaNQd0/OMI5sTJAuzFyddTu74jbGOMJNkg
	j3HJqRF0o81aQMKNhWzOxH+OKv0xqZYxtLFyBL1gK8U2D6+Yjo6Y5DO3mA2AfBRuXb2bbSdQSzJ
	hqoN5004FNALI1lz2QDvoIIodkpK82wosMJqRE2rkZAvJaKHSQOdUju+mgl7UZ4FPoQ==
X-Received: by 2002:a63:4346:: with SMTP id q67mr44739846pga.241.1557296268710;
        Tue, 07 May 2019 23:17:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPXX5BHn3GPOY+87N4KFQ5HKXItpZ9OoXEKpe93VzOu3SVyEA9n+y3O1XP2sAUKNA9s7lV
X-Received: by 2002:a63:4346:: with SMTP id q67mr44739751pga.241.1557296267306;
        Tue, 07 May 2019 23:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296267; cv=none;
        d=google.com; s=arc-20160816;
        b=OpEjTVluBIWkCiLTqDm9s3vbL8JYXr7j5G7aZU6UyML+BAsweVkwJJ/0kUK3C/8rB3
         gZVQx63PlfyQjcDT59uvlzmBM6QG++qdxBEFrcX4pXpvz3kf7E72H+p/lRoXwRztzZbz
         IkHZPAFKz/L6WsfO27wzbJg3+/YBXCyCzrund2+Sp7jIme60dU556l9t7rU2jNtn8Pmt
         QYsmirW0ntFRn6JAgOoZ4Ba187HdOdNqlX+orfsBIU0d9sg/2TD5ifyjlItRUXKdkiI9
         dJurfEwbkIJbpxr40hnl/xGOXFrGpX0QbEDrDbhVycBwdKGtcFI3HyDcaOtjal7gFs9n
         F7ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=944w9BffmrgL1FZ8NaoinfbTYpUqZJ/dbIn+hhkhMxI=;
        b=uFECLXneOCntswxnNnfAEjubniaPkA6CLSiSsmSVkif+kf0E1J58l8XeGpDkTXrvUp
         uf6r+Die3t0wqO56xg1Mw+d7bStX3r3pvWpym3Ft0aBYbSlOmL89+i6/El8j/V9LfVSp
         YQmdETP5gd9szNYtiu7Ku1F4IPEIslr3UiNgupMT1cydniO1K1HWjByODRDQjc0kgy3E
         dUqS4q9LjRj32TyhsO0LFyVtSJz2vYe1H8vW/m9B+qtRhmxUCMmnc7T9VfZIazAqFMMK
         2nICk2DFEqLmpSxe0BDPXeyuMu7h+drL8PRga6jU5ZVPFz8AFovxaEm09hVRnLvTO/wn
         FI+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si15362460pln.354.2019.05.07.23.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GWqG035756
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:17:46 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbqy8vh2k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:17:46 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:17:43 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:33 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486HWfF24641640
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:32 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 798E242042;
	Wed,  8 May 2019 06:17:32 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2FA9B42049;
	Wed,  8 May 2019 06:17:29 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:17:29 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:28 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Anshuman Khandual <anshuman.khandual@arm.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greentime Hu <green.hu@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>,
        Guo Ren <guoren@kernel.org>, Helge Deller <deller@gmx.de>,
        Ley Foon Tan <lftan@altera.com>, Matthew Wilcox <willy@infradead.org>,
        Matt Turner <mattst88@gmail.com>,
        Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>,
        Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>,
        Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>,
        Russell King <linux@armlinux.org.uk>, Sam Creasey <sammy@sammy.net>,
        x86@kernel.org, linux-alpha@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
        linux-mm@kvack.org, linux-parisc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org,
        linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 04/14] arm64: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:01 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0012-0000-0000-000003196C51
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0013-0000-0000-00002151EC54
Message-Id: <1557296232-15361-5-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=933 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The PTE allocations in arm64 are identical to the generic ones modulo the
GFP flags.

Using the generic pte_alloc_one() functions ensures that the user page
tables are allocated with __GFP_ACCOUNT set.

The arm64 definition of PGALLOC_GFP is removed and replaced with
GFP_PGTABLE_USER for p[gum]d_alloc_one() for the user page tables and
GFP_PGTABLE_KERNEL for the kernel page tables. The KVM memory cache is now
using GFP_PGTABLE_USER.

The mappings created with create_pgd_mapping() are now using
GFP_PGTABLE_KERNEL.

The conversion to the generic version of pte_free_kernel() removes the NULL
check for pte.

The pte_free() version on arm64 is identical to the generic one and
can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arm64/include/asm/pgalloc.h | 47 +++++++---------------------------------
 arch/arm64/mm/mmu.c              |  2 +-
 arch/arm64/mm/pgd.c              |  9 ++++++--
 virt/kvm/arm/mmu.c               |  2 +-
 4 files changed, 17 insertions(+), 43 deletions(-)

diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index dabba4b..07be429 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -24,18 +24,23 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 #define check_pgt_cache()		do { } while (0)
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_ZERO)
 #define PGD_SIZE	(PTRS_PER_PGD * sizeof(pgd_t))
 
 #if CONFIG_PGTABLE_LEVELS > 2
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
+	gfp_t gfp = GFP_PGTABLE_USER;
 	struct page *page;
 
-	page = alloc_page(PGALLOC_GFP);
+	if (mm == &init_mm)
+		gfp = GFP_PGTABLE_KERNEL;
+
+	page = alloc_page(gfp);
 	if (!page)
 		return NULL;
 	if (!pgtable_pmd_page_ctor(page)) {
@@ -72,7 +77,7 @@ static inline void __pud_populate(pud_t *pudp, phys_addr_t pmdp, pudval_t prot)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)__get_free_page(PGALLOC_GFP);
+	return (pud_t *)__get_free_page(GFP_PGTABLE_USER);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pudp)
@@ -100,42 +105,6 @@ static inline void __pgd_populate(pgd_t *pgdp, phys_addr_t pudp, pgdval_t prot)
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgdp);
 
-static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	return (pte_t *)__get_free_page(PGALLOC_GFP);
-}
-
-static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *pte;
-
-	pte = alloc_pages(PGALLOC_GFP, 0);
-	if (!pte)
-		return NULL;
-	if (!pgtable_page_ctor(pte)) {
-		__free_page(pte);
-		return NULL;
-	}
-	return pte;
-}
-
-/*
- * Free a PTE table.
- */
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *ptep)
-{
-	if (ptep)
-		free_page((unsigned long)ptep);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
-{
-	pgtable_page_dtor(pte);
-	__free_page(pte);
-}
-
 static inline void __pmd_populate(pmd_t *pmdp, phys_addr_t ptep,
 				  pmdval_t prot)
 {
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index ef82312..bf42f07 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -373,7 +373,7 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
 
 static phys_addr_t __pgd_pgtable_alloc(int shift)
 {
-	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
+	void *ptr = (void *)__get_free_page(GFP_PGTABLE_KERNEL);
 	BUG_ON(!ptr);
 
 	/* Ensure the zeroed page is visible to the page table walker */
diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
index 289f911..769516c 100644
--- a/arch/arm64/mm/pgd.c
+++ b/arch/arm64/mm/pgd.c
@@ -30,10 +30,15 @@ static struct kmem_cache *pgd_cache __ro_after_init;
 
 pgd_t *pgd_alloc(struct mm_struct *mm)
 {
+	gfp_t gfp = GFP_PGTABLE_USER;
+
+	if (unlikely(mm == &init_mm))
+		gfp = GFP_PGTABLE_KERNEL;
+
 	if (PGD_SIZE == PAGE_SIZE)
-		return (pgd_t *)__get_free_page(PGALLOC_GFP);
+		return (pgd_t *)__get_free_page(gfp);
 	else
-		return kmem_cache_alloc(pgd_cache, PGALLOC_GFP);
+		return kmem_cache_alloc(pgd_cache, gfp);
 }
 
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index 74b6582..17aa4ac 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -141,7 +141,7 @@ static int mmu_topup_memory_cache(struct kvm_mmu_memory_cache *cache,
 	if (cache->nobjs >= min)
 		return 0;
 	while (cache->nobjs < max) {
-		page = (void *)__get_free_page(PGALLOC_GFP);
+		page = (void *)__get_free_page(GFP_PGTABLE_USER);
 		if (!page)
 			return -ENOMEM;
 		cache->objects[cache->nobjs++] = page;
-- 
2.7.4

