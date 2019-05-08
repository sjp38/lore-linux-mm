Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 035DDC04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB521214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 06:18:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB521214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70E9E6B026F; Wed,  8 May 2019 02:18:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E4816B0270; Wed,  8 May 2019 02:18:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AD5B6B0271; Wed,  8 May 2019 02:18:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 248266B026F
	for <linux-mm@kvack.org>; Wed,  8 May 2019 02:18:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f1so3855928pfb.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 23:18:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=EWDwpjZZgdEdYfUucqT500NcxqqXwlQVEbW1HYDX34E=;
        b=rZzRMGwkXjH3rcor5gpOiKlM75eAknIu9v2x7Mr3dH8EHNi/L0Uxwqi9tmQzWQfRa1
         mJgkMncNT1gwQ1rw/xc/RsAky2Cmv6xL7jTbbcyvAazQqyMzAgAx/J4PhrCbdFdbHu+Y
         5tITO5CvRwARUkRc0HQmzq/jabVn3bdGs5bxJLKezKtOtcduCrei7MCtfMcOzA59iZRS
         BWkBdjwfZtag1yWGSGpOsjyVt27W8EJmLjC+Tiz/l4N6g1LpBI0UpZ+qQGppyOe7Hp5N
         AJaNwd8erDzo1D99DUDIynpWW9NVZ/mI1BbKojTbkOjqDZhlRzbgF+0XWIy8wYVOdmoU
         5RHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAULLok1iFyGG05b5Yk4rjW3lwbqV0YeY0b4xJECYG1yilzbl0hy
	JLzjMvnVoZ7nnAhJQsQ1xPqD6Fc4zprCS+hBc6KMDyd8uNr50gmrRAC8rwOG2W1gH12vecJp2DT
	qbwa+YUL3G3mV4D56x3OB/6Wo5TFMMoqGAhn5L2NLBcknbiQQDLXYsEXOdtYO3T3m6w==
X-Received: by 2002:a62:579b:: with SMTP id i27mr27809906pfj.205.1557296282822;
        Tue, 07 May 2019 23:18:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxoX3HMm7r+DAE+M5e1fl3SFj34+nw0bDzub09Yj2jdts1Zx1sq9iYrLv1HHy/o/fCDiQ4
X-Received: by 2002:a62:579b:: with SMTP id i27mr27809846pfj.205.1557296281852;
        Tue, 07 May 2019 23:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557296281; cv=none;
        d=google.com; s=arc-20160816;
        b=gtc1ZTSgssnrg1uz7y8FxmJWDXlvyUb38vjOBJR4tRj3faFqJwwm6LgGQ1lBP8i+8o
         uk/zmIBssnqz2MaEJg7a5kc+4iGaLS7N6gtMvAXAcbR+N65Vn4j0IrVpjclkeyo8ctjh
         gEGtdwUuMrWlnHKiV7yfpdP5B3R5mJDX046XW72iJXT/3ELPWdD6G4+KuWekASBoEB76
         b70M8Yc7ZjEB7YjsYez/uwIsLHF0L+sg9jjnexSRgA1Xp/dIp3sChOxHSf6kuILQPE/A
         C1Nb2psPX9V+YPpiRA2rweJT67csP+84R8qQBZsZymzwxfHZy5M3djcSQltJPFizbIUf
         XG+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=EWDwpjZZgdEdYfUucqT500NcxqqXwlQVEbW1HYDX34E=;
        b=d3UFwUF94jL2TA6DS64uWn3Na/bv0fwsuNYL2Q7cvv0/5S+yrsVVOGRn68t8xFWP2M
         XvtcBKtw6jgupRqEzdyuXiBPH/fpZITp1o6YrjGAL0+/VcZC/FuGsUEqmle0MkE1ugDx
         KFTHrLJK1mdfGLqMQ3+vXdS3AOl2KZKhbRqrievO6mKUT70sPv9qXuS4vkVmtPdlXma/
         yEiFb6kSAMvvPicaEQVDYBz4pGsuz/yyaoKToJMA3UPWlgdLNGIkq5xy16YWl9w9Sc4+
         2mpLa5qsmri17E159EEJ+dQVGhBDa+G4PqPqpKe1BfSk6LxJA8OHz0i5/U04jtO3kpfZ
         cBrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r8si20916475pgg.345.2019.05.07.23.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 23:18:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x486HmxT034051
	for <linux-mm@kvack.org>; Wed, 8 May 2019 02:18:01 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbpupfdb6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 02:18:00 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 07:17:58 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 07:17:49 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x486Hmp335127468
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 06:17:48 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5DD2752050;
	Wed,  8 May 2019 06:17:48 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 2163652074;
	Wed,  8 May 2019 06:17:45 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 09:17:44 +0300
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
Subject: [PATCH v2 08/14] mips: switch to generic version of pte allocation
Date: Wed,  8 May 2019 09:17:05 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
References: <1557296232-15361-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050806-0012-0000-0000-000003196C54
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050806-0013-0000-0000-00002151EC5C
Message-Id: <1557296232-15361-9-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=860 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

MIPS allocates kernel PTE pages with

	__get_free_pages(GFP_KERNEL | __GFP_ZERO, PTE_ORDER)

and user PTE pages with

	pte = alloc_pages(GFP_KERNEL, PTE_ORDER)

and then uses clear_highpage(pte) to zero out the allocated page for the
user page tables.

The PTE_ORDER is hardwired to zero, which makes MIPS implementation almost
identical to the generic one.

Switch MIPS to the generic version that does exactly the same thing for the
kernel page tables and adds __GFP_ACCOUNT for the user PTEs.

The pte_free_kernel() and pte_free() versions on mips are identical to the
generic ones and can be simply dropped.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Acked-by: Paul Burton <paul.burton@mips.com>
---
 arch/mips/include/asm/pgalloc.h | 33 ++-------------------------------
 1 file changed, 2 insertions(+), 31 deletions(-)

diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index 27808d9..aa16b85 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -13,6 +13,8 @@
 #include <linux/mm.h>
 #include <linux/sched.h>
 
+#include <asm-generic/pgalloc.h>	/* for pte_{alloc,free}_one */
+
 static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 	pte_t *pte)
 {
@@ -50,37 +52,6 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
-{
-	return (pte_t *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, PTE_ORDER);
-}
-
-static inline struct page *pte_alloc_one(struct mm_struct *mm)
-{
-	struct page *pte;
-
-	pte = alloc_pages(GFP_KERNEL, PTE_ORDER);
-	if (!pte)
-		return NULL;
-	clear_highpage(pte);
-	if (!pgtable_page_ctor(pte)) {
-		__free_page(pte);
-		return NULL;
-	}
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
 #define __pte_free_tlb(tlb,pte,address)			\
 do {							\
 	pgtable_page_dtor(pte);				\
-- 
2.7.4

