Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 056996B0269
	for <linux-mm@kvack.org>; Sat, 16 Jan 2016 12:49:59 -0500 (EST)
Received: by mail-qk0-f173.google.com with SMTP id s5so16983401qkd.0
        for <linux-mm@kvack.org>; Sat, 16 Jan 2016 09:49:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w201si20718746qka.0.2016.01.16.09.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Jan 2016 09:49:57 -0800 (PST)
Date: Sat, 16 Jan 2016 18:49:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20160116174953.GU31137@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>

Hello Hugh,

Thanks a lot for reviewing this.

On Thu, Jan 14, 2016 at 03:36:56PM -0800, Hugh Dickins wrote:
> Okay, yes, I can see that unlimited growth of the rmap list is a problem
> which we need to address; and I can see that successful deduplication
> tends towards this state much more than anon rmap or even file rmap.

The main difference with anon and file rmap, is that all other
rmap_walks require a very bad software running in userland to end up
in anything remotely close to what can happen with KSM. So the blame
definitely goes to userland if the rmap walk gets so slow. Secondly in
all cases except KSM the memory footprint in creating such long rmap
walks is an order of magnitude higher. So the badness of such an
userland app, would spread not just to the CPU usage but also to the
RAM utilization: the app would waste massive amounts of kernel memory
to manage little userland memory.

With KSM instead millions of entries to walk and millions of
pagetables and shadow pagetables to update during a single rmap walk
can happen with any optimal program running. The program itself won't
even know what's happening inside of KSM and has no way to limit the
sharing either.

> Schedule-friendly: you make an important point there: with the rmap
> mutexes and your recent cond_resched()s, I don't think we need to worry
> about a task doing explicit work for itself (memory hotremove, for example),
> that will take as long as it has to; but, as usual, we do need to worry
> about compaction serving THP, and the high mapcounts it might encounter.

It's not just those VM internal cases: migrate_pages of of the below
program takes >60 seconds without my patch, with my patch the max
latency is a few milliseconds. So yes now I made the rmap_walks
schedule friendly, but it can't be ok to be stuck in R state for 60
seconds in order to move a single page. Making it interruptible isn't
helping a lot either as then it would fail.

==
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <numaif.h>

#define MAXNODES 17

int main(void)
{
	unsigned long page_size;
	char *p;
	page_size = sysconf(_SC_PAGE_SIZE);
	unsigned long old_node = (1<<MAXNODES)-1, node = 1;
	if (posix_memalign((void **)&p, page_size, page_size))
		perror("malloc"), exit(1);
	if (madvise(p, page_size, MADV_MERGEABLE))
		perror("madvise"), exit(1);
	memset(p, 0xff, page_size);
	for (;;) {
		sleep(1);
		migrate_pages(getpid(), MAXNODES, &old_node, &node);
		if (node == 1)
			node = 2;
		else
			node = 1;
	}
	return 0;
}
==

> 
> > 
> > There's room for optimization to significantly reduce the IPI delivery
> > cost during the page_referenced(),
> 
> You're missing that Shaohua removed x86's TLB flush from page_referenced()
> a couple of years ago: b13b1d2d8692 "x86/mm: In the PTE swapout page
> reclaim case clear the accessed bit instead of flushing the TLB".
> Yes, it is confusing that "flush" remains in the names now there
> isn't a flush.  I assume x86 is your main concern?

All archs are my concern as KSM also is supported on cyanogenmod ARM,
but the IPIs still remain in the MMU notifier. And we don't always
have a young bit there so the spte must be invalidated and
flushed. Perhaps we could teach it to create invalidated-but-not-yet
flushed sptes.

Still the IPI aren't the main problem. Let's assume for the rest of
the email that there are no IPI during page_referenced() in any arch
no matter if there's a secondary MMU attached.

> > but at least for page_migration in
> > the KSM case (used by hard NUMA bindings, compaction and NUMA
> > balancing) it may be inevitable to send lots of IPIs if each
> > rmap_item->mm is active on a different CPU and there are lots of
> > CPUs. Even if we ignore the IPI delivery cost, we've still to walk the
> > whole KSM rmap list, so we can't allow millions or billions (ulimited)
>                                                               (unlimited)
> > number of entries in the KSM stable_node rmap_item lists.
> 
> You've got me fired up.  Mel's recent 72b252aed506 "mm: send one IPI per
> CPU to TLB flush all entries after unmapping pages" and nearby commits
> are very much to the point here; but because his first draft was unsafe
> in the page migration area, he dropped that, and ended up submitting
> for page reclaim alone.
> 
> That's the first low-hanging fruit: we should apply Mel's batching
> to page migration; and it's become clear enough in my mind, that I'm
> now impatient to try it myself (but maybe Mel will respond if he has
> a patch for it already).  If I can't post a patch for that early next
> week, someone else take over (or preempt me); yes, there's all kinds
> of other things I should be doing instead, but this is too tempting.
> 
> That can help, not just KSM's long chains, but most other migration of
> mapped pages too.  (The KSM case is particularly easy, because those
> pages are known to be mapped write-protected, and its long chains can
> benefit just from batching on the single page; but in general, I
> believe we want to batch across pages there too, when we can.)
> 
> But MMU notifiers: there I'm out of my element, and you are right at
> home.  I don't know how much of an issue the MMU notification per pte
> clear is for you, but I assume it's nasty.  Is there any way those
> can be batched too, across mms, at least for the single page?
> 
> Let me be a little rude: I think that is the problem you should be
> working on, which also would benefit way beyond KSM.  (But I may be
> naive to suppose that there's even a prospect of batching there.)

I'm certainly not against all that work. It was precisely looking into
how we could improve the MMU gathering to reduce the IPI when I found
the race condition in THP MMU gather and I posted "THP MMU gather"
patchset to linux-mm (which btw still needs to be reviewed and merged
too ;).

I mentioned some of those optimizations to point out that even if we
implement them, we've still to walk millions of rmap_items.

This is purely an hardware issue we're dealing with in KSM. The
software can be improved but ultimately we've to update millions of
ptes, even the ptep_clear_flush_young IPI-less of
b13b1d2d8692b437203de7a404c6b809d2cc4d99 has to modify millions of
pagetables (or double that if there's a secondary MMU attached of KVM)
before a rmap_walk can complete. Even the lightest kind of
page_referenced() has to do that, and more work is required if it's
not just page_referenced().

> Okay, now you get into the implementation details (it's a very helpful
> outline, thank you); but I don't agree that KSM should enforce such a
> limit, I think it should continue to do as it does today.
> 
> Using dup pages does provide a "clean" way to break up the rmap
> operations, and would be great if those operations were O(N^2).
> But they're O(N), so I think the dup pages actually add a little
> overhead, rather than solving anything.  Instead of having 1000

O(N) is exactly the problem. The rmap_walk has O(N) complexity and
there's no way to improve it because it is an hardware
constraint. Either you drop the entire x86 architecture pagetable
format, or you can't fix it. And not even exotic things like shared
pageteables could fix it for KSM because it's all non linear so
there's absolutely no guarantee any pagetable can be shared in the KSM
case. All pagetables could include a pointer to a page that is
different, while all other 511 entries points to the shared KSM page.

So we can't allow N to reach a number as high as 1 million or the
rmap_walk becomes a minefield.

This is why it is mandatory to have a sharing limit and I can't
foresee any other solution, that wouldn't look like a band aid.

I can't fix the above program in any other way to guarantee it won't
run into a minefield.

> maps served by 1 page of mapcount 1000, they're served by 4 pages
> of mapcount 250.  That lowers the max amount of work in unmapping
> one page, but what about when all four of those pages have to be
> unmapped in the same operation?  That will be a less common case,

If the migrate_pages of the above program runs for 1 page only, we
must guarantee it returns in a short amount of time and succeed.

If is called for 4 pages it's ok if it's take a little longer as long
as a signal can interrupt it in the same latency that would take if we
migrated 1 page only. And that already happens for free with my
solution without having to mess with all rmap_walks interfaces. We
don't have to add signal mess to the rmap_walk, the rmap_walk can
continue to be an atomic kind of thing and it already works.

However the main benefit is not in leaving rmap_walk alone and atomic
to remain reactive to signals in the 4 page case, the main difference
with what you're proposing and what I'm proposing is in the 1 page
case. Your solution requires >60 seconds before migrate_pages can
return success. My solution requires 3 milliseconds.

A program must be able to move all its memory around, without sometime
taking >60seconds for a single page to be moved.

The unfixable problem without the KSM sharing limit:

15:21:56.769124 migrate_pages(10024, , 0x7ffee1fc5760, 17, , 0x7ffee1fc5758, 17) = 1
15:23:02.760836 rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0

And ultimately this is a O(N) complexity issue that comes from an
hardware constraint.

> sure, but it still has to be acknowledged in worst latency.  And
> when considering page reclaim: we're starting out from a deficit
> of 3 pages when compared with before.
>
> Yes, there should be a limit (though I suspect not one hard limit,
> but something that is adjusted according to pressure), and maybe
> a tunable for it.  But this limit or limits imposed by rmap_walk
> callers: first approximation, just don't bother to call rmap_walk
> if page_mapcount is higher than limit, assume the page is referenced

How do you compact memory if you can't run the rmap_walk? That would
become a defragmentation minefield, instead of "a stuck for 60-sec in
R state" current minefield. Plus the migrate_pages syscall would
fail instead of succeeding in a few milliseconds.

> and not to be unmapped - the higher its mapcount, the more likely
> I'd like your design much better if there didn't have to be this
> garbage collection, and the related possibility of fragmentation.
> But I don't see how to avoid it in a seamless way.

Fragmentation can be dealt with shall it emerge as a problem, by just
implementing a refile operation that moves a rmap_item from one
stable_node_dup to another stable_node_dup (updating the pte).

I didn't implement the defrag of stable_node_dups because the
heuristic that compacts them works well enough and then I was afraid
it was just a waste of CPU to defrag stable_node_chains with low
number of remap_items to increase the "compression ratio".

Garbage collection has to be done anyway by KSM for all its metadata,
and that's not a big issue, we just run it once in a while. Whatever
happens inside KSM in terms of CPU utilization is schedule
friendly. What is important is that whatever KSM does during its
schedule friendly compute time, cannot impact anything else in the
system. KSM can't leak memory either as long as we run the garbage
collection once in a while.

> Nicely self-contained, but I think we should go beyond KSM.
> And all those +s did put me off a bit :(

Initially I thought of attacking the problem also with optimizations
and heuristics in the VM and not by introducing a sharing limit. The
first optimizations I already implemented by making the rmap_walks
schedule friendly as that was hugely beneficial anyway (as soon as I
noticed they weren't latency friendly and we weren't fully leveraging
the higher cost of the mutexes).

However I couldn't find a way to fix it "all" by touching only the VM
parts, no matter how I changed the VM, I would still have to deal with
a compaction minefield, a migration randomly not succeeding... or
taking minutes to migrate a single page etc.. All showstopper problems.

All other optimizations to speedup the rmap_walks are still welcome
and needed but they're optimization, they can't prevent unpredictable
computation complexity issues in the kernel to emerge during random
userland workloads.

By setting the max N to the sysfs configurable value, it makes the
rmap_walk of KSM from O(N) to O(1). Of course nothing is free so it
costs memory in lower potential "compression ratio" but compressing
x256 times is surely good enough and the last of my concerns.

Implementing the sharing limit and the stable_node_chains in KSM so it
wouldn't take more memory in the KSM metadata until we hit the sharing
limit, was higher priority concern, and I think I made it.

Obviously as the VM gets faster and smarter, the sharing limit should
better increase from the current 256 to 10k or 100k, but we'll never
be able to allow it to be 1m or 10m unless the CPU gets like 10-100
times faster. By then we'll have hundred of Terabytes of memory and
we'd be back to square one requiring a limit in the 10m 100m of
rmap_items per stable_node_dup.

In short I don't see the KSM sharing limit ever going to be obsolete
unless the whole pagetable format changes and we don't deal with
pagetables anymore.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
