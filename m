Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D17356B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 10:35:47 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so15826421pdj.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 07:35:47 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id k16si1618451pdm.244.2015.06.16.07.35.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 07:35:47 -0700 (PDT)
Received: by padev16 with SMTP id ev16so14029197pad.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 07:35:46 -0700 (PDT)
Date: Tue, 16 Jun 2015 23:35:03 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCHv2 3/8] zsmalloc: lower ZS_ALMOST_FULL waterline
Message-ID: <20150616143503.GC20596@swordfish>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150616133708.GB31387@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150616133708.GB31387@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/16/15 22:37), Minchan Kim wrote:
> On Fri, Jun 05, 2015 at 09:03:53PM +0900, Sergey Senozhatsky wrote:
> > get_fullness_group() considers 3/4 full pages as almost empty.
> > That, unfortunately, marks as ALMOST_EMPTY pages that we would
> > probably like to keep in ALMOST_FULL lists.
> > 
> > ALMOST_EMPTY:
> > [..]
> >   inuse: 3 max_objects: 4
> >   inuse: 5 max_objects: 7
> >   inuse: 5 max_objects: 7
> >   inuse: 2 max_objects: 3
> > [..]
> > 
> > For "inuse: 5 max_objexts: 7" ALMOST_EMPTY page, for example,
> > it'll take 2 obj_malloc to make the page FULL and 5 obj_free to
> > make it EMPTY. Compaction selects ALMOST_EMPTY pages as source
> > pages, which can result in extra object moves.
> > 
> > In other words, from compaction point of view, it makes more
> > sense to fill this page, rather than drain it.
> > 
> > Decrease ALMOST_FULL waterline to 2/3 of max capacity; which is,
> > of course, still imperfect, but can shorten compaction
> > execution time.
> 
> However, at worst case, once compaction is done, it could remain
> 33% fragment space while it can remain 25% fragment space in current.
> Maybe 25% wouldn't enough so we might need to scan ZS_ALMOST_FULL as
> source in future. Anyway, compaction is really slow path now so
> I prefer saving memory space by reduce internal fragmentation to
> performance caused more copy of objects.
> 

Well, agree. I think we can drop this one from the series for now.
It's very hard to support this patch with any numbers, etc. because
it depends on things that are out of zram/zsmalloc control -- IO and
data patterns.

(opposing this patch is also very hard, due to exactly same reason).

	-ss

> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > ---
> >  mm/zsmalloc.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index cd37bda..b94e281 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -198,7 +198,7 @@ static int zs_size_classes;
> >   *
> >   * (see: fix_fullness_group())
> >   */
> > -static const int fullness_threshold_frac = 4;
> > +static const int fullness_threshold_frac = 3;
> >  
> >  struct size_class {
> >  	/*
> > @@ -633,7 +633,7 @@ static enum fullness_group get_fullness_group(struct page *page)
> >  		fg = ZS_EMPTY;
> >  	else if (inuse == max_objects)
> >  		fg = ZS_FULL;
> > -	else if (inuse <= 3 * max_objects / fullness_threshold_frac)
> > +	else if (inuse <= 2 * max_objects / fullness_threshold_frac)
> >  		fg = ZS_ALMOST_EMPTY;
> >  	else
> >  		fg = ZS_ALMOST_FULL;
> > -- 
> > 2.4.2.387.gf86f31a
> > 
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
