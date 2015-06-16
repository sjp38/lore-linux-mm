Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 042EA6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 10:41:50 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so14134160pac.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 07:41:49 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id yf2si1641109pbb.223.2015.06.16.07.41.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 07:41:49 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so15932656pdj.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 07:41:49 -0700 (PDT)
Date: Tue, 16 Jun 2015 23:41:06 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCHv2 5/8] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150616144106.GD20596@swordfish>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-6-git-send-email-sergey.senozhatsky@gmail.com>
 <20150616141914.GC31387@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150616141914.GC31387@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/16/15 23:19), Minchan Kim wrote:
> On Fri, Jun 05, 2015 at 09:03:55PM +0900, Sergey Senozhatsky wrote:
> > This function checks if class compaction will free any pages.
> > Rephrasing -- do we have enough unused objects to form at least
> > one ZS_EMPTY page and free it. It aborts compaction if class
> > compaction will not result in any (further) savings.
> > 
> > EXAMPLE (this debug output is not part of this patch set):
> > 
> > -- class size
> > -- number of allocated objects
> > -- number of used objects,
> > -- estimated number of pages that will be freed
> > 
> > [..]
> >  class-3072 objs:24652 inuse:24628 maxobjs-per-page:4  pages-tofree:6
> 
> Please use clear term. We have been used zspage as cluster of pages.
> 
>                                      maxobjs-per-zspage:4
> 

OK, will correct.

class size
sats[OBJ_ALLOCATED]
stats[OBJ_USED]
get_maxobj_per_zspage()
+pages-per-zspage
zspages-to-free

> And say what is pages-per-zspage for each class.
> then, write how you calculate it for easy reviewing.
> 
> * class-3072
> * pages-per-zspage: 3
> * maxobjs-per-zspage = 4
> 
> In your example, allocated obj = 24652 and inuse obj = 24628
> so 24652 - 24628 = 24 = 4(ie, maxobjs-per-zspage) * 6
> so we can save 6 zspage. A zspage includes 3 pages so we can
> save 3 * 6 = 18 pages via compaction.
> 
> 

[..]

> > + * Make sure that we actually can compact this class,
> > + * IOW if migration will empty at least one page.
> 
>                             free at least one zspage

OK.

> > + *
> > + * Should be called under class->lock
> > + */
> > +static unsigned long zs_can_compact(struct size_class *class)
> > +{
> > +	/*
> > +	 * Calculate how many unused allocated objects we
> > +	 * have and see if we can free any zspages. Otherwise,
> > +	 * compaction can just move objects back and forth w/o
> > +	 * any memory gain.
> > +	 */
> > +	unsigned long obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
> > +		zs_stat_get(class, OBJ_USED);
> > +
> > +	obj_wasted /= get_maxobj_per_zspage(class->size,
> > +			class->pages_per_zspage);
> 
> I don't think we need division and make it simple.
> 
>         return obj_wasted >= get_maxobj_per_zspage

I use this number later for the shrinker, as a shrinker.count_objects()
return value (total number of zsages that can be freed).


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
