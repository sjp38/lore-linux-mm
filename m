Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 889AA6B016D
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:23:39 -0400 (EDT)
Message-Id: <4E414320020000780005057E@nat28.tlf.novell.com>
Date: Tue, 09 Aug 2011 13:24:32 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure
	 changes
References: <20110808204555.GA15850@ca-server1.us.oracle.com>
In-Reply-To: <20110808204555.GA15850@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com, konrad.wilk@oracle.com, kurt.hackel@oracle.com, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

>>> On 08.08.11 at 22:45, Dan Magenheimer <dan.magenheimer@oracle.com> =
wrote:
> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Subject: [PATCH V6 1/4] mm: frontswap: swap data structure changes
>=20
> This first patch of four in the frontswap series makes available core
> swap data structures (swap_lock, swap_list and swap_info) that are
> needed by frontswap.c but we don't need to expose them to the dozens
> of files that include swap.h so we create a new swapfile.h just to
> extern-ify these.
>=20
> Also add frontswap-related elements to swap_info_struct.  Frontswap_map
> points to vzalloc'ed one-bit-per-swap-page metadata that indicates
> whether the swap page is in frontswap or in the device and frontswap_page=
s
> counts how many pages are in frontswap.  We don't tie these to
> CONFIG_FRONTSWAP to avoid unnecessary clutter around various frontswap
> hooks.
>=20
> [v6: rebase to 3.0-rc1]
> [v5: no change from v4]
> [v4: rebase to 2.6.39]
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Matthew Wilcox <matthew@wil.cx>
> Cc: Chris Mason <chris.mason@oracle.com>
> Cc: Jan Beulich <JBeulich@novell.com>
> Cc: Rik Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
>=20
> --- linux/include/linux/swapfile.h	1969-12-31 17:00:00.000000000 =
-0700
> +++ frontswap/include/linux/swapfile.h	2011-08-08 08:59:03.9516945=
06 -0600
> @@ -0,0 +1,13 @@
> +#ifndef _LINUX_SWAPFILE_H
> +#define _LINUX_SWAPFILE_H
> +
> +/*
> + * these were static in swapfile.c but frontswap.c needs them and we =
don't
> + * want to expose them to the dozens of source files that include =
swap.h
> + */
> +extern spinlock_t swap_lock;
> +extern struct swap_list_t swap_list;
> +extern struct swap_info_struct *swap_info[];
> +extern int try_to_unuse(unsigned int, bool, unsigned long);
> +
> +#endif /* _LINUX_SWAPFILE_H */
> --- linux/include/linux/swap.h	2011-08-08 08:19:25.880690134 =
-0600
> +++ frontswap/include/linux/swap.h	2011-08-08 08:59:03.952691415 =
-0600
> @@ -194,6 +194,8 @@ struct swap_info_struct {
>  	struct block_device *bdev;	/* swap device or bdev of swap =
file */
>  	struct file *swap_file;		/* seldom referenced */
>  	unsigned int old_block_size;	/* seldom referenced */

#ifdef CONFIG_FRONTSWAP

> +	unsigned long *frontswap_map;	/* frontswap in-use, one bit per =
page */
> +	unsigned int frontswap_pages;	/* frontswap pages in-use counter =
*/


#endif

(to eliminate any overhead with that config option unset)

Jan

>  };
> =20
>  struct swap_list_t {



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
