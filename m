Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A57805F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 20:49:08 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator
Date: Tue, 3 Feb 2009 12:48:40 +1100
References: <20090114150900.GC25401@wotan.suse.de> <20090123161017.GC14517@wotan.suse.de> <alpine.DEB.1.10.0901261230540.1908@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0901261230540.1908@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902031248.42124.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 27 January 2009 04:34:21 Christoph Lameter wrote:
> On Fri, 23 Jan 2009, Nick Piggin wrote:
> > > SLUB can directly free an object to any slab page. "Queuing" on free
> > > via the per cpu slab is only possible if the object came from that per
> > > cpu slab. This is typically only the case for objects that were
> > > recently allocated.
> >
> > Ah yes ok that's right. But then you don't get LIFO allocation
> > behaviour for those cases.
>
> But you get more TLB local allocations.

Not necessarily at all. Because when the "active" page runs out, you've
lost all the LIFO information about objects with active caches and TLBs.


> > > Yes you can loose track of caching hot objects. That is one of the
> > > concerns with the SLUB approach. On the other hand: Caching
> > > architectures get more and more complex these days (especially in a
> > > NUMA system). The
> >
> > Because it is more important to get good cache behaviour.
>
> Its going to be quite difficult to realize algorithm that guestimate what
> information the processor keeps in its caches. The situation is quite
> complex in NUMA systems.

LIFO is fine.


> > So I think it is wrong to say it requires more metadata handling. SLUB
> > will have to switch pages more often or free objects to pages other than
> > the "fast" page (what do you call it?), so quite often I think you'll
> > find SLUB has just as much if not more metadata handling.
>
> Its the per cpu slab. SLUB does not switch pages often but frees objects
> not from the per cpu slab directly with minimal overhead compared to a per
> cpu slab free. The overhead is much less than the SLAB slowpath which has
> to be taken for alien caches etc.

But the slab allocator isn't just about allocating. It is also about
freeing. And you can be switching pages frequently in the freeing path.
And depending on allocation patterns, it can still be quite frequent
in the allocation path too (and even if you have gigantic pages, they
can still get mostly filled up which reduces your queue size and
increases rate of switching between them).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
