Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id ED5626B00AE
	for <linux-mm@kvack.org>; Sat, 15 Nov 2014 08:20:10 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so18265471pdj.24
        for <linux-mm@kvack.org>; Sat, 15 Nov 2014 05:20:10 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ap8si30857514pad.85.2014.11.15.05.20.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Nov 2014 05:20:09 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so19281765pac.37
        for <linux-mm@kvack.org>; Sat, 15 Nov 2014 05:20:08 -0800 (PST)
Date: Sat, 15 Nov 2014 22:20:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] zsmalloc: correct fragile [kmap|kunmap]_atomic use
Message-ID: <20141115132030.GB1046@swordfish>
References: <1415927461-14220-1-git-send-email-minchan@kernel.org>
 <20141114150732.GA2402@cerebellum.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141114150732.GA2402@cerebellum.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Jerome Marchand <jmarchan@redhat.com>

On (11/14/14 09:07), Seth Jennings wrote:
> On Fri, Nov 14, 2014 at 10:11:01AM +0900, Minchan Kim wrote:
> > The kunmap_atomic should use virtual address getting by kmap_atomic.
> > However, some pieces of code in zsmalloc uses modified address,
> > not the one got by kmap_atomic for kunmap_atomic.
> > 
> > It's okay for working because zsmalloc modifies the address
> > inner PAGE_SIZE bounday so it works with current kmap_atomic's
> > implementation. But it's still fragile with potential changing
> > of kmap_atomic so let's correct it.
> 
> Seems like you could just use PAGE_MASK to get the base page address
> from link like this:
> 

both solutions look good to me:
Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b3b57ef..d6ca05a 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -654,7 +654,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
>                  */
>                 next_page = get_next_page(page);
>                 link->next = obj_location_to_handle(next_page, 0);
> -               kunmap_atomic(link);
> +               kunmap_atomic((void *)((unsigned long)link & PAGE_MASK));
>                 page = next_page;
>                 off %= PAGE_SIZE;
>         }
> @@ -1087,7 +1087,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>                                         m_offset / sizeof(*link);
>         first_page->freelist = link->next;
>         memset(link, POISON_INUSE, sizeof(*link));
> -       kunmap_atomic(link);
> +       kunmap_atomic((void *)((unsigned long)link & PAGE_MASK));
>  
>         first_page->inuse++;
>         /* Now move the zspage to another fullness group, if required */
> @@ -1124,7 +1124,7 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
>         link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
>                                                         + f_offset);
>         link->next = first_page->freelist;
> -       kunmap_atomic(link);
> +       kunmap_atomic((void *)((unsigned long)link & PAGE_MASK));
>         first_page->freelist = (void *)obj;
>  
>         first_page->inuse--;
> ---
> 
> This seems cleaner, but, at the same time, it isn't obvious that we are
> passing the same value to kunmap_atomic() that we got from
> kmap_atomic().  Just a thought.
> 
> Either way:
> 
> Reviewed-by: Seth Jennings <sjennings@variantweb.net>
> 
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/zsmalloc.c | 21 ++++++++++++---------
> >  1 file changed, 12 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index b3b57ef85830..85e14f584048 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -629,6 +629,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
> >  		struct page *next_page;
> >  		struct link_free *link;
> >  		unsigned int i = 1;
> > +		void *vaddr;
> >  
> >  		/*
> >  		 * page->index stores offset of first object starting
> > @@ -639,8 +640,8 @@ static void init_zspage(struct page *first_page, struct size_class *class)
> >  		if (page != first_page)
> >  			page->index = off;
> >  
> > -		link = (struct link_free *)kmap_atomic(page) +
> > -						off / sizeof(*link);
> > +		vaddr = kmap_atomic(page);
> > +		link = (struct link_free *)vaddr + off / sizeof(*link);
> >  
> >  		while ((off += class->size) < PAGE_SIZE) {
> >  			link->next = obj_location_to_handle(page, i++);
> > @@ -654,7 +655,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
> >  		 */
> >  		next_page = get_next_page(page);
> >  		link->next = obj_location_to_handle(next_page, 0);
> > -		kunmap_atomic(link);
> > +		kunmap_atomic(vaddr);
> >  		page = next_page;
> >  		off %= PAGE_SIZE;
> >  	}
> > @@ -1055,6 +1056,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
> >  	unsigned long obj;
> >  	struct link_free *link;
> >  	struct size_class *class;
> > +	void *vaddr;
> >  
> >  	struct page *first_page, *m_page;
> >  	unsigned long m_objidx, m_offset;
> > @@ -1083,11 +1085,11 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
> >  	obj_handle_to_location(obj, &m_page, &m_objidx);
> >  	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
> >  
> > -	link = (struct link_free *)kmap_atomic(m_page) +
> > -					m_offset / sizeof(*link);
> > +	vaddr = kmap_atomic(m_page);
> > +	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
> >  	first_page->freelist = link->next;
> >  	memset(link, POISON_INUSE, sizeof(*link));
> > -	kunmap_atomic(link);
> > +	kunmap_atomic(vaddr);
> >  
> >  	first_page->inuse++;
> >  	/* Now move the zspage to another fullness group, if required */
> > @@ -1103,6 +1105,7 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
> >  	struct link_free *link;
> >  	struct page *first_page, *f_page;
> >  	unsigned long f_objidx, f_offset;
> > +	void *vaddr;
> >  
> >  	int class_idx;
> >  	struct size_class *class;
> > @@ -1121,10 +1124,10 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
> >  	spin_lock(&class->lock);
> >  
> >  	/* Insert this object in containing zspage's freelist */
> > -	link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
> > -							+ f_offset);
> > +	vaddr = kmap_atomic(f_page);
> > +	link = (struct link_free *)(vaddr + f_offset);
> >  	link->next = first_page->freelist;
> > -	kunmap_atomic(link);
> > +	kunmap_atomic(vaddr);
> >  	first_page->freelist = (void *)obj;
> >  
> >  	first_page->inuse--;
> > -- 
> > 2.0.0
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
