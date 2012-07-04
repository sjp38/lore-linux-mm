Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D92216B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 10:23:13 -0400 (EDT)
Date: Wed, 4 Jul 2012 16:23:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] Make TestSetPageDirty and dirty page accounting in
 one func
Message-ID: <20120704142309.GJ29842@tiehlicka.suse.cz>
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
 <1340881275-5651-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340881275-5651-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>, Nick Piggin <npiggin@kernel.dk>

[Add Nick to the CC]

On Thu 28-06-12 19:01:15, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Commit a8e7d49a(Fix race in create_empty_buffers() vs __set_page_dirty_buffers())
> extracts TestSetPageDirty from __set_page_dirty and is far away from
> account_page_dirtied.But it's better to make the two operations in one single
> function to keep modular.

> So in order to avoid the potential race mentioned in
> commit a8e7d49a, we can hold private_lock until __set_page_dirty completes.

So this is exactly what Nick suggested in the beginning
(https://lkml.org/lkml/2009/3/19/169)

> I guess there's no deadlock between ->private_lock and ->tree_lock by quick look.

Yes and mm/filemap.c says that explicitly:
 * Lock ordering:
 *
 *  ->i_mmap_mutex              (truncate_pagecache)
 *    ->private_lock            (__free_pte->__set_page_dirty_buffers)
 *      ->swap_lock             (exclusive_swap_page, others)
 *        ->mapping->tree_lock

> 
> It's a prepare patch for following memcg dirty page accounting patches.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

The patch seems to be correct.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  fs/buffer.c |   25 +++++++++++++------------
>  1 files changed, 13 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 838a9cf..e8d96b8 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -610,9 +610,15 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
>   * If warn is true, then emit a warning if the page is not uptodate and has
>   * not been truncated.
>   */
> -static void __set_page_dirty(struct page *page,
> +static int __set_page_dirty(struct page *page,
>  		struct address_space *mapping, int warn)
>  {
> +	if (unlikely(!mapping))
> +		return !TestSetPageDirty(page);
> +
> +	if (TestSetPageDirty(page))
> +		return 0;
> +
>  	spin_lock_irq(&mapping->tree_lock);
>  	if (page->mapping) {	/* Race with truncate? */
>  		WARN_ON_ONCE(warn && !PageUptodate(page));
> @@ -622,6 +628,8 @@ static void __set_page_dirty(struct page *page,
>  	}
>  	spin_unlock_irq(&mapping->tree_lock);
>  	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> +
> +	return 1;
>  }
>  
>  /*
> @@ -667,11 +675,9 @@ int __set_page_dirty_buffers(struct page *page)
>  			bh = bh->b_this_page;
>  		} while (bh != head);
>  	}
> -	newly_dirty = !TestSetPageDirty(page);
> +	newly_dirty = __set_page_dirty(page, mapping, 1);
>  	spin_unlock(&mapping->private_lock);
>  
> -	if (newly_dirty)
> -		__set_page_dirty(page, mapping, 1);
>  	return newly_dirty;
>  }
>  EXPORT_SYMBOL(__set_page_dirty_buffers);
> @@ -1115,14 +1121,9 @@ void mark_buffer_dirty(struct buffer_head *bh)
>  			return;
>  	}
>  
> -	if (!test_set_buffer_dirty(bh)) {
> -		struct page *page = bh->b_page;
> -		if (!TestSetPageDirty(page)) {
> -			struct address_space *mapping = page_mapping(page);
> -			if (mapping)
> -				__set_page_dirty(page, mapping, 0);
> -		}
> -	}
> +	if (!test_set_buffer_dirty(bh))
> +		__set_page_dirty(bh->b_page, page_mapping(bh->b_page), 0);
> +
>  }
>  EXPORT_SYMBOL(mark_buffer_dirty);
>  
> -- 
> 1.7.1
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
