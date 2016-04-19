Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A87C36B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 03:41:42 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m2so24722907ioa.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 00:41:42 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m6si2944240igx.88.2016.04.19.00.41.41
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 00:41:41 -0700 (PDT)
Date: Tue, 19 Apr 2016 16:42:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 08/16] zsmalloc: squeeze freelist into page->mapping
Message-ID: <20160419074239.GB18448@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-9-git-send-email-minchan@kernel.org>
 <20160417155621.GE575@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160417155621.GE575@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Mon, Apr 18, 2016 at 12:56:21AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (03/30/16 16:12), Minchan Kim wrote:
> [..]
> > +static void objidx_to_page_and_offset(struct size_class *class,
> > +				struct page *first_page,
> > +				unsigned long obj_idx,
> > +				struct page **obj_page,
> > +				unsigned long *offset_in_page)
> >  {
> > -	unsigned long obj;
> > +	int i;
> > +	unsigned long offset;
> > +	struct page *cursor;
> > +	int nr_page;
> >  
> > -	if (!page) {
> > -		VM_BUG_ON(obj_idx);
> > -		return NULL;
> > -	}
> > +	offset = obj_idx * class->size;
> 
> so we already know the `offset' before we call objidx_to_page_and_offset(),
> thus we can drop `struct size_class *class' and `obj_idx', and pass
> `long obj_offset'  (which is `obj_idx * class->size') instead, right?
> 
> we also _may be_ can return `cursor' from the function.
> 
> static struct page *objidx_to_page_and_offset(struct page *first_page,
> 					unsigned long obj_offset,
> 					unsigned long *offset_in_page);
> 
> this can save ~20 instructions, which is not so terrible for a hot path
> like obj_malloc(). what do you think?
> 
> well, seems that `unsigned long *offset_in_page' can be calculated
> outside of this function too, it's basically
> 
> 	*offset_in_page = (obj_idx * class->size) & ~PAGE_MASK;
> 
> so we don't need to supply it to this function, nor modify it there.
> which can save ~40 instructions on my system. does this sound silly?

Sound smart. :)
At least, we will use it in hot path.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
