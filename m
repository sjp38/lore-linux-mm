Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8A8CC4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 978B120872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="IYKgYCtR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 978B120872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CB846B000E; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96DF76B0008; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 722586B000E; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0247.hostedemail.com [216.40.44.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0EA6B0008
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DD3268243765
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:16 +0000 (UTC)
X-FDA: 75918457272.03.wine70_54b19f4c4501
X-HE-Tag: wine70_54b19f4c4501
X-Filterd-Recvd-Size: 7211
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:16 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDT5GGfz9txVw;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=IYKgYCtR; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 1hmBA15ncuo5; Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDT49WXz9txVx;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107033; bh=N7iNBXrKk9Iu0CbrqCmgFWgwrPQ2JpHJEeAehfG7eeM=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=IYKgYCtRz2jEkYJ4kZ6zdWpUGGcmfIS/eLuJExLYJgGphvHVpBWAxAOWkL03Z2df3
	 Amju3kN0tsConICiVsrLKk/g0sGS8mMWeKDOvGN2GE6w2qjs+kOt6oKIG/8+2vARhy
	 iynFM4s2s4EAeVbSYNVAK5K73ZWCkMCAido9WMOM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 006698B875;
	Tue, 10 Sep 2019 11:17:12 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id zPIeYemDEANR; Tue, 10 Sep 2019 11:17:12 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5E94D8B889;
	Tue, 10 Sep 2019 11:16:22 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 16E0F6B739; Tue, 10 Sep 2019 09:16:22 +0000 (UTC)
Message-Id: <c3c2b4de8794815d35d88c679f22a49fd8a9e0b7.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 03/15] powerpc/32: save DEAR/DAR before calling
 handle_page_fault
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

handle_page_fault() is the only function that save DAR/DEAR itself.

Save DAR/DEAR before calling handle_page_fault() to prepare for
VMAP stack which will require to save even before.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/entry_32.S       | 1 -
 arch/powerpc/kernel/head_32.S        | 2 ++
 arch/powerpc/kernel/head_40x.S       | 2 ++
 arch/powerpc/kernel/head_8xx.S       | 2 ++
 arch/powerpc/kernel/head_booke.h     | 2 ++
 arch/powerpc/kernel/head_fsl_booke.S | 1 +
 6 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/entry_32.S b/arch/powerpc/kernel/entry_32.S
index 6273b4862482..317ad9df8ba8 100644
--- a/arch/powerpc/kernel/entry_32.S
+++ b/arch/powerpc/kernel/entry_32.S
@@ -621,7 +621,6 @@ ppc_swapcontext:
  */
 	.globl	handle_page_fault
 handle_page_fault:
-	stw	r4,_DAR(r1)
 	addi	r3,r1,STACK_FRAME_OVERHEAD
 #ifdef CONFIG_PPC_BOOK3S_32
 	andis.  r0,r5,DSISR_DABRMATCH@h
diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index 9e868567b716..bebb49d877f2 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -310,6 +310,7 @@ BEGIN_MMU_FTR_SECTION
 END_MMU_FTR_SECTION_IFSET(MMU_FTR_HPTE_TABLE)
 1:	lwz	r5,_DSISR(r11)		/* get DSISR value */
 	mfspr	r4,SPRN_DAR
+	stw	r4, _DAR(r11)
 	EXC_XFER_LITE(0x300, handle_page_fault)
 
 
@@ -327,6 +328,7 @@ BEGIN_MMU_FTR_SECTION
 END_MMU_FTR_SECTION_IFSET(MMU_FTR_HPTE_TABLE)
 1:	mr	r4,r12
 	andis.	r5,r9,DSISR_SRR1_MATCH_32S@h /* Filter relevant SRR1 bits */
+	stw	r4, _DAR(r11)
 	EXC_XFER_LITE(0x400, handle_page_fault)
 
 /* External interrupt */
diff --git a/arch/powerpc/kernel/head_40x.S b/arch/powerpc/kernel/head_40x.S
index 585ea1976550..9bb663977e84 100644
--- a/arch/powerpc/kernel/head_40x.S
+++ b/arch/powerpc/kernel/head_40x.S
@@ -313,6 +313,7 @@ _ENTRY(saved_ksp_limit)
 	START_EXCEPTION(0x0400, InstructionAccess)
 	EXCEPTION_PROLOG
 	mr	r4,r12			/* Pass SRR0 as arg2 */
+	stw	r4, _DEAR(r11)
 	li	r5,0			/* Pass zero as arg3 */
 	EXC_XFER_LITE(0x400, handle_page_fault)
 
@@ -676,6 +677,7 @@ DataAccess:
 	mfspr	r5,SPRN_ESR		/* Grab the ESR, save it, pass arg3 */
 	stw	r5,_ESR(r11)
 	mfspr	r4,SPRN_DEAR		/* Grab the DEAR, save it, pass arg2 */
+	stw	r4, _DEAR(r11)
 	EXC_XFER_LITE(0x300, handle_page_fault)
 
 /* Other PowerPC processors, namely those derived from the 6xx-series
diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
index dac7c0a34eea..fb284d95c76a 100644
--- a/arch/powerpc/kernel/head_8xx.S
+++ b/arch/powerpc/kernel/head_8xx.S
@@ -486,6 +486,7 @@ InstructionTLBError:
 	tlbie	r4
 	/* 0x400 is InstructionAccess exception, needed by bad_page_fault() */
 .Litlbie:
+	stw	r4, _DAR(r11)
 	EXC_XFER_LITE(0x400, handle_page_fault)
 
 /* This is the data TLB error on the MPC8xx.  This could be due to
@@ -504,6 +505,7 @@ DARFixed:/* Return from dcbx instruction bug workaround */
 	mfspr	r5,SPRN_DSISR
 	stw	r5,_DSISR(r11)
 	mfspr	r4,SPRN_DAR
+	stw	r4, _DAR(r11)
 	andis.	r10,r5,DSISR_NOHPTE@h
 	beq+	.Ldtlbie
 	tlbie	r4
diff --git a/arch/powerpc/kernel/head_booke.h b/arch/powerpc/kernel/head_booke.h
index 2ae635df9026..37fc84ed90e3 100644
--- a/arch/powerpc/kernel/head_booke.h
+++ b/arch/powerpc/kernel/head_booke.h
@@ -467,6 +467,7 @@ ALT_FTR_SECTION_END_IFSET(CPU_FTR_EMB_HV)
 	mfspr	r5,SPRN_ESR;		/* Grab the ESR and save it */	      \
 	stw	r5,_ESR(r11);						      \
 	mfspr	r4,SPRN_DEAR;		/* Grab the DEAR */		      \
+	stw	r4, _DEAR(r11);						      \
 	EXC_XFER_LITE(0x0300, handle_page_fault)
 
 #define INSTRUCTION_STORAGE_EXCEPTION					      \
@@ -475,6 +476,7 @@ ALT_FTR_SECTION_END_IFSET(CPU_FTR_EMB_HV)
 	mfspr	r5,SPRN_ESR;		/* Grab the ESR and save it */	      \
 	stw	r5,_ESR(r11);						      \
 	mr      r4,r12;                 /* Pass SRR0 as arg2 */		      \
+	stw	r4, _DEAR(r11);						      \
 	li      r5,0;                   /* Pass zero as arg3 */		      \
 	EXC_XFER_LITE(0x0400, handle_page_fault)
 
diff --git a/arch/powerpc/kernel/head_fsl_booke.S b/arch/powerpc/kernel/head_fsl_booke.S
index adf0505dbe02..442aaac292b0 100644
--- a/arch/powerpc/kernel/head_fsl_booke.S
+++ b/arch/powerpc/kernel/head_fsl_booke.S
@@ -376,6 +376,7 @@ interrupt_base:
 	mfspr	r4,SPRN_DEAR		/* Grab the DEAR, save it, pass arg2 */
 	andis.	r10,r5,(ESR_ILK|ESR_DLK)@h
 	bne	1f
+	stw	r4, _DEAR(r11)
 	EXC_XFER_LITE(0x0300, handle_page_fault)
 1:
 	addi	r3,r1,STACK_FRAME_OVERHEAD
-- 
2.13.3


