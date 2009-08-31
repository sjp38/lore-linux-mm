Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 189E06B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 15:26:50 -0400 (EDT)
Date: Mon, 31 Aug 2009 20:26:22 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] swap: Fix swap size in case of block devices
In-Reply-To: <4A9C06B2.3040009@vflare.org>
Message-ID: <Pine.LNX.4.64.0908311959460.13560@sister.anvils>
References: <200908302149.10981.ngupta@vflare.org>
 <Pine.LNX.4.64.0908311151190.16326@sister.anvils> <4A9C06B2.3040009@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Karel Zak <kzak@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 31 Aug 2009, Nitin Gupta wrote:
> 
> mkswap sets last_page correctly: 0-based index of last usable
> swap page. To explain why this bug affects only block swap devices,
> some code walkthrough is done below:
> (BTW, I only checked mkswap which is part of util-linux-ng 2.14.2).
> 
> swapon()
> {
>  ...
>         nr_good_pages = swap_header->info.last_page -
>                         swap_header->info.nr_badpages -
>                         1 /* header page */;
> 
> ====
> 	off-by-one error: for both regular and block device case, but...
> ====
> 
>         if (nr_good_pages) {
>                 swap_map[0] = SWAP_MAP_BAD;
>                 p->max = maxpages;
>                 p->pages = nr_good_pages;
>                 nr_extents = setup_swap_extents(p, &span);
> ====
> For block devices, setup_swap_extents() leaves p->pages untouched.
> For regular files, it sets p->pages
> 	== total usable swap pages (including header page) - 1;

I think you're overlooking the "page < sis->max" condition
in setup_swap_extents()'s loop.  So at the end of the loop,
if no pages were lost to fragmentation, we have

		sis->max = page_no;		/* no change */
		sis->pages = page_no - 1;	/* no change */

> ====
>                 if (nr_extents < 0) {
>                         error = nr_extents;
>                         goto bad_swap;
>                 }
>                 nr_good_pages = p->pages;
> 
> ====
> So, for block device, nr_good_pages == last_page - nr_badpages - 1
> 				== (total pages - 1) - nr_badpages - 1 (error)
> 			For regular files, nr_good_pages == total pages - 1
> (correct)
> ====
> 
>         }
> ...
> }
> 
> 
> With this fix, block device case is corrected to last_page - nr_badpages - 1
> while regular file case remain correct since setup_swap_extents() still gives
> same correct value in p->pages (== total pages - 1).
> 
> 
> > And regarding the patch itself: my understanding is that the problem
> > is with the interpretation of last_page, so I don't think one change
> > to nr_good_pages would be enough to fix it - you'd need to change the
> > other places where last_page is referred to too.
> >
> 
> I looked at other instances of last_page in swapon() -- all these other
> instances looked correct to me.

I believe they're all consistent with the off-by-oneness of nr_good_pages.
p->max, for example, is consistently one more than p->pages, so long as
there are no bad pages and no overflowing the swp_entry_t.

Perhaps you're placing too much faith in your interpretation of "max"?
I dislike several conventions in swapfile.c, it does lend itself to
off-by-oneness.

> 
> > I'm still disinclined to make any change here myself (beyond
> > a comment noting the discrepancy); but tell me I'm a fool.
> >
> 
> I agree that nobody would bother losing 1 swap slot, so it might
> not be desirable to have this fix. But IMHO, I don't see any reason
> to leave this discrepancy between regular files and swap devices -- its
> just so odd.

Yes, I'd dislike that discrepancy between regular files and block
devices, if I could see it.  Though I'd probably still be cautious
about the disk partitions.

dd if=/dev/zero of=/swap bs=200k	# says 204800 bytes (205kB)
mkswap /swap				# says size = 196 KiB
swapon /swap				# dmesg says Adding 192k swap

which is what I've come to expect from the off-by-one,
even on regular files.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
