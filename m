Date: Thu, 15 Mar 2007 19:35:06 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/2] shmem: fix BUG in shmem_writepage
In-Reply-To: <E1HRaWY-0001mn-00@dorka.pomaz.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0703151909410.7795@blonde.wat.veritas.com>
References: <E1HRaWY-0001mn-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de, badari@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 14 Mar 2007, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> BUG_ON(!entry) in shmem_writepage() is triggered in rare
> circumstances.
> 
> The cause is that shmem_truncate_range() erroneously removes partially
> truncated directory pages at the end of the range.  A later reclaim on
> pages pointing to these removed directories triggers the BUG.

Thanks a lot for reporting this, and your 2/2 I've appended below,
correcting the CC to linux-mm@kvack.org.

And congratulations on working out how to go about fixing it:
shmem_truncate was very much more comprehensible before I converted it
to kmap'ing highmem index pages.  I had very mixed feelings over the
result of that conversion, but it worked until punch_hole came along.

Yes, there's a bug in the freeing that I never noticed,
and yes there are races to which I turned a blind eye.

I cannot give you an ACK on these patches immediately, any more than
I could ACK the original buggy patch: I'll have to think through it
all myself in the next few days.  I hope it can be done a little
differently than with punch_hole tests all over.

But I'm happy for your patches to go into -mm for now - thanks.

(What I'd love is to throw away _all_ that shmem index code, and
use the pagecache's radixtree to store swapentries in place of
pagepointers when swapped out.  But that has the disadvantage
that the memory used can never be highmem - unless we code up
highmem radixtrees, which would be a very misdirected effort.
Plus I think I saw Andrew contemplating some other use for the
empty radixtree entries just a few days ago.  Anyway, the bugs
need to be fixed before any such rewrite.)

Hugh

> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---
> 
> Index: linux/mm/shmem.c
> ===================================================================
> --- linux.orig/mm/shmem.c	2007-03-14 20:12:48.000000000 +0100
> +++ linux/mm/shmem.c	2007-03-14 20:25:55.000000000 +0100
> @@ -543,7 +543,9 @@ static void shmem_truncate_range(struct 
>  		if (*dir) {
>  			diroff = ((idx - ENTRIES_PER_PAGEPAGE/2) %
>  				ENTRIES_PER_PAGEPAGE) / ENTRIES_PER_PAGE;
> -			if (!diroff && !offset) {
> +			if (!diroff && !offset &&
> +			    (!punch_hole ||
> +			     limit - idx >= ENTRIES_PER_PAGEPAGE)) {
>  				*dir = NULL;
>  				nr_pages_to_free++;
>  				list_add(&middir->lru, &pages_to_free);
> @@ -570,9 +572,12 @@ static void shmem_truncate_range(struct 
>  			}
>  			stage = idx + ENTRIES_PER_PAGEPAGE;
>  			middir = *dir;
> -			*dir = NULL;
> -			nr_pages_to_free++;
> -			list_add(&middir->lru, &pages_to_free);
> +			if (!punch_hole ||
> +			    limit - idx >= ENTRIES_PER_PAGEPAGE) {
> +				*dir = NULL;
> +				nr_pages_to_free++;
> +				list_add(&middir->lru, &pages_to_free);
> +			}
>  			shmem_dir_unmap(dir);
>  			cond_resched();
>  			dir = shmem_dir_map(middir);
> @@ -598,7 +603,8 @@ static void shmem_truncate_range(struct 
>  		}
>  		if (offset)
>  			offset = 0;
> -		else if (subdir && !page_private(subdir)) {
> +		else if (subdir && 
> +			 (!punch_hole || limit - idx >= ENTRIES_PER_PAGE)) {
>  			dir[diroff] = NULL;
>  			nr_pages_to_free++;
>  			list_add(&subdir->lru, &pages_to_free);

> Subject: Re: [PATCH 2/2] shmem: don't release lock for hole punching
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> During truncation of shmem page directories, info->lock is released to
> improve latency.  But this is wrong for hole punching, because the
> memory areas being operated on are still in use by shmem_unuse,
> shmem_getpage and shmem_writepage.
> 
> So for hole punching don't release the lock.  Users of MADV_REMOVE
> likely don't care about latency anyway.  But this function really
> wants a cleanup, and with that latency could also be taken care of.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---
> 
> Index: linux/mm/shmem.c
> ===================================================================
> --- linux.orig/mm/shmem.c	2007-03-14 21:06:52.000000000 +0100
> +++ linux/mm/shmem.c	2007-03-14 21:15:54.000000000 +0100
> @@ -421,7 +421,7 @@ static int shmem_free_swp(swp_entry_t *d
>  }
>  
>  static int shmem_map_and_free_swp(struct page *subdir,
> -		int offset, int limit, struct page ***dir)
> +		int offset, int limit, struct page ***dir, int punch_hole)
>  {
>  	swp_entry_t *ptr;
>  	int freed = 0;
> @@ -429,10 +429,10 @@ static int shmem_map_and_free_swp(struct
>  	ptr = shmem_swp_map(subdir);
>  	for (; offset < limit; offset += LATENCY_LIMIT) {
>  		int size = limit - offset;
> -		if (size > LATENCY_LIMIT)
> +		if (!punch_hole && size > LATENCY_LIMIT)
>  			size = LATENCY_LIMIT;
>  		freed += shmem_free_swp(ptr+offset, ptr+offset+size);
> -		if (need_resched()) {
> +		if (!punch_hole && need_resched()) {
>  			shmem_swp_unmap(ptr);
>  			if (*dir) {
>  				shmem_dir_unmap(*dir);
> @@ -506,7 +506,8 @@ static void shmem_truncate_range(struct 
>  		nr_pages_to_free++;
>  		list_add(&topdir->lru, &pages_to_free);
>  	}
> -	spin_unlock(&info->lock);
> +	if (!punch_hole)
> +		spin_unlock(&info->lock);
>  
>  	if (info->swapped && idx < SHMEM_NR_DIRECT) {
>  		ptr = info->i_direct;
> @@ -589,14 +590,14 @@ static void shmem_truncate_range(struct 
>  			if (size > ENTRIES_PER_PAGE)
>  				size = ENTRIES_PER_PAGE;
>  			freed = shmem_map_and_free_swp(subdir,
> -						offset, size, &dir);
> +					offset, size, &dir, punch_hole);
>  			if (!dir)
>  				dir = shmem_dir_map(middir);
>  			nr_swaps_freed += freed;
> -			if (offset)
> +			if (offset && !punch_hole)
>  				spin_lock(&info->lock);
>  			set_page_private(subdir, page_private(subdir) - freed);
> -			if (offset)
> +			if (offset && !punch_hole)
>  				spin_unlock(&info->lock);
>  			if (!punch_hole)
>  				BUG_ON(page_private(subdir) > offset);
> @@ -613,6 +614,8 @@ static void shmem_truncate_range(struct 
>  done1:
>  	shmem_dir_unmap(dir);
>  done2:
> +	if (punch_hole)
> +		spin_unlock(&info->lock);
>  	if (inode->i_mapping->nrpages && (info->flags & SHMEM_PAGEIN)) {
>  		/*
>  		 * Call truncate_inode_pages again: racing shmem_unuse_inode

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
