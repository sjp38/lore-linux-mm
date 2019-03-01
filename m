Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12EF4C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:33:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5D1B206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="V9yDVuOO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5D1B206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 181038E0009; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16FCA8E000A; Fri,  1 Mar 2019 07:33:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3DFC8E0009; Fri,  1 Mar 2019 07:33:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFC78E0006
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:47 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id h65so11389949wrh.16
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
        b=sbc494muFcgOXRAn/tiD+ArxWIGugVoiIpsqLf86I7S2XNVS+HMaWjFEIEDS1jTU8W
         kIxkMdj2O3eLd7Gw2S06PCNJk4MCe9q1DS9mP91v8Gl2z8WTu/ZXZn3Ty3U+dJJUFOLS
         bBBnlp8enJ7O9KqtHC+FAW/DAfZr+aXiKOoivJZGHOwR+XOen1Ywxfu5KvHVCqrWKE0G
         mu0sXNTu7nITR57S9k+W6bzuleCdjpOK30UtYC9WvgZKJdi0Ez9xP/hl7ZHJZzFziCjF
         3Xtb+UEEqtSnx8MdKLPdfCZX4kevZ893wYFDrLrVt8fqGZrlIVRU8fFYILxhNdwcjFZr
         c54g==
X-Gm-Message-State: AHQUAuY5yw/7nG9ZIK1lzUGJE2Ra1+KpLhvw7pmpEPJnkuZYPgxr3w7f
	uKK4HRQajIl5UmiiDLt/PNU7YqjmYxJ778Hm0icM+LlCCoyZ87ewqzMYN/O+vewmws7Vs0N4UMO
	8uwXtBmUDJW/yTPSmH2dLS2DcHkCnVS1GISSYfCIEYxDYERofR87TMdi5FTjNvjpU/A==
X-Received: by 2002:a1c:2545:: with SMTP id l66mr2837419wml.96.1551443626979;
        Fri, 01 Mar 2019 04:33:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVZ4Av7JGGraat45U9vjXLulluh7DcX8SZ9Htt5OaHuFCQBx01drat5JOT8YqU72UhHPnX
X-Received: by 2002:a1c:2545:: with SMTP id l66mr2837359wml.96.1551443625466;
        Fri, 01 Mar 2019 04:33:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443625; cv=none;
        d=google.com; s=arc-20160816;
        b=sEbrk5BttY7WknTOnGXfcphS1NLtPGfmhzbovzUliWKJEkGdLlM5B9Ci78yP0VN1kk
         CBdYFaSbsO+GYJCx3UlA9xpsVl6TwvWa/bx7Cu9Ae144HVZ6QVjPDVuDVoALJvVMTi64
         phKpYfjV1tm+47DBVu4yK5nHo74XWwbZBbHyWK5XYXkBLjd3vZmsHKg13D+0Wp/MYd1+
         0VggRsnUWsUGoGTHQ9slCpydNwydNhA+GDq9Ng5Rjzq6tN6kzHzcAUsy7m3f436ubioj
         9PPk8sdkXZVD0BHonbW5nRzUFFMx7vdX18pHiSE4FSyF0LafguxtuMTpok5yqsOJT0EQ
         uomA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
        b=R5SgodJziJaA9Ykg6KGOfpyglusduTq6KWLpZ9AuvyXnHxjv9nhcZlNI+rZzk3a/ZS
         QfX/P53+hxVtw5UuyZmVeg2rkQjUyjIUreuVQ0sDVv886BSp5sNplHJoCJzRFM3Xw3/0
         nd/AEpdRksozdyGHrgJboua+RQOVUNhneb00eBtG5B/vA/PTDbk1uNDTfvSzzLGPdoOS
         OWDQcIANv6h/IVOGn63Vuk6tsNDBGiy73vU/GsUn2K02+uW9aW5VR+HxPF2Zf0HRkFBS
         5p6A856VmJ8k0sFwT+ZaeH6TqvQ0MYKFCl6uF+bkB8CaEop8Veew5oIaTjl+MDr62HbB
         OHyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=V9yDVuOO;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id v19si4441403wmc.192.2019.03.01.04.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:45 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=V9yDVuOO;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkH3z20z9txrq;
	Fri,  1 Mar 2019 13:33:43 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=V9yDVuOO; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id WaLy-Q3yGWd7; Fri,  1 Mar 2019 13:33:43 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkH2jbQz9txrh;
	Fri,  1 Mar 2019 13:33:43 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443623; bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=V9yDVuOO6s54csiG0Uu7iG7sHKI/cZ4MueHDZGOsWn0I4WWu6SeeOMophs+O9WhhY
	 SHjpVDKAcZ3g0ylB68KZJVCUcR7NzG92OPLhXApMwesa42L0S4+wCTOs2rm8owTVS2
	 N7Ok+BurOBBqPEXVJBhkrwQV99oHPfx5+VAB/lus=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A50F28BB8B;
	Fri,  1 Mar 2019 13:33:44 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id fMya_PpDFcO4; Fri,  1 Mar 2019 13:33:44 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 64D0A8BB73;
	Fri,  1 Mar 2019 13:33:44 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 434CA6F89E; Fri,  1 Mar 2019 12:33:44 +0000 (UTC)
Message-Id: <6b79065e99220dc1f01dc37d0112a329902e5905.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 06/11] powerpc/32: make KVIRT_TOP dependent on FIXMAP_START
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:44 +0000 (UTC)
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

