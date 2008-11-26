Date: Tue, 25 Nov 2008 17:17:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/9] swapfile: swapon use discard (trim)
Message-Id: <20081125171748.57450cb5.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0811252140230.17555@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
	<Pine.LNX.4.64.0811252140230.17555@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: dwmw2@infradead.org, jens.axboe@oracle.com, matthew@wil.cx, joern@logfs.org, James.Bottomley@HansenPartnership.com, djshin90@gmail.com, teheo@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Nov 2008 21:44:34 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> When adding swap, all the old data on swap can be forgotten: sys_swapon()
> discard all but the header page of the swap partition (or every extent
> but the header of the swap file), to give a solidstate swap device the
> opportunity to optimize its wear-levelling.
> 
> If that succeeds, note SWP_DISCARDABLE for later use, and report it
> with a "D" at the right end of the kernel's "Adding ... swap" message.
> Perhaps something should be shown in /proc/swaps (swapon -s), but we
> have to be more cautious before making any addition to that format.
> 


When reading the above text it's a bit hard to tell whether it's
talking about "this is how things are at present" or "this is how
things are after the patch".  This is fairly common with Hugh
changelogs.

> ---
> swapfile.c cleanup patches 0-5 just went to linux-mm: patches 6-9
> may be of wider interest, so I'm extending the Cc list for them.
> 
>  include/linux/swap.h |    1 +
>  mm/swapfile.c        |   39 +++++++++++++++++++++++++++++++++++++--
>  2 files changed, 38 insertions(+), 2 deletions(-)
> 
> --- swapfile5/include/linux/swap.h	2008-11-25 12:41:31.000000000 +0000
> +++ swapfile6/include/linux/swap.h	2008-11-25 12:41:34.000000000 +0000
> @@ -120,6 +120,7 @@ struct swap_extent {
>  enum {
>  	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
>  	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
> +	SWP_DISCARDABLE = (1 << 2),	/* blkdev supports discard */
>  					/* add others here before... */
>  	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
>  };
> --- swapfile5/mm/swapfile.c	2008-11-25 12:41:31.000000000 +0000
> +++ swapfile6/mm/swapfile.c	2008-11-25 12:41:34.000000000 +0000
> @@ -84,6 +84,37 @@ void swap_unplug_io_fn(struct backing_de
>  	up_read(&swap_unplug_sem);
>  }
>  
> +/*
> + * swapon tell device that all the old swap contents can be discarded,
> + * to allow the swap device to optimize its wear-levelling.
> + */
> +static int discard_swap(struct swap_info_struct *si)
> +{
> +	struct swap_extent *se;
> +	int err = 0;
> +
> +	list_for_each_entry(se, &si->extent_list, list) {
> +		sector_t start_block = se->start_block << (PAGE_SHIFT - 9);
> +		pgoff_t nr_blocks = se->nr_pages << (PAGE_SHIFT - 9);

I trust we don't have any shift overflows here.

It's a bit dissonant to see a pgoff_t with "blocks" in its name.  But
swap is like that..


> +		if (se->start_page == 0) {
> +			/* Do not discard the swap header page! */
> +			start_block += 1 << (PAGE_SHIFT - 9);
> +			nr_blocks -= 1 << (PAGE_SHIFT - 9);
> +			if (!nr_blocks)
> +				continue;
> +		}
> +
> +		err = blkdev_issue_discard(si->bdev, start_block,
> +						nr_blocks, GFP_KERNEL);
> +		if (err)
> +			break;
> +
> +		cond_resched();
> +	}
> +	return err;		/* That will often be -EOPNOTSUPP */
> +}
> +
>  #define SWAPFILE_CLUSTER	256
>  #define LATENCY_LIMIT		256
>  
> @@ -1649,6 +1680,9 @@ asmlinkage long sys_swapon(const char __
>  		goto bad_swap;
>  	}
>  
> +	if (discard_swap(p) == 0)
> +		p->flags |= SWP_DISCARDABLE;
> +
>  	mutex_lock(&swapon_mutex);
>  	spin_lock(&swap_lock);
>  	if (swap_flags & SWAP_FLAG_PREFER)
> @@ -1662,9 +1696,10 @@ asmlinkage long sys_swapon(const char __
>  	total_swap_pages += nr_good_pages;
>  
>  	printk(KERN_INFO "Adding %uk swap on %s.  "
> -			"Priority:%d extents:%d across:%lluk\n",
> +			"Priority:%d extents:%d across:%lluk%s\n",
>  		nr_good_pages<<(PAGE_SHIFT-10), name, p->prio,
> -		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10));
> +		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
> +		(p->flags & SWP_DISCARDABLE) ? " D" : "");
>  
>  	/* insert swap space into swap_list: */
>  	prev = -1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
