Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	NORMAL_HTTP_TO_IP,NUMERIC_HTTP_ADDR,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F226BC49ED6
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE84920872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="bnTfXOZX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE84920872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4E426B0008; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB4EC6B000C; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E4186B000D; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6A36B000C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 02BFF443F
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:17 +0000 (UTC)
X-FDA: 75918457314.14.color77_5504fcb34303
X-HE-Tag: color77_5504fcb34303
X-Filterd-Recvd-Size: 6795
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:16 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDV0sJBz9txW6;
	Tue, 10 Sep 2019 11:17:14 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=bnTfXOZX; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id iMt5jpHTS_2o; Tue, 10 Sep 2019 11:17:14 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDT6mtwz9txW1;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107033; bh=OUysxTrW56fqmPw2U8c/5GTPg4n/j/VebyDLfYGLObA=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=bnTfXOZXZtiruodW5cvUhB+HgPPnNQA6mAJaxjucLmbKZIJl1WFz1dd5DYt65yuek
	 d4RWYtkAowODPko8jRHX/1sinWLzftskCWKVyVhMU5p+AgPoJ5rn+xvaCprwPjB+BA
	 c/0n++x29Q1bMGDN3BxugVyI6REZYYKggl+BmHT4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 780AF8B86E;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id wOd2hPrXmFNz; Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 6DAC38B88A;
	Tue, 10 Sep 2019 11:16:23 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 1C0036B739; Tue, 10 Sep 2019 09:16:23 +0000 (UTC)
Message-Id: <32bb1f678114fab20f8cd621a9db9755adcdd279.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 04/15] powerpc/32: move MSR_PR test into EXCEPTION_PROLOG_0
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to simplify  VMAP stack implementation, move
MSR_PR test into EXCEPTION_PROLOG_0.

This requires to not modify cr0 between EXCEPTION_PROLOG_0
and EXCEPTION_PROLOG_1.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_32.h  |  4 ++--
 arch/powerpc/kernel/head_8xx.S | 39 ++++++++++++++++++++-------------------
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/arch/powerpc/kernel/head_32.h b/arch/powerpc/kernel/head_32.h
index 8e345f8d4b0e..436ffd862d2a 100644
--- a/arch/powerpc/kernel/head_32.h
+++ b/arch/powerpc/kernel/head_32.h
@@ -19,12 +19,12 @@
 .macro EXCEPTION_PROLOG_0
 	mtspr	SPRN_SPRG_SCRATCH0,r10
 	mtspr	SPRN_SPRG_SCRATCH1,r11
+	mfspr	r11, SPRN_SRR1		/* check whether user or kernel */
 	mfcr	r10
+	andi.	r11, r11, MSR_PR
 .endm
 
 .macro EXCEPTION_PROLOG_1
-	mfspr	r11,SPRN_SRR1		/* check whether user or kernel */
-	andi.	r11,r11,MSR_PR
 	tophys(r11,r1)			/* use tophys(r1) if kernel */
 	beq	1f
 	mfspr	r11,SPRN_SPRG_THREAD
diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
index fb284d95c76a..175c3cfc8014 100644
--- a/arch/powerpc/kernel/head_8xx.S
+++ b/arch/powerpc/kernel/head_8xx.S
@@ -497,8 +497,8 @@ InstructionTLBError:
 DataTLBError:
 	EXCEPTION_PROLOG_0
 	mfspr	r11, SPRN_DAR
-	cmpwi	cr0, r11, RPN_PATTERN
-	beq-	FixupDAR	/* must be a buggy dcbX, icbi insn. */
+	cmpwi	cr1, r11, RPN_PATTERN
+	beq-	cr1, FixupDAR	/* must be a buggy dcbX, icbi insn. */
 DARFixed:/* Return from dcbx instruction bug workaround */
 	EXCEPTION_PROLOG_1
 	EXCEPTION_PROLOG_2
@@ -531,9 +531,9 @@ DARFixed:/* Return from dcbx instruction bug workaround */
 DataBreakpoint:
 	EXCEPTION_PROLOG_0
 	mfspr	r11, SPRN_SRR0
-	cmplwi	cr0, r11, (.Ldtlbie - PAGE_OFFSET)@l
+	cmplwi	cr1, r11, (.Ldtlbie - PAGE_OFFSET)@l
 	cmplwi	cr7, r11, (.Litlbie - PAGE_OFFSET)@l
-	beq-	cr0, 11f
+	beq-	cr1, 11f
 	beq-	cr7, 11f
 	EXCEPTION_PROLOG_1
 	EXCEPTION_PROLOG_2
@@ -578,9 +578,9 @@ FixupDAR:/* Entry point for dcbx workaround. */
 	mfspr	r10, SPRN_SRR0
 	mtspr	SPRN_MD_EPN, r10
 	rlwinm	r11, r10, 16, 0xfff8
-	cmpli	cr0, r11, PAGE_OFFSET@h
+	cmpli	cr1, r11, PAGE_OFFSET@h
 	mfspr	r11, SPRN_M_TWB	/* Get level 1 table */
-	blt+	3f
+	blt+	cr1, 3f
 	rlwinm	r11, r10, 16, 0xfff8
 
 0:	cmpli	cr7, r11, (PAGE_OFFSET + 0x1800000)@h
@@ -595,7 +595,7 @@ FixupDAR:/* Entry point for dcbx workaround. */
 3:
 	lwz	r11, (swapper_pg_dir-PAGE_OFFSET)@l(r11)	/* Get the level 1 entry */
 	mtspr	SPRN_MD_TWC, r11
-	mtcr	r11
+	mtcrf	0x01, r11
 	mfspr	r11, SPRN_MD_TWC
 	lwz	r11, 0(r11)	/* Get the pte */
 	bt	28,200f		/* bit 28 = Large page (8M) */
@@ -608,16 +608,16 @@ FixupDAR:/* Entry point for dcbx workaround. */
  * no need to include them here */
 	xoris	r10, r11, 0x7c00	/* check if major OP code is 31 */
 	rlwinm	r10, r10, 0, 21, 5
-	cmpwi	cr0, r10, 2028	/* Is dcbz? */
-	beq+	142f
-	cmpwi	cr0, r10, 940	/* Is dcbi? */
-	beq+	142f
-	cmpwi	cr0, r10, 108	/* Is dcbst? */
-	beq+	144f		/* Fix up store bit! */
-	cmpwi	cr0, r10, 172	/* Is dcbf? */
-	beq+	142f
-	cmpwi	cr0, r10, 1964	/* Is icbi? */
-	beq+	142f
+	cmpwi	cr1, r10, 2028	/* Is dcbz? */
+	beq+	cr1, 142f
+	cmpwi	cr1, r10, 940	/* Is dcbi? */
+	beq+	cr1, 142f
+	cmpwi	cr1, r10, 108	/* Is dcbst? */
+	beq+	cr1, 144f		/* Fix up store bit! */
+	cmpwi	cr1, r10, 172	/* Is dcbf? */
+	beq+	cr1, 142f
+	cmpwi	cr1, r10, 1964	/* Is icbi? */
+	beq+	cr1, 142f
 141:	mfspr	r10,SPRN_M_TW
 	b	DARFixed	/* Nope, go back to normal TLB processing */
 
@@ -676,8 +676,9 @@ FixupDAR:/* Entry point for dcbx workaround. */
 	add	r10, r10, r30	;b	151f
 	add	r10, r10, r31
 151:
-	rlwinm. r11,r11,19,24,28	/* offset into jump table for reg RA */
-	beq	152f			/* if reg RA is zero, don't add it */
+	rlwinm	r11,r11,19,24,28	/* offset into jump table for reg RA */
+	cmpwi	cr1, r11, 0
+	beq	cr1, 152f		/* if reg RA is zero, don't add it */
 	addi	r11, r11, 150b@l	/* add start of table */
 	mtctr	r11			/* load ctr with jump address */
 	rlwinm	r11,r11,0,16,10		/* make sure we don't execute this more than once */
-- 
2.13.3


