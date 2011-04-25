Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 957848D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:38:44 -0400 (EDT)
Subject: Re: [PATCH] trace: Add tracepoints to fs subsystem
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <1303513209-26436-1-git-send-email-vnagarnaik@google.com>
References: <1303513209-26436-1-git-send-email-vnagarnaik@google.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 25 Apr 2011 11:38:42 -0400
Message-ID: <1303745922.18763.13.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaibhav Nagarnaik <vnagarnaik@google.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Michael Rubin <mrubin@google.com>, David Sharp <dhsharp@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jiaying Zhang <jiayingz@google.com>

On Fri, 2011-04-22 at 16:00 -0700, Vaibhav Nagarnaik wrote:
> From: Jiaying Zhang <jiayingz@google.com>

> +++ b/include/trace/events/fs.h
> @@ -0,0 +1,166 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM fs
> +
> +#if !defined(_TRACE_FS_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_FS_H
> +
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(fs_buffer_wait_start,
> +
> +	TP_PROTO(struct buffer_head *bh),
> +
> +	TP_ARGS(bh),
> +
> +	TP_STRUCT__entry(
> +		__field(	void *,	bh	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->bh = bh;
> +	),
> +
> +	TP_printk("bh %p", __entry->bh)
> +);
> +
> +TRACE_EVENT(fs_buffer_wait_end,
> +
> +	TP_PROTO(struct buffer_head *bh),
> +
> +	TP_ARGS(bh),
> +
> +	TP_STRUCT__entry(
> +		__field(void *, bh)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->bh = bh;
> +	),
> +
> +	TP_printk("bh %p", __entry->bh)

Whenever possible, if you have identical tracepoints, make a template
with DECLARE_EVENT_CLASS() and use DEFINE_EVENT() for each event. This
saves a tun of bloat.

> +);
> +


> +DECLARE_EVENT_CLASS(file_read,
> +	TP_PROTO(struct inode *inode, loff_t pos, size_t len),
> +
> +	TP_ARGS(inode, pos, len),
> +
> +	TP_STRUCT__entry(
> +		__field(	ino_t,	ino			)
> +		__field(	dev_t,	dev			)
> +		__field(	loff_t,	pos			)
> +		__field(	size_t,	len			)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->ino	= inode->i_ino;
> +		__entry->dev	= inode->i_sb->s_dev;
> +		__entry->pos	= pos;
> +		__entry->len	= len;
> +	),
> +
> +	TP_printk("dev %d,%d ino %lu pos %llu len %lu",
> +		  MAJOR(__entry->dev), MINOR(__entry->dev),
> +		  (unsigned long) __entry->ino,
> +		  (unsigned long long) __entry->pos,
> +		  (unsigned long) __entry->len)
> +);
> +
> +DEFINE_EVENT(file_read, file_read_enter,
> +
> +	TP_PROTO(struct inode *inode, loff_t pos, size_t len),
> +
> +	TP_ARGS(inode, pos, len)
> +);
> +
> +DEFINE_EVENT(file_read, file_read_exit,
> +
> +	TP_PROTO(struct inode *inode, loff_t pos, size_t len),
> +
> +	TP_ARGS(inode, pos, len)
> +);

Ah you do it here :)


> +
> +TRACE_EVENT(mpage_readpages,
> +	TP_PROTO(struct page *page, struct address_space *mapping,
> +		 unsigned nr_pages),
> +
> +	TP_ARGS(page, mapping, nr_pages),
> +
> +	TP_STRUCT__entry(
> +		__field(	pgoff_t, index			)
> +		__field(	ino_t,	ino			)
> +		__field(	dev_t,	dev			)
> +		__field(	unsigned,	nr_pages	)
> +
> +	),
> +
> +	TP_fast_assign(
> +		__entry->index	= page->index;
> +		__entry->ino	= mapping->host->i_ino;
> +		__entry->dev	= mapping->host->i_sb->s_dev;
> +		__entry->nr_pages	= nr_pages;
> +	),
> +
> +	TP_printk("dev %d,%d ino %lu page_index %lu nr_pages %u",
> +		  MAJOR(__entry->dev), MINOR(__entry->dev),
> +		  (unsigned long) __entry->ino,
> +		  __entry->index, __entry->nr_pages)
> +);
> +
> +#endif /* _TRACE_FS_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> +
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c641edf..94e549c 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -42,7 +42,7 @@
>  #include <linux/buffer_head.h> /* for try_to_free_buffers */
>  
>  #include <asm/mman.h>
> -
> +#include <trace/events/fs.h>
>  /*
>   * Shared mappings implemented 30.11.1994. It's not fully working yet,
>   * though.
> @@ -1054,6 +1054,7 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
>  	unsigned int prev_offset;
>  	int error;
>  
> +	trace_file_read_enter(inode, *ppos, desc->count);
>  	index = *ppos >> PAGE_CACHE_SHIFT;
>  	prev_index = ra->prev_pos >> PAGE_CACHE_SHIFT;
>  	prev_offset = ra->prev_pos & (PAGE_CACHE_SIZE-1);
> @@ -1254,6 +1255,7 @@ out:
>  	ra->prev_pos <<= PAGE_CACHE_SHIFT;
>  	ra->prev_pos |= prev_offset;
>  
> +	trace_file_read_exit(inode, *ppos, desc->written);
>  	*ppos = ((loff_t)index << PAGE_CACHE_SHIFT) + offset;
>  	file_accessed(filp);
>  }

You need the fs maintainers to take this patch.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
