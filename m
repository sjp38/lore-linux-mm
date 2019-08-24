Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12E6EC3A5A2
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 00:59:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E8021726
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 00:59:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E8021726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 600F36B04C6; Fri, 23 Aug 2019 20:59:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B00B6B04C7; Fri, 23 Aug 2019 20:59:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C6486B04C8; Fri, 23 Aug 2019 20:59:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id 25A2D6B04C6
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 20:59:36 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C6567688F
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 00:59:35 +0000 (UTC)
X-FDA: 75855513510.07.eye34_369f41361c122
X-HE-Tag: eye34_369f41361c122
X-Filterd-Recvd-Size: 5248
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 00:59:35 +0000 (UTC)
Received: from p5de0b6c5.dip0.t-ipconnect.de ([93.224.182.197] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1i1KOw-0003M2-0x; Sat, 24 Aug 2019 02:59:30 +0200
Date: Sat, 24 Aug 2019 02:59:28 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Song Liu <songliubraving@fb.com>
cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    Linux MM <linux-mm@kvack.org>, Kernel Team <Kernel-team@fb.com>, 
    "stable@vger.kernel.org" <stable@vger.kernel.org>, 
    Joerg Roedel <jroedel@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Rik van Riel <riel@surriel.com>
Subject: Re: [PATCH v2] x86/mm/pti: in pti_clone_pgtable(), increase addr
 properly
In-Reply-To: <alpine.DEB.2.21.1908211210160.2223@nanos.tec.linutronix.de>
Message-ID: <alpine.DEB.2.21.1908240225320.1939@nanos.tec.linutronix.de>
References: <20190820202314.1083149-1-songliubraving@fb.com> <2CB1A3FD-33EF-4D8B-B74A-CF35F9722993@fb.com> <alpine.DEB.2.21.1908211210160.2223@nanos.tec.linutronix.de>
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

On Wed, 21 Aug 2019, Thomas Gleixner wrote:
> On Wed, 21 Aug 2019, Song Liu wrote:
> > > On Aug 20, 2019, at 1:23 PM, Song Liu <songliubraving@fb.com> wrote:
> > > 
> > > Before 32-bit support, pti_clone_pmds() always adds PMD_SIZE to addr.
> > > This behavior changes after the 32-bit support:  pti_clone_pgtable()
> > > increases addr by PUD_SIZE for pud_none(*pud) case, and increases addr by
> > > PMD_SIZE for pmd_none(*pmd) case. However, this is not accurate because
> > > addr may not be PUD_SIZE/PMD_SIZE aligned.
> > > 
> > > Fix this issue by properly rounding up addr to next PUD_SIZE/PMD_SIZE
> > > in these two cases.
> > 
> > After poking around more, I found the following doesn't really make 
> > sense. 
> 
> I'm glad you figured that out yourself. Was about to write up something to
> that effect.
> 
> Still interesting questions remain:
> 
>   1) How did you end up feeding an unaligned address into that which points
>      to a 0 PUD?
> 
>   2) Is this related to Facebook specific changes and unlikely to affect any
>      regular kernel? I can't come up with a way to trigger that in mainline
> 
>   3) As this is a user page table and the missing mapping is related to
>      mappings required by PTI, how is the machine going in/out of user
>      space in the first place? Or did I just trip over what you called
>      nonsense?

And just because this ended in silence I looked at it myself after Peter
told me that this was on a kernel with PTI disabled. Aside of that my built
in distrust for debug war stories combined with fairy tale changelogs
triggered my curiousity anyway.

So that cannot be a kernel with PTI disabled compile time because in that
case the functions are not available, unless it's FB hackery which I do not
care about.

So the only way this can be reached is when PTI is configured but disabled
at boot time via pti=off or nopti.

For some silly reason and that goes back to before the 32bit support and
Joern did not notice either when he introduced pti_finalize() this results
in the following functions being called unconditionallY:

     pti_clone_entry_text()
     pti_clone_kernel_text()

pti_clone_kernel_text() was called unconditionally before the 32bit support
already and the only reason why it did not have any effect in that
situation is that it invokes pti_kernel_image_global_ok() and that returns
false when PTI is disabled on the kernel command line. Oh well. It
obviously never checked whether X86_FEATURE_PTI was disabled or enabled in
the first place.

Now 32bit moved that around into pti_finalize() and added the call to
pti_clone_entry_text() which just runs unconditionally.

Now there is still the interesting question why this matters. The to be
cloned page table entries are mapped and the start address even if
unaligned never points to something unmapped. The unmapped case only covers
holes and holes are obviously aligned at the upper levels even if the
address of the hole is unaligned.

So colour me still confused what's wrong there but the proper fix is the
trivial:

--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -666,6 +666,8 @@ void __init pti_init(void)
  */
 void pti_finalize(void)
 {
+	if (!boot_cpu_has(X86_FEATURE_PTI))
+		return;
 	/*
 	 * We need to clone everything (again) that maps parts of the
 	 * kernel image.

Hmm?

I'm going to look whether that makes any difference in the page tables
tomorrow with brain awake, but I wanted to share this before the .us
vanishes into the weekend :)

Thanks,

	tglx


