Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B2F9C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2889B214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2889B214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F4B26B000D; Wed,  8 May 2019 02:17:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CB2E6B000E; Wed,  8 May 2019 02:17:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8948C6B0010; Wed,  8 May 2019 02:17:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 690836B000D
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:17:43 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id k134so13972425ywe.7
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:17:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=yta1/gWTX19e69u6m7sFNQlkJw1MvYFxy61u5pVzi0M=;
        b=ZL4qDS9ZEj95q0RsHGId40q3fLqEoxRVeS7psHI6MgoFn1rRCq0LcWvfNoh+o1sdvA
         HIdq1NqhhC7eVDnZG+sdghKCZVyxdw6A+uWCMVUHJjfea6NRxkJiemSRd8oBN1OD+NeS
         GWXjDpBRPHSTj16LzTUHcM/RxevmnYV9SBPSEqYm6tv1OILzJwhUWNykMlgVz7gkIRd3
         4cvHL2pDJKMqUVh/AKI/2jfLltzmpZImnKmuRXE4d9Eic+DGXPYHRI56Uv/T4rEcvs6B
         15Sc8QtMDXhehaVYfFNLm27ARISivo4+LksOg63qgvFHXiT4cVcECM+l+7akhGBop8YW
         E+uA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV/xNYv03O7C2jqCa0P8hTNIifuPCGldKcZpaMDsnkr7s19ldYh
	u5yoNfxz6L7Yb8FLRK/mNPaQPKFwatCcg8eBx1f9sfEvqf93lLhCayrz0c56td02+ob+ysWH/Ko
	JSu7wVAvn5iKlQv02Xja5RwEInCYOs/6TAYbD+52SuGRZQgBAvzBeltjmVyz9LaQODA==
X-Received: by 2002:a81:62c6:: with SMTP id w189mr23901873ywb.377.1557296263190;
        Tue, 07 May 2019 23:17:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybSa6LKaqZsK6xO+BPLHvbanLToIFw1T2kcRJXBqyRMs04IAOEbhbwB1dF8O23AqP+ccBw
X-Received: by 2002:a81:62c6:: with SMTP id w189mr23901832ywb.377.1557296262077;
        Tue, 07 May 2019 23:17:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296262; cv=none;
        d=google.com; s=arc-20160816;
        b=tW+9wL0ixAxspqm74NW4KXs0Nkjl5u9mlvzo4nY0l/41QxNU+qHOuwj8X4/3sYXQbd
         EQx9CnvFL8eFSYF58pGgtBfBZlIPb7eZ29YSz7ZzrrtInj12VauQ2D/WvaV4z552hZiA
         M0/l2RZKkQ8sxMOhosII2ddQs8XDrj+s6+dDT6fLQAda+9VGDR8J5Jsp1ebhEKBgZ6Z1
         xyNoUE4ZG6TCTIFB93zeINjCCEZWgFQ0zTayFeQhtx7S9rEt0/jEeBrHLsnjcdiGYK8l
         5/HJznEaBXtqb4u5VYkvgLsU7ifBxkkdGslx3g6r4CZd+cKR0GLnLySiql+Z+PnPMp58
         awmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=yta1/gWTX19e69u6m7sFNQlkJw1MvYFxy61u5pVzi0M=;
        b=PzFy/aeb2833X1Npxr+SlCsWQbeU31OGRL576i0ivvyx6lDaY4aUdhuxTL2luSe9Cf
         O1hRLPj6/azp4DhFLqoJpK74dTABzqRPOa6ANGrPiesbyMgw2EY2MChaUMO+KXKqhRr1
         dvb2xB6P98GJGwPK88mimrRbf2PVf4akmULsn9YFhCzcT6zFRHfy3Gi4Nr7/ifoXApNa
         buvbQMWhIbPL2VEFiosu4BipOH78kEpPE4zTRXWIolcrEjabO8SQ/gDu2b93lQple0rt
         d6/wgqsSTK2FI9dC7BNbdNE4gGlX+xrgaVaDx9DisZrdXGY0AqB+JLCQ6hoAoVBfnpTl
         IgZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v71si5782995ywc.322.2019.05.07.23.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:17:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GWX7146347
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:17:41 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sbr22m6bw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:17:41 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:17:39 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:29 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486HS1g57278710
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:28 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8239CAE058;
	Wed,  8 May 2019 06:17:28 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3DA99AE04D;
	Wed,  8 May 2019 06:17:25 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:17:25 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:24 +0300
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
Subject: [PATCH v2 03/14] arm: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:00 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0028-0000-0000-0000036B6E56
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0029-0000-0000-0000242AEA1B
Message-Id: <1557296232-15361-4-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=906 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace __get_free_page() and alloc_pages() calls with the generic
__pte_alloc_one_kernel() and __pte_alloc_one().

There is no functional change for the kernel PTE allocation.

The difference for the user PTEs, is that the clear_pte_table() is now
called after pgtable_page_ctor() and the addition of __GFP_ACCOUNT to the
GFP flags.

The conversion to the generic version of pte_free_kernel() removes the NULL
check for pte.

The pte_free() version on arm is identical to the generic one and can be
simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arm/include/asm/pgalloc.h | 41 +++++++++++++----------------------------
 arch/arm/mm/mmu.c              |  2 +-
 2 files changed, 14 insertions(+), 29 deletions(-)

diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 17ab72f..13c5a9d 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -57,8 +57,6 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_ZERO)
-
 static inline void clean_pte_table(pte_t *pte)
 {
 	clean_dcache_area(pte + PTE_HWTABLE_PTRS, PTE_HWTABLE_SIZE);
@@ -80,54 +78,41 @@ static inline void clean_pte_table(pte_t *pte)
  *  |  h/w pt 1  |
  *  +------------+
  */
+
+#define __HAVE_ARCH_PTE_ALLOC_ONE_KERNEL
+#define __HAVE_ARCH_PTE_ALLOC_ONE
+#include <asm-generic/pgalloc.h>
+
 static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm)
 {
-	pte_t *pte;
+	pte_t *pte = __pte_alloc_one_kernel(mm);
 
-	pte = (pte_t *)__get_free_page(PGALLOC_GFP);
 	if (pte)
 		clean_pte_table(pte);
 
 	return pte;
 }
 
+#ifdef CONFIG_HIGHPTE
+#define PGTABLE_HIGHMEM __GFP_HIGHMEM
+#else
+#define PGTABLE_HIGHMEM 0
+#endif
+
 static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
-#ifdef CONFIG_HIGHPTE
-	pte = alloc_pages(PGALLOC_GFP | __GFP_HIGHMEM, 0);
-#else
-	pte = alloc_pages(PGALLOC_GFP, 0);
-#endif
+	pte = __pte_alloc_one(mm, GFP_PGTABLE_USER | PGTABLE_HIGHMEM);
 	if (!pte)
 		return NULL;
 	if (!PageHighMem(pte))
 		clean_pte_table(page_address(pte));
-	if (!pgtable_page_ctor(pte)) {
-		__free_page(pte);
-		return NULL;
-	}
 	return pte;
 }
 
-/*
- * Free one PTE table.
- */
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	if (pte)
-		free_page((unsigned long)pte);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
-{
-	pgtable_page_dtor(pte);
-	__free_page(pte);
-}
-
 static inline void __pmd_populate(pmd_t *pmdp, phys_addr_t pte,
 				  pmdval_t prot)
 {
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index f3ce341..e8e0382 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -732,7 +732,7 @@ static void __init *early_alloc(unsigned long sz)
 
 static void *__init late_alloc(unsigned long sz)
 {
-	void *ptr = (void *)__get_free_pages(PGALLOC_GFP, get_order(sz));
+	void *ptr = (void *)__get_free_pages(GFP_PGTABLE_KERNEL, get_order(sz));
 
 	if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
 		BUG();
-- 
2.7.4

