Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74C26C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33020214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33020214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEBAC6B0277; Wed,  8 May 2019 02:18:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC2DD6B0278; Wed,  8 May 2019 02:18:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65006B0279; Wed,  8 May 2019 02:18:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 880986B0277
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:18:20 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s8so12030638pgk.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:18:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=ib0sQhX6/F10oZhLJP5roByNw4PAFOqtWMhibTtH0Ng=;
        b=bJyT4ZEWJ9bh3VpBoRND7J/rWRwKHtZNr/AdlXBYXMsedjb7sceNLXuniXtQFrCj1a
         A4VrezRUng0MG+qTDkprXh64FOzcswV+Awkf6GpWKG/1DM9RZ7cU8Y4ioN37/z2AD6vN
         RcQLq5ElpnQKY1q6m6HSXZqeUj/iJ2rD7YLBwPm336i96m5YHFwErupG9P/nC5oFkhtD
         Cl5zPrH8ArkyE+ydApIhA2c5C1IbFAtvQy4nlvHjeeXnxvbOmssM9AIOf1lNg8bwQ7lc
         A+wfRbQfNFRjz+SiZUadYMBaifh5I20eOMZmsLMH3FLYrTSAtZgmUSgjaR7VbL+jQIS5
         qdpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXwoFi/fDdqRXeIDgrRHQz6rLj+EOI0voDtw8xePtGAGCHyYXGJ
	JT5u5NRFVS+HA6nuty8abcuUH7ZHfpsWwHdthqBWedkQBW4pC7Tol0U0FemSxQ940wcI7bg2K+S
	iM1CPtgOtEyvpq54O+PzKIAlOsRbjzK66DrRVH4ostCfDaauFLs0IOp2Mp9NFFjQNyg==
X-Received: by 2002:a17:902:4624:: with SMTP id o33mr45276218pld.191.1557296300151;
        Tue, 07 May 2019 23:18:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2wv4WqeR4NY/boODv8PmFTbRsHdpQkoU+AzE2jXZM1mBO/7aLz4ArJpNpMbb+iK6bZdp/
X-Received: by 2002:a17:902:4624:: with SMTP id o33mr45276167pld.191.1557296299434;
        Tue, 07 May 2019 23:18:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296299; cv=none;
        d=google.com; s=arc-20160816;
        b=rfmdXbD5BxsHmDWEnT7jEuKca78rI1qQrgu6udrohMrXosNSOAkScV7NAriqlaQA34
         r8d2rTXzDFaCaMZJwuBWCavycu1Zy5uxDJrBfVPAO3gU+hfPaTNp/3mf8h+eF+rNX3AC
         9T6wNeFhotVgE/A5VIHQd36gDpxcv1H3KVP8I/fLWpcZtWjRsM5xaTmiA0v95BMzkJWA
         FMKAbXp+Qt84Z4Pbn5/p6a97TRx8PdqY8K/s0FrPedt+mUMVHFvWv1FywvtI53wfMH6z
         BQt5Zhv8wDrNUpmVoc/fmyes/qfQUwSt7WwZGdm8+BMHN4JVmNqOGAZKUR2GE7FRinxv
         uEOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=ib0sQhX6/F10oZhLJP5roByNw4PAFOqtWMhibTtH0Ng=;
        b=Clz33rVZUZoJ73RL/4HgeBT62suVdIZAKVo1S+jmHfnEppJ3sGgUtuEZ9f/F7umS6D
         tDhiSUzclF4FVVctFjVjTJaQ0n7yFQh8+COEopQmfjvKrQ+xc7x6vVw9T7uy6VR5vSxQ
         Arnhh+Zu6MyecbTUIdgFJMUFcNAX1PRzaeuZWT9JJfoVLOhpmjpp91Xx2/rKo3s6FoJu
         R8Emra1B/H7f8Q0PaEDX+QuobTqBk2yGv5MUNOWI0oBz2sbgTAPVv8IVlcdrQGKfcx3B
         N7ZaYC9y6Zf5KNR9C6Ty6bXzCm+i5rY9bH1vErmu6OuzY64XPBXghsiTMeAgGOlkhaG9
         maEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b14si5186270pgk.485.2019.05.07.23.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:18:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GWJu035776
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:18:19 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbqy8vhsw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:18:18 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:18:15 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:18:06 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486I5Jq35324154
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:18:05 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 354ACA4064;
	Wed,  8 May 2019 06:18:04 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E1164A4054;
	Wed,  8 May 2019 06:18:00 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:18:00 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:18:00 +0300
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
Subject: [PATCH v2 12/14] riscv: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:09 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-4275-0000-0000-000003328178
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-4276-0000-0000-00003841EF0A
Message-Id: <1557296232-15361-13-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=964 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The only difference between the generic and RISC-V implementation of PTE
allocation is the usage of __GFP_RETRY_MAYFAIL for both kernel and user
PTEs and the absence of __GFP_ACCOUNT for the user PTEs.

The conversion to the generic version removes the __GFP_RETRY_MAYFAIL and
ensures that GFP_ACCOUNT is used for the user PTE allocations.

The pte_free() and pte_free_kernel() versions are identical to the generic
ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Palmer Dabbelt <palmer@sifive.com>
---
 arch/riscv/include/asm/pgalloc.h | 29 ++---------------------------
 1 file changed, 2 insertions(+), 27 deletions(-)

diff --git a/arch/riscv/include/asm/pgalloc.h b/arch/riscv/include/asm/pgalloc.h
index 94043cf..48f28bb 100644
--- a/arch/riscv/include/asm/pgalloc.h
+++ b/arch/riscv/include/asm/pgalloc.h
@@ -18,6 +18,8 @@
 #include <linux/mm.h>
 #include <asm/tlb.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 static inline void pmd_populate_kernel(struct mm_struct *mm,
 	pmd_t *pmd, pte_t *pte)
 {
@@ -82,33 +84,6 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 
 #endif /* __PAGETABLE_PMD_FOLDED */
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	return (pte_t *)__get_free_page(
-		GFP_KERNEL | __GFP_RETRY_MAYFAIL | __GFP_ZERO);
-}
-
-static inline struct page *pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *pte;
-
-	pte = alloc_page(GFP_KERNEL | __GFP_RETRY_MAYFAIL | __GFP_ZERO);
-	if (likely(pte != NULL))
-		pgtable_page_ctor(pte);
-	return pte;
-}
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
-{
-	pgtable_page_dtor(pte);
-	__free_page(pte);
-}
-
 #define __pte_free_tlb(tlb, pte, buf)   \
 do {                                    \
 	pgtable_page_dtor(pte);         \
-- 
2.7.4

