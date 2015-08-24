Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1EC6B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:19:50 -0400 (EDT)
Received: by pdob1 with SMTP id b1so47324475pdo.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:19:49 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id hi6si25006896pac.81.2015.08.23.19.19.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:19:48 -0700 (PDT)
Received: by padfo6 with SMTP id fo6so5189793pad.3
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:19:48 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 0/9] mm/compaction: redesign compaction
Date: Mon, 24 Aug 2015 11:19:24 +0900
Message-Id: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Major changes from v1:
o Add one skip-bit on each pageblock to avoid the pageblock that
cannot be used for migration target

o Allow freepage scanner to scan non-movable pageblock only if zone
is in compaction depleted state:
To allow scanning on non-movable pageblock cannot be avoided because
there is a system where almost pageblocks are unmovable pageblock.
And, without this patch, as compaction progress, all of freepages are
moved to non-movable pageblock due to asymetric characteristic of
scanner's target pageblock and compaction will stop working due to
shortage of migration target freepage. In experiment, allowing
freepage scanner to scan non-movable pageblock only if zone is
in compaction depleted state doesn't fragment the system more than
before with ensuring great success rate improvement.

o Don't use high-order freepage higher than the order we try to make:
It prevents parallel freepage scanner undo migration scanner's work.

o Include elapsed time in stress-highalloc test

o Include page owner result to check fragmentation

o All result are refreshed

o Remove Success attribute in result:
Showing two similar metric make reader somewhat confused
so remove less important one. Remained one Success(N) is calculated
by following equation.

Success(N) = successful allocation * 100 / order-3 candidates

o Prevent freepage scanner to scan a zone many times

Orignial cover-letter with some refresh
Recently, I got a report that android get slow due to order-2 page
allocation. With some investigation, I found that compaction usually
fails and many pages are reclaimed to make order-2 freepage. I can't
analyze detailed reason that causes compaction fail because I don't
have reproducible environment and compaction code is changed so much
from that version, v3.10. But, I was inspired by this report and started
to think limitation of current compaction algorithm.

Limitation of current compaction algorithm:

1) Migrate scanner can't scan behind of free scanner, because
each scanner starts at both side of zone and go toward each other. If
they meet at some point, compaction is stopped and scanners' position
is reset to both side of zone again. From my experience, migrate scanner
usually doesn't scan beyond of half of the zone range.

2) Compaction capability is highly depends on amount of free memory.
If there is 50 MB free memory on 4 GB system, migrate scanner can
migrate 50 MB used pages at maximum and then will meet free scanner.
If compaction can't make enough high order freepages during this
amount of work, compaction would fail. There is no way to escape this
failure situation in current algorithm and it will scan same region and
fail again and again. And then, it goes into compaction deferring logic
and will be deferred for some times.

3) Compaction capability is highly depends on migratetype of memory,
because freepage scanner doesn't scan unmovable pageblock.

To investigate compaction limitations, I made some compaction benchmarks.
Base environment of this benchmark is fragmented memory. Before testing,
25% of total size of memory is allocated. With some tricks, these
allocations are evenly distributed to whole memory range. So, after
allocation is finished, memory is highly fragmented and possibility of
successful order-3 allocation is very low. Roughly 1500 order-3 allocation
can be successful. Tests attempt excessive amount of allocation request,
that is, 3000, to find out algorithm limitation.

There are two variations.

pageblock type (unmovable / movable):

One is that most pageblocks are unmovable migratetype and the other is
that most pageblocks are movable migratetype.

memory usage (memory hogger 200 MB / kernel build with -j8):

Memory hogger means that 200 MB free memory is occupied by hogger.
Kernel build means that kernel build is running on background and it
will consume free memory, but, amount of consumption will be very
fluctuated.

With these variations, I made 4 test cases by mixing them.

hogger-frag-unmovable
hogger-frag-movable
build-frag-unmovable
build-frag-movable

All tests are conducted on 512 MB QEMU virtual machine with 8 CPUs.

I can easily check weakness of compaction algorithm by following test.

To check 1), hogger-frag-movable benchmark is used. Result is as
following.

Kernel:	Base

Success(N)                    70
compact_stall                307
compact_success               64
compact_fail                 243
pgmigrate_success          34592
compact_isolated           73977
compact_migrate_scanned  2280770
compact_free_scanned     4710313

Column 'Success(N) are calculated by following equations.

Success(N) = successful allocation * 100 /
		number of order-3 candidates

As mentioned above, there are roughly 1500 high order page candidates,
but, compaction just returns 70% of them even if system is under low load.
With new compaction approach, it can be increased to 94%.

To check 2), hogger-frag-movable benchmark is used again, but, with some
tweaks. Amount of allocated memory by memory hogger varys.

Kernel:	Base

200MB-Success(N)	70
250MB-Success(N)	38
300MB-Success(N)	29

As background knowledge, up to 250MB, there is enough
memory to succeed all order-3 allocation attempts. In 300MB case,
available memory before starting allocation attempt is just 57MB,
so all of attempts cannot succeed.

Anyway, as free memory decreases, compaction success rate also decreases.
It is better to remove this dependency to get stable compaction result
in any case. System is usually under the low memory state because kernel
try to keeps page cache as much as possible. Even in this case,
compaction should work well so change is needed.

To check 3), build-frag-unmovable/movable benchmarks are used.
All factors are same except pageblock migratetypes.

Test: build-frag-unmovable
Success(N)                    37

Test: build-frag-movable
Success(N)                    71

Pageblock migratetype makes big difference on success rate. 3) would be
one of reason related to this result. Because freepage scanner doesn't
scan non-movable pageblock, compaction can't get enough freepage for
migration and compaction easily fails. This patchset try to solve it
by allowing freepage scanner to scan on non-movable pageblock.

Result show that we cannot get all possible high order page through
current compaction algorithm. And, in case that migratetype of
pageblock is unmovable, success rate get worse.

This patchset try to solve these limitations by introducing new compaction
approach. Main changes of this patchset are as following:

1) Make freepage scanner scans non-movable pageblock
Watermark check doesn't consider how many pages in non-movable pageblock.
To fully utilize existing freepage, freepage scanner should scan
non-movable pageblock. Otherwise, all freepage will be on non-movable
pageblock and compaction cannot progress.

2) Introduce compaction depletion state
Compaction algorithm will be changed to scan whole zone range. In this
approach, compaction inevitably do back and forth migration between
different iterations. If back and forth migration can make highorder
freepage, it can be justified. But, in case of depletion of compaction
possiblity, this back and forth migration causes unnecessary overhead.
Compaction depleteion state is introduced to avoid this useless
back and forth migration by detecting depletion of compaction possibility.

3) Change scanner's behaviour
Migration scanner is changed to scan whole zone range regardless freepage
scanner position. Freepage scanner also scans whole zone from
zone_start_pfn to zone_end_pfn. To prevent back and forth migration
within one compaction iteration, freepage scanner marks skip-bit when
scanning pageblock. Migration scanner will skip this marked pageblock.
Finish condition is very simple. If migration scanner reaches end of
the zone, compaction will be finished. If freepage scanner reaches end of
the zone first, it restart at zone_start_pfn. This helps us to overcome
dependency on amount of free memory.

Following is all test results of this patchset.

Kernel:	Base vs Limit vs Nonmovable vs Redesign vs Threshold

Test: hogger-frag-unmovable

Success(N)                    44              38              51              89              81
compact_stall               1268            5280            4949            3954            3891
compact_success               82              68             107             247             220
compact_fail                1186            5212            4841            3707            3671
pgmigrate_success          28053           14948           75829        16976894          233854
compact_isolated           60850          144501          306681        34055071          525070
compact_migrate_scanned  1199597         2965599        33270886        57323542         2010671
compact_free_scanned     3020346          949566        45376207        46796518         2241243


Test: hogger-frag-movable

Success(N)                    70              60              68              94              83
compact_stall                307            4555            4380            3642            4048
compact_success               64              41              79             144             212
compact_fail                 243            4514            4301            3498            3835
pgmigrate_success          34592           14243           54207        15897219          216387
compact_isolated           73977          105025          258877        31899553          487712
compact_migrate_scanned  2280770         2886304        37214115        59146745         2513245
compact_free_scanned     4710313         1472874        44372985        49566134         4124319


Test: build-frag-unmovable

Success(N)                    37              44              64              79              78
compact_stall                624            6886            5056            4623            4486
compact_success              103             180             419             397             346
compact_fail                 521            6706            4637            4226            4140
pgmigrate_success          22004           23100          277106         6574370          131729
compact_isolated           61021          247653         1056863        13477284          336305
compact_migrate_scanned  2609360         4186815        70252458        73017961         2312430
compact_free_scanned     4808989        13112142        23091292        19290141         2484755


Test: build-frag-movable

Success(N)                    71              66              76              89              87
compact_stall                432            4644            4243            4053            3642
compact_success              110              94             170             264             202
compact_fail                 322            4550            4073            3788            3440
pgmigrate_success          51265           34215          120132         6497642          153413
compact_isolated          124238          176080          756052        13292640          353445
compact_migrate_scanned  4497824         2786343        75556954        69714502         2307433
compact_free_scanned     3809018         3456820        26786674        20243121         2325295

Redesigned compaction version shows great success rate even if
almost pageblocks are unmovable migratetype. It shows that
almost order-3 candidates are allocated unlike previous compaction
algorithm. Overhead is dropped to reasonable number by assigning
threshold appropriately.

Test: stress-highalloc in mmtests
(tweaks to request order-7 unmovable allocation)

Kernel:	Base vs Limit vs Nonmovable vs Redesign vs Threshold

Ops 1                                   24              11              23              83              74
Ops 2                                   39              22              44              83              75
Ops 3                                   90              85              89              92              92
Elapsed                               1428            1354            1697            1993            1489

Compaction stalls                     6351           29199           26434           14348           15859
Compaction success                    2291            1343            2964            5081            4483
Compaction failures                   4060           27856           23470            9266           11376
Page migrate success               3264680         1174053        31952619        53015969         3099520
Compaction pages isolated          6644306         2871488        64857701       106723902         6645394
Compaction migrate scanned        62964165        19857623       569563971       748424010        38447292
Compaction free scanned          356586772       309061359      2129832292       670368329        95853699
Compaction cost                       3955            1412           38387           62298            3612

Result shows that much improvement comes from redesign algorithm but it
causes too much overhead. However, further optimization reduces this
overhead greatly with a little success rate degradation. It looks like
optimized version has less overhead than base in this test.


Test: repeats stress-highalloc 3 times without rebooting
(request order-9 movable allocation)

pb[N] means number of non-mixed pageblock after N run
of stress-highalloc test (Large number is better)

Kernel:	Base vs Threshold

pb[1]:DMA32:movable:		1365	1364
pb[1]:Normal:movable:		393	394
pb[2]:DMA32:movable:		1306	1309
pb[2]:Normal:movable:		368	368
pb[3]:DMA32:movable:		1272	1275
pb[3]:Normal:movable:		358	350

This series that include the patch allowing freepage scanner
to scan non-movable pageblock in compaction depleted state
doesn't fragment memory more than before.


Test: hogger-frag-movable with free memory variation

Kernel:	Base vs Limit vs Nonmovable vs Redesign vs Threshold

200MB-Success(N)	70	60	68	94	83
250MB-Success(N)	38	36	43	93	75
300MB-Success(N)	29	20	30	89	74

Please see result of "hogger-frag-movable with free memory variation".
It shows that as hogger takes more memory, success rate decreases greatly
until redesign version. After redesigning compaction, success rate still
decreases but just a little.

In conclusion, this series solves three limitations of current compaction
algorithm successfully. :)

This patchset is based on linux-next-20150515 and not targeted to merge.
After merge window is finished, I will rebase it to recent kernel and
send v3.

Feel free to comment.
Thanks.

Joonsoo Kim (9):
  mm/compaction: skip useless pfn when updating cached pfn
  mm/compaction: introduce compaction depleted state on zone
  mm/compaction: limit compaction activity in compaction depleted state
  mm/compaction: remove compaction deferring
  mm/compaction: allow to scan nonmovable pageblock when depleted state
  mm/compaction: manage separate skip-bits for migration and free
    scanner
  mm/compaction: redesign compaction
  mm/compaction: don't use higher order freepage than compaction aims at
  mm/compaction: new threshold for compaction depleted zone

 include/linux/compaction.h        |  14 +-
 include/linux/mmzone.h            |  10 +-
 include/linux/pageblock-flags.h   |  37 +++-
 include/trace/events/compaction.h |  30 ++-
 mm/compaction.c                   | 377 ++++++++++++++++++++++++--------------
 mm/internal.h                     |   1 +
 mm/page_alloc.c                   |   5 +-
 mm/vmscan.c                       |   4 +-
 8 files changed, 296 insertions(+), 182 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
