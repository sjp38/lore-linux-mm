Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11411C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEE8620872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="kkcWCaCT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEE8620872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 774176B026E; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FEBF6B026F; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BDCF6B0272; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0043.hostedemail.com [216.40.44.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7676B026F
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D44A122025
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:20 +0000 (UTC)
X-FDA: 75918457440.10.books37_5dcebfb63353
X-HE-Tag: books37_5dcebfb63353
X-Filterd-Recvd-Size: 6290
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:20 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDZ0xGPz9txWF;
	Tue, 10 Sep 2019 11:17:18 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=kkcWCaCT; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id nDkcXMjkgDRt; Tue, 10 Sep 2019 11:17:18 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDY5crhz9txW3;
	Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107038; bh=NkamMLYWkTRb4MIQTbWL0E/hNXMZkvWH96BKgp+YBow=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=kkcWCaCTbkDRLSJzo4u1Zy9iGNFB2ICqDMZEaM9aMdsC1rRC+y70hBPy7dFZnq+WH
	 tRN/pYxLaxQwrgpV3NCaBitDiBeS/CrBfq2+J8NZ++JbqnXylJRBZ0GyYPqqvWwJii
	 X9qdC07RN5QxkTsWgfcoZ+qkHXu7Jkgi5MSZeOnU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 994E68B888;
	Tue, 10 Sep 2019 11:17:16 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id pfq1G8uDpkbN; Tue, 10 Sep 2019 11:17:15 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A34A88B89B;
	Tue, 10 Sep 2019 11:16:32 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 532426B739; Tue, 10 Sep 2019 09:16:32 +0000 (UTC)
Message-Id: <1e17bd51cb1db72fdfb204d9da56df939e14eaba.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 13/15] powerpc/8xx: Enable CONFIG_VMAP_STACK
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch enables CONFIG_VMAP_STACK. For that, a few changes are
done in head_8xx.S.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_8xx.S         | 34 ++++++++++++++++++++++++++++------
 arch/powerpc/platforms/Kconfig.cputype |  1 +
 2 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
index 225e242ce1c5..fc6d4d10e298 100644
--- a/arch/powerpc/kernel/head_8xx.S
+++ b/arch/powerpc/kernel/head_8xx.S
@@ -127,7 +127,7 @@ instruction_counter:
 /* Machine check */
 	. = 0x200
 MachineCheck:
-	EXCEPTION_PROLOG
+	EXCEPTION_PROLOG dar
 	save_dar_dsisr_on_stack r4, r5, r11
 	li	r6, RPN_PATTERN
 	mtspr	SPRN_DAR, r6	/* Tag DAR, to be used in DTLB Error */
@@ -140,7 +140,7 @@ MachineCheck:
 /* Alignment exception */
 	. = 0x600
 Alignment:
-	EXCEPTION_PROLOG
+	EXCEPTION_PROLOG dar
 	save_dar_dsisr_on_stack r4, r5, r11
 	li	r6, RPN_PATTERN
 	mtspr	SPRN_DAR, r6	/* Tag DAR, to be used in DTLB Error */
@@ -457,20 +457,26 @@ InstructionTLBError:
  */
 	. = 0x1400
 DataTLBError:
-	EXCEPTION_PROLOG_0
+	EXCEPTION_PROLOG_0 dar
 	mfspr	r11, SPRN_DAR
 	cmpwi	cr1, r11, RPN_PATTERN
 	beq-	cr1, FixupDAR	/* must be a buggy dcbX, icbi insn. */
 DARFixed:/* Return from dcbx instruction bug workaround */
+#ifdef CONFIG_VMAP_STACK
+	li	r11, RPN_PATTERN
+	mtspr	SPRN_DAR, r11	/* Tag DAR, to be used in DTLB Error */
+#endif
 	EXCEPTION_PROLOG_1
-	EXCEPTION_PROLOG_2
+	EXCEPTION_PROLOG_2 dar
 	get_and_save_dar_dsisr_on_stack r4, r5, r11
 	andis.	r10,r5,DSISR_NOHPTE@h
 	beq+	.Ldtlbie
 	tlbie	r4
 .Ldtlbie:
+#ifndef CONFIG_VMAP_STACK
 	li	r10,RPN_PATTERN
 	mtspr	SPRN_DAR,r10	/* Tag DAR, to be used in DTLB Error */
+#endif
 	/* 0x300 is DataAccess exception, needed by bad_page_fault() */
 	EXC_XFER_LITE(0x300, handle_page_fault)
 
@@ -492,16 +498,20 @@ DARFixed:/* Return from dcbx instruction bug workaround */
  */
 do_databreakpoint:
 	EXCEPTION_PROLOG_1
-	EXCEPTION_PROLOG_2
+	EXCEPTION_PROLOG_2 dar
 	addi	r3,r1,STACK_FRAME_OVERHEAD
 	mfspr	r4,SPRN_BAR
 	stw	r4,_DAR(r11)
+#ifdef CONFIG_VMAP_STACK
+	lwz	r5,_DSISR(r11)
+#else
 	mfspr	r5,SPRN_DSISR
+#endif
 	EXC_XFER_STD(0x1c00, do_break)
 
 	. = 0x1c00
 DataBreakpoint:
-	EXCEPTION_PROLOG_0
+	EXCEPTION_PROLOG_0 dar
 	mfspr	r11, SPRN_SRR0
 	cmplwi	cr1, r11, (.Ldtlbie - PAGE_OFFSET)@l
 	cmplwi	cr7, r11, (.Litlbie - PAGE_OFFSET)@l
@@ -530,6 +540,11 @@ InstructionBreakpoint:
 	EXCEPTION(0x1e00, Trap_1e, unknown_exception, EXC_XFER_STD)
 	EXCEPTION(0x1f00, Trap_1f, unknown_exception, EXC_XFER_STD)
 
+#ifdef CONFIG_VMAP_STACK
+stack_ovf_trampoline:
+	b	stack_ovf
+#endif
+
 	. = 0x2000
 
 /* This is the procedure to calculate the data EA for buggy dcbx,dcbi instructions
@@ -650,7 +665,14 @@ FixupDAR:/* Entry point for dcbx workaround. */
 152:
 	mfdar	r11
 	mtctr	r11			/* restore ctr reg from DAR */
+#ifdef CONFIG_VMAP_STACK
+	mfspr	r11, SPRN_SPRG_THREAD
+	stw	r10, DAR(r11)
+	mfspr	r10, SPRN_DSISR
+	stw	r10, DSISR(r11)
+#else
 	mtdar	r10			/* save fault EA to DAR */
+#endif
 	mfspr	r10,SPRN_M_TW
 	b	DARFixed		/* Go back to normal TLB handling */
 
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 12543e53fa96..3c42569b75cc 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -49,6 +49,7 @@ config PPC_8xx
 	select PPC_HAVE_KUEP
 	select PPC_HAVE_KUAP
 	select PPC_MM_SLICES if HUGETLB_PAGE
+	select HAVE_ARCH_VMAP_STACK
 
 config 40x
 	bool "AMCC 40x"
-- 
2.13.3


