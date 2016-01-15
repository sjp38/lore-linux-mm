Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C54F1828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 23:47:08 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so111413091pfn.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 20:47:08 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id 21si13845546pfl.36.2016.01.14.20.47.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 20:47:07 -0800 (PST)
Date: Fri, 15 Jan 2016 13:49:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160115044916.GB11203@bbox>
References: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
 <20160115023518.GA10843@bbox>
 <20160115032712.GC1993@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160115032712.GC1993@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Junil Lee <junil0814.lee@lge.com>, Andrew Morton <akpm@linux-foundation.org>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 15, 2016 at 12:27:12PM +0900, Sergey Senozhatsky wrote:
> Cc Andrew,
> 
> On (01/15/16 11:35), Minchan Kim wrote:
> [..]
> > > Signed-off-by: Junil Lee <junil0814.lee@lge.com>
> > > ---
> > >  mm/zsmalloc.c | 1 +
> > >  1 file changed, 1 insertion(+)
> > > 
> > > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > > index e7414ce..bb459ef 100644
> > > --- a/mm/zsmalloc.c
> > > +++ b/mm/zsmalloc.c
> > > @@ -1635,6 +1635,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
> > >  		free_obj = obj_malloc(d_page, class, handle);
> > >  		zs_object_copy(free_obj, used_obj, class);
> > >  		index++;
> > > +		free_obj |= BIT(HANDLE_PIN_BIT);
> > >  		record_obj(handle, free_obj);
> > 
> > I think record_obj should store free_obj to *handle with masking off least bit.
> > IOW, how about this?
> > 
> > record_obj(handle, obj)
> > {
> >         *(unsigned long)handle = obj & ~(1<<HANDLE_PIN_BIT);
> > }
> 
> [just a wild idea]
> 
> or zs_free() can take spin_lock(&class->lock) earlier, it cannot free the

Earlier? What do you mean? For getting right class, we should get a stable
handle so we couldn't get class lock first than handle lock.
If I misunderstand, please elaborate a bit.


> object until the class is locked anyway, and migration is happening with
> the locked class. extending class->lock scope in zs_free() thus should
> not affect the perfomance. so it'll be either zs_free() is touching the
> object or the migration, not both.
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
