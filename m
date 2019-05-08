Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 563C3C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13CC9216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13CC9216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC9C86B026B; Wed,  8 May 2019 02:17:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA1556B026C; Wed,  8 May 2019 02:17:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A67DB6B026D; Wed,  8 May 2019 02:17:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFD86B026B
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:17:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s8so12029953pgk.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:17:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=RSDhRSRvqbQGJ2LHREuCN7qGXp3a6Z///hrRs7dnlmw=;
        b=W0UyWZOlnv9rcueDQ27pOha2L0tAcffyGlcVq49xk6jFp6J6FKkLqgK6Amh/kFb5uq
         WrQv8zQp89HhFRzTwF/9CQOgxFIlkNh4ADZJ6KOjUr4i4MhYrghWru9MkG6FroaZef2N
         bhf8UkW6UdlYLIhmr3bgFC2a33G47ovFV4K1e/LI+sxirlg69Y8kCNf6/lAdOuDbDGUH
         NiAzVTnmBkD5fGsvgK6IhLWSuZT1mKbypjAkAsckC6XRo5X2ykpCGHxOfc2BdeqAH2EK
         yksg/ftVs/NxGsJD0bgVMOWIgH0frwskDCz1JSOGv8nWyCM+xO7ocrNCz7jnMFWoWnqC
         l7Uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWdT2HefHVWiIRE9wULADT0SwrF8xnmMqK36HNHEWe0i9k6qne0
	qpJWbl7EpFF/ViRb8dWfSjqmvGRM+RrHL4li+wHwl42PIKuw3OHaYYKO/0SE9APNNXIc7CwKiAH
	ClXvaNLBiAXCpdQdwDrhrR8khuA9Ac8tOMUx0snC2wNCpVXUM8yqHcDrS4cwuJ/OkkQ==
X-Received: by 2002:a63:d512:: with SMTP id c18mr45851364pgg.252.1557296274115;
        Tue, 07 May 2019 23:17:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3NbS8vPRDaBM1bJI4mqD2oW5McBxAjnLdizy7ZBpPGg7miAj2WcE5OlKkdZq8o9qFXKag
X-Received: by 2002:a63:d512:: with SMTP id c18mr45851322pgg.252.1557296273421;
        Tue, 07 May 2019 23:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296273; cv=none;
        d=google.com; s=arc-20160816;
        b=RR8xLa3H3dfklS9imtjZn1uPgoUtcWMys6A9LO+HDPD7RMFAXNdHQQyt2azDWFA2ct
         ZMbGhq1AdRgzO6uPRfDBSN/1ssxWcEFcg3D6VXwR1LjswUwbSfajN+N8fSZ0OuRKf+Sr
         574uTJT0kBjDrw+dxgyWpjjNTEQ+LljXgI+NQZjfneI6yAValOXjDWUZhGrJq1LV4pvS
         wxEjBvzmsArNMegX6lcDHRVoFPR2zCGtUGuVF978FoDK3AlxcAjVBbYc9f2G5yhiPvso
         7EOazPBb5YFvcQwKixOFfqjWVDtnuVjSCjJ8LKQESum2At6QJw15/q1Fphcb1AF7x6wa
         gIYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=RSDhRSRvqbQGJ2LHREuCN7qGXp3a6Z///hrRs7dnlmw=;
        b=S0PeJkVZej0Iwi6CCRfgEBHthkJSmxj9mMgzpOEsgd3uYBfUuF/AWUP3CJE+vq555u
         YM1bSUQ80XUo27mIGvRjvJDMwl/OzjY7ySZzBgQ1bvKyCgXrfGKWh7EeZuu90QERrKm9
         3NdevX4JnkpkfM6XMOSWqof0sjqSrQw5StUbrTXOlKY3h7cMPDBvbyikO8wqlPGEkuHp
         dhq1EkCHbuztlDoAMIRhSAyfddLlQlCk0Sfo1nfm03N3ldnbZ1mteFawBV3/tN+DnCnp
         Vi2x60Q8Oz27w+7lJMxMFP+f0uZxP290H+HacAsr8OGlhLAEvjCnGf1/RCsClHnkQrQU
         IdlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f1si15643711pgi.432.2019.05.07.23.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GWBQ031189
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:17:53 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbs3hhk4d-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:17:52 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:17:49 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:41 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486Hebs27459718
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:40 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 645BEA405B;
	Wed,  8 May 2019 06:17:40 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2048DA4060;
	Wed,  8 May 2019 06:17:37 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:17:37 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:36 +0300
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
Subject: [PATCH v2 06/14] hexagon: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:03 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0020-0000-0000-0000033A693F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0021-0000-0000-0000218D0869
Message-Id: <1557296232-15361-7-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=736 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

