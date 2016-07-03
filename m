Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 890186B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 19:56:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so362191537pfb.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 16:56:24 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m69si786503pfc.279.2016.07.03.16.56.22
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 16:56:23 -0700 (PDT)
Date: Mon, 4 Jul 2016 08:57:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/8] mm/zsmalloc: take obj index back from
 find_alloced_obj
Message-ID: <20160703235704.GB19044@bbox>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
 <1467355266-9735-3-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467355266-9735-3-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Fri, Jul 01, 2016 at 02:41:01PM +0800, Ganesh Mahendran wrote:
> the obj index value should be updated after return from
> find_alloced_obj()
 
        to avoid CPU buring caused by unnecessary object scanning.

Description should include what's the goal.

> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
>  mm/zsmalloc.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 405baa5..5c96ed1 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1744,15 +1744,16 @@ static void zs_object_copy(struct size_class *class, unsigned long dst,
>   * return handle.
>   */
>  static unsigned long find_alloced_obj(struct size_class *class,
> -					struct page *page, int index)
> +					struct page *page, int *index)
>  {
>  	unsigned long head;
>  	int offset = 0;
> +	int objidx = *index;

Nit:

We have used obj_idx so I prefer it for consistency with others.

Suggestion:
Could you mind changing index in zs_compact_control and
migrate_zspage with obj_idx in this chance?

Strictly speaking, such clean up is separate patch but I don't mind
mixing them here(Of course, you will send it as another clean up patch,
it would be better). If you mind, just let it leave as is. Sometime,
I wil do it.

>  	unsigned long handle = 0;
>  	void *addr = kmap_atomic(page);
>  
>  	offset = get_first_obj_offset(page);
> -	offset += class->size * index;
> +	offset += class->size * objidx;
>  
>  	while (offset < PAGE_SIZE) {
>  		head = obj_to_head(page, addr + offset);
> @@ -1764,9 +1765,11 @@ static unsigned long find_alloced_obj(struct size_class *class,
>  		}
>  
>  		offset += class->size;
> -		index++;
> +		objidx++;
>  	}
>  
> +	*index = objidx;

We can do this out of kmap section right before returing handle.

Thanks!

> +
>  	kunmap_atomic(addr);
>  	return handle;
>  }
> @@ -1794,11 +1797,11 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
>  	unsigned long handle;
>  	struct page *s_page = cc->s_page;
>  	struct page *d_page = cc->d_page;
> -	unsigned long index = cc->index;
> +	unsigned int index = cc->index;
>  	int ret = 0;
>  
>  	while (1) {
> -		handle = find_alloced_obj(class, s_page, index);
> +		handle = find_alloced_obj(class, s_page, &index);
>  		if (!handle) {
>  			s_page = get_next_page(s_page);
>  			if (!s_page)
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
