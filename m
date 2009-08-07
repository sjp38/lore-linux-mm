Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 00D566B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 03:50:44 -0400 (EDT)
Date: Fri, 7 Aug 2009 09:50:30 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/6] tracing, page-allocator: Add trace events for page
	allocation and page freeing
Message-ID: <20090807075030.GB20292@elte.hu>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1249574827-18745-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Mel Gorman <mel@csn.ul.ie> wrote:

> +TRACE_EVENT(mm_pagevec_free,

> +	TP_fast_assign(
> +		__entry->page		= page;
> +		__entry->order		= order;
> +		__entry->cold		= cold;
> +	),

> -	while (--i >= 0)
> +	while (--i >= 0) {
> +		trace_mm_pagevec_free(pvec->pages[i], 0, pvec->cold);
>  		free_hot_cold_page(pvec->pages[i], pvec->cold);
> +	}

Pagevec freeing has order 0 implicit, so you can further optimize 
this by leaving out the 'order' field and using this format string:

+	TP_printk("page=%p pfn=%lu order=0 cold=%d",
+                       __entry->page,
+                       page_to_pfn(__entry->page),
+                       __entry->cold)

the trace record becomes smaller by 4 bytes and the tracepoint 
fastpath becomes shorter as well.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
