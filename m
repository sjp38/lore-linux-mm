Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 849706B004D
	for <linux-mm@kvack.org>; Sat,  8 Aug 2009 01:44:36 -0400 (EDT)
Received: by gxk3 with SMTP id 3so2559032gxk.14
        for <linux-mm@kvack.org>; Fri, 07 Aug 2009 22:44:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090807173118.GA10446@csn.ul.ie>
References: <20090805165302.5BC8.A69D9226@jp.fujitsu.com>
	 <20090805094019.GB21950@csn.ul.ie>
	 <20090807100502.5BDC.A69D9226@jp.fujitsu.com>
	 <20090807173118.GA10446@csn.ul.ie>
Date: Sat, 8 Aug 2009 14:44:40 +0900
Message-ID: <2f11576a0908072244n45e57c93x6def9f6b64b24133@mail.gmail.com>
Subject: Re: [PATCH 1/4] tracing, page-allocator: Add trace events for page
	allocation and page freeing
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > In the NUMA case, this will be true but addressing it involves passing=
 down
>> > an additional argument in the non-tracing case which I wanted to avoid=
.
>> > As the stacktrace option is available to ftrace, I think I'll drop cal=
l_site
>> > altogether as anyone who really needs that information has options.
>>
>> Insted, can we move this tracepoint to alloc_pages_current(), alloc_page=
s_node() et al ?
>> On page tracking case, call_site information is one of most frequently u=
sed one.
>> if we need multiple trace combination, it become hard to use and reduce =
usefulness a bit.
>>
>
> Ok, lets think about that. The potential points that would need
> annotation are
>
> =A0 =A0 =A0 =A0o alloc_pages_current
> =A0 =A0 =A0 =A0o alloc_page_vma
> =A0 =A0 =A0 =A0o alloc_pages_node
> =A0 =A0 =A0 =A0o alloc_pages_exact_node
>
> The inlined functions that call those and should preserve the call_site
> are
>
> =A0 =A0 =A0 =A0o alloc_pages
>
> The slightly lower functions they call are as follows. These cannot
> trigger a tracepoint event because it would look like a duplicate.
>
> =A0 =A0 =A0 =A0o __alloc_pages_nodemask
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- called by __alloc_pages
> =A0 =A0 =A0 =A0o __alloc_pages
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- called by alloc_page_interleave() but ev=
ent logged
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- called by alloc_pages_node but event log=
ged
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- called by alloc_pages_exact_node but eve=
nt logged
>
> The more problematic ones are
>
> =A0 =A0 =A0 =A0o __get_free_pages
> =A0 =A0 =A0 =A0o get_zeroed_page
> =A0 =A0 =A0 =A0o alloc_pages_exact
>
> The are all real functions that call down to functions that would log
> events already based on your suggestion - alloc_pages_current() in
> particularly.
>
> Looking at it, it would appear the page allocator API would need a fair
> amount of reschuffling to preserve call_site and not duplicate events or
> else to pass call_site down through the API even in the non-tracing case.
> Minimally, that makes it a standalone patch but it would also need a good
> explanation as to why capturing the stack trace on the event is not enoug=
h
> to track the page for things like catching memory leaks.

I agree this is need to some cleanup.
I think I can do that and I can agree your.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
