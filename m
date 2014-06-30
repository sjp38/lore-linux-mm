Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5E55A6B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 19:02:15 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so9422398pab.4
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 16:02:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gp6si24696841pac.215.2014.06.30.16.02.14
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 16:02:14 -0700 (PDT)
Date: Mon, 30 Jun 2014 16:02:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH mmotm/next] mm: memcontrol: rewrite charge API: fix
 shmem_unuse
Message-Id: <20140630160212.46caf9c3d41445b61fece666@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1406301541420.4349@eggly.anvils>
References: <alpine.LSU.2.11.1406301541420.4349@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 30 Jun 2014 15:48:39 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> Under shmem swapping and swapoff load, I sometimes hit the
> VM_BUG_ON_PAGE(!page->mapping) in mem_cgroup_commit_charge() at
> mm/memcontrol.c:6502!  Each time it has been a call from shmem_unuse().
> 
> Yes, there are some cases (most commonly when the page being unswapped
> is in a file being unlinked and evicted at that time) when the charge
> should not be committed.  In the old scheme, the page got uncharged
> again on release; but in the new scheme, it hits that BUG beforehand.
> 
> It's a useful BUG, so adapt shmem_unuse() to allow for it.  Which needs
> more info from shmem_unuse_inode(): so abuse -EAGAIN internally to
> replace the previous !found state (-ENOENT would be a more natural
> code, but that's exactly what you get when the swap has been evicted).
> 
> ...
>
> --- 3.16-rc2-mm1/mm/shmem.c	2014-06-25 18:43:59.868588121 -0700
> +++ linux/mm/shmem.c	2014-06-30 15:05:50.736335600 -0700
> @@ -611,7 +611,7 @@ static int shmem_unuse_inode(struct shme
>  	radswap = swp_to_radix_entry(swap);
>  	index = radix_tree_locate_item(&mapping->page_tree, radswap);
>  	if (index == -1)
> -		return 0;
> +		return -EAGAIN;

Maybe it's time to document the shmem_unuse_inode() return values.

>  	/*
>  	 * Move _head_ to start search for next from here.
> @@ -670,7 +670,6 @@ static int shmem_unuse_inode(struct shme
>  			spin_unlock(&info->lock);
>  			swap_free(swap);
>  		}
> -		error = 1;	/* not an error, but entry was found */
>  	}
>  	return error;
>  }
> @@ -683,7 +682,6 @@ int shmem_unuse(swp_entry_t swap, struct
>  	struct list_head *this, *next;
>  	struct shmem_inode_info *info;
>  	struct mem_cgroup *memcg;
> -	int found = 0;
>  	int error = 0;
>  
>  	/*
> @@ -702,22 +700,24 @@ int shmem_unuse(swp_entry_t swap, struct
>  	if (error)
>  		goto out;
>  	/* No radix_tree_preload: swap entry keeps a place for page in tree */
> +	error = -EAGAIN;
>  
>  	mutex_lock(&shmem_swaplist_mutex);
>  	list_for_each_safe(this, next, &shmem_swaplist) {
>  		info = list_entry(this, struct shmem_inode_info, swaplist);
>  		if (info->swapped)
> -			found = shmem_unuse_inode(info, swap, &page);
> +			error = shmem_unuse_inode(info, swap, &page);
>  		else
>  			list_del_init(&info->swaplist);
>  		cond_resched();
> -		if (found)
> +		if (error != -EAGAIN)
>  			break;
>  	}
>  	mutex_unlock(&shmem_swaplist_mutex);
>  
> -	if (found < 0) {
> -		error = found;
> +	if (error) {
> +		if (error != -ENOMEM)
> +			error = 0;
>  		mem_cgroup_cancel_charge(page, memcg);
>  	} else
>  		mem_cgroup_commit_charge(page, memcg, true);

If I'm reading this correctly, shmem_unuse() can now return -EAGAIN and
that can get all the way back to userspace.  `man 2 swapoff' doesn't
know this...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
