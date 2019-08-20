Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE784C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:01:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA29D20679
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:01:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Q4kYVlD4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA29D20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 321A46B000E; Tue, 20 Aug 2019 06:01:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D1AA6B0010; Tue, 20 Aug 2019 06:01:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E8F36B0269; Tue, 20 Aug 2019 06:01:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id E7F776B000E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:01:01 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 96BC0181AC9B4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:01:01 +0000 (UTC)
X-FDA: 75842362722.17.brass37_25fda7376cb0a
X-HE-Tag: brass37_25fda7376cb0a
X-Filterd-Recvd-Size: 4272
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:01:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=K3x1PYKs8uoQSVAJgrYEuHNsKolkNQhJU7kFblu2V0E=; b=Q4kYVlD4BsdOrsy6IouqImCJa
	EK429go2B9/u0U0rNTx0piIVJSNUZZNKe+0NnTL0/tyClAOSczTcjv8lPOh/Jl1191EgomV/E+QCt
	fXZweSdGiLk2tu0PlQ6YAclkOboKULH7q/G9RFXqGAG2y02Vyz7I/HewOST1XjMjEAPnj2Xj5wPBn
	P0UnkhiHqtOFg+5jJmXOixjKCxij0w6On7vgTFonz2pRsh4cgcBenze9hvRlpLT615N4KgjU7h0gj
	ix5hhX9L0wF/CnLfT19yH6JDe2LeJhnXR2hIlvANXGj9MQn7lR+l4qFTIHFKbh04DJ13zph7x77OC
	iyugOAEIA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i00wk-0000kK-7O; Tue, 20 Aug 2019 10:00:58 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id 9A03F307765;
	Tue, 20 Aug 2019 12:00:24 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id C842320CE7744; Tue, 20 Aug 2019 12:00:55 +0200 (CEST)
Date: Tue, 20 Aug 2019 12:00:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com,
	stable@vger.kernel.org, Joerg Roedel <jroedel@suse.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH] x86/mm/pti: in pti_clone_pgtable() don't increase addr
 by PUD_SIZE
Message-ID: <20190820100055.GI2332@hirez.programming.kicks-ass.net>
References: <20190820075128.2912224-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820075128.2912224-1-songliubraving@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 12:51:28AM -0700, Song Liu wrote:
> pti_clone_pgtable() increases addr by PUD_SIZE for pud_none(*pud) case.
> This is not accurate because addr may not be PUD_SIZE aligned.
> 
> In our x86_64 kernel, pti_clone_pgtable() fails to clone 7 PMDs because
> of this issuse, including PMD for the irq entry table. For a memcache
> like workload, this introduces about 4.5x more iTLB-load and about 2.5x
> more iTLB-load-misses on a Skylake CPU.
> 
> This patch fixes this issue by adding PMD_SIZE to addr for pud_none()
> case.

> diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
> index b196524759ec..5a67c3015f59 100644
> --- a/arch/x86/mm/pti.c
> +++ b/arch/x86/mm/pti.c
> @@ -330,7 +330,7 @@ pti_clone_pgtable(unsigned long start, unsigned long end,
>  
>  		pud = pud_offset(p4d, addr);
>  		if (pud_none(*pud)) {
> -			addr += PUD_SIZE;
> +			addr += PMD_SIZE;
>  			continue;
>  		}

I'm thinking you're right in that there's a bug here, but I'm also
thinking your patch is both incomplete and broken.

What that code wants to do is skip to the end of the pud, a pmd_size
increase will not do that. And right below this, there's a second
instance of this exact pattern.

Did I get the below right?

---
diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index b196524759ec..32b20b3cb227 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -330,12 +330,14 @@ pti_clone_pgtable(unsigned long start, unsigned long end,
 
 		pud = pud_offset(p4d, addr);
 		if (pud_none(*pud)) {
+			addr &= PUD_MASK;
 			addr += PUD_SIZE;
 			continue;
 		}
 
 		pmd = pmd_offset(pud, addr);
 		if (pmd_none(*pmd)) {
+			addr &= PMD_MASK;
 			addr += PMD_SIZE;
 			continue;
 		}

