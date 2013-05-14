Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id EAB8C6B0002
	for <linux-mm@kvack.org>; Tue, 14 May 2013 16:32:46 -0400 (EDT)
Date: Wed, 15 May 2013 06:32:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 04/31] dcache: remove dentries from LRU before putting
 on dispose list
Message-ID: <20130514203241.GJ29466@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <1368382432-25462-5-git-send-email-glommer@openvz.org>
 <20130514054640.GE29466@dastard>
 <51923158.7040002@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51923158.7040002@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Tue, May 14, 2013 at 04:43:04PM +0400, Glauber Costa wrote:
> On 05/14/2013 09:46 AM, Dave Chinner wrote:
> > [ v2: don't decrement nr unused twice, spotted by Sha Zhengju ]
> > [ v7: (dchinner)
> > - shrink list leaks dentries when inode/parent can't be locked in
> >   dentry_kill().
> > - fix the scope of the sb locking inside shrink_dcache_sb()
> > - remove the readdition of dentry_lru_prune(). ]
> 
> Dave,
> 
> dentry_lru_prune was removed because it would only prune the dentry if
> it was in the LRU list, and it has to be always pruned (61572bb1).
> 
> You don't reintroduce dentry_lru_prune here, so the two locations which
> prune dentries read as follows:
> 
> 
>         if (dentry->d_flags & DCACHE_OP_PRUNE)
>                 dentry->d_op->d_prune(dentry);
> 
>         dentry_lru_del(dentry);
> 
> I believe this is wrong. My old version would do:
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
> 
> Which is SHRINK_LIST aware.

Right. Did I mention I was seeing a panic on a later patch? That's
because this patch removed the DCACHE_SHRINK_LIST check. So, the
DCACHE_SHRINK_LIST needs to move into dentry_lru_del(), and
dentry_lru_prune() can still go away. That's what my current version
of this patch does - I just didn't post it last night because it was
still running tests when I went to bed....

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
