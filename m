Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 474CD828DF
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:39:31 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id x3so15386494pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:39:31 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id f90si16085719pff.83.2016.03.14.23.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 23:39:30 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id u190so15299941pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:39:30 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:40:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 11/19] zsmalloc: squeeze freelist into page->mapping
Message-ID: <20160315064053.GF1464@swordfish>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-12-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457681423-26664-12-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On (03/11/16 16:30), Minchan Kim wrote:
> -static void *location_to_obj(struct page *page, unsigned long obj_idx)
> +static void objidx_to_page_and_ofs(struct size_class *class,
> +				struct page *first_page,
> +				unsigned long obj_idx,
> +				struct page **obj_page,
> +				unsigned long *ofs_in_page)

this looks big; 5 params, function "returning" both page and offset...
any chance to split it in two steps, perhaps?

besides, it is more intuitive (at least to me) when 'offset'
shortened to 'offt', not 'ofs'.

	-ss

>  {
> -	unsigned long obj;
> +	int i;
> +	unsigned long ofs;
> +	struct page *cursor;
> +	int nr_page;
>  
> -	if (!page) {
> -		VM_BUG_ON(obj_idx);
> -		return NULL;
> -	}
> +	ofs = obj_idx * class->size;
> +	cursor = first_page;
> +	nr_page = ofs >> PAGE_SHIFT;
>  
> -	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
> -	obj |= ((obj_idx) & OBJ_INDEX_MASK);
> -	obj <<= OBJ_TAG_BITS;
> +	*ofs_in_page = ofs & ~PAGE_MASK;
> +
> +	for (i = 0; i < nr_page; i++)
> +		cursor = get_next_page(cursor);
>  
> -	return (void *)obj;
> +	*obj_page = cursor;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
