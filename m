Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C494A6B026E
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 22:29:05 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so113700766pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 19:29:05 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id g15si13371062pfg.147.2016.01.14.19.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 19:29:05 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id n128so110405868pfn.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 19:29:05 -0800 (PST)
Date: Fri, 15 Jan 2016 12:30:15 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160115033015.GD1993@swordfish>
References: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
 <20160115023518.GA10843@bbox>
 <20160115032712.GC1993@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160115032712.GC1993@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Junil Lee <junil0814.lee@lge.com>, Andrew Morton <akpm@linux-foundation.org>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/15/16 12:27), Sergey Senozhatsky wrote:
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
> object until the class is locked anyway, and migration is happening with
			  UNlocked

> the locked class. extending class->lock scope in zs_free() thus should
> not affect the perfomance. so it'll be either zs_free() is touching the
> object or the migration, not both.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
