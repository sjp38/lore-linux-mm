Date: Mon, 22 Oct 2007 14:29:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 13/14] dentries: Extract common code to remove dentry
 from lru
Message-Id: <20071022142939.1b815680.akpm@linux-foundation.org>
In-Reply-To: <20070925233008.523093726@sgi.com>
References: <20070925232543.036615409@sgi.com>
	<20070925233008.523093726@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007 16:25:56 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> Extract the common code to remove a dentry from the lru into a new function
> dentry_lru_remove().
> 
> Two call sites used list_del() instead of list_del_init(). AFAIK the
> performance of both is the same. dentry_lru_remove() does a list_del_init().

list_del() will dirty two cachelines, but list_del_init() needs to dirty a
third, by writing to the to-be-removed list_head().

> As a result dentry->d_lru is now always empty when a dentry is freed.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  fs/dcache.c |   42 ++++++++++++++----------------------------
>  1 files changed, 14 insertions(+), 28 deletions(-)
> 
> Index: linux-2.6.23-rc8-mm1/fs/dcache.c
> ===================================================================
> --- linux-2.6.23-rc8-mm1.orig/fs/dcache.c	2007-09-25 14:53:57.000000000 -0700
> +++ linux-2.6.23-rc8-mm1/fs/dcache.c	2007-09-25 14:57:09.000000000 -0700
> @@ -95,6 +95,14 @@ static void d_free(struct dentry *dentry
>  		call_rcu(&dentry->d_u.d_rcu, d_callback);
>  }
>  
> +static void dentry_lru_remove(struct dentry *dentry)
> +{
> +	if (!list_empty(&dentry->d_lru)) {
> +		list_del_init(&dentry->d_lru);
> +		dentry_stat.nr_unused--;
> +	}
> +}

So can we switch this to list_del()?

>  /*
>   * Release the dentry's inode, using the filesystem
>   * d_iput() operation if defined.
> @@ -212,13 +220,7 @@ repeat:
>  unhash_it:
>  	__d_drop(dentry);
>  kill_it:
> -	/* If dentry was on d_lru list
> -	 * delete it from there
> -	 */
> -	if (!list_empty(&dentry->d_lru)) {
> -		list_del(&dentry->d_lru);
> -		dentry_stat.nr_unused--;
> -	}
> +	dentry_lru_remove(dentry);
>  	dentry = d_kill(dentry);
>  	if (dentry)
>  		goto repeat;
> @@ -286,10 +288,7 @@ int d_invalidate(struct dentry * dentry)
>  static inline struct dentry * __dget_locked(struct dentry *dentry)
>  {
>  	atomic_inc(&dentry->d_count);
> -	if (!list_empty(&dentry->d_lru)) {
> -		dentry_stat.nr_unused--;
> -		list_del_init(&dentry->d_lru);
> -	}

No, we can't.

> +	dentry_lru_remove(dentry);
>  	return dentry;
>  }
>  
> @@ -405,10 +404,7 @@ static void prune_one_dentry(struct dent
>  
>  		if (dentry->d_op && dentry->d_op->d_delete)
>  			dentry->d_op->d_delete(dentry);
> -		if (!list_empty(&dentry->d_lru)) {
> -			list_del(&dentry->d_lru);
> -			dentry_stat.nr_unused--;
> -		}
> +		dentry_lru_remove(dentry);
>  		__d_drop(dentry);
>  		dentry = d_kill(dentry);
>  		spin_lock(&dcache_lock);
> @@ -597,10 +593,7 @@ static void shrink_dcache_for_umount_sub
>  
>  	/* detach this root from the system */
>  	spin_lock(&dcache_lock);
> -	if (!list_empty(&dentry->d_lru)) {
> -		dentry_stat.nr_unused--;
> -		list_del_init(&dentry->d_lru);
> -	}
> +	dentry_lru_remove(dentry);
>  	__d_drop(dentry);
>  	spin_unlock(&dcache_lock);
>  
> @@ -614,11 +607,7 @@ static void shrink_dcache_for_umount_sub
>  			spin_lock(&dcache_lock);
>  			list_for_each_entry(loop, &dentry->d_subdirs,
>  					    d_u.d_child) {
> -				if (!list_empty(&loop->d_lru)) {
> -					dentry_stat.nr_unused--;
> -					list_del_init(&loop->d_lru);
> -				}
> -
> +				dentry_lru_remove(dentry);
>  				__d_drop(loop);
>  				cond_resched_lock(&dcache_lock);
>  			}
> @@ -800,10 +789,7 @@ resume:
>  		struct dentry *dentry = list_entry(tmp, struct dentry, d_u.d_child);
>  		next = tmp->next;
>  
> -		if (!list_empty(&dentry->d_lru)) {
> -			dentry_stat.nr_unused--;
> -			list_del_init(&dentry->d_lru);
> -		}
> +		dentry_lru_remove(dentry);

Doesn't seem like a terribly good change to me - it's one of those
cant-measure-a-difference changes which add up to a slower kernel after
we've merged three years worth of them.

Perhaps not all of those list_del_init() callers actually need to be using
the _init version?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
