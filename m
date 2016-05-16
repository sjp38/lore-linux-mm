Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0188D828E1
	for <linux-mm@kvack.org>; Sun, 15 May 2016 22:14:27 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so234359425pab.3
        for <linux-mm@kvack.org>; Sun, 15 May 2016 19:14:26 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id n11si39458270pfa.84.2016.05.15.19.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 May 2016 19:14:26 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id xm6so2590622pab.3
        for <linux-mm@kvack.org>; Sun, 15 May 2016 19:14:26 -0700 (PDT)
Date: Mon, 16 May 2016 11:14:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 07/12] zsmalloc: factor page chain functionality out
Message-ID: <20160516021420.GC504@swordfish>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-8-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462760433-32357-8-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (05/09/16 11:20), Minchan Kim wrote:
> For page migration, we need to create page chain of zspage dynamically
> so this patch factors it out from alloc_zspage.
> 
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

[..]
> +		page = alloc_page(flags);
> +		if (!page) {
> +			while (--i >= 0)
> +				__free_page(pages[i]);

				put_page() ?

a minor nit, put_page() here probably will be in alignment
with __free_zspage(), which does put_page().

	-ss

> +			return NULL;
> +		}
> +		pages[i] = page;
>  	}
>  
> +	create_page_chain(pages, class->pages_per_zspage);
> +	first_page = pages[0];
> +	init_zspage(class, first_page);
> +
>  	return first_page;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
