Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 55C086B01B9
	for <linux-mm@kvack.org>; Thu, 27 May 2010 16:32:50 -0400 (EDT)
Date: Thu, 27 May 2010 13:32:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] superblock: add filesystem shrinker operations
Message-Id: <20100527133239.5d038d9c.akpm@linux-foundation.org>
In-Reply-To: <1274777588-21494-5-git-send-email-david@fromorbit.com>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
	<1274777588-21494-5-git-send-email-david@fromorbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010 18:53:07 +1000
Dave Chinner <david@fromorbit.com> wrote:

> From: Dave Chinner <dchinner@redhat.com>
> 
> Now we have a per-superblock shrinker implementation, we can add a
> filesystem specific callout to it to allow filesystem internal
> caches to be shrunk by the superblock shrinker.
> 
> Rather than perpetuate the multipurpose shrinker callback API (i.e.
> nr_to_scan == 0 meaning "tell me how many objects freeable in the
> cache), two operations will be added. The first will return the
> number of objects that are freeable, the second is the actual
> shrinker call.
> 
>
> ...
>
>  static int prune_super(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
>  {
>  	struct super_block *sb;
> -	int count;
> +	int	fs_objects = 0;
> +	int	total_objects;
>  
>  	sb = container_of(shrink, struct super_block, s_shrink);
>  
> @@ -63,22 +64,40 @@ static int prune_super(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
>  		return -1;
>  	}
>  
> -	if (nr_to_scan) {
> -		/* proportion the scan between the two cache__ */
> -		int total;
> -
> -		total = sb->s_nr_dentry_unused + sb->s_nr_inodes_unused + 1;
> -		count = (nr_to_scan * sb->s_nr_dentry_unused) / total;
> +	if (sb->s_op && sb->s_op->nr_cached_objects)
> +		fs_objects = sb->s_op->nr_cached_objects(sb);
>  
> -		/* prune dcache first as icache is pinned by it */
> -		prune_dcache_sb(sb, count);
> -		prune_icache_sb(sb, nr_to_scan - count);
> +	total_objects = sb->s_nr_dentry_unused +
> +			sb->s_nr_inodes_unused + fs_objects + 1;
> +	if (nr_to_scan) {
> +		int	dentries;
> +		int	inodes;
> +
> +		/* proportion the scan between the cache__ */
> +		dentries = (nr_to_scan * sb->s_nr_dentry_unused) /
> +							total_objects;
> +		inodes = (nr_to_scan * sb->s_nr_inodes_unused) /
> +							total_objects;
> +		if (fs_objects)
> +			fs_objects = (nr_to_scan * fs_objects) /
> +							total_objects;
> +		/*
> +		 * prune the dcache first as the icache is pinned by it, then
> +		 * prune the icache, followed by the filesystem specific caches
> +		 */
> +		prune_dcache_sb(sb, dentries);
> +		prune_icache_sb(sb, inodes);
> +		if (sb->s_op && sb->s_op->free_cached_objects) {

Under which circumstances is a NULL ->free_cached_objects valid?

> +			sb->s_op->free_cached_objects(sb, fs_objects);
> +			fs_objects = sb->s_op->nr_cached_objects(sb);
> +		}
> +		total_objects = sb->s_nr_dentry_unused +
> +				sb->s_nr_inodes_unused + fs_objects;
>  	}

The return value from ->free_cached_objects() doesn't actually get
used.  Instead the code calls ->nr_cached_objects() twice.


> -	count = ((sb->s_nr_dentry_unused + sb->s_nr_inodes_unused) / 100)
> -						* sysctl_vfs_cache_pressure;
> +	total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
>  	up_read(&sb->s_umount);
> -	return count;
> +	return total_objects;
>  }
>  
>  /**
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 5bff2dc..efcdcc6 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1590,6 +1590,17 @@ struct super_operations {
>  	ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
>  #endif
>  	int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
> +
> +	/*
> +	 * memory shrinker operations.
> +	 * ->nr_cached_objects() should return the number of freeable cached
> +	 * objects the filesystem holds.
> +	 * ->free_cache_objects() should attempt to free the number of cached
> +	 * objects indicated. It should return how many objects it attempted to
> +	 * free.
> +	 */

I'd have thought that ->free_cache_objects() would always return the
number which it was passed.  Unless someone asked it to scan more
objects than exist, perhaps.

> +	int (*nr_cached_objects)(struct super_block *);
> +	int (*free_cached_objects)(struct super_block *, int);
>  };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
