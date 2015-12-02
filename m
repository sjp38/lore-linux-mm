Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 175A86B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 19:07:47 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so21566041pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 16:07:46 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id b14si451093pfj.132.2015.12.01.16.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 16:07:46 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so20847052pac.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 16:07:46 -0800 (PST)
Message-ID: <565E3650.4050209@linaro.org>
Date: Tue, 01 Dec 2015 16:07:44 -0800
From: "Shi, Yang" <yang.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] trace/events: Add gup trace events
References: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>	<1449011177-30686-2-git-send-email-yang.shi@linaro.org> <20151201185643.2ef6cd14@gandalf.local.home>
In-Reply-To: <20151201185643.2ef6cd14@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 12/1/2015 3:56 PM, Steven Rostedt wrote:
> On Tue,  1 Dec 2015 15:06:11 -0800
> Yang Shi <yang.shi@linaro.org> wrote:
>
>> page-faults events record the invoke to handle_mm_fault, but the invoke
>> may come from do_page_fault or gup. In some use cases, the finer event count
>> mey be needed, so add trace events support for:
>>
>> __get_user_pages
>> __get_user_pages_fast
>> fixup_user_fault
>>
>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> ---
>>   include/trace/events/gup.h | 77 ++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 77 insertions(+)
>>   create mode 100644 include/trace/events/gup.h
>>
>> diff --git a/include/trace/events/gup.h b/include/trace/events/gup.h
>> new file mode 100644
>> index 0000000..37d18f9
>> --- /dev/null
>> +++ b/include/trace/events/gup.h
>> @@ -0,0 +1,77 @@
>> +#undef TRACE_SYSTEM
>> +#define TRACE_SYSTEM gup
>> +
>> +#if !defined(_TRACE_GUP_H) || defined(TRACE_HEADER_MULTI_READ)
>> +#define _TRACE_GUP_H
>> +
>> +#include <linux/types.h>
>> +#include <linux/tracepoint.h>
>> +
>> +TRACE_EVENT(gup_fixup_user_fault,
>> +
>> +	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
>> +			unsigned long address, unsigned int fault_flags),
>> +
>> +	TP_ARGS(tsk, mm, address, fault_flags),
>> +
>> +	TP_STRUCT__entry(
>> +		__array(	char,	comm,	TASK_COMM_LEN	)
>
> Why save the comm? The tracing infrastructure should keep track of that.

The code is referred to kmem.h which has comm copied. If it is 
unnecessary, it definitely could be removed.

>
>> +		__field(	unsigned long,	address		)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		memcpy(__entry->comm, tsk->comm, TASK_COMM_LEN);
>> +		__entry->address	= address;
>> +	),
>> +
>> +	TP_printk("comm=%s address=%lx", __entry->comm, __entry->address)
>> +);
>> +
>> +TRACE_EVENT(gup_get_user_pages,
>> +
>> +	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
>> +			unsigned long start, unsigned long nr_pages,
>> +			unsigned int gup_flags, struct page **pages,
>> +			struct vm_area_struct **vmas, int *nonblocking),
>> +
>> +	TP_ARGS(tsk, mm, start, nr_pages, gup_flags, pages, vmas, nonblocking),
>
> Why so many arguments? Most are not used.

My understanding to TP_ARGS may be not right. Doesn't it require all the 
args defined by the function? If not, it could definitely be shrunk. 
Just need keep the args used by TP_printk?

Thanks,
Yang

>
> -- Steve
>
>> +
>> +	TP_STRUCT__entry(
>> +		__array(	char,	comm,	TASK_COMM_LEN	)
>> +		__field(	unsigned long,	start		)
>> +		__field(	unsigned long,	nr_pages	)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		memcpy(__entry->comm, tsk->comm, TASK_COMM_LEN);
>> +		__entry->start		= start;
>> +		__entry->nr_pages	= nr_pages;
>> +	),
>> +
>> +	TP_printk("comm=%s start=%lx nr_pages=%lu", __entry->comm, __entry->start, __entry->nr_pages)
>> +);
>> +
>> +TRACE_EVENT(gup_get_user_pages_fast,
>> +
>> +	TP_PROTO(unsigned long start, int nr_pages, int write,
>> +			struct page **pages),
>> +
>> +	TP_ARGS(start, nr_pages, write, pages),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	unsigned long,	start		)
>> +		__field(	unsigned long,	nr_pages	)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->start  	= start;
>> +		__entry->nr_pages	= nr_pages;
>> +	),
>> +
>> +	TP_printk("start=%lx nr_pages=%lu",  __entry->start, __entry->nr_pages)
>> +);
>> +
>> +#endif /* _TRACE_GUP_H */
>> +
>> +/* This part must be outside protection */
>> +#include <trace/define_trace.h>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
