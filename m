Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id EECD46B0096
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 08:36:38 -0400 (EDT)
Date: Mon, 3 Jun 2013 08:36:34 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] frontswap: fix incorrect zeroing and allocation size for
 frontswap_map
Message-ID: <20130603123634.GE6893@phenom.dumpdata.com>
References: <1370130777-6707-1-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370130777-6707-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Sun, Jun 02, 2013 at 08:52:57AM +0900, Akinobu Mita wrote:
> The bitmap accessed by bitops must have enough size to hold the required
> numbers of bits rounded up to a multiple of BITS_PER_LONG.  And the bitmap
> must not be zeroed by memset() if the number of bits cleared is not
> a multiple of BITS_PER_LONG.
> 
> This fixes incorrect zeroing and allocation size for frontswap_map.
> The incorrect zeroing part doesn't cause any problem because
> frontswap_map is freed just after zeroing.  But the wrongly calculated
> allocation size may cause the problem.
> 
> For 32bit systems, the allocation size of frontswap_map is about twice as
> large as required size.  For 64bit systems, the allocation size is smaller
> than requeired if the number of bits is not a multiple of BITS_PER_LONG.
       ^^^^^^^^^
       required.

Looks OK to me. Thanks for catching this. I will test it out and if it
does not break any regression tests should go for the next rc.

Thanks!
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  mm/frontswap.c | 2 +-
>  mm/swapfile.c  | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 538367e..1b24bdc 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -319,7 +319,7 @@ void __frontswap_invalidate_area(unsigned type)
>  			return;
>  		frontswap_ops->invalidate_area(type);
>  		atomic_set(&sis->frontswap_pages, 0);
> -		memset(sis->frontswap_map, 0, sis->max / sizeof(long));
> +		bitmap_zero(sis->frontswap_map, sis->max);
>  	}
>  	clear_bit(type, need_init);
>  }
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6c340d9..746af55b 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2116,7 +2116,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	}
>  	/* frontswap enabled? set up bit-per-page map for frontswap */
>  	if (frontswap_enabled)
> -		frontswap_map = vzalloc(maxpages / sizeof(long));
> +		frontswap_map = vzalloc(BITS_TO_LONGS(maxpages) * sizeof(long));
>  
>  	if (p->bdev) {
>  		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
> -- 
> 1.8.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
