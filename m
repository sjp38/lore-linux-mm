Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 917526B005A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 07:28:17 -0400 (EDT)
Date: Mon, 31 Aug 2009 12:27:32 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] swap: Fix swap size in case of block devices
In-Reply-To: <200908302149.10981.ngupta@vflare.org>
Message-ID: <Pine.LNX.4.64.0908311151190.16326@sister.anvils>
References: <200908302149.10981.ngupta@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Karel Zak <kzak@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 30 Aug 2009, Nitin Gupta wrote:

> During swapon, swap size is set to number of usable pages in the given
> swap file/block device minus 1 (for header page). In case of block devices,
> this size is incorrectly set as one page less than the actual due to an
> off-by-one error. For regular files, this size is set correctly.
> 
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>

I agree that there's an off-by-one disagreement between swapon and mkswap
regarding last_page.  The kernel seems to interpret it as the index of
what I'd call the end page, the first page beyond the swap area.

I'd never noticed that until the beginning of this year, and out of
caution I've done nothing about it.  I believe that the kernel has
been wrong since Linux 2.2.? or 2.3.?, ever since swap header version 1
was first introduced; and that mkswap has set it the same way all along.

But I've not spent time on the research to establish that for sure.

What if there used to be a version of mkswap which set last_page one
greater as the kernel expects?  Neither Karel nor I think that's the
case, but we're not absolutely certain.  And what if (I suppose I'm
getting even more wildly cautious here!) someone has learnt that
that page remains untouched and is now putting it to other use?
or has compensated for the off-by-one and is setting it one greater,
beyond the end of the partition, not using mkswap?

Since nobody has been hurt by it in all these years, I felt safer
to go on leaving that discrepancy as is.  Call me over cautious.

Regarding your patch comment: I'm puzzled by the remark "For regular
files, this size is set correctly".  Do you mean that mkswap is
setting last_page one higher when dealing with a regular file rather
than a block device (I was unaware of that, but never looked to see)?
But your patch appears to be to code shared equally between block
devices and regular files, so then you'd be introducing a bug on
regular files?  And shouldn't mkswap be fixed to be consistent
with itself?  Hopefully I've misunderstood: please explain further.

And regarding the patch itself: my understanding is that the problem
is with the interpretation of last_page, so I don't think one change
to nr_good_pages would be enough to fix it - you'd need to change the
other places where last_page is referred to too.

I'm still disinclined to make any change here myself (beyond
a comment noting the discrepancy); but tell me I'm a fool.

Hugh

> ---
> 
>  mm/swapfile.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 8ffdc0d..3d37b97 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1951,9 +1951,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	if (error)
>  		goto bad_swap;
> 
> +	/* excluding header page */
>  	nr_good_pages = swap_header->info.last_page -
> -			swap_header->info.nr_badpages -
> -			1 /* header page */;
> +			swap_header->info.nr_badpages;
> 
>  	if (nr_good_pages) {
>  		swap_map[0] = SWAP_MAP_BAD;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
