Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51E94C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 019E9206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="fS4TAjwz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 019E9206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34B3B6B000E; Fri, 26 Apr 2019 12:23:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D1186B0010; Fri, 26 Apr 2019 12:23:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D9916B0266; Fri, 26 Apr 2019 12:23:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1C896B000E
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:33 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id o16so3859908wrp.8
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
        b=axqlchajej1yDbWMWuZpu+LHR9G6VuOCkL0CD1Yh1EdhTYQUcnod5wxs01TbroFI0o
         xOE5P6VHKUQzMvZuPmqCCXI9jf+CbSj3RZkbonRztEov8bxj0qpedwv+cYZ6QH6UMu8e
         W+ivNQ9wmUwJBL4wiI/AAitCO5lxh14j2S90fHj5S0O5ibGTPClcUMp1VrmqbQQG6ZDh
         OfQv1JvgPwO+05K0v2ySNLKex6YPvmF7Ryw9dXdn8ZEd9Ho2XxAblH/+aHcvNh1ZkbaI
         xVencMoTf69lOponHBk128pmuzk/t7/b70oZNA/UzcvZhrhLSO7qBoGBxHMQTM5RcwTr
         gPDQ==
X-Gm-Message-State: APjAAAWqeDoFs5fKOWVKsSI4tYm9ufLvO4nyMS+CH3T8MMsQ7O0UH+rx
	D2lK7vaiL7ouM2C+Y/6yNKJV94sVtkMvwIbQlsRYRU9GNCx61tLSGa5131gN+BrNtolgyztHrvU
	aFd0M3ZUrpUNnGOfHUXIC6t7eNtp1r5sX0VD9ppERHMCp09DqDA7OKua1jEtu511/ZQ==
X-Received: by 2002:a7b:c40c:: with SMTP id k12mr8160179wmi.2.1556295813183;
        Fri, 26 Apr 2019 09:23:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2YYDQyAmMCYDU/0SX8XiuySh59HX9eQyLhOhfn791CYwewXBoNPRwAhdDJPW5Fsh18WfW
X-Received: by 2002:a7b:c40c:: with SMTP id k12mr8160120wmi.2.1556295812221;
        Fri, 26 Apr 2019 09:23:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295812; cv=none;
        d=google.com; s=arc-20160816;
        b=K9MlP8M1DR4KrogLzkIpFA5V05UeLfPVsx8N5waYACy37hV/DGciGtJHqk0Be+HHw8
         5F+JhGfJeZ//l+wu2VbJhYinR8xdTOGfog23lmbbFnd65ceyEo5FcCAfYlgrHjU81zWi
         GbAL0aIGJnpUYjsa94lPSi9fl1VHHtF/eD2JWQZyYhFUQmRKpxeghfqBuLFB9Prg3KwW
         H4lMoaiVNllKDdM4fvweXA1eKQ/JuvhtGo2C2/kAIJCX/zdiBLJ8MgjN+sbWm115fXHZ
         T3DlEealIYU5/v6yhbVhJRg/+Rk0eUyv69Y58FSwXah2A9O3+sfI9YVxiXuOa/LdRVNk
         u+CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
        b=epfHgAYkNXK9+p8DvEpWV5zgeSkRg5YOzbt4+Op1YPrRdDrd3HCcrjct33Do06QeyX
         G5oaPstuTnGu3rOIhAjjHRIitSPSFQoKSBqJn6t5xS9Nhjyl7RxUbd3CouE8tf3szQnY
         S0pwkxV+f9zSYr/NGDGFuh9usHRuU+getBQsjs5mP9ysFW6CpI1Akjw2N2Ywx56B1739
         ZQOFyLVliT0PotZyIXmVxiPzZoOcfZX0Uk1ZTpUxEdVJ7lHcgxB/A+HDmJ/gIhThzUAz
         EI5GQ4XxfBWZWDucMAsN/tSEJysrmlIq3dLommUiJItOyAqlhXdffFLmWHc0WMw5UvaI
         XaaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=fS4TAjwz;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id j67si17490996wmb.92.2019.04.26.09.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=fS4TAjwz;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9Z1Ks0z9v17w;
	Fri, 26 Apr 2019 18:23:30 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=fS4TAjwz; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id gwA0PTIrOIMs; Fri, 26 Apr 2019 18:23:30 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9Z02rbz9v17t;
	Fri, 26 Apr 2019 18:23:30 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295810; bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=fS4TAjwzTicw/PUlQxOzcTBcJWoAgSLee/JkoM02O9SX9kqJf+NtFvrjUoySYCaBw
	 9ZIKcPUED7JwQC0VKuTlyclCGMOASmCWAMHF0j+Nra2R6/xoeKWfu7y98NcSybCLjn
	 N6vG6KypL9alARPP0Kg3feEZLF3+Od69rVeXv1NI=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A667C8B950;
	Fri, 26 Apr 2019 18:23:31 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Hp1PCONqW6O8; Fri, 26 Apr 2019 18:23:31 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 78E758B82F;
	Fri, 26 Apr 2019 18:23:31 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 68403666FE; Fri, 26 Apr 2019 16:23:31 +0000 (UTC)
Message-Id: <1e92f048b27d26473b822ef6663d4a0eb004f5c3.1556295460.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 07/13] powerpc/32: make KVIRT_TOP dependent on
 FIXMAP_START
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:31 +0000 (UTC)
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

