Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 92AD36B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 02:43:44 -0500 (EST)
Received: by wmec201 with SMTP id c201so213251752wme.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 23:43:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y10si44414603wjw.208.2015.11.16.23.43.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 23:43:43 -0800 (PST)
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com>
 <20151112092923.19ee53dd@gandalf.local.home> <5645BFAA.1070004@suse.cz>
 <D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com>
 <20151113090115.1ad4235b@gandalf.local.home>
 <2F74FF6B-66DC-4BF9-972A-C2F5FFFA979F@gmail.com> <5649ACF6.1000704@suse.cz>
 <20151116092501.761f31d7@gandalf.local.home>
 <233209B0-A466-4149-93C6-7173FF0FD4C5@gmail.com>
 <20151116214304.6fa42a4e@grimm.local.home>
 <8582F660-B54A-474B-960E-CD5D0FF6428F@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564ADAB1.9030500@suse.cz>
Date: Tue, 17 Nov 2015 08:43:45 +0100
MIME-Version: 1.0
In-Reply-To: <8582F660-B54A-474B-960E-CD5D0FF6428F@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 17.11.2015 4:58, yalin wang wrote:
> 
>> On Nov 17, 2015, at 10:43, Steven Rostedt <rostedt@goodmis.org> wrote:
>>
>> On Tue, 17 Nov 2015 10:21:47 +0800
>> yalin wang <yalin.wang2010@gmail.com> wrote:
>>
>>
>>
>> Because the print_fmt has nothing to do with the fields. You can have
>> as your print_fmt as:
>>
>> 	TP_printk("Message = %s", "hello dolly!")
>>
>> And both userspace and the kernel with process that correctly (if I got
>> string processing working in userspace, which I believe I do). The
>> string is processed, it's not dependent on TP_STRUCT__entry() unless it
>> references a field there. Which can also be used too:
>>
>> 	TP_printk("Message = %s", __entry->musical ? "Hello dolly!" :
>> 			"Death Trap!")
>>
>> userspace will see in the entry:
>>
>> print_fmt: "Message = %s", REC->musical ? "Hello dolly!" : "Death Trap!"
>>
>> as long as the field "musical" exists, all is well.
>>
>> -- Steve
> Aha,  i see.
> Thanks very much for your explanation.
> Better print fat is :   
> TP_printk("mm=%p, scan_pfn=%s, writable=%d, referenced=%d, none_or_zero=%d, status=%s, unmapped=%d",
>                __entry->mm,
> 		__entry->pfn == (-1UL) ? "(null)" :  itoa(buff,  __entry->pin, 10), a?|..)
> 
> is this possible ?

I doubt so.

Why don't we just do (with %lx):
 __entry->pfn != -1UL ? __entry->pfn : 0,

Status already tells us that it's not a real pfn 0 (which I doubt would be
userspace-mapped and thus reachable by khugepaged anyway?).
Also it's what some other tracepoints do, see e.g. mm_page class in
include/trace/events/kmem.h.

> Thanks
> 
> 
> 
> 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
