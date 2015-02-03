Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 62BA76B006C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:07:12 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wp4so9170797obc.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:07:12 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id we1si4971990oeb.38.2015.02.03.09.07.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 09:07:11 -0800 (PST)
Received: by mail-oi0-f53.google.com with SMTP id i138so50090098oig.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:07:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54D0EE90.5030305@suse.cz>
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
	<20150203064941.GA9822@js1304-P5Q-DELUXE>
	<54D08F48.5030909@suse.cz>
	<CAAmzW4Oe+65bF5QQxTkJ72H4YpxmcxP0qSSdus6BmCspMyd1DA@mail.gmail.com>
	<54D0EE90.5030305@suse.cz>
Date: Wed, 4 Feb 2015 02:07:11 +0900
Message-ID: <CAAmzW4PRpQg871ymGQPsuht_j0+vyVo233gKhw3qvJS1WSu++Q@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] compaction: changing initial position of scanners
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

2015-02-04 0:51 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 02/03/2015 04:00 PM, Joonsoo Kim wrote:
>> 2015-02-03 18:05 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>>> On 02/03/2015 07:49 AM, Joonsoo Kim wrote:
>>>> On Mon, Jan 19, 2015 at 11:05:15AM +0100, Vlastimil Babka wrote:
>>>>
>>>> Hello,
>>>>
>>>> I don't have any elegant idea, but, have some humble opinion.
>>>>
>>>> The point is that migrate scanner should scan whole zone.
>>>> Although your pivot approach makes some sense and it can scan whole zone,
>>>> it could cause back and forth migration in a very short term whenever
>>>> both scanners get toward and passed each other.
>>>
>>> I don't understand the scenario you suggest? The scanners don't overlap in any
>>> single run, that doesn't change. If they meet, compaction terminates. They can
>>> "overlap" if you compare the current run with previous run, after pivot change.
>>
>> Yeah, I mean this case.
>>
>> I think that we should regard single run as whole zone scan rather than just
>> terminating criteria we have artificially defined and try to avoid
>> back and forth
>> problem as much as possible in this scale. Not overlapping in a single run you
>> mentioned doesn't solve this problem in this scale.
>>
>>> The it's true that e.g. migration scanner will operate on pageblocks where the
>>> free scanner has operated on previously. But pivot changes are only done after
>>> the full defer cycle, which is not short term.
>>
>> I don't think it's not short term. After successful run, if next high
>> order request
>> comes immediately, migrate scanner will immediately restart at the position
>> where previous free scanner has operated.
>
> Ah, I think I see where the misunderstanding comes from now. So to clarify,
> let's consider
>
> 1. single compaction run - single invocation of compact_zone(). It can start
> from cached pfn's from previous run, or zone boundaries (or pivot, after this
> series), and terminate with scanners meeting or not meeting.
>
> 2. full zone compaction - consists one or more compaction runs, where the first
> run starts at boundaries (pivot). It ends when scanners meet -
> compact_finished() returns COMPACT_COMPLETE
>
> 3. compaction after full defer cycle - this is full zone compaction, where
> compaction_restarting() returns true in its first run
>
> My understanding is that you think pivot changing occurs after each full zone
> compaction (definition 2), but in fact it occurs only each defer cycle
> (definition 3). See patch 5 for detailed reasoning. I don't think it's short
> term. It means full zone compactions (def 2) already failed many times and then
> was deferred for further time, using the same unchanged pivot.

Ah... thanks for clarifying. I actually think pivot changing occurs at
definition 2
as you guess. :)

> I think any of the alternatives you suggested below where migrate scanner
> processes whole zone during full zone compaction (2), would necessarily result
> in shorter-term back and forth migration than this scheme. On the other hand,
> the pivot changing proposed here might be too long-term. But it's a first
> attempt, and the frequency can be further tuned.

Yes, your proposal would be less problematic on back and forth problem than
my suggestion.

Hmm...nevertheless, I can't completely agree with pivot approach.

I'd like to remove dependency of migrate scanner and free scanner such as
termination criteria at this chance. Meeting position of both scanner is roughly
determined by on amount of free memory in the zone. If 200 MB is free in
the zone, migrate scanner can scan at maximum 200 MB from the start pfn
of the pivot. Without changing pivot quickly, we can scan only
this region regardless zone size so it cause bad effect to high order
allocation for a long time.

In stress-highalloc test, it doesn't matter since we try to attempt a lot of
allocations. This bad effect would not appear easily. Although middle of
allocation attempts are failed, latter attempts would succeed
since pivot would be changed in the middle of attempts.

But, in real world scenario, all allocation attempts are precise and
it'd be better
first come high order allocation request to succeed and this is another problem
than allocation success rate in stress-highalloc test. To accomplish it, we
need to change pivot as soon as possible. Without it, we could miss some
precise allocation attempt until pivot is changed. For this purpose, we should
remove defer logic or change it more loosely and then, resetting pivot would
occur soon so we could encounter back and forth problem frequently.

Therefore, it's better to change compaction logic more fundamentally.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
