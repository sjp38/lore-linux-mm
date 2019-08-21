Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7FBBC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:47:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7511122CE3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:47:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7511122CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1302C6B0289; Wed, 21 Aug 2019 14:47:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 109416B028B; Wed, 21 Aug 2019 14:47:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01E1F6B028C; Wed, 21 Aug 2019 14:46:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0007.hostedemail.com [216.40.44.7])
	by kanga.kvack.org (Postfix) with ESMTP id D49216B0289
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:46:59 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7DD438248AA7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:46:59 +0000 (UTC)
X-FDA: 75847316958.30.chain40_1f971caa6f807
X-HE-Tag: chain40_1f971caa6f807
X-Filterd-Recvd-Size: 6227
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:46:56 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B8135344;
	Wed, 21 Aug 2019 11:46:55 -0700 (PDT)
Received: from arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 12BF53F706;
	Wed, 21 Aug 2019 11:46:53 -0700 (PDT)
Date: Wed, 21 Aug 2019 19:46:51 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Will Deacon <will@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org,
	Dave Hansen <dave.hansen@intel.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>, linux-doc@vger.kernel.org,
	Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH v9 3/3] arm64: Relax
 Documentation/arm64/tagged-pointers.rst
Message-ID: <20190821184649.GD27757@arm.com>
References: <20190821164730.47450-1-catalin.marinas@arm.com>
 <20190821164730.47450-4-catalin.marinas@arm.com>
 <20190821173352.yqfgaozi7nfhcofg@willie-the-truck>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821173352.yqfgaozi7nfhcofg@willie-the-truck>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 06:33:53PM +0100, Will Deacon wrote:
> On Wed, Aug 21, 2019 at 05:47:30PM +0100, Catalin Marinas wrote:
> > From: Vincenzo Frascino <vincenzo.frascino@arm.com>
> > 
> > On AArch64 the TCR_EL1.TBI0 bit is set by default, allowing userspace
> > (EL0) to perform memory accesses through 64-bit pointers with a non-zero
> > top byte. However, such pointers were not allowed at the user-kernel
> > syscall ABI boundary.
> > 
> > With the Tagged Address ABI patchset, it is now possible to pass tagged
> > pointers to the syscalls. Relax the requirements described in
> > tagged-pointers.rst to be compliant with the behaviours guaranteed by
> > the AArch64 Tagged Address ABI.
> > 
> > Cc: Will Deacon <will.deacon@arm.com>
> > Cc: Szabolcs Nagy <szabolcs.nagy@arm.com>
> > Cc: Kevin Brodsky <kevin.brodsky@arm.com>
> > Acked-by: Andrey Konovalov <andreyknvl@google.com>
> > Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> > Co-developed-by: Catalin Marinas <catalin.marinas@arm.com>
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> > ---
> >  Documentation/arm64/tagged-pointers.rst | 23 ++++++++++++++++-------
> >  1 file changed, 16 insertions(+), 7 deletions(-)
> > 
> > diff --git a/Documentation/arm64/tagged-pointers.rst b/Documentation/arm64/tagged-pointers.rst
> > index 2acdec3ebbeb..04f2ba9b779e 100644
> > --- a/Documentation/arm64/tagged-pointers.rst
> > +++ b/Documentation/arm64/tagged-pointers.rst
> > @@ -20,7 +20,9 @@ Passing tagged addresses to the kernel
> >  --------------------------------------
> >  
> >  All interpretation of userspace memory addresses by the kernel assumes
> > -an address tag of 0x00.
> > +an address tag of 0x00, unless the application enables the AArch64
> > +Tagged Address ABI explicitly
> > +(Documentation/arm64/tagged-address-abi.rst).
> >  
> >  This includes, but is not limited to, addresses found in:
> >  
> > @@ -33,13 +35,15 @@ This includes, but is not limited to, addresses found in:
> >   - the frame pointer (x29) and frame records, e.g. when interpreting
> >     them to generate a backtrace or call graph.
> >  
> > -Using non-zero address tags in any of these locations may result in an
> > -error code being returned, a (fatal) signal being raised, or other modes
> > -of failure.
> > +Using non-zero address tags in any of these locations when the
> > +userspace application did not enable the AArch64 Tagged Address ABI may
> > +result in an error code being returned, a (fatal) signal being raised,
> > +or other modes of failure.
> >  
> > -For these reasons, passing non-zero address tags to the kernel via
> > -system calls is forbidden, and using a non-zero address tag for sp is
> > -strongly discouraged.
> > +For these reasons, when the AArch64 Tagged Address ABI is disabled,
> > +passing non-zero address tags to the kernel via system calls is
> > +forbidden, and using a non-zero address tag for sp is strongly
> > +discouraged.
> >  
> >  Programs maintaining a frame pointer and frame records that use non-zero
> >  address tags may suffer impaired or inaccurate debug and profiling
> > @@ -59,6 +63,11 @@ be preserved.
> >  The architecture prevents the use of a tagged PC, so the upper byte will
> >  be set to a sign-extension of bit 55 on exception return.
> >  
> > +This behaviour is maintained when the AArch64 Tagged Address ABI is
> > +enabled. In addition, with the exceptions above, the kernel will
> > +preserve any non-zero tags passed by the user via syscalls and stored in
> > +kernel data structures (e.g. ``set_robust_list()``, ``sigaltstack()``).

sigaltstack() is interesting, since we don't support tagged stacks.

Do we keep the ss_sp tag in the kernel, but squash it when delivering
a signal to the alternate stack?

(I can't remember whether this would be compatible with the
architectural tag checking semantics...)

> Hmm. I can see the need to provide this guarantee for things like
> set_robust_list(), but the problem is that the statement above is too broad
> and isn't strictly true: for example, mmap() doesn't propagate the tag of
> its address parameter into the VMA.
> 
> So I think we need to nail this down a bit more, but I'm having a really
> hard time coming up with some wording :(

Time for some creative vagueness?

We can write a statement of our overall intent, along with examples of
a few cases where the tag should and should not be expected to emerge
intact.

There is no foolproof rule, unless we can rewrite history...

Cheers
---Dave

