Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B790D6B039D
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 23:35:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e9so235257479pgc.5
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 20:35:20 -0800 (PST)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id m1si6224795pge.100.2016.11.17.20.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 20:35:19 -0800 (PST)
Received: by mail-pg0-x235.google.com with SMTP id 3so98844702pgd.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 20:35:19 -0800 (PST)
Date: Thu, 17 Nov 2016 20:35:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: support anonymous stable page
In-Reply-To: <20161111060644.GA24342@bbox>
Message-ID: <alpine.LSU.2.11.1611171950250.7304@eggly.anvils>
References: <1478842202-24009-1-git-send-email-minchan@kernel.org> <20161111060644.GA24342@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Darrick J . Wong" <darrick.wong@oracle.com>

On Fri, 11 Nov 2016, Minchan Kim wrote:
> Sorry for sending a wrong version. Here is new one.
> 
> From 2d42ead9335cde51fd58d6348439ca03cf359ba2 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 11 Nov 2016 15:02:57 +0900
> Subject: [PATCH] mm: support anonymous stable page
> 
> For developemnt for zram-swap asynchronous writeback, I found
> strange corruption of compressed page. With investigation, it
> reveals currently stable page doesn't support anonymous page.
> IOW, reuse_swap_page can reuse the page without waiting
> writeback completion so that it can corrupt data during
> zram compression. It can affect every swap device which supports
> asynchronous writeback and CRC checking as well as zRAM.
> 
> Unfortunately, reuse_swap_page should be atomic so that we
> cannot wait on writeback in there so the approach in this patch
> is simply return false if we found it needs stable page.
> Although it increases memory footprint temporarily, it happens
> rarely and it should be reclaimed easily althoug it happened.
> Also, It would be better than waiting of IO completion, which
> is critial path for application latency.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Ack to your intention (we discussed this together years ago, but saw
no actual demand for it before now), and I like what you're doing;
but it has to be NAK to this implementation.

I sensed there was an problem when you posted; but only now, after
searching through the uses of mapping->host, do I see that problem.

You're setting swap's mapping->host = inode when it used to be NULL:
which seems like a very good way to get what you need, but I'm afraid
it's a change which goes way beyond your intention.

See inode_to_bdi(): for ordinary disk-based swap, it will now pick
up the bdi of the block device instead of noop_backing_dev_info, so
swap would then pass the mapping_cap_account_dirty() and similar
tests (mostly in mm/page-writeback.c), and go down codepaths it
has never gone down before.

It's possible that swap (and shmem) would be better off going down
those paths, to be throttled in a similar way to files; but that's
debatable, and a much bigger change than you want to get into for
zram stable pages.

Maybe add SWP_STABLE_WRITES in include/linux/swap.h, and set that
in swap_info->flags according to bdi_cap_stable_pages_required(),
leaving mapping->host itself NULL as before?

Hugh

> ---
>  mm/swapfile.c | 16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 2210de290b54..ea591435d8e0 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -943,11 +943,21 @@ bool reuse_swap_page(struct page *page, int *total_mapcount)
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
> +			if (bdi_cap_stable_pages_required(
> +					inode_to_bdi(mapping->host)))
> +				return false;
>  		}
>  	}
> +out:
>  	return count <= 1;
>  }
>  
> @@ -2180,6 +2190,7 @@ static struct swap_info_struct *alloc_swap_info(void)
>  static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
>  {
>  	int error;
> +	struct address_space *swapper_space;
>  
>  	if (S_ISBLK(inode->i_mode)) {
>  		p->bdev = bdgrab(I_BDEV(inode));
> @@ -2202,6 +2213,9 @@ static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
>  	} else
>  		return -EINVAL;
>  
> +	swapper_space = &swapper_spaces[p->type];
> +	swapper_space->host = inode;
> +
>  	return 0;
>  }
>  
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
