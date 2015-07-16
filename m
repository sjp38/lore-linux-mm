Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B6D1C2802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:11:07 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so32517639pac.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:11:07 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id bq4si9927551pbc.180.2015.07.15.17.11.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:11:07 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so34593170pdb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:11:06 -0700 (PDT)
Date: Thu, 16 Jul 2015 09:11:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: use class->pages_per_zspage
Message-ID: <20150716001112.GF988@bgram>
References: <1437003764-2968-1-git-send-email-minchan@kernel.org>
 <20150716000225.GB3970@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716000225.GB3970@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 16, 2015 at 09:02:25AM +0900, Sergey Senozhatsky wrote:
> On (07/16/15 08:42), Minchan Kim wrote:
> > There is no need to recalcurate pages_per_zspage in runtime.
> > Just use class->pages_per_zspage to avoid unnecessary runtime
> > overhead.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/zsmalloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 27b9661c8fa6..154a30e9c8a8 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1711,7 +1711,7 @@ static unsigned long zs_can_compact(struct size_class *class)
> >  	obj_wasted /= get_maxobj_per_zspage(class->size,
> >  			class->pages_per_zspage);
> >  
> > -	return obj_wasted * get_pages_per_zspage(class->size);
> > +	return obj_wasted * class->pages_per_zspage;
> >  }
> 
> plus __zs_compact():
> 
> @@ -1761,8 +1761,7 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  
>                 putback_zspage(pool, class, dst_page);
>                 if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
> -                       pool->stats.pages_compacted +=
> -                               get_pages_per_zspage(class->size);
> +                       pool->stats.pages_compacted += class->pages_per_zspage;
>                 spin_unlock(&class->lock);
>                 cond_resched();
>                 spin_lock(&class->lock);
> 
> 	-ss

Thanks. I sent a v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
