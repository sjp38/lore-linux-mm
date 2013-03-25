Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 667526B0069
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 04:42:20 -0400 (EDT)
Date: Mon, 25 Mar 2013 17:42:17 +0900
From: Minchan Kim <minchan.kim@lge.com>
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
Message-ID: <20130325084217.GC2348@blaptop>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
 <514A6282.8020406@linaro.org>
 <20130322060113.GA4802@blaptop>
 <514C8FB0.4060105@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514C8FB0.4060105@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 22, 2013 at 10:06:56AM -0700, John Stultz wrote:
> On 03/21/2013 11:01 PM, Minchan Kim wrote:
> >On Wed, Mar 20, 2013 at 06:29:38PM -0700, John Stultz wrote:
> >>On 03/12/2013 12:38 AM, Minchan Kim wrote:
> >>>First of all, let's define the term.
> >>> From now on, I'd like to call it as vrange(a.k.a volatile range)
> >>>for anonymous page. If you have a better name in mind, please suggest.
> >>>
> >>>This version is still *RFC* because it's just quick prototype so
> >>>it doesn't support THP/HugeTLB/KSM and even couldn't build on !x86.
> >>>Before further sorting out issues, I'd like to post current direction
> >>>and discuss it. Of course, I'd like to extend this discussion in
> >>>comming LSF/MM.
> >>>
> >>>In this version, I changed lots of thing, expecially removed vma-based
> >>>approach because it needs write-side lock for mmap_sem, which will drop
> >>>performance in mutli-threaded big SMP system, KOSAKI pointed out.
> >>>And vma-based approach is hard to meet requirement of new system call by
> >>>John Stultz's suggested semantic for consistent purged handling.
> >>>(http://linux-kernel.2935.n7.nabble.com/RFC-v5-0-8-Support-volatile-for-anonymous-range-tt575773.html#none)
> >>>
> >>>I tested this patchset with modified jemalloc allocator which was
> >>>leaded by Jason Evans(jemalloc author) who was interest in this feature
> >>>and was happy to port his allocator to use new system call.
> >>>Super Thanks Jason!
> >>>
> >>>The benchmark for test is ebizzy. It have been used for testing the
> >>>allocator performance so it's good for me. Again, thanks for recommending
> >>>the benchmark, Jason.
> >>>(http://people.freebsd.org/~kris/scaling/ebizzy.html)
> >>>
> >>>The result is good on my machine (12 CPU, 1.2GHz, DRAM 2G)
> >>>
> >>>	ebizzy -S 20
> >>>
> >>>jemalloc-vanilla: 52389 records/sec
> >>>jemalloc-vrange: 203414 records/sec
> >>>
> >>>	ebizzy -S 20 with background memory pressure
> >>>
> >>>jemalloc-vanilla: 40746 records/sec
> >>>jemalloc-vrange: 174910 records/sec
> >>>
> >>>And it's much improved on KVM virtual machine.
> >>>
> >>>This patchset is based on v3.9-rc2
> >>>
> >>>- What's the sys_vrange(addr, length, mode, behavior)?
> >>>
> >>>   It's a hint that user deliver to kernel so kernel can *discard*
> >>>   pages in a range anytime. mode is one of VRANGE_VOLATILE and
> >>>   VRANGE_NOVOLATILE. VRANGE_NOVOLATILE is memory pin operation so
> >>>   kernel coudn't discard any pages any more while VRANGE_VOLATILE
> >>>   is memory unpin opeartion so kernel can discard pages in vrange
> >>>   anytime. At a moment, behavior is one of VRANGE_FULL and VRANGE
> >>>   PARTIAL. VRANGE_FULL tell kernel that once kernel decide to
> >>>   discard page in a vrange, please, discard all of pages in a
> >>>   vrange selected by victim vrange. VRANGE_PARTIAL tell kernel
> >>>   that please discard of some pages in a vrange. But now I didn't
> >>>   implemented VRANGE_PARTIAL handling yet.
> >>
> >>So I'm very excited to see this new revision! Moving away from the
> >>VMA based approach I think is really necessary, since managing the
> >>volatile ranges on a per-mm basis really isn't going to work when we
> >>want shared volatile ranges between processes (such as the
> >>shmem/tmpfs case Android uses).
> >>
> >>Just a few questions and observations from my initial playing around
> >>with the patch:
> >>
> >>1) So, I'm not sure I understand the benefit of VRANGE_PARTIAL. Why
> >>would VRANGE_PARTIAL be useful?
> >For exmaple, some process makes 64M vranges and now kernel needs 8M
> >pages to flee from memory pressure state. In this case, we don't need
> >to discard 64M all at once because if we discard only 8M page, the cost
> >of allocator is (8M/4K) * page(falut + allocation + zero-clearing)
> >while (64M/4K) * page(falut + allocation + zero-clearing), otherwise.
> >
> >If it were temporal image extracted on some compressed format, it's not
> >easy to regenerate punched hole data from original source so it would
> >be better to discard all pages in the vrange, which will be very far
> >from memory reclaimer.
> 
> So, if I understand you properly, its more an issue of the the added
> cost of making the purged range non-volatile, and re-faulting in the
> pages if we purge them all, when we didn't actually have the memory
> pressure to warrant purging the entire range?
> 
> Hrm. Ok, I can sort of see that.
> 
> So if we do partial-purging, all the data in the range is invalid -
> since we don't know which pages in particular were purged, but the
> costs when marking the range non-volatile and the costs of
> over-writing the pages with the re-created data will be slightly
> cheaper.

It could be heavily cheaper with my experiment in this patchset.
Allocator could avoid minor fault from 105799867 to 9401.

> 
> I guess the other benefit is if you're using the SIGBUS semantics,
> you might luck out and not actually touch a purged page. Where as if
> the entire range is purged, the process will definitely hit the
> SIGBUS if its accessing the volatile data.

Yes. I guess that's why Taras liked it.
Quote from old version
"
4) Having a new system call makes it easier for userspace apps to
   detect kernels without this functionality.

I really like the proposed interface. I like the suggestion of having
explicit FULL|PARTIAL_VOLATILE. Why not include PARTIAL_VOLATILE as a
required 3rd param in first version with expectation that
FULL_VOLATILE will be added later(and returning some not-supported error
in meantime)?
"

> 
> 
> So yea, its starting to make sense.
> 
> Much of my earlier confusion comes from comment in the vrange
> syscall implementation that suggests VRANGE_PARTIAL will purge from
> ranges intentionally in round-robin order, which I think is probably
> not advantageous, as it will invalidate more ranges causing more
> overhead.  Instead using the normal page eviction order with
> _PARTIAL would probably be best.

As you know, I insisted on several time "volatile pages" is nothing
special so we should reclaim them in normal page order.
But I changed my mind because in allocator's POV, if we reclaim in
normal page order, VM can swapout other working set pages instead of
volatile pages. What happens if we don't have this feature in kernel?
They may call madvise(DONTNEED) or munmap so there wouldn't be swpped
out(it could be major fault afterward).

A major fault could mitigate this feature's benefit so I'd like to
sweep volatile pages out firstly.

If we really want to reclaim some vrange pages in normal page order,
we can add new argument in vrange system call and handle it later.
But I'm not sure we really need it.

> 
> 
> >>2) I've got a trivial test program that I've used previously with
> >>ashmem & my earlier file based efforts that allocates 26megs of page
> >>aligned memory, and marks every other meg as volatile. Then it forks
> >>and the child generates a ton of memory pressure, causing pages to
> >>be purged (and the child killed by the OOM killer). Initially I
> >>didn't see my test purging any pages with your patches. The problem
> >>of course was the child's COW pages were not also marked volatile,
> >>so they could not be purged. Once I over-wrote the data in the
> >>child, breaking the COW links, the data in the parent was purged
> >>under pressure.  This is good, because it makes sure we don't purge
> >>cow pages if the volatility state isn't consistent, but it also
> >>brings up a few questions:
> >>
> >>     - Should volatility be inherited on fork? If volatility is not
> >>inherited on fork(), that could cause some strange behavior if the
> >>data was purged prior to the fork, and also its not clear what the
> >>behavior of the child should be with regards to data that was
> >>volatile at fork time.  However, we also don't want strange behavior
> >>on exec if overwritten volatile pages were unexpectedly purged.
> >I don't know why we should inherit volatility to child at least, for
> >anon vrange. Because it's not proper way to share the data.
> >For data sharing for anonymous page, we should use shmem so the work
> >could be done when we work tmpfs work, I guess.
> 
> I'm not suggesting the volatile *pages* on fork would be shared
> (other then they are COW), instead my point is the volatile *state*
> of the pages should probably be preserved over a fork.
> 
> Given the following example:
> 
> buf = malloc(BIGBUF);
> memset(buf, 'P', BIGBUF);
> vrange(buf, BIGBUF, VRANGE_VOLATILE, VRANGE_FULL);
> pid = fork();
> 
> if (!pid)    /* break COW sharing*/
>     memset(buf, 'C', BIGBUF);
> 
> generate_memory_pressure();
> purged = vrange(buf, BIGBUF, VRANGE_NOVOLATILE, VRANGE_FULL);
> 
> 
> Currently, because vrange is set before the fork, in this example,
> only the parent's volatile range will be purged. However, if we were
> to move the fork() one line up, then both parent and child would see
> their separate ranges purged. This behavior is not quite intuitive,
> as I usually expect the childs state to be identical to the parents
> at fork time.
> 
> In my mind, what would be less surprising is if in the above code,
> the volatility state of buf would be inherited to the child as well
> (basically copying the vrange tree at fork).
> 
> And the cow breaking in the above is just for clarification, even if
> the COW links weren't broken and the pages were still shared between
> the child and parent after fork, since they both would consider the
> buffer state as volatile, it would still be ok to purge the pages.
> 
> Now, the other side of the coin, is that if we have volatile data at
> fork time, but the child then goes on to call exec, we don't want
> the new process to randomly hit sigfaults when the earlier set
> volatile range is purged. So if we inherit volatile state to
> children, my thought is we probably want to clear all volatile state
> on exec.

Indeed, I got a your point and frankly speaking, I implemented it with
odd lock schemem in this version, then decided to drop it because
I was not sure who want to use such usecase scenario between parent and
child so tempted to drop it. ;-)

Okay. I have a idea, I will support it in next spin and I don't think
it is never odd that child has volatile data at forktime and exec of
child clear them.

> 
> 
> 
> 
> >>
> >>4) One of the harder aspects I'm trying to get my head around is how
> >>your patches seem to use both the page list shrinkers
> >>(discard_vpage) to purge ranges when particular pages selected, and
> >>a zone shrinker (discard_vrange_pages) which manages its own lru of
> >>vranges. I get that this is one way to handle purging anonymous
> >>pages when we are on a swapless system, but the dual purging systems
> >>definitely make the code harder to follow. Would something like my
> >discard_vpage is for avoiding swapping out in direct reclaim path
> >when kswapd miss the page.
> >
> >discard_vrange_pages is for handling volatile pages as top prioirty
> >prio to reclaim non-volatile pages.
> 
> So one note: while I've pushed for freeing volatile pages first in
> the past, I know  Mel has had some objections to this, for instance,

Me, too at that time. But I changed my mind as I mentioned earlier.

> he thought there are cases where freeing the volatile data first
> wasn't the right thing to do, such as the case with streaming data,
> and that we probably want to leave it to the page eviction LRUs to
> pick the pages for us.

I agree on streaming data. It would be great to reclaim them rather than
vrange pages. But current VM isn't smart to detect streaming data and
reclaim them as top priority without user's help.

If user helps kernel with hint(ex, fadvise), kernel free them instantly
so there isn't any remained pages in LRU and if kernel can't free pages
with some reason(dirty or locked), kernel can move them into inactive
LRU's tail so in next turn, kernel can reclaim them as top-priority if
they meet free-condition.

It means what we have to care is remained streaming data in LRU when
user helps kernel with some advise.
If it's really severe problem, I'd like to introduce new LRU list called by
easy-reclaimable so kernel can move them in easy-lru list and reclaim
them as top-priority before discarding vrange pages.

> 
> 
> >
> >I think it's very clear, NOT to understand. :)
> >And discard_vpage is basic core function to discard volatile page
> >so it could be used many places.
> 
> Ok, I suspect it will make more sense as I get more familiar with it. :)
> 
> >
> >>earlier attempts at changing vmscan to shrink anonymous pages be
> >>simpler? Or is that just not going to fly w/ the mm folks?
> >There were many attempt at old. Could you point out?
> 
> https://lkml.org/lkml/2012/6/12/587
> Although I know you had objections to my specific implementation,
> since it kept non-volatile anonymous pages on the active list.

It breaks my goal "Hint system call should be cheap" because we need
something to move pages from active list to inactive's one in volatile
system call context and it would be never cheap.

> 
> 
> 
> thanks
> -john

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
