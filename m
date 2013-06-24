Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 4B78F6B0034
	for <linux-mm@kvack.org>; Sun, 23 Jun 2013 22:53:24 -0400 (EDT)
Date: Mon, 24 Jun 2013 12:52:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] list_lru: remove special case function
 list_lru_dispose_all.
Message-ID: <20130624025259.GK29376@dastard>
References: <1371992544-17152-1-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371992544-17152-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, fs-devel <linux-fsdevel@vger.kernel.org>, Glauber Costa <glommer@openvz.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>

On Sun, Jun 23, 2013 at 09:02:24AM -0400, Glauber Costa wrote:
> The list_lru implementation has one function, list_lru_dispose_all, with only
> one user (the dentry code). At first, such function appears to make sense
> because we are really not interested in the result of isolating each dentry
> separately - all of them are going away anyway. However, it's implementation
> is buggy in the following way:
> 
> When we call list_lru_dispose_all in fs/dcache.c, we scan all dentries marking
> them with DCACHE_SHRINK_LIST. However, this is done without the nlru->lock
> taken.  The imediate result of that is that someone else may add or remove the
> dentry from the LRU at the same time. When list_lru_del happens in that
> scenario we will see an element that is not yet marked with DCACHE_SHRINK_LIST
> (even though it will be in the future) and obviously remove it from an lru
> where the element no longer is. Since list_lru_dispose_all will in effect count
> down nlru's  nr_items and list_lru_del will do the same, this will lead to an
> imbalance.
> 
> The solution for this would not be so simple: we can obviously just keep the
> lru_lock taken, but then we have no guarantees that we will be able to acquire
> the dentry lock (dentry->d_lock). To properly solve this, we need a
> communication mechanism between the lru and dentry code, so they can coordinate
> this with each other.
> 
> Such mechanism already exists in the form of the list_lru_walk_cb callback. So
> it is possible to construct a dcache-side prune function that does the right
> thing only by calling list_lru_walk in a loop until no more dentries are
> available.
> 
> With only one user, plus the fact that a sane solution for the problem would
> involve boucing between dcache and list_lru anyway, I see little justification
> to keep the special case list_lru_dispose_all in tree.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Chinner <dchinner@redhat.com>

Yes, that's a problem that needs fixing, and it is the right way to
do it. It's the same reason that xfs_wait_buftarg() uses
list_lru_walk() for this "dispose of all objects" operation, and now
the code matches ;)

Acked-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
