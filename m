Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ED1D66B004F
	for <linux-mm@kvack.org>; Thu, 21 May 2009 17:05:46 -0400 (EDT)
Date: Thu, 21 May 2009 22:00:20 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC][PATCH] synchrouns swap freeing at zapping vmas
In-Reply-To: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0905212035200.15631@sister.anvils>
References: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 May 2009, KAMEZAWA Hiroyuki wrote:
> 
> In these 6-7 weeks, we tried to fix memcg's swap-leak race by checking
> swap is valid or not after I/O.

I realize you've been working on different solutions for many weeks,
and would love a positive response.  Sorry, I'm not providing that:
these patches are not so beautiful that I'm eager to see them go in.

I ought to be attending to other priorities, but you've been clever
enough to propose intrusive mods that I can't really ignore, just to
force a response out of me!  And I'd better get a reply in with my
new address, before the old starts bouncing in a few days time.

> But Andrew Morton pointed out that
> "trylock in free_swap_and_cache() is not good"
> Oh, yes. it's not good.

Well, it has served non-memcg very well for years:
what's so bad about it now?

I've skimmed through the threads, starting from Nishimura-san's mail
on 17 March, was that the right one?  My head spins like Balbir's.

It seems like you have two leaks, but I may have missed the point.

One, that mem-swap accounting and mem+swap accounting have some
disagreement about when to (un)account to a memcg, with the result
that orphaned swapcache pages are liable to be accounted, but not
on the LRUs of the memcg.  I'd have thought that inconsistency is
something you should be sorting out at the memcg end, without
needing changes to the non-memcg code.

Other, that orphaned swapcache pages can build up until swap is
full, before reaching sufficient global memory pressure to run
through the global LRUs, which is what has traditionally dealt
with the issue.  And when swap is filled in this way, memcgs can
no longer put their pages out to swap, so OOM prematurely instead.

I can imagine (just imagining, haven't checked, may be quite wrong)
that split LRUs have interfered with that freeing of swapcache pages:
since vmscan.c is mainly targetted at freeing memory, I think it tries
to avoid the swapbacked LRUs once swap is full, so may now be missing
out on freeing such pages?

And it's probably an inefficient way to get at them anyway.
Why not have a global scan to target swapcache pages whenever swap is
approaching full (full in a real sense, not vm_swap_full's 50% sense)?
And run that before OOMing, memcg or not.

Sorry, you're probably going to have to explain for the umpteenth
time why these approaches do not work.

> 
> Then, this patch series is a trial to remove trylock for swapcache AMAP.
> Patches are more complex and larger than expected but the behavior itself is
> much appreciate than prevoius my posts for memcg...
>  
> This series contains 2 patches.
>   1. change refcounting in swap_map.
>      This is for allowing swap_map to indicate there is swap reference/cache.

You've gone to a lot of trouble to obscure what this patch is doing:
lots of changes that didn't need to be made, and an enum of 0 or 1
which keeps on being translated to a count of 2 or 1.

Using the 0x8000 bit in the swap_map to indicate if that swap entry
is in swapcache, yes, that may well be a good idea - and I don't know
why that bit isn't already used: might relate to when pids were limited
to 32000, but more likely was once used as a flag later abandoned.
But you don't need to change every single call to swap_free() etc,
they can mostly do just the same as they already do.

Whether it works correctly, I haven't tried to decide.  But was
puzzled when by the end of it, no real use was actually made of
the changes: the same trylock_page as before, it just wouldn't
get tried unsuccessfully so often.  Just preparatory work for
the second patch?

>   2. synchronous freeing of swap entries.
>      For avoiding race, free swap_entries in appropriate way with lock_page().
>      After this patch, race between swapin-readahead v.s. zap_page_range()
>      will go away.
>      Note: the whole code for zap_page_range() will not work until the system
>      or cgroup is very swappy. So, no influence in typical case.

This patch adds quite a lot of ugliness in a hot path which is already
uglier than we'd like.   Adding overhead to zap_pte_range, for the rare
swap and memcg case, isn't very welcome.

> 
> There are used trylocks more than this patch treats. But IIUC, they are not
> racy with memcg and I don't care them.
> (And....I have no idea to remove trylock() in free_pages_and_swapcache(),
>  which is called via tlb_flush_mmu()....preemption disabled and using percpu.)

I know well the difficulty, several of us have had patches to solve most
of the percpu mmu_gather problems, but the file truncation case (under
i_mmap_lock) has so far defeated us; and you can't ignore that case,
truncation has to remove even the anon (possibly swapcache) pages
from a private file mapping.

But I'm afraid, if you do nothing about free_pages_and_swapcache,
then I can't see much point in studying the rest of it, which
would only be addressing half of your problem.

> 
> These patches + Nishimura-san's writeback fix will do complete work, I think.
> But test is not enough.

Please provide a pointer to Nishimura-san's writeback fix,
I seem to have missed that.

There is indeed little point in attacking the trylock_page()s here,
unless you also attack all those PageWriteback backoffs.  I can imagine
a simple patch to do that (removing from swapcache while PageWriteback),
but it would be adding more atomic ops, and using spin_lock_irq on
swap_lock everywhere, probably not a good tradeoff.

> 
> Any comments are welcome. 

I sincerely wish I could be less discouraging!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
