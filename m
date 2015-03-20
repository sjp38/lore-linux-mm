Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 584CB6B006C
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 00:16:13 -0400 (EDT)
Received: by pagj4 with SMTP id j4so5027066pag.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 21:16:13 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id hv8si7115366pad.13.2015.03.19.21.16.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 21:16:12 -0700 (PDT)
Message-ID: <550B9EF2.7000604@huawei.com>
Date: Fri, 20 Mar 2015 12:15:46 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tracing: add trace event for memory-failure
References: <1426734270-8146-1-git-send-email-xiexiuqi@huawei.com> <20150319103939.GD11544@pd.tnic>
In-Reply-To: <20150319103939.GD11544@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: n-horiguchi@ah.jp.nec.com, gong.chen@linux.intel.com, bhelgaas@google.com, tony.luck@intel.com, rostedt@goodmis.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

On 2015/3/19 18:39, Borislav Petkov wrote:
> On Thu, Mar 19, 2015 at 11:04:30AM +0800, Xie XiuQi wrote:
>> Memory-failure as the high level machine check handler, it's necessary
>> to report memory page recovery action result to user space by ftrace.
>>
>> This patch add a event at ras group for memory-failure.
>>
>> The output like below:
>> #  tracer: nop
>> # 
>> #  entries-in-buffer/entries-written: 2/2   #P:24
>> # 
>> #                               _-----=> irqs-off
>> #                              / _----=> need-resched
>> #                             | / _---=> hardirq/softirq
>> #                             || / _--=> preempt-depth
>> #                             ||| /     delay
>> #            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
>> #               | |       |   ||||       |         |
>>        mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: free buddy page recovery: Delayed
>>
>> ---
>> v1->v2:
>>  - Comment update
>>  - Just passing 'result' instead of 'action_name[result]',
>>    suggested by Steve. And hard coded there because trace-cmd
>>    and perf do not have a way to process enums.
>>
>> Cc: Tony Luck <tony.luck@intel.com>
>> Cc: Steven Rostedt <rostedt@goodmis.org>
>> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
>> ---
>>  include/ras/ras_event.h | 38 ++++++++++++++++++++++++++++++++++++++
>>  mm/memory-failure.c     |  3 +++
>>  2 files changed, 41 insertions(+)
>>
>> diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
>> index 79abb9c..ebb05f3 100644
>> --- a/include/ras/ras_event.h
>> +++ b/include/ras/ras_event.h
>> @@ -232,6 +232,44 @@ TRACE_EVENT(aer_event,
>>  		__print_flags(__entry->status, "|", aer_uncorrectable_errors))
>>  );
>>  
>> +/*
>> + * memory-failure recovery action result event
>> + *
>> + * unsigned long pfn -	Page Number of the corrupted page
>> + * char * action -	Recovery action for various type of pages
>> + * int result	 -	Action result
>> + *
>> + * NOTE: 'action' and 'result' are defined at mm/memory-failure.c
>> + */
>> +TRACE_EVENT(memory_failure_event,
> 
> What is the real reason for adding this TP? Real-life use cases please.
> Add those to the commit message too.
> 
> "Just because" is not a proper justification.

RAS user space tools like rasdaemon which base on trace event, could
receive mce error event, but no memory recovery result event. So, I
want to add this event to make this scenario complete.

I'll add it to commit message, thanks.

> 
>> +	TP_PROTO(const unsigned long pfn,
>> +		 const char *action,
>> +		 const int result),
>> +
>> +	TP_ARGS(pfn, action, result),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(unsigned long, pfn)
>> +		__string(action, action)
>> +		__field(int, result)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->pfn	= pfn;
>> +		__assign_str(action, action);
>> +		__entry->result	= result;
>> +	),
>> +
>> +	TP_printk("pfn %#lx: %s page recovery: %s",
>> +		__entry->pfn,
>> +		__get_str(action),
>> +		__print_symbolic(__entry->result,
>> +				{0, "Ignored"},
>> +				{1, "Failed"},
>> +				{2, "Delayed"},
>> +				{3, "Recovered"})
> 
> If you're going to do this, please add a comment above it like this:
> 
> /*
>  * Keep those in sync with static const char *action_name[] in
>  * mm/memory-failure.c
>  */

Thanks. I will ;-)

> 
> Thanks.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
