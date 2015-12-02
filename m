Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC586B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 19:18:29 -0500 (EST)
Received: by ioc74 with SMTP id 74so28463147ioc.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 16:18:29 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0094.hostedemail.com. [216.40.44.94])
        by mx.google.com with ESMTPS id t10si1318545igr.54.2015.12.01.16.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 16:18:29 -0800 (PST)
Date: Tue, 1 Dec 2015 19:18:26 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/7] trace/events: Add gup trace events
Message-ID: <20151201191826.771bce5d@gandalf.local.home>
In-Reply-To: <565E3650.4050209@linaro.org>
References: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
	<1449011177-30686-2-git-send-email-yang.shi@linaro.org>
	<20151201185643.2ef6cd14@gandalf.local.home>
	<565E3650.4050209@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Tue, 01 Dec 2015 16:07:44 -0800
"Shi, Yang" <yang.shi@linaro.org> wrote:

> On 12/1/2015 3:56 PM, Steven Rostedt wrote:
> > On Tue,  1 Dec 2015 15:06:11 -0800
> > Yang Shi <yang.shi@linaro.org> wrote:
> >  
> >> page-faults events record the invoke to handle_mm_fault, but the invoke
> >> may come from do_page_fault or gup. In some use cases, the finer event count
> >> mey be needed, so add trace events support for:
> >>
> >> __get_user_pages
> >> __get_user_pages_fast
> >> fixup_user_fault
> >>
> >> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> >> ---
> >>   include/trace/events/gup.h | 77 ++++++++++++++++++++++++++++++++++++++++++++++
> >>   1 file changed, 77 insertions(+)
> >>   create mode 100644 include/trace/events/gup.h
> >>
> >> diff --git a/include/trace/events/gup.h b/include/trace/events/gup.h
> >> new file mode 100644
> >> index 0000000..37d18f9
> >> --- /dev/null
> >> +++ b/include/trace/events/gup.h
> >> @@ -0,0 +1,77 @@
> >> +#undef TRACE_SYSTEM
> >> +#define TRACE_SYSTEM gup
> >> +
> >> +#if !defined(_TRACE_GUP_H) || defined(TRACE_HEADER_MULTI_READ)
> >> +#define _TRACE_GUP_H
> >> +
> >> +#include <linux/types.h>
> >> +#include <linux/tracepoint.h>
> >> +
> >> +TRACE_EVENT(gup_fixup_user_fault,
> >> +
> >> +	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
> >> +			unsigned long address, unsigned int fault_flags),
> >> +
> >> +	TP_ARGS(tsk, mm, address, fault_flags),
> >> +
> >> +	TP_STRUCT__entry(
> >> +		__array(	char,	comm,	TASK_COMM_LEN	)  
> >
> > Why save the comm? The tracing infrastructure should keep track of that.  
> 
> The code is referred to kmem.h which has comm copied. If it is 
> unnecessary, it definitely could be removed.

Sometimes comm isn't that reliable. But really, the only tracepoint
that should record it is sched_switch, and sched_wakeup. With those
two, the rest of the trace points should be fine.

> 
> >  
> >> +		__field(	unsigned long,	address		)
> >> +	),
> >> +
> >> +	TP_fast_assign(
> >> +		memcpy(__entry->comm, tsk->comm, TASK_COMM_LEN);
> >> +		__entry->address	= address;
> >> +	),
> >> +
> >> +	TP_printk("comm=%s address=%lx", __entry->comm, __entry->address)
> >> +);
> >> +
> >> +TRACE_EVENT(gup_get_user_pages,
> >> +
> >> +	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
> >> +			unsigned long start, unsigned long nr_pages,
> >> +			unsigned int gup_flags, struct page **pages,
> >> +			struct vm_area_struct **vmas, int *nonblocking),
> >> +
> >> +	TP_ARGS(tsk, mm, start, nr_pages, gup_flags, pages, vmas, nonblocking),  
> >
> > Why so many arguments? Most are not used.  
> 
> My understanding to TP_ARGS may be not right. Doesn't it require all the 
> args defined by the function? If not, it could definitely be shrunk. 
> Just need keep the args used by TP_printk?

It only needs what is used by TP_fast_assign().

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
