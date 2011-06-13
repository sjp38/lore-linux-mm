Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D79FB6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:34:00 -0400 (EDT)
Date: Mon, 13 Jun 2011 16:33:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] writeback: trace global_dirty_state
Message-ID: <20110613143356.GG4907@quack.suse.cz>
References: <20110610144805.GA9986@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610144805.GA9986@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri 10-06-11 22:48:05, Wu Fengguang wrote:
> [It seems beneficial to queue this simple trace event for
>  next/upstream after the review?]
> 
> Add trace event balance_dirty_state for showing the global dirty page
> counts and thresholds at each global_dirty_limits() invocation.  This
> will cover the callers throttle_vm_writeout(), over_bground_thresh()
> and each balance_dirty_pages() loop.
  OK, this might be useful. But shouldn't we also add similar trace point
for bdi limits? Otherwise the information is of limited use...

								Honza
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/trace/events/writeback.h |   36 +++++++++++++++++++++++++++++
>  mm/page-writeback.c              |    1 
>  2 files changed, 37 insertions(+)
> 
> --- linux-next.orig/mm/page-writeback.c	2011-06-10 21:52:34.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2011-06-10 22:08:26.000000000 +0800
> @@ -430,6 +430,7 @@ void global_dirty_limits(unsigned long *
>  	}
>  	*pbackground = background;
>  	*pdirty = dirty;
> +	trace_global_dirty_state(background, dirty);
>  }
>  
>  /**
> --- linux-next.orig/include/trace/events/writeback.h	2011-06-10 21:52:34.000000000 +0800
> +++ linux-next/include/trace/events/writeback.h	2011-06-10 22:25:33.000000000 +0800
> @@ -187,6 +187,42 @@ TRACE_EVENT(writeback_queue_io,
>  		__entry->moved)
>  );
>  
> +TRACE_EVENT(global_dirty_state,
> +
> +	TP_PROTO(unsigned long background_thresh,
> +		 unsigned long dirty_thresh
> +	),
> +
> +	TP_ARGS(background_thresh,
> +		dirty_thresh
> +	),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long,	nr_dirty)
> +		__field(unsigned long,	nr_writeback)
> +		__field(unsigned long,	nr_unstable)
> +		__field(unsigned long,	background_thresh)
> +		__field(unsigned long,	dirty_thresh)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nr_dirty	= global_page_state(NR_FILE_DIRTY);
> +		__entry->nr_writeback	= global_page_state(NR_WRITEBACK);
> +		__entry->nr_unstable	= global_page_state(NR_UNSTABLE_NFS);
> +		__entry->background_thresh = background_thresh;
> +		__entry->dirty_thresh	= dirty_thresh;
> +	),
> +
> +	TP_printk("dirty=%lu writeback=%lu unstable=%lu "
> +		  "bg_thresh=%lu thresh=%lu",
> +		  __entry->nr_dirty,
> +		  __entry->nr_writeback,
> +		  __entry->nr_unstable,
> +		  __entry->background_thresh,
> +		  __entry->dirty_thresh
> +	)
> +);
> +
>  DECLARE_EVENT_CLASS(writeback_congest_waited_template,
>  
>  	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
