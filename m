Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D079B6B01B8
	for <linux-mm@kvack.org>; Wed, 26 May 2010 12:41:24 -0400 (EDT)
Date: Thu, 27 May 2010 02:41:16 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 3/5] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100526164116.GD22536@laptop>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1274777588-21494-4-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 06:53:06PM +1000, Dave Chinner wrote:
> @@ -456,21 +456,16 @@ static void prune_one_dentry(struct dentry * dentry)
>   * which flags are set. This means we don't need to maintain multiple
>   * similar copies of this loop.
>   */
> -static void __shrink_dcache_sb(struct super_block *sb, int *count, int flags)
> +static void __shrink_dcache_sb(struct super_block *sb, int count, int flags)
>  {
>  	LIST_HEAD(referenced);
>  	LIST_HEAD(tmp);
>  	struct dentry *dentry;
> -	int cnt = 0;
>  
>  	BUG_ON(!sb);
> -	BUG_ON((flags & DCACHE_REFERENCED) && count == NULL);
> +	BUG_ON((flags & DCACHE_REFERENCED) && count == -1);
>  	spin_lock(&dcache_lock);
> -	if (count != NULL)
> -		/* called from prune_dcache() and shrink_dcache_parent() */
> -		cnt = *count;
> -restart:
> -	if (count == NULL)
> +	if (count == -1)
>  		list_splice_init(&sb->s_dentry_lru, &tmp);
>  	else {
>  		while (!list_empty(&sb->s_dentry_lru)) {
> @@ -492,13 +487,13 @@ restart:
>  			} else {
>  				list_move_tail(&dentry->d_lru, &tmp);
>  				spin_unlock(&dentry->d_lock);
> -				cnt--;
> -				if (!cnt)
> +				if (--count == 0)
>  					break;
>  			}
>  			cond_resched_lock(&dcache_lock);
>  		}
>  	}
> +prune_more:
>  	while (!list_empty(&tmp)) {
>  		dentry = list_entry(tmp.prev, struct dentry, d_lru);
>  		dentry_lru_del_init(dentry);
> @@ -516,88 +511,29 @@ restart:
>  		/* dentry->d_lock was dropped in prune_one_dentry() */
>  		cond_resched_lock(&dcache_lock);
>  	}
> -	if (count == NULL && !list_empty(&sb->s_dentry_lru))
> -		goto restart;
> -	if (count != NULL)
> -		*count = cnt;
> +	if (count == -1 && !list_empty(&sb->s_dentry_lru)) {
> +		list_splice_init(&sb->s_dentry_lru, &tmp);
> +		goto prune_more;
> +	}

Nitpick but I prefer just the restart label wher it is previously. This
is moving setup for the next iteration into the "error" case.


> +static int prune_super(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
> +{
> +	struct super_block *sb;
> +	int count;
> +
> +	sb = container_of(shrink, struct super_block, s_shrink);
> +
> +	/*
> +	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
> +	 * to recurse into the FS that called us in clear_inode() and friends..
> +	 */
> +	if (!(gfp_mask & __GFP_FS))
> +		return -1;
> +
> +	/*
> +	 * if we can't get the umount lock, then there's no point having the
> +	 * shrinker try again because the sb is being torn down.
> +	 */
> +	if (!down_read_trylock(&sb->s_umount))
> +		return -1;

Would you just elaborate on the lock order problem somewhere? (the
comment makes it look like we *could* take the mutex if we wanted
to).


> +
> +	if (!sb->s_root) {
> +		up_read(&sb->s_umount);
> +		return -1;
> +	}
> +
> +	if (nr_to_scan) {
> +		/* proportion the scan between the two cacheN? */
> +		int total;
> +
> +		total = sb->s_nr_dentry_unused + sb->s_nr_inodes_unused + 1;
> +		count = (nr_to_scan * sb->s_nr_dentry_unused) / total;
> +
> +		/* prune dcache first as icache is pinned by it */
> +		prune_dcache_sb(sb, count);
> +		prune_icache_sb(sb, nr_to_scan - count);
> +	}
> +
> +	count = ((sb->s_nr_dentry_unused + sb->s_nr_inodes_unused) / 100)
> +						* sysctl_vfs_cache_pressure;

Do you think truncating in the divisions is at all a problem? It
probably doesn't matter much I suppose.

> @@ -162,6 +213,7 @@ void deactivate_locked_super(struct super_block *s)
>  	struct file_system_type *fs = s->s_type;
>  	if (atomic_dec_and_test(&s->s_active)) {
>  		vfs_dq_off(s, 0);
> +		unregister_shrinker(&s->s_shrink);
>  		fs->kill_sb(s);
>  		put_filesystem(fs);
>  		put_super(s);
> @@ -335,6 +387,7 @@ retry:
>  	list_add_tail(&s->s_list, &super_blocks);
>  	list_add(&s->s_instances, &type->fs_supers);
>  	spin_unlock(&sb_lock);
> +	register_shrinker(&s->s_shrink);
>  	get_filesystem(type);
>  	return s;
>  }
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 7b90c43..5bff2dc 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -382,6 +382,7 @@ struct inodes_stat_t {
>  #include <linux/capability.h>
>  #include <linux/semaphore.h>
>  #include <linux/fiemap.h>
> +#include <linux/mm.h>
>  
>  #include <asm/atomic.h>
>  #include <asm/byteorder.h>
> @@ -1385,8 +1386,14 @@ struct super_block {
>  	 * generic_show_options()
>  	 */
>  	char *s_options;
> +
> +	struct shrinker s_shrink;	/* per-sb shrinker handle */
>  };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
