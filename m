Date: Mon, 7 Jan 2008 01:12:10 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] i386: avoid expensive ppro ordering workaround for default 686 kernels
Message-ID: <20080107001210.GA21007@wotan.suse.de>
References: <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de> <alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org> <20080101234133.4a744329@the-village.bc.nu> <20080102110225.GA16154@wotan.suse.de> <20080102134433.6ca82011@the-village.bc.nu> <20080103041708.GB26487@wotan.suse.de> <20080103142330.111d4067@lxorguk.ukuu.org.uk> <20080103231017.GA25880@wotan.suse.de> <20080104162700.3aef1806@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080104162700.3aef1806@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 04, 2008 at 04:27:00PM +0000, Alan Cox wrote:
> > > The cost on a 586 SMP box (ie pentium) is basically nil. All cross CPU
> > > transactions are hideously slow anyway locked or not.
> > 
> > That's wrong. Firstly, spinlocks are very often retaken by the same CPU, and they
> 
> Go time it. It certainly used to be the case.

I don't understand what your point is. You bring up socket-to-socket transfers,
but we are talking about the cost of locked ops (which may or may not involve a
cacheline transfer).

For example, a spin lock + unlock (in cache) is around 40 cycles on my Core2. A
ppro style unlock makes it 70.

And it is quite common with a lot of locks for the cacheline *not* to be bouncing
(eg. scheduler runqueue locks).

 
> > On 586 SMP systems, didn't lock ops actually go out on the bus, and hence are much
> > more expensive than they are today (although today they are still one or two orders
> > of magnitude more expensive than regular memory ops).
> 
> All cross CPU cache stuff goes that way, not that may P5 SMP boxes are
> running today except in Mr Bottomley's residence.
> 
> > And if you build a kernel which is to support 686, PII, and later, you don't want
> > them by default either, most probably.
> 
> I want a kernel for VIA C3 or later which happens to include K6 (still
> common), PII+ and maybe not PPro.

I want a kernel for all those and also ppros, but I'm not willing to hammer
everyone else to work around some rare errata. There are probably quite fewer
SMP ppros than UP ones too.

You're just skirting the whole issue by saying you don't want to support ppro
at all. The issue is having a kernel that supports a wide range of CPUs
including ppro. *You* may not want that. Others may.
 

> So your patch should go in the bitbucket by the sound of it and Adrian's
> get merged.

Adrian's patch IMO should get merged, sure (although last time it came up, it
got rejected for some maybe not completely valid reasons). But Adrian's patch
does not attack the problem which mine does. If you select PPro + PII + PIII +
etc..., then you will still have SMP ppro errata workarounds compiled in. You
need another option specifically asking whether you want them or not. Ie. my
patch.

What is your exact objection to making this configurable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
