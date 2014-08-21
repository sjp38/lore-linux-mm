Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 73BBE6B0037
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 19:18:25 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so15592480pab.29
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 16:18:25 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ui8si38354579pab.67.2014.08.21.16.18.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 16:18:24 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so15270104pab.6
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 16:18:24 -0700 (PDT)
Date: Thu, 21 Aug 2014 23:23:19 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 2/4] zsmalloc: change return value unit of
 zs_get_total_size_bytes
Message-ID: <20140821232319.GG10703@gmail.com>
References: <1408580838-29236-1-git-send-email-minchan@kernel.org>
 <1408580838-29236-3-git-send-email-minchan@kernel.org>
 <CALZtONBuZOORHAF0UHEZM7Aybuoesg3fyjnu9ACj_F7O5G35Og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONBuZOORHAF0UHEZM7Aybuoesg3fyjnu9ACj_F7O5G35Og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, David Horner <ds2horner@gmail.com>

On Thu, Aug 21, 2014 at 02:53:57PM -0400, Dan Streetman wrote:
> On Wed, Aug 20, 2014 at 8:27 PM, Minchan Kim <minchan@kernel.org> wrote:
> > zs_get_total_size_bytes returns a amount of memory zsmalloc
> > consumed with *byte unit* but zsmalloc operates *page unit*
> > rather than byte unit so let's change the API so benefit
> > we could get is that reduce unnecessary overhead
> > (ie, change page unit with byte unit) in zsmalloc.
> >
> > Now, zswap can rollback to zswap_pool_pages.
> > Over to zswap guys ;-)
> 
> We could change zpool/zswap over to total pages instead of total
> bytes, since both zbud and zsmalloc now report size in pages.  The
> only downside would be if either changed later to not use only whole
> pages (or if they start using huge pages for storage...), but for what
> they do that seems unlikely.  After this patch is finalized I can
> write up a quick patch unless Seth disagrees (or already has a patch
> :)
> 
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/block/zram/zram_drv.c |  4 ++--
> >  include/linux/zsmalloc.h      |  2 +-
> >  mm/zsmalloc.c                 | 10 +++++-----
> >  3 files changed, 8 insertions(+), 8 deletions(-)
> >
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index d00831c3d731..302dd37bcea3 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -103,10 +103,10 @@ static ssize_t mem_used_total_show(struct device *dev,
> >
> >         down_read(&zram->init_lock);
> >         if (init_done(zram))
> > -               val = zs_get_total_size_bytes(meta->mem_pool);
> > +               val = zs_get_total_size(meta->mem_pool);
> >         up_read(&zram->init_lock);
> >
> > -       return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> > +       return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
> >  }
> >
> >  static ssize_t max_comp_streams_show(struct device *dev,
> > diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> > index e44d634e7fb7..105b56e45d23 100644
> > --- a/include/linux/zsmalloc.h
> > +++ b/include/linux/zsmalloc.h
> > @@ -46,6 +46,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
> >                         enum zs_mapmode mm);
> >  void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
> >
> > -u64 zs_get_total_size_bytes(struct zs_pool *pool);
> > +unsigned long zs_get_total_size(struct zs_pool *pool);
> 
> minor naming suggestion, but since the name is changing anyway,
> "zs_get_total_size" implies to me the units are bytes, would
> "zs_get_total_pages" be clearer that it's returning size in # of
> pages, not bytes?

It's better. Will change.
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
