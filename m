Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 2F19E6B0006
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 14:00:26 -0500 (EST)
Message-ID: <5138E3C7.9080205@sr71.net>
Date: Thu, 07 Mar 2013 11:00:23 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv7 4/8] zswap: add to mm/
References: <1362585143-6482-1-git-send-email-sjenning@linux.vnet.ibm.com> <1362585143-6482-5-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1362585143-6482-5-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 03/06/2013 07:52 AM, Seth Jennings wrote:
> +static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
> +{
> +	struct crypto_comp *tfm;
> +	u8 *dst;
> +
> +	switch (action) {
> +	case CPU_UP_PREPARE:
> +		tfm = crypto_alloc_comp(zswap_compressor, 0, 0);
> +		if (IS_ERR(tfm)) {
> +			pr_err("can't allocate compressor transform\n");
> +			return NOTIFY_BAD;
> +		}
> +		*per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = tfm;
> +		dst = (u8 *)__get_free_pages(GFP_KERNEL, 1);

Are there some alignment requirements for 'dst'?  If not, why not use
kmalloc()?  I think kmalloc() should always be used where possible since
slab debugging is so useful compared to what we can do with raw
buddy-allocated pages.

Where does the order-1 requirement come from by the way?

...
> +**********************************/
> +/* attempts to compress and store an single page */
> +static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> +				struct page *page)
> +{
...
> +	/* store */
> +	handle = zs_malloc(tree->pool, dlen,
> +		__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
> +			__GFP_NOWARN);
> +	if (!handle) {
> +		zswap_reject_zsmalloc_fail++;
> +		ret = -ENOMEM;
> +		goto putcpu;
> +	}
> +

I think there needs to at least be some strong comments in here about
why you're doing this kind of allocation.  From some IRC discussion, it
seems like you found some pathological case where zswap wasn't helping
make reclaim progress and ended up draining the reserve pools and you
did this to avoid draining the reserve pools.

I think the lack of progress doing reclaim is really the root cause you
should be going after here instead of just working around the symptom.

> +/* NOTE: this is called in atomic context from swapon and must not sleep */
> +static void zswap_frontswap_init(unsigned type)
> +{
> +	struct zswap_tree *tree;
> +
> +	tree = kzalloc(sizeof(struct zswap_tree), GFP_NOWAIT);
> +	if (!tree)
> +		goto err;
> +	tree->pool = zs_create_pool(GFP_NOWAIT, &zswap_zs_ops);
> +	if (!tree->pool)
> +		goto freetree;
> +	tree->rbroot = RB_ROOT;
> +	spin_lock_init(&tree->lock);
> +	zswap_trees[type] = tree;
> +	return;
> +
> +freetree:
> +	kfree(tree);
> +err:
> +	pr_err("alloc failed, zswap disabled for swap type %d\n", type);
> +}

How large are these allocations?  Why are you doing GFP_NOWAIT instead
of GFP_ATOMIC?  This seems like the kind of thing that you'd _want_ to
be able to dip in to the reserves for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
