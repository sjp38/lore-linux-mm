Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E2E4E6B003D
	for <linux-mm@kvack.org>; Tue, 14 May 2013 03:11:01 -0400 (EDT)
Date: Tue, 14 May 2013 17:10:46 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 04/31] dcache: remove dentries from LRU before putting
 on dispose list
Message-ID: <20130514071046.GH29466@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <1368382432-25462-5-git-send-email-glommer@openvz.org>
 <20130514054640.GE29466@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130514054640.GE29466@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Tue, May 14, 2013 at 03:46:40PM +1000, Dave Chinner wrote:
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
> dentry_lru_del() has to handle the DCACHE_SHRINK_LIST case
> differently because the dentry isn't on the LRU list.
> 
> [ v2: don't decrement nr unused twice, spotted by Sha Zhengju ]
> [ v7: (dchinner)
> - shrink list leaks dentries when inode/parent can't be locked in
>   dentry_kill().
> - fix the scope of the sb locking inside shrink_dcache_sb()

<sigh>

I need find a dealer that sells better crack.

> @@ -883,9 +923,16 @@ void shrink_dcache_sb(struct super_block *sb)
>  
>  	spin_lock(&sb->s_dentry_lru_lock);
>  	while (!list_empty(&sb->s_dentry_lru)) {
> -		list_splice_init(&sb->s_dentry_lru, &tmp);
> +		/*
> +		 * account for removal here so we don't need to handle it later
> +		 * even though the dentry is no longer on the lru list.
> +		 */
>  		spin_unlock(&sb->s_dentry_lru_lock);
> -		shrink_dentry_list(&tmp);
> +		list_splice_init(&sb->s_dentry_lru, &tmp);
> +		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
> +		sb->s_nr_dentry_unused = 0;
> +
> +		shrink_dcache_list(&tmp);
>  		spin_lock(&sb->s_dentry_lru_lock);

This is now completely wrong. It should end up like this:

	while (!list_empty(&sb->s_dentry_lru)) {
		/*
		 * account for removal here so we don't need to handle it later
		 * even though the dentry is no longer on the lru list.
		 */
		list_splice_init(&sb->s_dentry_lru, &tmp);
		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
		sb->s_nr_dentry_unused = 0;
		spin_unlock(&sb->s_dentry_lru_lock);

		shrink_dcache_list(&tmp);

		spin_lock(&sb->s_dentry_lru_lock);
	}
	spin_unlock(&sb->s_dentry_lru_lock);

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
