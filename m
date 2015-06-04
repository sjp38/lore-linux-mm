Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 193F9900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 22:34:00 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so19254851pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 19:33:59 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ds16si3569319pdb.171.2015.06.03.19.33.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 19:33:59 -0700 (PDT)
Received: by padjw17 with SMTP id jw17so19352141pad.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 19:33:59 -0700 (PDT)
Date: Thu, 4 Jun 2015 11:34:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 02/10] zsmalloc: always keep per-class stats
Message-ID: <20150604023423.GC1951@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604021821.GC2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604021821.GC2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/04/15 11:18), Minchan Kim wrote:
> On Sat, May 30, 2015 at 12:05:20AM +0900, Sergey Senozhatsky wrote:
> > always account per-class `zs_size_stat' stats. this data will
> > help us make better decisions during compaction. we are especially
> > interested in OBJ_ALLOCATED and OBJ_USED, which can tell us if
> > class compaction will result in any memory gain.
> > 
> > for instance, we know the number of allocated objects in the class,
> > the number of objects being used (so we also know how many objects
> > are not used) and the number of objects per-page. so we can estimate
> > how many pages compaction can free (pages that will turn into
> > ZS_EMPTY during compaction).
> 
> Fair enough but I need to read further patches to see if we need
> really this at the moment.
> 
> I hope it would be better to write down more detail in cover-letter
> so when I read just [0/0] I realize your goal and approach without
> looking into detail in each patch.
> 

sure, will do later today.
I caught a cold, so I'm a bit slow.

	-ss

> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > ---
> >  mm/zsmalloc.c | 49 ++++++++++++-------------------------------------
> >  1 file changed, 12 insertions(+), 37 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index e615b31..778b8db 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -169,14 +169,12 @@ enum zs_stat_type {
> >  	NR_ZS_STAT_TYPE,
> >  };
> >  
> > -#ifdef CONFIG_ZSMALLOC_STAT
> > -
> > -static struct dentry *zs_stat_root;
> > -
> >  struct zs_size_stat {
> >  	unsigned long objs[NR_ZS_STAT_TYPE];
> >  };
> >  
> > +#ifdef CONFIG_ZSMALLOC_STAT
> > +static struct dentry *zs_stat_root;
> >  #endif
> >  
> >  /*
> > @@ -201,25 +199,21 @@ static int zs_size_classes;
> >  static const int fullness_threshold_frac = 4;
> >  
> >  struct size_class {
> > +	spinlock_t		lock;
> > +	struct page		*fullness_list[_ZS_NR_FULLNESS_GROUPS];
> >  	/*
> >  	 * Size of objects stored in this class. Must be multiple
> >  	 * of ZS_ALIGN.
> >  	 */
> > -	int size;
> > -	unsigned int index;
> > +	int			size;
> > +	unsigned int		index;
> >  
> >  	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> > -	int pages_per_zspage;
> > -	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
> > -	bool huge;
> > -
> > -#ifdef CONFIG_ZSMALLOC_STAT
> > -	struct zs_size_stat stats;
> > -#endif
> > -
> > -	spinlock_t lock;
> > +	int			pages_per_zspage;
> > +	struct zs_size_stat	stats;
> >  
> > -	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
> > +	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
> > +	bool			huge;
> >  };
> >  
> >  /*
> > @@ -439,8 +433,6 @@ static int get_size_class_index(int size)
> >  	return min(zs_size_classes - 1, idx);
> >  }
> >  
> > -#ifdef CONFIG_ZSMALLOC_STAT
> > -
> >  static inline void zs_stat_inc(struct size_class *class,
> >  				enum zs_stat_type type, unsigned long cnt)
> >  {
> > @@ -459,6 +451,8 @@ static inline unsigned long zs_stat_get(struct size_class *class,
> >  	return class->stats.objs[type];
> >  }
> >  
> > +#ifdef CONFIG_ZSMALLOC_STAT
> > +
> >  static int __init zs_stat_init(void)
> >  {
> >  	if (!debugfs_initialized())
> > @@ -574,23 +568,6 @@ static void zs_pool_stat_destroy(struct zs_pool *pool)
> >  }
> >  
> >  #else /* CONFIG_ZSMALLOC_STAT */
> > -
> > -static inline void zs_stat_inc(struct size_class *class,
> > -				enum zs_stat_type type, unsigned long cnt)
> > -{
> > -}
> > -
> > -static inline void zs_stat_dec(struct size_class *class,
> > -				enum zs_stat_type type, unsigned long cnt)
> > -{
> > -}
> > -
> > -static inline unsigned long zs_stat_get(struct size_class *class,
> > -				enum zs_stat_type type)
> > -{
> > -	return 0;
> > -}
> > -
> >  static int __init zs_stat_init(void)
> >  {
> >  	return 0;
> > @@ -608,7 +585,6 @@ static inline int zs_pool_stat_create(char *name, struct zs_pool *pool)
> >  static inline void zs_pool_stat_destroy(struct zs_pool *pool)
> >  {
> >  }
> > -
> >  #endif
> >  
> >  
> > @@ -1682,7 +1658,6 @@ static void putback_zspage(struct zs_pool *pool, struct size_class *class,
> >  			class->size, class->pages_per_zspage));
> >  		atomic_long_sub(class->pages_per_zspage,
> >  				&pool->pages_allocated);
> > -
> >  		free_zspage(first_page);
> >  	}
> >  }
> > -- 
> > 2.4.2.337.gfae46aa
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
