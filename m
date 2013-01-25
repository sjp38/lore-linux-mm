Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 4DA556B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 17:44:50 -0500 (EST)
Message-ID: <51030ADA.8030403@redhat.com>
Date: Fri, 25 Jan 2013 17:44:42 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 8/9] zswap: add to mm/
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-9-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1357590280-31535-9-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/07/2013 03:24 PM, Seth Jennings wrote:
> zswap is a thin compression backend for frontswap. It receives
> pages from frontswap and attempts to store them in a compressed
> memory pool, resulting in an effective partial memory reclaim and
> dramatically reduced swap device I/O.
>
> Additional, in most cases, pages can be retrieved from this
> compressed store much more quickly than reading from tradition
> swap devices resulting in faster performance for many workloads.
>
> This patch adds the zswap driver to mm/
>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

I like the approach of flushing pages into actual disk based
swap when compressed swap is full.  I would like it if that
was advertised more prominently in the changelog :)

The code looks mostly good, complaints are at the nitpick level.

One worry is that the pool can grow to whatever maximum was
decided, and there is no way to shrink it when memory is
required for something else.

Would it be an idea to add a shrinker for the zcache pool,
that can also shrink the zcache pool when required?

Of course, that does lead to the question of how to balance
the pressure from that shrinker, with the new memory entering
zcache from the swap side. I have no clear answers here, just
something to think about...


> +static void zswap_flush_entries(unsigned type, int nr)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct zswap_entry *entry;
> +	int i, ret;
> +
> +/*
> + * This limits is arbitrary for now until a better
> + * policy can be implemented. This is so we don't
> + * eat all of RAM decompressing pages for writeback.
> + */
> +#define ZSWAP_MAX_OUTSTANDING_FLUSHES 64
> +	if (atomic_read(&zswap_outstanding_flushes) >
> +		ZSWAP_MAX_OUTSTANDING_FLUSHES)
> +		return;

Having this #define right in the middle of the function is
rather ugly.  Might be worth moving it to the top.

> +static int __init zswap_debugfs_init(void)
> +{
> +	if (!debugfs_initialized())
> +		return -ENODEV;
> +
> +	zswap_debugfs_root = debugfs_create_dir("zswap", NULL);
> +	if (!zswap_debugfs_root)
> +		return -ENOMEM;
> +
> +	debugfs_create_u64("saved_by_flush", S_IRUGO,
> +			zswap_debugfs_root, &zswap_saved_by_flush);
> +	debugfs_create_u64("pool_limit_hit", S_IRUGO,
> +			zswap_debugfs_root, &zswap_pool_limit_hit);
> +	debugfs_create_u64("reject_flush_attempted", S_IRUGO,
> +			zswap_debugfs_root, &zswap_flush_attempted);
> +	debugfs_create_u64("reject_tmppage_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_tmppage_fail);
> +	debugfs_create_u64("reject_flush_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_flush_fail);
> +	debugfs_create_u64("reject_zsmalloc_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_zsmalloc_fail);
> +	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
> +	debugfs_create_u64("reject_compress_poor", S_IRUGO,
> +			zswap_debugfs_root, &zswap_reject_compress_poor);
> +	debugfs_create_u64("flushed_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_flushed_pages);
> +	debugfs_create_u64("duplicate_entry", S_IRUGO,
> +			zswap_debugfs_root, &zswap_duplicate_entry);
> +	debugfs_create_atomic_t("pool_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_pool_pages);
> +	debugfs_create_atomic_t("stored_pages", S_IRUGO,
> +			zswap_debugfs_root, &zswap_stored_pages);
> +	debugfs_create_atomic_t("outstanding_flushes", S_IRUGO,
> +			zswap_debugfs_root, &zswap_outstanding_flushes);
> +

Some of these statistics would be very useful to system
administrators, who will not be mounting debugfs on
production systems.

Would it make sense to export some of these statistics
through sysfs?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
