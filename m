Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 6AC296B007D
	for <linux-mm@kvack.org>; Mon, 13 May 2013 22:02:51 -0400 (EDT)
Date: Tue, 14 May 2013 12:02:48 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 04/31] dcache: remove dentries from LRU before putting
 on dispose list
Message-ID: <20130514020248.GB29466@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <1368382432-25462-5-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368382432-25462-5-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Sun, May 12, 2013 at 10:13:25PM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> One of the big problems with modifying the way the dcache shrinker
> and LRU implementation works is that the LRU is abused in several
> ways. One of these is shrink_dentry_list().
> 
> Basically, we can move a dentry off the LRU onto a different list
> without doing any accounting changes, and then use dentry_lru_prune()
> to remove it from what-ever list it is now on to do the LRU
> accounting at that point.
> 
> This makes it -really hard- to change the LRU implementation. The
> use of the per-sb LRU lock serialises movement of the dentries
> between the different lists and the removal of them, and this is the
> only reason that it works. If we want to break up the dentry LRU
> lock and lists into, say, per-node lists, we remove the only
> serialisation that allows this lru list/dispose list abuse to work.
> 
> To make this work effectively, the dispose list has to be isolated
> from the LRU list - dentries have to be removed from the LRU
> *before* being placed on the dispose list. This means that the LRU
> accounting and isolation is completed before disposal is started,
> and that means we can change the LRU implementation freely in
> future.
> 
> This means that dentries *must* be marked with DCACHE_SHRINK_LIST
> when they are placed on the dispose list so that we don't think that
> parent dentries found in try_prune_one_dentry() are on the LRU when
> the are actually on the dispose list. This would result in
> accounting the dentry to the LRU a second time. Hence
> dentry_lru_prune() has to handle the DCACHE_SHRINK_LIST case
> differently because the dentry isn't on the LRU list.
> 
> [ v2: don't decrement nr unused twice, spotted by Sha Zhengju ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Acked-by: Mel Gorman <mgorman@suse.de>
> ---
>  fs/dcache.c | 93 ++++++++++++++++++++++++++++++++++++++++++++++---------------
>  1 file changed, 71 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 795c15d..868abf9 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -331,7 +331,6 @@ static void dentry_lru_add(struct dentry *dentry)
>  static void __dentry_lru_del(struct dentry *dentry)
>  {
>  	list_del_init(&dentry->d_lru);
> -	dentry->d_flags &= ~DCACHE_SHRINK_LIST;
>  	dentry->d_sb->s_nr_dentry_unused--;
>  	this_cpu_dec(nr_dentry_unused);
>  }
> @@ -341,6 +340,8 @@ static void __dentry_lru_del(struct dentry *dentry)
>   */
>  static void dentry_lru_del(struct dentry *dentry)
>  {
> +	BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
> +
>  	if (!list_empty(&dentry->d_lru)) {
>  		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
>  		__dentry_lru_del(dentry);
> @@ -348,15 +349,39 @@ static void dentry_lru_del(struct dentry *dentry)
>  	}
>  }
>  
> +static void dentry_lru_prune(struct dentry *dentry)
> +{
> +	/*
> +	 * inform the fs via d_prune that this dentry is about to be
> +	 * unhashed and destroyed.
> +	 */
> +	if (dentry->d_flags & DCACHE_OP_PRUNE)
> +		dentry->d_op->d_prune(dentry);
> +
> +	if (list_empty(&dentry->d_lru))
> +		return;
> +
> +	if ((dentry->d_flags & DCACHE_SHRINK_LIST)) {
> +		list_del_init(&dentry->d_lru);
> +		dentry->d_flags &= ~DCACHE_SHRINK_LIST;
> +	} else {
> +		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
> +		__dentry_lru_del(dentry);
> +		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
> +	}
> +}

Re-adding this function is wrong - it went away because the act of
calling ->d_prune is independent of the presence of the dentry on
the LRU.

> @@ -479,14 +504,8 @@ relock:
>  
>  	if (ref)
>  		dentry->d_count--;
> -	/*
> -	 * inform the fs via d_prune that this dentry is about to be
> -	 * unhashed and destroyed.
> -	 */
> -	if (dentry->d_flags & DCACHE_OP_PRUNE)
> -		dentry->d_op->d_prune(dentry);
>  
> -	dentry_lru_del(dentry);
> +	dentry_lru_prune(dentry);
>  	/* if it was on the hash then remove it */
>  	__d_drop(dentry);
>  	return d_kill(dentry, parent);

So this change is not necessary.

> @@ -914,14 +970,7 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
>  		do {
>  			struct inode *inode;
>  
> -			/*
> -			 * inform the fs that this dentry is about to be
> -			 * unhashed and destroyed.
> -			 */
> -			if (dentry->d_flags & DCACHE_OP_PRUNE)
> -				dentry->d_op->d_prune(dentry);
> -
> -			dentry_lru_del(dentry);
> +			dentry_lru_prune(dentry);
>  			__d_shrink(dentry);
>  
>  			if (dentry->d_count != 0) {

Nor is this one.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
