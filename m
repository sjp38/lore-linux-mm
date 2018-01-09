Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB5216B025E
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 06:01:45 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t65so10299505pfe.22
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 03:01:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11sor1886261plq.123.2018.01.09.03.01.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 03:01:44 -0800 (PST)
Date: Tue, 9 Jan 2018 03:01:41 -0800
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH] zswap: only save zswap header if zpool is shrinkable
Message-ID: <20180109110141.GA91365@google.com>
References: <20180108225101.15790-1-yuzhao@google.com>
 <20180109044817.GB6953@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109044817.GB6953@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 09, 2018 at 01:48:17PM +0900, Sergey Senozhatsky wrote:
> On (01/08/18 14:51), Yu Zhao wrote:
> [..]
> >  int zpool_shrink(struct zpool *zpool, unsigned int pages,
> >  			unsigned int *reclaimed)
> >  {
> > -	return zpool->driver->shrink(zpool->pool, pages, reclaimed);
> > +	return zpool_shrinkable(zpool) ?
> > +	       zpool->driver->shrink(zpool->pool, pages, reclaimed) : -EINVAL;
> >  }
> >  
> >  /**
> > @@ -355,6 +356,20 @@ u64 zpool_get_total_size(struct zpool *zpool)
> >  	return zpool->driver->total_size(zpool->pool);
> >  }
> >  
> > +/**
> > + * zpool_shrinkable() - Test if zpool is shrinkable
> > + * @pool	The zpool to test
> > + *
> > + * Zpool is only shrinkable when it's created with struct
> > + * zpool_ops.evict and its driver implements struct zpool_driver.shrink.
> > + *
> > + * Returns: true if shrinkable; false otherwise.
> > + */
> > +bool zpool_shrinkable(struct zpool *zpool)
> > +{
> > +	return zpool->ops && zpool->ops->evict && zpool->driver->shrink;
> > +}
> 
> just a side note,
> it might be a bit confusing and maybe there is a better
> name for it. zsmalloc is shrinkable (we register a shrinker
> callback), but not in the way zpool defines it.

Thanks. Do zpool_evictable() and zpool->driver->evict make more sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
