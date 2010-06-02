Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 64A1B6B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 15:29:14 -0400 (EDT)
Date: Wed, 2 Jun 2010 12:29:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 1/4] Frontswap (was Transcendent Memory): swap data
 structure changes
Message-Id: <20100602122910.71f981e8.akpm@linux-foundation.org>
In-Reply-To: <20100528174041.GA28176@ca-server1.us.oracle.com>
References: <20100528174041.GA28176@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, riel@redhat.com, avi@redhat.com, pavel@ucw.cz, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2010 10:40:41 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> [PATCH V2 1/4] Frontswap (was Transcendent Memory): swap data structure changes
> 
> Core swap data structures are needed by frontswap.c but we don't
> need to expose them to the dozens of files that include swap.h
> so create a new swapfile.h just to extern-ify these.
> 
> Add frontswap-related elements to swap_info_struct.  Don't tie
> these to CONFIG_FRONTSWAP to avoid unnecessary clutter around
> various frontswap hooks.
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> Diffstat:
>  swap.h                                   |    2 ++
>  swapfile.h                               |   13 +++++++++++++
>  2 files changed, 15 insertions(+)
> 
> --- linux-2.6.34/include/linux/swapfile.h	1969-12-31 17:00:00.000000000 -0700
> +++ linux-2.6.34-frontswap/include/linux/swapfile.h	2010-05-21 16:36:45.000000000 -0600
> @@ -0,0 +1,13 @@
> +#ifndef _LINUX_SWAPFILE_H
> +#define _LINUX_SWAPFILE_H
> +
> +/*
> + * these were static in swapfile.c but frontswap.c needs them and we don't
> + * want to expose them to the dozens of source files that include swap.h
> + */
> +extern spinlock_t swap_lock;
> +extern struct swap_list_t swap_list;
> +extern struct swap_info_struct *swap_info[];
> +extern int try_to_unuse(unsigned int, bool, unsigned long);
> +
> +#endif /* _LINUX_SWAPFILE_H */
> --- linux-2.6.34/include/linux/swap.h	2010-05-16 15:17:36.000000000 -0600
> +++ linux-2.6.34-frontswap/include/linux/swap.h	2010-05-24 10:13:41.000000000 -0600
> @@ -182,6 +182,8 @@ struct swap_info_struct {
>  	struct block_device *bdev;	/* swap device or bdev of swap file */
>  	struct file *swap_file;		/* seldom referenced */
>  	unsigned int old_block_size;	/* seldom referenced */
> +	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
> +	unsigned int frontswap_pages;	/* frontswap pages in-use counter */

Is a 32-bit uint large enough?  Maybe there are other things in swap
which restrict us to less than 16TB, dunno.


>  };
>  
>  struct swap_list_t {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
