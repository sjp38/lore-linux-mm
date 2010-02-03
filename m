Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B6DC66B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 09:22:30 -0500 (EST)
Subject: [RFC] slub: ARCH_SLAB_MINALIGN defaults to 8 on x86_32. is this
 too big?
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 03 Feb 2010 14:22:26 +0000
Message-ID: <1265206946.2118.57.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, penberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi all,

slub.c sets the default value of ARCH_SLAB_MINALIGN to sizeof(unsigned
long long) if the architecture didn't already override it.

And as x86_32 doesn't set a value this means that slab objects get
aligned to 8 bytes, potentially wasting 4 bytes per object. Slub forces
objects to be aligned to sizeof(void *) anyway, but I don't see that
there is any need for it to be 8 on 32bits.

I'm working on a patch to pack more buffer_heads into each kmem_cache
slab page.
On 32 bits the structure size is 52 bytes and with the alignment applied
I end up with a slab of 73 x 56 byte objects. However, if the minimum
alignment was sizeof(void *) then I'd get 78 x 52 byte objects. So there
is quite a memory saving to be had in changing this.

Can I define a ARCH_SLAB_MINALIGN in x86_64 to sizeof(void *) ? 
or would it be ok to change the default in slub.c to sizeof(void *) ?

Or am I missing something ?

regards
Richard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
