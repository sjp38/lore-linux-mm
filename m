Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 473A9829C4
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 12:37:37 -0400 (EDT)
Received: by wevk48 with SMTP id k48so24477714wev.5
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 09:37:36 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id ib9si3828421wjb.198.2015.03.13.09.37.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 09:37:35 -0700 (PDT)
Received: by wggx12 with SMTP id x12so24401825wgg.13
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 09:37:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1426241451-25729-1-git-send-email-xiexiuqi@huawei.com>
References: <1426241451-25729-1-git-send-email-xiexiuqi@huawei.com>
Date: Fri, 13 Mar 2015 09:37:34 -0700
Message-ID: <CA+8MBbKen9JfQ29AWVZuxO9CkPCmjG670q0Fg7G-qCPDrtDHig@mail.gmail.com>
Subject: Re: [PATCH] tracing: add trace event for memory-failure
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Chen Gong <gong.chen@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Borislav Petkov <bp@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jingle.chen@huawei.com

On Fri, Mar 13, 2015 at 3:10 AM, Xie XiuQi <xiexiuqi@huawei.com> wrote:
> Memory-failure as the high level machine check handler, it's necessary
> to report memory page recovery action result to user space by ftrace.
>
> This patch add a event at ras group for memory-failure.
>
> The output like below:
> # tracer: nop
> #
> # entries-in-buffer/entries-written: 2/2   #P:24
> #
> #                              _-----=> irqs-off
> #                             / _----=> need-resched
> #                            | / _---=> hardirq/softirq
> #                            || / _--=> preempt-depth
> #                            ||| /     delay
> #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
> #              | |       |   ||||       |         |
>       mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: free buddy page recovery: Delayed
>
> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
> ---
>  include/ras/ras_event.h |   36 ++++++++++++++++++++++++++++++++++++
>  mm/memory-failure.c     |    3 +++
>  2 files changed, 39 insertions(+), 0 deletions(-)
>
> diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
> index 79abb9c..0a6c8f3 100644
> --- a/include/ras/ras_event.h
> +++ b/include/ras/ras_event.h
> @@ -232,6 +232,42 @@ TRACE_EVENT(aer_event,
>                 __print_flags(__entry->status, "|", aer_uncorrectable_errors))
>  );
>
> +/*
> + * memory-failure recovery action result event
> + *
> + * unsigned long pfn - Page Number of the corrupted page
> + * char * action -     Recovery action: "free buddy", "free huge", "high
> + *                     order kernel", "free buddy, 2nd try", "different
> + *                     compound page after locking", "hugepage already
> + *                     hardware poisoned", "unmapping failed", "already
> + *                     truncated LRU", etc.
> + * char * result -     Action result: Ignored, Failed, Delayed, Recovered.
> + */
> +TRACE_EVENT(memory_failure_event,
> +       TP_PROTO(const unsigned long pfn,
> +                const char *action,
> +                const char *result),
> +
> +       TP_ARGS(pfn, action, result),
> +
> +       TP_STRUCT__entry(
> +               __field(unsigned long, pfn)
> +               __string(action, action)
> +               __string(result, result)
> +       ),
> +
> +       TP_fast_assign(
> +               __entry->pfn = pfn;
> +               __assign_str(action, action);
> +               __assign_str(result, result);
> +       ),
> +
> +       TP_printk("pfn %#lx: %s page recovery: %s",
> +               __entry->pfn,
> +               __get_str(action),
> +               __get_str(result)
> +       )
> +);
>  #endif /* _TRACE_HW_EVENT_MC_H */
>
>  /* This part must be outside protection */
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d487f8d..86a9cce 100644
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
> @@ -837,6 +838,8 @@ static struct page_state {
>   */
>  static void action_result(unsigned long pfn, char *msg, int result)
>  {
> +       trace_memory_failure_event(pfn, msg, action_name[result]);
> +
>         pr_err("MCE %#lx: %s page recovery: %s\n",
>                 pfn, msg, action_name[result]);
>  }
> --
> 1.7.1
>
> --

Concept looks good to me. Adding Steven Rostedt as we've historically had
challenges adding new trace points in the cleanest way.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
