Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 31CFE6B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 10:22:33 -0500 (EST)
Date: Tue, 29 Nov 2011 16:22:28 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 7/9] readahead: add vfs/readahead tracing event
Message-ID: <20111129152228.GO5635@quack.suse.cz>
References: <20111129130900.628549879@intel.com>
 <20111129131456.797240894@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129131456.797240894@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 29-11-11 21:09:07, Wu Fengguang wrote:
> This is very useful for verifying whether the readahead algorithms are
> working to the expectation.
> 
> Example output:
> 
> # echo 1 > /debug/tracing/events/vfs/readahead/enable
> # cp test-file /dev/null
> # cat /debug/tracing/trace  # trimmed output
> readahead-initial(dev=0:15, ino=100177, req=0+2, ra=0+4-2, async=0) = 4
> readahead-subsequent(dev=0:15, ino=100177, req=2+2, ra=4+8-8, async=1) = 8
> readahead-subsequent(dev=0:15, ino=100177, req=4+2, ra=12+16-16, async=1) = 16
> readahead-subsequent(dev=0:15, ino=100177, req=12+2, ra=28+32-32, async=1) = 32
> readahead-subsequent(dev=0:15, ino=100177, req=28+2, ra=60+60-60, async=1) = 24
> readahead-subsequent(dev=0:15, ino=100177, req=60+2, ra=120+60-60, async=1) = 0
> 
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Jens Axboe <axboe@kernel.dk>
> CC: Steven Rostedt <rostedt@goodmis.org>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
  Looks OK.

  Acked-by: Jan Kara <jack@suse.cz>

									Honza
> ---
>  include/trace/events/vfs.h |   64 +++++++++++++++++++++++++++++++++++
>  mm/readahead.c             |    5 ++
>  2 files changed, 69 insertions(+)
> 
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-next/include/trace/events/vfs.h	2011-11-29 20:58:59.000000000 +0800
> @@ -0,0 +1,64 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM vfs
> +
> +#if !defined(_TRACE_VFS_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_VFS_H
> +
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(readahead,
> +	TP_PROTO(struct address_space *mapping,
> +		 pgoff_t offset,
> +		 unsigned long req_size,
> +		 enum readahead_pattern pattern,
> +		 pgoff_t start,
> +		 unsigned long size,
> +		 unsigned long async_size,
> +		 unsigned int actual),
> +
> +	TP_ARGS(mapping, offset, req_size, pattern, start, size, async_size,
> +		actual),
> +
> +	TP_STRUCT__entry(
> +		__field(	dev_t,		dev		)
> +		__field(	ino_t,		ino		)
> +		__field(	pgoff_t,	offset		)
> +		__field(	unsigned long,	req_size	)
> +		__field(	unsigned int,	pattern		)
> +		__field(	pgoff_t,	start		)
> +		__field(	unsigned int,	size		)
> +		__field(	unsigned int,	async_size	)
> +		__field(	unsigned int,	actual		)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->dev		= mapping->host->i_sb->s_dev;
> +		__entry->ino		= mapping->host->i_ino;
> +		__entry->offset		= offset;
> +		__entry->req_size	= req_size;
> +		__entry->pattern	= pattern;
> +		__entry->start		= start;
> +		__entry->size		= size;
> +		__entry->async_size	= async_size;
> +		__entry->actual		= actual;
> +	),
> +
> +	TP_printk("readahead-%s(dev=%d:%d, ino=%lu, "
> +		  "req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d",
> +			ra_pattern_names[__entry->pattern],
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
> +#endif /* _TRACE_VFS_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> --- linux-next.orig/mm/readahead.c	2011-11-29 20:58:53.000000000 +0800
> +++ linux-next/mm/readahead.c	2011-11-29 20:59:20.000000000 +0800
> @@ -29,6 +29,9 @@ static const char * const ra_pattern_nam
>  	[RA_PATTERN_ALL]                = "all",
>  };
>  
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/vfs.h>
> +
>  /*
>   * Initialise a struct file's readahead state.  Assumes that the caller has
>   * memset *ra to zero.
> @@ -215,6 +218,8 @@ static inline void readahead_event(struc
>  				for_mmap, for_metadata,
>  				pattern, start, size, async_size, actual);
>  #endif
> +	trace_readahead(mapping, offset, req_size,
> +			pattern, start, size, async_size, actual);
>  }
>  
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
