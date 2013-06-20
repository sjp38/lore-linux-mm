Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 7664F6B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 11:23:33 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 20 Jun 2013 09:19:53 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E1C9838C804A
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 11:19:43 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5KFJh1848300032
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 11:19:44 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5KFJ6H6031971
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 09:19:06 -0600
Date: Thu, 20 Jun 2013 10:18:59 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] zswap: limit pool fragment
Message-ID: <20130620151859.GC9461@cerebellum>
References: <1371739102-11436-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371739102-11436-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, konrad.wilk@oracle.com, Bob Liu <bob.liu@oracle.com>

On Thu, Jun 20, 2013 at 10:38:22PM +0800, Bob Liu wrote:
> If zswap pool fragment is heavy, it's meanless to store more pages to zswap.
> So refuse allocate page to zswap pool to limit the fragmentation.

This is a little light on specifics.

>From looking at the code it would seem that you are preventing further
growth of the zswap pool if the overall compression ratio achieved in the
pool doesn't reach a certain threshold; in this case an arbitrary 70%.

So there are some issues:

1. If the first few pages that come into zswap don't compress well this logic
makes a horrible assumption that all future page will also not compress well
and effectively disables zswap until those poorly-compressed pages are removed
from the pool.  So that's a huge problem.

2. It mucks up the allocator API with a change to zbud_alloc's signature

3. It introduces yet another (should be) tunable in the form of the compression
threshold and really just reimplements the per-page compression threshold that
was removed from the code during development (the per-page check was better
than this because it doesn't suffer from issue #1).  It was decided that the
decisions about whether the page can be (efficiently) stored should be the job
of the allocator.

Seth

> 
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---
>  include/linux/zbud.h |    2 +-
>  mm/zbud.c            |    4 +++-
>  mm/zswap.c           |   15 +++++++++++++--
>  3 files changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
> index 2571a5c..71a61be 100644
> --- a/include/linux/zbud.h
> +++ b/include/linux/zbud.h
> @@ -12,7 +12,7 @@ struct zbud_ops {
>  struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
>  void zbud_destroy_pool(struct zbud_pool *pool);
>  int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> -	unsigned long *handle);
> +	unsigned long *handle, bool dis_pagealloc);
>  void zbud_free(struct zbud_pool *pool, unsigned long handle);
>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
>  void *zbud_map(struct zbud_pool *pool, unsigned long handle);
> diff --git a/mm/zbud.c b/mm/zbud.c
> index 9bb4710..5ace447 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -248,7 +248,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
>   * a new page.
>   */
>  int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> -			unsigned long *handle)
> +			unsigned long *handle, bool dis_pagealloc)
>  {
>  	int chunks, i, freechunks;
>  	struct zbud_header *zhdr = NULL;
> @@ -279,6 +279,8 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> 
>  	/* Couldn't find unbuddied zbud page, create new one */
>  	spin_unlock(&pool->lock);
> +	if (dis_pagealloc)
> +		return -ENOSPC;
>  	page = alloc_page(gfp);
>  	if (!page)
>  		return -ENOMEM;
> diff --git a/mm/zswap.c b/mm/zswap.c
> index deda2b6..7fe2b1b 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -607,10 +607,12 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  	struct zswap_entry *entry, *dupentry;
>  	int ret;
>  	unsigned int dlen = PAGE_SIZE, len;
> -	unsigned long handle;
> +	unsigned long handle, stored_pages;
>  	char *buf;
>  	u8 *src, *dst;
>  	struct zswap_header *zhdr;
> +	u64 tmp;
> +	bool dis_pagealloc = false;
> 
>  	if (!tree) {
>  		ret = -ENODEV;
> @@ -645,10 +647,19 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  		goto freepage;
>  	}
> 
> +	/* If the fragment of zswap pool is heavy, don't alloc new page to
> +	 * zswap pool anymore. The limitation of fragment is 70% percent currently
> +	 */
> +	stored_pages = atomic_read(&zswap_stored_pages);
> +	tmp = zswap_pool_pages * 100;
> +	do_div(tmp, stored_pages + 1);
> +	if (tmp > 70)
> +		dis_pagealloc = true;
> +
>  	/* store */
>  	len = dlen + sizeof(struct zswap_header);
>  	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
> -		&handle);
> +		&handle, dis_pagealloc);
>  	if (ret == -ENOSPC) {
>  		zswap_reject_compress_poor++;
>  		goto freepage;
> -- 
> 1.7.10.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
