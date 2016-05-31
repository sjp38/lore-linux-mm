Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A32CB6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 08:29:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so63867963lfh.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 05:29:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1si50433800wjz.36.2016.05.31.05.29.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 05:29:26 -0700 (PDT)
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
 <20160531063740.GC30967@js1304-P5Q-DELUXE>
 <276c5490-c5e3-2ba5-68d8-df02922f6122@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8c3efbf0-6c05-273d-5d35-bd0b386a20ec@suse.cz>
Date: Tue, 31 May 2016 14:29:24 +0200
MIME-Version: 1.0
In-Reply-To: <276c5490-c5e3-2ba5-68d8-df02922f6122@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/31/2016 02:07 PM, Vlastimil Babka wrote:
> On 05/31/2016 08:37 AM, Joonsoo Kim wrote:
>>> @@ -3695,22 +3695,22 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>>  	else
>>>  		no_progress_loops++;
>>>
>>> -	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
>>> -				 did_some_progress > 0, no_progress_loops))
>>> -		goto retry;
>>> -
>>> +	should_retry = should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
>>> +				 did_some_progress > 0, no_progress_loops);
>>>  	/*
>>>  	 * It doesn't make any sense to retry for the compaction if the order-0
>>>  	 * reclaim is not able to make any progress because the current
>>>  	 * implementation of the compaction depends on the sufficient amount
>>>  	 * of free memory (see __compaction_suitable)
>>>  	 */
>>> -	if (did_some_progress > 0 &&
>>> -			should_compact_retry(ac, order, alloc_flags,
>>> +	if (did_some_progress > 0)
>>> +		should_retry |= should_compact_retry(ac, order, alloc_flags,
>>>  				compact_result, &compact_priority,
>>> -				compaction_retries))
>>> +				compaction_retries);
>>> +	if (should_retry)
>>>  		goto retry;
>>
>> Hmm... it looks odd that we check should_compact_retry() when
>> did_some_progress > 0. If system is full of anonymous memory and we
>> don't have swap, we can't reclaim anything but we can compact.
>
> Right, thanks.

Hmm on the other hand, should_compact_retry will assume (in 
compaction_zonelist_suitable()) that reclaimable memory is actually 
reclaimable. If there's nothing to tell us that it actually isn't, if we 
drop the reclaim progress requirement. That's risking an infinite loop?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
