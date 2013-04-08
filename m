Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 07AE56B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 19:28:05 -0400 (EDT)
Date: Tue, 9 Apr 2013 09:28:03 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 10/28] dcache: convert to use new lru list
 infrastructure
Message-ID: <20130408232803.GD17758@dastard>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
 <1364548450-28254-11-git-send-email-glommer@parallels.com>
 <5162C2C4.7010807@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5162C2C4.7010807@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, hughd@google.com, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Apr 08, 2013 at 05:14:44PM +0400, Glauber Costa wrote:
> On 03/29/2013 01:13 PM, Glauber Costa wrote:
> > +	if (dentry->d_flags & DCACHE_REFERENCED) {
> > +		dentry->d_flags &= ~DCACHE_REFERENCED;
> > +		spin_unlock(&dentry->d_lock);
> > +
> > +		/*
> > +		 * XXX: this list move should be be done under d_lock. Need to
> > +		 * determine if it is safe just to do it under the lru lock.
> > +		 */
> > +		return 1;
> > +	}
> 
> I've carefully audited the list manipulations in dcache and determined
> this is safe. I've replaced the fixme string for the following text. Let
> me know if you believe this is not right.

....

> diff --git a/fs/dcache.c b/fs/dcache.c
> index a2fc76e..8e166a4 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -855,8 +855,23 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>  		spin_unlock(&dentry->d_lock);
>  
>  		/*
> -		 * XXX: this list move should be be done under d_lock. Need to
> -		 * determine if it is safe just to do it under the lru lock.
> +		 * The list move itself will be made by the common LRU code. At
> +		 * this point, we've dropped the dentry->d_lock but keep the
> +		 * lru lock. This is safe to do, since every list movement is
> +		 * protected by the lru lock even if both locks are held.
> +		 *
> +		 * This is guaranteed by the fact that all LRU management
> +		 * functions are intermediated by the LRU API calls like
> +		 * list_lru_add and list_lru_del. List movement in this file
> +		 * only ever occur through this functions or through callbacks
> +		 * like this one, that are called from the LRU API.
> +		 *
> +		 * The only exceptions to this are functions like
> +		 * shrink_dentry_list, and code that first checks for the
> +		 * DCACHE_SHRINK_LIST flag.  Those are guaranteed to be
> +		 * operating only with stack provided lists after they are
> +		 * properly isolated from the main list.  It is thus, always a
> +		 * local access.
>  		 */
>  		return LRU_ROTATE;

It looks correct - I just never got around to doing the audit to
determine it was. Thanks!

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
