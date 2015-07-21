Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A91166B028B
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 05:27:58 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so36112324wic.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 02:27:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10si18259305wij.0.2015.07.21.02.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 02:27:56 -0700 (PDT)
Message-ID: <55AE109A.4020803@suse.cz>
Date: Tue, 21 Jul 2015 11:27:54 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com> <20150625110314.GJ11809@suse.de> <CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com> <20150625172550.GA26927@suse.de> <CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com> <20150625184135.GB26927@suse.de> <CAAmzW4OuArqzavsPY3_3u5OnnO=ZY1HSnUT4Rgoq2ytd+n89xQ@mail.gmail.com> <20150626102241.GH26927@suse.de> <20150708082458.GA17015@js1304-P5Q-DELUXE>
In-Reply-To: <20150708082458.GA17015@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On 07/08/2015 10:24 AM, Joonsoo Kim wrote:
> On Fri, Jun 26, 2015 at 11:22:41AM +0100, Mel Gorman wrote:
>> On Fri, Jun 26, 2015 at 11:07:47AM +0900, Joonsoo Kim wrote:
>>
>> The whole reason we avoid migrating to unmovable blocks is because it
>> did happen and quite quickly.  Do not use unmovable blocks as migration
>> targets. If high-order kernel allocations are required then some reclaim
>> is necessary for compaction to work with.
>
> Hello, Mel and Vlastimil.
>
> Sorry for late response. I need some time to get the number and it takes
> so long due to bugs on page owner. Before mentioning about this patchset,
> I should mention that result of my previous patchset about active
> fragmentation avoidance that you have reviewed is wrong. Incorrect result
> is caused by page owner bug and correct result shows just slight
> improvement rather than dramatical improvment.
>
> https://lkml.org/lkml/2015/4/27/92

Doh, glad you found the bug.
BTW I still think patch 1 of that series would make sense and it's a 
code cleanup too. Patch 2 would depend on the corrected measurements. 
Patch 3 also, and the active anti-fragmentation work could be done by 
kcompactd if the idea of that thread floats.

> Back to our discussion, indeed, you are right. As you expected,
> fragmentation increases due to this patch. It's not much but adding
> other changes of this patchset accelerates fragmentation more so
> it's not tolerable in the end.
>
> Below is number of *non-mixed* pageblock measured by page owner
> after running modified stress-highalloc test that repeats test 3 times
> without rebooting like as Vlastimil did.
>
> pb[n] means that it is measured after n times runs of stress-highalloc
> test without rebooting. They are averaged by 3 runs.
>
>                          base nonmovable redesign revert-nonmovable
> pb[1]:DMA32:movable:    1359    1333    1303    1380
> pb[1]:Normal:movable:   368     341     356     364
>
> pb[2]:DMA32:movable:    1306    1277    1216    1322
> pb[2]:Normal:movable:   359     345     325     349
>
> pb[3]:DMA32:movable:    1265    1240    1179    1276
> pb[3]:Normal:movable:   330     330     312     332
>
> Allowing scanning on nonmovable pageblock increases fragmentation so
> non-mixed pageblock is reduced by rougly 2~3%. Whole of this patchset
> bumps this reduction up to roughly 6%. But, with reverting nonmovable
> patch, it get restored and looks better than before.

Hm that's somewhat strange. Why is it only the *combination* of 
"nonmovable" and "redesign" that makes it so bad?

> Nevertheless, still, I'd like to change freepage scanner's behaviour
> because there are systems that most of pageblocks are unmovable pageblock.
> In this kind of system, without this change, compaction would not
> work well as my experiment, build-frag-unmovable, showed, and essential
> high-order allocation fails.
>
> I have no idea how to overcome this situation without this kind of change.
> If you have such a idea, please let me know.

Hm it's a tough one :/

> Here is similar idea to handle this situation without causing more
> fragmentation. Changes as following:
>
> 1. Freepage scanner just scan only movable pageblocks.
> 2. If freepage scanner doesn't find any freepage on movable pageblocks
> and whole zone range is scanned, freepage scanner start to scan on
> non-movable pageblocks.
>
> Here is the result.
>                                                  new-idea
> pb[1]:DMA32:movable:                            1371
> pb[1]:Normal:movable:                            384
>
> pb[2]:DMA32:movable:                            1322
> pb[2]:Normal:movable:                            372
>
> pb[3]:DMA32:movable:                            1273
> pb[3]:Normal:movable:                            358
>
> Result is better than revert-nonmovable case. Although I didn't attach
> the whole result, this one is better than revert one in term of success
> rate.
>
> Before starting to optimize this idea, I'd like to hear your opinion
> about this change.

Well, it might be better than nothing. Optimization could be remembering 
from the first pass which pageblock was the emptiest? But that would 
make the first pass more involved, so I'm not sure.

> I think this change is essential because fail on high-order allocation
> up to PAGE_COSTLY_ORDER is functional failure and MM should guarantee
> it's success. After lumpy recliam is removed, this kind of allocation
> unavoidably rely on work of compaction. We can't prevent that movable
> pageblocks are turned into unmovable pageblock because it is highly
> workload dependant.
>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
