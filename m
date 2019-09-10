Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A01BC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFDD420872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="ILD8zG85"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFDD420872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1D0F6B026B; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5BD66B026F; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 749E16B026D; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4458F6B026B
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id F0BD02201A
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:19 +0000 (UTC)
X-FDA: 75918457398.22.smash62_5bd1b345cf5d
X-HE-Tag: smash62_5bd1b345cf5d
X-Filterd-Recvd-Size: 4421
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:19 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDY1BGwz9txWB;
	Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=ILD8zG85; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id wXfacbMexOL1; Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDY065Xz9txVx;
	Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107037; bh=SuQxAQ4l/1mHGi45aVKRS3CT3WsuP/jKyi3kssGze6g=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=ILD8zG85dCE0kLAHDclW0NTtLGVovzOZlWbsJp+md5sZVRk1tvGllomdrtVY7yeET
	 n4cb9wK6/AgQdnwHRjH2m+kqE6wJT3MJKYbQ1WXMrjluff66cpK9t7D6CjXimPpUKE
	 4q3k41Q6ihWGqbwQ4kn6Mv8QR28rmQ41iDKelEWc=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 490168B884;
	Tue, 10 Sep 2019 11:17:16 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id GogIUwTdsHr4; Tue, 10 Sep 2019 11:17:15 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 89F168B898;
	Tue, 10 Sep 2019 11:16:30 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 47AD06B739; Tue, 10 Sep 2019 09:16:30 +0000 (UTC)
Message-Id: <d23763ecf0e247b03d2b0337b845f86ee1e7c013.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 11/15] powerpc/8xx: move DataStoreTLBMiss perf handler
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move DataStoreTLBMiss perf handler in order to cope
with future growing exception prolog.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_8xx.S | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
index 5aa63693f790..1e718e47fe3c 100644
--- a/arch/powerpc/kernel/head_8xx.S
+++ b/arch/powerpc/kernel/head_8xx.S
@@ -166,18 +166,6 @@ SystemCall:
  */
 	EXCEPTION(0x1000, SoftEmu, program_check_exception, EXC_XFER_STD)
 
-/* Called from DataStoreTLBMiss when perf TLB misses events are activated */
-#ifdef CONFIG_PERF_EVENTS
-	patch_site	0f, patch__dtlbmiss_perf
-0:	lwz	r10, (dtlb_miss_counter - PAGE_OFFSET)@l(0)
-	addi	r10, r10, 1
-	stw	r10, (dtlb_miss_counter - PAGE_OFFSET)@l(0)
-	mfspr	r10, SPRN_DAR
-	mtspr	SPRN_DAR, r11	/* Tag DAR */
-	mfspr	r11, SPRN_M_TW
-	rfi
-#endif
-
 	. = 0x1100
 /*
  * For the MPC8xx, this is a software tablewalk to load the instruction
@@ -486,6 +474,18 @@ DARFixed:/* Return from dcbx instruction bug workaround */
 	/* 0x300 is DataAccess exception, needed by bad_page_fault() */
 	EXC_XFER_LITE(0x300, handle_page_fault)
 
+/* Called from DataStoreTLBMiss when perf TLB misses events are activated */
+#ifdef CONFIG_PERF_EVENTS
+	patch_site	0f, patch__dtlbmiss_perf
+0:	lwz	r10, (dtlb_miss_counter - PAGE_OFFSET)@l(0)
+	addi	r10, r10, 1
+	stw	r10, (dtlb_miss_counter - PAGE_OFFSET)@l(0)
+	mfspr	r10, SPRN_DAR
+	mtspr	SPRN_DAR, r11	/* Tag DAR */
+	mfspr	r11, SPRN_M_TW
+	rfi
+#endif
+
 /* On the MPC8xx, these next four traps are used for development
  * support of breakpoints and such.  Someday I will get around to
  * using them.
-- 
2.13.3


