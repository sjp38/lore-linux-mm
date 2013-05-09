Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CBA246B0095
	for <linux-mm@kvack.org>; Thu,  9 May 2013 02:49:38 -0400 (EDT)
Message-ID: <518B464E.6010208@huawei.com>
Date: Thu, 9 May 2013 14:46:38 +0800
From: "zhangwei(Jovi)" <jovi.zhangwei@huawei.com>
MIME-Version: 1.0
Subject: Re: [page fault tracepoint 1/2] Add page fault trace event definitions
References: <1368079520-11015-1-git-send-email-fdeslaur@gmail.com>
In-Reply-To: <1368079520-11015-1-git-send-email-fdeslaur@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Francis Deslauriers <fdeslaur@gmail.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, rostedt@goodmis.org, fweisbec@gmail.com, raphael.beamonte@gmail.com, mathieu.desnoyers@efficios.com, linux-kernel@vger.kernel.org

On 2013/5/9 14:05, Francis Deslauriers wrote:
> Add page_fault_entry and page_fault_exit event definitions. It will
> allow each architecture to instrument their page faults.

I'm wondering if this tracepoint could handle other page faults,
like faults in kernel memory(vmalloc, kmmio, etc...)

And if we decide to support those faults, add a type annotate in TP_printk
would be much helpful for user, to let user know what type of page faults happened.

Thanks.
> 
> Signed-off-by: Francis Deslauriers <fdeslaur@gmail.com>
> Reviewed-by: RaphaA<<l Beamonte <raphael.beamonte@gmail.com>
> Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
> ---
>  include/trace/events/fault.h |   51 ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 51 insertions(+)
>  create mode 100644 include/trace/events/fault.h
> 
> diff --git a/include/trace/events/fault.h b/include/trace/events/fault.h
> new file mode 100644
> index 0000000..522ddee
> --- /dev/null
> +++ b/include/trace/events/fault.h
> @@ -0,0 +1,51 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM fault
> +
> +#if !defined(_TRACE_FAULT_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_FAULT_H
> +
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(page_fault_entry,
> +
> +	TP_PROTO(struct pt_regs *regs, unsigned long address,
> +					int write_access),
> +
> +	TP_ARGS(regs, address, write_access),
> +
> +	TP_STRUCT__entry(
> +		__field(	unsigned long,	ip	)
> +		__field(	unsigned long,	addr	)
> +		__field(	uint8_t,	write	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->ip	= regs ? instruction_pointer(regs) : 0UL;
> +		__entry->addr	= address;
> +		__entry->write	= !!write_access;
> +	),
> +
> +	TP_printk("ip=%lu addr=%lu write_access=%d",
> +		__entry->ip, __entry->addr, __entry->write)
> +);
> +
> +TRACE_EVENT(page_fault_exit,
> +
> +	TP_PROTO(int result),
> +
> +	TP_ARGS(result),
> +
> +	TP_STRUCT__entry(
> +		__field(	int,	res	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->res	= result;
> +	),
> +
> +	TP_printk("result=%d", __entry->res)
> +);
> +
> +#endif /* _TRACE_FAULT_H */
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
