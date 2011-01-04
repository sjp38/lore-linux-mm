Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A433A6B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 18:12:51 -0500 (EST)
Date: Tue, 4 Jan 2011 23:12:21 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
Message-ID: <20110104231221.GA12222@shareable.org>
References: <cover.1292443200.git.m.nazarewicz@samsung.com> <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com> <20101223100642.GD3636@n2100.arm.linux.org.uk> <87k4j0ehdl.fsf@erwin.mina86.com> <20101223135120.GL3636@n2100.arm.linux.org.uk> <4D1357D5.9000507@samsung.com> <20101223142053.GN3636@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101223142053.GN3636@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Tomasz Fujak <t.fujak@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Kyungmin Park <kmpark@infradead.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ankita Garg <ankita@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Russell King - ARM Linux wrote:
> I'll give you another solution to the problem - lobby ARM Ltd to have
> this restriction lifted from the architecture specification, which
> will probably result in the speculative prefetching also having to be
> removed.

I don't know if there was lobbying involved, but the way some barriers
on x86 turned out to be unnecessary, on both Intel and AMD, after
years of specs which abstractly implied they might be necessary....  I
guess someone realised the relaxed specs weren't providing a benefit
at the hardware level.

Perhaps it is possible to draw this to ARM's attention as a rather
serious performance-damaging thing, so they might tighten the rules in
favour of common sense, at least for the majority of devices?

Off the top of my head (and I really don't know much about the
internals of an ARM), hardware that avoided speculation where there
was no entry already in the TLB for the address... that would be
workable, as page/range TLB flushes would be enough to protect
pages from access.

With regard to specific chips (i.e. current ones, while lobbying to
tighten the rules for future ones).  Is there a control register on
the chips which are known to have this annoying issue, to turn off the
problematic cache behaviour (permanently while Linux runs), or some
set of memory attributes that produces that effect?  (Obviously there
is: Turn off all caching, but is there a weaker and equally effective
one on current hardware with the problem?)

It might be there simply _isn't_ any solution that satisfies the
generality of ARM spec, while satisfying the engineering requirements
of particular media player chips on which the CMA+DMA may be perfectly
safe.  That would be unpleasant but hardly the first time some feature
was not usable on some chips and essential on some others.

Take, for example, those (now old) ARMs that mishandle SWP so it can't
be used.  We still use SWP in kernels, and indeed userspace, which
will break if run on those particular chips, but that's ok - it's an
understood limitation.

Russell, I think the repeated attempts to propose the same thing,
which you keep rejecting (rightly), isn't because they're not
listening, but because you haven't got a better solution - other than
scrap the hardware :-)  Their code might actually be 100% reliable with
the chips they use in those products, and it might be the _only_
solution which works on those, thus solving a real problem.

What's the right thing to do in that case?  Maintain a fork out of
tree, or some Kconfig animal that says you can't select this ARM
subarch and that memory facility in the same kernel because they are
technically incompatible - but at least everyone can see the code, and
know which chip families to avoid for certain applications?

Here is a hint of an idea for a way forward:

    - An API that everyone can use (in drivers etc.), that behaves the
      same for everyone, except that:

    - On some chips (ARMv7...) some functions requires a large
      up-front memory reservation at boot time, (but that's ok because
      you probably have gobs of RAM with it anyway).

    - On other chips (<= ARMv6?) it is safe to reduce the up-front
      reservation to less, maybe zero.  (Better for smaller memories).

    - Maybe it even makes sense for drivers using the API to request,
      at boot time, "_if_ you need early reservation, then _this_ is
      how much I will need maximum".  The values can potentially
      dynamic anti-fragmantation allocators too.  (I've done a bit of
      research on this - a sort of "semi-reservation" where you don't
      keep it free up front, but you limit how its used and grouped in
      a precise way, to make sure other uses are sufficiently
      reclaimable to satisfy the call when it comes.)

    - Didn't reserve enough in advance for the architectural
      constraints - get NULL back.  That's what allocators always do.
      That's what /proc/cmdline's options have a long history helping
      with - finding the setting which works on your kit.  People are
      already used to a bit of fiddly tuning (and random crashes ;-)
      with these media application sorts of things.

Presumably the problem will ease off with IOMMUs and/or sensible SG
(and/or sensible architectural constraints) becoming ubiquitous eventually.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
