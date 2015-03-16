Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD796B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 09:05:57 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so57969527pdb.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 06:05:56 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id lp6si22499835pab.69.2015.03.16.06.05.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 06:05:55 -0700 (PDT)
Message-ID: <5506D4FA.4020501@huawei.com>
Date: Mon, 16 Mar 2015 21:04:58 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tracing: add trace event for memory-failure
References: <1426241451-25729-1-git-send-email-xiexiuqi@huawei.com> <20150316092708.GC15902@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150316092708.GC15902@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

On 2015/3/16 17:27, Naoya Horiguchi wrote:
> On Fri, Mar 13, 2015 at 06:10:51PM +0800, Xie XiuQi wrote:
>> Memory-failure as the high level machine check handler, it's necessary
>> to report memory page recovery action result to user space by ftrace.
>>
>> This patch add a event at ras group for memory-failure.
>>
>> The output like below:
>> # tracer: nop
>> #
>> # entries-in-buffer/entries-written: 2/2   #P:24
>> #
>> #                              _-----=> irqs-off
>> #                             / _----=> need-resched
>> #                            | / _---=> hardirq/softirq
>> #                            || / _--=> preempt-depth
>> #                            ||| /     delay
>> #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
>> #              | |       |   ||||       |         |
>>       mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: free buddy page recovery: Delayed
>>
>> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
>> ---
>>  include/ras/ras_event.h |   36 ++++++++++++++++++++++++++++++++++++
>>  mm/memory-failure.c     |    3 +++
>>  2 files changed, 39 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
>> index 79abb9c..0a6c8f3 100644
>> --- a/include/ras/ras_event.h
>> +++ b/include/ras/ras_event.h
>> @@ -232,6 +232,42 @@ TRACE_EVENT(aer_event,
>>  		__print_flags(__entry->status, "|", aer_uncorrectable_errors))
>>  );
>>  
>> +/*
>> + * memory-failure recovery action result event
>> + *
>> + * unsigned long pfn -	Page Number of the corrupted page
>> + * char * action -	Recovery action: "free buddy", "free huge", "high
>> + *			order kernel", "free buddy, 2nd try", "different
>> + *			compound page after locking", "hugepage already
>> + *			hardware poisoned", "unmapping failed", "already
>> + *			truncated LRU", etc.
> 
> Listing all possible values here might be prone to become out of date when
> someone try to add/remove/change action_result() call sites.
> So I'd like to have some enumerator to bundle these strings in one place
> in mm/memory-failure.c.
> # I feel like doing this later.

Good, we need this.

> 
>> + * char * result -	Action result: Ignored, Failed, Delayed, Recovered.
> 
> mm/memory-failure.c has good explanation:
> 
>   /*
>    * Error handlers for various types of pages.
>    */
>   enum outcome {
>           IGNORED,        /* Error: cannot be handled */
>           FAILED,         /* Error: handling failed */
>           DELAYED,        /* Will be handled later */
>           RECOVERED,      /* Successfully recovered */
>   };
> 
> So adding a reference to here looks better to me.

Thanks for you comments. I'll change it.

> 
> Thanks,
> Naoya Horiguchi
> 
>> + */
>> +TRACE_EVENT(memory_failure_event,
>> +	TP_PROTO(const unsigned long pfn,
>> +		 const char *action,
>> +		 const char *result),
>> +
>> +	TP_ARGS(pfn, action, result),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(unsigned long, pfn)
>> +		__string(action, action)
>> +		__string(result, result)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->pfn = pfn;
>> +		__assign_str(action, action);
>> +		__assign_str(result, result);
>> +	),
>> +
>> +	TP_printk("pfn %#lx: %s page recovery: %s",
>> +		__entry->pfn,
>> +		__get_str(action),
>> +		__get_str(result)
>> +	)
>> +);
>>  #endif /* _TRACE_HW_EVENT_MC_H */
>>  
>>  /* This part must be outside protection */
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index d487f8d..86a9cce 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -56,6 +56,7 @@
>>  #include <linux/mm_inline.h>
>>  #include <linux/kfifo.h>
>>  #include "internal.h"
>> +#include <ras/ras_event.h>
>>  
>>  int sysctl_memory_failure_early_kill __read_mostly = 0;
>>  
>> @@ -837,6 +838,8 @@ static struct page_state {
>>   */
>>  static void action_result(unsigned long pfn, char *msg, int result)
>>  {
>> +	trace_memory_failure_event(pfn, msg, action_name[result]);
>> +
>>  	pr_err("MCE %#lx: %s page recovery: %s\n",
>>  		pfn, msg, action_name[result]);
>>  }
>> -- 
>> 1.7.1
>>
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
