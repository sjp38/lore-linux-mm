Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4D16B6B00D5
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 07:47:14 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so4131379wiw.2
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 04:47:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si32203209wia.1.2014.11.13.04.47.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 04:47:11 -0800 (PST)
Message-ID: <5464A84C.1040903@suse.cz>
Date: Thu, 13 Nov 2014 13:47:08 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm, compaction: more focused lru and pcplists draining
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz> <1412696019-21761-6-git-send-email-vbabka@suse.cz> <20141027074112.GC23379@js1304-P5Q-DELUXE> <545738F1.4010307@suse.cz> <20141104003733.GB8412@js1304-P5Q-DELUXE>
In-Reply-To: <20141104003733.GB8412@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 11/04/2014 01:37 AM, Joonsoo Kim wrote:
> On Mon, Nov 03, 2014 at 09:12:33AM +0100, Vlastimil Babka wrote:
>> On 10/27/2014 08:41 AM, Joonsoo Kim wrote:
>>> On Tue, Oct 07, 2014 at 05:33:39PM +0200, Vlastimil Babka wrote:
>>>
>>> And, I wonder why last_migrated_pfn is set after isolate_migratepages().
>>
>> Not sure I understand your question. With the mistake above, it
>> cannot currently be set at the point isolate_migratepages() is
>> called, so you might question the goto check_drain in the
>> ISOLATE_NONE case, if that's what you are wondering about.
>>
>> When I correct that, it might be set when COMPACT_CLUSTER_MAX pages
>> are isolated and migrated the middle of a pageblock, and then the
>> rest of the pageblock contains no pages that could be isolated, so
>> the last isolate_migratepages() attempt in the pageblock returns
>> with ISOLATE_NONE. Still there were some migrations that produced
>> free pages that should be drained at that point.
>
> To clarify my question, I attach psuedo code that I thought correct.

Sorry for the late reply.

> static int compact_zone()
> {
>          unsigned long last_migrated_pfn = 0;
>
>          ...
>
>          compaction_suitable();
>
>          ...
>
>          while (compact_finished()) {
>                  if (!last_migrated_pfn)
>                          last_migrated_pfn = cc->migrate_pfn - 1;
>
>                  isolate_migratepages();
>                  switch case
>                  migrate_pages();
>                  ...
>
>                  check_drain: (at the end of loop)
>                          do flush and reset last_migrated_pfn if needed
>          }
> }
>
> We should record last_migrated_pfn before isolate_migratepages() and
> then compare it with cc->migrate_pfn after isolate_migratepages() to
> know if we moved away from the previous cc->order aligned block.
> Am I missing something?

What about this scenario, with pageblock order:

- record cc->migrate_pfn pointing to pageblock X
- isolate_migratepages() skips the pageblock due to e.g. skip bit, or 
the pageblock being a THP already...
- loop to pageblock X+1, last_migrated_pfn is still set to pfn of 
pageblock X (more precisely the pfn is (X << pageblock_order) - 1 per 
your code, but doesn't matter)
- isolate_migratepages isolates something, but ends up somewhere in the 
middle of pageblock due to COMPACT_CLUSTER_MAX
- cc->migrate_pfn points to pageblock X+1 (plus some pages it scanned)
- so it will decide that it has fully migrated pageblock X and it's time 
to drain. But the drain is most likely useless - we didn't migrate 
anything in pageblock X, we skipped it. And in X+1 we didn't migrate 
everything yet, so we should drain only after finishing the other part 
of the pageblock.

In short, "last_migrated_pfn" is not "last position of migrate scanner" 
but "last block where we *actually* migrated".

I think if you would try to fix the scenario above, you would end up 
with something like my patch :)

Vlastimil

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
