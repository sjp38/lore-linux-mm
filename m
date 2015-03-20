Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 186E26B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 01:55:54 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so98838904pdb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 22:55:53 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id pc2si7259132pac.137.2015.03.19.22.55.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 22:55:53 -0700 (PDT)
Received: by pdbni2 with SMTP id ni2so98838651pdb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 22:55:53 -0700 (PDT)
Date: Fri, 20 Mar 2015 14:55:59 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: mm/zsmalloc.c: count in handle's size when calculating
 pages_per_zspage
Message-ID: <20150320055559.GA23604@swordfish>
References: <430707086.362221426765159948.JavaMail.weblogic@epmlwas05d>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <430707086.362221426765159948.JavaMail.weblogic@epmlwas05d>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghao Xie <yinghao.xie@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, sergey.senozhatsky@gmail.com


Hello,

sorry, I've a question.

On (03/19/15 11:39), Yinghao Xie wrote:
> @@ -1426,11 +1430,6 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>  	/* extra space in chunk to keep the handle */
>  	size += ZS_HANDLE_SIZE;
>  	class = pool->size_class[get_size_class_index(size)];
> -	/* In huge class size, we store the handle into first_page->private */
> -	if (class->huge) {
> -		size -= ZS_HANDLE_SIZE;
> -		class = pool->size_class[get_size_class_index(size)];
> -	}

if huge class uses page->private to store a handle, shouldn't we pass
"size -= ZS_HANDLE_SIZE" to get_size_class_index() ?

	-ss

>  	spin_lock(&class->lock);
>  	first_page = find_get_zspage(class);
> @@ -1856,9 +1855,7 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
>  		struct size_class *class;
>  
>  		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
> -		if (size > ZS_MAX_ALLOC_SIZE)
> -			size = ZS_MAX_ALLOC_SIZE;
> -		pages_per_zspage = get_pages_per_zspage(size);
> +		pages_per_zspage = get_pages_per_zspage(size + ZS_HANDLE_SIZE);
>  
>  		/*
>  		 * size_class is used for normal zsmalloc operation such

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
