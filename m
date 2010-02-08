Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 622AF6B0047
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 03:19:28 -0500 (EST)
Date: Mon, 8 Feb 2010 19:19:18 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 05/11] readahead: replace ra->mmap_miss with
 ra->ra_flags
Message-ID: <20100208081918.GD9781@laptop>
References: <20100207041013.891441102@intel.com>
 <20100207041043.429863034@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100207041043.429863034@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Andi Kleen <andi@firstfloor.org>, Steven Whitehouse <swhiteho@redhat.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 07, 2010 at 12:10:18PM +0800, Wu Fengguang wrote:
> Introduce a readahead flags field and embed the existing mmap_miss in it
> (to save space).

Is that the only reason? 
 
> It will be possible to lose the flags in race conditions, however the
> impact should be limited.

Is this really a good tradeoff? Randomly readahead behaviour can
change.

I never liked this mmap_miss counter, though. It doesn't seem like
it can adapt properly for changing mmap access patterns.

Is there any reason why the normal readahead algorithms can't
detect this kind of behaviour (in much fewer than 100 misses) and
also adapt much faster if the access changes?

> 
> CC: Nick Piggin <npiggin@suse.de>
> CC: Andi Kleen <andi@firstfloor.org>
> CC: Steven Whitehouse <swhiteho@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/fs.h |   30 +++++++++++++++++++++++++++++-
>  mm/filemap.c       |    7 ++-----
>  2 files changed, 31 insertions(+), 6 deletions(-)
> 
> --- linux.orig/include/linux/fs.h	2010-02-07 11:46:35.000000000 +0800
> +++ linux/include/linux/fs.h	2010-02-07 11:46:37.000000000 +0800
> @@ -892,10 +892,38 @@ struct file_ra_state {
>  					   there are only # of pages ahead */
>  
>  	unsigned int ra_pages;		/* Maximum readahead window */
> -	unsigned int mmap_miss;		/* Cache miss stat for mmap accesses */
> +	unsigned int ra_flags;
>  	loff_t prev_pos;		/* Cache last read() position */
>  };
>  
> +/* ra_flags bits */
> +#define	READAHEAD_MMAP_MISS	0x0000ffff /* cache misses for mmap access */
> +
> +/*
> + * Don't do ra_flags++ directly to avoid possible overflow:
> + * the ra fields can be accessed concurrently in a racy way.
> + */
> +static inline unsigned int ra_mmap_miss_inc(struct file_ra_state *ra)
> +{
> +	unsigned int miss = ra->ra_flags & READAHEAD_MMAP_MISS;
> +
> +	if (miss < READAHEAD_MMAP_MISS) {
> +		miss++;
> +		ra->ra_flags = miss | (ra->ra_flags &~ READAHEAD_MMAP_MISS);
> +	}
> +	return miss;
> +}
> +
> +static inline void ra_mmap_miss_dec(struct file_ra_state *ra)
> +{
> +	unsigned int miss = ra->ra_flags & READAHEAD_MMAP_MISS;
> +
> +	if (miss) {
> +		miss--;
> +		ra->ra_flags = miss | (ra->ra_flags &~ READAHEAD_MMAP_MISS);
> +	}
> +}
> +
>  /*
>   * Check if @index falls in the readahead windows.
>   */
> --- linux.orig/mm/filemap.c	2010-02-07 11:46:35.000000000 +0800
> +++ linux/mm/filemap.c	2010-02-07 11:46:37.000000000 +0800
> @@ -1418,14 +1418,12 @@ static void do_sync_mmap_readahead(struc
>  		return;
>  	}
>  
> -	if (ra->mmap_miss < INT_MAX)
> -		ra->mmap_miss++;
>  
>  	/*
>  	 * Do we miss much more than hit in this file? If so,
>  	 * stop bothering with read-ahead. It will only hurt.
>  	 */
> -	if (ra->mmap_miss > MMAP_LOTSAMISS)
> +	if (ra_mmap_miss_inc(ra) > MMAP_LOTSAMISS)
>  		return;
>  
>  	/*
> @@ -1455,8 +1453,7 @@ static void do_async_mmap_readahead(stru
>  	/* If we don't want any read-ahead, don't bother */
>  	if (VM_RandomReadHint(vma))
>  		return;
> -	if (ra->mmap_miss > 0)
> -		ra->mmap_miss--;
> +	ra_mmap_miss_dec(ra);
>  	if (PageReadahead(page))
>  		page_cache_async_readahead(mapping, ra, file,
>  					   page, offset, ra->ra_pages);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
