Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 82A526B006C
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 00:56:47 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7433463pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 21:56:46 -0700 (PDT)
Date: Sat, 16 Jun 2012 12:56:37 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] swap: fix shmem swapping when more than 8 areas
Message-ID: <20120616045637.GA2331@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <alpine.LSU.2.00.1206151752420.8741@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1206151752420.8741@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwp.linux@gmail.com>

On Fri, Jun 15, 2012 at 05:55:50PM -0700, Hugh Dickins wrote:
>Minchan Kim reports that when a system has many swap areas, and tmpfs
>swaps out to the ninth or more, shmem_getpage_gfp()'s attempts to read
>back the page cannot locate it, and the read fails with -ENOMEM.
>
>Whoops.  Yes, I blindly followed read_swap_header()'s pte_to_swp_entry(
>swp_entry_to_pte()) technique for determining maximum usable swap offset,
>without stopping to realize that that actually depends upon the pte swap
>encoding shifting swap offset to the higher bits and truncating it there.
>Whereas our radix_tree swap encoding leaves offset in the lower bits:
>it's swap "type" (that is, index of swap area) that was truncated.
>
>Fix it by reducing the SWP_TYPE_SHIFT() in swapops.h, and removing the
>broken radix_to_swp_entry(swp_to_radix_entry()) from read_swap_header().
>
>This does not reduce the usable size of a swap area any further, it leaves
>it as claimed when making the original commit: no change from 3.0 on x86_64,
>nor on i386 without PAE; but 3.0's 512GB is reduced to 128GB per swapfile
>on i386 with PAE.  It's not a change I would have risked five years ago,
>but with x86_64 supported for ten years, I believe it's appropriate now.
>
>Hmm, and what if some architecture implements its swap pte with offset
>encoded below type?  That would equally break the maximum usable swap
>offset check.  Happily, they all follow the same tradition of encoding
>offset above type, but I'll prepare a check on that for next.
>
>Reported-and-Reviewed-and-Tested-by: Minchan Kim <minchan@kernel.org>
>Signed-off-by: Hugh Dickins <hughd@google.com>
>Cc: stable@vger.kernel.org [3.1, 3.2, 3.3, 3.4]
>---
>
> include/linux/swapops.h |    8 +++++---
> mm/swapfile.c           |   12 ++++--------
> 2 files changed, 9 insertions(+), 11 deletions(-)
>
>--- 3.5-rc2/include/linux/swapops.h	2012-05-20 15:29:13.000000000 -0700
>+++ linux/include/linux/swapops.h	2012-06-13 12:01:35.390711624 -0700
>@@ -9,13 +9,15 @@
>  * get good packing density in that tree, so the index should be dense in
>  * the low-order bits.
>  *
>- * We arrange the `type' and `offset' fields so that `type' is at the five
>+ * We arrange the `type' and `offset' fields so that `type' is at the seven
>  * high-order bits of the swp_entry_t and `offset' is right-aligned in the
>- * remaining bits.
>+ * remaining bits.  Although `type' itself needs only five bits, we allow for
>+ * shmem/tmpfs to shift it all up a further two bits: see swp_to_radix_entry().
>  *
>  * swp_entry_t's are *never* stored anywhere in their arch-dependent format.
>  */
>-#define SWP_TYPE_SHIFT(e)	(sizeof(e.val) * 8 - MAX_SWAPFILES_SHIFT)
>+#define SWP_TYPE_SHIFT(e)	((sizeof(e.val) * 8) - \
>+			(MAX_SWAPFILES_SHIFT + RADIX_TREE_EXCEPTIONAL_SHIFT))

Hi Hugh,

Since SHIFT == MAX_SWAPFILES_SHIFT + RADIX_TREE_EXCEPTIONAL_SHIFT == 7
and the low two bits used for radix_tree, the available swappages number 
based of 32bit architectures reduce to 2^(32-7-2) = 32GB?

Regards,
Wanpeng Li

> #define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
> 
> /*
>--- 3.5-rc2/mm/swapfile.c	2012-06-08 18:48:40.744605221 -0700
>+++ linux/mm/swapfile.c	2012-06-13 12:13:56.214729684 -0700
>@@ -1916,24 +1916,20 @@ static unsigned long read_swap_header(st
> 
> 	/*
> 	 * Find out how many pages are allowed for a single swap
>-	 * device. There are three limiting factors: 1) the number
>+	 * device. There are two limiting factors: 1) the number
> 	 * of bits for the swap offset in the swp_entry_t type, and
> 	 * 2) the number of bits in the swap pte as defined by the
>-	 * the different architectures, and 3) the number of free bits
>-	 * in an exceptional radix_tree entry. In order to find the
>+	 * different architectures. In order to find the
> 	 * largest possible bit mask, a swap entry with swap type 0
> 	 * and swap offset ~0UL is created, encoded to a swap pte,
> 	 * decoded to a swp_entry_t again, and finally the swap
> 	 * offset is extracted. This will mask all the bits from
> 	 * the initial ~0UL mask that can't be encoded in either
> 	 * the swp_entry_t or the architecture definition of a
>-	 * swap pte.  Then the same is done for a radix_tree entry.
>+	 * swap pte.
> 	 */
> 	maxpages = swp_offset(pte_to_swp_entry(
>-			swp_entry_to_pte(swp_entry(0, ~0UL))));
>-	maxpages = swp_offset(radix_to_swp_entry(
>-			swp_to_radix_entry(swp_entry(0, maxpages)))) + 1;
>-
>+			swp_entry_to_pte(swp_entry(0, ~0UL)))) + 1;
> 	if (maxpages > swap_header->info.last_page) {
> 		maxpages = swap_header->info.last_page + 1;
> 		/* p->max is an unsigned int: don't overflow it */
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
