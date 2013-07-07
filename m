Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 0E4496B0034
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 15:31:39 -0400 (EDT)
Message-ID: <51D9C217.5030507@redhat.com>
Date: Sun, 07 Jul 2013 15:31:35 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] swap: warn when a swap area overflows the maximum
 size
References: <1373197450.26573.5.camel@warfang>  <1373197978.26573.7.camel@warfang> <1373224421.26573.11.camel@warfang>
In-Reply-To: <1373224421.26573.11.camel@warfang>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Valdis Kletnieks <valdis.kletnieks@vt.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 07/07/2013 03:13 PM, Raymond Jennings wrote:
> Turned the comparison around for clarity of "bigger than"
>
> No semantic changes, if it still compiles it should do the same thing so
> I've omitted the testing this time.  Will be happy to retest if required
> but I'm on an atom 330 and kernel rebuilds are a nightmare.

Added CC: Andrew Morton, since this should probably go into -mm :)

> ----
>
> swap: warn when a swap area overflows the maximum size
>
> It is possible to swapon a swap area that is too big for the pte width
> to handle.
>
> Presently this failure happens silently.
>
> Instead, emit a diagnostic to warn the user.
>
> Signed-off-by: Raymond Jennings <shentino@gmail.com>
> Acked-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

Reviewed-by: Rik van Riel <riel@redhat.com>

> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 36af6ee..5a4ce53 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1953,6 +1953,12 @@ static unsigned long read_swap_header(struct
> swap_info_struct *p,
>           */
>          maxpages = swp_offset(pte_to_swp_entry(
>                          swp_entry_to_pte(swp_entry(0, ~0UL)))) + 1;
> +       if (swap_header->info.last_page > maxpages) {
> +               printk(KERN_WARNING
> +                      "Truncating oversized swap area, only using %luk
> out of %luk
> \n",
> +                      maxpages << (PAGE_SHIFT - 10),
> +                      swap_header->info.last_page << (PAGE_SHIFT -
> 10));
> +       }
>          if (maxpages > swap_header->info.last_page) {
>                  maxpages = swap_header->info.last_page + 1;
>                  /* p->max is an unsigned int: don't overflow it */
>
> ----
>
> Testing results, root prompt commands and kernel log messages:
>
> # lvresize /dev/system/swap --size 16G
> # mkswap /dev/system/swap
> # swapon /dev/system/swap
>
> Jul  7 04:27:22 warfang kernel: Adding 16777212k swap
> on /dev/mapper/system-swap.  Priority:-1 extents:1 across:16777212k
>
> # lvresize /dev/system/swap --size 16G
> # mkswap /dev/system/swap
> # swapon /dev/system/swap
>
> Jul  7 04:27:22 warfang kernel: Truncating oversized swap area, only
> using 33554432k out of 67108860k
> Jul  7 04:27:22 warfang kernel: Adding 33554428k swap
> on /dev/mapper/system-swap.  Priority:-1 extents:1 across:33554428k
>
>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
