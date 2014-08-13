Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0536B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 11:30:24 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id m20so4223182qcx.21
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:30:24 -0700 (PDT)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id b4si3038626qae.64.2014.08.13.08.30.23
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 08:30:23 -0700 (PDT)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id EC7EE100ED7
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 11:30:20 -0400 (EDT)
Date: Wed, 13 Aug 2014 10:30:20 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [RFC 3/3] zram: limit memory size for zram
Message-ID: <20140813153020.GC2768@cerebellum.variantweb.net>
References: <1407225723-23754-1-git-send-email-minchan@kernel.org>
 <1407225723-23754-4-git-send-email-minchan@kernel.org>
 <20140805094859.GE27993@bbox>
 <20140805131615.GA961@swordfish>
 <20140806065253.GC3796@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140806065253.GC3796@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, Aug 06, 2014 at 03:52:53PM +0900, Minchan Kim wrote:
> On Tue, Aug 05, 2014 at 10:16:15PM +0900, Sergey Senozhatsky wrote:
> > Hello,
> > 
> > On (08/05/14 18:48), Minchan Kim wrote:
> > > Another idea: we could define void zs_limit_mem(unsinged long nr_pages)
> > > in zsmalloc and put the limit in zs_pool via new API from zram so that
> > > zs_malloc could be failed as soon as it exceeds the limit.
> > > 
> > > In the end, zram doesn't need to call zs_get_total_size_bytes on every
> > > write. It's more clean and right layer, IMHO.
> > 
> > yes, I think this one is better.
> > 
> > 	-ss
> 
> From 279c406b5a8eabd03edca55490ec92b539b39c76 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 5 Aug 2014 16:24:57 +0900
> Subject: [PATCH] zram: limit memory size for zram
> 
> I have received a request several time from zram users.
> They want to limit memory size for zram because zram can consume
> lot of memory on system without limit so it makes memory management
> control hard.
> 
> This patch adds new knob to limit memory of zram.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  Documentation/blockdev/zram.txt |  1 +
>  drivers/block/zram/zram_drv.c   | 39 +++++++++++++++++++++++++++++++++++++--
>  include/linux/zsmalloc.h        |  2 ++
>  mm/zsmalloc.c                   | 24 ++++++++++++++++++++++++
>  4 files changed, 64 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> index d24534bee763..fcb0561dfe2e 100644
> --- a/Documentation/blockdev/zram.txt
> +++ b/Documentation/blockdev/zram.txt
> @@ -96,6 +96,7 @@ size of the disk when not in use so a huge zram is wasteful.
>  		compr_data_size
>  		mem_used_total
>  		mem_used_max
> +		mem_limit
>  
>  7) Deactivate:
>  	swapoff /dev/zram0
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index a4d637b4db7d..069e81ef0c17 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -137,6 +137,41 @@ static ssize_t max_comp_streams_show(struct device *dev,
>  	return scnprintf(buf, PAGE_SIZE, "%d\n", val);
>  }
>  
> +static ssize_t mem_limit_show(struct device *dev,
> +		struct device_attribute *attr, char *buf)
> +{
> +	u64 val = 0;
> +	struct zram *zram = dev_to_zram(dev);
> +	struct zram_meta *meta = zram->meta;
> +
> +	down_read(&zram->init_lock);
> +	if (init_done(zram))
> +		val = zs_get_limit_size_bytes(meta->mem_pool);
> +	up_read(&zram->init_lock);
> +
> +	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> +}
> +
> +static ssize_t mem_limit_store(struct device *dev,
> +		struct device_attribute *attr, const char *buf, size_t len)
> +{
> +	int ret;
> +	u64 limit;
> +	struct zram *zram = dev_to_zram(dev);
> +	struct zram_meta *meta = zram->meta;
> +
> +	ret = kstrtoull(buf, 0, &limit);
> +	if (ret < 0)
> +		return ret;
> +
> +	down_write(&zram->init_lock);
> +	if (init_done(zram))
> +		zs_set_limit_size_bytes(meta->mem_pool, limit);
> +	up_write(&zram->init_lock);
> +	ret = len;
> +	return ret;
> +}
> +
>  static ssize_t max_comp_streams_store(struct device *dev,
>  		struct device_attribute *attr, const char *buf, size_t len)
>  {
> @@ -506,8 +541,6 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  
>  	handle = zs_malloc(meta->mem_pool, clen);
>  	if (!handle) {
> -		pr_info("Error allocating memory for compressed page: %u, size=%zu\n",
> -			index, clen);
>  		ret = -ENOMEM;
>  		goto out;
>  	}
> @@ -854,6 +887,7 @@ static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
>  static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
>  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
>  static DEVICE_ATTR(mem_used_max, S_IRUGO, mem_used_max_show, NULL);
> +static DEVICE_ATTR(mem_limit, S_IRUGO, mem_limit_show, mem_limit_store);
>  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
>  		max_comp_streams_show, max_comp_streams_store);
>  static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
> @@ -883,6 +917,7 @@ static struct attribute *zram_disk_attrs[] = {
>  	&dev_attr_compr_data_size.attr,
>  	&dev_attr_mem_used_total.attr,
>  	&dev_attr_mem_used_max.attr,
> +	&dev_attr_mem_limit.attr,
>  	&dev_attr_max_comp_streams.attr,
>  	&dev_attr_comp_algorithm.attr,
>  	NULL,
> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> index fb087ca06a88..41122251a2d0 100644
> --- a/include/linux/zsmalloc.h
> +++ b/include/linux/zsmalloc.h
> @@ -49,4 +49,6 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
>  u64 zs_get_total_size_bytes(struct zs_pool *pool);
>  u64 zs_get_max_size_bytes(struct zs_pool *pool);
>  
> +u64 zs_get_limit_size_bytes(struct zs_pool *pool);
> +void zs_set_limit_size_bytes(struct zs_pool *pool, u64 limit);

While having a function to change the limit is fine, the setting of the
initial limit should be a parameter to zs_create_pool() since, if the
user doesn't call zs_set_limit_size_bytes() after zs_create_pool(), the
default size is 0.

This also breaks zswap which does its pool size limiting in the zswap
layer using zs_get_total_size_bytes() to poll for the pool size.

It also has implications for the new zpool abstraction layer which
doesn't have a handle for setting the pool limit.

Could you do what zswap does already and enforce the pool limit in the
zram code?

Seth

>  #endif
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 3b5be076268a..8ca51118cf2b 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -220,6 +220,7 @@ struct zs_pool {
>  	gfp_t flags;	/* allocation flags used when growing pool */
>  	unsigned long pages_allocated;
>  	unsigned long max_pages_allocated;
> +	unsigned long pages_limited;
>  };
>  
>  /*
> @@ -940,6 +941,11 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>  
>  	if (!first_page) {
>  		spin_unlock(&class->lock);
> +
> +		if (pool->pages_limited && (pool->pages_limited <
> +			pool->pages_allocated + class->pages_per_zspage))
> +			return 0;
> +
>  		first_page = alloc_zspage(class, pool->flags);
>  		if (unlikely(!first_page))
>  			return 0;
> @@ -1132,6 +1138,24 @@ u64 zs_get_max_size_bytes(struct zs_pool *pool)
>  }
>  EXPORT_SYMBOL_GPL(zs_get_max_size_bytes);
>  
> +void zs_set_limit_size_bytes(struct zs_pool *pool, u64 limit)
> +{
> +	pool->pages_limited = round_down(limit, PAGE_SIZE) >> PAGE_SHIFT;
> +}
> +EXPORT_SYMBOL_GPL(zs_set_limit_size_bytes);
> +
> +u64 zs_get_limit_size_bytes(struct zs_pool *pool)
> +{
> +	u64 npages;
> +
> +	spin_lock(&pool->stat_lock);
> +	npages = pool->pages_limited;
> +	spin_unlock(&pool->stat_lock);
> +	return npages << PAGE_SHIFT;
> +
> +}
> +EXPORT_SYMBOL_GPL(zs_get_limit_size_bytes);
> +
>  module_init(zs_init);
>  module_exit(zs_exit);
>  
> -- 
> 2.0.0
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
