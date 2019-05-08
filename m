Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F3E0C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E0F5214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E0F5214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D77616B026D; Wed,  8 May 2019 02:17:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D506C6B026E; Wed,  8 May 2019 02:17:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C15EB6B026F; Wed,  8 May 2019 02:17:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0CC16B026D
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:17:58 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id k10so12064947ywb.18
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:17:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=t7dg5T44Dd4KXE8IEpFncflshllFm9CtUz+kLIXhYgI=;
        b=SegLgv4g71bwERZ4xrgBT9nE3a/xl/Lf3eUwxx6L5OS5bhuzsm0+OOlDfzdUwJjWcz
         Ev+/3VVktvN9H5IPNbNuugUXVLmIUfL2m9W8C+A/WVTEWVYnLmWzrPs6I2Tm54gpXKnU
         CEymJ4lbz7lfm2c4lBrujr7/TcTcJ8YO6+WfKRkbhpTConmifCBOXEzdTqu6qGy8p/HI
         2oJb4cDN5b5NsnehlnzKzjm1SBsEhVPVwobKYfYsifkNSbYGYPa+ha5RAEQo+L5d33Qp
         7r6olWGqgQf6JI9P972Vz9B/I0qsHmg386NrrQoi7cAZ7Lv/LxKrAXhtxQpmI7Tzo0p4
         qyxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVZccbqWJmY57FYQhJY2cvHX02vWUjqWiHvba7awDVA54ECseVE
	2ypwY3YCMBvvZBr7QZTF5wK+DCIrtXMQjUPpXaXF6xpwKJvJNuAHFh0kpOtq25gjZC6pdf39fzI
	uCcVhKZStUiIT1ldwOhK+TIehCSqQZS6gECguEZQmEwihQhaVKqhfKhRg1Z+lmjhLNA==
X-Received: by 2002:a81:84d7:: with SMTP id u206mr19077592ywf.497.1557296278374;
        Tue, 07 May 2019 23:17:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyqXzhO59cuw+E87+mISjUGuAgo+v1jFa8BCfYZ+s8Cai/9yusJJOx+D5LPruwdUhVj0Z2
X-Received: by 2002:a81:84d7:: with SMTP id u206mr19077551ywf.497.1557296277305;
        Tue, 07 May 2019 23:17:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296277; cv=none;
        d=google.com; s=arc-20160816;
        b=vwnt04Pv548wdUpmqRdkTk3PRKeAGJVlQXE3aao4O/IYge/6/y80MGQpL0XO245MH8
         VkWHu5jmvmTAWVD2iGDJkrcwuSIw+8++qO3R7lp8Y8QLyZkR9EzhdiyVwU9Ri3uLEd9F
         OKJ+fwZlmdH+lWt7a/OKBrFDmoMu2MDhpwkI57wehsbwEmTPxTDnNpcsbXcN9p0pKxEA
         xpIFA83VNYIzpesvQLSwL3oAwRTVG77S17gRwy7jF9ez4C/Mq6Wg/vok1PQa1dqkDEwf
         NgjJt8mw6qBqbW/nIe1u3Yshbp36YxOZp8Dz4blC9ZBb+ehtWIR9h0OzheYgwrWMVXdt
         DCyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=t7dg5T44Dd4KXE8IEpFncflshllFm9CtUz+kLIXhYgI=;
        b=T8szVAgcvuHAYXRvY8Nu+qypJIcKRAAe/2TWG48T3adU6OMYSMzRApnfd4M3RFqm8N
         UzE5N+oha+dyyZ1uTXt6D6BDjI91CGu2mk2nhjQKW0BC76XLnPAmXdHb26l15pBWeo/g
         3H0GCbqjicZbw1hQVxlzc4Vr6dk25evU3bMlvzbg9QbzlOi/eJFJ9XBboqihhyH4x4XU
         USlKDdfe65M9PGVIVOqzlq0aZawUPE+dHHoQh5u2GCjfadJRy8T1YdUsu67nvjsVGOog
         F8cDg9DeXg3wAoOOhBapNZSDMuRV11HMZsvJe2f9YEQlRu0ayMRj0cnYJsdcqutUEUqV
         yWxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e6si4536870ybk.484.2019.05.07.23.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:17:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GVJE075944
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:17:57 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbqa5x3t4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:17:56 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:17:54 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:45 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486HiZB51380408
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:44 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 810B1A4053;
	Wed,  8 May 2019 06:17:44 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3854AA404D;
	Wed,  8 May 2019 06:17:41 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:17:41 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:40 +0300
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
Subject: [PATCH v2 07/14] m68k: sun3: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:04 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0020-0000-0000-0000033A6940
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0021-0000-0000-0000218D086B
Message-Id: <1557296232-15361-8-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=773 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The sun3 MMU variant of m68k uses GFP_KERNEL to allocate a PTE page and
then memset(0) or clear_highpage() to clear it.

This is equivalent to allocating the page with GFP_KERNEL | __GFP_ZERO,
which allows replacing sun3 implementation of pte_alloc_one() and
pte_alloc_one_kernel() with the generic ones.

The pte_free() and pte_free_kernel() versions are identical to the generic
ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/m68k/include/asm/sun3_pgalloc.h | 41 ++----------------------------------
 1 file changed, 2 insertions(+), 39 deletions(-)

diff --git a/arch/m68k/include/asm/sun3_pgalloc.h b/arch/m68k/include/asm/sun3_pgalloc.h
index 1456c5e..1a8ddbd 100644
--- a/arch/m68k/include/asm/sun3_pgalloc.h
+++ b/arch/m68k/include/asm/sun3_pgalloc.h
@@ -13,55 +13,18 @@
 
 #include <asm/tlb.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 extern const char bad_pmd_string[];
 
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
 
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-        free_page((unsigned long) pte);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t page)
-{
-	pgtable_page_dtor(page);
-        __free_page(page);
-}
-
 #define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
 	pgtable_page_dtor(pte);				\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	unsigned long page = __get_free_page(GFP_KERNEL);
-
-	if (!page)
-		return NULL;
-
-	memset((void *)page, 0, PAGE_SIZE);
-	return (pte_t *) (page);
-}
-
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
-{
-        struct page *page = alloc_pages(GFP_KERNEL, 0);
-
-	if (page == NULL)
-		return NULL;
-
-	clear_highpage(page);
-	if (!pgtable_page_ctor(page)) {
-		__free_page(page);
-		return NULL;
-	}
-	return page;
-
-}
-
 static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
 {
 	pmd_val(*pmd) = __pa((unsigned long)pte);
-- 
2.7.4

