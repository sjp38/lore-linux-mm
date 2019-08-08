Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77295C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:52:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34DAC217D7
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:52:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34DAC217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C05CB6B0003; Thu,  8 Aug 2019 03:52:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDD6D6B0006; Thu,  8 Aug 2019 03:52:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2F076B0008; Thu,  8 Aug 2019 03:52:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 673256B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 03:52:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g21so58584251pfb.13
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 00:52:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=NERU+eYUw0BgIky1n95Wgv4VtzNzVI4ozopwli4tkQY=;
        b=cV/XhowDUrqvKN743R0Y07JMMjHNWpzQ2X9lz2AbxUXOZj/DYSSUx0jhvkUJ+vcwqR
         Khih32FvvW/7AudsEDUjavhsQFDSgvpBObaXB8D+M8j49o+MDIVwQzY0BusbSDHeof+g
         H/49ri+0BO9Lc3E+CBSXYhcKSmXP9N3mbUk4l4LQQOvRl8ItKC1UiGN17zLpQze7aeLt
         z11Wlx/9EvN5zYyr4cMyykif1atE1jXytHJ5yqIKky835+AkCMVdaqzV9o96cJIKKQpu
         XxsnfWL6B7iADWqvUDU389uNBUFjD9/CVC9JzOIQWCqTd0+iX4lnvs8UvNltK7OcWEDw
         4dog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAURzRl/e20lhTMd9xaDt/QaTf7iYYym+AuVvnJXoAdgCVikHfgm
	GMXVjD74DbKHWBpT4xT3kBS5HNOWKG9yq3nKjE0gAjb44XE1LkDuVsguUne7ns3UK6TqBZGRP7R
	5KpjUssH3wLReNtxFnxhWU24FOYws3ULFnah0LHZB55wjm10HB0h4NUkjcm6cGPvn3A==
X-Received: by 2002:a17:902:7894:: with SMTP id q20mr5559279pll.339.1565250744041;
        Thu, 08 Aug 2019 00:52:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwatdLir1BgoQYQXFFhgyxmci9YspjQQGPk31oebMOKFBvFhrxxofBZjEDcET5DIchn806Q
X-Received: by 2002:a17:902:7894:: with SMTP id q20mr5559249pll.339.1565250743359;
        Thu, 08 Aug 2019 00:52:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565250743; cv=none;
        d=google.com; s=arc-20160816;
        b=bkuR4G+PPdIo9OypZwiiTt25x4iyyTfO8438IT1nh1I3UhtotFMvv6VaO6We3lciTz
         ScUssDCMvoxLFzbLX0VQHoR1PY0SGXQe3X9I5d/HYuR9QmXEMjABGtPDAms9MM8nF21q
         PlgAmVsEw1qqw4LEf2dgU0hxZfsPEVBhtoA1mmgEx9nEY/z/itq7N1UNpwxWhOTo9UQJ
         qStFCh+zQJW00PGCqlcGGf59mwReepwpErr9S39lPFGf6pmYBty9kU+CKIS2BuIAzWW0
         KrvC42ExHkU2eukuuDRR7S+83gK3YLkxZkaxYmZzjz5mwu45ea97UtVEKHkN/rMXZGiX
         cCEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=NERU+eYUw0BgIky1n95Wgv4VtzNzVI4ozopwli4tkQY=;
        b=t7T+tLIuNA6SztqUs/pfrbXkDBR8LHcxG20bLkBGcgqqlXgUU0iUraed02lxyq/SqN
         PZeZ+rh2uXYSH40nuDQjJqgYhGCft7lJsztavlBsT7vLMpY5SEd6zuid0h2tM/J+LVfv
         je4cLmumxgwFuXwL4GNrtdO1HercTVsRxippJDEJNGU/zNjzRP+G/ezKxEYgi9kXt36u
         HewiKvUoEkYbjpixollRu58KklBpd5TgA0gXcLP0Ynj4Y3OJkxOzH3OvMBFt9S29tlgf
         2zRBKBQO6HhwATAMeBrJ7m4uHnviRKO3UHUyFMSI8st3yJuQVsiBbtjT1FvTF/f+O3+m
         NvoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v4si42951113pgf.470.2019.08.08.00.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 00:52:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x787qFGg019750
	for <linux-mm@kvack.org>; Thu, 8 Aug 2019 03:52:22 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u8cjqxyaj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Aug 2019 03:52:22 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 8 Aug 2019 08:52:20 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 8 Aug 2019 08:52:17 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x787qGeM33947662
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 8 Aug 2019 07:52:16 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 317B1AE053;
	Thu,  8 Aug 2019 07:52:16 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 668F9AE051;
	Thu,  8 Aug 2019 07:52:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  8 Aug 2019 07:52:14 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 08 Aug 2019 10:52:13 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Tony Luck <tony.luck@intel.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-sh@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 2/3] ia64: switch to generic version of pte allocation
Date: Thu,  8 Aug 2019 10:52:07 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1565250728-21721-1-git-send-email-rppt@linux.ibm.com>
References: <1565250728-21721-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19080807-4275-0000-0000-000003568A20
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080807-4276-0000-0000-000038688E6D
Message-Id: <1565250728-21721-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-08_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=867 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908080090
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The ia64 implementation pte_alloc_one(), pte_alloc_one_kernel(),
pte_free_kernel() and pte_free() is identical to the generic except of lack
of __GFP_ACCOUNT for the user PTEs allocation.

Switch ia64 to use generic version of these functions.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/ia64/include/asm/pgalloc.h | 32 ++------------------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index b03d993..f4c4910 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -20,6 +20,8 @@
 #include <linux/page-flags.h>
 #include <linux/threads.h>
 
+#include <asm-generic/pgalloc.h>
+
 #include <asm/mmu_context.h>
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
@@ -82,36 +84,6 @@ pmd_populate_kernel(struct mm_struct *mm, pmd_t * pmd_entry, pte_t * pte)
 	pmd_val(*pmd_entry) = __pa(pte);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *page;
-
-	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
-	if (!page)
-		return NULL;
-	if (!pgtable_page_ctor(page)) {
-		__free_page(page);
-		return NULL;
-	}
-	return page;
-}
-
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
-{
-	pgtable_page_dtor(pte);
-	__free_page(pte);
-}
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
-
 #define __pte_free_tlb(tlb, pte, address)	pte_free((tlb)->mm, pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
-- 
2.7.4

