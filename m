Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A51C6B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 03:18:08 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xr1so19819291wjb.7
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 00:18:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c202si11476921wmh.27.2016.12.15.00.18.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 00:18:07 -0800 (PST)
Subject: Re: [PATCH 3/3] oom, trace: add compaction retry tracepoint
References: <20161214145324.26261-1-mhocko@kernel.org>
 <20161214145324.26261-4-mhocko@kernel.org>
 <60cfb7ca-fb95-7a34-bae2-9b7c49119573@suse.cz>
 <20161214181133.GB16763@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <46f91596-3927-3be3-0f86-bd0f5a588cfd@suse.cz>
Date: Thu, 15 Dec 2016 09:18:05 +0100
MIME-Version: 1.0
In-Reply-To: <20161214181133.GB16763@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 12/14/2016 07:11 PM, Michal Hocko wrote:
> On Wed 14-12-16 18:28:38, Vlastimil Babka wrote:
>> On 12/14/2016 03:53 PM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> Higher order requests oom debugging is currently quite hard. We do have
>>> some compaction points which can tell us how the compaction is operating
>>> but there is no trace point to tell us about compaction retry logic.
>>> This patch adds a one which will have the following format
>>>
>>>             bash-3126  [001] ....  1498.220001: compact_retry: order=9 priority=COMPACT_PRIO_SYNC_LIGHT compaction_result=withdrawn retries=0 max_retries=16 should_retry=0
>>>
>>> we can see that the order 9 request is not retried even though we are in
>>> the highest compaction priority mode becase the last compaction attempt
>>> was withdrawn. This means that compaction_zonelist_suitable must have
>>> returned false and there is no suitable zone to compact for this request
>>> and so no need to retry further.
>>>
>>> another example would be
>>>            <...>-3137  [001] ....    81.501689: compact_retry: order=9 priority=COMPACT_PRIO_SYNC_LIGHT compaction_result=failed retries=0 max_retries=16 should_retry=0
>>>
>>> in this case the order-9 compaction failed to find any suitable
>>> block. We do not retry anymore because this is a costly request
>>> and those do not go below COMPACT_PRIO_SYNC_LIGHT priority.
>>>
>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>> ---
>>>  include/trace/events/mmflags.h | 26 ++++++++++++++++++++++++++
>>>  include/trace/events/oom.h     | 39 +++++++++++++++++++++++++++++++++++++++
>>>  mm/page_alloc.c                | 22 ++++++++++++++++------
>>>  3 files changed, 81 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
>>> index 7e4cfede873c..aa4caa6914a9 100644
>>> --- a/include/trace/events/mmflags.h
>>> +++ b/include/trace/events/mmflags.h
>>> @@ -187,8 +187,32 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
>>>  	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
>>>  	EM( COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")	\
>>>  	EMe(COMPACT_CONTENDED,		"contended")
>>> +
>>> +/* High-level compaction status feedback */
>>> +#define COMPACTION_FAILED	1
>>> +#define COMPACTION_WITHDRAWN	2
>>> +#define COMPACTION_PROGRESS	3
>>> +
>>> +#define compact_result_to_feedback(result)	\
>>> +({						\
>>> + 	enum compact_result __result = result;	\
>>> +	(compaction_failed(__result)) ? COMPACTION_FAILED : \
>>> +		(compaction_withdrawn(__result)) ? COMPACTION_WITHDRAWN : COMPACTION_PROGRESS; \
>>> +})
>>
>> It seems you forgot to actually use this "function" (sorry, didn't notice
>> earlier) so currently it's translating enum compact_result directly into the
>> failed/withdrawn/progress strings, which is wrong.
>
> You are right. I've screwed while integrating the enum translation part.
>
>> The correct place for the result->feedback conversion should be
>> TP_fast_assign, so __entry->result should become __entry->feedback. It's too
>> late in TP_printk, as userspace tools (e.g. trace-cmd) won't know the
>> functions that compact_result_to_feedback() uses.
>
> Thanks. The follow up fix should be
> ---
> From 82c9064698594d694b052d3847c905e90becc7c5 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 14 Dec 2016 19:09:10 +0100
> Subject: [PATCH] fold me "oom, trace: add compaction retry tracepoint"
>
> Do not forget to translate compact_result into a highlevel constants
> as per Vlastimil
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

OK, with that:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/trace/events/oom.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
> index e9d690665b7a..38baeb27221a 100644
> --- a/include/trace/events/oom.h
> +++ b/include/trace/events/oom.h
> @@ -94,7 +94,7 @@ TRACE_EVENT(compact_retry,
>  	TP_fast_assign(
>  		__entry->order = order;
>  		__entry->priority = priority;
> -		__entry->result = result;
> +		__entry->result = compact_result_to_feedback(result);
>  		__entry->retries = retries;
>  		__entry->max_retries = max_retries;
>  		__entry->ret = ret;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
