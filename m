Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CA05B6B0254
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 05:16:26 -0500 (EST)
Received: by wmec201 with SMTP id c201so112257203wme.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 02:16:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si27536867wjy.59.2015.11.16.02.16.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Nov 2015 02:16:25 -0800 (PST)
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com>
 <20151112092923.19ee53dd@gandalf.local.home> <5645BFAA.1070004@suse.cz>
 <D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com>
 <20151113090115.1ad4235b@gandalf.local.home>
 <2F74FF6B-66DC-4BF9-972A-C2F5FFFA979F@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5649ACF6.1000704@suse.cz>
Date: Mon, 16 Nov 2015 11:16:22 +0100
MIME-Version: 1.0
In-Reply-To: <2F74FF6B-66DC-4BF9-972A-C2F5FFFA979F@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 11/16/2015 02:35 AM, yalin wang wrote:
>
>> On Nov 13, 2015, at 22:01, Steven Rostedt <rostedt@goodmis.org> wrote:
>>
>> On Fri, 13 Nov 2015 19:54:11 +0800
>> yalin wang <yalin.wang2010@gmail.com> wrote:
>>
>>>>>> 	TP_fast_assign(
>>>>>> 		__entry->mm = mm;
>>>>>> -		__entry->pfn = pfn;
>>>>>> +		__entry->pfn = page_to_pfn(page);
>>>>>
>>>>> Instead of the condition, we could have:
>>>>>
>>>>> 	__entry->pfn = page ? page_to_pfn(page) : -1;
>>>>
>>>> I agree. Please do it like this.
>>
>> hmm, pfn is defined as an unsigned long, would -1 be the best.
>> Or should it be (-1UL).
>>
>> Then we could also have:
>>
>>         TP_printk("mm=%p, scan_pfn=0x%lx%s, writable=%d, referenced=%d, none_or_zero=%d, status=%s, unmapped=%d",
>>                 __entry->mm,
>>                 __entry->pfn == (-1UL) ? 0 : __entry->pfn,
>> 		__entry->pfn == (-1UL) ? "(null)" : "",
>>
>> Note the added %s after %lx I have in the print format.
>>
>> -- Steve
> it is not easy to print for perf tools in userspace ,
> if you use this format ,
> for user space perf tool, it print the entry by look up the member in entry struct by offset ,
> you print a dynamic string which user space perf tool dona??t know how to print this string .

Does it work through trace-cmd?

> Thanks
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
