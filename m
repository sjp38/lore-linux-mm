Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 2CD6C6B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 10:04:40 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/6] Reduce compaction scanning and lock contention
Date: Thu, 20 Sep 2012 15:04:29 +0100
Message-Id: <1348149875-29678-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Hi Richard,

This series is following up from your mail at
http://www.spinics.net/lists/kvm/msg80080.html . I am pleased the lock
contention is now reduced but acknowledge that the scanning rates are
stupidly high. Fortunately, I am reasonably confident I know what is
going wrong. If all goes according to plain this should drastically reduce
the amount of time your workload spends on compaction. I would very much
appreciate if you drop the MM patches (i.e. keep the btrfs patches) and
replace them with this series. I know that Rik's patches are dropped and
this is deliberate. I reimplemented his idea on top of the fifth patch on
this series to cover both the migrate and free scanners. Thanks to Rik who
discussed how the idea could be reimplemented on IRC which was very helpful.
Hopefully the patch actually reflects what we discussed :)

Shaohua, I would also appreciate if you tested this series. I picked up
one of your patches but replaced another and want to make sure that the
workload you were investigating is still ok.

===

Richard Davies and Shaohua Li have both reported lock contention problems
in compaction on the zone and LRU locks as well as significant amounts of
time being spent in compaction. It is critical that performance gains from
THP are not offset by the cost of allocating them in the first place. This
series aims to reduce lock contention and scanning rates.

Patch 1 is a fix for c67fe375 (mm: compaction: Abort async compaction if
	locks are contended or taking too long) to properly abort in all
	cases when contention is detected.

Patch 2 defers acquiring the zone->lru_lock as long as possible.

Patch 3 defers acquiring the zone->lock as lock as possible.

Patch 4 reverts Rik's "skip-free" patches as the core concept gets
	reimplemented later and the remaining patches are easier to
	understand if this is reverted first.

Patch 5 adds a pageblock-skip bit to the pageblock flags to cache what
	pageblocks should be skipped by the migrate and free scanners.
	This drastically reduces the amount of scanning compaction has
	to do.

Patch 6 reimplements something similar to Rik's idea except it uses the
	pageblock-skip information to decide where the scanners should
	restart from and does not need to wrap around.

I tested this on 3.6-rc5 as that was the kernel base that the earlier threads
worked on. It will need a bit of work to rebase on top of Andrews tree for
merging due to other compaction changes but it will not be a major problem.
Kernels tested were

vanilla		3.6-rc5
lesslock	Patches 1-3
revert		Patches 1-4
cachefail	Patches 1-5
skipuseless	Patches 1-6

Stress high-order allocation tests looked ok.

STRESS-HIGHALLOC
                   3.6.0         3.6.0-rc5         3.6.0-rc5        3.6.0-rc5         3.6.0-rc5
                   rc5-vanilla    lesslock            revert        cachefail       skipuseless      
Pass 1          17.00 ( 0.00%)    19.00 ( 2.00%)    29.00 (12.00%)   24.00 ( 7.00%)    20.00 ( 3.00%)
Pass 2          16.00 ( 0.00%)    19.00 ( 3.00%)    39.00 (23.00%)   37.00 (21.00%)    35.00 (19.00%)
while Rested    88.00 ( 0.00%)    88.00 ( 0.00%)    88.00 ( 0.00%)   85.00 (-3.00%)    86.00 (-2.00%)

Success rates are improved a bit by the series as there are fewer
opporunities to race with other allocation requests if compaction is
scanning less.  I recognise the success rates are still low but patches
that tackle parts of that are in Andrews tree already.

The time to complete the tests did not vary that much and are uninteresting
as were the vmstat statistics so I will not present them here.

Using ftrace I recorded how much scanning was done by compaction and got this

                            3.6.0         3.6.0-rc5 3.6.0-rc5  3.6.0-rc5  3.6.0-rc5
                            rc5-vanilla    lesslock    revert  cachefail  skipuseless      
Total   free    scanned       185020625  223313210  744553485   37149462   29231432 
Total   free    isolated         845094    1174759    4301672     906689     721963 
Total   free    efficiency      0.0046%    0.0053%    0.0058%    0.0244%    0.0247% 
Total   migrate scanned       187708506  143133150  428180990   21941574   12288851 
Total   migrate isolated         714376    1081134    3950098     711357     590552 
Total   migrate efficiency      0.0038%    0.0076%    0.0092%    0.0324%    0.0481% 

The efficiency is worthless because of the nature of the test and the
number of failures.  The really interesting point as far as this patch
series is concerned is the number of pages scanned.

Note that reverting Rik's patches massively increases the number of pages scanned
indicating that those patches really did make a huge difference to CPU usage.

However, caching what pageblocks should be skipped has a much higher
impact. With patches 1-5 applied, free page scanning is reduced by 80%
in comparison to the vanilla kernel and migrate page scanning is reduced
by 88%. If the basic concept of Rik's patches are implemened on top then
scanning is even further reduced. Free scanning is reduced by 84% and
migrate scanning is reduced by 93%.

 include/linux/mmzone.h          |    5 +-
 include/linux/pageblock-flags.h |   19 +-
 mm/compaction.c                 |  407 ++++++++++++++++++++++++---------------
 mm/internal.h                   |   13 +-
 mm/page_alloc.c                 |    6 +-
 5 files changed, 284 insertions(+), 166 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
