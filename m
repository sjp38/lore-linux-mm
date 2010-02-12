Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 78FA56B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 11:19:12 -0500 (EST)
Subject: Re: [PATCH 08/11] readahead: add tracing event
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20100202153317.365099890@intel.com>
References: <20100202152835.683907822@intel.com>
	 <20100202153317.365099890@intel.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Fri, 12 Feb 2010 11:19:05 -0500
Message-ID: <1265991545.24271.36.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-02-02 at 23:28 +0800, Wu Fengguang wrote:
> plain text document attachment (readahead-tracer.patch)
> Example output:

> +	TP_printk("readahead-%s(dev=%d:%d, ino=%lu, "
> +		  "req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d",
> +			ra_pattern_names[__entry->pattern],

The above totally breaks any parsing by tools. We have already have a
way to map values to strings with __print_symbolic():

		__print_symbolic(__entry->pattern,
			{ RA_PATTERN_INITIAL, "initial" },
			{ RA_PATTERN_SUBSEQUENT, "subsequent"},
			{ RA_PATTERN_CONTEXT, "context"},
			{ RA_PATTERN_THRASH, "thrash"},
			{ RA_PATTERN_MMAP_AROUND, "around"},
			{ RA_PATTERN_FADVISE, "fadvise" },
			{ RA_PATTERN_RANDOM, "random"},
			{ RA_PATTERN_ALL, "all" }),

see include/trace/irq.h for another example.

-- Steve

> +			MAJOR(__entry->dev),
> +			MINOR(__entry->dev),
> +			__entry->ino,
> +			__entry->offset,
> +			__entry->req_size,
> +			__entry->start,
> +			__entry->size,
> +			__entry->async_size,
> +			__entry->start > __entry->offset,
> +			__entry->actual)
> +);
> +
> +#endif /* _TRACE_READAHEAD_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> --- linux.orig/mm/readahead.c	2010-02-01 21:55:43.000000000 +0800
> +++ linux/mm/readahead.c	2010-02-01 21:57:25.000000000 +0800
> @@ -19,11 +19,25 @@
>  #include <linux/pagevec.h>
>  #include <linux/pagemap.h>
>  
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/readahead.h>
> +
>  /*
>   * Set async size to 1/# of the thrashing threshold.
>   */
>  #define READAHEAD_ASYNC_RATIO	8
>  
> +const char * const ra_pattern_names[] = {
> +	[RA_PATTERN_INITIAL]		= "initial",
> +	[RA_PATTERN_SUBSEQUENT]		= "subsequent",
> +	[RA_PATTERN_CONTEXT]		= "context",
> +	[RA_PATTERN_THRASH]		= "thrash",
> +	[RA_PATTERN_MMAP_AROUND]	= "around",
> +	[RA_PATTERN_FADVISE]		= "fadvise",
> +	[RA_PATTERN_RANDOM]		= "random",
> +	[RA_PATTERN_ALL]		= "all",
> +};
> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
