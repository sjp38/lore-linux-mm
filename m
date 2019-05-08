Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C53C0C04AAE
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B5BE214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B5BE214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B7696B000A; Wed,  8 May 2019 02:17:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 167FD6B000C; Wed,  8 May 2019 02:17:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 030846B000D; Wed,  8 May 2019 02:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC1736B000A
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:17:39 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j62so36025860ywe.3
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:17:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=pzcpsKtRjHX9AmWbU7IwER1/7nYGwT4KOYESImvW+sQ=;
        b=SUew1Xf9ZJ0LyrnUS3/V4hBvlYGjoirgOr1qKH6AHdxfip8JSFpSohsznudLA2uVO1
         U/j/GJjemPhxK0QwqhlZdzuU4G/hPwPr9CCUYdr2jUYXtnyx8EDMNE1Rf/JmqVKXhcF+
         RkiRUt9LGZ0c6PGGhrKGCvBPxAl0PAW1T47Yv2k0hQdZTTMdJI+GSFj8loXha7sbV+uI
         X4wczXtVNXC5R7fevMF7jEbBB+b0ick7i/wGUws55+vGBxelubK689yksGREjuf8jwa0
         R5vMliHBe2cvrkFRnvvfDv/ICMsaa6xAlYYzbfMS0JzUqu/K3l4UYeD7qtWzHOk1kDDU
         H90A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVZclJRZ2Rj/J+jYE3e37CmmUEXS7q9TOfZK7wdkbCWxdPacPW9
	esEXRA8SWLc8eYNF5+/5eV8Mi961ZZ3HkfA87cXmT+l6N4Db9dJyy24izvyEt2KRoKHt3OVKqOI
	z7ON/utGbg7PsggKJ6t3fHL5LL1q5fXCSEl7NeS/LHfMRO2hoERRAsjqHa4PMHLJ9xQ==
X-Received: by 2002:a81:3685:: with SMTP id d127mr22384812ywa.32.1557296259597;
        Tue, 07 May 2019 23:17:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXTHwQvKlp1rSoNAf0RGtFCgV3Ka5MHNQKKwXMGkiBK9m96JuVdEFtV8/AlknhFc0TNiPj
X-Received: by 2002:a81:3685:: with SMTP id d127mr22384780ywa.32.1557296258632;
        Tue, 07 May 2019 23:17:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296258; cv=none;
        d=google.com; s=arc-20160816;
        b=v2Cx52zqWFdJFPzpYqFFu5Gv7U3b3yVhSvO3PYquGCt04jIyUOCTFzwotNsaHCgcMh
         h9U3hN2A8ITuHtcSb+XNO0s1BM1Z21uwN5fNgJvKPmvoqOnR1t57rteqOG7VD7TQlFPh
         O9GgYrhxX4vpiOLXPXpM5lRlCbV7plBLjKVF8AO0RL0OdQkB0aWkZsLFxthqDhRcTFSb
         5mU7F2q6XNemuLoCpcKo6Vc7jAirHPgIM7XxQq+990jPLoYyp637hDf+CutTqdKK0P4l
         cXJpnwypq0nnFNVzixozeQ7fW4095ylcT8g9FiYvCBpbB6DfAqG03gL1RI0ApK09MiXg
         oVIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=pzcpsKtRjHX9AmWbU7IwER1/7nYGwT4KOYESImvW+sQ=;
        b=VBBYQj3fCYPdjPLGMG1qpVBDlqVe3uEtWWmS7sYJHvorG3zCFyt7wUusaVq+Wc6/qM
         vYxCp+TysCAx8COLgoXFu2x6QiSSYrlxmyNnjlFMg+FTpIUrlz1h0ocx8pRidH1QjqlZ
         gTWbx3pr3pkO64+TKqsE7KWlgPK8fVNMmUtEAzl1Eiwpgu/71US7eHQvjTFDTTgFzwHt
         +yRKQ/YTffUjZrWr+76isy4hqTKYNMU6wn2RiiFWiFifzME8M/8LIN9szU8bqdlui3Wg
         4W0xtNpjATQpFaWiPrBEls/4mnyI50G4czuF14PBGxTdHtZGnRGnMcKN9jn1EO7xhcd/
         iH5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q184si1424222ywh.163.2019.05.07.23.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:17:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GYu9076105
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:17:38 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbqa5x3er-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:17:38 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:17:35 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:25 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486HO2w43909196
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:24 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 89B4F52051;
	Wed,  8 May 2019 06:17:24 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 4F91C52050;
	Wed,  8 May 2019 06:17:21 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:20 +0300
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
Subject: [PATCH v2 02/14] alpha: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:16:59 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0028-0000-0000-0000036B6E51
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0029-0000-0000-0000242AEA19
Message-Id: <1557296232-15361-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=794 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

alpha allocates PTE pages with __get_free_page() and uses
GFP_KERNEL | __GFP_ZERO for the allocations.

Switch it to the generic version that does exactly the same thing for the
kernel page tables and adds __GFP_ACCOUNT for the user PTEs.

The alpha pte_free() and pte_free_kernel() versions are identical to the
generic ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/alpha/include/asm/pgalloc.h | 40 +++-------------------------------------
 1 file changed, 3 insertions(+), 37 deletions(-)

diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgalloc.h
index 02f9f91..71ded3b 100644
--- a/arch/alpha/include/asm/pgalloc.h
+++ b/arch/alpha/include/asm/pgalloc.h
@@ -5,6 +5,8 @@
 #include <linux/mm.h>
 #include <linux/mmzone.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 /*      
  * Allocate and free page tables. The xxx_kernel() versions are
  * used to allocate a kernel page table - this turns on ASN bits
@@ -41,7 +43,7 @@ pgd_free(struct mm_struct *mm, pgd_t *pgd)
 static inline pmd_t *
 pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pmd_t *ret = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
+	pmd_t *ret = (pmd_t *)__get_free_page(GFP_PGTABLE_USER);
 	return ret;
 }
 
@@ -51,42 +53,6 @@ pmd_free(struct mm_struct *mm, pmd_t *pmd)
 	free_page((unsigned long)pmd);
 }
 
-static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
-	return pte;
-}
-
-static inline void
-pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
-
-static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm)
-{
-	pte_t *pte = pte_alloc_one_kernel(mm);
-	struct page *page;
-
-	if (!pte)
-		return NULL;
-	page = virt_to_page(pte);
-	if (!pgtable_page_ctor(page)) {
-		__free_page(page);
-		return NULL;
-	}
-	return page;
-}
-
-static inline void
-pte_free(struct mm_struct *mm, pgtable_t page)
-{
-	pgtable_page_dtor(page);
-	__free_page(page);
-}
-
 #define check_pgt_cache()	do { } while (0)
 
 #endif /* _ALPHA_PGALLOC_H */
-- 
2.7.4

