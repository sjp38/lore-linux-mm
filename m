Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 02BF16B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 10:48:54 -0400 (EDT)
Received: by obbop1 with SMTP id op1so130116557obb.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:48:53 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id fg3si35048630pac.187.2015.07.07.07.48.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 07:48:53 -0700 (PDT)
Received: by pddu5 with SMTP id u5so39601019pdd.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:48:53 -0700 (PDT)
Date: Tue, 7 Jul 2015 23:48:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 5/7] zsmalloc/zram: introduce zs_pool_stats api
Message-ID: <20150707144845.GB23003@blaptop>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-6-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707133638.GB3898@blaptop>
 <20150707143256.GB1450@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707143256.GB1450@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, Jul 07, 2015 at 11:32:56PM +0900, Sergey Senozhatsky wrote:
> On (07/07/15 22:36), Minchan Kim wrote:
> [..]
> > >  	struct zram *zram = dev_to_zram(dev);
> > > +	struct zs_pool_stats pool_stats = {0};
> > 
> > Does it work even if first member of the structure is non-scalar?
> > Personally I prefer memset for initliazation.
> > I believe modern compiler would optimize that quite well.
> 
> zs_pool_stats contains only one member now, so I didn't bother.
> 
> [..]
> > >  struct zs_pool {
> > > -	char *name;
> > > +	char			*name;
> > 
> > huge tab?
> > 
> > >  
> > > -	struct size_class **size_class;
> > > -	struct kmem_cache *handle_cachep;
> > > +	struct size_class	**size_class;
> > > +	struct kmem_cache	*handle_cachep;
> > 
> > tab?
> > tab?
> > 
> > >  
> > > -	gfp_t flags;	/* allocation flags used when growing pool */
> > > -	atomic_long_t pages_allocated;
> > 
> > Why changes comment position?
> 
> Because otherwise it breaks 80-cols rule.
> 
> > > +	/* Allocation flags used when growing pool */
> > > +	gfp_t			flags;
> > > +	atomic_long_t		pages_allocated;
> > >  
> > 
> > Why blank line?
> 
> To make it more readable? Separating logically different
> struct members. That's why the original code contains blank
> lines between `char *name' and `struct size_class **size_class;
> struct kmem_cache *handle_cachep;` and so on.
> 
> I see no issue.
> 

Okay, I am not against aboves you mentioned.
But please don't squeeze cleanup patch into core patchset from next time.
It really hate to review and make confused git-blame.

> 
> > > +	struct zs_pool_stats	stats;
> > >  #ifdef CONFIG_ZSMALLOC_STAT
> > > -	struct dentry *stat_dentry;
> > > +	struct dentry		*stat_dentry;
> > 
> > Tab.
> 
> Well, I see no issue with aligned struct members. Looks less
> hairy and less messy than the original one.

But this is that I'm strongly against with you.
It depends on the person coding style.

I have been used white space.
As well, when I look at current code under mm which I'm getting used,
almost everything use just white space.

> 
> clean:
> 
> struct zs_pool {
>         char                    *name;
> 
>         struct size_class       **size_class;
>         struct kmem_cache       *handle_cachep;
> 
>         /* Allocation flags used when growing pool */
>         gfp_t                   flags;
>         atomic_long_t           pages_allocated;
> 
>         struct zs_pool_stats    stats;
> 
>         /* Compact classes */
>         struct shrinker         shrinker;
>         bool                    shrinker_enabled;
> #ifdef CONFIG_ZSMALLOC_STAT
>         struct dentry           *stat_dentry;
> #endif
> };
> 
> 
> 
> dirty:

Never dirty. It's more readable.

> 
> struct zs_pool {
>         char *name;
> 
>         struct size_class **size_class;
>         struct kmem_cache *handle_cachep;
> 
>         gfp_t flags;    /* allocation flags used when growing pool */
>         atomic_long_t pages_allocated;
> 
> #ifdef CONFIG_ZSMALLOC_STAT
>         struct dentry *stat_dentry;
> #endif
> };
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
