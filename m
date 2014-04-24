Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0DE26B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:42:23 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fb1so1691392pad.10
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:42:23 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id iw1si3375058pbb.24.2014.04.24.13.42.20
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 13:42:20 -0700 (PDT)
Message-ID: <5359772A.8070108@sr71.net>
Date: Thu, 24 Apr 2014 13:42:18 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] x86: mm: trace tlb flushes
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182425.93E696A3@viggo.jf.intel.com> <20140424101419.GS23991@suse.de>
In-Reply-To: <20140424101419.GS23991@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On 04/24/2014 03:14 AM, Mel Gorman wrote:
> On Mon, Apr 21, 2014 at 11:24:25AM -0700, Dave Hansen wrote:
>> @@ -105,9 +108,10 @@ static void flush_tlb_func(void *info)
>>  
>>  	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
>>  	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
>> -		if (f->flush_end == TLB_FLUSH_ALL)
>> +		if (f->flush_end == TLB_FLUSH_ALL) {
>>  			local_flush_tlb();
>> -		else if (!f->flush_end)
>> +			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
>> +		} else if (!f->flush_end)
>>  			__flush_tlb_single(f->flush_start);
>>  		else {
>>  			unsigned long addr;
> 
> Why is only the TLB_FLUSH_ALL case traced here and not the single flush
> or range of flushes? __native_flush_tlb_single() doesn't have a trace
> point so I worry we are missing visibility on this part in particular
> this part.
> 
>                         while (addr < f->flush_end) {
>                                 __flush_tlb_single(addr);
>                                 addr += PAGE_SIZE;
>                         }

You're right, I missed that bit.  I've corrected in a later version of
the patch.

>> @@ -152,7 +156,9 @@ void flush_tlb_current_task(void)
>>  	preempt_disable();
>>  
>>  	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
>> +	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>>  	local_flush_tlb();
>> +	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN_DONE, TLB_FLUSH_ALL);
>>  	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
>>  		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
>>  	preempt_enable();
> 
> Are the two tracepoints really useful? Are they fine enough to measure
> the cost of the TLB flush? It misses the refill obviously but not much
> we can do there.

It's fine enough, but I did realize over time that the cost of the
tracepoint is about 3x the cost of a 1-page tlb flush itself, so these
are unusable for detailed measurements.  I'll remove it for now.

>>  #endif /* _LINUX_MM_TYPES_H */
>> diff -puN /dev/null include/trace/events/tlb.h
>> --- /dev/null	2014-04-10 11:28:14.066815724 -0700
>> +++ b/include/trace/events/tlb.h	2014-04-21 11:10:35.529868198 -0700
>> @@ -0,0 +1,37 @@
>> +#undef TRACE_SYSTEM
>> +#define TRACE_SYSTEM tlb
>> +
>> +#if !defined(_TRACE_TLB_H) || defined(TRACE_HEADER_MULTI_READ)
>> +#define _TRACE_TLB_H
>> +
>> +#include <linux/mm_types.h>
>> +#include <linux/tracepoint.h>
>> +
>> +extern const char * const tlb_flush_reason_desc[];
>> +
>> +TRACE_EVENT(tlb_flush,
>> +
>> +	TP_PROTO(int reason, unsigned long pages),
>> +	TP_ARGS(reason, pages),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	  int, reason)
>> +		__field(unsigned long,  pages)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->reason = reason;
>> +		__entry->pages  = pages;
>> +	),
>> +
>> +	TP_printk("pages: %ld reason: %d (%s)",
>> +		__entry->pages,
>> +		__entry->reason,
>> +		tlb_flush_reason_desc[__entry->reason])
>> +);
>> +
> 
> I would also suggest you match the output formatting with writeback.h
> which would look like
> 
> pages:%lu reason:%s
> 
> The raw format should still have the integer while the string formatting
> would have something human readable.

I can do that.  The only bummer with the human-readable strings is
turning them back in to something that the filters can take.  I think
I'll just do:

+       TP_printk("pages:%ld reason:%s (%d)",
+               __entry->pages,
+               __print_symbolic(__entry->reason, TLB_FLUSH_REASON),
+               __entry->reason)
+);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
