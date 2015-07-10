Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB836B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 22:29:44 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so43566988pdr.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 19:29:44 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id vw7si11341362pbc.193.2015.07.09.19.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 19:29:43 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so43566738pdr.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 19:29:43 -0700 (PDT)
Date: Fri, 10 Jul 2015 11:29:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Message-ID: <20150710022910.GA18266@blaptop>
References: <1436491929-6617-1-git-send-email-minchan@kernel.org>
 <20150710015828.GA692@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710015828.GA692@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Sergey,

On Fri, Jul 10, 2015 at 10:58:28AM +0900, Sergey Senozhatsky wrote:
> On (07/10/15 10:32), Minchan Kim wrote:
> > There is no reason to prevent select ZS_ALMOST_FULL as migration
> > source if we cannot find source from ZS_ALMOST_EMPTY.
> > 
> > With this patch, zs_can_compact will return more exact result.
> > 
> 
> wouldn't that be too aggresive?
> 
> drainig 'only ZS_ALMOST_EMPTY classes' sounds safer than draining
> 'ZS_ALMOST_EMPTY and ZS_ALMOST_FULL clases'. you seemed to be worried
> that compaction can leave no unused objects in classes, which will
> result in zspage allocation happening right after compaction. it looks
> like here the chances to cause zspage allocation are even higher. don't
> you think so?

Good question.

My worry was failure of order-0 page allocation in zram-swap path
when memory presssure is really heavy but I didn't insist to you
from sometime. The reason I changed my mind was

1. It's almost dead system if there is no order-0 page
2. If old might be working well, it's not our design, just luck.


> 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/zsmalloc.c |   19 ++++++++++++-------
> >  1 file changed, 12 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 8c78bcb..7bd7dde 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1687,12 +1687,20 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
> >  static struct page *isolate_source_page(struct size_class *class)
> >  {
> >  	struct page *page;
> > +	int i;
> > +	bool found = false;
> >  
> > -	page = class->fullness_list[ZS_ALMOST_EMPTY];
> > -	if (page)
> > -		remove_zspage(page, class, ZS_ALMOST_EMPTY);
> > +	for (i = ZS_ALMOST_EMPTY; i >= ZS_ALMOST_FULL; i--) {
> > +		page = class->fullness_list[i];
> > +		if (!page)
> > +			continue;
> >  
> > -	return page;
> > +		remove_zspage(page, class, i);
> > +		found = true;
> > +		break;
> > +	}
> > +
> > +	return found ? page : NULL;
> >  }
> >  
> >  /*
> > @@ -1706,9 +1714,6 @@ static unsigned long zs_can_compact(struct size_class *class)
> >  {
> >  	unsigned long obj_wasted;
> >  
> > -	if (!zs_stat_get(class, CLASS_ALMOST_EMPTY))
> > -		return 0;
> > -
> 
> well, you asked to add this check like a week or two ago (it's not even
> in -next yet) and now you remove it.

The reason I wanted to check CLASS_ALMOST_EMPTY is to make zs_can_compact exact.
But with this patch, we can achieve it without above.

> 
> >  	obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
> >  		zs_stat_get(class, OBJ_USED);
> >  
> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
