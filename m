Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 697D06B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 22:07:48 -0400 (EDT)
Received: by oigx81 with SMTP id x81so65905313oig.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 19:07:48 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id p204si21091701oib.133.2015.06.25.19.07.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 19:07:47 -0700 (PDT)
Received: by obbop1 with SMTP id op1so58616197obb.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 19:07:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150625184135.GB26927@suse.de>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20150625110314.GJ11809@suse.de>
	<CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>
	<20150625172550.GA26927@suse.de>
	<CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>
	<20150625184135.GB26927@suse.de>
Date: Fri, 26 Jun 2015 11:07:47 +0900
Message-ID: <CAAmzW4OuArqzavsPY3_3u5OnnO=ZY1HSnUT4Rgoq2ytd+n89xQ@mail.gmail.com>
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

2015-06-26 3:41 GMT+09:00 Mel Gorman <mgorman@suse.de>:
> On Fri, Jun 26, 2015 at 03:14:39AM +0900, Joonsoo Kim wrote:
>> > It could though. Reclaim/compaction is entered for orders higher than
>> > PAGE_ALLOC_COSTLY_ORDER and when scan priority is sufficiently high.
>> > That could be adjusted if you have a viable case where orders <
>> > PAGE_ALLOC_COSTLY_ORDER must succeed and currently requires excessive
>> > reclaim instead of relying on compaction.
>>
>> Yes. I saw this problem in real situation. In ARM, order-2 allocation
>> is requested
>> in fork(), so it should be succeed. But, there is not enough order-2 freepage,
>> so reclaim/compaction begins. Compaction fails repeatedly although
>> I didn't check exact reason.
>
> That should be identified and repaired prior to reimplementing
> compaction because it's important.

Unfortunately, I got report a long time ago and I don't have any real
environment
to reproduce it. What I have remembered is that there are too many unmovable
allocations from graphic driver and zram and they really makes fragmented
memory. In that time, problem is solved by ad-hoc approach such as killing
many apps. But, it's sub-optimal and loosing performance greatly so I imitate
this effect in my benchmark and try to solve it by this patchset.

>> >> >> 3) Compaction capability is highly depends on migratetype of memory,
>> >> >> because freepage scanner doesn't scan unmovable pageblock.
>> >> >>
>> >> >
>> >> > For a very good reason. Unmovable allocation requests that fallback to
>> >> > other pageblocks are the worst in terms of fragmentation avoidance. The
>> >> > more of these events there are, the more the system will decay. If there
>> >> > are many of these events then a compaction benchmark may start with high
>> >> > success rates but decay over time.
>> >> >
>> >> > Very broadly speaking, the more the mm_page_alloc_extfrag tracepoint
>> >> > triggers with alloc_migratetype == MIGRATE_UNMOVABLE, the faster the
>> >> > system is decaying. Having the freepage scanner select unmovable
>> >> > pageblocks will trigger this event more frequently.
>> >> >
>> >> > The unfortunate impact is that selecting unmovable blocks from the free
>> >> > csanner will improve compaction success rates for high-order kernel
>> >> > allocations early in the lifetime of the system but later fail high-order
>> >> > allocation requests as more pageblocks get converted to unmovable. It
>> >> > might be ok for kernel allocations but THP will eventually have a 100%
>> >> > failure rate.
>> >>
>> >> I wrote rationale in the patch itself. We already use non-movable pageblock
>> >> for migration scanner. It empties non-movable pageblock so number of
>> >> freepage on non-movable pageblock will increase. Using non-movable
>> >> pageblock for freepage scanner negates this effect so number of freepage
>> >> on non-movable pageblock will be balanced. Could you tell me in detail
>> >> how freepage scanner select unmovable pageblocks will cause
>> >> more fragmentation? Possibly, I don't understand effect of this patch
>> >> correctly and need some investigation. :)
>> >>
>> >
>> > The long-term success rate of fragmentation avoidance depends on
>> > minimsing the number of UNMOVABLE allocation requests that use a
>> > pageblock belonging to another migratetype. Once such a fallback occurs,
>> > that pageblock potentially can never be used for a THP allocation again.
>> >
>> > Lets say there is an unmovable pageblock with 500 free pages in it. If
>> > the freepage scanner uses that pageblock and allocates all 500 free
>> > pages then the next unmovable allocation request needs a new pageblock.
>> > If one is not completely free then it will fallback to using a
>> > RECLAIMABLE or MOVABLE pageblock forever contaminating it.
>>
>> Yes, I can imagine that situation. But, as I said above, we already use
>> non-movable pageblock for migration scanner. While unmovable
>> pageblock with 500 free pages fills, some other unmovable pageblock
>> with some movable pages will be emptied. Number of freepage
>> on non-movable would be maintained so fallback doesn't happen.
>>
>> Anyway, it is better to investigate this effect. I will do it and attach
>> result on next submission.
>>
>
> Lets say we have X unmovable pageblocks and Y pageblocks overall. If the
> migration scanner takes movable pages from X then there is more space for
> unmovable allocations without having to increase X -- this is good. If
> the free scanner uses the X pageblocks as targets then they can fill. The
> next unmovable allocation then falls back to another pageblock and we
> either have X+1 unmovable pageblocks (full steal) or a mixed pageblock
> (partial steal) that cannot be used for THP. Do this enough times and
> X == Y and all THP allocations fail.

This was similar with my understanding but different conclusion.

As number of unmovable pageblocks, X, which is filled by movable pages
due to this compaction change increases, reclaimed/migrated out pages
from them also increase. And, then, further unmovable allocation request
will use this free space and eventually these pageblocks are totally filled
by unmovable allocation. Therefore, I guess, in the long-term, increasing X
is saturated and X == Y will not happen.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
