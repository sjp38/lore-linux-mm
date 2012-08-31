Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 34B2A6B0069
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 13:08:28 -0400 (EDT)
Date: Fri, 31 Aug 2012 13:08:14 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] frontswap: support exclusive gets if tmem backend is
 capable
Message-ID: <20120831170814.GF18929@localhost.localdomain>
References: <5557ec97-daa1-41a6-b3db-671f116ddc50@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5557ec97-daa1-41a6-b3db-671f116ddc50@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Fri, Aug 31, 2012 at 08:48:10AM -0700, Dan Magenheimer wrote:
> Konrad, can this go in linux-next and in the next window?
> 
> Tmem, as originally specified, assumes that "get" operations
> performed on persistent pools never flush the page of data out
> of tmem on a successful get, waiting instead for a flush
> operation.  This is intended to mimic the model of a swap
> disk, where a disk read is non-destructive.  Unlike a
> disk, however, freeing up the RAM can be valuable.  Over
> the years that frontswap was in the review process, several
> reviewers (and notably Hugh Dickins in 2010) pointed out that
> this would result, at least temporarily, in two copies of the
> data in RAM: one (compressed for zcache) copy in tmem,
> and one copy in the swap cache.  We wondered if this could
> be done differently, at least optionally.
> 
> This patch allows tmem backends to instruct the frontswap
> code that this backend performs exclusive gets.  Zcache2
> already contains hooks to support this feature.  Other
> backends are completely unaffected unless/until they are
> updated to support this feature.
> 
> While it is not clear that exclusive gets are a performance
> win on all workloads at all times, this small patch allows for
> experimentation by backends.
> 
> P.S. Let's not quibble about the naming of "get" vs "read" vs
> "load" etc.  The naming is currently horribly inconsistent between
> cleancache and frontswap and existing tmem backends, so will need
> to be straightened out as a separate patch.  "Get" is used
> by the tmem architecture spec, existing backends, and
> all documentation and presentation material so I am
> using it in this patch.
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
> index 0e4e2ee..3044254 100644
> --- a/include/linux/frontswap.h
> +++ b/include/linux/frontswap.h
> @@ -19,6 +19,8 @@ extern struct frontswap_ops
>  extern void frontswap_shrink(unsigned long);
>  extern unsigned long frontswap_curr_pages(void);
>  extern void frontswap_writethrough(bool);
> +#define FRONTSWAP_HAS_EXCLUSIVE_GETS
> +extern void frontswap_tmem_exclusive_gets(bool);

I don't think you need the #define here.. 
>  
>  extern void __frontswap_init(unsigned type);
>  extern int __frontswap_store(struct page *page);
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index e250255..b1496fb 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -48,6 +48,13 @@ EXPORT_SYMBOL(frontswap_enabled);
>   */
>  static bool frontswap_writethrough_enabled __read_mostly;
>  
> +/*
> + * If enabled, the underlying tmem implementation is capable of doing
> + * exclusive gets, so frontswap_load, on a successful tmem_get must
> + * mark the page as no longer in frontswap AND mark it dirty.
> + */
> +static bool frontswap_tmem_exclusive_gets_enabled __read_mostly;
> +
>  #ifdef CONFIG_DEBUG_FS
>  /*
>   * Counters available via /sys/kernel/debug/frontswap (if debugfs is
> @@ -101,6 +108,15 @@ void frontswap_writethrough(bool enable)
>  EXPORT_SYMBOL(frontswap_writethrough);
>  
>  /*
> + * Enable/disable frontswap exclusive gets (see above).
> + */
> +void frontswap_tmem_exclusive_gets(bool enable)
> +{
> +	frontswap_tmem_exclusive_gets_enabled = enable;
> +}
> +EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);

We got two of these now - the writethrough and this one. Merging
them in one function and one flag might be better. So something like:
static int frontswap_mode = 0;

void frontswap_set_mode(int set_mode)
{
	if (mode & (FRONTSWAP_WRITETH | FRONTSWAP_EXCLUS..)
		mode |= set_mode;
}

... and
> +
> +/*
>   * Called when a swap device is swapon'd.
>   */
>  void __frontswap_init(unsigned type)
> @@ -174,8 +190,13 @@ int __frontswap_load(struct page *page)
>  	BUG_ON(sis == NULL);
>  	if (frontswap_test(sis, offset))
>  		ret = (*frontswap_ops.load)(type, offset, page);
> -	if (ret == 0)
> +	if (ret == 0) {
>  		inc_frontswap_loads();
> +		if (frontswap_tmem_exclusive_gets_enabled) {

For these perhaps use asm goto for optimization? Is this showing up in
perf as a hotspot? The asm goto might be a bit too much.

> +			SetPageDirty(page);
> +			frontswap_clear(sis, offset);
> +		}
> +	}
>  	return ret;
>  }
>  EXPORT_SYMBOL(__frontswap_load);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
