Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5204AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 024FA2184D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="rNHXO1mN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 024FA2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC6B18E0009; Tue, 26 Feb 2019 12:22:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A288A8E0003; Tue, 26 Feb 2019 12:22:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87DE68E0009; Tue, 26 Feb 2019 12:22:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24EC08E0003
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:50 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id n12so712724wmc.2
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
        b=CqDtb1+8nRjxNoPiPUc2rzRw0mHCp9D/7I17QyXs6SUsFmI9LoNKeoeOpZaUfRnFo8
         /CT23tDEQKlZTtNvBkkYXK9Z/bmYBNMD8eJZL/cAcL6UJPFpKFV4WX7GYBOekBNxmVjd
         lUxLmAsZhxR1IMgOHvc+GcGJOewnUEexgR5NtLFatidJZ+09GnEwObGHlUtPHrspxY1G
         mNV4kyU+e5bs5ekBfpncoOUdqm29itLLAggd1cJMqn/1KzfDlh5AGcFTIIXWiPbwPO48
         r8mrjnscTP51OEXbno90F+I1Ix666XqrSqVqAxkNMCqbynfOUE11eITuRqSKtj0Wz4vd
         KAtA==
X-Gm-Message-State: AHQUAua0JmNmfxKz1SREXGbysc7m2qHUbi1PolHE6mrOImbpkpuNILOk
	yFPvdUG8UaIDmIsKv1i3gXF0+OaK8zFtNcBbL0VzRepMv9KIwbuHdFUKAU4djXXikypGeVwtlgq
	n6SB65+63O6MZabtvse683oRtXMJ4TTOa91sIVngpgbs9IFW5aSufinCAfM+rSawjIA==
X-Received: by 2002:a1c:f011:: with SMTP id a17mr3273863wmb.89.1551201769661;
        Tue, 26 Feb 2019 09:22:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaPOhlDSSyCovJ3xkUQdtxKMv9ppY0d6ixfm7tvRW300V1/gslmv/9RNkWbWhwsgu9lSdyu
X-Received: by 2002:a1c:f011:: with SMTP id a17mr3273813wmb.89.1551201768605;
        Tue, 26 Feb 2019 09:22:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201768; cv=none;
        d=google.com; s=arc-20160816;
        b=yYyyBF6Oxz4xAC+reDUoiugJlVBX+o6AvKS6RlKYIAO1Pn6FBg+xvdFYxRHapSofjY
         xrskBXHncR5+dnZZs+3AbsHWb0qi/j/euM8xvGOkuQZ19RMROrEdF665+FxxuBHNmbDi
         4oULccs449sUQGmWBO4WNJEURcGJH4T6c9VanJOZuHU3OudWWH9MrqX8Qhs0VPmPHFVC
         CT/E+LwY0EXOq3q048hflI1NjvHwHe/ZSIJJpJnABmMorR29e4fxBFtKobls6mnGtL28
         xBt/nMxOAZjQYxKrsXMdKvcWH+AjzA/igybo967jcPxWiocDx4TFCxrySZyjF9AivhNc
         qA+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
        b=T5BYZ0b3+LX4L3J8ro+UMO+OFV01+pFHcHQstDGPm3eowkqNJ5bwf4LjDG7DDaWjtK
         qwhIQ3inif07gMT8cMGYmbehJi1ZMVED6UexpiOl/XCe58Wh9msSi97zs9wP8mWaYuXr
         56l6K+zQmlrpgrsvUQq08BMhLIpdgl6qrSYy/rp6Mi/d6Fj2dRyQ0PuxriaIzs42SZ3c
         gYRO0bF+t2EtZS9c5on4TpBjemkW/S/6erAID5l91B9pnCFZtFVSZZShlnKkwfkDR0ye
         GnxZsoC25sDxFVwzlYQBFEJaDa/OxQ0iqETtwG3XlRTmeWQWkbgd6ni6l3zqnxidXouS
         9sGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=rNHXO1mN;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id v7si8815764wrw.312.2019.02.26.09.22.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:48 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=rNHXO1mN;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485HB2tbLz9vJLh;
	Tue, 26 Feb 2019 18:22:46 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=rNHXO1mN; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Lz3Mvh_-1mNd; Tue, 26 Feb 2019 18:22:46 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485HB1frfz9vJLY;
	Tue, 26 Feb 2019 18:22:46 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201766; bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=rNHXO1mNgSm6WOxlfqgdYv6AHdpqgKOl9JSU5H/US/o8ln8L7ilUrpGl8DuiGqCMd
	 kYcaKvMmjD7aPj7GYIeHsEeSztlQAxmJ0UVTJqwWtkWkGI68s6qbrKzWbw5b6vwzXr
	 AKd53PcunRUychYDbcFaQeoICHnZPIYkAgUhP8sc=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BE63D8B97C;
	Tue, 26 Feb 2019 18:22:47 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 2rviB2LY8cFU; Tue, 26 Feb 2019 18:22:47 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 7C6868B96A;
	Tue, 26 Feb 2019 18:22:47 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5949B6F7A6; Tue, 26 Feb 2019 17:22:47 +0000 (UTC)
Message-Id: <8193c76acf453687f4479afb4ecbbba37fca2da6.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 06/11] powerpc/32: make KVIRT_TOP dependent on FIXMAP_START
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we add KASAN shadow area, KVIRT_TOP can't be anymore fixed
at 0xfe000000.

This patch uses FIXADDR_START to define KVIRT_TOP.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/book3s/32/pgtable.h | 13 ++++++++++---
 arch/powerpc/include/asm/nohash/32/pgtable.h | 13 ++++++++++---
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index aa8406b8f7ba..838de59f6754 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -134,15 +134,24 @@ static inline bool pte_user(pte_t pte)
 #define PGDIR_MASK	(~(PGDIR_SIZE-1))
 
 #define USER_PTRS_PER_PGD	(TASK_SIZE / PGDIR_SIZE)
+
+#ifndef __ASSEMBLY__
+
+int map_kernel_page(unsigned long va, phys_addr_t pa, pgprot_t prot);
+
+#endif /* !__ASSEMBLY__ */
+
 /*
  * This is the bottom of the PKMAP area with HIGHMEM or an arbitrary
  * value (for now) on others, from where we can start layout kernel
  * virtual space that goes below PKMAP and FIXMAP
  */
+#include <asm/fixmap.h>
+
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
 #else
-#define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
+#define KVIRT_TOP	FIXADDR_START
 #endif
 
 /*
@@ -373,8 +382,6 @@ static inline void __ptep_set_access_flags(struct vm_area_struct *vma,
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 3 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 3 })
 
-int map_kernel_page(unsigned long va, phys_addr_t pa, pgprot_t prot);
-
 /* Generic accessors to PTE bits */
 static inline int pte_write(pte_t pte)		{ return !!(pte_val(pte) & _PAGE_RW);}
 static inline int pte_read(pte_t pte)		{ return 1; }
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index bed433358260..0284f8f5305f 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -64,15 +64,24 @@ extern int icache_44x_need_flush;
 #define pgd_ERROR(e) \
 	pr_err("%s:%d: bad pgd %08lx.\n", __FILE__, __LINE__, pgd_val(e))
 
+#ifndef __ASSEMBLY__
+
+int map_kernel_page(unsigned long va, phys_addr_t pa, pgprot_t prot);
+
+#endif /* !__ASSEMBLY__ */
+
+
 /*
  * This is the bottom of the PKMAP area with HIGHMEM or an arbitrary
  * value (for now) on others, from where we can start layout kernel
  * virtual space that goes below PKMAP and FIXMAP
  */
+#include <asm/fixmap.h>
+
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
 #else
-#define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
+#define KVIRT_TOP	FIXADDR_START
 #endif
 
 /*
@@ -379,8 +388,6 @@ static inline int pte_young(pte_t pte)
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 3 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 3 })
 
-int map_kernel_page(unsigned long va, phys_addr_t pa, pgprot_t prot);
-
 #endif /* !__ASSEMBLY__ */
 
 #endif /* __ASM_POWERPC_NOHASH_32_PGTABLE_H */
-- 
2.13.3

