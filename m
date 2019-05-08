Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB362C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7F7421726
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:17:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7F7421726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2BE96B0269; Wed,  8 May 2019 02:17:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADCF86B026A; Wed,  8 May 2019 02:17:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E16C6B026B; Wed,  8 May 2019 02:17:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 68EB46B0269
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:17:50 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j66so35808306ywa.17
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:17:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=KMDH7UhlqrjDMi05SGu6p2scdtnri2K5p9n09LvWutA=;
        b=BwfHAHp9QJEsPQCsytJlE2MN8tPCJyW2niAeohWr540+mSMsbhorv8ufmzM3qwt3vM
         e1wALZNe+ibd5WGreP14sc/QdgNJ75j9uO/ylDwsumU8DliwEMSHKh8dZtVAiCnFXTny
         fyhaoi7NeKfQ4Tp9J2JjjjJ36nYpDWBt1FUfbP/j5RVKjI3F1jff2q/jQtmCZrJSSxqS
         78W/hpaisLFmjUf/Kh3Y0a0GELBhq5hGGwDpFPtDqCdJdSsUrPldKoM48X1Ip1foyQDP
         aseCvnLLiG74KJMmvOLBCiK73TVaTlRSGIaJwQK2DMCIOO/YF1WNDisA4WDlx1Y2a/gj
         9/YA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWubnzalDnyEHAk2rRvrRv+y7mbKf8SWgamK5uGg60If4nnoQaS
	ok+lnxF7b/u9s07cbkavt3IbvLoQZgEZeVcQHG9YCRbqWa8c8OQdohlffAbpHS9c1KBRNUlcBrj
	TzaOGNl+c6UOFuSPta5DdMWtRxBGFK68qt4/wl5Tm+gekwdAj9xSstiHkKQ4YPHBjuQ==
X-Received: by 2002:a81:120c:: with SMTP id 12mr24417572yws.74.1557296270190;
        Tue, 07 May 2019 23:17:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzs9y9ewYJQzJF3H0SOcsE/hh6am1v6Y4UU8HIMaU6gowiclMLylOHTU1XHyBsCrOhGjA3S
X-Received: by 2002:a81:120c:: with SMTP id 12mr24417555yws.74.1557296269511;
        Tue, 07 May 2019 23:17:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296269; cv=none;
        d=google.com; s=arc-20160816;
        b=pWnHELhooHiPzNN/2NUAvTUavhj71rB/OI0sNHr33SaJX9YNn6kqSgu01enU/8d6yo
         spAynNj4JedxxPcseSw9BsQgXQYE9ip0rqCS7XQjxS6tBLhBXNtIybIJGtLNR+/o8GSj
         X2M/+A9GbWBtMeu0BH0yhRi083vDbf07/UBVIsZTCGl7DjHUCY5m4gMbGPD+vSBIqLrR
         LD25K4la/pJQqQ7E1gpEIZHEgHfutuG6apMpFjkoi0c0erxOra7+6NqZ/IK+Mpp3tS3h
         KRBlT75mQxnstbnNoSm96lUMTbPZesoGCsGKrCw2UCElKU8zTySWXWYfJwYBuzqNU5Wo
         i+ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=KMDH7UhlqrjDMi05SGu6p2scdtnri2K5p9n09LvWutA=;
        b=tmGav1Ual1d5uysz8ZBsHVIFg7anSWzNjgL3sejfz/oiQWq3trJI2n5yOyXyJDQSzH
         BasqA2rqXw3xI/SfEL6Ma+SYjopOVYq1+5r+IXukHFTXWj+oiQU1TTGZ2flyFQJIl0LE
         +oCoSwjPnh+Jlej7rFJDhBHDEJvted2FAQ4dwRvkq0aVhQegdJmbnv1lVcg1F8InOYz5
         wsP5erKcn2f7E4wyeqUmw6QiRnlUnY5kuHAIWeCDe5VpnFsDMtJKodIg0VSmqAt65TCF
         BNy+X3GmxkCF+79dchkWknsACVzn8RNnbDXFos7cnJ6sT0mnmb8u0lIGQYcZ3bGw7xtl
         cvWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p188si6569257ywb.383.2019.05.07.23.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:17:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486GlBd015237
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:17:49 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sbq4h6g3m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:17:48 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:17:46 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:37 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486HaIa31326456
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:36 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6AFE14C044;
	Wed,  8 May 2019 06:17:36 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 25EBD4C040;
	Wed,  8 May 2019 06:17:33 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 06:17:33 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:32 +0300
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
Subject: [PATCH v2 05/14] csky: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:02 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0028-0000-0000-0000036B6E57
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0029-0000-0000-0000242AEA20
Message-Id: <1557296232-15361-6-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=824 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The csky implementation pte_alloc_one(), pte_free_kernel() and pte_free()
is identical to the generic except of lack of __GFP_ACCOUNT for the user
PTEs allocation.

Switch csky to use generic version of these functions.

The csky implementation of pte_alloc_one_kernel() is not replaced because
it does not clear the allocated page but rather sets each PTE in it to a
non-zero value.

The pte_free_kernel() and pte_free() versions on csky are identical to the
generic ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Acked-by: Guo Ren <ren_guo@c-sky.com>
---
 arch/csky/include/asm/pgalloc.h | 30 +++---------------------------
 1 file changed, 3 insertions(+), 27 deletions(-)

diff --git a/arch/csky/include/asm/pgalloc.h b/arch/csky/include/asm/pgalloc.h
index d213bb4..98c571670 100644
--- a/arch/csky/include/asm/pgalloc.h
+++ b/arch/csky/include/asm/pgalloc.h
@@ -8,6 +8,9 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 
+#define __HAVE_ARCH_PTE_ALLOC_ONE_KERNEL
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 					pte_t *pte)
 {
@@ -39,33 +42,6 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 	return pte;
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *pte;
-
-	pte = alloc_pages(GFP_KERNEL | __GFP_ZERO, 0);
-	if (!pte)
-		return NULL;
-
-	if (!pgtable_page_ctor(pte)) {
-		__free_page(pte);
-		return NULL;
-	}
-
-	return pte;
-}
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_pages((unsigned long)pte, PTE_ORDER);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
-{
-	pgtable_page_dtor(pte);
-	__free_pages(pte, PTE_ORDER);
-}
-
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	free_pages((unsigned long)pgd, PGD_ORDER);
-- 
2.7.4

