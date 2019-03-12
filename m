Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C015C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BD5E213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="KOMrUZ4F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BD5E213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6153F8E0002; Tue, 12 Mar 2019 18:16:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 574838E0003; Tue, 12 Mar 2019 18:16:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EE128E0002; Tue, 12 Mar 2019 18:16:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C26688E0003
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:09 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s5so1587985wrp.17
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=OGZz0Q4R6Zdt3TK+8zOZmGmuwyLbFuizUxlVfu9yL9A=;
        b=n/ZaiOZaosz1iXIInfdpd5TCAEjSjjrNozVqHDfiQj6qpk+dlhkL0uriTULkzdXq5K
         fmXnuCQ1zbW0EhBFBVlK2YeF0XqkWA9F0XmQb+rqKRAMavJVN9gzkrs9rTkpume4rzVm
         W/p5KtZ2J9k0Z+EXm69vU98eNxfFBHp3hQAid+WP30wxFh+j/Z09iurhYx99J5eDCzJI
         XddJjEPQXYDqygVHg5v/ZpKAKvPjin4kuyTEpg/wrutisgIXqZdTLKHJj23zgK35jxOS
         eTewNrIfTSxKKjnwZJc/C0WadbvWeDTvR2KH9V5OFCMpc4axj7o4v/Vd8GzlVlwKFJ8N
         maBg==
X-Gm-Message-State: APjAAAUtV5D4MVhTBf4DucuL++764PnW1/Gzxuw4DzRLXxhbHMq/QkIM
	JFa+nPzGQ9wcJVgQLNdYjuP949rqpk5hSECJSwgjO9Rp3dDI9v6rOG+HkVw50CR/E/cxilB/0Zx
	0A1DEPgDX2J9Rr9gN0aRKNU9f9QYOHufC8dE8Cvvb8n45VbbIT1IYKJy+XH8yuZWDVw==
X-Received: by 2002:a5d:624a:: with SMTP id m10mr7226537wrv.18.1552428968991;
        Tue, 12 Mar 2019 15:16:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ69pNgpfFFwmoPwCqp0ILfA2u/KayufJlU+k3eguYsPAve81vV6ZSikCE7Ddw7l0RIayI
X-Received: by 2002:a5d:624a:: with SMTP id m10mr7226497wrv.18.1552428967729;
        Tue, 12 Mar 2019 15:16:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428967; cv=none;
        d=google.com; s=arc-20160816;
        b=aKHb67lMxCRhGC4cDoDh/y2s+cIK+9eKX3XZ8LISJNv+D5mR5CHSsd2Nzw2nkbuPXt
         o4xz3b8go1+O3Q2L19jvEUGZRWfB/lTmozoki+/D9fmCwS1m/S0DQE8IZca64+hV8e9e
         JThcRgpbri0MZn8T1zBy8TsHtq2W1GfMXOs+xiE1SDCiy8xOkbA79mRkhtkVY1OWoU1R
         fKKGW8DVOPhRpTKjW7xBQ5QENS1O2TMfSaVlnnqrFpPly6QJVUnMb9ao9IfSc+pr22aK
         7XpcoRuj+2LIusKzP6eAIX8EjdnYV+uT9RYvzCOKpDw1Etf9b6yAxU5S52zWCWhSap3/
         Bn/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=OGZz0Q4R6Zdt3TK+8zOZmGmuwyLbFuizUxlVfu9yL9A=;
        b=AWDkYP4hQ24nC+uuT5SVfREAhCXHHDiVG616kzvgn8FVihTXD7hSxYwym3JU043lPq
         Dqiu4VK0c2vPB+dXSLkJA+Xglry0+rOU0Ap3/pv3TGcn9GrhXMicjcRWjY1YUURsD5kr
         SBM3QqPz3Wt1RIDGv8S2JHiGzoYT1w0H3i7ggSYR6AR4H5ZMM7LlLKmOOBZA+glT4f3q
         ylnmArP3678sFIfMZTU2tuEDhx4mml4JSBITeZ3Vre549TJUITFwf8+bY615SoV5rbs0
         n0PKNGCYm5Vdb0EoNr1yiIjO68ji6JlytfhqE5GHlDMhDAA3kGfIM21RqPQ2GCQyObye
         h7/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=KOMrUZ4F;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 80si11947wma.155.2019.03.12.15.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=KOMrUZ4F;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7C05ytz9vRb3;
	Tue, 12 Mar 2019 23:16:07 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=KOMrUZ4F; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id elEkdr7Q7Ccb; Tue, 12 Mar 2019 23:16:06 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7B666bz9vRb0;
	Tue, 12 Mar 2019 23:16:06 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428966; bh=OGZz0Q4R6Zdt3TK+8zOZmGmuwyLbFuizUxlVfu9yL9A=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=KOMrUZ4FKyn9Qx1LCGBi8JhdyFrSKh1AC5NYVUt4kLLKAUUMshB3pcEdeJe/MY8Ar
	 x6dG2+UiC7TocRsy2IisyT4g135rUL8xdYwIiXsIJFWi4PX7IQjNBohPT0deK3LkXw
	 gl4IRuc04fxu6pHHL1SfvxrWbTTKcopk05zMCiEY=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 119218B8B1;
	Tue, 12 Mar 2019 23:16:07 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id EYmmjq3CtNLR; Tue, 12 Mar 2019 23:16:06 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CD0438B8A7;
	Tue, 12 Mar 2019 23:16:06 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id A162C6FA15; Tue, 12 Mar 2019 22:16:06 +0000 (UTC)
Message-Id: <5047ab5aaf0fd90887fa1e5f0369182d71dcf0f6.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 01/18] powerpc/6xx: fix setup and use of SPRN_SPRG_PGDIR
 for hash32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Not only the 603 but all 6xx need SPRN_SPRG_PGDIR to be initialised at
startup. This patch move it from __setup_cpu_603() to start_here()
and __secondary_start(), close to the initialisation of SPRN_THREAD.

Previously, virt addr of PGDIR was retrieved from thread struct.
Now that it is the phys addr which is stored in SPRN_SPRG_PGDIR,
hash_page() shall not convert it to phys anymore.
This patch removes the conversion.

Fixes: 93c4a162b014("powerpc/6xx: Store PGDIR physical address in a SPRG")
Reported-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/cpu_setup_6xx.S | 3 ---
 arch/powerpc/kernel/head_32.S       | 6 ++++++
 arch/powerpc/mm/hash_low_32.S       | 8 ++++----
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/kernel/cpu_setup_6xx.S b/arch/powerpc/kernel/cpu_setup_6xx.S
index 6f1c11e0691f..7534ecff5e92 100644
--- a/arch/powerpc/kernel/cpu_setup_6xx.S
+++ b/arch/powerpc/kernel/cpu_setup_6xx.S
@@ -24,9 +24,6 @@ BEGIN_MMU_FTR_SECTION
 	li	r10,0
 	mtspr	SPRN_SPRG_603_LRU,r10		/* init SW LRU tracking */
 END_MMU_FTR_SECTION_IFSET(MMU_FTR_NEED_DTLB_SW_LRU)
-	lis	r10, (swapper_pg_dir - PAGE_OFFSET)@h
-	ori	r10, r10, (swapper_pg_dir - PAGE_OFFSET)@l
-	mtspr	SPRN_SPRG_PGDIR, r10
 
 BEGIN_FTR_SECTION
 	bl	__init_fpu_registers
diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index ce6a972f2584..48051c8977c5 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -855,6 +855,9 @@ __secondary_start:
 	li	r3,0
 	stw	r3, RTAS_SP(r4)		/* 0 => not in RTAS */
 #endif
+	lis	r4, (swapper_pg_dir - PAGE_OFFSET)@h
+	ori	r4, r4, (swapper_pg_dir - PAGE_OFFSET)@l
+	mtspr	SPRN_SPRG_PGDIR, r4
 
 	/* enable MMU and jump to start_secondary */
 	li	r4,MSR_KERNEL
@@ -942,6 +945,9 @@ start_here:
 	li	r3,0
 	stw	r3, RTAS_SP(r4)		/* 0 => not in RTAS */
 #endif
+	lis	r4, (swapper_pg_dir - PAGE_OFFSET)@h
+	ori	r4, r4, (swapper_pg_dir - PAGE_OFFSET)@l
+	mtspr	SPRN_SPRG_PGDIR, r4
 
 	/* stack */
 	lis	r1,init_thread_union@ha
diff --git a/arch/powerpc/mm/hash_low_32.S b/arch/powerpc/mm/hash_low_32.S
index 1f13494efb2b..a6c491f18a04 100644
--- a/arch/powerpc/mm/hash_low_32.S
+++ b/arch/powerpc/mm/hash_low_32.S
@@ -70,12 +70,12 @@ _GLOBAL(hash_page)
 	lis	r0,KERNELBASE@h		/* check if kernel address */
 	cmplw	0,r4,r0
 	ori	r3,r3,_PAGE_USER|_PAGE_PRESENT /* test low addresses as user */
-	mfspr	r5, SPRN_SPRG_PGDIR	/* virt page-table root */
+	mfspr	r5, SPRN_SPRG_PGDIR	/* phys page-table root */
 	blt+	112f			/* assume user more likely */
-	lis	r5,swapper_pg_dir@ha	/* if kernel address, use */
-	addi	r5,r5,swapper_pg_dir@l	/* kernel page table */
+	lis	r5, (swapper_pg_dir - PAGE_OFFSET)@ha	/* if kernel address, use */
+	addi	r5 ,r5 ,(swapper_pg_dir - PAGE_OFFSET)@l	/* kernel page table */
 	rlwimi	r3,r9,32-12,29,29	/* MSR_PR -> _PAGE_USER */
-112:	tophys(r5, r5)
+112:
 #ifndef CONFIG_PTE_64BIT
 	rlwimi	r5,r4,12,20,29		/* insert top 10 bits of address */
 	lwz	r8,0(r5)		/* get pmd entry */
-- 
2.13.3

