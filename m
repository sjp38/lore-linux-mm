Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12411C76195
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 14:19:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B36FD20828
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 14:19:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B36FD20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AF378E000C; Sun, 21 Jul 2019 10:19:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15F698E0005; Sun, 21 Jul 2019 10:19:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04E758E000C; Sun, 21 Jul 2019 10:19:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFC0F8E0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 10:19:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y66so21997176pfb.21
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 07:19:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:mime-version:content-disposition:user-agent:message-id;
        bh=mtKq0p8eXC2Dx800lhNUwX3iSe8yQWF9xJxQtizQWsc=;
        b=XC+nOl1eqS/ZG7lDdL1nsC7+Uc42UcaZvkSGLavVXur/HE/JnHeCuWkVv8ULjKM25x
         uYMpdh6YL2Kg1hkGVIZBPP+09mZDLTqS4yL9qEsdf3zih5+ac9veWmqbNNr/CgFKWJVb
         DVuW3ijWTj2zgqdxLIWcqDtdM6pO/O9PSPm5QU6ZmRovdDNiAqhGS5o94fiXic7KLc10
         X6BwBKLBzfhiIw0rOC6Zlv75Tps+rSeci3/lXLxpOdroJRnlvBrRZcAPyxZT9NS/6Ul6
         azcmA8yPIPdg/OBrK3aE1B2bWg5HDu6AxGw34BJ74ZwPPiHpkCLV8+u9r/qE3Z50hNsV
         1Iig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUJ/+sSmFjOb0ztfME2IV1zz9ih8JSoMci9un365KFDvXamRaBV
	PHP6fF7Pa+bCCrcH37uwlvB/iUTFdVdyrscoSr5Ys037TTcvyD59/9QrNe/oWodxXXclJ3Iwj70
	wTQAB5t1rH0tRp+okFVDZI5Xp+dZcl3KGn+TijoAwR6gjTrAiDrA05YLYzHBDDgpg5g==
X-Received: by 2002:a17:902:b48c:: with SMTP id y12mr35884894plr.202.1563718764367;
        Sun, 21 Jul 2019 07:19:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz66v3BGuOhDa1xQUknxZK0OcbR1PLEDvXFLajGAoq8krXz5Zk7P4cuFrWqPWpPY9x7yoAf
X-Received: by 2002:a17:902:b48c:: with SMTP id y12mr35884843plr.202.1563718763613;
        Sun, 21 Jul 2019 07:19:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563718763; cv=none;
        d=google.com; s=arc-20160816;
        b=CED5zowe5KXqODvbgbIRueX6zPjEzPqgdQBO/adh+Og+fzDZ2XqTN7PaeOYlnkvi/u
         hhWSujpOj2YhDjzj9Ot06pi00zKg50ChEB2shGMZ/PK5KgYAbDdSUke+nCWxlti51c3v
         iCE2BNjlOQVFUQF2p0P+7aA0+N5axpjbD7jKCrlJ8fG42KONxEefDL9YF6ZrgQu5HtLV
         Xsjwa2uRCtenCGpChJjWxsTvXlpwSbW2pcL40pwU1slmIaBw4s6tFNps1OApXSBaSPKL
         XAGSjaMJluuT3zPerMdZ/404SBwwvY+Hg13N58bcM1Ru2Tl7dTgSRAJAYUdvGaOhBINt
         qPBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:content-disposition:mime-version:subject:cc
         :to:from:date;
        bh=mtKq0p8eXC2Dx800lhNUwX3iSe8yQWF9xJxQtizQWsc=;
        b=t4y2pl56CyJ6OiaDk89Av8GOiTIybFDSuXIa858XSjaLGbMYhH9FLsUVgnMQHWHmNe
         +tUwsEDabpAvp7w5SlwoAFmwiOxuGq7U332zHEh1eB+SLBoCQaP1sNinkgZgmOEa4Bw0
         ISEVr1RF8+5eTWnjkr+ceNCuMixcbJGzDVqQixl/G7E/p00T7FSHyEUs/YKs7ip+QZA1
         oUeVcTCpTXc3GEzupx1FvQd2OqPbbkMVa7PRwUM5xaMGF6OSTBZimoFgt/A4wgd1xaY1
         brrB9oEmGZZH93hd8NNafui601Hjqa96bKgqC3ob8mZA7JB5zttlAa6z8RgbHSeO7yA7
         VRuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p35si6406384pgb.484.2019.07.21.07.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 07:19:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6LE1qJq023394
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 10:19:23 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tvg2q8bu1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 10:19:22 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 21 Jul 2019 15:19:20 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 21 Jul 2019 15:19:18 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6LEJHJg12845238
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 21 Jul 2019 14:19:17 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3D4F4A4054;
	Sun, 21 Jul 2019 14:19:17 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AAF83A405B;
	Sun, 21 Jul 2019 14:19:16 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 21 Jul 2019 14:19:16 +0000 (GMT)
Date: Sun, 21 Jul 2019 17:19:14 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Richard Kuo <rkuo@codeaurora.org>, linux-hexagon@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: [RESEND PATCH v2 06/14] hexagon: switch to generic version of pte
 allocation
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19072114-0028-0000-0000-00000386899B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072114-0029-0000-0000-00002446BA21
Message-Id: <20190721141914.GD26312@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-21_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=912 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907210171
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

The patch below was a part of of the series that switched a couple of
arches to use generic versions of pte_{alloc,free}_one.

Unfortunately, it fell between the cracks and I've noticed this only today :(

I understand that merge window is going to close in couple of hours, but
maybe this may still go in?

-- 
Sincerely yours,
Mike.

From e298accfb0b023de70e255adf3f9a8d1b2c01063 Mon Sep 17 00:00:00 2001
From: Mike Rapoport <rppt@linux.ibm.com>
Date: Tue, 30 Apr 2019 17:27:50 +0300
Subject: [PATCH v2 06/14] hexagon: switch to generic version of pte allocation

The hexagon implementation pte_alloc_one(), pte_alloc_one_kernel(),
pte_free_kernel() and pte_free() is identical to the generic except of
lack of __GFP_ACCOUNT for the user PTEs allocation.

Switch hexagon to use generic version of these functions.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/hexagon/include/asm/pgalloc.h | 34 ++--------------------------------
 1 file changed, 2 insertions(+), 32 deletions(-)

diff --git a/arch/hexagon/include/asm/pgalloc.h b/arch/hexagon/include/asm/pgalloc.h
index d361838..7661a26 100644
--- a/arch/hexagon/include/asm/pgalloc.h
+++ b/arch/hexagon/include/asm/pgalloc.h
@@ -24,6 +24,8 @@
 #include <asm/mem-layout.h>
 #include <asm/atomic.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 #define check_pgt_cache() do {} while (0)
 
 extern unsigned long long kmap_generation;
@@ -59,38 +61,6 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long) pgd);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *pte;
-
-	pte = alloc_page(GFP_KERNEL | __GFP_ZERO);
-	if (!pte)
-		return NULL;
-	if (!pgtable_page_ctor(pte)) {
-		__free_page(pte);
-		return NULL;
-	}
-	return pte;
-}
-
-/* _kernel variant gets to use a different allocator */
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	gfp_t flags =  GFP_KERNEL | __GFP_ZERO;
-	return (pte_t *) __get_free_page(flags);
-}
-
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
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
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 				pgtable_t pte)
 {
-- 
2.7.4


