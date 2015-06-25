Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id E24296B006E
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:32:52 -0400 (EDT)
Received: by obbkm3 with SMTP id km3so51653804obb.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:32:52 -0700 (PDT)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id js10si20188899oeb.0.2015.06.25.10.32.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 10:32:52 -0700 (PDT)
Received: by obctg8 with SMTP id tg8so51542783obc.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:32:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <558C03BF.40209@suse.cz>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
	<558C03BF.40209@suse.cz>
Date: Fri, 26 Jun 2015 02:32:51 +0900
Message-ID: <CAAmzW4POd-tFrjDu1G1T9=jDqmLLCRoHuxdVucE--8ksHWtySA@mail.gmail.com>
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

2015-06-25 22:35 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 06/25/2015 02:45 AM, Joonsoo Kim wrote:
>>
>> Recently, I got a report that android get slow due to order-2 page
>> allocation. With some investigation, I found that compaction usually
>> fails and many pages are reclaimed to make order-2 freepage. I can't
>> analyze detailed reason that causes compaction fail because I don't
>> have reproducible environment and compaction code is changed so much
>> from that version, v3.10. But, I was inspired by this report and started
>> to think limitation of current compaction algorithm.
>>
>> Limitation of current compaction algorithm:
>>
>> 1) Migrate scanner can't scan behind of free scanner, because
>> each scanner starts at both side of zone and go toward each other. If
>> they meet at some point, compaction is stopped and scanners' position
>> is reset to both side of zone again. From my experience, migrate scanner
>> usually doesn't scan beyond of half of the zone range.
>
>
> Yes, I've also pointed this out in the RFC for pivot changing compaction.

Hello, Vlastimil.

Yes, you did. :)

>> 2) Compaction capability is highly depends on amount of free memory.
>> If there is 50 MB free memory on 4 GB system, migrate scanner can
>> migrate 50 MB used pages at maximum and then will meet free scanner.
>> If compaction can't make enough high order freepages during this
>> amount of work, compaction would fail. There is no way to escape this
>> failure situation in current algorithm and it will scan same region and
>> fail again and again. And then, it goes into compaction deferring logic
>> and will be deferred for some times.
>
>
> That's 1) again but in more detail.

Hmm... I don't think this is same issue. 1) is about what pageblock
migration scanner can scan in many iterations. But, 2) is about how
many pages migration scanner can scan in one iteration. Think about
your pivot change approach. It can change pivot so migration scanner
can scan whole zone range sometime. But, in each iteration, it can
scans limited number of pages according to amount of free memory.
If free memory is low, pivot approach needs more iteration in order to
scan whole zone range. I'd like to remove this dependency.

>> 3) Compaction capability is highly depends on migratetype of memory,
>> because freepage scanner doesn't scan unmovable pageblock.
>
>
> Yes, I've also observed this issue recently.

Cool!!

>> To investigate compaction limitations, I made some compaction benchmarks.
>> Base environment of this benchmark is fragmented memory. Before testing,
>> 25% of total size of memory is allocated. With some tricks, these
>> allocations are evenly distributed to whole memory range. So, after
>> allocation is finished, memory is highly fragmented and possibility of
>> successful order-3 allocation is very low. Roughly 1500 order-3 allocation
>> can be successful. Tests attempt excessive amount of allocation request,
>> that is, 3000, to find out algorithm limitation.
>>
>> There are two variations.
>>
>> pageblock type (unmovable / movable):
>>
>> One is that most pageblocks are unmovable migratetype and the other is
>> that most pageblocks are movable migratetype.
>>
>> memory usage (memory hogger 200 MB / kernel build with -j8):
>>
>> Memory hogger means that 200 MB free memory is occupied by hogger.
>> Kernel build means that kernel build is running on background and it
>> will consume free memory, but, amount of consumption will be very
>> fluctuated.
>>
>> With these variations, I made 4 test cases by mixing them.
>>
>> hogger-frag-unmovable
>> hogger-frag-movable
>> build-frag-unmovable
>> build-frag-movable
>>
>> All tests are conducted on 512 MB QEMU virtual machine with 8 CPUs.
>>
>> I can easily check weakness of compaction algorithm by following test.
>>
>> To check 1), hogger-frag-movable benchmark is used. Result is as
>> following.
>>
>> bzImage-improve-base
>> compact_free_scanned           5240676
>> compact_isolated               75048
>> compact_migrate_scanned        2468387
>> compact_stall                  710
>> compact_success                98
>> pgmigrate_success              34869
>> Success:                       25
>> Success(N):                    53
>>
>> Column 'Success' and 'Success(N) are calculated by following equations.
>>
>> Success = successful allocation * 100 / attempts
>> Success(N) = successful allocation * 100 /
>>                 number of successful order-3 allocation
>
>
> As Mel pointed out, this is a weird description. The one from patch 5 makes
> more sense and I hope it's correct:
>
> Success = successful allocation * 100 / attempts
> Success(N) = successful allocation * 100 / order 3 candidates

Thanks. I used this comment to reply Mel's ask.

>
>>
>> As mentioned above, there are roughly 1500 high order page candidates,
>> but, compaction just returns 53% of them. With new compaction approach,
>> it can be increased to 94%. See result at the end of this cover-letter.
>>
>> To check 2), hogger-frag-movable benchmark is used again, but, with some
>> tweaks. Amount of allocated memory by memory hogger varys.
>>
>> bzImage-improve-base
>> Hogger:                 150MB   200MB   250MB   300MB
>> Success:                41      25      17      9
>> Success(N):             87      53      37      22
>>
>> As background knowledge, up to 250MB, there is enough
>> memory to succeed all order-3 allocation attempts. In 300MB case,
>> available memory before starting allocation attempt is just 57MB,
>> so all of attempts cannot succeed.
>>
>> Anyway, as free memory decreases, compaction success rate also decreases.
>> It is better to remove this dependency to get stable compaction result
>> in any case.
>>
>> To check 3), build-frag-unmovable/movable benchmarks are used.
>> All factors are same except pageblock migratetypes.
>>
>> Test: build-frag-unmovable
>>
>> bzImage-improve-base
>> compact_free_scanned           5032378
>> compact_isolated               53368
>> compact_migrate_scanned        1456516
>> compact_stall                  538
>> compact_success                93
>> pgmigrate_success              19926
>> Success:                       15
>> Success(N):                    33
>>
>> Test: build-frag-movable
>>
>> bzImage-improve-base
>> compact_free_scanned           3059086
>> compact_isolated               129085
>> compact_migrate_scanned        5029856
>> compact_stall                  388
>> compact_success                99
>> pgmigrate_success              52898
>> Success:                       38
>> Success(N):                    82
>>
>> Pageblock migratetype makes big difference on success rate. 3) would be
>> one of reason related to this result. Because freepage scanner doesn't
>> scan non-movable pageblock, compaction can't get enough freepage for
>> migration and compaction easily fails. This patchset try to solve it
>> by allowing freepage scanner to scan on non-movable pageblock.
>>
>> Result show that we cannot get all possible high order page through
>> current compaction algorithm. And, in case that migratetype of
>> pageblock is unmovable, success rate get worse. Although we can solve
>> problem 3) in current algorithm, there is unsolvable limitations, 1), 2),
>> so I'd like to change compaction algorithm.
>>
>> This patchset try to solve these limitations by introducing new compaction
>> approach. Main changes of this patchset are as following:
>>
>> 1) Make freepage scanner scans non-movable pageblock
>> Watermark check doesn't consider how many pages in non-movable pageblock.
>> To fully utilize existing freepage, freepage scanner should scan
>> non-movable pageblock.
>
>
> I share Mel's concerns here. The evaluation should consider long-term
> fragmentation effects. Especially when you've already seen a regression from
> this patch.

Okay. I will evaluate it. Anyway, do you have any scenario that this
causes more fragmentation? It would be helpful to know scenario
before investigation.

>> 2) Introduce compaction depletion state
>> Compaction algorithm will be changed to scan whole zone range. In this
>> approach, compaction inevitably do back and forth migration between
>> different iterations. If back and forth migration can make highorder
>> freepage, it can be justified. But, in case of depletion of compaction
>> possiblity, this back and forth migration causes unnecessary overhead.
>> Compaction depleteion state is introduced to avoid this useless
>> back and forth migration by detecting depletion of compaction possibility.
>
>
> Interesting, but I'll need to study this in more detail to grasp it
> completely.

No problem.

> Limiting the scanning because of not enough success might
> naturally lead to even less success and potentially never recover?

Yes, that is possible and some fine tuning may be needed. But, we
can't estimate exact state of memory in advance so it would be the best
to use heuristic.

In fact, I think that we should limit scanning in sync compaction
in any case. It is dangerous and very time consuming approach that
sync compaction scan as much as possible until it finds that compaction
is really impossible. This is related to recent change on network code
to prevent direct compaction.

We should balance effort on compaction and others such as reclaim.
Direct reclaim is limited up to certain amount of pages, but, sync
compaction doesn't have any limit. It is odd. Best strategy would be
limiting scan of sync compaction and implement high-level control
how many sync compaction is attempted according to amount of
reclaim effort.

>> 3) Change scanner's behaviour
>> Migration scanner is changed to scan whole zone range regardless freepage
>> scanner position. Freepage scanner also scans whole zone from
>> zone_start_pfn to zone_end_pfn.
>
>
> OK so you did propose this in response to my pivot changing compaction. I've
> been testing approach like this too, to see which is better, but it differs
> in many details. E.g. I just disabled pageblock skip bits for the time
> being, the way you handle them probably makes sense. The results did look
> nice (when free scanner ignored pageblock migratetype), but the cost was
> very high. Not ignoring migratetype looked like a better compromise on
> high-level look, but the inability of free scanner to find anything does
> suck.

Yes. As mentioned in some place, I think that inability of free scanner
to find freepage is big trouble than fragmentation

> I wonder what compromise could exist here.

I also wonder it. :)
I will investigate more.

> You did also post a RFC
> that migrates everything out of newly made unmovable pageblocks in the event
> of fallback allocation, and letting free scanner use such pageblocks goes
> against that.

I think that this patchset is more important than that patchset. I will
re-consider it again after seeing this patchset's conclusion.



>> To prevent back and forth migration
>> within one compaction iteration, freepage scanner marks skip-bit when
>> scanning pageblock. Migration scanner will skip this marked pageblock.
>> Finish condition is very simple. If migration scanner reaches end of
>> the zone, compaction will be finished. If freepage scanner reaches end of
>> the zone first, it restart at zone_start_pfn. This helps us to overcome
>> dependency on amount of free memory.
>
>
> Isn't there a danger of the free scanner scanning the zone many times during
> single compaction run?

I found this in another test with CMA after sending it. Maybe,
there is some corner case. I need to fix it.

> Does anything prevent it from scanning the same
> pageblock as the migration scanner at the same time? The skip bit is set
> only after free scanner is finished with a block AFAICS.

There is a check in isolate_freepages() that preventing freescanner
from scanning same pageblock where migration scanner scans now.
There is no such guard in case of parallel compaction, but, I guess that
this race window is small enough because freepage scanner scan and
marks skip-bit quickly.

Thanks for detailed and quick review. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
