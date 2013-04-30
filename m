Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 232CF6B00E1
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 10:01:48 -0400 (EDT)
Date: Tue, 30 Apr 2013 15:01:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 04/31] dentry: move to per-sb LRU locks
Message-ID: <20130430140144.GD6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-5-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-5-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Sat, Apr 27, 2013 at 03:19:00AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> With the dentry LRUs being per-sb structures, there is no real need
> for a global dentry_lru_lock. The locking can be made more
> fine-grained by moving to a per-sb LRU lock, isolating the LRU
> operations of different filesytsems completely from each other.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Acked-by: Mel Gorman <mgorman@suse.de>

But one comment below

> @@ -81,7 +81,6 @@
>  int sysctl_vfs_cache_pressure __read_mostly = 100;
>  EXPORT_SYMBOL_GPL(sysctl_vfs_cache_pressure);
>  
> -static __cacheline_aligned_in_smp DEFINE_SPINLOCK(dcache_lru_lock);
>  __cacheline_aligned_in_smp DEFINE_SEQLOCK(rename_lock);
>  
>  EXPORT_SYMBOL(rename_lock);

It made sense to cache-align these locks because you don't want two
unrelated global locks causing each other to bounce but ....

> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 8d47c9a..df3174d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1263,7 +1263,9 @@ struct super_block {
>  	struct list_head	s_files;
>  #endif
>  	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use */
> -	/* s_dentry_lru, s_nr_dentry_unused protected by dcache.c lru locks */
> +
> +	/* s_dentry_lru_lock protects s_dentry_lru and s_nr_dentry_unused */
> +	spinlock_t		s_dentry_lru_lock ____cacheline_aligned_in_smp;
>  	struct list_head	s_dentry_lru;	/* unused dentry lru */
>  	int			s_nr_dentry_unused;	/* # of dentry on lru */
>  

It's less compelling to align within a structure like this. If move the
lock and the fields it protects to a read-mostly section then there
should be no need to cache-align the lock, create a large hole in the
struct and grow the size of struct super_block unnecessarily.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
