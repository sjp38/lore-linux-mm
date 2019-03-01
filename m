Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CEC3C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B55B206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="jQUGSbxf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B55B206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B1FF8E000E; Fri,  1 Mar 2019 07:33:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 536D38E0006; Fri,  1 Mar 2019 07:33:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D8A58E000E; Fri,  1 Mar 2019 07:33:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D58F88E0006
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:52 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id m2so8694658wrs.23
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=SbRyFF+pV64b+XRgQ6Ve2az6+06FWhJBNHkEXCWvzd0=;
        b=hsi7snnH770v+mQS5YiE4XhVGdxiFhSQZlxg96XA2+3s49VRDVIhrsFbAEMihP5xD7
         KQ33EqXdB7L384lRsRdoJDZTWxHMR0T4OFGt6KxkimV0mzwWBbBZg2Xt/nW1EEGFksfH
         +9z5DXT0l8uMoOtyL8lWjl94RRh7096UlP4PNBOWomqHLtLbgrMek/SeIRreqdN8JSn6
         OyqZrFQUK/02H12vY30e+XWgvwqYQLO+6+c4OX6qr0PDaA9j64VJ12hwAIYRJBynmUhy
         /yE6xfNlZmzv+0qcPiLN93V+UjeQGAEx9fuvEyh3rJLTQCW+R7r5PTbCAWP02rfocriV
         dFjA==
X-Gm-Message-State: APjAAAUbmsJuZ3a0TVQqotv0btFrjwgJGWTqvZ5jhk6LaBWqZBkIscng
	AR0/DOyLjIsy7HioIOO+BrEqzmRUzEnKjJefMct1iJH+Z85l8TLJll/aJ0TjfpaNrhUlcSM/8rN
	vwXRQQKB4byOBjS+ra6YfBF1AGGxJQHgDIFsem9SbjzVV0s0mTxBE85IaJI2snm34qg==
X-Received: by 2002:a1c:ce46:: with SMTP id e67mr3178259wmg.40.1551443632351;
        Fri, 01 Mar 2019 04:33:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbbwWLwnVr3MK72/w4PUYxLwUXVSCi53Hw1Y0rWa/Ili5vmxlhE0RtF1G7UqcR6C1gMmvIV
X-Received: by 2002:a1c:ce46:: with SMTP id e67mr3178184wmg.40.1551443630580;
        Fri, 01 Mar 2019 04:33:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443630; cv=none;
        d=google.com; s=arc-20160816;
        b=tp+wDFUNPmiMB7vMfFDW5b+R7lp4dvAMa/5El2HNPmqRQJiuASAgUhGXfC6upNJQv7
         tDiPxajOtRDLVnJEkRDj30yg8S97AyuJh1ABlMAa5irar5YLy/2wg1tYHaldigLaiMgF
         JsKdvlQLzONqSt7l3pLmoV53dE/lvEzHM9iyrzBgJesx759bONpH7AgM2G5IgD9N8COW
         Oi9/3g4R9PtFRzBbhzxUAPmdetcS2DdZPmaOU8C50fPGTlKV7Y7VicR0LWR4B8frgypD
         53ZFBQl179E8tiJUTunaztTIFpkgPH3Jui2kRdpRqXZ57y0ubE0BcFNbW4m9SrxgkpEW
         uDjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=SbRyFF+pV64b+XRgQ6Ve2az6+06FWhJBNHkEXCWvzd0=;
        b=Wk7Z9ZpVKA1pthW8Id1VsxIKOnUQecUZ9NyjesQvUOX1O5x4x8zLojgyghk9rNvxuU
         dzEjJynOTqCG1xQyPGxK7eEFBb44knEHyvf86wlko0jSlglaumwxrIrnQHpw8bulhOBZ
         4Vs6Hn5yNze9BQ4SbOXki+z5k+1dLz6kj9ugFtbC6B8pcD3fFxM7HJ5PjQL2k5e+CNWg
         SXuT2ZX1+yWGAlDpen6i1s0snycBNq4la+ProL//j21kiZEb7RxHJEBI692nHJeQw992
         79iOro9VAUOycUTNlxLMuZ1lMxek9+jFtOqNdB/IaNInD+LRyUkl9bsdUnby4ECKeu4+
         P4jA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=jQUGSbxf;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id s13si5303221wrp.282.2019.03.01.04.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:50 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=jQUGSbxf;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkN5gT5z9txry;
	Fri,  1 Mar 2019 13:33:48 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=jQUGSbxf; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id KzUCUZQO2WVe; Fri,  1 Mar 2019 13:33:48 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkN4KsQz9txrw;
	Fri,  1 Mar 2019 13:33:48 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443628; bh=SbRyFF+pV64b+XRgQ6Ve2az6+06FWhJBNHkEXCWvzd0=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=jQUGSbxf0n0BHfFduSfo3NlG+yVSjD8Emfm3IACUY5XPk61g6vu82FjB+kRroKVl8
	 BawcNfSoPUbiQty52jKX3SfxYLUeL3Lk6/dAdYvZ85sUJJjaaDtWVJS9AHzhPxRi4T
	 5OVgaVJ5/lWknEbvruc7F7tvzJ55Wz3YjDyQAh6c=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D43E68BB8B;
	Fri,  1 Mar 2019 13:33:49 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id riH7IzGJt6Ky; Fri,  1 Mar 2019 13:33:49 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 8844F8BB73;
	Fri,  1 Mar 2019 13:33:49 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 61C9C6F89E; Fri,  1 Mar 2019 12:33:49 +0000 (UTC)
Message-Id: <b6b179efc9bd58d27874832969e7a5c890fd3690.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 11/11] powerpc/32s: set up an early static hash table for
 KASAN.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:49 +0000 (UTC)
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

For hash32, the zero shadow page gets mapped with PAGE_READONLY instead
of PAGE_KERNEL_RO, because the PP bits don't provide a RO kernel, so
PAGE_KERNEL_RO is equivalent to PAGE_KERNEL. By using PAGE_READONLY,
the page is RO for both kernel and user, but this is not a security issue
as it contains only zeroes.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/kasan.h      |  1 +
 arch/powerpc/kernel/head_32.S         | 43 ++++++++++++++++++++++-------
 arch/powerpc/mm/kasan/kasan_init_32.c | 51 ++++++++++++++++++++++++++++++-----
 arch/powerpc/mm/mmu_decl.h            |  1 +
 4 files changed, 79 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
index 74a4ba9fb8a3..c9fe0369a8fc 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -29,6 +29,7 @@
 
 #ifdef CONFIG_KASAN
 void kasan_early_init(void);
+void kasan_mmu_init(void);
 void kasan_init(void);
 #else
 static inline void kasan_init(void) { }
diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index e644aab2cf5b..7f7fbdd73b79 100644
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
@@ -881,11 +885,24 @@ _ENTRY(__restore_cpu_setup)
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
@@ -897,14 +914,6 @@ load_up_mmu:
 	tophys(r6,r6)
 	lwz	r6,_SDR1@l(r6)
 	mtspr	SPRN_SDR1,r6
-	li	r0,16		/* load up segment register values */
-	mtctr	r0		/* for context 0 */
-	lis	r3,0x2000	/* Ku = 1, VSID = 0 */
-	li	r4,0
-3:	mtsrin	r3,r4
-	addi	r3,r3,0x111	/* increment VSID */
-	addis	r4,r4,0x1000	/* address of next segment */
-	bdnz	3b
 
 /* Load the BAT registers with the values set up by MMU_init.
    MMU_init takes care of whether we're on a 601 or not. */
@@ -926,6 +935,17 @@ BEGIN_MMU_FTR_SECTION
 END_MMU_FTR_SECTION_IFSET(MMU_FTR_USE_HIGH_BATS)
 	blr
 
+load_segment_registers:
+	li	r0, 16		/* load up segment register values */
+	mtctr	r0		/* for context 0 */
+	lis	r3, 0x2000	/* Ku = 1, VSID = 0 */
+	li	r4, 0
+3:	mtsrin	r3, r4
+	addi	r3, r3, 0x111	/* increment VSID */
+	addis	r4, r4, 0x1000	/* address of next segment */
+	bdnz	3b
+	blr
+
 /*
  * This is where the main kernel code starts.
  */
@@ -961,6 +981,9 @@ start_here:
 	bl	__save_cpu_setup
 	bl	MMU_init
 BEGIN_MMU_FTR_SECTION
+#ifdef CONFIG_KASAN
+	bl	kasan_mmu_init
+#endif
 	bl	MMU_init_hw_patch
 END_MMU_FTR_SECTION_IFSET(MMU_FTR_HPTE_TABLE)
 
diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
index cc788917ce38..f6dbc537c051 100644
--- a/arch/powerpc/mm/kasan/kasan_init_32.c
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -39,7 +39,10 @@ static int kasan_init_shadow_page_tables(unsigned long k_start, unsigned long k_
 
 		if (!new)
 			return -ENOMEM;
-		kasan_populate_pte(new, PAGE_KERNEL_RO);
+		if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+			kasan_populate_pte(new, PAGE_READONLY);
+		else
+			kasan_populate_pte(new, PAGE_KERNEL_RO);
 		pmd_populate_kernel(&init_mm, pmd, new);
 	}
 	return 0;
@@ -60,10 +63,13 @@ static int __ref kasan_init_region(void *start, size_t size)
 	unsigned long k_cur;
 	pmd_t *pmd;
 	void *block = NULL;
-	int ret = kasan_init_shadow_page_tables(k_start, k_end);
 
-	if (ret)
-		return ret;
+	if (!early_mmu_has_feature(MMU_FTR_HPTE_TABLE)) {
+		int ret = kasan_init_shadow_page_tables(k_start, k_end);
+
+		if (ret)
+			return ret;
+	}
 
 	if (!slab_is_available())
 		block = memblock_alloc(k_end - k_start, PAGE_SIZE);
@@ -84,15 +90,26 @@ static int __ref kasan_init_region(void *start, size_t size)
 
 static void __init kasan_remap_early_shadow_ro(void)
 {
-	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		kasan_populate_pte(kasan_early_shadow_pte, PAGE_READONLY);
+	else
+		kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
+
 	flush_tlb_kernel_range(KASAN_SHADOW_START, KASAN_SHADOW_END);
 }
 
-void __init kasan_init(void)
+void __init kasan_mmu_init(void)
 {
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
@@ -104,6 +121,12 @@ void __init kasan_init(void)
 		if (ret)
 			panic("kasan: kasan_init_region() failed");
 	}
+}
+
+void __init kasan_init(void)
+{
+	if (!early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		kasan_mmu_init();
 
 	kasan_remap_early_shadow_ro();
 
@@ -131,6 +154,20 @@ void *module_alloc(unsigned long size)
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
@@ -148,5 +185,5 @@ void __init kasan_early_init(void)
 	} while (pmd++, addr = next, addr != end);
 
 	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
-		WARN(1, "KASAN not supported on hash 6xx");
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

