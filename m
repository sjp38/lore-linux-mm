Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 251C26B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:31:17 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id n8so134436633ybn.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 23:31:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bu7si23829110wjc.65.2016.08.15.23.31.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Aug 2016 23:31:16 -0700 (PDT)
Subject: Re: [PATCH v6 06/11] mm, compaction: more reliably increase direct
 compaction priority
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-7-vbabka@suse.cz>
 <20160816060737.GC17448@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d32f4619-e7a8-863a-bf94-4cbc0b452630@suse.cz>
Date: Tue, 16 Aug 2016 08:31:13 +0200
MIME-Version: 1.0
In-Reply-To: <20160816060737.GC17448@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/16/2016 08:07 AM, Joonsoo Kim wrote:
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  mm/page_alloc.c | 18 +++++++++++-------
>>  1 file changed, 11 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index fb975cec3518..b28517b918b0 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3155,13 +3155,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>>  	 * so it doesn't really make much sense to retry except when the
>>  	 * failure could be caused by insufficient priority
>>  	 */
>> -	if (compaction_failed(compact_result)) {
>> -		if (*compact_priority > MIN_COMPACT_PRIORITY) {
>> -			(*compact_priority)--;
>> -			return true;
>> -		}
>> -		return false;
>> -	}
>> +	if (compaction_failed(compact_result))
>> +		goto check_priority;
>>
>>  	/*
>>  	 * make sure the compaction wasn't deferred or didn't bail out early
>> @@ -3185,6 +3180,15 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>>  	if (compaction_retries <= max_retries)
>>  		return true;
>>
>> +	/*
>> +	 * Make sure there is at least one attempt at the highest priority
>> +	 * if we exhausted all retries at the lower priorities
>> +	 */
>> +check_priority:
>> +	if (*compact_priority > MIN_COMPACT_PRIORITY) {
>> +		(*compact_priority)--;
>> +		return true;
>> +	}
>>  	return false;
>
> The only difference that this patch makes is increasing priority when
> COMPACT_PARTIAL(COMPACTION_SUCCESS) returns. In that case, we can

Hm it's true that I adjusted this patch from the previous version, 
before realizing that PARTIAL is now SUCCESS.

> usually allocate high-order freepage so we would not enter here. Am I
> missing something? Is it really needed behaviour change?

It will likely be rare when this triggers, when compaction success 
doesn't lead to allocation success due to parallel allocation activity.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
