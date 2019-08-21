Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6C21C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 10:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 825B322D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 10:17:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 825B322D6D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EB4C6B02B5; Wed, 21 Aug 2019 06:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17F166B02B6; Wed, 21 Aug 2019 06:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08AE86B02B7; Wed, 21 Aug 2019 06:17:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0089.hostedemail.com [216.40.44.89])
	by kanga.kvack.org (Postfix) with ESMTP id D63BA6B02B5
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 06:17:05 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 699AB181AC9CC
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:17:05 +0000 (UTC)
X-FDA: 75846032010.28.alarm84_5af36a5f3b12d
X-HE-Tag: alarm84_5af36a5f3b12d
X-Filterd-Recvd-Size: 2836
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:17:04 +0000 (UTC)
Received: from p5de0b6c5.dip0.t-ipconnect.de ([93.224.182.197] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1i0Nfp-00012g-VP; Wed, 21 Aug 2019 12:17:02 +0200
Date: Wed, 21 Aug 2019 12:17:00 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Song Liu <songliubraving@fb.com>
cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    Linux MM <linux-mm@kvack.org>, Kernel Team <Kernel-team@fb.com>, 
    "stable@vger.kernel.org" <stable@vger.kernel.org>, 
    Joerg Roedel <jroedel@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2] x86/mm/pti: in pti_clone_pgtable(), increase addr
 properly
In-Reply-To: <2CB1A3FD-33EF-4D8B-B74A-CF35F9722993@fb.com>
Message-ID: <alpine.DEB.2.21.1908211210160.2223@nanos.tec.linutronix.de>
References: <20190820202314.1083149-1-songliubraving@fb.com> <2CB1A3FD-33EF-4D8B-B74A-CF35F9722993@fb.com>
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

On Wed, 21 Aug 2019, Song Liu wrote:
> > On Aug 20, 2019, at 1:23 PM, Song Liu <songliubraving@fb.com> wrote:
> > 
> > Before 32-bit support, pti_clone_pmds() always adds PMD_SIZE to addr.
> > This behavior changes after the 32-bit support:  pti_clone_pgtable()
> > increases addr by PUD_SIZE for pud_none(*pud) case, and increases addr by
> > PMD_SIZE for pmd_none(*pmd) case. However, this is not accurate because
> > addr may not be PUD_SIZE/PMD_SIZE aligned.
> > 
> > Fix this issue by properly rounding up addr to next PUD_SIZE/PMD_SIZE
> > in these two cases.
> 
> After poking around more, I found the following doesn't really make 
> sense. 

I'm glad you figured that out yourself. Was about to write up something to
that effect.

Still interesting questions remain:

  1) How did you end up feeding an unaligned address into that which points
     to a 0 PUD?

  2) Is this related to Facebook specific changes and unlikely to affect any
     regular kernel? I can't come up with a way to trigger that in mainline

  3) As this is a user page table and the missing mapping is related to
     mappings required by PTI, how is the machine going in/out of user
     space in the first place? Or did I just trip over what you called
     nonsense?

Thanks,

	tglx




