Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20080107194543.GA2788@flint.arm.linux.org.uk>
References: <20071221104701.GE28484@wotan.suse.de>
	 <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com>
	 <20080107044355.GA11222@wotan.suse.de>
	 <20080107103028.GA9325@flint.arm.linux.org.uk>
	 <6934efce0801071049u546005e7t7da4311cc0611ccd@mail.gmail.com>
	 <20080107194543.GA2788@flint.arm.linux.org.uk>
Content-Type: text/plain
Date: Tue, 08 Jan 2008 10:11:15 +0000
Message-Id: <1199787075.17809.10.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-01-07 at 19:45 +0000, Russell King wrote:
> In old ARM CPUs, there were two bits that defined the characteristics of
> the mapping - the C and B bits (C = cacheable, B = bufferable)
> 
> Some ARMv5 (particularly Xscale-based) and all ARMv6 CPUs extend this to
> five bits and introduce "memory types" - 3 bits of TEX, and C and B.
> 
> Between these bits, it defines:
> 
> - strongly ordered
> - bufferable only *
> - device, sharable *
> - device, unsharable
> - memory, bufferable and cacheable, write through, no write allocate
> - memory, bufferable and cacheable, write back, no write allocate
> - memory, bufferable and cacheable, write back, write allocate
> - implementation defined combinations (eg, selecting "minicache")
> - and a set of 16 states to allow the policy of inner and outer levels
>   of cache to be defined (two bits per level).

Can we not restrict these to a maximum of 8 base types at run-time? If
yes, we can only use 3 bits for encoding and also benefit from the
automatic remapping in later ARM CPUs. For those not familiar with ARM,
8 combinations of the TEX, C, B and S (shared) bits can be specified in
separate registers and the pte would only use 3 bits to refer to those.
Even older cores would benefit from this as I think it is faster to read
the encoding from an array in set_pte than doing all the bit comparisons
to calculate the hardware pte in the current implementation.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
