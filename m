Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7C16B0038
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 09:41:46 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so73670374ied.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:41:46 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id g82si1092253ioe.83.2015.04.13.06.41.45
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 06:41:45 -0700 (PDT)
Date: Mon, 13 Apr 2015 10:41:41 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 9/9] tools lib traceevent: Honor operator priority
Message-ID: <20150413134141.GF3200@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-10-git-send-email-namhyung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428298576-9785-10-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>

Em Mon, Apr 06, 2015 at 02:36:16PM +0900, Namhyung Kim escreveu:
> Currently it ignores operator priority and just sets processed args as a
> right operand.  But it could result in priority inversion in case that
> the right operand is also a operator arg and its priority is lower.
> 
> For example, following print format is from new kmem events.
> 
>   "page=%p", REC->pfn != -1UL ? (((struct page *)(0xffffea0000000000UL)) + (REC->pfn)) : ((void *)0)
> 
> But this was treated as below:
> 
>   REC->pfn != ((null - 1UL) ? ((struct page *)0xffffea0000000000UL + REC->pfn) : (void *) 0)
> 
> In this case, the right arg was '?' operator which has lower priority.
> But it just sets the whole arg so making the output confusing - page was
> always 0 or 1 since that's the result of logical operation.
> 
> With this patch, it can handle it properly like following:
> 
>   ((REC->pfn != (null - 1UL)) ? ((struct page *)0xffffea0000000000UL + REC->pfn) : (void *) 0)

And this one already went upstream.

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
