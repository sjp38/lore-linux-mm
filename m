Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E462E6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 20:48:12 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id y10so7452794pdj.4
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:48:12 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id rg11si23460707pdb.142.2014.09.23.17.48.10
        for <linux-mm@kvack.org>;
        Tue, 23 Sep 2014 17:48:11 -0700 (PDT)
Date: Wed, 24 Sep 2014 09:48:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] zsmalloc: merge size_class to reduce fragmentation
Message-ID: <20140924004841.GA25874@js1304-P5Q-DELUXE>
References: <1411461011-17959-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140923152555.0bf1c500a6adf4c218f34a86@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140923152555.0bf1c500a6adf4c218f34a86@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com, "seungho1.park" <seungho1.park@lge.com>

On Tue, Sep 23, 2014 at 03:25:55PM -0700, Andrew Morton wrote:
> On Tue, 23 Sep 2014 17:30:11 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > zsmalloc has many size_classes to reduce fragmentation and they are
> > in 16 bytes unit, for example, 16, 32, 48, etc., if PAGE_SIZE is 4096.
> > And, zsmalloc has constraint that each zspage has 4 pages at maximum.
> > 
> > In this situation, we can see interesting aspect.
> > Let's think about size_class for 1488, 1472, ..., 1376.
> > To prevent external fragmentation, they uses 4 pages per zspage and
> > so all they can contain 11 objects at maximum.
> > 
> > 16384 (4096 * 4) = 1488 * 11 + remains
> > 16384 (4096 * 4) = 1472 * 11 + remains
> > 16384 (4096 * 4) = ...
> > 16384 (4096 * 4) = 1376 * 11 + remains
> > 
> > It means that they have same chracteristics and classification between
> > them isn't needed. If we use one size_class for them, we can reduce
> > fragementation and save some memory. Below is result of my simple test.
> > 
> > TEST ENV: EXT4 on zram, mount with discard option
> > WORKLOAD: untar kernel source code, remove directory in descending order
> > in size. (drivers arch fs sound include net Documentation firmware
> > kernel tools)
> > 
> > Each line represents orig_data_size, compr_data_size, mem_used_total,
> > fragmentation overhead (mem_used - compr_data_size) and overhead ratio
> > (overhead to compr_data_size), respectively, after untar and remove
> > operation is executed.
> > 
> > * untar-nomerge.out
> > 
> > orig_size compr_size used_size overhead overhead_ratio
> > 525.88MB 199.16MB 210.23MB  11.08MB 5.56%
> > 288.32MB  97.43MB 105.63MB   8.20MB 8.41%
> > 177.32MB  61.12MB  69.40MB   8.28MB 13.55%
> > 146.47MB  47.32MB  56.10MB   8.78MB 18.55%
> > 124.16MB  38.85MB  48.41MB   9.55MB 24.58%
> > 103.93MB  31.68MB  40.93MB   9.25MB 29.21%
> >  84.34MB  22.86MB  32.72MB   9.86MB 43.13%
> >  66.87MB  14.83MB  23.83MB   9.00MB 60.70%
> >  60.67MB  11.11MB  18.60MB   7.49MB 67.48%
> >  55.86MB   8.83MB  16.61MB   7.77MB 88.03%
> >  53.32MB   8.01MB  15.32MB   7.31MB 91.24%
> > 
> > * untar-merge.out
> > 
> > orig_size compr_size used_size overhead overhead_ratio
> > 526.23MB 199.18MB 209.81MB  10.64MB 5.34%
> > 288.68MB  97.45MB 104.08MB   6.63MB 6.80%
> > 177.68MB  61.14MB  66.93MB   5.79MB 9.47%
> > 146.83MB  47.34MB  52.79MB   5.45MB 11.51%
> > 124.52MB  38.87MB  44.30MB   5.43MB 13.96%
> > 104.29MB  31.70MB  36.83MB   5.13MB 16.19%
> >  84.70MB  22.88MB  27.92MB   5.04MB 22.04%
> >  67.11MB  14.83MB  19.26MB   4.43MB 29.86%
> >  60.82MB  11.10MB  14.90MB   3.79MB 34.17%
> >  55.90MB   8.82MB  12.61MB   3.79MB 42.97%
> >  53.32MB   8.01MB  11.73MB   3.73MB 46.53%
> > 
> > As you can see above result, merged one has better utilization (overhead
> > ratio, 5th column) and uses less memory (mem_used_total, 3rd column).
> > 
> 
> The above is great, but it provided no description of the implementation,
> and there are no code comments describing what's going on either.

Okay. I will add it.

> 
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -193,6 +193,7 @@ struct size_class {
> >  	 */
> >  	int size;
> >  	unsigned int index;
> > +	unsigned int nr_obj;
> 
> Documenting the data structures is critical.  If the roles and
> relationships and interactions between the data structures are
> skilfully described, the implementation tends to become relatively
> obvious.

Okay.

> 
> >  	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> >  	int pages_per_zspage;
> > @@ -214,7 +215,8 @@ struct link_free {
> >  };
> >  
> >  struct zs_pool {
> > -	struct size_class size_class[ZS_SIZE_CLASSES];
> > +	struct size_class *size_class[ZS_SIZE_CLASSES];
> > +	struct size_class __size_class[ZS_SIZE_CLASSES];
> 
> Are these the best possible names?
> 
> I assume the entries in size_class[] point into entries in
> __size_class[].  Some description of how (and why!) this is arranged
> would go a long way.

Okay.

> 
> > @@ -949,20 +961,28 @@ struct zs_pool *zs_create_pool(gfp_t flags)
> >  	if (!pool)
> >  		return NULL;
> >  
> > -	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
> > +	for (i = ZS_SIZE_CLASSES - 1; i >= 0; i--) {
> >  		int size;
> >  		struct size_class *class;
> > +		struct size_class *prev_class;
> >  
> >  		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
> >  		if (size > ZS_MAX_ALLOC_SIZE)
> >  			size = ZS_MAX_ALLOC_SIZE;
> >  
> > -		class = &pool->size_class[i];
> > +		class = &pool->__size_class[i];
> >  		class->size = size;
> >  		class->index = i;
> >  		spin_lock_init(&class->lock);
> >  		class->pages_per_zspage = get_pages_per_zspage(size);
> > +		class->nr_obj = class->pages_per_zspage * PAGE_SIZE / size;
> >  
> > +		pool->size_class[i] = class;
> > +		if (i < ZS_SIZE_CLASSES - 1) {
> > +			prev_class = pool->size_class[i + 1];
> > +			if (is_same_density(prev_class, class))
> > +				pool->size_class[i] = prev_class;
> > +		}
> >  	}
> 
> This is the key part and is a great place to explain your design to your
> readers.

Yes.

> 
> Please, let's do better than this?
> 

Okay. :)
I will consider all your comments and send v2 soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
