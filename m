Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id CCA656B006C
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:42:56 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so38827350pab.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 17:42:56 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id qg11si42259837pab.141.2015.06.24.17.42.53
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 17:42:55 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 00/10] redesign compaction algorithm
Date: Thu, 25 Jun 2015 09:45:11 +0900
Message-Id: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

bzImage-improve-base
compact_free_scanned           5240676
compact_isolated               75048
compact_migrate_scanned        2468387
compact_stall                  710
compact_success                98
pgmigrate_success              34869
Success:                       25
Success(N):                    53

Column 'Success' and 'Success(N) are calculated by following equations.

Success = successful allocation * 100 / attempts
Success(N) = successful allocation * 100 /
		number of successful order-3 allocation

As mentioned above, there are roughly 1500 high order page candidates,
but, compaction just returns 53% of them. With new compaction approach,
it can be increased to 94%. See result at the end of this cover-letter.

To check 2), hogger-frag-movable benchmark is used again, but, with some
tweaks. Amount of allocated memory by memory hogger varys.

bzImage-improve-base
Hogger:			150MB	200MB	250MB	300MB
Success:		41	25	17	9
Success(N):		87	53	37	22

As background knowledge, up to 250MB, there is enough
memory to succeed all order-3 allocation attempts. In 300MB case,
available memory before starting allocation attempt is just 57MB,
so all of attempts cannot succeed.

Anyway, as free memory decreases, compaction success rate also decreases.
It is better to remove this dependency to get stable compaction result
in any case.

To check 3), build-frag-unmovable/movable benchmarks are used.
All factors are same except pageblock migratetypes.

Test: build-frag-unmovable

bzImage-improve-base
compact_free_scanned           5032378
compact_isolated               53368
compact_migrate_scanned        1456516
compact_stall                  538
compact_success                93
pgmigrate_success              19926
Success:                       15
Success(N):                    33

Test: build-frag-movable

bzImage-improve-base
compact_free_scanned           3059086
compact_isolated               129085
compact_migrate_scanned        5029856
compact_stall                  388
compact_success                99
pgmigrate_success              52898
Success:                       38
Success(N):                    82

Pageblock migratetype makes big difference on success rate. 3) would be
one of reason related to this result. Because freepage scanner doesn't
scan non-movable pageblock, compaction can't get enough freepage for
migration and compaction easily fails. This patchset try to solve it
by allowing freepage scanner to scan on non-movable pageblock.

Result show that we cannot get all possible high order page through
current compaction algorithm. And, in case that migratetype of
pageblock is unmovable, success rate get worse. Although we can solve
problem 3) in current algorithm, there is unsolvable limitations, 1), 2),
so I'd like to change compaction algorithm.

This patchset try to solve these limitations by introducing new compaction
approach. Main changes of this patchset are as following:

1) Make freepage scanner scans non-movable pageblock
Watermark check doesn't consider how many pages in non-movable pageblock.
To fully utilize existing freepage, freepage scanner should scan
non-movable pageblock.

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

Test: hogger-frag-unmovable
                                      base nonmovable   redesign  threshold
compact_free_scanned               2800710    5615427    6441095    2235764
compact_isolated                     58323     114183    2711081     647701
compact_migrate_scanned            1078970    2437597    4175464    1697292
compact_stall                          341       1066       2059       2092
compact_success                         80        123        207        210
pgmigrate_success                    27034      53832    1348113     318395
Success:                                22         29         44         40
Success(N):                             46         61         90         83


Test: hogger-frag-movable
                                      base nonmovable   redesign  threshold
compact_free_scanned               5240676    5883401    8103231    1860428
compact_isolated                     75048      83201    3108978     427602
compact_migrate_scanned            2468387    2755690    4316163    1474287
compact_stall                          710        664       2117       1964
compact_success                         98        102        234        183
pgmigrate_success                    34869      38663    1547318     208629
Success:                                25         26         45         44
Success(N):                             53         56         94         92


Test: build-frag-unmovable
                                      base nonmovable   redesign  threshold
compact_free_scanned               5032378    4110920    2538420    1891170
compact_isolated                     53368     330762    1020908     534680
compact_migrate_scanned            1456516    6164677    4809150    2667823
compact_stall                          538        746       2609       2500
compact_success                         93        350        438        403
pgmigrate_success                    19926     152754     491609     251977
Success:                                15         31         39         40
Success(N):                             33         65         80         81


Test: build-frag-movable
                                      base nonmovable   redesign  threshold
compact_free_scanned               3059086    3852269    2359553    1461131
compact_isolated                    129085     238856     907515     387373
compact_migrate_scanned            5029856    5051868    3785605    2177090
compact_stall                          388        540       2195       2157
compact_success                         99        218        247        225
pgmigrate_success                    52898     110021     439739     182366
Success:                                38         37         43         43
Success(N):                             82         77         89         90


Test: hogger-frag-movable with free memory variation

Hogger:			150MB	200MB	250MB	300MB
bzImage-improve-base
Success:		41	25	17	9
Success(N):		87	53	37	22

bzImage-improve-threshold
Success:		44	44	42	37
Success(N):		94	92	91	80


Test: stress-highalloc in mmtests
(tweaks to request order-7 unmovable allocation)

Ops 1		30.00		 8.33		84.67		78.00
Ops 2		32.33		26.67		84.33		79.00
Ops 3		91.67		92.00		95.00		94.00
Compaction stalls                 5110        5581       10296       10475
Compaction success                1787        1807        5173        4744
Compaction failures               3323        3774        5123        5731
Compaction pages isolated      6370911    15421622    30534650    11825921
Compaction migrate scanned    52681405    83721428   150444732    53517273
Compaction free scanned      418049611   579768237   310629538   139433577
Compaction cost                   3745        8822       17324        6628

Result shows that much improvement comes from redesign algorithm but it
causes too much overhead. However, further optimization reduces this
overhead greatly with a little success rate degradation.

We can observe regression from a patch that allows scanning on
non-movable pageblock in some cases. Although this regression is bad,
there are also much improvement in other cases when most of pageblocks
are non-movable migratetype. IMHO, that patch can be justified by
improvement case. Moreover, this regression disappears after applying
following patches so we don't need to worry.

Please see result of "hogger-frag-movable with free memory variation".
It shows that patched version solves limitations of current compaction
algorithm and almost possible order-3 candidates can be allocated
regardless of amount of free memory.

This patchset is based on next-20150515.
Feel free to comment. :)
Thanks.

Joonsoo Kim (10):
  mm/compaction: update skip-bit if whole pageblock is really scanned
  mm/compaction: skip useless pfn for scanner's cached pfn
  mm/compaction: always update cached pfn
  mm/compaction: clean-up restarting condition check
  mm/compaction: make freepage scanner scans non-movable pageblock
  mm/compaction: introduce compaction depleted state on zone
  mm/compaction: limit compaction activity in compaction depleted state
  mm/compaction: remove compaction deferring
  mm/compaction: redesign compaction
  mm/compaction: new threshold for compaction depleted zone

 include/linux/compaction.h        |  14 +-
 include/linux/mmzone.h            |   6 +-
 include/trace/events/compaction.h |  30 ++--
 mm/compaction.c                   | 353 ++++++++++++++++++++++----------------
 mm/internal.h                     |   1 +
 mm/page_alloc.c                   |   2 +-
 mm/vmscan.c                       |   4 +-
 7 files changed, 229 insertions(+), 181 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
