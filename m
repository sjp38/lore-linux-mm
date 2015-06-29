Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 160096B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 19:36:03 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so125154168pdj.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 16:36:02 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id o8si66850089pdp.62.2015.06.29.16.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 16:36:02 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so111826972pac.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 16:36:01 -0700 (PDT)
Date: Tue, 30 Jun 2015 08:36:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv3 7/7] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150629233630.GA7301@swordfish>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150629070711.GD13179@bbox>
 <20150629085744.GA549@swordfish>
 <20150629133956.GA15331@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150629133956.GA15331@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/29/15 22:39), Minchan Kim wrote:
> Hi Sergey,
> 
> Sorry for too late reply.
> 

Hello Minchan,

Sure, no problem.


Will send out a new patchset later today. Thanks.

	-ss

> On Mon, Jun 29, 2015 at 05:57:44PM +0900, Sergey Senozhatsky wrote:
> > Hello,
> > 
> > thanks for review.
> > 
> > On (06/29/15 16:07), Minchan Kim wrote:
> > [..]
> > > >  			if (!migrate_zspage(pool, class, &cc))
> > > > -				break;
> > > > +				goto out;
> > > 
> > > It should retry with another target_page instead of going out.
> > 
> > yep.
> > 
> > [..]
> > > > +static unsigned long zs_shrinker_scan(struct shrinker *shrinker,
> > > > +		struct shrink_control *sc)
> > > > +{
> > [..]
> > > 
> > > Returns migrated object count.
> > > 
> > [..]
> > > > +static unsigned long zs_shrinker_count(struct shrinker *shrinker,
> > > > +		struct shrink_control *sc)
> > > > +{
> > [..]
> > > 
> > > But it returns wasted_obj / max_obj_per_zspage?
> > > 
> > 
> > Good catch.
> > So,  __zs_compact() and zs_shrinker_count() are ok. Returning
> > "wasted_obj / max_obj_per_zspage" from zs_can_compact() makes
> > sense there. The only place is zs_shrinker_scan()->zs_compact().
> 
> I want to make zs_can_compact return freeable page unit.
> 
> ie,
> 
>         return obj_wasted * class->pages_per_zspage;
>   
> and let's make __zs_compact returns the number of freed pages.
> 
> IOW, I like your (c).
> 
> > 
> > Hm, I can think of:
> > 
> > (a) We can change zs_compact() to return the total number of
> > freed zspages. That will not really change a user visible
> > interface. We export (fwiw) the number of compacted objects
> > in mm_stat. Basically, this is internal zsmalloc() counter and
> > no user space program can ever do anything with that data. From
> > that prospective we will just replace one senseless number with
> > another (equally meaningless) one.
> > 
> > 
> > (b) replace zs_compact() call in zs_shrinker_scan() with a class loop
> > 
> > 1764         int i;
> > 1765         unsigned long nr_migrated = 0;
> > 1766         struct size_class *class;
> > 1767
> > 1768         for (i = zs_size_classes - 1; i >= 0; i--) {
> > 1769                 class = pool->size_class[i];
> > 1770                 if (!class)
> > 1771                         continue;
> > 1772                 if (class->index != i)
> > 1773                         continue;
> > 1774                 nr_migrated += __zs_compact(pool, class);
> > 1775         }
> > 1776
> > 1777         return nr_migrated;
> > 
> > But on every iteration increment nr_migrated with
> > 		"nr_migrated += just_migrated / max_obj_per_zspage"
> > 
> > (which will be unnecessary if zs_compact() will return the number of freed
> > zspages).
> > 
> > So, (b) is mostly fine, except that we already have several pool->size_class
> > loops, with same `if (!class)' and `if (class->index...)' checks; and it
> > asks for some sort of refactoring or... a tricky for_each_class() define.
> > 
> > 
> > In both cases, however, we don't tell anything valuable to user space.
> > Thus,
> > 
> > (c) Return from zs_compact() the number of pages (PAGE_SIZE) freed.
> > And change compaction to operate in terms of pages (PAGE_SIZE). At
> > least mm_stat::compacted will turn into something useful for user
> > space.
> 
> Yes.
> 
> Thanks.
> 
> > 
> > 	-ss
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
