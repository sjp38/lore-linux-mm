Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 9B28C6B00B8
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 02:12:39 -0400 (EDT)
Message-ID: <4FD58C54.7050504@kernel.org>
Date: Mon, 11 Jun 2012 15:12:36 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 08/10] mm: frontswap: add tracing support
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com> <1339325468-30614-9-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-9-git-send-email-levinsasha928@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/10/2012 07:51 PM, Sasha Levin wrote:

> Add tracepoints to frontswap API.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>


Normally, adding new tracepoint isn't easy without special reason.
I'm not sure all of frontswap function tracing would be valuable.
Shsha, Why do you want to add tracing?
What's scenario you want to use tracing?

> ---
>  include/trace/events/frontswap.h |  167 ++++++++++++++++++++++++++++++++++++++
>  mm/frontswap.c                   |   14 +++
>  2 files changed, 181 insertions(+), 0 deletions(-)
>  create mode 100644 include/trace/events/frontswap.h
> 
> diff --git a/include/trace/events/frontswap.h b/include/trace/events/frontswap.h
> new file mode 100644
> index 0000000..2e5efab
> --- /dev/null
> +++ b/include/trace/events/frontswap.h
> @@ -0,0 +1,167 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM frontswap
> +
> +#if !defined(_TRACE_FRONTSWAP_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_FRONTSWAP_H
> +
> +#include <linux/tracepoint.h>
> +
> +struct frontswap_ops;
> +
> +TRACE_EVENT(frontswap_init,
> +	TP_PROTO(unsigned int type, void *sis, void *frontswap_map),
> +	TP_ARGS(type, sis, frontswap_map),
> +
> +	TP_STRUCT__entry(
> +		__field(	unsigned int,	type		)
> +		__field(	void *,		sis		)
> +		__field(	void *,		frontswap_map	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->type		= type;
> +		__entry->sis		= sis;
> +		__entry->frontswap_map	= frontswap_map;
> +	),
> +
> +	TP_printk("type: %u sis: %p frontswap_map: %p",
> +		  __entry->type, __entry->sis, __entry->frontswap_map)
> +);
> +
> +TRACE_EVENT(frontswap_register_ops,
> +	TP_PROTO(struct frontswap_ops *old, struct frontswap_ops *new),
> +	TP_ARGS(old, new),
> +
> +	TP_STRUCT__entry(
> +		__field(struct frontswap_ops *,		old		)
> +		__field(struct frontswap_ops *,		new		)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->old		= old;
> +		__entry->new		= new;
> +	),
> +
> +	TP_printk("old: {init=%p store=%p load=%p invalidate_page=%p invalidate_area=%p}"
> +		" new: {init=%p store=%p load=%p invalidate_page=%p invalidate_area=%p}",
> +		__entry->old->init,__entry->old->store,__entry->old->load,
> +		__entry->old->invalidate_page,__entry->old->invalidate_area,__entry->new->init,
> +		__entry->new->store,__entry->new->load,__entry->new->invalidate_page,
> +		__entry->new->invalidate_area)
> +);
> +
> +TRACE_EVENT(frontswap_store,
> +	TP_PROTO(void *page, int dup, int ret),
> +	TP_ARGS(page, dup, ret),
> +
> +	TP_STRUCT__entry(
> +		__field(	int,		dup		)
> +		__field(	int,		ret		)
> +		__field(	void *,		page		)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->dup		= dup;
> +		__entry->ret		= ret;
> +		__entry->page		= page;
> +	),
> +
> +	TP_printk("page: %p dup: %d ret: %d",
> +		  __entry->page, __entry->dup, __entry->ret)
> +);
> +
> +TRACE_EVENT(frontswap_load,
> +	TP_PROTO(void *page, int ret),
> +	TP_ARGS(page, ret),
> +
> +	TP_STRUCT__entry(
> +		__field(	int,		ret		)
> +		__field(	void *,		page		)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->ret		= ret;
> +		__entry->page		= page;
> +	),
> +
> +	TP_printk("page: %p ret: %d",
> +		  __entry->page, __entry->ret)
> +);
> +
> +TRACE_EVENT(frontswap_invalidate_page,
> +	TP_PROTO(int type, unsigned long offset, void *sis, int test),
> +	TP_ARGS(type, offset, sis, test),
> +
> +	TP_STRUCT__entry(
> +		__field(	int,		type		)
> +		__field(	unsigned long,	offset		)
> +		__field(	void *,		sis		)
> +		__field(	int,		test		)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->type		= type;
> +		__entry->offset		= offset;
> +		__entry->sis		= sis;
> +		__entry->test		= test;
> +	),
> +
> +	TP_printk("type: %d offset: %lu sys: %p frontswap_test: %d",
> +		  __entry->type, __entry->offset, __entry->sis, __entry->test)
> +);
> +
> +TRACE_EVENT(frontswap_invalidate_area,
> +	TP_PROTO(int type, void *sis, void *map),
> +	TP_ARGS(type, sis, map),
> +
> +	TP_STRUCT__entry(
> +		__field(	int,		type		)
> +		__field(	void *,		map		)
> +		__field(	void *,		sis		)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->type		= type;
> +		__entry->sis		= sis;
> +		__entry->map		= map;
> +	),
> +
> +	TP_printk("type: %d sys: %p map: %p",
> +		  __entry->type, __entry->sis, __entry->map)
> +);
> +
> +TRACE_EVENT(frontswap_curr_pages,
> +	TP_PROTO(unsigned long totalpages),
> +	TP_ARGS(totalpages),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long,		totalpages	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->totalpages	= totalpages;
> +	),
> +
> +	TP_printk("total pages: %lu",
> +		  __entry->totalpages)
> +);
> +
> +TRACE_EVENT(frontswap_shrink,
> +	TP_PROTO(unsigned long target_pages),
> +	TP_ARGS(target_pages),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long,		target_pages	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->target_pages	= target_pages;
> +	),
> +
> +	TP_printk("target pages: %lu",
> +		  __entry->target_pages)
> +);
> +
> +#endif /* _TRACE_FRONTSWAP_H */
> +
> +#include <trace/define_trace.h>
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 7c26e89..7da55a3 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -11,6 +11,7 @@
>   * This work is licensed under the terms of the GNU GPL, version 2.
>   */
>  
> +#define CREATE_TRACE_POINTS
>  #include <linux/mm.h>
>  #include <linux/mman.h>
>  #include <linux/swap.h>
> @@ -23,6 +24,7 @@
>  #include <linux/debugfs.h>
>  #include <linux/frontswap.h>
>  #include <linux/swapfile.h>
> +#include <trace/events/frontswap.h>
>  
>  /*
>   * frontswap_ops is set by frontswap_register_ops to contain the pointers
> @@ -85,6 +87,7 @@ struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
>  {
>  	struct frontswap_ops old = frontswap_ops;
>  
> +	trace_frontswap_register_ops(&old, ops);
>  	frontswap_ops = *ops;
>  	frontswap_enabled = true;
>  	return old;
> @@ -108,6 +111,9 @@ void __frontswap_init(unsigned type)
>  	struct swap_info_struct *sis = swap_info[type];
>  
>  	BUG_ON(sis == NULL);
> +
> +	trace_frontswap_init(type, sis, sis->frontswap_map);
> +
>  	if (sis->frontswap_map == NULL)
>  		return;
>  	frontswap_ops.init(type);
> @@ -134,6 +140,7 @@ int __frontswap_store(struct page *page)
>  	if (frontswap_test(sis, offset))
>  		dup = 1;
>  	ret = frontswap_ops.store(type, offset, page);
> +	trace_frontswap_store(page, dup, ret);
>  	if (ret == 0) {
>  		frontswap_set(sis, offset);
>  		inc_frontswap_succ_stores();
> @@ -174,6 +181,7 @@ int __frontswap_load(struct page *page)
>  	BUG_ON(sis == NULL);
>  	if (frontswap_test(sis, offset))
>  		ret = frontswap_ops.load(type, offset, page);
> +	trace_frontswap_load(page, ret);
>  	if (ret == 0)
>  		inc_frontswap_loads();
>  	return ret;
> @@ -189,6 +197,7 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
>  	struct swap_info_struct *sis = swap_info[type];
>  
>  	BUG_ON(sis == NULL);
> +	trace_frontswap_invalidate_page(type, offset, sis, frontswap_test(sis, offset));
>  	if (frontswap_test(sis, offset)) {
>  		frontswap_ops.invalidate_page(type, offset);
>  		atomic_dec(&sis->frontswap_pages);
> @@ -207,6 +216,7 @@ void __frontswap_invalidate_area(unsigned type)
>  	struct swap_info_struct *sis = swap_info[type];
>  
>  	BUG_ON(sis == NULL);
> +	trace_frontswap_invalidate_area(type, sis, sis->frontswap_map);
>  	if (sis->frontswap_map == NULL)
>  		return;
>  	frontswap_ops.invalidate_area(type);
> @@ -295,6 +305,8 @@ void frontswap_shrink(unsigned long target_pages)
>  	unsigned long pages_to_unuse = 0;
>  	int type, ret;
>  
> +	trace_frontswap_shrink(target_pages);
> +
>  	/*
>  	 * we don't want to hold swap_lock while doing a very
>  	 * lengthy try_to_unuse, but swap_list may change
> @@ -322,6 +334,8 @@ unsigned long frontswap_curr_pages(void)
>  	totalpages = __frontswap_curr_pages();
>  	spin_unlock(&swap_lock);
>  
> +	trace_frontswap_curr_pages(totalpages);
> +
>  	return totalpages;
>  }
>  EXPORT_SYMBOL(frontswap_curr_pages);



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
