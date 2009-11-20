Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D2CF76B00BF
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 09:49:03 -0500 (EST)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAKEcAnE025266
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 09:38:10 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAKEmun9090444
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 09:48:56 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAKEmtQ4032257
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 09:48:56 -0500
Date: Fri, 20 Nov 2009 06:48:55 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep complaints in slab allocator
Message-ID: <20091120144855.GB22527@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20091118181202.GA12180@linux.vnet.ibm.com> <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com> <1258709153.11284.429.camel@laptop> <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com> <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B067816.6070304@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 20, 2009 at 01:05:58PM +0200, Pekka Enberg wrote:
> Peter Zijlstra kirjoitti:
>> On Fri, 2009-11-20 at 12:38 +0200, Pekka Enberg wrote:
>>>
>>> On Fri, Nov 20, 2009 at 11:25 AM, Peter Zijlstra <peterz@infradead.org> 
>>> wrote:
>>>>  2) propagate the nesting information and user spin_lock_nested(), given
>>>> that slab is already a rat's nest, this won't make it any less obvious.
>>> spin_lock_nested() doesn't really help us here because there's a
>>> _real_ possibility of a recursive spin lock here, right? 
>> Well, I was working under the assumption that your analysis of it being
>> a false positive was right ;-)
>> I briefly tried to verify that, but got lost and gave up, at which point
>> I started looking for ways to annotate.
>
> Uh, ok, so apparently I was right after all. There's a comment in 
> free_block() above the slab_destroy() call that refers to the comment above 
> alloc_slabmgmt() function definition which explains it all.
>
> Long story short: ->slab_cachep never points to the same kmalloc cache 
> we're allocating or freeing from. Where do we need to put the 
> spin_lock_nested() annotation? Would it be enough to just use it in 
> cache_free_alien() for alien->lock or do we need it in cache_flusharray() 
> as well?

Hmmm...  If the nc->lock spinlocks are always from different slabs
(as alloc_slabmgmt()'s block comment claims), why not just give each
array_cache structure's lock its own struct lock_class_key?  They
are zero size unless you have lockdep enabled.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
