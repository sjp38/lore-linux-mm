Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 67B446B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 23:22:05 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so61776767pad.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 20:22:05 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.230])
        by mx.google.com with ESMTP id tn7si39874353pac.210.2015.03.18.20.22.03
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 20:22:03 -0700 (PDT)
Date: Wed, 18 Mar 2015 23:22:54 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] tracing: add trace event for memory-failure
Message-ID: <20150318232254.0739d363@grimm.local.home>
In-Reply-To: <1426734270-8146-1-git-send-email-xiexiuqi@huawei.com>
References: <1426734270-8146-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: n-horiguchi@ah.jp.nec.com, gong.chen@linux.intel.com, bhelgaas@google.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

On Thu, 19 Mar 2015 11:04:30 +0800
Xie XiuQi <xiexiuqi@huawei.com> wrote:

> Memory-failure as the high level machine check handler, it's necessary
> to report memory page recovery action result to user space by ftrace.
> 
> This patch add a event at ras group for memory-failure.
> 
> The output like below:
> #  tracer: nop
> # 
> #  entries-in-buffer/entries-written: 2/2   #P:24
> # 
> #                               _-----=> irqs-off
> #                              / _----=> need-resched
> #                             | / _---=> hardirq/softirq
> #                             || / _--=> preempt-depth
> #                             ||| /     delay
> #            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
> #               | |       |   ||||       |         |
>        mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: free buddy page recovery: Delayed
> 
> ---
> v1->v2:
>  - Comment update
>  - Just passing 'result' instead of 'action_name[result]',
>    suggested by Steve. And hard coded there because trace-cmd
>    and perf do not have a way to process enums.
> 

I'll try to fix that issue soon, such that enums will work.

> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
> ---
>  include/ras/ras_event.h | 38 ++++++++++++++++++++++++++++++++++++++
>  mm/memory-failure.c     |  3 +++
>  2 files changed, 41 insertions(+)
> 
> diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
> index 79abb9c..ebb05f3 100644
> --- a/include/ras/ras_event.h
> +++ b/include/ras/ras_event.h
> @@ -232,6 +232,44 @@ TRACE_EVENT(aer_event,
>  		__print_flags(__entry->status, "|", aer_uncorrectable_errors))
>  );
>  
> +/*
> + * memory-failure recovery action result event
> + *
> + * unsigned long pfn -	Page Number of the corrupted page
> + * char * action -	Recovery action for various type of pages
> + * int result	 -	Action result
> + *
> + * NOTE: 'action' and 'result' are defined at mm/memory-failure.c
> + */
> +TRACE_EVENT(memory_failure_event,
> +	TP_PROTO(const unsigned long pfn,
> +		 const char *action,
> +		 const int result),

"const unsigned long" and "const int" is that really needed? These are
passed by value parameters. There's no need to make them const. The
"const char *" is required though.

-- Steve

> +
> +	TP_ARGS(pfn, action, result),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, pfn)
> +		__string(action, action)
> +		__field(int, result)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pfn	= pfn;
> +		__assign_str(action, action);
> +		__entry->result	= result;
> +	),
> +
> +	TP_printk("pfn %#lx: %s page recovery: %s",
> +		__entry->pfn,
> +		__get_str(action),
> +		__print_symbolic(__entry->result,
> +				{0, "Ignored"},
> +				{1, "Failed"},
> +				{2, "Delayed"},
> +				{3, "Recovered"})
> +	)
> +);
>  #endif /* _TRACE_HW_EVENT_MC_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index feb803b..3a71668 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -56,6 +56,7 @@
>  #include <linux/mm_inline.h>
>  #include <linux/kfifo.h>
>  #include "internal.h"
> +#include <ras/ras_event.h>
>  
>  int sysctl_memory_failure_early_kill __read_mostly = 0;
>  
> @@ -844,6 +845,8 @@ static struct page_state {
>   */
>  static void action_result(unsigned long pfn, char *msg, int result)
>  {
> +	trace_memory_failure_event(pfn, msg, result);
> +
>  	pr_err("MCE %#lx: %s page recovery: %s\n",
>  		pfn, msg, action_name[result]);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
