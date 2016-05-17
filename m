Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF626B0005
	for <linux-mm@kvack.org>; Mon, 16 May 2016 21:14:17 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 190so8661888iow.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:14:17 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id yg4si543671igb.64.2016.05.16.18.14.16
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 18:14:16 -0700 (PDT)
Date: Tue, 17 May 2016 10:14:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 08/12] zsmalloc: introduce zspage structure
Message-ID: <20160517011418.GB31335@bbox>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-9-git-send-email-minchan@kernel.org>
 <20160516030941.GD504@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160516030941.GD504@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, May 16, 2016 at 12:09:41PM +0900, Sergey Senozhatsky wrote:
> On (05/09/16 11:20), Minchan Kim wrote:
> > We have squeezed meta data of zspage into first page's descriptor.
> > So, to get meta data from subpage, we should get first page first
> > of all. But it makes trouble to implment page migration feature
> > of zsmalloc because any place where to get first page from subpage
> > can be raced with first page migration. IOW, first page it got
> > could be stale. For preventing it, I have tried several approahces
> > but it made code complicated so finally, I concluded to separate
> > metadata from first page. Of course, it consumes more memory. IOW,
> > 16bytes per zspage on 32bit at the moment. It means we lost 1%
> > at *worst case*(40B/4096B) which is not bad I think at the cost of
> > maintenance.
> > 
> > Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> [..]
> > @@ -153,8 +138,6 @@
> >  enum fullness_group {
> >  	ZS_ALMOST_FULL,
> >  	ZS_ALMOST_EMPTY,
> > -	_ZS_NR_FULLNESS_GROUPS,
> > -
> >  	ZS_EMPTY,
> >  	ZS_FULL
> >  };
> > @@ -203,7 +186,7 @@ static const int fullness_threshold_frac = 4;
> >  
> >  struct size_class {
> >  	spinlock_t lock;
> > -	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
> > +	struct list_head fullness_list[2];
> 
> seems that it also has some cleaup bits in it.
> 
> [..]
> > -static int create_handle_cache(struct zs_pool *pool)
> > +static int create_cache(struct zs_pool *pool)
> >  {
> >  	pool->handle_cachep = kmem_cache_create("zs_handle", ZS_HANDLE_SIZE,
> >  					0, 0, NULL);
> > -	return pool->handle_cachep ? 0 : 1;
> > +	if (!pool->handle_cachep)
> > +		return 1;
> > +
> > +	pool->zspage_cachep = kmem_cache_create("zspage", sizeof(struct zspage),
> > +					0, 0, NULL);
> > +	if (!pool->zspage_cachep) {
> > +		kmem_cache_destroy(pool->handle_cachep);
> 		^^^^^
> 
> do you need to NULL a pool->handle_cachep here?

Thanks, Will fix.

> 
> zs_create_pool()
> 	if (create_cache() == 1) {
> 			pool->zspage_cachep NULL
> 			pool->handle_cachep !NULL   already freed -> kmem_cache_destroy()
> 			return 1;
> 		goto err
> 	}
> err:
> 	zs_destroy_pool()
> 		destroy_cache() {
> 			kmem_cache_destroy(pool->handle_cachep);  !NULL and freed
> 			kmem_cache_destroy(pool->zspage_cachep);  NULL ok
> 		}
> 
> 
> can we also switch create_cache() to errnos? I just like a bit
> better
> 		return -ENOMEM;
> 	else
> 		return 0;
> 
> than
> 
> 		return 1;
> 	else
> 		return 0;
> 

Hmm, of course, I can do it easily.
But zs_create_pool returns NULL without error propagation from sub
functions so I don't see any gain from returning errno from
create_cache. I don't mean I hate it but just need a justificaion
to persuade grumpy me.

> 
> > @@ -997,44 +951,38 @@ static void init_zspage(struct size_class *class, struct page *first_page)
> >  		off %= PAGE_SIZE;
> >  	}
> >  
> > -	set_freeobj(first_page, (unsigned long)location_to_obj(first_page, 0));
> > +	set_freeobj(zspage,
> > +		(unsigned long)location_to_obj(zspage->first_page, 0));
> 
> 	static unsigned long location_to_obj()
> 
> it's already returning "(unsigned long)", so here and in several other places
> this cast can be dropped.

Yeb.

> 
> [..]
> > +static struct zspage *isolate_zspage(struct size_class *class, bool source)
> >  {
> > +	struct zspage *zspage;
> > +	enum fullness_group fg[2] = {ZS_ALMOST_EMPTY, ZS_ALMOST_FULL};
> > +	if (!source) {
> > +		fg[0] = ZS_ALMOST_FULL;
> > +		fg[1] = ZS_ALMOST_EMPTY;
> > +	}
> > +
> > +	for (i = 0; i < 2; i++) {
> 
> sorry, why not "for (i = ZS_ALMOST_EMPTY; i <= ZS_ALMOST_FULL ..." ?

For source zspage, the policy is to find a fragment object from ZS_ALMOST_EMPTY.
For target zspage, the policy is to find a fragment object from ZS_ALMOST_FULL.

Do I misunderstand your question?

> 
> > +		zspage = list_first_entry_or_null(&class->fullness_list[fg[i]],
> > +							struct zspage, list);
> > +		if (zspage) {
> > +			remove_zspage(class, zspage, fg[i]);
> > +			return zspage;
> >  		}
> >  	}
> >  
> > -	return page;
> > +	return zspage;
> >  }
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
