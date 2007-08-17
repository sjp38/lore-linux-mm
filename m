Date: Fri, 17 Aug 2007 12:20:30 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 16/23] mm: scalable bdi statistics counters.
Message-ID: <20070817162030.GA27836@filer.fsl.cs.sunysb.edu>
References: <20070816074525.065850000@chello.nl> <20070816074628.520798000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070816074628.520798000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 16, 2007 at 09:45:41AM +0200, Peter Zijlstra wrote:
...
> Index: linux-2.6/include/linux/backing-dev.h
> ===================================================================
> --- linux-2.6.orig/include/linux/backing-dev.h
> +++ linux-2.6/include/linux/backing-dev.h
...
> @@ -24,6 +26,12 @@ enum bdi_state {
>  
>  typedef int (congested_fn)(void *, int);
>  
> +enum bdi_stat_item {
> +	NR_BDI_STAT_ITEMS
> +};

enum numbering starts at 0, so NR_BDI_STAT_ITEMS == 0

> +
> +#define BDI_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
> +
>  struct backing_dev_info {
>  	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
>  	unsigned long state;	/* Always use atomic bitops on this */
> @@ -32,15 +40,86 @@ struct backing_dev_info {
>  	void *congested_data;	/* Pointer to aux data for congested func */
>  	void (*unplug_io_fn)(struct backing_dev_info *, struct page *);
>  	void *unplug_io_data;
> +
> +	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];

So, this is a 0-element array.

>  };
>  
> -static inline int bdi_init(struct backing_dev_info *bdi)
> +int bdi_init(struct backing_dev_info *bdi);
> +void bdi_destroy(struct backing_dev_info *bdi);
> +
> +static inline void __add_bdi_stat(struct backing_dev_info *bdi,
> +		enum bdi_stat_item item, s64 amount)
>  {
> -	return 0;
> +	__percpu_counter_add(&bdi->bdi_stat[item], amount, BDI_STAT_BATCH);

Boom!

>  }

Josef 'Jeff' Sipek.

-- 
You measure democracy by the freedom it gives its dissidents, not the
freedom it gives its assimilated conformists.
		- Abbie Hoffman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
