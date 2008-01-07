Date: Mon, 7 Jan 2008 19:45:43 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
Message-ID: <20080107194543.GA2788@flint.arm.linux.org.uk>
References: <20071221104701.GE28484@wotan.suse.de> <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com> <20080107044355.GA11222@wotan.suse.de> <20080107103028.GA9325@flint.arm.linux.org.uk> <6934efce0801071049u546005e7t7da4311cc0611ccd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6934efce0801071049u546005e7t7da4311cc0611ccd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 07, 2008 at 10:49:57AM -0800, Jared Hulbert wrote:
> > ARM is going to have to use the three remaining bits we have in the PTE
> > to store the memory type to resolve bugs on later platforms.  Once they're
> > used, ARM will no longer have any room for any further PTE expansion.
> 
> Russell,
> 
> Can you explain this a little more.

In old ARM CPUs, there were two bits that defined the characteristics of
the mapping - the C and B bits (C = cacheable, B = bufferable)

Some ARMv5 (particularly Xscale-based) and all ARMv6 CPUs extend this to
five bits and introduce "memory types" - 3 bits of TEX, and C and B.

Between these bits, it defines:

- strongly ordered
- bufferable only *
- device, sharable *
- device, unsharable
- memory, bufferable and cacheable, write through, no write allocate
- memory, bufferable and cacheable, write back, no write allocate
- memory, bufferable and cacheable, write back, write allocate
- implementation defined combinations (eg, selecting "minicache")
- and a set of 16 states to allow the policy of inner and outer levels
  of cache to be defined (two bits per level).

Of course, not all CPUs support all the above - for example, if write
back caches aren't supported then the result is a write through cache.
The write allocation setting is a "hint" - if the hardware doesn't
support write allocate, it'll just be read allocate.

There are now CPUs out there where the old combinations (TEX=0) are
broken - and causes nasty effects like writes to bypass the write
protection under certain circumstances, or the data cache to hang if
you're using a strongly ordered mapping.

The "workaround" for these is to avoid the problematical mapping mode -
which is CPU specific, and depends on knowledge of what's being mapped.
For instance, you might use a sharable device mapping instead of
strongly ordered for devices.  However, you might want to use an
outer cacheable but inner uncacheable mapping instead of strongly
ordered for memory.

Now, couple this with the fix for shared mmaps - where we normally turn
a cacheable mapping into a bufferable mapping, or if the write buffer has
visible side effects, a strongly ordered mapping, or if strongly ordered
mappings are buggy... etc.

Also note that there are devices (typically "unshared" devices) on some
ARM CPUs that you can only access if you set the TEX bits correctly.

Currently, Linux is able to setup mappings in kernel space to cover
any combination of settings.  However, userspace is much more limited
because we don't carry the additional bits around in the Linux version
of the PTE - and as such shared mmaps on some systems can end up locking
the CPU.

A few attempts have been made at solving these without using the
additional PTE bits, but they've been less that robust.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
