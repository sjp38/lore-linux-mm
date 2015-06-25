Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 62C006B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 09:36:03 -0400 (EDT)
Received: by wguu7 with SMTP id u7so62817471wgu.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 06:36:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd10si8679521wib.30.2015.06.25.06.36.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 06:36:01 -0700 (PDT)
Message-ID: <558C03BF.40209@suse.cz>
Date: Thu, 25 Jun 2015 15:35:59 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On 06/25/2015 02:45 AM, Joonsoo Kim wrote:
> Recently, I got a report that android get slow due to order-2 page
> allocation. With some investigation, I found that compaction usually
> fails and many pages are reclaimed to make order-2 freepage. I can't
> analyze detailed reason that causes compaction fail because I don't
> have reproducible environment and compaction code is changed so much
> from that version, v3.10. But, I was inspired by this report and started
> to think limitation of current compaction algorithm.
>
> Limitation of current compaction algorithm:
>
> 1) Migrate scanner can't scan behind of free scanner, because
> each scanner starts at both side of zone and go toward each other. If
> they meet at some point, compaction is stopped and scanners' position
> is reset to both side of zone again. From my experience, migrate scanner
> usually doesn't scan beyond of half of the zone range.

Yes, I've also pointed this out in the RFC for pivot changing compaction.

> 2) Compaction capability is highly depends on amount of free memory.
> If there is 50 MB free memory on 4 GB system, migrate scanner can
> migrate 50 MB used pages at maximum and then will meet free scanner.
> If compaction can't make enough high order freepages during this
> amount of work, compaction would fail. There is no way to escape this
> failure situation in current algorithm and it will scan same region and
> fail again and again. And then, it goes into compaction deferring logic
> and will be deferred for some times.

That's 1) again but in more detail.

> 3) Compaction capability is highly depends on migratetype of memory,
> because freepage scanner doesn't scan unmovable pageblock.

Yes, I've also observed this issue recently.

> To investigate compaction limitations, I made some compaction benchmarks.
> Base environment of this benchmark is fragmented memory. Before testing,
> 25% of total size of memory is allocated. With some tricks, these
> allocations are evenly distributed to whole memory range. So, after
> allocation is finished, memory is highly fragmented and possibility of
> successful order-3 allocation is very low. Roughly 1500 order-3 allocation
> can be successful. Tests attempt excessive amount of allocation request,
> that is, 3000, to find out algorithm limitation.
>
> There are two variations.
>
> pageblock type (unmovable / movable):
>
> One is that most pageblocks are unmovable migratetype and the other is
> that most pageblocks are movable migratetype.
>
> memory usage (memory hogger 200 MB / kernel build with -j8):
>
> Memory hogger means that 200 MB free memory is occupied by hogger.
> Kernel build means that kernel build is running on background and it
> will consume free memory, but, amount of consumption will be very
> fluctuated.
>
> With these variations, I made 4 test cases by mixing them.
>
> hogger-frag-unmovable
> hogger-frag-movable
> build-frag-unmovable
> build-frag-movable
>
> All tests are conducted on 512 MB QEMU virtual machine with 8 CPUs.
>
> I can easily check weakness of compaction algorithm by following test.
>
> To check 1), hogger-frag-movable benchmark is used. Result is as
> following.
>
> bzImage-improve-base
> compact_free_scanned           5240676
> compact_isolated               75048
> compact_migrate_scanned        2468387
> compact_stall                  710
> compact_success                98
> pgmigrate_success              34869
> Success:                       25
> Success(N):                    53
>
> Column 'Success' and 'Success(N) are calculated by following equations.
>
> Success = successful allocation * 100 / attempts
> Success(N) = successful allocation * 100 /
> 		number of successful order-3 allocation

As Mel pointed out, this is a weird description. The one from patch 5 
makes more sense and I hope it's correct:

Success = successful allocation * 100 / attempts
Success(N) = successful allocation * 100 / order 3 candidates

>
> As mentioned above, there are roughly 1500 high order page candidates,
> but, compaction just returns 53% of them. With new compaction approach,
> it can be increased to 94%. See result at the end of this cover-letter.
>
> To check 2), hogger-frag-movable benchmark is used again, but, with some
> tweaks. Amount of allocated memory by memory hogger varys.
>
> bzImage-improve-base
> Hogger:			150MB	200MB	250MB	300MB
> Success:		41	25	17	9
> Success(N):		87	53	37	22
>
> As background knowledge, up to 250MB, there is enough
> memory to succeed all order-3 allocation attempts. In 300MB case,
> available memory before starting allocation attempt is just 57MB,
> so all of attempts cannot succeed.
>
> Anyway, as free memory decreases, compaction success rate also decreases.
> It is better to remove this dependency to get stable compaction result
> in any case.
>
> To check 3), build-frag-unmovable/movable benchmarks are used.
> All factors are same except pageblock migratetypes.
>
> Test: build-frag-unmovable
>
> bzImage-improve-base
> compact_free_scanned           5032378
> compact_isolated               53368
> compact_migrate_scanned        1456516
> compact_stall                  538
> compact_success                93
> pgmigrate_success              19926
> Success:                       15
> Success(N):                    33
>
> Test: build-frag-movable
>
> bzImage-improve-base
> compact_free_scanned           3059086
> compact_isolated               129085
> compact_migrate_scanned        5029856
> compact_stall                  388
> compact_success                99
> pgmigrate_success              52898
> Success:                       38
> Success(N):                    82
>
> Pageblock migratetype makes big difference on success rate. 3) would be
> one of reason related to this result. Because freepage scanner doesn't
> scan non-movable pageblock, compaction can't get enough freepage for
> migration and compaction easily fails. This patchset try to solve it
> by allowing freepage scanner to scan on non-movable pageblock.
>
> Result show that we cannot get all possible high order page through
> current compaction algorithm. And, in case that migratetype of
> pageblock is unmovable, success rate get worse. Although we can solve
> problem 3) in current algorithm, there is unsolvable limitations, 1), 2),
> so I'd like to change compaction algorithm.
>
> This patchset try to solve these limitations by introducing new compaction
> approach. Main changes of this patchset are as following:
>
> 1) Make freepage scanner scans non-movable pageblock
> Watermark check doesn't consider how many pages in non-movable pageblock.
> To fully utilize existing freepage, freepage scanner should scan
> non-movable pageblock.

I share Mel's concerns here. The evaluation should consider long-term 
fragmentation effects. Especially when you've already seen a regression 
from this patch.

> 2) Introduce compaction depletion state
> Compaction algorithm will be changed to scan whole zone range. In this
> approach, compaction inevitably do back and forth migration between
> different iterations. If back and forth migration can make highorder
> freepage, it can be justified. But, in case of depletion of compaction
> possiblity, this back and forth migration causes unnecessary overhead.
> Compaction depleteion state is introduced to avoid this useless
> back and forth migration by detecting depletion of compaction possibility.

Interesting, but I'll need to study this in more detail to grasp it 
completely. Limiting the scanning because of not enough success might 
naturally lead to even less success and potentially never recover?

> 3) Change scanner's behaviour
> Migration scanner is changed to scan whole zone range regardless freepage
> scanner position. Freepage scanner also scans whole zone from
> zone_start_pfn to zone_end_pfn.

OK so you did propose this in response to my pivot changing compaction. 
I've been testing approach like this too, to see which is better, but it 
differs in many details. E.g. I just disabled pageblock skip bits for 
the time being, the way you handle them probably makes sense. The 
results did look nice (when free scanner ignored pageblock migratetype), 
but the cost was very high. Not ignoring migratetype looked like a 
better compromise on high-level look, but the inability of free scanner 
to find anything does suck. I wonder what compromise could exist here. 
You did also post a RFC that migrates everything out of newly made 
unmovable pageblocks in the event of fallback allocation, and letting 
free scanner use such pageblocks goes against that.

> To prevent back and forth migration
> within one compaction iteration, freepage scanner marks skip-bit when
> scanning pageblock. Migration scanner will skip this marked pageblock.
> Finish condition is very simple. If migration scanner reaches end of
> the zone, compaction will be finished. If freepage scanner reaches end of
> the zone first, it restart at zone_start_pfn. This helps us to overcome
> dependency on amount of free memory.

Isn't there a danger of the free scanner scanning the zone many times 
during single compaction run? Does anything prevent it from scanning the 
same pageblock as the migration scanner at the same time? The skip bit 
is set only after free scanner is finished with a block AFAICS.

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
