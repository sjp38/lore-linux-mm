Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20080108105227.GA10546@flint.arm.linux.org.uk>
References: <20071221104701.GE28484@wotan.suse.de>
	 <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com>
	 <20080107044355.GA11222@wotan.suse.de>
	 <20080107103028.GA9325@flint.arm.linux.org.uk>
	 <6934efce0801071049u546005e7t7da4311cc0611ccd@mail.gmail.com>
	 <20080107194543.GA2788@flint.arm.linux.org.uk>
	 <1199787075.17809.10.camel@pc1117.cambridge.arm.com>
	 <20080108105227.GA10546@flint.arm.linux.org.uk>
Content-Type: text/plain
Date: Tue, 08 Jan 2008 13:54:15 +0000
Message-Id: <1199800456.17809.72.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-08 at 10:52 +0000, Russell King wrote:
> On Tue, Jan 08, 2008 at 10:11:15AM +0000, Catalin Marinas wrote:
> > Can we not restrict these to a maximum of 8 base types at run-time? If
> > yes, we can only use 3 bits for encoding and also benefit from the
> > automatic remapping in later ARM CPUs. For those not familiar with ARM,
> > 8 combinations of the TEX, C, B and S (shared) bits can be specified in
> > separate registers and the pte would only use 3 bits to refer to those.
> > Even older cores would benefit from this as I think it is faster to read
> > the encoding from an array in set_pte than doing all the bit comparisons
> > to calculate the hardware pte in the current implementation.
> 
> So basically that gives us the following combinations:

I reordered them a  bit for easier commenting.

> TEXCB
> 00010 - write through mappings (selectable via kernel command line)
> 	  and also work-around for user read-only write-back mappings
> 	  on PXA2.
> 00011 - normal write back mappings
> 00111 - write back write allocate mappings

Do you need to use all of the above at the same time? We could have only
one type, "normal memory", and configure the desired TEX encoding at
boot time.

> 00000 - /dev/mem and device uncachable mappings (strongly ordered)
> 00101 - Xscale3 "shared device" work-around for strongly ordered mappings
> 01000 - non-shared device (will be required to map some devices to
> userspace)
> 	  and also Xscale3 work-around for strongly ordered mappings

I don't know the details of the Xscale3 bug but would you need all of
these encodings at run-time? Do you need both "strongly ordered" and the
workaround? We could only have the "strongly ordered" type and configure
the TEX bits at boot time to be "shared device" if the workaround is
needed.

For the last one, we could have the "non-shared device" type.

> 00001 - frame buffers

This would be "shared device" on newer CPUs.

> 00110 - PXA3 mini-cache or other "implementation defined features"
> 10111 - Xscale3 L2 cache-enabled mappings

It depends on how many of these you would need at run-time. If the base
types are "normal", "strongly ordered", "shared device", "non-shared
device", you still have 4 more left (or 3 on ARMv6 with TEX remapping
enabled since one encoding is implementation defined).

> It's unclear at present what circumstances you'd use each of the two
> Xscale3 work-around bit combinations - or indeed whether there's a
> printing error in the documentation concerning TEXCB=00101.

As I said, I don't know the details of this bug and can't comment.

> It's also unclear how to squeeze these down into a bit pattern in such
> a way that we avoid picking out bits from the Linux PTE, and recombining
> them so we can look them up in a table or whatever - especially given
> that set_pte is a fast path and extra cycles there have a VERY noticable
> impact on overall system performance.

As with the automatic remapping on ARMv6, we could use TEX[0], C and B
to for the 3 bit index in the table. For pre-ARMv6 hardware, we need a
bit of shifting and masking before looking up in the 8 32bit words table
but, for subsequent calls to set_pte, it is likely that the table would
be in cache anyway. There is also the option of choosing 3 consecutive
bits to avoid shifting on pre-ARMv6.

I agree there would be a delay on pre-ARMv6 CPUs but the impact might
not be that big since the current set_pte implementations still do
additional bit shifting/comparison for the access permissions. The
advantage is that we free 2 bits from the TEXCB encoding.

I haven't run any benchmarks and I can't say how big the impact is but,
based on some past discussions, 3-4 more cycles in set_pte might go
unnoticed because of other, bigger overheads.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
