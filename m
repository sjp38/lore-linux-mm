Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 815B26B01CF
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 07:48:27 -0400 (EDT)
Date: Wed, 24 Mar 2010 11:48:05 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
Message-ID: <20100324114804.GF21147@csn.ul.ie>
References: <20100315130935.f8b0a2d7.akpm@linux-foundation.org> <20100322235053.GD9590@csn.ul.ie> <4e5e476b1003231435i47e5d95fg9d7eac0d14d3e26b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4e5e476b1003231435i47e5d95fg9d7eac0d14d3e26b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Corrado Zoccolo <czoccolo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 10:35:20PM +0100, Corrado Zoccolo wrote:
> Hi Mel,
> On Tue, Mar 23, 2010 at 12:50 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Mon, Mar 15, 2010 at 01:09:35PM -0700, Andrew Morton wrote:
> >> On Mon, 15 Mar 2010 13:34:50 +0100
> >> Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
> >>
> >> > c) If direct reclaim did reasonable progress in try_to_free but did not
> >> > get a page, AND there is no write in flight at all then let it try again
> >> > to free up something.
> >> > This could be extended by some kind of max retry to avoid some weird
> >> > looping cases as well.
> >> >
> >> > d) Another way might be as easy as letting congestion_wait return
> >> > immediately if there are no outstanding writes - this would keep the
> >> > behavior for cases with write and avoid the "running always in full
> >> > timeout" issue without writes.
> >>
> >> They're pretty much equivalent and would work.  But there are two
> >> things I still don't understand:
> >>
> >> 1: Why is direct reclaim calling congestion_wait() at all?  If no
> >> writes are going on there's lots of clean pagecache around so reclaim
> >> should trivially succeed.  What's preventing it from doing so?
> >>
> >> 2: This is, I think, new behaviour.  A regression.  What caused it?
> >>
> >
> > 120+ kernels and a lot of hurt later;
> >
> > Short summary - The number of times kswapd and the page allocator have been
> >        calling congestion_wait and the length of time it spends in there
> >        has been increasing since 2.6.29. Oddly, it has little to do
> >        with the page allocator itself.
> >
> > Test scenario
> > =============
> > X86-64 machine 1 socket 4 cores
> > 4 consumer-grade disks connected as RAID-0 - software raid. RAID controller
> >        on-board and a piece of crap, and a decent RAID card could blow
> >        the budget.
> > Booted mem=256 to ensure it is fully IO-bound and match closer to what
> >        Christian was doing
> >
> > At each test, the disks are partitioned, the raid arrays created and an
> > ext2 filesystem created. iozone sequential read/write tests are run with
> > increasing number of processes up to 64. Each test creates 8G of files. i.e.
> > 1 process = 8G. 2 processes = 2x4G etc
> >
> >        iozone -s 8388608 -t 1 -r 64 -i 0 -i 1
> >        iozone -s 4194304 -t 2 -r 64 -i 0 -i 1
> >        etc.
> >
> > Metrics
> > =======
> >
> > Each kernel was instrumented to collected the following stats
> >
> >        pg-Stall        Page allocator stalled calling congestion_wait
> >        pg-Wait         The amount of time spent in congestion_wait
> >        pg-Rclm         Pages reclaimed by direct reclaim
> >        ksd-stall       balance_pgdat() (ie kswapd) staled on congestion_wait
> >        ksd-wait        Time spend by balance_pgdat in congestion_wait
> >
> > Large differences in this do not necessarily show up in iozone because the
> > disks are so slow that the stalls are a tiny percentage overall. However, in
> > the event that there are many disks, it might be a greater problem. I believe
> > Christian is hitting a corner case where small delays trigger a much larger
> > stall.
> >
> > Why The Increases
> > =================
> >
> > The big problem here is that there was no one change. Instead, it has been
> > a steady build-up of a number of problems. The ones I identified are in the
> > block IO, CFQ IO scheduler, tty and page reclaim. Some of these are fixed
> > but need backporting and others I expect are a major surprise. Whether they
> > are worth backporting or not heavily depends on whether Christian's problem
> > is resolved.
> >
> > Some of the "fixes" below are obviously not fixes at all. Gathering this data
> > took a significant amount of time. It'd be nice if people more familiar with
> > the relevant problem patches could spring a theory or patch.
> >
> > The Problems
> > ============
> >
> > 1. Block layer congestion queue async/sync difficulty
> >        fix title: asyncconfusion
> >        fixed in mainline? yes, in 2.6.31
> >        affects: 2.6.30
> >
> >        2.6.30 replaced congestion queues based on read/write with sync/async
> >        in commit 1faa16d2. Problems were identified with this and fixed in
> >        2.6.31 but not backported. Backporting 8aa7e847 and 373c0a7e brings
> >        2.6.30 in line with 2.6.29 performance. It's not an issue for 2.6.31.
> >
> > 2. TTY using high order allocations more frequently
> >        fix title: ttyfix
> >        fixed in mainline? yes, in 2.6.34-rc2
> >        affects: 2.6.31 to 2.6.34-rc1
> >
> >        2.6.31 made pty's use the same buffering logic as tty.  Unfortunately,
> >        it was also allowed to make high-order GFP_ATOMIC allocations. This
> >        triggers some high-order reclaim and introduces some stalls. It's
> >        fixed in 2.6.34-rc2 but needs back-porting.
> >
> > 3. Page reclaim evict-once logic from 56e49d21 hurts really badly
> >        fix title: revertevict
> >        fixed in mainline? no
> >        affects: 2.6.31 to now
> >
> >        For reasons that are not immediately obvious, the evict-once patches
> >        *really* hurt the time spent on congestion and the number of pages
> >        reclaimed. Rik, I'm afaid I'm punting this to you for explanation
> >        because clearly you tested this for AIM7 and might have some
> >        theories. For the purposes of testing, I just reverted the changes.
> >
> > 4. CFQ scheduler fairness commit 718eee057 causes some hurt
> >        fix title: none available
> >        fixed in mainline? no
> >        affects: 2.6.33 to now
> >
> >        A bisection finger printed this patch as being a problem introduced
> >        between 2.6.32 and 2.6.33. It increases a small amount the number of
> >        times the page allocator stalls but drastically increased the number
> >        of pages reclaimed. It's not clear why the commit is such a problem.
> >
> >        Unfortunately, I could not test a revert of this patch. The CFQ and
> >        block IO changes made in this window were extremely convulated and
> >        overlapped heavily with a large number of patches altering the same
> >        code as touched by commit 718eee057. I tried reverting everything
> >        made on and after this commit but the results were unsatisfactory.
> >
> >        Hence, there is no fix in the results below
> >
> > Results
> > =======
> >
> > Here are the highlights of kernels tested. I'm omitting the bisection
> > results for obvious reasons. The metrics were gathered at two points;
> > after filesystem creation and after IOZone completed.
> >
> > The lower the number for each metric, the better.
> >
> >                                                     After Filesystem Setup                                       After IOZone
> >                                         pg-Stall  pg-Wait  pg-Rclm  ksd-stall  ksd-wait        pg-Stall  pg-Wait  pg-Rclm  ksd-stall  ksd-wait
> > 2.6.29                                          0        0        0          2         1               4        3      183        152         0
> > 2.6.30                                          1        5       34          1        25             783     3752    31939         76         0
> > 2.6.30-asyncconfusion                           0        0        0          3         1              44       60     2656        893         0
> > 2.6.30.10                                       0        0        0          2        43             777     3699    32661         74         0
> > 2.6.30.10-asyncconfusion                        0        0        0          2         1              36       88     1699       1114         0
> >
> > asyncconfusion can be back-ported easily to 2.6.30.10. Performance is not
> > perfectly in line with 2.6.29 but it's better.
> >
> > 2.6.31                                          0        0        0          3         1           49175   245727  2730626     176344         0
> > 2.6.31-revertevict                              0        0        0          3         2              31      147     1887        114         0
> > 2.6.31-ttyfix                                   0        0        0          2         2           46238   231000  2549462     170912         0
> > 2.6.31-ttyfix-revertevict                       0        0        0          3         0               7       35      448        121         0
> > 2.6.31.12                                       0        0        0          2         0           68897   344268  4050646     183523         0
> > 2.6.31.12-revertevict                           0        0        0          3         1              18       87     1009        147         0
> > 2.6.31.12-ttyfix                                0        0        0          2         0           62797   313805  3786539     173398         0
> > 2.6.31.12-ttyfix-revertevict                    0        0        0          3         2               7       35      448        199         0
> >
> > Applying the tty fixes from 2.6.34-rc2 and getting rid of the evict-once
> > patches bring things back in line with 2.6.29 again.
> >
> > Rik, any theory on evict-once?
> >
> > 2.6.32                                          0        0        0          3         2           44437   221753  2760857     132517         0
> > 2.6.32-revertevict                              0        0        0          3         2              35       14     1570        460         0
> > 2.6.32-ttyfix                                   0        0        0          2         0           60770   303206  3659254     166293         0
> > 2.6.32-ttyfix-revertevict                       0        0        0          3         0              55       62     2496        494         0
> > 2.6.32.10                                       0        0        0          2         1           90769   447702  4251448     234868         0
> > 2.6.32.10-revertevict                           0        0        0          3         2             148      597     8642        478         0
> > 2.6.32.10-ttyfix                                0        0        0          3         0           91729   453337  4374070     238593         0
> > 2.6.32.10-ttyfix-revertevict                    0        0        0          3         1              65      146     3408        347         0
> >
> > Again, fixing tty and reverting evict-once helps bring figures more in line
> > with 2.6.29.
> >
> > 2.6.33                                          0        0        0          3         0          152248   754226  4940952     267214         0
> > 2.6.33-revertevict                              0        0        0          3         0             883     4306    28918        507         0
> > 2.6.33-ttyfix                                   0        0        0          3         0          157831   782473  5129011     237116         0
> > 2.6.33-ttyfix-revertevict                       0        0        0          2         0            1056     5235    34796        519         0
> > 2.6.33.1                                        0        0        0          3         1          156422   776724  5078145     234938         0
> > 2.6.33.1-revertevict                            0        0        0          2         0            1095     5405    36058        477         0
> > 2.6.33.1-ttyfix                                 0        0        0          3         1          136324   673148  4434461     236597         0
> > 2.6.33.1-ttyfix-revertevict                     0        0        0          1         1            1339     6624    43583        466         0
> >
> > At this point, the CFQ commit "cfq-iosched: fairness for sync no-idle
> > queues" has lodged itself deep within CGQ and I couldn't tear it out or
> > see how to fix it. Fixing tty and reverting evict-once helps but the number
> > of stalls is significantly increased and a much larger number of pages get
> > reclaimed overall.
> >
> > Corrado?
> 
> The major changes in I/O scheduing behaviour are:
> * buffered writes:
>    before we could schedule few writes, then interrupt them to do
>   some reads, and then go back to writes; now we guarantee some
>   uninterruptible time slice for writes, but the delay between two
>   slices is increased. The total write throughput averaged over a time
>   window larger than 300ms should be comparable, or even better with
>   2.6.33. Note that the commit you cite has introduced a bug regarding
>   write throughput on NCQ disks that was later fixed by 1efe8fe1, merged
>   before 2.6.33 (this may lead to confusing bisection results).

This is true. The CFQ and block IO changes in that window are almost
impossible to properly bisect and isolate individual changes. There were
multiple dependant patches that modified each others changes. It's unclear
if this modification can even be isolated although your suggestion below
is the best bet.

> * reads (and sync writes):
>   * before, we serviced a single process for 100ms, then switched to
>     an other, and so on.
>   * after, we go round robin for random requests (they get a unified
>     time slice, like buffered writes do), and we have consecutive time
>     slices for sequential requests, but the length of the slice is reduced
>     when the number of concurrent processes doing I/O increases.
> 
> This means that with 16 processes doing sequential I/O on the same
> disk, before you were switching between processes every 100ms, and now
> every 32ms. The old behaviour can be brought back by setting
> /sys/block/sd*/queue/iosched/low_latency to 0.

Will try this and see what happens.

> For random I/O, the situation (going round robin, it will translate to
> switching every 8 ms on average) is not revertable via flags.
> 

At the moment, I'm not testing random IO so it shouldn't be a factor in
the tests.

> >
> > 2.6.34-rc1                                      0        0        0          1         1          150629   746901  4895328     239233         0
> > 2.6.34-rc1-revertevict                          0        0        0          1         0            2595    12901    84988        622         0
> > 2.6.34-rc1-ttyfix                               0        0        0          1         1          159603   791056  5186082     223458         0
> > 2.6.34-rc1-ttyfix-revertevict                   0        0        0          0         0            1549     7641    50484        679         0
> >
> > Again, ttyfix and revertevict help a lot but CFQ needs to be fixed to get
> > back to 2.6.29 performance.
> >
> > Next Steps
> > ==========
> >
> > Jens, any problems with me backporting the async/sync fixes from 2.6.31 to
> > 2.6.30.x (assuming that is still maintained, Greg?)?
> >
> > Rik, any suggestions on what can be done with evict-once?
> >
> > Corrado, any suggestions on what can be done with CFQ?
> 
> If my intuition that switching between processes too often is
> detrimental when you have memory pressure (higher probability to need
> to re-page-in some of the pages that were just discarded), I suggest
> trying setting low_latency to 0, and maybe increasing the slice_sync
> (to get more slice to a single process before switching to an other),
> slice_async (to give more uninterruptible time to buffered writes) and
> slice_async_rq (to higher the limit of consecutive write requests can
> be sent to disk).
> While this would normally lead to a bad user experience on a system
> with plenty of memory, it should keep things acceptable when paging in
> / swapping / dirty page writeback is overwhelming.
> 

Christian, would you be able to follow the same instructions and see can
you make a difference to your test? It is known for your situation that
memory is unusually low for size of your workload so it's a possibility.

Thanks Corrado.

> Corrado
> 
> >
> > Christian, can you test the following amalgamated patch on 2.6.32.10 and
> > 2.6.33 please? Note it's 2.6.32.10 because the patches below will not apply
> > cleanly to 2.6.32 but it will against 2.6.33. It's a combination of ttyfix
> > and revertevict. If your problem goes away, it implies that the stalls I
> > can measure are roughly correlated to the more significant problem you have.
> >
> > ===== CUT HERE =====
> >
> > From d9661adfb8e53a7647360140af3b92284cbe52d4 Mon Sep 17 00:00:00 2001
> > From: Alan Cox <alan@linux.intel.com>
> > Date: Thu, 18 Feb 2010 16:43:47 +0000
> > Subject: [PATCH] tty: Keep the default buffering to sub-page units
> >
> > We allocate during interrupts so while our buffering is normally diced up
> > small anyway on some hardware at speed we can pressure the VM excessively
> > for page pairs. We don't really need big buffers to be linear so don't try
> > so hard.
> >
> > In order to make this work well we will tidy up excess callers to request_room,
> > which cannot itself enforce this break up.
> >
> > Signed-off-by: Alan Cox <alan@linux.intel.com>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> >
> > diff --git a/drivers/char/tty_buffer.c b/drivers/char/tty_buffer.c
> > index 66fa4e1..f27c4d6 100644
> > --- a/drivers/char/tty_buffer.c
> > +++ b/drivers/char/tty_buffer.c
> > @@ -247,7 +247,8 @@ int tty_insert_flip_string(struct tty_struct *tty, const unsigned char *chars,
> >  {
> >        int copied = 0;
> >        do {
> > -               int space = tty_buffer_request_room(tty, size - copied);
> > +               int goal = min(size - copied, TTY_BUFFER_PAGE);
> > +               int space = tty_buffer_request_room(tty, goal);
> >                struct tty_buffer *tb = tty->buf.tail;
> >                /* If there is no space then tb may be NULL */
> >                if (unlikely(space == 0))
> > @@ -283,7 +284,8 @@ int tty_insert_flip_string_flags(struct tty_struct *tty,
> >  {
> >        int copied = 0;
> >        do {
> > -               int space = tty_buffer_request_room(tty, size - copied);
> > +               int goal = min(size - copied, TTY_BUFFER_PAGE);
> > +               int space = tty_buffer_request_room(tty, goal);
> >                struct tty_buffer *tb = tty->buf.tail;
> >                /* If there is no space then tb may be NULL */
> >                if (unlikely(space == 0))
> > diff --git a/include/linux/tty.h b/include/linux/tty.h
> > index 6abfcf5..d96e588 100644
> > --- a/include/linux/tty.h
> > +++ b/include/linux/tty.h
> > @@ -68,6 +68,16 @@ struct tty_buffer {
> >        unsigned long data[0];
> >  };
> >
> > +/*
> > + * We default to dicing tty buffer allocations to this many characters
> > + * in order to avoid multiple page allocations. We assume tty_buffer itself
> > + * is under 256 bytes. See tty_buffer_find for the allocation logic this
> > + * must match
> > + */
> > +
> > +#define TTY_BUFFER_PAGE                ((PAGE_SIZE  - 256) / 2)
> > +
> > +
> >  struct tty_bufhead {
> >        struct delayed_work work;
> >        spinlock_t lock;
> > From 352fa6ad16b89f8ffd1a93b4419b1a8f2259feab Mon Sep 17 00:00:00 2001
> > From: Mel Gorman <mel@csn.ul.ie>
> > Date: Tue, 2 Mar 2010 22:24:19 +0000
> > Subject: [PATCH] tty: Take a 256 byte padding into account when buffering below sub-page units
> >
> > The TTY layer takes some care to ensure that only sub-page allocations
> > are made with interrupts disabled. It does this by setting a goal of
> > "TTY_BUFFER_PAGE" to allocate. Unfortunately, while TTY_BUFFER_PAGE takes the
> > size of tty_buffer into account, it fails to account that tty_buffer_find()
> > rounds the buffer size out to the next 256 byte boundary before adding on
> > the size of the tty_buffer.
> >
> > This patch adjusts the TTY_BUFFER_PAGE calculation to take into account the
> > size of the tty_buffer and the padding. Once applied, tty_buffer_alloc()
> > should not require high-order allocations.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Cc: stable <stable@kernel.org>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> >
> > diff --git a/include/linux/tty.h b/include/linux/tty.h
> > index 568369a..593228a 100644
> > --- a/include/linux/tty.h
> > +++ b/include/linux/tty.h
> > @@ -70,12 +70,13 @@ struct tty_buffer {
> >
> >  /*
> >  * We default to dicing tty buffer allocations to this many characters
> > - * in order to avoid multiple page allocations. We assume tty_buffer itself
> > - * is under 256 bytes. See tty_buffer_find for the allocation logic this
> > - * must match
> > + * in order to avoid multiple page allocations. We know the size of
> > + * tty_buffer itself but it must also be taken into account that the
> > + * the buffer is 256 byte aligned. See tty_buffer_find for the allocation
> > + * logic this must match
> >  */
> >
> > -#define TTY_BUFFER_PAGE                ((PAGE_SIZE  - 256) / 2)
> > +#define TTY_BUFFER_PAGE        (((PAGE_SIZE - sizeof(struct tty_buffer)) / 2) & ~0xFF)
> >
> >
> >  struct tty_bufhead {
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index bf9213b..5ba0d9a 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -94,7 +94,6 @@ extern void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
> >  extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
> >                                                        int priority);
> >  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> > -int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> >  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> >                                       struct zone *zone,
> >                                       enum lru_list lru);
> > @@ -243,12 +242,6 @@ mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
> >        return 1;
> >  }
> >
> > -static inline int
> > -mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
> > -{
> > -       return 1;
> > -}
> > -
> >  static inline unsigned long
> >  mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
> >                         enum lru_list lru)
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 66035bf..bbb0eda 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -843,17 +843,6 @@ int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
> >        return 0;
> >  }
> >
> > -int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
> > -{
> > -       unsigned long active;
> > -       unsigned long inactive;
> > -
> > -       inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
> > -       active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
> > -
> > -       return (active > inactive);
> > -}
> > -
> >  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> >                                       struct zone *zone,
> >                                       enum lru_list lru)
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 692807f..5512301 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1428,59 +1428,13 @@ static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
> >        return low;
> >  }
> >
> > -static int inactive_file_is_low_global(struct zone *zone)
> > -{
> > -       unsigned long active, inactive;
> > -
> > -       active = zone_page_state(zone, NR_ACTIVE_FILE);
> > -       inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> > -
> > -       return (active > inactive);
> > -}
> > -
> > -/**
> > - * inactive_file_is_low - check if file pages need to be deactivated
> > - * @zone: zone to check
> > - * @sc:   scan control of this context
> > - *
> > - * When the system is doing streaming IO, memory pressure here
> > - * ensures that active file pages get deactivated, until more
> > - * than half of the file pages are on the inactive list.
> > - *
> > - * Once we get to that situation, protect the system's working
> > - * set from being evicted by disabling active file page aging.
> > - *
> > - * This uses a different ratio than the anonymous pages, because
> > - * the page cache uses a use-once replacement algorithm.
> > - */
> > -static int inactive_file_is_low(struct zone *zone, struct scan_control *sc)
> > -{
> > -       int low;
> > -
> > -       if (scanning_global_lru(sc))
> > -               low = inactive_file_is_low_global(zone);
> > -       else
> > -               low = mem_cgroup_inactive_file_is_low(sc->mem_cgroup);
> > -       return low;
> > -}
> > -
> > -static int inactive_list_is_low(struct zone *zone, struct scan_control *sc,
> > -                               int file)
> > -{
> > -       if (file)
> > -               return inactive_file_is_low(zone, sc);
> > -       else
> > -               return inactive_anon_is_low(zone, sc);
> > -}
> > -
> >  static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
> >        struct zone *zone, struct scan_control *sc, int priority)
> >  {
> >        int file = is_file_lru(lru);
> >
> > -       if (is_active_lru(lru)) {
> > -               if (inactive_list_is_low(zone, sc, file))
> > -                   shrink_active_list(nr_to_scan, zone, sc, priority, file);
> > +       if (lru == LRU_ACTIVE_FILE) {
> > +               shrink_active_list(nr_to_scan, zone, sc, priority, file);
> >                return 0;
> >        }
> >

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
