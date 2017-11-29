Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2EFC6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:51:50 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id g98so1484294otg.11
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:51:50 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 34si470551otp.245.2017.11.29.02.51.49
        for <linux-mm@kvack.org>;
        Wed, 29 Nov 2017 02:51:49 -0800 (PST)
Date: Wed, 29 Nov 2017 10:51:51 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] mm: make faultaround produce old ptes
Message-ID: <20171129105151.GA10179@arm.com>
References: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
 <CAADWXX8FmAs1qB9=fsWZjt8xTEnGOAMS=eCHnuDLJrZiX6x=7w@mail.gmail.com>
 <f09cd880-f647-7dc8-2ca9-67dab411c6c3@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f09cd880-f647-7dc8-2ca9-67dab411c6c3@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, jack@suse.cz, minchan@kernel.org, catalin.marinas@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de

On Wed, Nov 29, 2017 at 11:35:28AM +0530, Vinayak Menon wrote:
> On 11/29/2017 1:15 AM, Linus Torvalds wrote:
> > On Mon, Nov 27, 2017 at 9:07 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
> >> Making the faultaround ptes old results in a unixbench regression for some
> >> architectures [3][4]. But on some architectures it is not found to cause
> >> any regression. So by default produce young ptes and provide an option for
> >> architectures to make the ptes old.
> > Ugh. This hidden random behavior difference annoys me.
> >
> > It should also be better documented in the code if we end up doing it.
> Okay.
> > The reason x86 seems to prefer young pte's is simply that a TLB lookup
> > of an old entry basically causes a micro-fault that then sets the
> > accessed bit (using a locked cycle) and then a restart.
> >
> > Those microfaults are not visible to software, but they are pretty
> > expensive in hardware, probably because they basically serialize
> > execution as if a real page fault had happened.
> >
> > HOWEVER - and this is the part that annoys me most about the hidden
> > behavior - I suspect it ends up being very dependent on
> > microarchitectural details in addition to the actual load. So it might
> > be more true on some cores than others, and it might be very
> > load-dependent. So hiding it as some architectural helper function
> > really feels wrong to me. It would likely be better off as a real
> > flag, and then maybe we could make the default behavior be set by
> > architecture (or even dynamically by the architecture bootup code if
> > it turns out to be enough of an issue).
> >
> > And I'm actually somewhat suspicious of your claim that it's not
> > noticeable on arm64. It's entirely possible that the serialization
> > cost of the hardware access flag is much lower, but I thought that in
> > virtualization you actually end up taking a SW fault, which in turn
> > would be much more expensive. In fact, I don't even find that
> > "Hardware Accessed" bit in my armv8 docs at all, so I'm guessing it's
> > new to 8.1? So this is very much not about architectures at all, but
> > about small details in microarchitectural behavior.
> The experiments were done on v8.2 hardware with CONFIG_ARM64_HW_AFDBM enabled.
> I have tried with CONFIG_ARM64_HW_AFDBM "disabled", and the unixbench score drops down,
> probably due to the SW faults.

Sure, but I think the point is that just because a CPU implements hardware
access/dirty management (DBM -- added in 8.1), it doesn't mean it's going
to be efficient on all implementations, and so having this keyed off the
architecture isn't the right thing to do.

If we had a flag, as suggested, then we could set that by default on CPUs
that implement hardware DBM and clear it on a case-by-case basis if
implementations pop up where it's a performance issue, although I think
it's more likely that setting the dirty bit is the expensive one since
it's not allowed to be performed speculatively.

Linus -- if you want the latest architecture document, it's now available
here without a click-through:

https://developer.arm.com/products/architecture/a-profile/docs/ddi0487/latest/arm-architecture-reference-manual-armv8-for-armv8-a-architecture-profile

p2109 has stuff about DBM. It is also available at Stage-2, but nobody's
done the KVM work yet by the looks of it.

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
