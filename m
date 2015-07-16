Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B2A5A2802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:12:38 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so33569174pdj.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:12:38 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id se6si9957442pbc.119.2015.07.15.17.12.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:12:37 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so33506516pdb.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:12:37 -0700 (PDT)
Date: Thu, 16 Jul 2015 09:13:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: use class->pages_per_zspage
Message-ID: <20150716001310.GC3970@swordfish>
References: <1437003764-2968-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437003764-2968-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (07/16/15 08:42), Minchan Kim wrote:
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 27b9661c8fa6..154a30e9c8a8 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1711,7 +1711,7 @@ static unsigned long zs_can_compact(struct size_class *class)
>  	obj_wasted /= get_maxobj_per_zspage(class->size,
>  			class->pages_per_zspage);
>  
> -	return obj_wasted * get_pages_per_zspage(class->size);
> +	return obj_wasted * class->pages_per_zspage;
>  }
>  
>  static void __zs_compact(struct zs_pool *pool, struct size_class *class)

[resending, not sure that my previous reply was delivered. connectivity
problems on my side]


plus __zs_compact():

@@ -1761,8 +1761,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 
                putback_zspage(pool, class, dst_page);
                if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
-                       pool->stats.pages_compacted +=
-                               get_pages_per_zspage(class->size);
+                       pool->stats.pages_compacted += class->pages_per_zspage;
                spin_unlock(&class->lock);
                cond_resched();
                spin_lock(&class->lock);

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
