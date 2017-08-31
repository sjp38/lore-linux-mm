Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2587D6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 10:44:15 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id k191so1674784oih.0
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 07:44:15 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e9si6907619oic.520.2017.08.31.07.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 07:44:13 -0700 (PDT)
Date: Thu, 31 Aug 2017 10:44:10 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/5] tracing, mm: Record pfn instead of pointer to
 struct page
Message-ID: <20170831104410.09777356@gandalf.local.home>
In-Reply-To: <ea9f2ead-e69a-ff6a-debd-73f8e52cc620@suse.cz>
References: <1428963302-31538-1-git-send-email-acme@kernel.org>
	<1428963302-31538-2-git-send-email-acme@kernel.org>
	<897eb045-d63c-b9e3-c6e7-0f6b94536c0f@suse.cz>
	<20170831094306.0fb655a5@gandalf.local.home>
	<ea9f2ead-e69a-ff6a-debd-73f8e52cc620@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org

On Thu, 31 Aug 2017 16:31:36 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:


> > Which version of trace-cmd failed? It parses for me. Hmm, the
> > vmemmap_base isn't in the event format file. It's the actually address.
> > That's probably what failed to parse.  
> 
> Mine says 2.6. With 4.13-rc6 I get FAILED TO PARSE.

Right, but you have the vmemmap_base in the event format, which can't
be parsed by userspace because it has no idea what the value of the
vmemmap_base is.

> 
> >   
> >>
> >> I'm quite sure it's due to the "page=%p" part, which uses pfn_to_page().
> >> The events/kmem/mm_page_alloc/format file contains this for page:
> >>
> >> REC->pfn != -1UL ? (((struct page *)vmemmap_base) + (REC->pfn)) : ((void *)0)  
> > 


> >> On older 4.4-based kernel:
> >>
> >> REC->pfn != -1UL ? (((struct page *)(0xffffea0000000000UL)) + (REC->pfn)) : ((void *)0)  
> > 
> > This is what I have on 4.13-rc7
> >   
> >>
> >> This also fails to parse, so it must be the struct page part?  
> > 
> > Again, what version of trace-cmd do you have?  
> 
> On the older distro it was 2.0.4

Right. That's probably why it failed to parse here. If you installed
the latest trace-cmd from the git repo, it probably will parse fine.

> 
> >   
> >>
> >> I think the problem is, even if ve solve this with some more
> >> preprocessor trickery to make the format file contain only constant
> >> numbers, pfn_to_page() on e.g. sparse memory model without vmmemap is
> >> more complicated than simple arithmetic, and can't be exported in the
> >> format file.
> >>
> >> I'm afraid that to support userspace parsing of the trace data, we will
> >> have to store both struct page and pfn... or perhaps give up on reporting
> >> the struct page pointer completely. Thoughts?  
> > 
> > Had some thoughts up above.  
> 
> Yeah, it could be made to work for some configurations, but see the part
> about "sparse memory model without vmemmap" above.

Right, but that should work with the latest trace-cmd. Does it?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
