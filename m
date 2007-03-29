In-reply-to: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
	(message from Hugh Dickins on Wed, 28 Mar 2007 15:50:03 +0100 (BST))
Subject: Re: [PATCH 1/4] holepunch: fix shmem_truncate_range punching too far
References: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
Message-Id: <E1HWsJq-0000vz-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 29 Mar 2007 12:57:26 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com
Cc: akpm@linux-foundation.org, mszeredi@suse.cz, pbadari@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Miklos Szeredi observes BUG_ON(!entry) in shmem_writepage() triggered
> in rare circumstances, because shmem_truncate_range() erroneously
> removes partially truncated directory pages at the end of the range:
> later reclaim on pages pointing to these removed directories triggers
> the BUG.  Indeed, and it can also cause data loss beyond the hole.
> 
> Fix this as in the patch proposed by Miklos, but distinguish between
> "limit" (how far we need to search: ignore truncation's next_index
> optimization in the holepunch case - if there are races it's more
> consistent to act on the whole range specified) and "upper_limit"
> (how far we can free directory pages: generally we must be careful
> to keep partially punched pages, but can relax at end of file -
> i_size being held stable by i_mutex).
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> Cc: Miklos Szeredi <mszeredi@suse.cs>
> Cc: Badari Pulavarty <pbadari@us.ibm.com>
> ---
> Patch is against 2.6.21-rc5: intended for 2.6.21.
> To apply this series to -mm, please first revert Miklos'
> shmem-dont-release-lock-for-hole-punching.patch
> shmem-fix-bug-in-shmem_writepage.patch
> which these replace.
> 
>  mm/shmem.c |   32 +++++++++++++++++++++-----------
>  1 file changed, 21 insertions(+), 11 deletions(-)
> 
> --- 2.6.21-rc5/mm/shmem.c	2007-03-07 13:09:01.000000000 +0000
> +++ punch1/mm/shmem.c	2007-03-28 11:50:57.000000000 +0100
> @@ -481,7 +481,8 @@ static void shmem_truncate_range(struct 
>  	long nr_swaps_freed = 0;
>  	int offset;
>  	int freed;
> -	int punch_hole = 0;
> +	int punch_hole;
> +	unsigned long upper_limit;
>  
>  	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
>  	idx = (start + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
> @@ -492,11 +493,18 @@ static void shmem_truncate_range(struct 
>  	info->flags |= SHMEM_TRUNCATE;
>  	if (likely(end == (loff_t) -1)) {
>  		limit = info->next_index;
> +		upper_limit = SHMEM_MAX_INDEX;
>  		info->next_index = idx;
> +		punch_hole = 0;
>  	} else {
> -		limit = (end + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
> -		if (limit > info->next_index)
> -			limit = info->next_index;
> +		if (end + 1 >= inode->i_size) {	/* we may free a little more */

Why end + 1?  If the hole end is at 4096 and the file size is 4097 we
surely don't want to truncate that second page also?

Otherwise ACK.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
