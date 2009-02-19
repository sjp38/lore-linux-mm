Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB65C6B003D
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 23:42:25 -0500 (EST)
Message-ID: <499CE2FE.90503@bk.jp.nec.com>
Date: Thu, 19 Feb 2009 13:41:34 +0900
From: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
References: <1234863220.4744.34.camel@laptop> <499A99BC.2080700@bk.jp.nec.com> <20090217201651.576E.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090217201651.576E.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, rostedt@goodmis.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi Kosaki-san,

Thank you for your comment.

KOSAKI Motohiro wrote:
> Hi
> 
> 
> In my 1st impression, this patch description is a bit strange.
> 
>> The below patch adds instrumentation for pagecache.
>>
>> I thought it would be useful to trace pagecache behavior for problem
>> analysis (performance bottlenecks, behavior differences between stable
>> time and trouble time).
>>
>> By using those tracepoints, we can describe and visualize pagecache
>> transition (file-by-file basis) in kernel and  pagecache
>> consumes most of the memory in running system and pagecache hit rate
>> and writeback behavior will influence system load and performance.
> 
> Why do you think this tracepoint describe pagecache hit rate?
> and, why describe writeback behavior?

I mean, we can describe file-by-file basis pagecache usage by using 
these tracepoints and it is important for analyzing process I/O behavior. 
Currently, we can understand the amount of pagecache from "Cached"
in /proc/meminfo. So I'd like to understand which files are using pagecache. 

> 
>> I attached an example which is visualization of pagecache status using
>> SystemTap. 
> 
> it seems no attached. and SystemTap isn't used kernel developer at all.
> I don't think it's enough explanation.
> Can you make seekwatcher liked completed comsumer program?
> (if you don't know seekwatcher, see http://oss.oracle.com/~mason/seekwatcher/)

I understand a tracer using these tracepoints need to be implemented.
What I want to do is counting pagecache per file. We can retrieve inode
from mapping and count pagecache per inode in these tracepoints.

>> That graph describes pagecache transition of File A and File B
>> on a file-by-file basis with the situation where regular I/O to File A
>> is delayed because of other I/O to File B. 
> 
> If you want to see I/O activity, you need to add tracepoint into block layer.

I think tracking pagecache is useful for understanding process I/O activity,
because whether process I/O completes by accessing memory or HDD is determined by
accessed files on pagecache or not.

> 
>> We visually understand
>> pagecache for File A is narrowed down due to I/O pressure from File B.
> 
> confused. Can we assume the number of anon pages/files pages ratio don't chage?
> 
> 
>> Peter Zijlstra wrote:
>>> On Tue, 2009-02-17 at 18:00 +0900, Atsushi Tsuji wrote:
>>>
>>>> The below patch adds instrumentation for pagecache.
>>> And somehow you forgot to CC any of the mm people.. ;-)
>> Hi Peter,
>>
>> Ah, sorry.
>> Thank you for adding to CC list.
>>
>>>> +DECLARE_TRACE(filemap_add_to_page_cache,
>>>> +	TPPROTO(struct address_space *mapping, pgoff_t offset),
>>>> +	TPARGS(mapping, offset));
>>>> +DECLARE_TRACE(filemap_remove_from_page_cache,
>>>> +	TPPROTO(struct address_space *mapping),
>>>> +	TPARGS(mapping));
>>> This is rather asymmetric, why don't we care about the offset for the
>>> removed page?
>>>
>> Indeed.
>> I added the offset to the argument for the removed page and resend fixed patch.
>>
>> Signed-off-by: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
>> ---
>> diff --git a/include/trace/filemap.h b/include/trace/filemap.h
> 
> please add diffstat.
> 
> 
>> new file mode 100644
>> index 0000000..a17dc92
>> --- /dev/null
>> +++ b/include/trace/filemap.h
>> @@ -0,0 +1,13 @@
>> +#ifndef _TRACE_FILEMAP_H
>> +#define _TRACE_FILEMAP_H
>> +
>> +#include <linux/tracepoint.h>
>> +
>> +DECLARE_TRACE(filemap_add_to_page_cache,
>> +	TPPROTO(struct address_space *mapping, pgoff_t offset),
>> +	TPARGS(mapping, offset));
>> +DECLARE_TRACE(filemap_remove_from_page_cache,
>> +	TPPROTO(struct address_space *mapping, pgoff_t offset),
>> +	TPARGS(mapping, offset));
>> +
>> +#endif
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index 23acefe..23f75d2 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -34,6 +34,7 @@
>>  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
>>  #include <linux/memcontrol.h>
>>  #include <linux/mm_inline.h> /* for page_is_file_cache() */
>> +#include <trace/filemap.h>
>>  #include "internal.h"
>>  
>>  /*
>> @@ -43,6 +44,8 @@
>>  
>>  #include <asm/mman.h>
>>  
>> +DEFINE_TRACE(filemap_add_to_page_cache);
>> +DEFINE_TRACE(filemap_remove_from_page_cache);
>>  
>>  /*
>>   * Shared mappings implemented 30.11.1994. It's not fully working yet,
>> @@ -120,6 +123,7 @@ void __remove_from_page_cache(struct page *page)
>>  	page->mapping = NULL;
>>  	mapping->nrpages--;
>>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>> +	trace_filemap_remove_from_page_cache(mapping, page->index);
> 
> __remove_from_page_cache() is passed struct page.
> Why don't you use struct page
> 
> and, this mean
>   - the page have been removed from mapping.
>   - vmstate have been decremented.
>   - but, the page haven't been uncharged from memcg.
> 
> Why?
> 
> 
>>  	BUG_ON(page_mapped(page));
>>  	mem_cgroup_uncharge_cache_page(page);
>>  
>> @@ -475,6 +479,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
>>  		if (likely(!error)) {
>>  			mapping->nrpages++;
>>  			__inc_zone_page_state(page, NR_FILE_PAGES);
>> +			trace_filemap_add_to_page_cache(mapping, offset);
> 
> Why do you select this line?
> In general, trace point calling under spin lock grabbing is a bit problematic.
 
I understand my patch is wrong. I will fix and send it later.

> 
>>  		} else {
>>  			page->mapping = NULL;
>>  			mem_cgroup_uncharge_cache_page(page);
>>
> 
> And, both function is freqentlly called one.
> I worry about performance issue. can you prove no degression?

I will try to probe that.

Thanks,
-Atsushi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
