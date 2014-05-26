Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BB7286B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 15:36:59 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so7962776pad.18
        for <linux-mm@kvack.org>; Mon, 26 May 2014 12:36:59 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id lc8si15986831pab.180.2014.05.26.12.36.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 May 2014 12:36:58 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so7993398pab.38
        for <linux-mm@kvack.org>; Mon, 26 May 2014 12:36:58 -0700 (PDT)
Date: Mon, 26 May 2014 12:35:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/5] mm/rmap: share the i_mmap_rwsem
In-Reply-To: <1400816006-3083-5-git-send-email-davidlohr@hp.com>
Message-ID: <alpine.LSU.2.11.1405261216460.3411@eggly.anvils>
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com> <1400816006-3083-5-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 22 May 2014, Davidlohr Bueso wrote:

> Similarly to rmap_walk_anon() and collect_procs_anon(),
> there is opportunity to share the lock in rmap_walk_file()
> and collect_procs_file() for file backed pages.

And lots of other places, no?  I welcome i_mmap_rwsem, but I think
you're approaching it wrongly to separate this off from 2/5, then
follow anon_vma for the places that can be converted to lock_read().

If you go back through 2/5 and study the context of each, I think
you'll find most make no modification to the tree, and can well
use the lock_read() rather than the lock_write().

I could be wrong, but I don't think there are any hidden gotchas.
There certainly are in the anon_vma case (where THP makes special
use of the anon_vma lock), and used to be in the i_mmap_lock case
(when invalidation had to be single-threaded across cond_rescheds),
but I think i_mmap_rwsem should be straightforward.

Sure, it's safe to use the lock_write() variant, but please don't
prefer it to lock_read() without good reason.

Hugh

> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  include/linux/fs.h  | 10 ++++++++++
>  mm/memory-failure.c |  4 ++--
>  mm/rmap.c           |  4 ++--
>  3 files changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 60a1d7d..4c2c228 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -467,6 +467,16 @@ static inline void i_mmap_unlock_write(struct address_space *mapping)
>  	up_write(&mapping->i_mmap_rwsem);
>  }
>  
> +static inline void i_mmap_lock_read(struct address_space *mapping)
> +{
> +	down_read(&mapping->i_mmap_rwsem);
> +}
> +
> +static inline void i_mmap_unlock_read(struct address_space *mapping)
> +{
> +	up_read(&mapping->i_mmap_rwsem);
> +}
> +
>  /*
>   * Might pages of this file be mapped into userspace?
>   */
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 1389a28..acbcd8e 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -434,7 +434,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
>  	struct task_struct *tsk;
>  	struct address_space *mapping = page->mapping;
>  
> -	i_mmap_lock_write(mapping);
> +	i_mmap_lock_read(mapping);
>  	read_lock(&tasklist_lock);
>  	for_each_process(tsk) {
>  		pgoff_t pgoff = page_pgoff(page);
> @@ -456,7 +456,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
>  		}
>  	}
>  	read_unlock(&tasklist_lock);
> -	i_mmap_unlock_write(mapping);
> +	i_mmap_unlock_read(mapping);
>  }
>  
>  /*
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 9a56e4f..5841dcb 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1685,7 +1685,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
>  
>  	if (!mapping)
>  		return ret;
> -	i_mmap_lock_write(mapping);
> +	i_mmap_lock_read(mapping);
>  	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>  		unsigned long address = vma_address(page, vma);
>  
> @@ -1708,7 +1708,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
>  	ret = rwc->file_nonlinear(page, mapping, rwc->arg);
>  
>  done:
> -	i_mmap_unlock_write(mapping);
> +	i_mmap_unlock_read(mapping);
>  	return ret;
>  }
>  
> -- 
> 1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
