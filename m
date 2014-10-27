Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id C6D136B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 05:39:06 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id u10so5439749lbd.34
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 02:39:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ao9si19076288lac.33.2014.10.27.02.39.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 02:39:04 -0700 (PDT)
Message-ID: <544E12B5.5070008@suse.cz>
Date: Mon, 27 Oct 2014 10:39:01 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm, compaction: always update cached scanner positions
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz> <1412696019-21761-5-git-send-email-vbabka@suse.cz> <20141027073522.GB23379@js1304-P5Q-DELUXE>
In-Reply-To: <20141027073522.GB23379@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 10/27/2014 08:35 AM, Joonsoo Kim wrote:> On Tue, Oct 07, 2014 at
05:33:38PM +0200, Vlastimil Babka wrote:
>> Compaction caches the migration and free scanner positions between
compaction
>> invocations, so that the whole zone gets eventually scanned and there
is no
>> bias towards the initial scanner positions at the beginning/end of
the zone.
>>
>> The cached positions are continuously updated as scanners progress
and the
>> updating stops as soon as a page is successfully isolated. The reasoning
>> behind this is that a pageblock where isolation succeeded is likely
to succeed
>> again in near future and it should be worth revisiting it.
>>
>> However, the downside is that potentially many pages are rescanned
without
>> successful isolation. At worst, there might be a page where isolation
from LRU
>> succeeds but migration fails (potentially always). So upon
encountering this
>> page, cached position would always stop being updated for no good reason.
>> It might have been useful to let such page be rescanned with sync
compaction
>> after async one failed, but this is now handled by caching scanner
position
>> for async and sync mode separately since commit 35979ef33931 ("mm,
compaction:
>> add per-zone migration pfn cache for async compaction").
>
> Hmm... I'm not sure that this patch is good thing.
>
> In asynchronous compaction, compaction could be easily failed and
> isolated freepages are returned to the buddy. In this case, next
> asynchronous compaction would skip those returned freepages and
> both scanners could meet prematurely.

If migration fails, free pages now remain isolated until next migration
attempt, which should happen within the same compaction when it isolates
new migratepages - it won't fail completely just because of failed
migration. It might run out of time due to need_resched and then yeah,
some free pages might be skipped. That's some tradeoff but at least my
tests don't seem to show reduced success rates.

> And, I guess that pageblock skip feature effectively disable pageblock
> rescanning if there is no freepage during rescan.

If there's no freepage during rescan, then the cached free_pfn also
won't be pointed to the pageblock anymore. Regardless of pageblock skip
being set, there will not be second rescan. But there will still be the
first rescan to determine there are no freepages.

> This patch would
> eliminate effect of pageblock skip feature.

I don't think so (as explained above). Also if free pages were isolated
(and then returned and skipped over), the pageblock should remain
without skip bit, so after scanners meet and positions reset (which
doesn't go hand in hand with skip bit reset), the next round will skip
over the blocks without freepages and find quickly the blocks where free
pages were skipped in the previous round.

> IIUC, compaction logic assume that there are many temporary failure
> conditions. Retrying from others would reduce effect of this temporary
> failure so implementation looks as is.

The implementation of pfn caching was written at time when we did not
keep isolated free pages between migration attempts in a single
compaction run. And the idea of async compaction is to try with minimal
effort (thus latency), and if there's a failure, try somewhere else.
Making sure we don't skip anything doesn't seem productive.

> If what we want is scanning each page once in each epoch, we can
> implement compaction logic differently.

Well I'm open to suggestions :) Can't say the current set of heuristics
is straightforward to reason about.

> Please let me know if I'm missing something.
>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
