Message-ID: <3D3F0ACE.D4195BF@zip.com.au>
Date: Wed, 24 Jul 2002 13:15:10 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page_add/remove_rmap costs
References: <3D3E4A30.8A108B45@zip.com.au> <Pine.LNX.4.44L.0207241319550.3086-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> ...
> > It is interesting to note that the length of the pte_chain is not a big
> > factor in all of this.  So changing the singly-linked list to something
> > else probably won't help much.
> 
> This is more disturbing ... ;)

Well yes.  It may well indicate that my test is mostly LIFO
on the pte chains.  So FIFO workloads would be worse.

> > My gut feel here is that this will be hard to tweak - some algorithmic
> > change will be needed.
> >
> > The pte_chains are doing precisely zilch but chew CPU cycles with this
> > workload.  The machine has 2G of memory free.  The rmap is pure overhead.
> >
> > Would it be possible to not build the pte_chain _at all_ until it is
> > actually needed?  Do it lazily?  So in the page reclaim code, if the
> > page has no rmap chain we go off and build it then?  This would require
> > something like a pfn->pte lookup function at the vma level, and a
> > page->vmas_which_own_me lookup.
> 
> > Then again, if the per-vma pfn->pte lookup is feasible, we may not need
> > the pte_chain at all...
> 
> It is feasible, both davem and bcrl made code to this effect. The
> only problem with that code is that it gets ugly quick after mremap.

So.. who's going to do it?

It's early days yet - although this looks bad on benchmarks we really
need a better understanding of _why_ it's so bad, and of whether it
really matters for real workloads.

For example: given that copy_page_range performs atomic ops against
page->count, how come page_add_rmap()'s atomic op against page->flags
is more of a problem?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
