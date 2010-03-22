Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC1C56B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 19:51:17 -0400 (EDT)
Date: Mon, 22 Mar 2010 23:50:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
Message-ID: <20100322235053.GD9590@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100315130935.f8b0a2d7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 01:09:35PM -0700, Andrew Morton wrote:
> On Mon, 15 Mar 2010 13:34:50 +0100
> Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
> 
> > c) If direct reclaim did reasonable progress in try_to_free but did not
> > get a page, AND there is no write in flight at all then let it try again
> > to free up something.
> > This could be extended by some kind of max retry to avoid some weird
> > looping cases as well.
> > 
> > d) Another way might be as easy as letting congestion_wait return
> > immediately if there are no outstanding writes - this would keep the 
> > behavior for cases with write and avoid the "running always in full 
> > timeout" issue without writes.
> 
> They're pretty much equivalent and would work.  But there are two
> things I still don't understand:
> 
> 1: Why is direct reclaim calling congestion_wait() at all?  If no
> writes are going on there's lots of clean pagecache around so reclaim
> should trivially succeed.  What's preventing it from doing so?
> 
> 2: This is, I think, new behaviour.  A regression.  What caused it?
> 

120+ kernels and a lot of hurt later;

Short summary - The number of times kswapd and the page allocator have been
	calling congestion_wait and the length of time it spends in there
	has been increasing since 2.6.29. Oddly, it has little to do
	with the page allocator itself.

Test scenario
=============
X86-64 machine 1 socket 4 cores
4 consumer-grade disks connected as RAID-0 - software raid. RAID controller
	on-board and a piece of crap, and a decent RAID card could blow
	the budget.
Booted mem=256 to ensure it is fully IO-bound and match closer to what
	Christian was doing

At each test, the disks are partitioned, the raid arrays created and an
ext2 filesystem created. iozone sequential read/write tests are run with
increasing number of processes up to 64. Each test creates 8G of files. i.e.
1 process = 8G. 2 processes = 2x4G etc

	iozone -s 8388608 -t 1 -r 64 -i 0 -i 1
	iozone -s 4194304 -t 2 -r 64 -i 0 -i 1
	etc.

Metrics
=======

Each kernel was instrumented to collected the following stats

	pg-Stall	Page allocator stalled calling congestion_wait
	pg-Wait		The amount of time spent in congestion_wait
	pg-Rclm		Pages reclaimed by direct reclaim
	ksd-stall	balance_pgdat() (ie kswapd) staled on congestion_wait
	ksd-wait	Time spend by balance_pgdat in congestion_wait

Large differences in this do not necessarily show up in iozone because the
disks are so slow that the stalls are a tiny percentage overall. However, in
the event that there are many disks, it might be a greater problem. I believe
Christian is hitting a corner case where small delays trigger a much larger
stall.

Why The Increases
=================

The big problem here is that there was no one change. Instead, it has been
a steady build-up of a number of problems. The ones I identified are in the
block IO, CFQ IO scheduler, tty and page reclaim. Some of these are fixed
but need backporting and others I expect are a major surprise. Whether they
are worth backporting or not heavily depends on whether Christian's problem
is resolved.

Some of the "fixes" below are obviously not fixes at all. Gathering this data
took a significant amount of time. It'd be nice if people more familiar with
the relevant problem patches could spring a theory or patch.

The Problems
============

1. Block layer congestion queue async/sync difficulty
	fix title: asyncconfusion
	fixed in mainline? yes, in 2.6.31
	affects: 2.6.30

	2.6.30 replaced congestion queues based on read/write with sync/async
	in commit 1faa16d2. Problems were identified with this and fixed in
	2.6.31 but not backported. Backporting 8aa7e847 and 373c0a7e brings
	2.6.30 in line with 2.6.29 performance. It's not an issue for 2.6.31.

2. TTY using high order allocations more frequently
	fix title: ttyfix
	fixed in mainline? yes, in 2.6.34-rc2
	affects: 2.6.31 to 2.6.34-rc1

	2.6.31 made pty's use the same buffering logic as tty.	Unfortunately,
	it was also allowed to make high-order GFP_ATOMIC allocations. This
	triggers some high-order reclaim and introduces some stalls. It's
	fixed in 2.6.34-rc2 but needs back-porting.

3. Page reclaim evict-once logic from 56e49d21 hurts really badly
	fix title: revertevict
	fixed in mainline? no
	affects: 2.6.31 to now

	For reasons that are not immediately obvious, the evict-once patches
	*really* hurt the time spent on congestion and the number of pages
	reclaimed. Rik, I'm afaid I'm punting this to you for explanation
	because clearly you tested this for AIM7 and might have some
	theories. For the purposes of testing, I just reverted the changes.

4. CFQ scheduler fairness commit 718eee057 causes some hurt
	fix title: none available
	fixed in mainline? no
	affects: 2.6.33 to now

	A bisection finger printed this patch as being a problem introduced
	between 2.6.32 and 2.6.33. It increases a small amount the number of
	times the page allocator stalls but drastically increased the number
	of pages reclaimed. It's not clear why the commit is such a problem.

	Unfortunately, I could not test a revert of this patch. The CFQ and
	block IO changes made in this window were extremely convulated and
	overlapped heavily with a large number of patches altering the same
	code as touched by commit 718eee057. I tried reverting everything
	made on and after this commit but the results were unsatisfactory.

	Hence, there is no fix in the results below

Results
=======

Here are the highlights of kernels tested. I'm omitting the bisection
results for obvious reasons. The metrics were gathered at two points;
after filesystem creation and after IOZone completed.

The lower the number for each metric, the better.

                                                     After Filesystem Setup                                       After IOZone
                                         pg-Stall  pg-Wait  pg-Rclm  ksd-stall  ksd-wait        pg-Stall  pg-Wait  pg-Rclm  ksd-stall  ksd-wait
2.6.29                                          0        0        0          2         1               4        3      183        152         0
2.6.30                                          1        5       34          1        25             783     3752    31939         76         0
2.6.30-asyncconfusion                           0        0        0          3         1              44       60     2656        893         0
2.6.30.10                                       0        0        0          2        43             777     3699    32661         74         0
2.6.30.10-asyncconfusion                        0        0        0          2         1              36       88     1699       1114         0

asyncconfusion can be back-ported easily to 2.6.30.10. Performance is not
perfectly in line with 2.6.29 but it's better.

2.6.31                                          0        0        0          3         1           49175   245727  2730626     176344         0
2.6.31-revertevict                              0        0        0          3         2              31      147     1887        114         0
2.6.31-ttyfix                                   0        0        0          2         2           46238   231000  2549462     170912         0
2.6.31-ttyfix-revertevict                       0        0        0          3         0               7       35      448        121         0
2.6.31.12                                       0        0        0          2         0           68897   344268  4050646     183523         0
2.6.31.12-revertevict                           0        0        0          3         1              18       87     1009        147         0
2.6.31.12-ttyfix                                0        0        0          2         0           62797   313805  3786539     173398         0
2.6.31.12-ttyfix-revertevict                    0        0        0          3         2               7       35      448        199         0

Applying the tty fixes from 2.6.34-rc2 and getting rid of the evict-once
patches bring things back in line with 2.6.29 again.

Rik, any theory on evict-once?

2.6.32                                          0        0        0          3         2           44437   221753  2760857     132517         0
2.6.32-revertevict                              0        0        0          3         2              35       14     1570        460         0
2.6.32-ttyfix                                   0        0        0          2         0           60770   303206  3659254     166293         0
2.6.32-ttyfix-revertevict                       0        0        0          3         0              55       62     2496        494         0
2.6.32.10                                       0        0        0          2         1           90769   447702  4251448     234868         0
2.6.32.10-revertevict                           0        0        0          3         2             148      597     8642        478         0
2.6.32.10-ttyfix                                0        0        0          3         0           91729   453337  4374070     238593         0
2.6.32.10-ttyfix-revertevict                    0        0        0          3         1              65      146     3408        347         0

Again, fixing tty and reverting evict-once helps bring figures more in line
with 2.6.29.

2.6.33                                          0        0        0          3         0          152248   754226  4940952     267214         0
2.6.33-revertevict                              0        0        0          3         0             883     4306    28918        507         0
2.6.33-ttyfix                                   0        0        0          3         0          157831   782473  5129011     237116         0
2.6.33-ttyfix-revertevict                       0        0        0          2         0            1056     5235    34796        519         0
2.6.33.1                                        0        0        0          3         1          156422   776724  5078145     234938         0
2.6.33.1-revertevict                            0        0        0          2         0            1095     5405    36058        477         0
2.6.33.1-ttyfix                                 0        0        0          3         1          136324   673148  4434461     236597         0
2.6.33.1-ttyfix-revertevict                     0        0        0          1         1            1339     6624    43583        466         0

At this point, the CFQ commit "cfq-iosched: fairness for sync no-idle
queues" has lodged itself deep within CGQ and I couldn't tear it out or
see how to fix it. Fixing tty and reverting evict-once helps but the number
of stalls is significantly increased and a much larger number of pages get
reclaimed overall.

Corrado?

2.6.34-rc1                                      0        0        0          1         1          150629   746901  4895328     239233         0
2.6.34-rc1-revertevict                          0        0        0          1         0            2595    12901    84988        622         0
2.6.34-rc1-ttyfix                               0        0        0          1         1          159603   791056  5186082     223458         0
2.6.34-rc1-ttyfix-revertevict                   0        0        0          0         0            1549     7641    50484        679         0

Again, ttyfix and revertevict help a lot but CFQ needs to be fixed to get
back to 2.6.29 performance.

Next Steps
==========

Jens, any problems with me backporting the async/sync fixes from 2.6.31 to
2.6.30.x (assuming that is still maintained, Greg?)?

Rik, any suggestions on what can be done with evict-once?

Corrado, any suggestions on what can be done with CFQ?

Christian, can you test the following amalgamated patch on 2.6.32.10 and
2.6.33 please? Note it's 2.6.32.10 because the patches below will not apply
cleanly to 2.6.32 but it will against 2.6.33. It's a combination of ttyfix
and revertevict. If your problem goes away, it implies that the stalls I
can measure are roughly correlated to the more significant problem you have.

===== CUT HERE =====
