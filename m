Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A5A0C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46C7A20872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="AC3fr2ag"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46C7A20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41AA56B026D; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 242A96B026E; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E04C6B026F; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id DC6536B026D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 907B555FB1
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:20 +0000 (UTC)
X-FDA: 75918457440.18.geese63_5d75ef125f20
X-HE-Tag: geese63_5d75ef125f20
X-Filterd-Recvd-Size: 4929
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:20 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDY6S2gz9txVv;
	Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=AC3fr2ag; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id xmvf9NDOOVTe; Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDY5Q6Wz9txVx;
	Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107037; bh=sPQkpfAXuHD4qRlIU4DOLkneuq2pFkJAZAVl214Hg7k=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=AC3fr2agaTwZz1bzV6/xYbSr8/zaoRY8R4z/R9A9f9MJ82BSDuK6dx+Pu2yMs6Ev2
	 En+RVSREFoC3ngSIhPgNOUVkFpnMrntTfUG5LlYx+CDuBeFiopHetyN7YgZInmU01C
	 qBDclOSirLXLRDacdnDvIkU9jtNTIkGjtQqPCo6M=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 4A6498B87F;
	Tue, 10 Sep 2019 11:17:15 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id DH4HRl5Mrzx2; Tue, 10 Sep 2019 11:17:15 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BD6BB8B89C;
	Tue, 10 Sep 2019 11:16:33 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 66C596B739; Tue, 10 Sep 2019 09:16:33 +0000 (UTC)
Message-Id: <106a755225eabfcaa1ed3bed39f763c0a3292cce.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 14/15] powerpc/32s: reorganise DSI handler.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The part decidated to handling hash_page() is fully unneeded for
processors not having real hash pages like the 603.

Lets enlarge the content of the feature fixup, and provide
an alternative which jumps directly instead of getting NIPs.

Also, in preparation of VMAP stacks, the end of DSI handler has moved
to later in the code as it won't fit anymore once VMAP stacks
are there.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_32.S | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index 449625b4ff03..5bda6a092673 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -295,24 +295,22 @@ __secondary_hold_acknowledge:
 	DO_KVM  0x300
 DataAccess:
 	EXCEPTION_PROLOG
-	mfspr	r10,SPRN_DSISR
-	stw	r10,_DSISR(r11)
+	get_and_save_dar_dsisr_on_stack	r4, r5, r11
+BEGIN_MMU_FTR_SECTION
 #ifdef CONFIG_PPC_KUAP
-	andis.	r0,r10,(DSISR_BAD_FAULT_32S | DSISR_DABRMATCH | DSISR_PROTFAULT)@h
+	andis.	r0, r5, (DSISR_BAD_FAULT_32S | DSISR_DABRMATCH | DSISR_PROTFAULT)@h
 #else
-	andis.	r0,r10,(DSISR_BAD_FAULT_32S|DSISR_DABRMATCH)@h
+	andis.	r0, r5, (DSISR_BAD_FAULT_32S | DSISR_DABRMATCH)@h
 #endif
-	bne	1f			/* if not, try to put a PTE */
-	mfspr	r4,SPRN_DAR		/* into the hash table */
-	rlwinm	r3,r10,32-15,21,21	/* DSISR_STORE -> _PAGE_RW */
-BEGIN_MMU_FTR_SECTION
+	bne	handle_page_fault_tramp	/* if not, try to put a PTE */
+	rlwinm	r3, r5, 32 - 15, 21, 21	/* DSISR_STORE -> _PAGE_RW */
 	bl	hash_page
-END_MMU_FTR_SECTION_IFSET(MMU_FTR_HPTE_TABLE)
-1:	lwz	r5,_DSISR(r11)		/* get DSISR value */
-	mfspr	r4,SPRN_DAR
-	stw	r4, _DAR(r11)
-	EXC_XFER_LITE(0x300, handle_page_fault)
-
+	lwz	r5, _DSISR(r11)		/* get DSISR value */
+	lwz	r4, _DAR(r11)
+	b	handle_page_fault_tramp
+FTR_SECTION_ELSE
+	b	handle_page_fault_tramp
+ALT_MMU_FTR_SECTION_END_IFSET(MMU_FTR_HPTE_TABLE)
 
 /* Instruction access exception. */
 	. = 0x400
@@ -642,6 +640,9 @@ END_MMU_FTR_SECTION_IFSET(MMU_FTR_NEED_DTLB_SW_LRU)
 
 	. = 0x3000
 
+handle_page_fault_tramp:
+	EXC_XFER_LITE(0x300, handle_page_fault)
+
 AltiVecUnavailable:
 	EXCEPTION_PROLOG
 #ifdef CONFIG_ALTIVEC
-- 
2.13.3


