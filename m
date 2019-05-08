Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5442FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1356D214C6
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1356D214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AAC56B0279; Wed,  8 May 2019 02:18:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 759D56B027A; Wed,  8 May 2019 02:18:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FD996B027B; Wed,  8 May 2019 02:18:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA876B0279
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:18:22 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q188so17646517ywc.15
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:18:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=S1l6ptHaLefxATgM+xhGwYYnGVfvAIX9vuXKLdDbgYM=;
        b=PClKC9W220kwbJ/HFAp07S8Bvu+AFRsNbS0RHAkcZ9cUFGrpyCSzm295xVDGg2epC/
         F7Q7bkKWH49+ODmFLd7XOPUXVQ2IuQxBvQD00D46bH/klP1gWEdKmjhnjDw32eyhhuAC
         +hdyfDtdCb1lafFDdco6KvRiGL3WoUqprMVdViTLt9J6dl4tpGgwcrvwWMsq9riEgi/L
         3fE+fkaI1LLCLlTACvt3VZim9l09O8PZqTFp1oW3qdBiEmuEeqjGPN1Aev85Gno39YEj
         DkyZCvNcHjEnXgP7gmh7HL58lMMHVy865SLGhW9tjv7BDAHB1PruYJjaAQ3u0Hu1bLCX
         bRRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUs7mE+Dzy0XUTZYrDT5KQ7UiL+9qS3g+Ouy6UDsWHRWBpUJJVx
	s+D5+9MJqEnxb8QvpIMxgZjcwZ3RwcEAmUNgZLFPNdbcAM6rAw2lhglSVwfFXqxtATmXJJM9egJ
	/0j+6Dnn4pgz4/4ZTyZEllrJAow+cWidgvPrKbRGsNMx1LjaiwZm7JdufJDGNlYzPLg==
X-Received: by 2002:a81:4ecc:: with SMTP id c195mr5401706ywb.31.1557296302013;
        Tue, 07 May 2019 23:18:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyApMKDZ1Dsa3A1Ip6YBPAeWGlT1rJbysy55pOUsixYGcK3pva6x+uKi7ffdiqLi+6igu8x
X-Received: by 2002:a81:4ecc:: with SMTP id c195mr5401680ywb.31.1557296301294;
        Tue, 07 May 2019 23:18:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296301; cv=none;
        d=google.com; s=arc-20160816;
        b=CQXbxN3T6VtBdLGuy9VWZaJ7Bz42yd2v6Ea4LCeY8Yuo21B7DRcJio//jg85QoBhor
         L1IVPJ8FXm9Q/6v9XlH5EKBQX1D9GgfC+fHZfhqB7IeJsLtg4rfdp3qoy+e8jx9NfyHh
         ChOkLQQzOWEP2rIpmT2LD35pZSCOzRGQFp/q2umoT5Y55VSoAIYS26k423TTJ4PpDbrp
         kabfwt429BGdbaIOELSbNVJgff1CFW4uZo1462xoJCS83HlsLNQqxY/+RWf6zOqNfPEn
         x2hQ0+kfCzhUf+r0i3FaqM+JQ1osnMPU6GtRQiFszOVq+KtH8cxTZ18Z2E8sqBgu1UBM
         Vgjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=S1l6ptHaLefxATgM+xhGwYYnGVfvAIX9vuXKLdDbgYM=;
        b=HP035JSK4fqAZ1kwdLAnop2pApvl10mthnNe4xBp477V0UVQKrJVaPH49244he5F6t
         snof8yT/9ux4ri5ozHMcH5j5Xgih5j7LfzYUZ84XabWdYNIsb3t4TZSol8uS2FrA0bcZ
         VqCoypvrbGOnZjou8OBjJm6r1RZcfOLZabugn/mEY1F5SFG5GOGUeiKuRcaLdfvKUl2d
         Bv6+igBge2w7ebGXncm7JDSHGpvRIAEv+RoR1Nr9y/0reYNlpr+02JDvNoMTAsjmmylV
         5r1UM65TdyYHzHKspz4XqZ74/t6E1+iyyzmOEAV3Kt+YQ1PK3TltjVjiluiQ7iAULnL/
         PQ6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 197si6195402ybf.174.2019.05.07.23.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:18:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486Gaj6131178
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:18:21 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sbr09vg3r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:18:20 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:18:18 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:18:09 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486I8L347317072
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:18:08 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2F8CAA4053;
	Wed,  8 May 2019 06:18:08 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D7771A4040;
	Wed,  8 May 2019 06:18:04 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:18:04 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:18:04 +0300
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
Subject: [PATCH v2 13/14] um: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:10 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0016-0000-0000-000002796FE5
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0017-0000-0000-000032D61D38
Message-Id: <1557296232-15361-14-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=911 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

um allocates PTE pages with __get_free_page() and uses
GFP_KERNEL | __GFP_ZERO for the allocations.

Switch it to the generic version that does exactly the same thing for the
kernel page tables and adds __GFP_ACCOUNT for the user PTEs.

The pte_free() and pte_free_kernel() versions are identical to the generic
ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Acked-by: Anton Ivanov <anton.ivanov@cambridgegreys.com>
---
 arch/um/include/asm/pgalloc.h | 16 ++--------------
 arch/um/kernel/mem.c          | 22 ----------------------
 2 files changed, 2 insertions(+), 36 deletions(-)

diff --git a/arch/um/include/asm/pgalloc.h b/arch/um/include/asm/pgalloc.h
index 99eb568..d7b282e 100644
--- a/arch/um/include/asm/pgalloc.h
+++ b/arch/um/include/asm/pgalloc.h
@@ -10,6 +10,8 @@
 
 #include <linux/mm.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 #define pmd_populate_kernel(mm, pmd, pte) \
 	set_pmd(pmd, __pmd(_PAGE_TABLE + (unsigned long) __pa(pte)))
 
@@ -25,20 +27,6 @@
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *);
-extern pgtable_t pte_alloc_one(struct mm_struct *);
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long) pte);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
-{
-	pgtable_page_dtor(pte);
-	__free_page(pte);
-}
-
 #define __pte_free_tlb(tlb,pte, address)		\
 do {							\
 	pgtable_page_dtor(pte);				\
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 99aa11b..2280374 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -215,28 +215,6 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long) pgd);
 }
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	pte_t *pte;
-
-	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
-	return pte;
-}
-
-pgtable_t pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *pte;
-
-	pte = alloc_page(GFP_KERNEL|__GFP_ZERO);
-	if (!pte)
-		return NULL;
-	if (!pgtable_page_ctor(pte)) {
-		__free_page(pte);
-		return NULL;
-	}
-	return pte;
-}
-
 #ifdef CONFIG_3_LEVEL_PGTABLES
 pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-- 
2.7.4

