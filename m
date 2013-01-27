Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 7B32D6B0005
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 19:26:36 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp8so72434pbb.20
        for <linux-mm@kvack.org>; Sat, 26 Jan 2013 16:26:35 -0800 (PST)
Message-ID: <1359246393.4159.1.camel@kernel>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sat, 26 Jan 2013 18:26:33 -0600
In-Reply-To: <CAH9JG2UpVtxeLB21kx5-_pokK8p_uVZ-2o41Ep--oOyKStBZFQ@mail.gmail.com>
References: <20130122065341.GA1850@kernel.org>
	 <20130123075808.GH2723@blaptop> <1359018598.2866.5.camel@kernel>
	 <CAH9JG2UpVtxeLB21kx5-_pokK8p_uVZ-2o41Ep--oOyKStBZFQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Sat, 2013-01-26 at 13:40 +0900, Kyungmin Park wrote:
> Hi,
> 
> On 1/24/13, Simon Jeons <simon.jeons@gmail.com> wrote:
> > Hi Minchan,
> > On Wed, 2013-01-23 at 16:58 +0900, Minchan Kim wrote:
> >> On Tue, Jan 22, 2013 at 02:53:41PM +0800, Shaohua Li wrote:
> >> > Hi,
> >> >
> >> > Because of high density, low power and low price, flash storage (SSD) is
> >> > a good
> >> > candidate to partially replace DRAM. A quick answer for this is using
> >> > SSD as
> >> > swap. But Linux swap is designed for slow hard disk storage. There are a
> >> > lot of
> >> > challenges to efficiently use SSD for swap:
> >>
> >> Many of below item could be applied in in-memory swap like zram, zcache.
> >>
> >> >
> >> > 1. Lock contentions (swap_lock, anon_vma mutex, swap address space
> >> > lock)
> >> > 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB
> >> > flush. This
> >> > overhead is very high even in a normal 2-socket machine.
> >> > 3. Better swap IO pattern. Both direct and kswapd page reclaim can do
> >> > swap,
> >> > which makes swap IO pattern is interleave. Block layer isn't always
> >> > efficient
> >> > to do request merge. Such IO pattern also makes swap prefetch hard.
> >>
> >> Agreed.
> >>
> >> > 4. Swap map scan overhead. Swap in-memory map scan scans an array, which
> >> > is
> >> > very inefficient, especially if swap storage is fast.
> >>
> >> Agreed.
> >>
> 

HI Kyungmin,

> 5. SSD related optimization, mainly discard support.
> 
> Now swap codes are based on each swap slots. it means it can't
> optimize discard feature since getting meaningful performance gain, it
> requires 2 pages at least. Of course it's based on eMMC. In case of
> SSD. it requires more pages to support discard.

Could explain 2 pages or more pages you mentioned used for what? Why
need it? I'm interested in.

> 
> To address issue. I consider the batched discard approach used at filesystem.
> *Sometime* scan all empty slot and it issues discard continuous swap
> slots as many as possible.
> 
> How to you think?
> 
> Thank you,
> Kyungmin Park
> 
> P.S., It's almost same topics to optimize the eMMC with swap. I mean
> I"m very interested with this topics.
> 
> >> > 6. Better swap prefetch algorithm. Besides item 3, sequentially accessed
> >> > pages
> >> > aren't always in LRU list adjacently, so page reclaim will not swap such
> >> > pages
> >> > in adjacent storage sectors. This makes swap prefetch hard.
> >>
> >> One of problem is LRU churning and I wanted to try to fix it.
> >> http://marc.info/?l=linux-mm&m=130978831028952&w=4
> >>
> >> > 7. Alternative page reclaim policy to bias reclaiming anonymous page.
> >> > Currently reclaim anonymous page is considering harder than reclaim file
> >> > pages,
> >> > so we bias reclaiming file pages. If there are high speed swap storage,
> >> > we are
> >> > considering doing swap more aggressively.
> >>
> >> Yeb. We need it. I tried it with extending vm_swappiness to 200.
> >>
> >> From: Minchan Kim <minchan@kernel.org>
> >> Date: Mon, 3 Dec 2012 16:21:00 +0900
> >> Subject: [PATCH] mm: increase swappiness to 200
> >>
> >> We have thought swap out cost is very high but it's not true
> >> if we use fast device like swap-over-zram. Nonetheless, we can
> >> swap out 1:1 ratio of anon and page cache at most.
> >> It's not enough to use swap device fully so we encounter OOM kill
> >> while there are many free space in zram swap device. It's never
> >> what we want.
> >>
> >> This patch makes swap out aggressively.
> >>
> >> Cc: Luigi Semenzato <semenzato@google.com>
> >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> ---
> >>  kernel/sysctl.c |    3 ++-
> >>  mm/vmscan.c     |    6 ++++--
> >>  2 files changed, 6 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> >> index 693e0ed..f1dbd9d 100644
> >> --- a/kernel/sysctl.c
> >> +++ b/kernel/sysctl.c
> >> @@ -130,6 +130,7 @@ static int __maybe_unused two = 2;
> >>  static int __maybe_unused three = 3;
> >>  static unsigned long one_ul = 1;
> >>  static int one_hundred = 100;
> >> +extern int max_swappiness;
> >>  #ifdef CONFIG_PRINTK
> >>  static int ten_thousand = 10000;
> >>  #endif
> >> @@ -1157,7 +1158,7 @@ static struct ctl_table vm_table[] = {
> >>                 .mode           = 0644,
> >>                 .proc_handler   = proc_dointvec_minmax,
> >>                 .extra1         = &zero,
> >> -               .extra2         = &one_hundred,
> >> +               .extra2         = &max_swappiness,
> >>         },
> >>  #ifdef CONFIG_HUGETLB_PAGE
> >>         {
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 53dcde9..64f3c21 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -53,6 +53,8 @@
> >>  #define CREATE_TRACE_POINTS
> >>  #include <trace/events/vmscan.h>
> >>
> >> +int max_swappiness = 200;
> >> +
> >>  struct scan_control {
> >>         /* Incremented by the number of inactive pages that were scanned
> >> */
> >>         unsigned long nr_scanned;
> >> @@ -1626,6 +1628,7 @@ static int vmscan_swappiness(struct scan_control
> >> *sc)
> >>         return mem_cgroup_swappiness(sc->target_mem_cgroup);
> >>  }
> >>
> >> +
> >>  /*
> >>   * Determine how aggressively the anon and file LRU lists should be
> >>   * scanned.  The relative value of each set of LRU lists is determined
> >> @@ -1701,11 +1704,10 @@ static void get_scan_count(struct lruvec *lruvec,
> >> struct scan_control *sc,
> >>         }
> >>
> >>         /*
> >> -        * With swappiness at 100, anonymous and file have the same
> >> priority.
> >>          * This scanning priority is essentially the inverse of IO cost.
> >>          */
> >>         anon_prio = vmscan_swappiness(sc);
> >> -       file_prio = 200 - anon_prio;
> >> +       file_prio = max_swappiness - anon_prio;
> >>
> >>         /*
> >>          * OK, so we have swap space and a fair amount of page cache
> >> --
> >> 1.7.9.5
> >>
> >> > 8. Huge page swap. Huge page swap can solve a lot of problems above, but
> >> > both
> >> > THP and hugetlbfs don't support swap.
> >>
> >> Another items are indirection layers. Please read Rik's mail below.
> >> Indirection layers could give many flexibility to backends and helpful
> >> for defragmentation.
> >>
> >> One of idea I am considering is that makes hierarchy swap devides,
> >> NOT priority-based. I mean currently swap devices are used up by prioirty
> >> order.
> >> It's not good fit if we use fast swap and slow swap at the same time.
> >> I'd like to consume fast swap device (ex, in-memory swap) firstly, then
> >> I want to migrate some of swap pages from fast swap to slow swap to
> >> make room for fast swap. It could solve below concern.
> >> In addition, buffering via in-memory swap could make big chunk which is
> >> aligned
> >> to slow device's block size so migration speed from fast swap to slow
> >> swap
> >> could be enhanced so wear out problem would go away, too.
> >>
> >> Quote from last KS2012 - http://lwn.net/Articles/516538/
> >> "Andrea Arcangeli was also concerned that the first pages to be evicted
> >> from
> >> memory are, by definition of the LRU page order, the ones that are least
> >> likely
> >> to be used in the future. These are the pages that should be going to
> >> secondary
> >> storage and more frequently used pages should be going to zcache. As it
> >> stands,
> >> zcache may fill up with no-longer-used pages and then the system continues
> >> to
> >> move used pages from and to the disk."
> >>
> >> From riel@redhat.com Sun Apr 10 17:50:10 2011
> >> Date: Sun, 10 Apr 2011 20:50:01 -0400
> >> From: Rik van Riel <riel@redhat.com>
> >> To: Linux Memory Management List <linux-mm@kvack.org>
> >> Subject: [LSF/Collab] swap cache redesign idea
> >>
> >> On Thursday after LSF, Hugh, Minchan, Mel, Johannes and I were
> >> sitting in the hallway talking about yet more VM things.
> >>
> >> During that discussion, we came up with a way to redesign the
> >> swap cache.  During my flight home, I came with ideas on how
> >> to use that redesign, that may make the changes worthwhile.
> >>
> >> Currently, the page table entries that have swapped out pages
> >> associated with them contain a swap entry, pointing directly
> >> at the swap device and swap slot containing the data. Meanwhile,
> >> the swap count lives in a separate array.
> >>
> >> The redesign we are considering moving the swap entry to the
> >> page cache radix tree for the swapper_space and having the pte
> >> contain only the offset into the swapper_space.  The swap count
> >> info can also fit inside the swapper_space page cache radix
> >> tree (at least on 64 bits - on 32 bits we may need to get
> >> creative or accept a smaller max amount of swap space).
> >>
> >> This extra layer of indirection allows us to do several things:
> >>
> >> 1) get rid of the virtual address scanning swapoff; instead
> >>     we just swap the data in and mark the pages as present in
> >>     the swapper_space radix tree
> >
> > If radix tree will store all rmap to the pages? If not, how to position
> > the pages?
> >
> >>
> >> 2) free swap entries as the are read in, without waiting for
> >>     the process to fault it in - this may be useful for memory
> >>     types that have a large erase block
> >>
> >> 3) together with the defragmentation from (2), we can always
> >>     do writes in large aligned blocks - the extra indirection
> >>     will make it relatively easy to have special backend code
> >>     for different kinds of swap space, since all the state can
> >>     now live in just one place
> >>
> >> 4) skip writeout of zero-filled pages - this can be a big help
> >>     for KVM virtual machines running Windows, since Windows zeroes
> >>     out free pages;   simply discarding a zero-filled page is not
> >>     at all simple in the current VM, where we would have to iterate
> >>     over all the ptes to free the swap entry before being able to
> >>     free the swap cache page (I am not sure how that locking would
> >>     even work)
> >>
> >>     with the extra layer of indirection, the locking for this scheme
> >>     can be trivial - either the faulting process gets the old page,
> >>     or it gets a new one, either way it'll be zero filled
> >>
> >> 5) skip writeout of pages the guest has marked as free - same as
> >>     above, with the same easier locking
> >>
> >> Only one real question remaining - how do we handle the swap count
> >> in the new scheme?  On 64 bit systems we have enough space in the
> >> radix tree, on 32 bit systems maybe we'll have to start overflowing
> >> into the "swap_count_continued" logic a little sooner than we are
> >> now and reduce the maximum swap size a little?
> >>
> >> >
> >> > I had some progresses in these areas recently:
> >> > http://marc.info/?l=linux-mm&m=134665691021172&w=2
> >> > http://marc.info/?l=linux-mm&m=135336039115191&w=2
> >> > http://marc.info/?l=linux-mm&m=135882182225444&w=2
> >> > http://marc.info/?l=linux-mm&m=135754636926984&w=2
> >> > http://marc.info/?l=linux-mm&m=135754634526979&w=2
> >> > But a lot of problems remain. I'd like to discuss the issues at the
> >> > meeting.
> >>
> >> I have an interest on this topic.
> >> Thnaks.
> >>
> >> >
> >> > Thanks,
> >> > Shaohua
> >> >
> >> > --
> >> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> > the body to majordomo@kvack.org.  For more info on Linux MM,
> >> > see: http://www.linux-mm.org/ .
> >> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>
> >
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
