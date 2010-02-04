Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 972816B004D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 11:43:15 -0500 (EST)
Date: Thu, 4 Feb 2010 10:42:53 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC] slub: ARCH_SLAB_MINALIGN defaults to 8 on x86_32. is this
 too big?
In-Reply-To: <1265217903.2118.86.camel@localhost>
Message-ID: <alpine.DEB.2.00.1002041019300.28165@router.home>
References: <1265206946.2118.57.camel@localhost>  <alpine.DEB.2.00.1002030932480.5671@router.home> <1265217903.2118.86.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Richard Kennedy wrote:

> gives me this output :-
> 32 bit : size = 12 , offset of l = 4
> 64 bit : size = 16 , offset of l = 8
>
> Doesn't that suggest that it would be safe to use sizeof(void *) ?
> (at least on x86 anyway).

Maybe. But the rule of thumb is to align objects by their size which we
would be violating.

A 64 bit object may span multiple cachelines if aligned to a 32 bit
boundary. Which may result in nasty surprise because the object can no
longer be read and written from memory in an atomic way. If there is
a guarantee that no 64 bit operation ever occurs then it may be
fine.

Fetching a 64 bit object that straddles a cacheline boundary also requires
2 fetches instead of one to read the object which can increase the
cache footprint of functions accessing the structure.

Slab allocators (aside from SLOB which is rarely used) assume the minimal
alignment to be sizeof(unsigned long long).

> We end up with a large number of buffer_heads and as they are pretty
> small an extra 4 bytes does make a significant difference.
> On my 64 bit machine I often see thousands of pages of buffer_heads, so
> squeezing a few more per page could be a considerable saving.

On your 64 bit machine you wont be able to do the optimization that you
are talking about.

The buffer head structure is already fairly big so this wont make too much
of a difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
