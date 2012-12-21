Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 939216B005A
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 06:09:16 -0500 (EST)
Date: Fri, 21 Dec 2012 09:08:56 -0200
From: Carlos Maiolino <cmaiolino@redhat.com>
Subject: Re: [PATCH v2 1/2] super: fix calculation of shrinkable objects for
 small numbers
Message-ID: <20121221110856.GA8852@andromeda.usersys.redhat.com>
References: <1356086810-6950-1-git-send-email-glommer@parallels.com>
 <1356086810-6950-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1356086810-6950-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Dec 21, 2012 at 02:46:49PM +0400, Glauber Costa wrote:
> The sysctl knob sysctl_vfs_cache_pressure is used to determine which
> percentage of the shrinkable objects in our cache we should actively try
> to shrink.
> 
> It works great in situations in which we have many objects (at least
> more than 100), because the aproximation errors will be negligible. But
> if this is not the case, specially when total_objects < 100, we may end
> up concluding that we have no objects at all (total / 100 = 0,  if total
> < 100).
> 
> This is certainly not the biggest killer in the world, but may matter in
> very low kernel memory situations.
> 
> [ v2: fix it for all occurrences of sysctl_vfs_cache_pressure ]
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Dave Chinner <david@fromorbit.com>
> CC: "Theodore Ts'o" <tytso@mit.edu>
> CC: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  fs/gfs2/glock.c        | 2 +-
>  fs/gfs2/quota.c        | 2 +-
>  fs/mbcache.c           | 2 +-
>  fs/nfs/dir.c           | 2 +-
>  fs/quota/dquot.c       | 5 ++---
>  fs/super.c             | 2 +-
>  fs/xfs/xfs_qm.c        | 2 +-
>  include/linux/dcache.h | 4 ++++
>  8 files changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
> index 0f22d09..b2b65dc 100644
> --- a/fs/gfs2/glock.c
> +++ b/fs/gfs2/glock.c
> @@ -1415,7 +1415,7 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
>  	atomic_add(nr_skipped, &lru_count);
>  	spin_unlock(&lru_lock);
>  out:
> -	return (atomic_read(&lru_count) / 100) * sysctl_vfs_cache_pressure;
> +	return vfs_pressure_ratio(atomic_read(&lru_count));
>  }
>  
>  static struct shrinker glock_shrinker = {
> diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
> index c5af8e1..fcc92de 100644
> --- a/fs/gfs2/quota.c
> +++ b/fs/gfs2/quota.c
> @@ -117,7 +117,7 @@ int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
>  	spin_unlock(&qd_lru_lock);
>  
>  out:
> -	return (atomic_read(&qd_lru_count) * sysctl_vfs_cache_pressure) / 100;
> +	return vfs_pressure_ratio(atomic_read(&qd_lru_count));
>  }
>  
>  static u64 qd2offset(struct gfs2_quota_data *qd)
> diff --git a/fs/mbcache.c b/fs/mbcache.c
> index 8c32ef3..5eb0476 100644
> --- a/fs/mbcache.c
> +++ b/fs/mbcache.c
> @@ -189,7 +189,7 @@ mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
>  	list_for_each_entry_safe(entry, tmp, &free_list, e_lru_list) {
>  		__mb_cache_entry_forget(entry, gfp_mask);
>  	}
> -	return (count / 100) * sysctl_vfs_cache_pressure;
> +	return vfs_pressure_ratio(count);
>  }
>  
>  
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b9e66b7..6002971 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1950,7 +1950,7 @@ remove_lru_entry:
>  	}
>  	spin_unlock(&nfs_access_lru_lock);
>  	nfs_access_free_list(&head);
> -	return (atomic_long_read(&nfs_access_nr_entries) / 100) * sysctl_vfs_cache_pressure;
> +	return vfs_pressure_ratio(atomic_long_read(&nfs_access_nr_entries));
>  }
>  
>  static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
> diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
> index 05ae3c9..f90bdf2 100644
> --- a/fs/quota/dquot.c
> +++ b/fs/quota/dquot.c
> @@ -719,9 +719,8 @@ static int shrink_dqcache_memory(struct shrinker *shrink,
>  		prune_dqcache(nr);
>  		spin_unlock(&dq_list_lock);
>  	}
> -	return ((unsigned)
> -		percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS])
> -		/100) * sysctl_vfs_cache_pressure;
> +	return vfs_pressure_ratio(
> +	percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS]));
>  }
>  
>  static struct shrinker dqcache_shrinker = {
> diff --git a/fs/super.c b/fs/super.c
> index 12f1237..1302f63 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -104,7 +104,7 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
>  				sb->s_nr_inodes_unused + fs_objects;
>  	}
>  
> -	total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
> +	total_objects = vfs_pressure_ratio(total_objects);
>  	drop_super(sb);
>  	return total_objects;
>  }
> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index 2e86fa0..269ca79 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -1566,7 +1566,7 @@ xfs_qm_shake(
>  	}
>  
>  out:
> -	return (qi->qi_lru_count / 100) * sysctl_vfs_cache_pressure;
> +	return vfs_pressure_ratio(qi->qi_lru_count);
>  }
>  
>  /*
> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
> index 5920079..f30006c 100644
> --- a/include/linux/dcache.h
> +++ b/include/linux/dcache.h
> @@ -417,4 +417,8 @@ extern void d_clear_need_lookup(struct dentry *dentry);
>  
>  extern int sysctl_vfs_cache_pressure;
>  
> +static inline unsigned long vfs_pressure_ratio(unsigned long val)
> +{
> +	return mult_frac(val, sysctl_vfs_cache_pressure, 100);
> +}
>  #endif	/* __LINUX_DCACHE_H */
> -- 
> 1.7.11.7
> 

Looks Good,

Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
-- 
Carlos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
