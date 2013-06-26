Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 850E86B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 04:28:09 -0400 (EDT)
Date: Wed, 26 Jun 2013 10:28:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] inode: move inode to a different list inside lock
Message-ID: <20130626082807.GH28748@dhcp22.suse.cz>
References: <1372228181-18827-1-git-send-email-glommer@openvz.org>
 <1372228181-18827-2-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372228181-18827-2-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, dchinner@redhat.com, Glauber Costa <glommer@openvz.org>

On Wed 26-06-13 02:29:40, Glauber Costa wrote:
> When removing an element from the lru, this will be done today after the lock
> is released. This is a clear mistake, although we are not sure if the bugs we
> are seeing are related to this. All list manipulations are done inside the
> lock, and so should this one.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>

Yes this fixed BUG_ONs triggered during my testing (e.g. BUG at mm/list_lru.c:92)
Tested-by: Michal Hocko <mhocko@suse.cz>

> ---
>  fs/inode.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index a2b49c8..e315c0a 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -735,9 +735,9 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>  
>  	WARN_ON(inode->i_state & I_NEW);
>  	inode->i_state |= I_FREEING;
> +	list_move(&inode->i_lru, freeable);
>  	spin_unlock(&inode->i_lock);
>  
> -	list_move(&inode->i_lru, freeable);
>  	this_cpu_dec(nr_unused);
>  	return LRU_REMOVED;
>  }
> -- 
> 1.8.2.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
