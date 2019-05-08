Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3999C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 800C421655
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 800C421655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33F3C6B0273; Wed,  8 May 2019 02:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF956B0274; Wed,  8 May 2019 02:18:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18E6E6B0275; Wed,  8 May 2019 02:18:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E930D6B0273
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:18:08 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id g128so35854047ywf.11
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:18:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=1WhkMOf9YAuwG2fro1ZYKVlionAxnm9JkehCHmz44mE=;
        b=jxVKPqbRZ+Du5T3PyNY5yLLDGeXioy2+/LhcrfBUK2ESBUR7FbqgTssFArF2xwrGUx
         r9DmkRSqeuD6+6NS3+hftMzrwXdsm6qzNfHz7KfA8Fi+DeivyC1GyzWC4G+4UNRDiLRw
         X9dikJSflPw684cPTktS2madJ1N+ut8TQWO1MTnr6TZYVaZgTUb5AJkE3OgjvFYmrEZy
         wlmLW+5hwXoT6oaWSUhQMmH6Gtn6zK06GGo1iWBWOmqXlJ5We1IePRB60saLEolgmnGw
         PUavNTgObw3ra0fjwJMehkpYyhAdYhirB6ay543VDkB51WR2jwQBSIS3sqzn9YCOeNi+
         N+GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVsVK+BwK09U3LZgD0isHOdzeQCwkP10dyxKgNtdUe59jEGrEa3
	2iXBHHrtwqbsPJfERhEpeXzNyNvCDC/N6bEt254biCEHpnNjr//Cv8FkcLXvKylK5anMgdv2jP8
	G2U6/qoA8vIkfqDdDJOTfJWthodV3KvI8VkaRVA6P7hGdPptGuXnt/CCL2NTXLjOMgw==
X-Received: by 2002:a81:3955:: with SMTP id g82mr24684534ywa.274.1557296288659;
        Tue, 07 May 2019 23:18:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEibppAgfGwSrvKlwWCrswYqh0yKpXHxyIiDVOUHa6w9YYyiPVOWlif1KNt3fwUP3GvgFy
X-Received: by 2002:a81:3955:: with SMTP id g82mr24684486ywa.274.1557296287631;
        Tue, 07 May 2019 23:18:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296287; cv=none;
        d=google.com; s=arc-20160816;
        b=dFF70/sRGwph93hHXo5/C385YwPxmOS4mGlpMPGrjMLYRpnE/GPposk8wGDVeP4U15
         EYUP0arux173kfKucGwzOsoIvfG8TRlEmzDcb57pMQPjNNcItvR3Wns+ONW43vlQYUyi
         pxbkaq2NU/fkbVQMXPwLeZHxM/5WreMJIJKLwy7pmlhbgjHUZKBwjZ3rCA7Cbgu9Z2xQ
         Ias9zjmDLJepjB+j1LpGJvXdxAWs3kSCRKptv/iNaPGt+1U3acL89ZGv1VhFX7AORGVe
         yfhR9XVKDk8V7xEGe11puH7fSXeJayhKdIKTQ25ytRmr9NEUNOlAvamJ9poM/b2ByQ7z
         DFdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=1WhkMOf9YAuwG2fro1ZYKVlionAxnm9JkehCHmz44mE=;
        b=xssbKAuf5apnIsL6J0J+ZCSalF2bMVUsn0qXs1PuDByvO4wphOEIeEBHDtPUQrDuzT
         Q/NEtPddbHvALRt/KMy83RftG7lJXoFGDLE9NI16PTzvIeeux6PlB4hvtISee/+GyKT6
         ppaKRCS2BmlFL6VkfcZkQMiL9g7wkpq7BygohpnJ6V+wnyT/JqplXRzLOLLcY2NQHNOG
         QzsIKxH+jyP6nZnEBQfANU567zG05a9OHOKrls3Jst0/yGZWseCRDg8kiJr/0Y8HF4vQ
         csu+1wm/3xd+vPxDOSqmOpHY7EAovrBDM7Dvg45J9s+JMGaAJphWGme0TCOk1wdq54kw
         xUKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d191si6102851ywh.392.2019.05.07.23.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:18:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GlIF015231
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:18:07 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sbq4h6ggm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:18:07 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:18:05 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:57 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486Hugh59834568
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:56 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 533124203F;
	Wed,  8 May 2019 06:17:56 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0A92342042;
	Wed,  8 May 2019 06:17:53 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:17:52 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:52 +0300
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
Subject: [PATCH v2 10/14] nios2: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:07 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0016-0000-0000-000002796FE1
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0017-0000-0000-000032D61D35
Message-Id: <1557296232-15361-11-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=755 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

nios2 allocates kernel PTE pages with

        __get_free_pages(GFP_KERNEL | __GFP_ZERO, PTE_ORDER);

and user page tables with

        pte = alloc_pages(GFP_KERNEL, PTE_ORDER);
        if (pte)
                clear_highpage();

The PTE_ORDER is hardwired to zero, which makes nios2 implementation almost
identical to the generic one.

Switch nios2 to the generic version that does exactly the same thing for
the kernel page tables and adds __GFP_ACCOUNT for the user PTEs.

The pte_free_kernel() and pte_free() versions on nios2 are identical to the
generic ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/nios2/include/asm/pgalloc.h | 37 ++-----------------------------------
 1 file changed, 2 insertions(+), 35 deletions(-)

diff --git a/arch/nios2/include/asm/pgalloc.h b/arch/nios2/include/asm/pgalloc.h
index 3a149ea..4bc8cf7 100644
--- a/arch/nios2/include/asm/pgalloc.h
+++ b/arch/nios2/include/asm/pgalloc.h
@@ -12,6 +12,8 @@
 
 #include <linux/mm.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 	pte_t *pte)
 {
@@ -37,41 +39,6 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	pte_t *pte;
-
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_ZERO, PTE_ORDER);
-
-	return pte;
-}
-
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *pte;
-
-	pte = alloc_pages(GFP_KERNEL, PTE_ORDER);
-	if (pte) {
-		if (!pgtable_page_ctor(pte)) {
-			__free_page(pte);
-			return NULL;
-		}
-		clear_highpage(pte);
-	}
-	return pte;
-}
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_pages((unsigned long)pte, PTE_ORDER);
-}
-
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
-{
-	pgtable_page_dtor(pte);
-	__free_pages(pte, PTE_ORDER);
-}
-
 #define __pte_free_tlb(tlb, pte, addr)				\
 	do {							\
 		pgtable_page_dtor(pte);				\
-- 
2.7.4

