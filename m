Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11D50C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4355214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4355214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 734DE6B0275; Wed,  8 May 2019 02:18:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70B726B0276; Wed,  8 May 2019 02:18:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D3DE6B0277; Wed,  8 May 2019 02:18:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D17E6B0275
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:18:14 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id j6so23041375ywd.23
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:18:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=4p4447Ny7N3himwF4MCGOnz8416Ac3gj5P3sttQzcBg=;
        b=FSPHOLxwsAoqr3apmytgGIa8PjvtHl++LrtsQRZUYa48yLmgtX2oNt5zxHPLzJTBsM
         xlHEB5eiFFj3+fge5L56vjbgssy3xktUKsn6TCMZVNW1yrzVMBtJOUQ/Bb+GYbOfjHoK
         BNKvZZCb8UCCBjLb/b48kriRAFaHPX0/l/eEDSMdwuwgiKbNYFvcxHHvw7OzawlpGpnR
         OhHZdZzG+wrph8OtWF8r0HJeaCBcHpBjulDKUwcdZECYOAjN5xty9I09MNQ3ySXCNR03
         VGP21n38ADHRffxVLX6Iuuqe1GgtwbwASYwLkktxVeH/fTqc5ImVe/w0kwkIw6cqR0R7
         cfzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVk7gqlV1mITaeQkxULJ94DqnidLe018076ngYg0p+rjB2AcZPy
	kY9BhK8co/eRX5ig2tl4qBvU3csVq380bulKH+o0AZ3icqenWWyRscibfSD37uCEPxAHfBndtkv
	GrSNV/l0tcQNvPROu6qImg5lhzAWEdMV1oazDzeBZPpS+BA8w7JuZQ/OcqesI4dztYg==
X-Received: by 2002:a25:cf97:: with SMTP id f145mr24009802ybg.457.1557296294012;
        Tue, 07 May 2019 23:18:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiWv6v1qahCb2vSQSs+kgvATZJ1EyfuagFS+8Lh3pSOUFB6Kvnjm0oMcyKcVoEXLe31rbO
X-Received: by 2002:a25:cf97:: with SMTP id f145mr24009761ybg.457.1557296292839;
        Tue, 07 May 2019 23:18:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296292; cv=none;
        d=google.com; s=arc-20160816;
        b=dRLjVdFMr0NPNtk35jHhM6Q4Yh+Dcf03QtYlE1Cg0KTNQRQ7+kE88ftCoYsm/Hb83J
         LYfiFUmsdHtBq6blerzdYjjid5YAht4NnZZ6oNiUgNyaCCIQXPnqMaYaIRod/O0e1yD5
         7auKyRq+QjDNm7yw2DWswmM603+0yYZP4OgeBNIcmmsmeXcdEX/BzH6OM8G0+po1hSsJ
         2Pd5sbMEWmC1bMvuu75zj1gdyLDhPx43uCBvVtyvmTvfk5k12Kqv/Z25OIVa1+xoPjWT
         gb99qSl6x8r8JSs5wC7FmnShUKBXwTHaPDvtOAp02uwEIysphR9DBI3fpuqU4u//R/OF
         AnCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=4p4447Ny7N3himwF4MCGOnz8416Ac3gj5P3sttQzcBg=;
        b=dv0vIcJ5I3OYJMPnbfajCUJcnqsAzVxD3rQbHeAgVOKVQYW4Mo3swh3oRCFCxad5pS
         ZXn5UsHuTTR5qrIZOc83jRe8ZXjyffO4K/GzCTopho2ysAZ+4pYBhieQl5TgX4rfSUrt
         iZQegPiixtYeUaI41Pn/O3w9QdtEIR3yqcUQsPbrRIkvUA5uWz74u6yl8YNvvaK71aVg
         7fePd9aaDyjaQlJr2R/+5ntB8Y06uJySks1jaq/XFkkexXJGTKXaEbXoPHyM8LD42ki8
         QwUtb6rl7MuAaxhdQroN5BZj21SDxV0e0DblgJLE6WT7kVMIIsA653BIJ7UiaVNoIr1M
         kKrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 13si2839706ywl.24.2019.05.07.23.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:18:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GcGA072849
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:18:12 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbp870dr6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:18:12 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:18:10 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:18:01 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486I0PN53477388
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:18:00 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 433594C058;
	Wed,  8 May 2019 06:18:00 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EF0454C046;
	Wed,  8 May 2019 06:17:56 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:17:56 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:56 +0300
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
Subject: [PATCH v2 11/14] parisc: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:08 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0028-0000-0000-0000036B6E5E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0029-0000-0000-0000242AEA26
Message-Id: <1557296232-15361-12-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=921 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

parisc allocates PTE pages with __get_free_page() and uses
GFP_KERNEL | __GFP_ZERO for the allocations.

Switch it to the generic version that does exactly the same thing for the
kernel page tables and adds __GFP_ACCOUNT for the user PTEs.

The pte_free_kernel() and pte_free() versions on are identical to the
generic ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/parisc/include/asm/pgalloc.h | 33 ++-------------------------------
 1 file changed, 2 insertions(+), 31 deletions(-)

diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index ea75cc9..4f2059a 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -10,6 +10,8 @@
 
 #include <asm/cache.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 /* Allocate the top level pgd (page directory)
  *
  * Here (for 64 bit kernels) we implement a Hybrid L2/L3 scheme: we
@@ -122,37 +124,6 @@ pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
 	pmd_populate_kernel(mm, pmd, page_address(pte_page))
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
-static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *page = alloc_page(GFP_KERNEL|__GFP_ZERO);
-	if (!page)
-		return NULL;
-	if (!pgtable_page_ctor(page)) {
-		__free_page(page);
-		return NULL;
-	}
-	return page;
-}
-
-static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
-	return pte;
-}
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
-
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
-{
-	pgtable_page_dtor(pte);
-	pte_free_kernel(mm, page_address(pte));
-}
-
 #define check_pgt_cache()	do { } while (0)
 
 #endif
-- 
2.7.4

