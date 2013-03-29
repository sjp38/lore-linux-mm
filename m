Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 578E96B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 21:18:03 -0400 (EDT)
Date: Fri, 29 Mar 2013 10:18:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: remove swapcache page early
Message-ID: <20130329011801.GA32245@blaptop>
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
 <alpine.LNX.2.00.1303271230210.29687@eggly.anvils>
 <433aaa17-7547-4e39-b472-7060ee15e85f@default>
 <20130328010706.GB22908@blaptop>
 <5f1504e7-8b07-4109-8271-b214b496ca61@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5f1504e7-8b07-4109-8271-b214b496ca61@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <bob.liu@oracle.com>

On Thu, Mar 28, 2013 at 11:19:12AM -0700, Dan Magenheimer wrote:
> > From: Minchan Kim [mailto:minchan@kernel.org]
> > Subject: Re: [RFC] mm: remove swapcache page early
> > 
> > Hi Dan,
> > 
> > On Wed, Mar 27, 2013 at 03:24:00PM -0700, Dan Magenheimer wrote:
> > > > From: Hugh Dickins [mailto:hughd@google.com]
> > > > Subject: Re: [RFC] mm: remove swapcache page early
> > > >
> > > > I believe the answer is for frontswap/zmem to invalidate the frontswap
> > > > copy of the page (to free up the compressed memory when possible) and
> > > > SetPageDirty on the PageUptodate PageSwapCache page when swapping in
> > > > (setting page dirty so nothing will later go to read it from the
> > > > unfreed location on backing swap disk, which was never written).
> > >
> > > There are two duplication issues:  (1) When can the page be removed
> > > from the swap cache after a call to frontswap_store; and (2) When
> > > can the page be removed from the frontswap storage after it
> > > has been brought back into memory via frontswap_load.
> > >
> > > This patch from Minchan addresses (1).  The issue you are raising
> > 
> > No. I am addressing (2).
> > 
> > > here is (2).  You may not know that (2) has recently been solved
> > > in frontswap, at least for zcache.  See frontswap_exclusive_gets_enabled.
> > > If this is enabled (and it is for zcache but not yet for zswap),
> > > what you suggest (SetPageDirty) is what happens.
> > 
> > I am blind on zcache so I didn't see it. Anyway, I'd like to address it
> > on zram and zswap.
> 
> Zswap can enable it trivially by adding a function call in init_zswap.
> (Note that it is not enabled by default for all frontswap backends
> because it is another complicated tradeoff of cpu time vs memory space
> that needs more study on a broad set of workloads.)
> 
> I wonder if something like this would have a similar result for zram?
> (Completely untested... snippet stolen from swap_entry_free with
> SetPageDirty added... doesn't compile yet, but should give you the idea.)

Nice idea!

After I see your patch, I realized it was Hugh's suggestion and
you implemented it in proper place.

Will resend it after testing. Maybe nextweek.
Thanks!

> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 56276fe..2d10988 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -81,7 +81,17 @@ void end_swap_bio_read(struct bio *bio, int err)
>  				iminor(bio->bi_bdev->bd_inode),
>  				(unsigned long long)bio->bi_sector);
>  	} else {
> +		struct swap_info_struct *sis;
> +
>  		SetPageUptodate(page);
> +		sis = page_swap_info(page);
> +		if (sis->flags & SWP_BLKDEV) {
> +			struct gendisk *disk = sis->bdev->bd_disk;
> +			if (disk->fops->swap_slot_free_notify) {
> +				SetPageDirty(page);
> +				disk->fops->swap_slot_free_notify(sis->bdev,
> +								  offset);
> +			}
> +		}
>  	}
>  	unlock_page(page);
>  	bio_put(bio);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
