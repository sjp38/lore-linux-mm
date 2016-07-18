Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C58106B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 05:23:42 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p41so110839601lfi.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 02:23:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si6564140wmd.141.2016.07.18.02.23.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 02:23:41 -0700 (PDT)
Subject: Re: [PATCH v3 13/17] mm, compaction: use correct watermark when
 checking allocation success
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-14-vbabka@suse.cz>
 <20160706054722.GF23627@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ce4db136-ce45-ca62-3be7-62a135b4fecb@suse.cz>
Date: Mon, 18 Jul 2016 11:23:38 +0200
MIME-Version: 1.0
In-Reply-To: <20160706054722.GF23627@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 07/06/2016 07:47 AM, Joonsoo Kim wrote:
> On Fri, Jun 24, 2016 at 11:54:33AM +0200, Vlastimil Babka wrote:
>> The __compact_finished() function uses low watermark in a check that has to
>> pass if the direct compaction is to finish and allocation should succeed. This
>> is too pessimistic, as the allocation will typically use min watermark. It may
>> happen that during compaction, we drop below the low watermark (due to parallel
>> activity), but still form the target high-order page. By checking against low
>> watermark, we might needlessly continue compaction.
>>
>> Similarly, __compaction_suitable() uses low watermark in a check whether
>> allocation can succeed without compaction. Again, this is unnecessarily
>> pessimistic.
>>
>> After this patch, these check will use direct compactor's alloc_flags to
>> determine the watermark, which is effectively the min watermark.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> ---
>>  mm/compaction.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 76897850c3c2..371760a85085 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -1320,7 +1320,7 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
>>  		return COMPACT_CONTINUE;
>>
>>  	/* Compaction run is not finished if the watermark is not met */
>> -	watermark = low_wmark_pages(zone);
>> +	watermark = zone->watermark[cc->alloc_flags & ALLOC_WMARK_MASK];
>
> finish condition is changed. We have two more watermark checks in
> try_to_compact_pages() and kcompactd_do_work() and they should be
> changed too.

Ugh, I've completely missed them. Thanks for catching this, hopefully 
fixing that will improve the results.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
