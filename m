Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 337126B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 20:28:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4M0STQw025709
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 May 2009 09:28:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DCDB45DE61
	for <linux-mm@kvack.org>; Fri, 22 May 2009 09:28:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B9EE45DE57
	for <linux-mm@kvack.org>; Fri, 22 May 2009 09:28:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E39BE1DB803F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 09:28:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 65FED1DB803B
	for <linux-mm@kvack.org>; Fri, 22 May 2009 09:28:28 +0900 (JST)
Date: Fri, 22 May 2009 09:26:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] synchrouns swap freeing at zapping vmas
Message-Id: <20090522092656.21e76d8f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0905212035200.15631@sister.anvils>
References: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0905212035200.15631@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 May 2009 22:00:20 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Thu, 21 May 2009, KAMEZAWA Hiroyuki wrote:
> > 
> > In these 6-7 weeks, we tried to fix memcg's swap-leak race by checking
> > swap is valid or not after I/O.
> 
> I realize you've been working on different solutions for many weeks,
> and would love a positive response.  Sorry, I'm not providing that:
> these patches are not so beautiful that I'm eager to see them go in.
> 
> I ought to be attending to other priorities, but you've been clever
> enough to propose intrusive mods that I can't really ignore, just to
> force a response out of me!

Sorry and thank you for your time and kindness.

>  And I'd better get a reply in with my new address, before the old
 > starts bouncing in a few days time.
> 
Updated my address book.


> > But Andrew Morton pointed out that
> > "trylock in free_swap_and_cache() is not good"
> > Oh, yes. it's not good.
> 
> Well, it has served non-memcg very well for years:
> what's so bad about it now?
> 
> I've skimmed through the threads, starting from Nishimura-san's mail
> on 17 March, was that the right one?  My head spins like Balbir's.
> 
Maybe right.

> It seems like you have two leaks, but I may have missed the point.
> 
> One, that mem-swap accounting and mem+swap accounting have some
> disagreement about when to (un)account to a memcg, with the result
> that orphaned swapcache pages are liable to be accounted, but not
> on the LRUs of the memcg.  I'd have thought that inconsistency is
> something you should be sorting out at the memcg end, without
> needing changes to the non-memcg code.
> 
I did these things in memcg. But finally,

-----------------------------------------------
                       |     free_swap_and_cache()
lock_page()            |        
 try_to_free_swap()    |
   check swap refcnt   |
                       |   swap refcnt goes to 1.
                             trylock failure
unlock_page()          | 
------------------------------------------------
This race was the last obstacle in front of me in previous patch.
This patch is a trial to remove trylock. (this patch teach me much ;)

> Other, that orphaned swapcache pages can build up until swap is
> full, before reaching sufficient global memory pressure to run
> through the global LRUs, which is what has traditionally dealt
> with the issue.  And when swap is filled in this way, memcgs can
> no longer put their pages out to swap, so OOM prematurely instead.
> 
yes.

> I can imagine (just imagining, haven't checked, may be quite wrong)
> that split LRUs have interfered with that freeing of swapcache pages:
> since vmscan.c is mainly targetted at freeing memory, I think it tries
> to avoid the swapbacked LRUs once swap is full, so may now be missing
> out on freeing such pages?
> 
Hmm, I feel it is possible. 

> And it's probably an inefficient way to get at them anyway.
> Why not have a global scan to target swapcache pages whenever swap is
> approaching full (full in a real sense, not vm_swap_full's 50% sense)?
> And run that before OOMing, memcg or not.
> 
It's one of points.
I or Nishimura have to modify vm_swap_full() to see memcg information.

But the problem in readahead case is
 - swap entry is used.
 - it's accoutned to a memcg by swap_cgroup
 - but not on memcg's LRU and we can't free it.

> Sorry, you're probably going to have to explain for the umpteenth
> time why these approaches do not work.
> 
IIRC, Nishimura and guys walks mainly for HPC and they tends to have tons of
memory. Then, I'd like to avoid scanning global LRU without any hints, as much as
possible.




> > 
> > Then, this patch series is a trial to remove trylock for swapcache AMAP.
> > Patches are more complex and larger than expected but the behavior itself is
> > much appreciate than prevoius my posts for memcg...
> >  
> > This series contains 2 patches.
> >   1. change refcounting in swap_map.
> >      This is for allowing swap_map to indicate there is swap reference/cache.
> 
> You've gone to a lot of trouble to obscure what this patch is doing:
> lots of changes that didn't need to be made, and an enum of 0 or 1
> which keeps on being translated to a count of 2 or 1.
> 
Ah, ok. it's not good.

> Using the 0x8000 bit in the swap_map to indicate if that swap entry
> is in swapcache, yes, that may well be a good idea - and I don't know
> why that bit isn't already used: might relate to when pids were limited
> to 32000, but more likely was once used as a flag later abandoned.
> But you don't need to change every single call to swap_free() etc,
> they can mostly do just the same as they already do.
> 
yes. Using 0x8000 as flag is the choice.

> Whether it works correctly, I haven't tried to decide.  But was
> puzzled when by the end of it, no real use was actually made of
> the changes: the same trylock_page as before, it just wouldn't
> get tried unsuccessfully so often.  Just preparatory work for
> the second patch?
> 
When swap count returns 1, there are 2 possibilities.
  - there is a swap cache
  - there is swap reference.

In second patch, I wanted to avoid unnecesasry call for
  find_get_page() -> lock_page() -> try_to_free_swap().
because I know I can't use large buffer for batched work.

Without second patch, I have a chace to fix this race
-----------------------------------------------
                       |     free_swap_and_cache()
lock_page()            |        
 try_to_free_swap()    |
   check swap refcnt   |
                       |   swap refcnt goes to 1.
                       |   trylock failure
unlock_page()          | 
------------------------------------------------

There will be no race between swap cache handling v.s. swap usage.



> >   2. synchronous freeing of swap entries.
> >      For avoiding race, free swap_entries in appropriate way with lock_page().
> >      After this patch, race between swapin-readahead v.s. zap_page_range()
> >      will go away.
> >      Note: the whole code for zap_page_range() will not work until the system
> >      or cgroup is very swappy. So, no influence in typical case.
> 
> This patch adds quite a lot of ugliness in a hot path which is already
> uglier than we'd like.   Adding overhead to zap_pte_range, for the rare
> swap and memcg case, isn't very welcome.
> 
Ok, I have to agree.

> > 
> > There are used trylocks more than this patch treats. But IIUC, they are not
> > racy with memcg and I don't care them.
> > (And....I have no idea to remove trylock() in free_pages_and_swapcache(),
> >  which is called via tlb_flush_mmu()....preemption disabled and using percpu.)
> 
> I know well the difficulty, several of us have had patches to solve most
> of the percpu mmu_gather problems, but the file truncation case (under
> i_mmap_lock) has so far defeated us; and you can't ignore that case,
> truncation has to remove even the anon (possibly swapcache) pages
> from a private file mapping.
> 
Ah, I may misunderstand following lines.
== zap_pte_range()
 832                  * If details->check_mapping, we leave swap entries;
 833                  * if details->nonlinear_vma, we leave file entries.
 834                  */
 835                 if (unlikely(details))
 836                         continue;
==
Then...this is bug ?

> But I'm afraid, if you do nothing about free_pages_and_swapcache,
> then I can't see much point in studying the rest of it, which
> would only be addressing half of your problem.
> 
> > 
> > These patches + Nishimura-san's writeback fix will do complete work, I think.
> > But test is not enough.
> 
> Please provide a pointer to Nishimura-san's writeback fix,
> I seem to have missed that.
> 
This one.
  http://marc.info/?l=linux-kernel&m=124236139502335&w=2

> There is indeed little point in attacking the trylock_page()s here,
> unless you also attack all those PageWriteback backoffs.  I can imagine
> a simple patch to do that (removing from swapcache while PageWriteback),
> but it would be adding more atomic ops, and using spin_lock_irq on
> swap_lock everywhere, probably not a good tradeoff.
> 
Ok, I should consider more.
> > 
> > Any comments are welcome. 
> 
> I sincerely wish I could be less discouraging!
> 
I've been feeling like to crash my head by hitting it against an edge ot a tofu
in these days. But if patch 1/2 is acceptable with the modification you suggested,
there will be a way to go. 

You encouraged me :) thanks.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
