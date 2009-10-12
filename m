Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5076B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 09:43:29 -0400 (EDT)
Date: Mon, 12 Oct 2009 14:43:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091012134328.GB8200@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910050714.01908.elendil@planet.nl> <200910050851.02056.elendil@planet.nl> <200910120110.28061.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200910120110.28061.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 12, 2009 at 01:10:25AM +0200, Frans Pop wrote:
> Sorry for going quiet on this issue for a few days, but I have been 
> spending *a lot* of time on it. I've done what amounts to 5 bisection 
> rounds at ~20 minutes per iteration and in total over 80 boots.
> 
> The problem with my first bisection was that there are *at least two* 
> changes at the root of this issue, both committed between .30 and .30-rc1. 
> Because of this a normal bisection will not lead to a reliable result and 
> even with my last effort I can only narrow it down to two different areas, 
> and not 100% to specific commits.
> 

Thanks very much for your detailed work on this.

> The two identified areas are:
> 1) a wireless merge which causes the SKB errors to appear in the first
>    place, but not always;
> 2) an mm merge which makes the SKB errors occur *much* quicker; IMHO this
>    is the change that also causes the regressions reported by Pekka and
>    Karol.
> 
> So below my results. The issue is both complex and subtle. Now it's up to 
> you, domain experts for both mm *and* wireless/networking, to make sense of 
> it all and come up with suggestions on how to proceed.
> 
> I've improved my test and it's now a lot more reliable, but there are still 
> timing influences.

The timing influences is probably because kswapd is working from the
time memory gets full. High-order allocation failures would cause it to
start reclaiming at that order so it's a race always to see can it do
its work before an atomic allocation fails or not.

> Also, because this is all merge-window stuff, I'm 
> hitting quite a few minor and major regressions between commits that can 
> affect tests.
> 
> Please study the information below carefully. I know it's long, but I think 
> this issue justifies that.
> 

Agreed. I'll be looking at commits, both wireless and mm but obviously
anything I saw about wireless needs to be taken with a generous dose of
salt.

> On Monday 05 October 2009, Frans Pop wrote:
> > This looks conclusive. I tested .30 and .32-rc3 from clean reboots and
> > only starting gitk. I only started music playing in the background
> > (amarok) from an NFS share to ensure network activity.
> >
> > With .32-rc3 I got 4 SKB allocation errors while starting the *second*
> > gitk instance. And the system was completely frozen with music stopped
> > until gitk finished loading.
> 
> With .32-rc3, .31.1 and vanilla .31 I will get multiple SKB allocation 
> errors the *first time* I run the test, *every* time.
> 

So, this remains a current problem that wasn't solved by accident.

> > With .30 I was able to start *three* gitk's (which meant 2 of them got
> > (partially) swapped out) without any allocation errors. And with the
> > system remaining relatively responsive. There was a short break in the
> > music while I started the 2nd instance, but it just continued playing
> > afterwards. There was also some mild latency in the mouse cursor, but
> > nothing like the full desktop freeze I get with .32-rc3.
> 
> With both .30.2 and vanilla .30 I have *never* been able to get any SKB 
> allocation errors. No matter how often I repeat the test.
> 
> So, the start and end position are 100% reproducible. Problem is that this 
> changes during the bisection. At some point the test will fail (no SKB 
> errors) the first time I run it, but it will fail on the second or third 
> attempt.
> Apparently at some point memory must already be fragmented (or higher 
> orders already used up) to some extend for the errors to trigger.
> 

That is a reasonable assessment. It could be because

1. Something in the intevening commits greatly increases the number of
   GFP_ATOMIC allocations that are occuring. It's a pity that the allocator
   tracepoints are not available in those kernels. It would have made
   investigating this theory easier.

2. kswapd is no longer reclaiming high-order pages as well as it used
   to be it due to changes in kswapd itself or lumpy reclaim

3. Fragmentation avoidance has been broken in some subtle manner

I think 3 is particularly unlikely and am expecting it to be 1 or 2.

> TEST METHOD
> -----------
> As a normal bisection (I tried 3 times...) did not lead anywhere, I had to 
> think of an alternative approach. I decided to start by manually selecting 
> merges by Linus into mainline. The advantage is that that makes the 
> bisection linear and makes it a lot easier to see patterns.
> After narrowing down to a specific merge, I bisected (again semi-manually) 
> inside that merge.
> 
> Because I suspected there were multiple changes involved, I deliberately 
> tried to find two points:
> - where do I first start seeing SKB errors at all, even if it is only at
>   the second or third try;
> - where do I start getting SKB errors reliably on the first try.
> 
> I worked from "good" to "bad", i.e. I started at .30. The merges were not 
> chosen completely randomly. From the first 3 bisections I strongly 
> suspected the first 'net-next' merge and the first 'akpm' merge, but I did 
> make sure to confirm that suspicion.
> 

A very good approach.

> TEST DESCRIPTION
> ----------------
> The test I've ended up using is:
> 1) clean boot
> 2) start music in amarok from NFS share; use very long song to avoid file
>    changes and thus ensure a fluent stream of network data during the test
> 3) start 'gitk v2.6.29..master &' - to use up some memory
> 4) start first 'gitk master &' - after this all normal memory is as good as
>    used up, with minor swap; this never resulted in SKB errors
> 5) start second 'gitk master &' - this causes heavy swapping (>700 MB) and
>    is the real test
> 6) if there were no SKB errors after 5), kill the gitk processes and repeat
>    steps 3) to 5). I've done this up to 4 times in some cases
> 7) if the results are not clear or when there is doubt later, repeat from
>    step 1) with same kernel
> 
> Memory after initial 'gitk v2.6.29..master &':
>              total       used       free     shared    buffers     cached
> Mem:       2030776    1153008     877768          0      41572     333968
> -/+ buffers/cache:     777468    1253308
> Swap:      2097144          0    2097144
> 
> Memory after first 'gitk master &':
>              total       used       free     shared    buffers     cached
> Mem:       2030776    1979040      51736          0      35684     238420
> -/+ buffers/cache:    1704936     325840
> Swap:      2097144      21876    2075268
> 
> Memory after second 'gitk master &' (with .30.2):
>              total       used       free     shared    buffers     cached
> Mem:       2030776    2011608      19168          0      21836      92336
> -/+ buffers/cache:    1897436     133340
> Swap:      2097144     776160    1320984
> 
> OVERVIEW OF RESULTS
> -------------------
> Below I list the most relevant merges and commits. Note that they are 
> listed in commit order; my kernel version shows the order of testing.
> 
> For the commits I tested the test results are listed on the next line.
> The first number on that line consists of the test series + the iteration 
> (and also identifies the kernel I used).
> A "+" means I got no SKB errors, a "-" that I did get them. A "|" means I 
> rebooted for a second series of tests.
> 
> v2.6.30-2330-gdb8e7f1	'x86-fixes-for-linus' of linux-2.6-tip
> 	1.1	+++	iwlagn sw-error during first test
> v2.6.30-4127-g0fa2133	'merge' of powerpc (last merge before net-next-2.6)
> 	1.2	+++
> v2.6.30-5398-g2ed0e21	net-next-2.6 (mega-merge!)
> 	1.4	+-	system reboot fails after testing
> v2.6.30-5517-g609106b	'merge' of powerpc
> 	1.3	+-	system reboot fails after testing
> v2.6.30-5927-gf83b1e6	'for-linus' of linux1394-2.6 (last merge before akpm)
> 	2.2	++-
> v2.6.30-6111-g517d086	'akpm'
> 	2.1	-|-
> 
> BISECTION OF net-next-2.6 MERGE
> -------------------------------
> Note that this merge was based not on .30 vanilla, but partly on 
> v2.6.30-rc1 and partly on v2.6.30-rc6.
> I think this had an influence on the latencies I saw (i.e. because some 
> post-rc6 bug fixes were not present it changes the general behavior of the 
> system during the swapping). For example: with v2.6.30-4127-g0fa2133 the 
> system remained more responsive (smaller music skips) than with 
> v2.6.30-rc1-1219-g82d0481.
> 
> I started again by testing merges, this time those by David.
> 
> v2.6.30-rc1-1219-g82d0481	'master' of wireless-next-2.6
> 	1.5	++++	bad latencies

The bad latencies might imply that there are a lot more allocations
going on than there used to be. Maybe it was just because of a wireless
bug though that was later fixed.

> v2.6.30-rc6-660-gbb803cf	'master' of net-2.6
> v2.6.30-rc6-808-g45ea4ea	'master' of wireless-next-2.6
> v2.6.30-rc6-850-gc649c0e	'master' of net-2.6
> v2.6.30-rc6-922-g3f1f39c	'linux-2.6.31.y' of wimax
> v2.6.30-rc6-999-gb2f8f75	'master' of net-2.6
> v2.6.30-rc6-1028-ga8c617e	'net-next' of lksctp-dev
> 	1.7	++++|++++|++++
> 	I went back to this one twice because the bisection inside the
> 	next merge (see below) did not give a clear result.
> v2.6.30-rc6-1103-gb1bc81a	'master' of wireless-next-2.6
> 	1.8	+-
> v2.6.30-rc6-1224-g84503dd	'master' of wireless-next-2.6
> 	1.6	+-
> 
> So the problem started in the v2.6.30-rc6-1103-gb1bc81a merge.
> I was unable to narrow it down to an exact commit; AFAICT the remaining 
> ones (between v2.6.30-rc6-1028-g8fc0fee and v2.6.30-rc6-1032-g7ba10a8) are 
> uninteresting. But it *must* be in this area!
> 
> For a good overview of the area, use 'gitk 3f1f39c4..b1bc81a0'.
> 
> v2.6.30-rc6-1028-g8fc0fee	cfg80211: use key size constants
> 	1.11	++++
> v2.6.30-rc6-1031-g1bb5633	iwmc3200wifi: fix printk format
> 	1.14	+++-	not quite conclusive...
> v2.6.30-rc6-1032-g7ba10a8	mac80211: fix transposed min/max CW values
> 	1.13	-
> 	This is a bugfix for aa837ee1d from an earlier merge! Could this maybe
> 	influence the test results in between? There are various SKB related
> 	changes there, for example: dfbf97f3..e5b9215e.

Maybe. Your commit id's are different to what I see. Maybe it's because your
tree has been shuffled around a bit but after some digging around in this
general area, I saw this patch

4752c93c30 iwlcore: Allow skb allocation from tasklet

This patch increases the number of GFP_ATOMIC allocations that can occur by
allocating GFP_ATOMIC in some cases and GFP_KERNEL in others. Previously,
only GFP_KERNEL was used and I didn't realise this allocation method was
so recent. Problems of this sort have cropped up before and while there
are later changes that suppress some of these warnings, I believe this is
a strong candidate for where the allocation failures started appearing.

> v2.6.30-rc6-1037-g2c5b9e5	wireless: libertas: fix unaligned accesses
> 	1.12	+-
> v2.6.30-rc6-1044-g729e9c7	cfg80211: fix for duplicate userspace replies
> 	1.10	+-
> v2.6.30-rc6-1075-gc587de0	iwlwifi: unify station management
> 	1.9	++-|+-
> v2.6.30-rc6-1076-gd14d444	iwl3945: port allow skb allocation in tasklet
> 	I thought this was a prime candidate, but as you can see several commits
> 	before failed too. Still worth looking at I think!
> 

Your commit IDs are different to what I see but it's the commit merge at
b1bc81a0ef86b86fa410dd303d84c8c7bd09a64d. I agree that the last commit
(d14d44407b9f06e3cf967fcef28ccb780caf0583) could make the problem worse
because it expands the use of GFP_ATOMIC for another driver.

> BISECTION of akpm (mm) MERGE
> ----------------------------
> So here I went looking for "where does the test start failing on the first 
> try". Again, I was unable to narrow it down to a single commit.
> 
> For a good overview of the area, use 'gitk f83b1e61..517d0869'.
> 
> v2.6.30-5466-ga1dd268	mm: use alloc_pages_exact in alloc_large_system_hash
> 	2.3	+-
> v2.6.30-5478-ge9bb35d	mm: setup_per_zone_inactive_ratio - fix comment and..
> 	2.5	+-
> v2.6.30-5486-g35282a2	migration: only migrate_prep() once per move_pages()
> 	2.6	-|+|-	not quite conclusive...
> v2.6.30-5492-gbce7394	page-allocator: reset wmark_min and inactive ratio..
> 	2.4	-|-
> 

While I didn't spot anything too out of the ordinary here, they did occur
shortly after a number of other page allocator related patches.  One small
thing I noticed there is that kswapd is getting woken up less now than it did
previously. Generally, I wouldn't have expected it to make a difference but
it's possible that kswapd is not being woken up to reclaim at a higher order
than it was previously. I have a patch for this below. It'd be nice if you
could apply it and see do fewer allocation failures occur on current mainline.

> WHERE NEXT?
> ===========
> I think the results confirm there is definitely an issue here and that my 
> test is reliable and consistent enough to show it. And as it currently is 
> the only test we have...
> 
> I hope that the info above is enough for the mm and wireless domain 
> experts to identify likely candidates in the areas I've identified.
> 
> The next step could be trying specific reverts or debug patches, either on 
> top of current git, or 2.6.31, or inside the identified areas.
> I'll run anything you care to throw at me and will try to provide any 
> additional info you need, but at this point it's up to you.
> 

For the wireless people in mainline - iwl_rx_replenish_now() is doing
a GFP_ATOMIC allocation that does not use __GFP_NOWARN. As part of
investigating allocation failures, iwl_rx_allocate() was taught to
distinguish between a benign and serious allocation failure - serious
being there are very few RX buffers left and packet loss could occur soon
(see commit f82a924cc88a5541df1d4b9d38a0968cd077a051). I think this GFP mask
should be made GFP_ATOMIC|__GFP_NOWARN so that warnings only appear when the
failure is serious, dump stack after the warning if you need it. I have a
feeling that almost all these warnings have been benign and are related to
the introduction of GFP_ATOMIC being used so heavily to move more expensive
allocations to the tasklet (presumably to reduce user-visible latency).

Frans, could you try the following kswapd-related patch please? I'd be
interested in seeing if the number of allocation failure warnings are
reduced with it. After that, could you edit
drivers/net/wireless/iwlwifi/iwl-rx.c and make the GFP_ATOMIC in
iwl_rx_replenish_now() GFP_ATOMIC|__GFP_NOWARN and see do any of the
"serious" allocation failure messages appear.

Thanks again for your persistence.

==== CUT HERE ====
