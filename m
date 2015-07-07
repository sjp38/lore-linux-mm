Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B50B56B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 10:33:45 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so126882114pdb.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:33:45 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id rm15si35023864pac.85.2015.07.07.07.33.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 07:33:44 -0700 (PDT)
Received: by pacws9 with SMTP id ws9so115671628pac.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 07:33:44 -0700 (PDT)
Date: Tue, 7 Jul 2015 23:32:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v6 5/7] zsmalloc/zram: introduce zs_pool_stats api
Message-ID: <20150707143256.GB1450@swordfish>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-6-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707133638.GB3898@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150707133638.GB3898@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/07/15 22:36), Minchan Kim wrote:
[..]
> >  	struct zram *zram = dev_to_zram(dev);
> > +	struct zs_pool_stats pool_stats = {0};
> 
> Does it work even if first member of the structure is non-scalar?
> Personally I prefer memset for initliazation.
> I believe modern compiler would optimize that quite well.

zs_pool_stats contains only one member now, so I didn't bother.

[..]
> >  struct zs_pool {
> > -	char *name;
> > +	char			*name;
> 
> huge tab?
> 
> >  
> > -	struct size_class **size_class;
> > -	struct kmem_cache *handle_cachep;
> > +	struct size_class	**size_class;
> > +	struct kmem_cache	*handle_cachep;
> 
> tab?
> tab?
> 
> >  
> > -	gfp_t flags;	/* allocation flags used when growing pool */
> > -	atomic_long_t pages_allocated;
> 
> Why changes comment position?

Because otherwise it breaks 80-cols rule.

> > +	/* Allocation flags used when growing pool */
> > +	gfp_t			flags;
> > +	atomic_long_t		pages_allocated;
> >  
> 
> Why blank line?

To make it more readable? Separating logically different
struct members. That's why the original code contains blank
lines between `char *name' and `struct size_class **size_class;
struct kmem_cache *handle_cachep;` and so on.

I see no issue.


> > +	struct zs_pool_stats	stats;
> >  #ifdef CONFIG_ZSMALLOC_STAT
> > -	struct dentry *stat_dentry;
> > +	struct dentry		*stat_dentry;
> 
> Tab.

Well, I see no issue with aligned struct members. Looks less
hairy and less messy than the original one.

clean:

struct zs_pool {
        char                    *name;

        struct size_class       **size_class;
        struct kmem_cache       *handle_cachep;

        /* Allocation flags used when growing pool */
        gfp_t                   flags;
        atomic_long_t           pages_allocated;

        struct zs_pool_stats    stats;

        /* Compact classes */
        struct shrinker         shrinker;
        bool                    shrinker_enabled;
#ifdef CONFIG_ZSMALLOC_STAT
        struct dentry           *stat_dentry;
#endif
};



dirty:

struct zs_pool {
        char *name;

        struct size_class **size_class;
        struct kmem_cache *handle_cachep;

        gfp_t flags;    /* allocation flags used when growing pool */
        atomic_long_t pages_allocated;

#ifdef CONFIG_ZSMALLOC_STAT
        struct dentry *stat_dentry;
#endif
};

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
