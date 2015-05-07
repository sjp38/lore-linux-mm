Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 97D606B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 02:04:43 -0400 (EDT)
Received: by ieczm2 with SMTP id zm2so31705114iec.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:04:43 -0700 (PDT)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id vf3si1661526igb.60.2015.05.06.23.04.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 May 2015 23:04:43 -0700 (PDT)
Message-ID: <554AFFC9.2040904@huawei.com>
Date: Thu, 7 May 2015 14:01:45 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3/3] tracing: add trace event for memory-failure
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>	<1429519480-11687-4-git-send-email-xiexiuqi@huawei.com> <20150506222551.56108f53@grimm.local.home>
In-Reply-To: <20150506222551.56108f53@grimm.local.home>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: n-horiguchi@ah.jp.nec.com, mingo@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, koct9i@gmail.com, hpa@linux.intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@amacapital.net, nasa4836@gmail.com, gong.chen@linux.intel.com, bhelgaas@google.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

On 2015/5/7 10:25, Steven Rostedt wrote:
> On Mon, 20 Apr 2015 16:44:40 +0800
> Xie XiuQi <xiexiuqi@huawei.com> wrote:
> 

...

>> + *
>> + * unsigned long pfn -	Page Frame Number of the corrupted page
>> + * int type	-	Page types of the corrupted page
>> + * int result	-	Result of recovery action
>> + */
>> +
>> +#ifdef CONFIG_MEMORY_FAILURE
>> +#define MF_ACTION_RESULT	\
>> +	EM ( MF_IGNORED, "Ignord" )	\
> 
>  "Ignored" ?

My fault, I'll correct it, thanks.

> 
>> +	EM ( MF_FAILED,  "Failed" )	\
>> +	EM ( MF_DELAYED, "Delayed" )	\
>> +	EMe ( MF_RECOVERED, "Recovered" )
>> +
>> +#define MF_PAGE_TYPE		\
>> +	EM ( MF_MSG_KERNEL, "reserved kernel page" )			\
>> +	EM ( MF_MSG_KERNEL_HIGH_ORDER, "high-order kernel page" )	\
...
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->pfn	= pfn;
>> +		__entry->type	= type;
>> +		__entry->result	= result;
>> +	),
>> +
>> +	TP_printk("pfn %#lx: recovery action for %s: %s",
> 
> Hmm, "%#" is new to me. I'm not sure libtraceevent handles that.
> 
> Not your problem, I need to make sure that it does, and if it does not,
> I need to fix it.
> 
> I'm not even sure what %# does.
> 
> Other than the typo,
> 
> Acked-by: Steven Rostedt <rostedt@goodmis.org>

Thanks,
	Xie XiuQi

> 
> -- Steve
> 
> 
>> +		__entry->pfn,
>> +		__print_symbolic(__entry->type, MF_PAGE_TYPE),
>> +		__print_symbolic(__entry->result, MF_ACTION_RESULT)
>> +	)
>> +);
>> +#endif /* CONFIG_MEMORY_FAILURE */
>>  #endif /* _TRACE_HW_EVENT_MC_H */
>>  
>>  /* This part must be outside protection */
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index f074f8e..42c5981 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -56,6 +56,7 @@
>>  #include <linux/mm_inline.h>
>>  #include <linux/kfifo.h>
>>  #include "internal.h"
>> +#include "ras/ras_event.h"
>>  
>>  int sysctl_memory_failure_early_kill __read_mostly = 0;
>>  
>> @@ -850,6 +851,8 @@ static struct page_state {
>>  static void action_result(unsigned long pfn, enum mf_action_page_type type,
>>  			  enum mf_result result)
>>  {
>> +	trace_memory_failure_event(pfn, type, result);
>> +
>>  	pr_err("MCE %#lx: recovery action for %s: %s\n",
>>  		pfn, action_page_types[type], action_name[result]);
>>  }
> 
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
