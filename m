Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10C336B0007
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 19:08:01 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u13-v6so5899201pfm.8
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 16:08:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37-v6sor2408537plv.44.2018.08.04.16.07.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 Aug 2018 16:07:59 -0700 (PDT)
Date: Sat, 4 Aug 2018 16:07:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before
 swapcache_free
In-Reply-To: <20180727140749669129112@wingtech.com>
Message-ID: <alpine.LSU.2.11.1808041332410.1120@eggly.anvils>
References: <2018072514375722198958@wingtech.com>, <20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>, <2018072610214038358990@wingtech.com>, <20180726060640.GQ28386@dhcp22.suse.cz>, <20180726150323057627100@wingtech.com>,
 <20180726151118.db0cf8016e79bed849e549f9@linux-foundation.org> <20180727140749669129112@wingtech.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: akpm <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Fri, 27 Jul 2018, zhaowuyun@wingtech.com wrote:
> >On Thu, 26 Jul 2018 15:03:23 +0800 "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com> wrote:
> >
> >> >On Thu 26-07-18 10:21:40, zhaowuyun@wingtech.com wrote:
> >> >[...]
> >> >> Our project really needs a fix to this issue
> >> >
> >> >Could you be more specific why? My understanding is that RT tasks
> >> >usually have all the memory mlocked otherwise all the real time
> >> >expectations are gone already.
> >> >--
> >> >Michal Hocko
> >> >SUSE Labs
> >>
> >>
> >> The RT thread is created by a process with normal priority, and the process was sleep,
> >> then some task needs the RT thread to do something, so the process create this thread, and set it to RT policy.
> >> I think that is the reason why RT task would read the swap.
> >
> >A simpler bandaid might be to replace the cond_resched() with msleep(1). 
> 
> 
> Thanks for the suggestion, we will try that.

Andrew's msleep(1) may be a good enough bandaid for you. And I share
Michal's doubt about your design, in which an RT thread meets swap:
this may not be the last problem you have with that.

But this is a real bug when CONFIG_PREEMPT=y, RT threads or not: we
just didn't notice, because it's usually hidden by the cond_resched().
(I think that was added in 3.10, because in 2.6.29 I had been guilty of
inserting a discard, and wait for completion, in between allocating swap
and adding to swap cache; but Shao Hua fixed my discard in 3.12.) Thanks
a lot for making us aware of this bug.

After reminding myself of the issues here, I disagree with much of what
has been said: we shall "always" want the loop in __read_swap_cache_async()
(though some of its error handling is probably superfluous now, agreed);
and your disabling of preemption is not just a bandaid, it's exactly the
right approach.

We could do something heavier, perhaps rearranging the swapcache tree work
to be done under swap_lock as well as tree_lock (I'm talking 4.9-language),
but that's very unlikely to be an improvement. Disabling preemption yokes
the two spinlocks together in an efficient way, without overhead on other
paths; on rare occasions we spin around __read_swap_cache_async() instead
of spinning around to acquire a spinlock.

But your patch is incomplete. The same needs to be done in delete_from_
swap_cache(), and we would also need to protect against preemption between
the get_swap_page() and the add_to_swap_cache(), in add_to_swap() and in
shmem_writepage(). The latter gets messy, but 4.11 (where Tim Chen uses
SWAP_HAS_CACHE more widely) gives a good hint: __read_swap_cache_async()
callers are only interested in swap entries that are already in use and
still in use. (Though swapoff has to be more careful, partly because one
of its jobs is to clear out swap-cache-only entries, partly because the
current interface would mistake a NULL for no-entry as out-of-memory.)

Below is the patch I would do for 4.9 (diffed against 4.9.117), and I'm
showing that because it's the simplest case. Although the principles stay
the same, the codebase here has gone through several shifts, and 4.19 will
probably be different again. So I'll test and post a patch against 4.19-rc
in a few weeks time, and that can then be backported to stable: but will
need several manual backports because of the intervening changes.

I did wonder whether just to extend the irq-disabled section in
delete_from_swap_cache() etc: that's easy, and works, and is even better
protection against spinning too long; but it's not absolutely necessary,
so all in all, probably better avoided. I did wonder whether to remove
the cond_resched(), but it's not a bad place for one, so I've left it in.

When checking worst cases of looping around __read_swap_cache_async(),
after the patch, I was worried for a while. I had naively imagined that
going more than twice around the loop should be vanishingly rare, but
that is not so at all. But the bad cases I looked into were all the same:
after forking, two processes, on HT siblings, each serving do_swap_page(),
trying to bring the same swap into its mm, with a sparse swapper_space
tree: one process gets to do all the work of allocating new radix-tree
nodes and bringing them into D-cache, while the other just spins around
__read_swap_cache_async() seeing SWAP_HAS_CACHE but not yet the page in
the radix-tree. That's okay, that makes sense.

Hugh
---

 mm/swap_state.c |   26 +++++++++++++-------------
 mm/swapfile.c   |    8 +++++++-
 mm/vmscan.c     |    3 +++
 3 files changed, 23 insertions(+), 14 deletions(-)

--- 4.9.117/mm/swap_state.c	2016-12-11 11:17:54.000000000 -0800
+++ linux/mm/swap_state.c	2018-08-04 11:50:46.577788766 -0700
@@ -225,9 +225,11 @@ void delete_from_swap_cache(struct page
 	address_space = swap_address_space(entry);
 	spin_lock_irq(&address_space->tree_lock);
 	__delete_from_swap_cache(page);
+	/* Expedite swapcache_free() to help __read_swap_cache_async() */
+	preempt_disable();
 	spin_unlock_irq(&address_space->tree_lock);
-
 	swapcache_free(entry);
+	preempt_enable();
 	put_page(page);
 }
 
@@ -337,19 +339,17 @@ struct page *__read_swap_cache_async(swp
 		if (err == -EEXIST) {
 			radix_tree_preload_end();
 			/*
-			 * We might race against get_swap_page() and stumble
-			 * across a SWAP_HAS_CACHE swap_map entry whose page
-			 * has not been brought into the swapcache yet, while
-			 * the other end is scheduled away waiting on discard
-			 * I/O completion at scan_swap_map().
+			 * We might race against __delete_from_swap_cache() and
+			 * stumble across a swap_map entry whose SWAP_HAS_CACHE
+			 * has not yet been cleared: hence preempt_disable()
+			 * in __remove_mapping() and delete_from_swap_cache(),
+			 * so they cannot schedule away before clearing it.
 			 *
-			 * In order to avoid turning this transitory state
-			 * into a permanent loop around this -EEXIST case
-			 * if !CONFIG_PREEMPT and the I/O completion happens
-			 * to be waiting on the CPU waitqueue where we are now
-			 * busy looping, we just conditionally invoke the
-			 * scheduler here, if there are some more important
-			 * tasks to run.
+			 * We need similar protection against racing calls to
+			 * __read_swap_cache_async(): preempt_disable() before
+			 * swapcache_prepare() above, preempt_enable() after
+			 * __add_to_swap_cache() below: which are already in
+			 * radix_tree_maybe_preload(), radix_tree_preload_end().
 			 */
 			cond_resched();
 			continue;
--- 4.9.117/mm/swapfile.c	2018-08-04 11:40:08.463504848 -0700
+++ linux/mm/swapfile.c	2018-08-04 11:50:46.577788766 -0700
@@ -2670,7 +2670,13 @@ static int __swap_duplicate(swp_entry_t
 		/* set SWAP_HAS_CACHE if there is no cache and entry is used */
 		if (!has_cache && count)
 			has_cache = SWAP_HAS_CACHE;
-		else if (has_cache)		/* someone else added cache */
+		/*
+		 * __read_swap_cache_async() can usually skip entries without
+		 * real usage (including those in between being allocated and
+		 * added to swap cache); but swapoff (!SWP_WRITEOK) must not.
+		 */
+		else if (has_cache &&
+			 (count || !(p->flags & SWP_WRITEOK)))
 			err = -EEXIST;
 		else				/* no users remaining */
 			err = -ENOENT;
--- 4.9.117/mm/vmscan.c	2018-08-04 11:40:08.471504902 -0700
+++ linux/mm/vmscan.c	2018-08-04 11:50:46.577788766 -0700
@@ -709,8 +709,11 @@ static int __remove_mapping(struct addre
 		swp_entry_t swap = { .val = page_private(page) };
 		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
+		/* Expedite swapcache_free() for __read_swap_cache_async() */
+		preempt_disable();
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		swapcache_free(swap);
+		preempt_enable();
 	} else {
 		void (*freepage)(struct page *);
 		void *shadow = NULL;
