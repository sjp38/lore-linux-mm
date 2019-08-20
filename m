Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30FA0C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:39:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F218B2087E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:39:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F218B2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E5986B026E; Tue, 20 Aug 2019 09:39:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 895776B026F; Tue, 20 Aug 2019 09:39:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 783AF6B0270; Tue, 20 Aug 2019 09:39:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id 567006B026E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:39:40 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 034508248ABF
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:39:40 +0000 (UTC)
X-FDA: 75842913720.06.bulb46_373b1679a9500
X-HE-Tag: bulb46_373b1679a9500
X-Filterd-Recvd-Size: 2588
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:39:39 +0000 (UTC)
Received: from p5de0b6c5.dip0.t-ipconnect.de ([93.224.182.197] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1i04MI-0006WU-TW; Tue, 20 Aug 2019 15:39:35 +0200
Date: Tue, 20 Aug 2019 15:39:34 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Song Liu <songliubraving@fb.com>
cc: Peter Zijlstra <peterz@infradead.org>, 
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>, 
    Kernel Team <Kernel-team@fb.com>, 
    "stable@vger.kernel.org" <stable@vger.kernel.org>, 
    Joerg Roedel <jroedel@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH] x86/mm/pti: in pti_clone_pgtable() don't increase addr
 by PUD_SIZE
In-Reply-To: <44EA504D-2388-49EF-A807-B9712903B146@fb.com>
Message-ID: <alpine.DEB.2.21.1908201539200.2223@nanos.tec.linutronix.de>
References: <20190820075128.2912224-1-songliubraving@fb.com> <20190820100055.GI2332@hirez.programming.kicks-ass.net> <alpine.DEB.2.21.1908201315450.2223@nanos.tec.linutronix.de> <44EA504D-2388-49EF-A807-B9712903B146@fb.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Aug 2019, Song Liu wrote:
> > On Aug 20, 2019, at 4:16 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > 
> > On Tue, 20 Aug 2019, Peter Zijlstra wrote:
> >> What that code wants to do is skip to the end of the pud, a pmd_size
> >> increase will not do that. And right below this, there's a second
> >> instance of this exact pattern.
> >> 
> >> Did I get the below right?
> >> 
> >> ---
> >> diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
> >> index b196524759ec..32b20b3cb227 100644
> >> --- a/arch/x86/mm/pti.c
> >> +++ b/arch/x86/mm/pti.c
> >> @@ -330,12 +330,14 @@ pti_clone_pgtable(unsigned long start, unsigned long end,
> >> 
> >> 		pud = pud_offset(p4d, addr);
> >> 		if (pud_none(*pud)) {
> >> +			addr &= PUD_MASK;
> >> 			addr += PUD_SIZE;
> > 
> > 			round_up(addr, PUD_SIZE);
> 
> I guess we need "round_up(addr + PMD_SIZE, PUD_SIZE)". 

Right you are.

