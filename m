Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDB86B005D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 04:02:56 -0400 (EDT)
Date: Fri, 7 Aug 2009 10:02:49 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2/6] tracing, page-allocator: Add trace events for
	anti-fragmentation falling back to other migratetypes
Message-ID: <20090807080249.GA21821@elte.hu>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1249574827-18745-3-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Mel Gorman <mel@csn.ul.ie> wrote:

> +++ b/mm/page_alloc.c
> @@ -839,6 +839,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  							start_migratetype);
>  
>  			expand(zone, page, order, current_order, area, migratetype);
> +
> +			trace_mm_page_alloc_extfrag(page, order, current_order,
> +				start_migratetype, migratetype,
> +				current_order < pageblock_order,
> +				migratetype == start_migratetype);

This tracepoint too should be optimized some more:

 - pageblock_order can be passed down verbatim instead of the 
   'current_order < pageblock_order': it means one comparison less 
   in the fast-path, plus it gives more trace information as well.

 - migratetype == start_migratetype check is superfluous as both 
   values are already traced. This property can be added to the 
   TP_printk() post-processing stage instead, if the pretty-printing 
   is desired.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
