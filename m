Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1543E82F82
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 05:03:37 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id c201so24672759wme.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 02:03:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wz10si17791064wjc.58.2015.12.10.02.03.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 02:03:35 -0800 (PST)
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
 <1449242195-16374-1-git-send-email-vbabka@suse.cz>
 <20151210025944.GB17967@js1304-P5Q-DELUXE>
 <20151210040456.GC7814@home.goodmis.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56694DF6.70600@suse.cz>
Date: Thu, 10 Dec 2015 11:03:34 +0100
MIME-Version: 1.0
In-Reply-To: <20151210040456.GC7814@home.goodmis.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On 12/10/2015 05:04 AM, Steven Rostedt wrote:
> On Thu, Dec 10, 2015 at 11:59:44AM +0900, Joonsoo Kim wrote:
>> Ccing, Steven to ask trace-cmd problem.
>>
>> I'd like to use %pgp in tracepoint output. It works well when I do
>> 'cat /sys/kernel/debug/tracing/trace' but not works well when I do
>> './trace-cmd report'. It prints following error log.
>>
>>    [page_ref:page_ref_unfreeze] bad op token &
>>    [page_ref:page_ref_set] bad op token &
>>    [page_ref:page_ref_mod_unless] bad op token &
>>    [page_ref:page_ref_mod_and_test] bad op token &
>>    [page_ref:page_ref_mod_and_return] bad op token &
>>    [page_ref:page_ref_mod] bad op token &
>>    [page_ref:page_ref_freeze] bad op token &
>>
>> Following is the format I used.
>>
>> TP_printk("pfn=0x%lx flags=%pgp count=%d mapcount=%d mapping=%p mt=%d val=%d ret=%d",
>>                  __entry->pfn, &__entry->flags, __entry->count,
>>                  __entry->mapcount, __entry->mapping, __entry->mt,
>>                  __entry->val, __entry->ret)
>>
>> Could it be solved by 'trace-cmd' itself?

You mean that trace-cmd/parse-events.c would interpret the raw value of 
flags by itself? That would mean the flags became fixed ABI, not a good 
idea...

>> Or it's better to pass flags by value?

If it's value (as opposed to a pointer in %pgp), that doesn't change 
much wrt. having to intepret them?

>> Or should I use something like show_gfp_flags()?

Sounds like least pain to me, at least for now. We just need to have the 
translation tables available as #define with __print_flags() in some 
trace/events header, like the existing trace/events/gfpflags.h for gfp 
flags. These tables can still be reused within mm/debug.c or printk code 
without copy/paste, like I did in "[PATCH v2 6/9] mm, debug: introduce 
dump_gfpflag_names() for symbolic printing of gfp_flags" [1]. Maybe it's 
not the most elegant solution, but works without changing parse-events.c 
using the existing format export.

So if you agree, I can do this in the next spin.

[1] https://lkml.org/lkml/2015/11/24/354

> Yes this can be solved in perf and trace-cmd via the parse-events.c file. And
> as soon as that happens, whatever method we decide upon becomes a userspace
> ABI. So don't think you can change it later.
>
> -- Steve
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
