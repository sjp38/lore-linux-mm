Date: Wed, 24 Jul 2002 13:24:13 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: page_add/remove_rmap costs
In-Reply-To: <3D3E4A30.8A108B45@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207241319550.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jul 2002, Andrew Morton wrote:

> It's just a ton of forking and exitting.

And exec()ing ...

> What we see here is:
>
> - We did 12477 forks
> - those forks called copy_page_range() 174,521 times in total
> - Of the 4,106,673 calls to page_add_rmap, 2,774,954 came from
>   copy_page_range and 1,029,498 came from do_no_page.
> - Of the 4,119,825 calls to page_remove_rmap(), 3,863,194 came
>   from zap_page_range().
>
> So it's pretty much all happening in fork() and exit().

And exec() ... In fact, I suspect that about half of the calls
to page_remove_rmap() are coming via exec().


> The page_add_rmap() one is interesting - the pte_chain_unlock() is as
> expensive as the pte_chain_lock().  Which would tend to indicate either
> that the page->flags has expired from cache or some other CPU has stolen
> it.
>
> It is interesting to note that the length of the pte_chain is not a big
> factor in all of this.  So changing the singly-linked list to something
> else probably won't help much.

This is more disturbing ... ;)


> My gut feel here is that this will be hard to tweak - some algorithmic
> change will be needed.
>
> The pte_chains are doing precisely zilch but chew CPU cycles with this
> workload.  The machine has 2G of memory free.  The rmap is pure overhead.
>
> Would it be possible to not build the pte_chain _at all_ until it is
> actually needed?  Do it lazily?  So in the page reclaim code, if the
> page has no rmap chain we go off and build it then?  This would require
> something like a pfn->pte lookup function at the vma level, and a
> page->vmas_which_own_me lookup.

> Then again, if the per-vma pfn->pte lookup is feasible, we may not need
> the pte_chain at all...

It is feasible, both davem and bcrl made code to this effect. The
only problem with that code is that it gets ugly quick after mremap.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
