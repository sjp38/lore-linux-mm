Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31D966B047E
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 16:27:19 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so274164789pga.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 13:27:19 -0800 (PST)
Received: from mail-pg0-x22b.google.com (mail-pg0-x22b.google.com. [2607:f8b0:400e:c05::22b])
        by mx.google.com with ESMTPS id r4si9866398pgr.239.2016.11.18.13.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 13:27:18 -0800 (PST)
Received: by mail-pg0-x22b.google.com with SMTP id p66so106690082pga.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 13:27:18 -0800 (PST)
Date: Fri, 18 Nov 2016 13:26:59 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: support anonymous stable page
In-Reply-To: <20161118065820.GA7277@bbox>
Message-ID: <alpine.LSU.2.11.1611181258530.9347@eggly.anvils>
References: <1478842202-24009-1-git-send-email-minchan@kernel.org> <20161111060644.GA24342@bbox> <alpine.LSU.2.11.1611171950250.7304@eggly.anvils> <20161118065820.GA7277@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>

On Fri, 18 Nov 2016, Minchan Kim wrote:
> On Thu, Nov 17, 2016 at 08:35:10PM -0800, Hugh Dickins wrote:
> > 
> > Maybe add SWP_STABLE_WRITES in include/linux/swap.h, and set that
> > in swap_info->flags according to bdi_cap_stable_pages_required(),
> > leaving mapping->host itself NULL as before?
> 
> The problem with the approach is that we need to get swap_info_struct
> in reuse_swap_page so maybe, every caller should pass swp_entry_t
> into reuse_swap_page. It would be no problem if swap slot is really
> referenced the page(IOW, pte is real swp_entry_t) but some cases
> where swap slot is already empty but the page remains in only
> swap cache, we cannot pass swp_entry_t which means that we cannot
> get swap_info_struct.

I don't see the problem: if the page is PageSwapCache (and page
lock is held), then the swp_entry_t is there in page->private:
see page_swapcount(), which reuse_swap_page() just called.

> 
> So, if I didn't miss, another option I can imagine is to move
> SWP_STABLE_WRITES to address_space->flags as AS_STABLE_WRITES.
> With that, we can always get the information without passing
> swp_entry_t. Is there any better idea?

I think what you suggest below would work fine (and be quicker
than looking up the swap_info again): but is horribly misleading
for anyone else interested in stable writes, for whom the info is
kept in the bdi, and not in this new mapping flag.

So I'd much prefer that you keep the swap special case inside the
world of swap, with a SWP_STABLE_WRITES flag.  Maybe unfold
page_swapcount() inside reuse_swap_page(), so that it only
needs a single lookup (or perhaps I'm optimizing prematurely).

Hugh

> 
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index dd15d39e1985..5397e82bfd57 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -26,6 +26,8 @@ enum mapping_flags {
>  	AS_EXITING	= 4, 	/* final truncate in progress */
>  	/* writeback related tags are not used */
>  	AS_NO_WRITEBACK_TAGS = 5,
> +	/* need stable write for swap */
> +	AS_STABLE_WRITES = 6,
>  };
>  
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> @@ -55,6 +57,21 @@ static inline int mapping_unevictable(struct address_space *mapping)
>  	return !!mapping;
>  }
>  
> +static inline void mapping_set_stable(struct address_space *mapping)
> +{
> +	set_bit(AS_STABLE_WRITES, &mapping->flags);
> +}
> +
> +static inline void mapping_clear_stable(struct address_space *mapping)
> +{
> +	clear_bit(AS_STABLE_WRITES, &mapping->flags);
> +}
> +
> +static inline int mapping_stable(struct address_space *mapping)
> +{
> +	return test_bit(AS_STABLE_WRITES, &mapping->flags);
> +}
> +
>  static inline void mapping_set_exiting(struct address_space *mapping)
>  {
>  	set_bit(AS_EXITING, &mapping->flags);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 2210de290b54..0c31fd814933 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -943,11 +943,20 @@ bool reuse_swap_page(struct page *page, int *total_mapcount)
>  	count = page_trans_huge_mapcount(page, total_mapcount);
>  	if (count <= 1 && PageSwapCache(page)) {
>  		count += page_swapcount(page);
> -		if (count == 1 && !PageWriteback(page)) {
> +		if (count != 1)
> +			goto out;
> +		if (!PageWriteback(page)) {
>  			delete_from_swap_cache(page);
>  			SetPageDirty(page);
> +		} else {
> +			struct address_space *mapping;
> +
> +			mapping = page_mapping(page);
> +			if (mapping_stable(mapping))
> +				return false;
>  		}
>  	}
> +out:
>  	return count <= 1;
>  }
>  
> @@ -2386,6 +2395,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	unsigned long *frontswap_map = NULL;
>  	struct page *page = NULL;
>  	struct inode *inode = NULL;
> +	struct address_space *swapper_space;
>  
>  	if (swap_flags & ~SWAP_FLAGS_VALID)
>  		return -EINVAL;
> @@ -2447,6 +2457,13 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  		error = -ENOMEM;
>  		goto bad_swap;
>  	}
> +
> +	swapper_space = &swapper_spaces[p->type];
> +	if (bdi_cap_stable_pages_required(inode_to_bdi(inode)))
> +		mapping_set_stable(swapper_space);
> +	else
> +		mapping_clear_stable(swapper_space);
> +
>  	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
>  		int cpu;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
