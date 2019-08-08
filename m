Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EFA6C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:52:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 542D2218FD
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 07:52:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 542D2218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C06B6B0007; Thu,  8 Aug 2019 03:52:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 772EE6B0008; Thu,  8 Aug 2019 03:52:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C3506B000A; Thu,  8 Aug 2019 03:52:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35B006B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 03:52:26 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id s17so30444164ybg.15
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 00:52:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=+BHJI2YXAwfICzIdAdGeZj4KKn5sG/NIxvWCudui1Ls=;
        b=gq9pjwObJD+llVFWD964c2VjcuiqC2SGmITxAfBnmo3arSsrEVFIKjTqZjsEGSKPba
         kbiRX9b4l0CCi4VfqmZ4ILMew1s/Cf0sgCO/os1K5SF04VoQBi+HjVgW1oImaBvSskA9
         Rs9q3vGuWrSL/id9C1N+F/E8ONOfCHb/YTZ01VkwcyaGG71zTHETcPGhUF7hs9h1vmHn
         mugcZguSweIxNWgYe59nddDrQSGknJm5HXzNRoBv2gLMizDgi8iPpISE22cmzrP88+9g
         gcr5CYvpq83Eb4bn/Yx035sQkqXe/ntygFP9EVG2Kg9rsJiGp8MTX+vJfApdeU/afuPi
         +X3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWyWO0Mh7DSIzXqJ3lsxEqCiyuJbM9w502QwDQya4EKqeJkYshf
	Tz31v4ZSJiILZ72XcCYc+asgzWKPFbLNT4KG2zmX0SvKu7LOsnMPNWq4OVOY6g8xcoAFKxvnqp8
	wGtsNuu+ysxk4sJZZFz1+OPdNNijNdt+tuGdnwmAKjTFXYabrHlmNUs92I5zA0Qa1Wg==
X-Received: by 2002:a81:7407:: with SMTP id p7mr8009292ywc.282.1565250746003;
        Thu, 08 Aug 2019 00:52:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLzJQoPTEriTuZxlvaBuiE+q2fECVFz8QDhO2MgiWc6RrUAWH5hmx9juahpoxHfNqwM8Vt
X-Received: by 2002:a81:7407:: with SMTP id p7mr8009280ywc.282.1565250745374;
        Thu, 08 Aug 2019 00:52:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565250745; cv=none;
        d=google.com; s=arc-20160816;
        b=GZ0r2M20Bt74M6KxyFcXdjEjwYAuGIAy54ZLQhemhn5dfpyM6Mkjkk8Rqpl+k1vCYC
         l1npuxEO4O7P+IxkfCNsegS3f1fr4mwkXTwkhFdTVC/H7FPbKc4YzT2opGMutG9NUEOS
         5z9zPucDD3roGe41FREdev26Wj0/szocGQhgZCeMeRW6ubZn3mkr6WBgaDPof0w5DQFq
         /OSc8TInBl1DvcofmZJG1efZe40exopDmj1+5JJIS1rn1XcZp63qgW8XhEg5DOOAViLE
         jZbpOWE0m+Z+uyJxx+zPr/pJu+HXh3tgcZU1tBewsUz7H3uXhjBFmyOiMaar68ybsTyB
         QVgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=+BHJI2YXAwfICzIdAdGeZj4KKn5sG/NIxvWCudui1Ls=;
        b=OVtGA4sj4vCDExRhs4JmFMUSM/U/hN41IpITFzaMv+/eIJfrmX/6NtJ3jRlRhPqHix
         apqcsX8VG7XqttE7VlmB/Pt3JAZ0ESg7uoOoPD7cyNVHvaQguaP1c7EGvuez1p9E8R07
         jfr+eD7zpQUF8LEDhQOhhchLKA97Dh8ZrgYIj50naxjeFfOzQvVaggaKbfhTOKT+GMoK
         rtDofJJa+cJ21UsInB51Q3r/VhoOmgAQMRH+tkNh/07vzDv0r+yXbx95uDwcU4L9UHuQ
         BdGZxcWnCtEo/npSF4fCWeG0XF5u4DHiXU+3NJQTgQffT2FlC13BmmxfOxKqTI6F2V3N
         xuag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l66si28364990ybc.81.2019.08.08.00.52.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 00:52:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x787qEm8006248
	for <linux-mm@kvack.org>; Thu, 8 Aug 2019 03:52:25 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2u8ed2kbfs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Aug 2019 03:52:24 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 8 Aug 2019 08:52:23 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 8 Aug 2019 08:52:19 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x787qIqi31785064
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 8 Aug 2019 07:52:18 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 94EC7A404D;
	Thu,  8 Aug 2019 07:52:18 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CD1F9A4040;
	Thu,  8 Aug 2019 07:52:16 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  8 Aug 2019 07:52:16 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 08 Aug 2019 10:52:16 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Tony Luck <tony.luck@intel.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-sh@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 3/3] sh: switch to generic version of pte allocation
Date: Thu,  8 Aug 2019 10:52:08 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1565250728-21721-1-git-send-email-rppt@linux.ibm.com>
References: <1565250728-21721-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19080807-0016-0000-0000-0000029C2B8E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080807-0017-0000-0000-000032FC2D77
Message-Id: <1565250728-21721-4-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-08_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=920 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908080090
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The sh implementation pte_alloc_one(), pte_alloc_one_kernel(),
pte_free_kernel() and pte_free() is identical to the generic except of lack
of __GFP_ACCOUNT for the user PTEs allocation.

Switch sh to use generic version of these functions.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/sh/include/asm/pgalloc.h | 34 +---------------------------------
 1 file changed, 1 insertion(+), 33 deletions(-)

diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index 9e15054..8c6341a 100644
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -3,6 +3,7 @@
 #define __ASM_SH_PGALLOC_H
 
 #include <asm/page.h>
+#include <asm-generic/pgalloc.h>
 
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
@@ -26,39 +27,6 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 }
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
-/*
- * Allocate and free page tables.
- */
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
-}
-
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
 #define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
 	pgtable_page_dtor(pte);				\
-- 
2.7.4

