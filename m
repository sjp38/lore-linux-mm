Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1791C49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59E1620872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="bRfVBqGT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59E1620872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4637D6B000A; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 444F66B000D; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 329966B000C; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0113.hostedemail.com [216.40.44.113])
	by kanga.kvack.org (Postfix) with ESMTP id 14DA46B0008
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:17 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id BBE3222012
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:16 +0000 (UTC)
X-FDA: 75918457272.16.cause36_547412a13045
X-HE-Tag: cause36_547412a13045
X-Filterd-Recvd-Size: 6598
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:16 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDT4VFtz9txVy;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=bRfVBqGT; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id gGVpoIF28Ftl; Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDT3N62z9txVw;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107033; bh=kGon0ub1xJnz0O6Eae+CiFjeXTbJxumDVRZ8IyCl084=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=bRfVBqGTm7ZP4TNHo9d4OwEGPPNEDsVuceZm4Z9QKfBh3L9M1H18Boq0bohSbaYj7
	 YQcZbhlnXwS5bfH7AQ/zHN6iTLd4PJv46JVLKpfogSFrNFL8HMO3a8xyNYXg7jDBbP
	 13NG9g4/xhCgJySauKt5R3YagsKncUdvCP9ZOJdw=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 327F18B878;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id BWrtv-xqzQwT; Tue, 10 Sep 2019 11:17:12 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 66CD38B886;
	Tue, 10 Sep 2019 11:16:20 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 096006B739; Tue, 10 Sep 2019 09:16:20 +0000 (UTC)
Message-Id: <20ee91d8a7abc7d27a79ba704c0fd4b2800e9951.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 01/15] powerpc/32: replace MTMSRD() by mtmsr
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On PPC32, MTMSRD() is simply defined as mtmsr.

Replace MTMSRD(reg) by mtmsr reg in files dedicated to PPC32,
this makes the code less obscure.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/entry_32.S | 18 +++++++++---------
 arch/powerpc/kernel/head_32.h  |  4 ++--
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/kernel/entry_32.S b/arch/powerpc/kernel/entry_32.S
index d60908ea37fb..6273b4862482 100644
--- a/arch/powerpc/kernel/entry_32.S
+++ b/arch/powerpc/kernel/entry_32.S
@@ -397,7 +397,7 @@ ret_from_syscall:
 	LOAD_REG_IMMEDIATE(r10,MSR_KERNEL)	/* doesn't include MSR_EE */
 	/* Note: We don't bother telling lockdep about it */
 	SYNC
-	MTMSRD(r10)
+	mtmsr	r10
 	lwz	r9,TI_FLAGS(r2)
 	li	r8,-MAX_ERRNO
 	andi.	r0,r9,(_TIF_SYSCALL_DOTRACE|_TIF_SINGLESTEP|_TIF_USER_WORK_MASK|_TIF_PERSYSCALL_MASK)
@@ -554,7 +554,7 @@ syscall_exit_work:
 	 */
 	ori	r10,r10,MSR_EE
 	SYNC
-	MTMSRD(r10)
+	mtmsr	r10
 
 	/* Save NVGPRS if they're not saved already */
 	lwz	r4,_TRAP(r1)
@@ -697,7 +697,7 @@ END_FTR_SECTION_IFSET(CPU_FTR_SPE)
 	and.	r0,r0,r11	/* FP or altivec or SPE enabled? */
 	beq+	1f
 	andc	r11,r11,r0
-	MTMSRD(r11)
+	mtmsr	r11
 	isync
 1:	stw	r11,_MSR(r1)
 	mfcr	r10
@@ -831,7 +831,7 @@ ret_from_except:
 	/* Note: We don't bother telling lockdep about it */
 	LOAD_REG_IMMEDIATE(r10,MSR_KERNEL)
 	SYNC			/* Some chip revs have problems here... */
-	MTMSRD(r10)		/* disable interrupts */
+	mtmsr	r10		/* disable interrupts */
 
 	lwz	r3,_MSR(r1)	/* Returning to user mode? */
 	andi.	r0,r3,MSR_PR
@@ -998,7 +998,7 @@ END_FTR_SECTION_IFSET(CPU_FTR_NEED_PAIRED_STWCX)
 	 */
 	LOAD_REG_IMMEDIATE(r10,MSR_KERNEL & ~MSR_RI)
 	SYNC
-	MTMSRD(r10)		/* clear the RI bit */
+	mtmsr	r10		/* clear the RI bit */
 	.globl exc_exit_restart
 exc_exit_restart:
 	lwz	r12,_NIP(r1)
@@ -1234,7 +1234,7 @@ do_resched:			/* r10 contains MSR_KERNEL here */
 #endif
 	ori	r10,r10,MSR_EE
 	SYNC
-	MTMSRD(r10)		/* hard-enable interrupts */
+	mtmsr	r10		/* hard-enable interrupts */
 	bl	schedule
 recheck:
 	/* Note: And we don't tell it we are disabling them again
@@ -1243,7 +1243,7 @@ recheck:
 	 */
 	LOAD_REG_IMMEDIATE(r10,MSR_KERNEL)
 	SYNC
-	MTMSRD(r10)		/* disable interrupts */
+	mtmsr	r10		/* disable interrupts */
 	lwz	r9,TI_FLAGS(r2)
 	andi.	r0,r9,_TIF_NEED_RESCHED
 	bne-	do_resched
@@ -1252,7 +1252,7 @@ recheck:
 do_user_signal:			/* r10 contains MSR_KERNEL here */
 	ori	r10,r10,MSR_EE
 	SYNC
-	MTMSRD(r10)		/* hard-enable interrupts */
+	mtmsr	r10		/* hard-enable interrupts */
 	/* save r13-r31 in the exception frame, if not already done */
 	lwz	r3,_TRAP(r1)
 	andi.	r0,r3,1
@@ -1341,7 +1341,7 @@ _GLOBAL(enter_rtas)
 	stw	r9,8(r1)
 	LOAD_REG_IMMEDIATE(r0,MSR_KERNEL)
 	SYNC			/* disable interrupts so SRR0/1 */
-	MTMSRD(r0)		/* don't get trashed */
+	mtmsr	r0		/* don't get trashed */
 	li	r9,MSR_KERNEL & ~(MSR_IR|MSR_DR)
 	mtlr	r6
 	stw	r7, THREAD + RTAS_SP(r2)
diff --git a/arch/powerpc/kernel/head_32.h b/arch/powerpc/kernel/head_32.h
index 8abc7783dbe5..b2ca8c9ffd8b 100644
--- a/arch/powerpc/kernel/head_32.h
+++ b/arch/powerpc/kernel/head_32.h
@@ -50,7 +50,7 @@
 	rlwinm	r9,r9,0,14,12		/* clear MSR_WE (necessary?) */
 #else
 	li	r10,MSR_KERNEL & ~(MSR_IR|MSR_DR) /* can take exceptions */
-	MTMSRD(r10)			/* (except for mach check in rtas) */
+	mtmsr	r10			/* (except for mach check in rtas) */
 #endif
 	stw	r0,GPR0(r11)
 	lis	r10,STACK_FRAME_REGS_MARKER@ha /* exception frame marker */
@@ -80,7 +80,7 @@
 	rlwinm	r9,r9,0,14,12		/* clear MSR_WE (necessary?) */
 #else
 	LOAD_REG_IMMEDIATE(r10, MSR_KERNEL & ~(MSR_IR|MSR_DR)) /* can take exceptions */
-	MTMSRD(r10)			/* (except for mach check in rtas) */
+	mtmsr	r10			/* (except for mach check in rtas) */
 #endif
 	lis	r10,STACK_FRAME_REGS_MARKER@ha /* exception frame marker */
 	stw	r2,GPR2(r11)
-- 
2.13.3


