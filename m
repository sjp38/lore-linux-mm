Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E3C436B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 10:41:47 -0500 (EST)
Date: Wed, 3 Feb 2010 09:41:29 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC] slub: ARCH_SLAB_MINALIGN defaults to 8 on x86_32. is this
 too big?
In-Reply-To: <1265206946.2118.57.camel@localhost>
Message-ID: <alpine.DEB.2.00.1002030932480.5671@router.home>
References: <1265206946.2118.57.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Richard Kennedy wrote:

> slub.c sets the default value of ARCH_SLAB_MINALIGN to sizeof(unsigned
> long long) if the architecture didn't already override it.
>
> And as x86_32 doesn't set a value this means that slab objects get
> aligned to 8 bytes, potentially wasting 4 bytes per object. Slub forces
> objects to be aligned to sizeof(void *) anyway, but I don't see that
> there is any need for it to be 8 on 32bits.

Note that 64 bit entities may  exist even under 32 bit (llong) that need
to be aligned properly.

struct buffer_head contains a sector_t which is 64 bit so you should align
to an 8 byte boundary.

> I'm working on a patch to pack more buffer_heads into each kmem_cache
> slab page.
> On 32 bits the structure size is 52 bytes and with the alignment applied
> I end up with a slab of 73 x 56 byte objects. However, if the minimum
> alignment was sizeof(void *) then I'd get 78 x 52 byte objects. So there
> is quite a memory saving to be had in changing this.

SLUB is not restricted to order 0 pages and can use order 1 or 2 pages as
long as this reduces the memory footprint (byte wastage in a slab page is
reduced) and as long as the kernel has contiguous memory available. It
will use order 0 when memory is fragmented.

> Can I define a ARCH_SLAB_MINALIGN in x86_64 to sizeof(void *) ?
> or would it be ok to change the default in slub.c to sizeof(void *) ?
>
> Or am I missing something ?

I'd say leave it alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
