Date: Sat, 14 Jan 2006 02:53:43 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: use-once-cleanup testing
Message-ID: <20060114045343.GA3355@dmt.cnet>
References: <20060114000533.GA4111@dmt.cnet> <43C883AA.30101@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43C883AA.30101@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: akpm@osdl.org, Peter Zijlstra <peter@programming.kicks-ass.net>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Sat, Jan 14, 2006 at 03:52:58PM +1100, Nick Piggin wrote:
> 
> Marcelo Tosatti wrote:
> 
> >Hi folks,
> >
> >Rik's use-once cleanup patch (1) gets rid of a nasty problem. The
> >use-once logic does not work for mmaped() files, due to the questionable
> >assumption that any referenced pages of such files should be held in
> >memory:
> >
> >1 - http://lwn.net/Articles/134387/
> >
> >static int shrink_list(struct list_head *page_list, struct scan_control 
> >*sc)
> >{
> >...
> >               referenced = page_referenced(page, 1);
> >               /* In active use or really unfreeable?  Activate it. */
> >               if (referenced && page_mapping_inuse(page))
> >                       goto activate_locked;
> >
> >The page activation scheme relies on mark_page_accessed() (exported
> >function) to do the list move itself, which is the only way for in-cache
> >non mapped pages to be promoted to the active list.
> >
> >Rik's patch instead only sets the referenced bit at
> >mark_page_accessed(), changing the use-once logic to work by means
> >of a newly created PG_new flag. The flag, set at add_to_pagecache()
> >time, gives pages a second round on the inactive list in case they
> >get referenced. Page activation is then performed if the page is
> >re-referenced.
> >
> >
> 
> This is what I've done too (though I prefer a PG_useonce flag
> which gets set after they're first seen referenced).
> 
> I think Wu may also be doing something like it for adaptive readahead.
> 
> Basically: it has been reinvented so many times that it *has* to be a
> good idea ;)

For most mixed loads, think so. But not for all certainly.

> >Another clear advantage of not doing the list move at mark_page_accessed()
> >time is decreased zone->lru_lock contention and cache thrashing in 
> >general (profiling on SMP machines would be interesting).
> >
> >
> 
> It also allows one to get rid of the dirty hacks in mark_page_accessed
> callers and means read() based useonce actually works properly in cases
> where userspace isn't working in blocks of PAGE_SIZE (rsync I think was
> one that did this, with fairly horrible results).
> 
> >A possibly negative side-effect of PG_new, already mentioned by Nikita
> >in this list, is that used-once pages lurk around longer in cache, which
> >can slowdown particular workloads (it should not be hard to create such
> >loads).
> >
> >
> 
> Yes, I found that also doing use-once on mapped pages caused fairly huge
> slowdowns in some cases. File IO could much more easily cause X and its
> applications to get swapped out.
> 
> >However, the ongoing non-resident book keeping implementation makes it
> >possible to completly get rid of "second chance" behaviour: re-accessed
> >evicted pages are automatically promoted to the active list.
> >
> >
> Possibly. I think moving unmapped use-once over to PG_useonce first, and
> tidying the weird warts and special cases (that don't make sense) from
> vmscan is a good first step.
> 
> Unfortunately I don't think Andrew wants a bar of any of it. Nor would
> a crazy rewrite-pagereclaim tree really get any sort of testing at all,
> realistically :(
> 
> Ideas?

I think that creating a page replacement interface used by the VM to
hide the details of the reclaim specifics is an important step forward,
allowing co-existance of different replacement policies.

It opens up many possibilities.

Peter started the abstraction of the page reclaim code for his CLOCK-Pro
implementation, and I've been working with him to improve it.

The current code is logically glued together, there is no distiction
between reclaim cache interface and LRU: they are the same.

Please take a look at
http://programming.kicks-ass.net/kernel-patches/page-replace/2.6.16-rc1/page-replace-documentation.patch
and the related patches in that directory.

Its basically separating the actions invoked by generic VM:

- book keeping of page information (insertion, deletion, reference, and
so on).
- selection of pagecache candidates for eviction

And:
- balancing between slab/pagecache eviction
- page eviction
- page writeout

IMO they should all be separate, with shared helpers functions, as the 
document and patches suggest.

The current set makes the traditional LRU 2-queue and CLOCK-Pro policies
co-exist (at the very moment it contains several patches which change
behaviour such as Rik's PG_new, Wu's zone scanning balancing, but they
are not necessarily related to this).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
