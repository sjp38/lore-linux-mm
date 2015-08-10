Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 826C46B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:05:49 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so101295037pab.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:05:49 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id d5si31844213pde.239.2015.08.10.01.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 01:05:48 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so21696339pac.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:05:48 -0700 (PDT)
Date: Mon, 10 Aug 2015 17:06:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC zsmalloc 1/4] zsmalloc: keep max_object in size_class
Message-ID: <20150810080624.GA600@swordfish>
References: <1439190743-13933-1-git-send-email-minchan@kernel.org>
 <1439190743-13933-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439190743-13933-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, gioh.kim@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (08/10/15 16:12), Minchan Kim wrote:
> Every zspage in a size_class has same max_objects so we could
> move it to a size_class.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/zsmalloc.c | 22 ++++++++++------------
>  1 file changed, 10 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index f135b1b..491491a 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -33,8 +33,6 @@
>   *	page->freelist: points to the first free object in zspage.
>   *		Free objects are linked together using in-place
>   *		metadata.
> - *	page->objects: maximum number of objects we can store in this
> - *		zspage (class->zspage_order * PAGE_SIZE / class->size)
>   *	page->lru: links together first pages of various zspages.
>   *		Basically forming list of zspages in a fullness group.
>   *	page->mapping: class index and fullness group of the zspage
> @@ -206,6 +204,7 @@ struct size_class {
>  	 * of ZS_ALIGN.
>  	 */
>  	int size;
> +	int max_objects;

may be change it to objs_per_zspage or something similar? we have
class->pages_per_zspage, so class->objs_per_zspage sounds ok.
otherwise, it's class->max_objects, which gives a false feeling
that there is class's limit on objects, not zspages's.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
