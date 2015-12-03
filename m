Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 54CC66B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 23:08:02 -0500 (EST)
Received: by igcto18 with SMTP id to18so3630294igc.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 20:08:02 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.228])
        by mx.google.com with ESMTP id u29si10303438ioi.124.2015.12.02.20.08.01
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 20:08:01 -0800 (PST)
Date: Wed, 2 Dec 2015 23:07:58 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V2 1/7] trace/events: Add gup trace events
Message-ID: <20151202230758.0411d8c9@grimm.local.home>
In-Reply-To: <1449096813-22436-2-git-send-email-yang.shi@linaro.org>
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
	<1449096813-22436-2-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Wed,  2 Dec 2015 14:53:27 -0800
Yang Shi <yang.shi@linaro.org> wrote:

> page-faults events record the invoke to handle_mm_fault, but the invoke
> may come from do_page_fault or gup. In some use cases, the finer event count
> mey be needed, so add trace events support for:
> 
> __get_user_pages
> __get_user_pages_fast
> fixup_user_fault
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>  include/trace/events/gup.h | 71 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 71 insertions(+)
>  create mode 100644 include/trace/events/gup.h
> 
> diff --git a/include/trace/events/gup.h b/include/trace/events/gup.h
> new file mode 100644
> index 0000000..03a4674
> --- /dev/null
> +++ b/include/trace/events/gup.h
> @@ -0,0 +1,71 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM gup
> +
> +#if !defined(_TRACE_GUP_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_GUP_H
> +
> +#include <linux/types.h>
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(gup_fixup_user_fault,
> +
> +	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
> +			unsigned long address, unsigned int fault_flags),
> +
> +	TP_ARGS(tsk, mm, address, fault_flags),

Arges added and not used by TP_fast_assign(), this will slow down the
code while tracing is enabled, as they need to be added to the trace
function call.

> +
> +	TP_STRUCT__entry(
> +		__field(	unsigned long,	address		)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->address	= address;
> +	),
> +
> +	TP_printk("address=%lx",  __entry->address)
> +);
> +
> +TRACE_EVENT(gup_get_user_pages,
> +
> +	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
> +			unsigned long start, unsigned long nr_pages),
> +
> +	TP_ARGS(tsk, mm, start, nr_pages),

Here too but this is worse. See below.

> +
> +	TP_STRUCT__entry(
> +		__field(	unsigned long,	start		)
> +		__field(	unsigned long,	nr_pages	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->start		= start;
> +		__entry->nr_pages	= nr_pages;
> +	),
> +
> +	TP_printk("start=%lx nr_pages=%lu", __entry->start, __entry->nr_pages)
> +);
> +
> +TRACE_EVENT(gup_get_user_pages_fast,
> +
> +	TP_PROTO(unsigned long start, int nr_pages, int write,
> +			struct page **pages),
> +
> +	TP_ARGS(start, nr_pages, write, pages),

This and the above "gup_get_user_pages" have the same entry field,
assign and printk. They should be combined into a DECLARE_EVENT_CLASS()
and two DEFINE_EVENT()s. That will save on size as the
DECLARE_EVENT_CLASS() is the biggest part of each TRACE_EVENT().

-- Steve


> +
> +	TP_STRUCT__entry(
> +		__field(	unsigned long,	start		)
> +		__field(	unsigned long,	nr_pages	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->start  	= start;
> +		__entry->nr_pages	= nr_pages;
> +	),
> +
> +	TP_printk("start=%lx nr_pages=%lu",  __entry->start, __entry->nr_pages)
> +);
> +
> +#endif /* _TRACE_GUP_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
