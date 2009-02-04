Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4F6F96B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:13:59 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3677482C4F1
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:16:33 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BNljySAtUMhZ for <linux-mm@kvack.org>;
	Wed,  4 Feb 2009 11:16:33 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CAFD382C51B
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:14:13 -0500 (EST)
Date: Wed, 4 Feb 2009 11:06:20 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <498893EE.9060107@cs.helsinki.fi>
Message-ID: <alpine.DEB.1.10.0902041050160.19633@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de> <1232959706.21504.7.camel@penberg-laptop> <20090203101205.GF9840@csn.ul.ie> <498893EE.9060107@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, Pekka Enberg wrote:

> Anyway, even if we did end up going forward with SLQB, it would sure as hell
> be less painful if we understood the reasons behind it.

The reasons may depend on hardware contingencies like TLB handling
overhead and various inefficiencies that depend on the exact processor
model. Also the type of applications you want to run. Some of the IA64
heritage of SLUB may be seen in the results of these tests. Note that PPC
and IA64 have larger page sizes (which results in SLUB being able to put
more objects into an order 0 page) and higher penalties for TLB handling.
The initial justification for SLUB were Mel's results on IA64 that showed
a 5-10% increase in performance through SLUB.

In my current position we need to run extremely low latency code in user
space and want to avoid any disturbance by kernel code interrupting user
space. My main concern for my current work context is that switching to
SLQB will bring back the old cache cleaning problems and introduce
latencies for our user space applications. Otherwise I am on x86 now so
the TLB issues are less of a concern for me now.

In general it may be better to have a larger selection of slab allocators.
I think this is no problem as long as we have motivated people that
maintain these. Nick seems to be very motivated at this point. So lets
merge SLQB as soon as we can and expose it to a wider audience so that it
can mature. And people can have more fun running one against the other
refining these more and more.

There are still two major things that I hope will happen soon to clean up stuff in
the slab allocators:

1. The introduction of a per cpu allocator.

This is important to optimize the fastpaths. The cpu allocator will allow
us to get rid of the arrays indexes by NR_CPUS and allow operations that
are atomic wrt. interrupts. The lookup of the kmem_cache_cpu struct
address will no longer be necessary.

2. Alloc/free without disabling interrupts.

Matthieu has written an early implementation of allocation functions that
do not require interrupt disable/enable. It seems that these are right now
the major cause of latency in the fast paths. Andi has stated that the
interrupt enable/disable has been optimized in recent releases of new
processors. The overhead may be due to the flags being pushed onto the
stack and retrieved later. Mathieus implementation can be made more
elegant if atomic per cpu ops are available. This could significantly
increase the speed of the fast paths in the allocators (may be a challenge
to SLAB and SLQB since they need to update a counter and a pointer but its
straightforward in SLUB).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
