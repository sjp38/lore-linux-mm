Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD5FDC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 962BC214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 962BC214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4284C6B027B; Wed,  8 May 2019 02:18:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FFBA6B027C; Wed,  8 May 2019 02:18:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EE766B027D; Wed,  8 May 2019 02:18:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2866B027B
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:18:27 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id 11so36052383ywt.12
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:18:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=bKEkXuUB0aT6OqT4IPvc1dAm0vfoKxIg4G5OqzwkthI=;
        b=F76cMSHZAtcnJfhWvdbONOhGdmXHFDsGrsoiKT7Ytwfa8QZxW+V6Cqo8LR3bpd7MXj
         OW5TUCzaiGfNJ/Lr8dMxydvf6i57mJPXHN72OOMPVVBKWCbejuw++NbMv6w4weKfD8Oy
         JkobxpNYv00qwrJZyEtR6V9Nxxgz13WhS3twDTWNwTBogW+pkxA/7Vu8nkQvO32uiR8l
         w5RlDL3clibHbYKqb5FeU0Be0GX3bafbUyBjIIWZPJeEj925Ap+Aex9oLM+MeA144Yfb
         n+FvBAK0ff/DAS8TC/mVneFScer3V726RV8xV6CqXRvsjrHi0F44TgwmlDVHKNNyWShL
         Og4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW1SAtqq2JvfnIsR8DBR2jfPPCU8+VFdUUcLBAoLTg3xVUqZ/67
	06aA6b98qvJ7N2cf3NG3rheEnLdWWkjTE/IfqGtGsVhCsLolzvlcc/UYMXbQOW9FRqoXe6kecG2
	3T1QsrjCcmFMJlLNfe8ARmD4OaPSJqgTm2t/uEb2jbvLAGOfEHTDoCGqLvVsnrH/t9Q==
X-Received: by 2002:a25:d257:: with SMTP id j84mr22604016ybg.326.1557296306825;
        Tue, 07 May 2019 23:18:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjGAkTPprdLJpHfwldkgkdcFCs73L+HkooiUnTludYtyC+VaV3c3HknSyPNZZtpThnwyi1
X-Received: by 2002:a25:d257:: with SMTP id j84mr22603987ybg.326.1557296305725;
        Tue, 07 May 2019 23:18:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296305; cv=none;
        d=google.com; s=arc-20160816;
        b=L8J24XtV1CNkpmUKbAZ4M1lMcTPAfKvCfaN3MrgZEI+cNY1SCKzUcO2fn2HETHG1jk
         bHVNwoSvFK2sYbk1+BtjtoRM5ql93h1jodF2BYObcUr17xMCriXFKUics90FjhGNXaXA
         g06BDPa4hPevxJLesyHEMdmqmAwGzIskayuHChZcP4iQ8Mo3Hz5smSQuZiVh0qnuGHak
         ZRR1iUMLOw+TPAUpHdfSuFJxDUDMX+TXPsRcClaEHeWRHIUC6hKQgt6opxrlfrOBOCHN
         IRUiGzg7c3Fp0tR6IcBx2S54x48h0tbQIoYy9mkQZPBuulTtaHZnrma0Es483GUv6VDz
         woHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=bKEkXuUB0aT6OqT4IPvc1dAm0vfoKxIg4G5OqzwkthI=;
        b=CYbqPl9OEgD3VojOrMQBtNasXe0o8QWT/fcZ/iVzp5fDft1PI799kgJn1Ik56jOO6q
         WZJtGW3fMXIN8rkD5aBZFbbU6B7UgVOROMgMFKmmw0ldIdLZNFn5EbXbskKmbEp0mxqC
         tLxM+9yA9jz3NnU/cfYG8eRi6n0lvBUTroxCCsRbJDTWRxCv6t0NCB/ZnHwOH5COfAFI
         Cu7GZ7AzOqqKkwr8FfU+ZmV1olV3HjVHhjgnt8zZZsbqlx8396apDG6qz09w0oqFNatT
         Gw9oGmNPEijl2TUJUXCqW2JvhuXrh6EM1CJOB3dUvS9NFo7aHoPw5c3+Vsgi6OqfbNVo
         fP8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h5si6153726ywh.129.2019.05.07.23.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:18:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486Glic015234
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:18:25 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sbq4h6gx3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:18:25 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:18:22 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:18:13 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486ICnC48693404
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:18:12 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0FC5252051;
	Wed,  8 May 2019 06:18:12 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id C2D5252057;
	Wed,  8 May 2019 06:18:08 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:18:08 +0300
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
Subject: [PATCH v2 14/14] unicore32: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:11 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0028-0000-0000-0000036B6E67
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0029-0000-0000-0000242AEA29
Message-Id: <1557296232-15361-15-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=751 adultscore=0 classifier=spam adjust=0 reason=mlx
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

The pte_free() and pte_free_kernel() versions are identical to the generic
ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/unicore32/include/asm/pgalloc.h | 36 ++++++++----------------------------
 1 file changed, 8 insertions(+), 28 deletions(-)

diff --git a/arch/unicore32/include/asm/pgalloc.h b/arch/unicore32/include/asm/pgalloc.h
index 7cceabe..dd09af6 100644
--- a/arch/unicore32/include/asm/pgalloc.h
+++ b/arch/unicore32/include/asm/pgalloc.h
@@ -17,6 +17,10 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#define __HAVE_ARCH_PTE_ALLOC_ONE_KERNEL
+#define __HAVE_ARCH_PTE_ALLOC_ONE
+#include <asm-generic/pgalloc.h>
+
 #define check_pgt_cache()		do { } while (0)
 
 #define _PAGE_USER_TABLE	(PMD_TYPE_TABLE | PMD_PRESENT)
@@ -28,17 +32,14 @@ extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
 #define pgd_alloc(mm)			get_pgd_slow(mm)
 #define pgd_free(mm, pgd)		free_pgd_slow(mm, pgd)
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_ZERO)
-
 /*
  * Allocate one PTE table.
  */
 static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm)
 {
-	pte_t *pte;
+	pte_t *pte = __pte_alloc_one_kernel(mm);
 
-	pte = (pte_t *)__get_free_page(PGALLOC_GFP);
 	if (pte)
 		clean_dcache_area(pte, PTRS_PER_PTE * sizeof(pte_t));
 
@@ -50,35 +51,14 @@ pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
-	pte = alloc_pages(PGALLOC_GFP, 0);
+	pte = __pte_alloc_one(mm, GFP_PGTABLE_USER);
 	if (!pte)
 		return NULL;
-	if (!PageHighMem(pte)) {
-		void *page = page_address(pte);
-		clean_dcache_area(page, PTRS_PER_PTE * sizeof(pte_t));
-	}
-	if (!pgtable_page_ctor(pte)) {
-		__free_page(pte);
-	}
-
+	if (!PageHighMem(pte))
+		clean_pte_table(page_address(pte));
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
 static inline void __pmd_populate(pmd_t *pmdp, unsigned long pmdval)
 {
 	set_pmd(pmdp, __pmd(pmdval));
-- 
2.7.4

