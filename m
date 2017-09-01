Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 159396B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 07:15:46 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x133so5207468oif.6
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 04:15:46 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g184si1665633oib.42.2017.09.01.04.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 04:15:44 -0700 (PDT)
Date: Fri, 1 Sep 2017 07:15:41 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/5] tracing, mm: Record pfn instead of pointer to
 struct page
Message-ID: <20170901071541.30293b95@gandalf.local.home>
In-Reply-To: <50a3640a-df45-c164-e89a-6e306b4c3937@suse.cz>
References: <1428963302-31538-1-git-send-email-acme@kernel.org>
	<1428963302-31538-2-git-send-email-acme@kernel.org>
	<897eb045-d63c-b9e3-c6e7-0f6b94536c0f@suse.cz>
	<20170831094306.0fb655a5@gandalf.local.home>
	<ea9f2ead-e69a-ff6a-debd-73f8e52cc620@suse.cz>
	<20170831104410.09777356@gandalf.local.home>
	<50a3640a-df45-c164-e89a-6e306b4c3937@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org

On Fri, 1 Sep 2017 10:16:21 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:
 
> > Right, but that should work with the latest trace-cmd. Does it?  
> 
> Hmm, by "sparse memory model without vmemmap" I don't mean there's a
> number instead of "vmemmap_base". I mean CONFIG_SPARSEMEM=y
> 
> Then __pfn_to_page() looks like this:
> 
> #define __page_to_pfn(pg)                                       \
> ({      const struct page *__pg = (pg);                         \
>         int __sec = page_to_section(__pg);                      \
>         (unsigned long)(__pg - __section_mem_map_addr(__nr_to_section(__sec))); \
> })
> 
> Then the part of format file looks like this:
> 
> REC->pfn != -1UL ? ({ unsigned long __pfn = (REC->pfn); struct mem_section *__sec = __pfn_to_section(__pfn); __section_mem_map_addr(__sec) + __pfn; }) : ((void *)0)

Ouch.

> 
> The section things involve some array lookups, so I don't see how we
> could pass it to tracing userspace. Would we want to special-case
> this config to store both pfn and struct page in the trace frame? And
> make sure the simpler ones work despite all the exsisting gotchas?
> I'd rather say we should either store both pfn and page pointer, or
> just throw away the page pointer as the pfn is enough to e.g. match
> alloc and free, and also much more deterministic.

Write up a patch and we'll take a look.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
