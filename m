Date: Tue, 8 Jan 2008 10:52:27 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
Message-ID: <20080108105227.GA10546@flint.arm.linux.org.uk>
References: <20071221104701.GE28484@wotan.suse.de> <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com> <20080107044355.GA11222@wotan.suse.de> <20080107103028.GA9325@flint.arm.linux.org.uk> <6934efce0801071049u546005e7t7da4311cc0611ccd@mail.gmail.com> <20080107194543.GA2788@flint.arm.linux.org.uk> <1199787075.17809.10.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1199787075.17809.10.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 08, 2008 at 10:11:15AM +0000, Catalin Marinas wrote:
> On Mon, 2008-01-07 at 19:45 +0000, Russell King wrote:
> > In old ARM CPUs, there were two bits that defined the characteristics of
> > the mapping - the C and B bits (C = cacheable, B = bufferable)
> > 
> > Some ARMv5 (particularly Xscale-based) and all ARMv6 CPUs extend this to
> > five bits and introduce "memory types" - 3 bits of TEX, and C and B.
> > 
> > Between these bits, it defines:
> > 
> > - strongly ordered
> > - bufferable only *
> > - device, sharable *
> > - device, unsharable
> > - memory, bufferable and cacheable, write through, no write allocate
> > - memory, bufferable and cacheable, write back, no write allocate
> > - memory, bufferable and cacheable, write back, write allocate
> > - implementation defined combinations (eg, selecting "minicache")
> > - and a set of 16 states to allow the policy of inner and outer levels
> >   of cache to be defined (two bits per level).
> 
> Can we not restrict these to a maximum of 8 base types at run-time? If
> yes, we can only use 3 bits for encoding and also benefit from the
> automatic remapping in later ARM CPUs. For those not familiar with ARM,
> 8 combinations of the TEX, C, B and S (shared) bits can be specified in
> separate registers and the pte would only use 3 bits to refer to those.
> Even older cores would benefit from this as I think it is faster to read
> the encoding from an array in set_pte than doing all the bit comparisons
> to calculate the hardware pte in the current implementation.

So basically that gives us the following combinations:

TEXCB
00000 - /dev/mem and device uncachable mappings (strongly ordered)
00001 - frame buffers
00010 - write through mappings (selectable via kernel command line)
	  and also work-around for user read-only write-back mappings
	  on PXA2.
00011 - normal write back mappings
00101 - Xscale3 "shared device" work-around for strongly ordered mappings
00110 - PXA3 mini-cache or other "implementation defined features"
00111 - write back write allocate mappings
01000 - non-shared device (will be required to map some devices to userspace)
	  and also Xscale3 work-around for strongly ordered mappings
10111 - Xscale3 L2 cache-enabled mappings

It's unclear at present what circumstances you'd use each of the two
Xscale3 work-around bit combinations - or indeed whether there's a
printing error in the documentation concerning TEXCB=00101.

It's also unclear how to squeeze these down into a bit pattern in such
a way that we avoid picking out bits from the Linux PTE, and recombining
them so we can look them up in a table or whatever - especially given
that set_pte is a fast path and extra cycles there have a VERY noticable
impact on overall system performance.

However, until we get around to sorting out the implementation of the
Xscale3 strongly ordered work-around which seems to be the highest
priority (and hardest to resolve) I don't think there's much more to
discuss; we don't have a clear way ahead on these issues at the moment.
All we current have is the errata entry, and we know people are seeing
data corruption on Xscale3 platforms.

And no, I don't think we can keep it contained within the Xscale3 support
file - the set_pte method isn't passed sufficient information for that.
Conversely, setting the TEX bits behind set_pte's back by using set_pte_ext
results in loss of that information when the page is aged - again resulting
in data corruption.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
