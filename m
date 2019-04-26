Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37383C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:24:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD7DC206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:24:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="OLgh7x0M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD7DC206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F72F6B026B; Fri, 26 Apr 2019 12:23:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A7DD6B026C; Fri, 26 Apr 2019 12:23:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 123F06B026D; Fri, 26 Apr 2019 12:23:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B85596B026B
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:39 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id x1so3852390wrd.15
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=bsJkMjdLq6ewn4TB3Y8GTdcDq1dyDSMregq4xjGo1IU=;
        b=T5tY8HwG9MNeIY7lF3jPD7FZ/kgCqkGNXHljMgwKHgngm4fVsXx3jv6Y9qP7Jb1XQQ
         WNynFLN0syOAu73FLvrQUzsbWnQLR7FpKt01ZqwoqPUBZ870S62yE2xskHgy9JWClKsk
         oeusrg5Q2H34aUaXgB6tvBLK8toE7C2s/pVf8PUl24Lpe3UKjmyxgWszHnwFcPesFyaa
         Ml4wk2MvuYmlSo7cKU0vIUt2QKOb2MVdKMJ99BSA2mCYi6xypEIEhWT/gEIVEEuWjFf7
         z6HCUqP3u3XpUz3e0Hjn650TXXhVY74v3alzJHepqlkmpVS/y2qo8XYNj+4HiGWbutE0
         gO9A==
X-Gm-Message-State: APjAAAXh+jcVBb3aaI6IZJmPj5MJEPIxscPYGxOLDLaqDlI2R/3zgGfF
	cjECMwzQWtN4sxV3YVPwLDGWDmicnCJd5O4xzhosaqcIeTGItL2+dyorl0QwIKPcCYYqSg17tFG
	bGReLIltumfo9YDdqB7Vkl30irjhdH89ElSrYGRLCNJExgEiYg7wnC6b5+8ABTgiTXw==
X-Received: by 2002:a5d:6441:: with SMTP id d1mr9243854wrw.149.1556295819275;
        Fri, 26 Apr 2019 09:23:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyN93qpZYs3NEQIUp/SxnvaLD30UJHpeZC4JeSqWexcyIz2Jg38aSITrC5i7d1Iexj2x9ZI
X-Received: by 2002:a5d:6441:: with SMTP id d1mr9243697wrw.149.1556295817405;
        Fri, 26 Apr 2019 09:23:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295817; cv=none;
        d=google.com; s=arc-20160816;
        b=ji8LmtPE6o/g1MWMHRpa3kxnvOfTX9qYM/pAeoxqEdPvkLEd/sWs8Zh/z7VtNXPxbP
         w72u6himUJA3nUwx8pQe4Qn8E14F7oAUPUQze2u8HJmk2x/LWjGTXdWs1nzwuS64WN5d
         /3jNgv0WSEvM+COxKQBRG6M1vs8NMHe8Txjv7MAIaHq99+4i1YXi5OCs6PDqpPOG6alu
         txKBGJ+Q2YTtJpfRcDKWYqRIGaRO+0hf7KvhXQpyyuqogMGaLJckC8jvMEpepI88YP+o
         a1ONFfP4dSsIUG+X8DdnO87iUiGFNYWI0sRWXytr1VmPWgxQdP2JyMdvvVv7p3E6ZuDM
         gLvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=bsJkMjdLq6ewn4TB3Y8GTdcDq1dyDSMregq4xjGo1IU=;
        b=cAnagUfVQiZ9Eb7296NwC5ebFE5oC11prxMCaJF9owmbJGVlqZyHWaZzZ5inY9Vc6D
         VOtjb1S+L3CgS0J8P9DfQ07r5Ky6jUtEhGc84qfSzxKscSJVH3Ig/U313BWGRq2Eigcr
         lyml9Siq/+rBqQyVaTKNECESn5u/FWBJFr2j7EX/XsRtcH8N+V4BUXUEJhL64610Hlhe
         cNFtZWGIHU7Rq659yvvoustEWqNuak50DtkFWuNuvIrK9CCkrw+FuvAJmV9IqC3v8nz8
         SmFAXlC60KHX8xW3Dj9RDDDObtXpP6rFPEaYqgSPkVRHPyEYcgTRmpZfT3/nwcDUilBN
         ZmLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=OLgh7x0M;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id a187si20629715wmf.0.2019.04.26.09.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=OLgh7x0M;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9g2YbPz9v2H6;
	Fri, 26 Apr 2019 18:23:35 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=OLgh7x0M; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id xR0niIOPlR0b; Fri, 26 Apr 2019 18:23:35 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9g1VqDz9v1kv;
	Fri, 26 Apr 2019 18:23:35 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295815; bh=bsJkMjdLq6ewn4TB3Y8GTdcDq1dyDSMregq4xjGo1IU=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=OLgh7x0ModFLi989OrPQCQmIx6j7GaFZpBPFWCpLzyLqU9ROTXNTzCj8q4cfYfA3A
	 YVW2r5v2g5C+9hKHtNQsCDVmZQ5BI8rnB3sURT4ZmXCxqDvgh1i215Lv6VzcHfFA/Y
	 iEIwcpYCQ5UaVUVPzgQl5vZ8WwpqK/XnyLtqeqI4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D780C8B950;
	Fri, 26 Apr 2019 18:23:36 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id G3CIG6GdX10p; Fri, 26 Apr 2019 18:23:36 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id ADF218B82F;
	Fri, 26 Apr 2019 18:23:36 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 94EAE666FE; Fri, 26 Apr 2019 16:23:36 +0000 (UTC)
Message-Id: <6083ee9536cc5e27a9fda6e161dc395b145c188b.1556295461.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 12/13] powerpc/32s: set up an early static hash table for
 KASAN.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

KASAN requires early activation of hash table, before memblock()
functions are available.

This patch implements an early hash_table statically defined in
__initdata.

During early boot, a single page table is used.

For hash32, when doing the final init, one page table is allocated
for each PGD entry because of the _PAGE_HASHPTE flag which can't be
common to several virt pages. This is done after memblock get
available but before switching to the final hash table, otherwise
there are issues with TLB flushing due to the shared entries.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_32.S         | 70 ++++++++++++++++++++++-------------
 arch/powerpc/mm/kasan/kasan_init_32.c | 23 +++++++++++-
 arch/powerpc/mm/mmu_decl.h            |  1 +
 3 files changed, 68 insertions(+), 26 deletions(-)

diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index 5958ea685968..73288df1c5d6 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -160,6 +160,10 @@ __after_mmu_off:
 	bl	flush_tlbs
 
 	bl	initial_bats
+	bl	load_segment_registers
+#ifdef CONFIG_KASAN
+	bl	early_hash_table
+#endif
 #if defined(CONFIG_BOOTX_TEXT)
 	bl	setup_disp_bat
 #endif
@@ -205,7 +209,7 @@ __after_mmu_off:
  */
 turn_on_mmu:
 	mfmsr	r0
-	ori	r0,r0,MSR_DR|MSR_IR
+	ori	r0,r0,MSR_DR|MSR_IR|MSR_RI
 	mtspr	SPRN_SRR1,r0
 	lis	r0,start_here@h
 	ori	r0,r0,start_here@l
@@ -884,11 +888,24 @@ _ENTRY(__restore_cpu_setup)
 	blr
 #endif /* !defined(CONFIG_PPC_BOOK3S_32) */
 
-
 /*
  * Load stuff into the MMU.  Intended to be called with
  * IR=0 and DR=0.
  */
+#ifdef CONFIG_KASAN
+early_hash_table:
+	sync			/* Force all PTE updates to finish */
+	isync
+	tlbia			/* Clear all TLB entries */
+	sync			/* wait for tlbia/tlbie to finish */
+	TLBSYNC			/* ... on all CPUs */
+	/* Load the SDR1 register (hash table base & size) */
+	lis	r6, early_hash - PAGE_OFFSET@h
+	ori	r6, r6, 3	/* 256kB table */
+	mtspr	SPRN_SDR1, r6
+	blr
+#endif
+
 load_up_mmu:
 	sync			/* Force all PTE updates to finish */
 	isync
@@ -900,29 +917,6 @@ load_up_mmu:
 	tophys(r6,r6)
 	lwz	r6,_SDR1@l(r6)
 	mtspr	SPRN_SDR1,r6
-	li	r0, NUM_USER_SEGMENTS /* load up user segment register values */
-	mtctr	r0		/* for context 0 */
-	li	r3, 0		/* Kp = 0, Ks = 0, VSID = 0 */
-#ifdef CONFIG_PPC_KUEP
-	oris	r3, r3, SR_NX@h	/* Set Nx */
-#endif
-#ifdef CONFIG_PPC_KUAP
-	oris	r3, r3, SR_KS@h	/* Set Ks */
-#endif
-	li	r4,0
-3:	mtsrin	r3,r4
-	addi	r3,r3,0x111	/* increment VSID */
-	addis	r4,r4,0x1000	/* address of next segment */
-	bdnz	3b
-	li	r0, 16 - NUM_USER_SEGMENTS /* load up kernel segment registers */
-	mtctr	r0			/* for context 0 */
-	rlwinm	r3, r3, 0, ~SR_NX	/* Nx = 0 */
-	rlwinm	r3, r3, 0, ~SR_KS	/* Ks = 0 */
-	oris	r3, r3, SR_KP@h		/* Kp = 1 */
-3:	mtsrin	r3, r4
-	addi	r3, r3, 0x111	/* increment VSID */
-	addis	r4, r4, 0x1000	/* address of next segment */
-	bdnz	3b
 
 /* Load the BAT registers with the values set up by MMU_init.
    MMU_init takes care of whether we're on a 601 or not. */
@@ -944,6 +938,32 @@ BEGIN_MMU_FTR_SECTION
 END_MMU_FTR_SECTION_IFSET(MMU_FTR_USE_HIGH_BATS)
 	blr
 
+load_segment_registers:
+	li	r0, NUM_USER_SEGMENTS /* load up user segment register values */
+	mtctr	r0		/* for context 0 */
+	li	r3, 0		/* Kp = 0, Ks = 0, VSID = 0 */
+#ifdef CONFIG_PPC_KUEP
+	oris	r3, r3, SR_NX@h	/* Set Nx */
+#endif
+#ifdef CONFIG_PPC_KUAP
+	oris	r3, r3, SR_KS@h	/* Set Ks */
+#endif
+	li	r4, 0
+3:	mtsrin	r3, r4
+	addi	r3, r3, 0x111	/* increment VSID */
+	addis	r4, r4, 0x1000	/* address of next segment */
+	bdnz	3b
+	li	r0, 16 - NUM_USER_SEGMENTS /* load up kernel segment registers */
+	mtctr	r0			/* for context 0 */
+	rlwinm	r3, r3, 0, ~SR_NX	/* Nx = 0 */
+	rlwinm	r3, r3, 0, ~SR_KS	/* Ks = 0 */
+	oris	r3, r3, SR_KP@h		/* Kp = 1 */
+3:	mtsrin	r3, r4
+	addi	r3, r3, 0x111	/* increment VSID */
+	addis	r4, r4, 0x1000	/* address of next segment */
+	bdnz	3b
+	blr
+
 /*
  * This is where the main kernel code starts.
  */
diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
index 42617fcad828..ba8361487075 100644
--- a/arch/powerpc/mm/kasan/kasan_init_32.c
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -94,6 +94,13 @@ void __init kasan_mmu_init(void)
 	int ret;
 	struct memblock_region *reg;
 
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE)) {
+		ret = kasan_init_shadow_page_tables(KASAN_SHADOW_START, KASAN_SHADOW_END);
+
+		if (ret)
+			panic("kasan: kasan_init_shadow_page_tables() failed");
+	}
+
 	for_each_memblock(memory, reg) {
 		phys_addr_t base = reg->base;
 		phys_addr_t top = min(base + reg->size, total_lowmem);
@@ -135,6 +142,20 @@ void *module_alloc(unsigned long size)
 }
 #endif
 
+#ifdef CONFIG_PPC_BOOK3S_32
+u8 __initdata early_hash[256 << 10] __aligned(256 << 10) = {0};
+
+static void __init kasan_early_hash_table(void)
+{
+	modify_instruction_site(&patch__hash_page_A0, 0xffff, __pa(early_hash) >> 16);
+	modify_instruction_site(&patch__flush_hash_A0, 0xffff, __pa(early_hash) >> 16);
+
+	Hash = (struct hash_pte *)early_hash;
+}
+#else
+static void __init kasan_early_hash_table(void) {}
+#endif
+
 void __init kasan_early_init(void)
 {
 	unsigned long addr = KASAN_SHADOW_START;
@@ -152,5 +173,5 @@ void __init kasan_early_init(void)
 	} while (pmd++, addr = next, addr != end);
 
 	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
-		WARN(true, "KASAN not supported on hash 6xx");
+		kasan_early_hash_table();
 }
diff --git a/arch/powerpc/mm/mmu_decl.h b/arch/powerpc/mm/mmu_decl.h
index d726ff776054..31fce3914ddc 100644
--- a/arch/powerpc/mm/mmu_decl.h
+++ b/arch/powerpc/mm/mmu_decl.h
@@ -106,6 +106,7 @@ extern unsigned int rtas_data, rtas_size;
 struct hash_pte;
 extern struct hash_pte *Hash, *Hash_end;
 extern unsigned long Hash_size, Hash_mask;
+extern u8 early_hash[];
 
 #endif /* CONFIG_PPC32 */
 
-- 
2.13.3

