Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E41FD6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 10:31:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a47so1205582wra.0
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 07:31:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8si6367844wro.444.2017.08.31.07.31.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Aug 2017 07:31:38 -0700 (PDT)
Subject: Re: [PATCH 1/5] tracing, mm: Record pfn instead of pointer to struct
 page
References: <1428963302-31538-1-git-send-email-acme@kernel.org>
 <1428963302-31538-2-git-send-email-acme@kernel.org>
 <897eb045-d63c-b9e3-c6e7-0f6b94536c0f@suse.cz>
 <20170831094306.0fb655a5@gandalf.local.home>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ea9f2ead-e69a-ff6a-debd-73f8e52cc620@suse.cz>
Date: Thu, 31 Aug 2017 16:31:36 +0200
MIME-Version: 1.0
In-Reply-To: <20170831094306.0fb655a5@gandalf.local.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org

On 08/31/2017 03:43 PM, Steven Rostedt wrote:
> On Mon, 31 Jul 2017 09:43:41 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> On 04/14/2015 12:14 AM, Arnaldo Carvalho de Melo wrote:
>>> From: Namhyung Kim <namhyung@kernel.org>
>>>
>>> The struct page is opaque for userspace tools, so it'd be better to save
>>> pfn in order to identify page frames.
>>>
>>> The textual output of $debugfs/tracing/trace file remains unchanged and
>>> only raw (binary) data format is changed - but thanks to libtraceevent,
>>> userspace tools which deal with the raw data (like perf and trace-cmd)
>>> can parse the format easily.  
>>
>> Hmm it seems trace-cmd doesn't work that well, at least on current
>> x86_64 kernel where I noticed it:
>>
>>  trace-cmd-22020 [003] 105219.542610: mm_page_alloc:        [FAILED TO PARSE] pfn=0x165cb4 order=0 gfp_flags=29491274 migratetype=1
> 
> Which version of trace-cmd failed? It parses for me. Hmm, the
> vmemmap_base isn't in the event format file. It's the actually address.
> That's probably what failed to parse.

Mine says 2.6. With 4.13-rc6 I get FAILED TO PARSE.

> 
>>
>> I'm quite sure it's due to the "page=%p" part, which uses pfn_to_page().
>> The events/kmem/mm_page_alloc/format file contains this for page:
>>
>> REC->pfn != -1UL ? (((struct page *)vmemmap_base) + (REC->pfn)) : ((void *)0)
> 
> But yeah, I think the output is wrong. I just ran this:
> 
>  page=0xffffea00000a62f4 pfn=680692 order=0 migratetype=0 gfp_flags=GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK
> 
> But running it with trace-cmd report -R (raw format):
> 
>  mm_page_alloc:         pfn=0xa62f4 order=0 gfp_flags=24150208 migratetype=0
> 
> The parser currently ignores types, so it doesn't do pointer
> arithmetic correctly, and would be hard to here as it doesn't know the
> size of the struct page. What could work is if we changed the printf
> fmt to be:
> 
>   (unsigned long)(0xffffea0000000000UL) + (REC->pfn * sizeof(struct page))
> 
> 
>>
>> I think userspace can't know vmmemap_base nor the implied sizeof(struct
>> page) for pointer arithmetic?
>>
>> On older 4.4-based kernel:
>>
>> REC->pfn != -1UL ? (((struct page *)(0xffffea0000000000UL)) + (REC->pfn)) : ((void *)0)
> 
> This is what I have on 4.13-rc7
> 
>>
>> This also fails to parse, so it must be the struct page part?
> 
> Again, what version of trace-cmd do you have?

On the older distro it was 2.0.4

> 
>>
>> I think the problem is, even if ve solve this with some more
>> preprocessor trickery to make the format file contain only constant
>> numbers, pfn_to_page() on e.g. sparse memory model without vmmemap is
>> more complicated than simple arithmetic, and can't be exported in the
>> format file.
>>
>> I'm afraid that to support userspace parsing of the trace data, we will
>> have to store both struct page and pfn... or perhaps give up on reporting
>> the struct page pointer completely. Thoughts?
> 
> Had some thoughts up above.

Yeah, it could be made to work for some configurations, but see the part
about "sparse memory model without vmemmap" above.

> -- Steve
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
