Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB7756B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 10:58:41 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so202509772pac.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:58:41 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id r6si2644628pai.159.2016.04.17.07.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 07:58:41 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id hb4so13950416pac.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:58:40 -0700 (PDT)
Date: Mon, 18 Apr 2016 00:56:21 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v3 08/16] zsmalloc: squeeze freelist into page->mapping
Message-ID: <20160417155621.GE575@swordfish>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-9-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459321935-3655-9-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hello,

On (03/30/16 16:12), Minchan Kim wrote:
[..]
> +static void objidx_to_page_and_offset(struct size_class *class,
> +				struct page *first_page,
> +				unsigned long obj_idx,
> +				struct page **obj_page,
> +				unsigned long *offset_in_page)
>  {
> -	unsigned long obj;
> +	int i;
> +	unsigned long offset;
> +	struct page *cursor;
> +	int nr_page;
>  
> -	if (!page) {
> -		VM_BUG_ON(obj_idx);
> -		return NULL;
> -	}
> +	offset = obj_idx * class->size;

so we already know the `offset' before we call objidx_to_page_and_offset(),
thus we can drop `struct size_class *class' and `obj_idx', and pass
`long obj_offset'  (which is `obj_idx * class->size') instead, right?

we also _may be_ can return `cursor' from the function.

static struct page *objidx_to_page_and_offset(struct page *first_page,
					unsigned long obj_offset,
					unsigned long *offset_in_page);

this can save ~20 instructions, which is not so terrible for a hot path
like obj_malloc(). what do you think?

well, seems that `unsigned long *offset_in_page' can be calculated
outside of this function too, it's basically

	*offset_in_page = (obj_idx * class->size) & ~PAGE_MASK;

so we don't need to supply it to this function, nor modify it there.
which can save ~40 instructions on my system. does this sound silly?

	-ss

> +	cursor = first_page;
> +	nr_page = offset >> PAGE_SHIFT;
>  
> -	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
> -	obj |= ((obj_idx) & OBJ_INDEX_MASK);
> -	obj <<= OBJ_TAG_BITS;
> +	*offset_in_page = offset & ~PAGE_MASK;
> +
> +	for (i = 0; i < nr_page; i++)
> +		cursor = get_next_page(cursor);
>  
> -	return (void *)obj;
> +	*obj_page = cursor;
>  }

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
