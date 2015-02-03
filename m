Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 19C196B006E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 10:00:56 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id z81so49512736oif.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 07:00:55 -0800 (PST)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id tr1si6120164obb.35.2015.02.03.07.00.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 07:00:55 -0800 (PST)
Received: by mail-oi0-f54.google.com with SMTP id v63so49437752oia.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 07:00:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54D08F48.5030909@suse.cz>
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
	<20150203064941.GA9822@js1304-P5Q-DELUXE>
	<54D08F48.5030909@suse.cz>
Date: Wed, 4 Feb 2015 00:00:55 +0900
Message-ID: <CAAmzW4Oe+65bF5QQxTkJ72H4YpxmcxP0qSSdus6BmCspMyd1DA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] compaction: changing initial position of scanners
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

2015-02-03 18:05 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 02/03/2015 07:49 AM, Joonsoo Kim wrote:
>> On Mon, Jan 19, 2015 at 11:05:15AM +0100, Vlastimil Babka wrote:
>>
>> Hello,
>>
>> I don't have any elegant idea, but, have some humble opinion.
>>
>> The point is that migrate scanner should scan whole zone.
>> Although your pivot approach makes some sense and it can scan whole zone,
>> it could cause back and forth migration in a very short term whenever
>> both scanners get toward and passed each other.
>
> I don't understand the scenario you suggest? The scanners don't overlap in any
> single run, that doesn't change. If they meet, compaction terminates. They can
> "overlap" if you compare the current run with previous run, after pivot change.

Yeah, I mean this case.

I think that we should regard single run as whole zone scan rather than just
terminating criteria we have artificially defined and try to avoid
back and forth
problem as much as possible in this scale. Not overlapping in a single run you
mentioned doesn't solve this problem in this scale.

> The it's true that e.g. migration scanner will operate on pageblocks where the
> free scanner has operated on previously. But pivot changes are only done after
> the full defer cycle, which is not short term.

I don't think it's not short term. After successful run, if next high
order request
comes immediately, migrate scanner will immediately restart at the position
where previous free scanner has operated.

>
>> I think that if we permit
>> overlap of scanner, we don't need to adhere to reverse linear scanning
>> in freepage scanner since reverse liner scan doesn't prevent back and
>> forth migration from now on.
>
> I believe that we still don't permit overlap, but anyway...
>
>> There are two solutions on this problem.
>> One is that free scanner scans pfn in same direction where migrate scanner
>> goes with having proper interval.
>>
>> |=========================|
>> MMM==>  <Interval>  FFF==>
>>
>> Enough interval guarantees to prevent back and forth migration,
>> at least, in a very short period.
>
> That would depend on the termination criteria and what to do after restart.
> You would have to terminate as soon as one scanner approaches the position where
> the other started. Otherwise you overlap and migrate back in a single run. So
> you terminate and that will typically mean one of the scanners did not finish
> its part fully, so there are pageblocks scanned by neither one. You could adjust
> the interval to find the optimal one. But you shouldn't do it immediately next
> run, as that would overlap the previous run too soon. Or maybe adjust it only a
> little... I don't know if that's simpler than my approach, it seems more quirky.

Yeah, the idea comes from quick thought so it's not perfect.
In fact, if we regard single run as whole zone scan, back and forth problem is
inevitable. What we can do best is reducing bad effect of that problem. With
interval, we don't try to migrate page which we immediately use for freepage
in a very short period.

I think that we can break relationship of free scanner and migrate scanner.
It's not necessary that summation of scanned range of both scanner is whole
zone. The point is migrate scanner should scan whole zone. Free scanner
would adjust scanning position based on the position where
migrate scanner is, whenever necessary.

>> Or, we could make free scanner totally different with linear scan.
>> Linear scanning to get freepage wastes much time if system memory
>> is really big and most of it is used. If we takes freepage from the
>> buddy, we can eliminate this scanning overhead. With additional
>> logic, that is, comparing position of freepage with migrate scanner
>> and selectively taking it, we can avoid back and forth migration
>> in a very short period.
>
> I think the metric we should be looking is the ration between free pages scanned
> and migrate pages scanned. It's true that after this series in the
> allocate-as-thp scenario, it was more than 10 in the first run after reboot.
> So maybe it could be more efficient to search the buddy lists. But then again,
> when to terminate in this case? The free lists are changing continuously. And to
> compare position, you also need to predict how much the migrate scanner will
> progress in the single run, because you don't want to take pages from there.

We can terminate when whole zone is scanned. As I mentioned above, we can't
avoid back and forth problem in case of whole zone range and I'd like to do what
we can do our best, avoiding back and forth in a very short term. Maybe, taking
freepage positioned zone_range/2 far from with migrated scanner at that time
would prevent the problem occurrence in a very short term.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
