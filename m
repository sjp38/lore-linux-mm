Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E67DA6B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 05:47:09 -0500 (EST)
Received: by wmec201 with SMTP id c201so75031451wme.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:47:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n19si25065615wjr.18.2015.11.13.02.47.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 02:47:08 -0800 (PST)
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com>
 <20151112092923.19ee53dd@gandalf.local.home>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5645BFAA.1070004@suse.cz>
Date: Fri, 13 Nov 2015 11:47:06 +0100
MIME-Version: 1.0
In-Reply-To: <20151112092923.19ee53dd@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, yalin wang <yalin.wang2010@gmail.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, ebru.akagunduz@gmail.com, riel@redhat.com, kirill.shutemov@linux.intel.com, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/12/2015 03:29 PM, Steven Rostedt wrote:
> On Thu, 12 Nov 2015 16:21:02 +0800
> yalin wang <yalin.wang2010@gmail.com> wrote:
>
>> This crash is caused by NULL pointer deference, in page_to_pfn() marco,
>> when page == NULL :
>>
>> [  182.639154 ] Unable to handle kernel NULL pointer dereference at virtual address 00000000
>
>
>> add the trace point with TP_CONDITION(page),
>
> I wonder if we still want to trace even if page is NULL?

I'd say we want to. There's even a "SCAN_PAGE_NULL" result defined for 
that case, and otherwise we would only have to guess why collapsing 
failed, which is the thing that the tracepoint should help us find out 
in the first place :)

>> avoid trace NULL page.
>>
>> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
>> ---
>>   include/trace/events/huge_memory.h | 20 ++++++++++++--------
>>   mm/huge_memory.c                   |  6 +++---
>>   2 files changed, 15 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
>> index 11c59ca..727647b 100644
>> --- a/include/trace/events/huge_memory.h
>> +++ b/include/trace/events/huge_memory.h
>> @@ -45,12 +45,14 @@ SCAN_STATUS
>>   #define EM(a, b)	{a, b},
>>   #define EMe(a, b)	{a, b}
>>
>> -TRACE_EVENT(mm_khugepaged_scan_pmd,
>> +TRACE_EVENT_CONDITION(mm_khugepaged_scan_pmd,
>>
>> -	TP_PROTO(struct mm_struct *mm, unsigned long pfn, bool writable,
>> +	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
>>   		 bool referenced, int none_or_zero, int status, int unmapped),
>>
>> -	TP_ARGS(mm, pfn, writable, referenced, none_or_zero, status, unmapped),
>> +	TP_ARGS(mm, page, writable, referenced, none_or_zero, status, unmapped),
>> +
>> +	TP_CONDITION(page),
>>
>>   	TP_STRUCT__entry(
>>   		__field(struct mm_struct *, mm)
>> @@ -64,7 +66,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
>>
>>   	TP_fast_assign(
>>   		__entry->mm = mm;
>> -		__entry->pfn = pfn;
>> +		__entry->pfn = page_to_pfn(page);
>
> Instead of the condition, we could have:
>
> 	__entry->pfn = page ? page_to_pfn(page) : -1;

I agree. Please do it like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
