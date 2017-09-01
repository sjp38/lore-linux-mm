Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB1B06B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 04:16:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p17so2920538wmd.0
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 01:16:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k127si1716948wmf.154.2017.09.01.01.16.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 01:16:22 -0700 (PDT)
Subject: Re: [PATCH 1/5] tracing, mm: Record pfn instead of pointer to struct
 page
References: <1428963302-31538-1-git-send-email-acme@kernel.org>
 <1428963302-31538-2-git-send-email-acme@kernel.org>
 <897eb045-d63c-b9e3-c6e7-0f6b94536c0f@suse.cz>
 <20170831094306.0fb655a5@gandalf.local.home>
 <ea9f2ead-e69a-ff6a-debd-73f8e52cc620@suse.cz>
 <20170831104410.09777356@gandalf.local.home>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <50a3640a-df45-c164-e89a-6e306b4c3937@suse.cz>
Date: Fri, 1 Sep 2017 10:16:21 +0200
MIME-Version: 1.0
In-Reply-To: <20170831104410.09777356@gandalf.local.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org

On 08/31/2017 04:44 PM, Steven Rostedt wrote:
> On Thu, 31 Aug 2017 16:31:36 +0200
> Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> 
>>> Which version of trace-cmd failed? It parses for me. Hmm, the
>>> vmemmap_base isn't in the event format file. It's the actually address.
>>> That's probably what failed to parse.  
>>
>> Mine says 2.6. With 4.13-rc6 I get FAILED TO PARSE.
> 
> Right, but you have the vmemmap_base in the event format, which can't
> be parsed by userspace because it has no idea what the value of the
> vmemmap_base is.

This seems to be caused by CONFIG_RANDOMIZE_MEMORY. If we somehow put the value
in the format file, it's an info leak? (but I guess kernels that care must have
ftrace disabled anyway :)

>>
>>>   
>>>>
>>>> I'm quite sure it's due to the "page=%p" part, which uses pfn_to_page().
>>>> The events/kmem/mm_page_alloc/format file contains this for page:
>>>>
>>>> REC->pfn != -1UL ? (((struct page *)vmemmap_base) + (REC->pfn)) : ((void *)0)  
>>>>
>>>> I think the problem is, even if ve solve this with some more
>>>> preprocessor trickery to make the format file contain only constant
>>>> numbers, pfn_to_page() on e.g. sparse memory model without vmmemap is
>>>> more complicated than simple arithmetic, and can't be exported in the
>>>> format file.
>>>>
>>>> I'm afraid that to support userspace parsing of the trace data, we will
>>>> have to store both struct page and pfn... or perhaps give up on reporting
>>>> the struct page pointer completely. Thoughts?  
>>>
>>> Had some thoughts up above.  
>>
>> Yeah, it could be made to work for some configurations, but see the part
>> about "sparse memory model without vmemmap" above.
> 
> Right, but that should work with the latest trace-cmd. Does it?

Hmm, by "sparse memory model without vmemmap" I don't mean there's a
number instead of "vmemmap_base". I mean CONFIG_SPARSEMEM=y

Then __pfn_to_page() looks like this:

#define __page_to_pfn(pg)                                       \
({      const struct page *__pg = (pg);                         \
        int __sec = page_to_section(__pg);                      \
        (unsigned long)(__pg - __section_mem_map_addr(__nr_to_section(__sec))); \
})

Then the part of format file looks like this:

REC->pfn != -1UL ? ({ unsigned long __pfn = (REC->pfn); struct mem_section *__sec = __pfn_to_section(__pfn); __section_mem_map_addr(__sec) + __pfn; }) : ((void *)0)

The section things involve some array lookups, so I don't see how we
could pass it to tracing userspace. Would we want to special-case
this config to store both pfn and struct page in the trace frame? And
make sure the simpler ones work despite all the exsisting gotchas?
I'd rather say we should either store both pfn and page pointer, or
just throw away the page pointer as the pfn is enough to e.g. match
alloc and free, and also much more deterministic.
 
> -- Steve
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
