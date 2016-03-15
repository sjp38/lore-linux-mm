Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDD3828DF
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:50:36 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id mh10so8570020igb.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:50:36 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g79si4670129ioe.130.2016.03.14.23.50.34
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 23:50:35 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:51:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 11/19] zsmalloc: squeeze freelist into page->mapping
Message-ID: <20160315065126.GA3039@bbox>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-12-git-send-email-minchan@kernel.org>
 <20160315064053.GF1464@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160315064053.GF1464@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On Tue, Mar 15, 2016 at 03:40:53PM +0900, Sergey Senozhatsky wrote:
> On (03/11/16 16:30), Minchan Kim wrote:
> > -static void *location_to_obj(struct page *page, unsigned long obj_idx)
> > +static void objidx_to_page_and_ofs(struct size_class *class,
> > +				struct page *first_page,
> > +				unsigned long obj_idx,
> > +				struct page **obj_page,
> > +				unsigned long *ofs_in_page)
> 
> this looks big; 5 params, function "returning" both page and offset...
> any chance to split it in two steps, perhaps?

Yes, it's rather ugly but I don't have a good idea.
Feel free to suggest if you have a better idea.

> 
> besides, it is more intuitive (at least to me) when 'offset'
> shortened to 'offt', not 'ofs'.

Indeed. I will change it to get_page_and_offset instead of
abbreviation if we cannot refactor it more.

> 
> 	-ss
> 
> >  {
> > -	unsigned long obj;
> > +	int i;
> > +	unsigned long ofs;
> > +	struct page *cursor;
> > +	int nr_page;
> >  
> > -	if (!page) {
> > -		VM_BUG_ON(obj_idx);
> > -		return NULL;
> > -	}
> > +	ofs = obj_idx * class->size;
> > +	cursor = first_page;
> > +	nr_page = ofs >> PAGE_SHIFT;
> >  
> > -	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
> > -	obj |= ((obj_idx) & OBJ_INDEX_MASK);
> > -	obj <<= OBJ_TAG_BITS;
> > +	*ofs_in_page = ofs & ~PAGE_MASK;
> > +
> > +	for (i = 0; i < nr_page; i++)
> > +		cursor = get_next_page(cursor);
> >  
> > -	return (void *)obj;
> > +	*obj_page = cursor;
> >  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
