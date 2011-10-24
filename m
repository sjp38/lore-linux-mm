Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3156B0031
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 11:06:57 -0400 (EDT)
Date: Mon, 24 Oct 2011 17:06:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] swapfile.c: Initialize a variable.
Message-ID: <20111024150653.GA18948@tiehlicka.suse.cz>
References: <1317876074-25417-1-git-send-email-corone.il.han@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317876074-25417-1-git-send-email-corone.il.han@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Il Han <corone.il.han@gmail.com>
Cc: linux-mm@kvack.org

On Thu 06-10-11 13:41:14, Il Han wrote:
> Initialize the variable to remove the following warning.
> 
> mm/swapfile.c:2028: warning: 'span' may be used uninitialized in this function
> 
> Initialize it.

It looks that the warning is bogus because span is always initialized
if nr_extents >=0. Check out setup_swap_map_and_extents and
setup_swap_extents (for S_ISBLK it is trivial and for S_ISREG we are
setting the value after we jump out of the loop and all error cases go
either to out directly or through bad_bmap labels).

It should be much better to use uninitialized_var instead if we just
want to shut up compiler.

> 
> Signed-off-by: Il Han <corone.il.han@gmail.com>
> ---
>  mm/swapfile.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 17bc224..d5ca685 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2016,7 +2016,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	int error;
>  	union swap_header *swap_header;
>  	int nr_extents;
> -	sector_t span;
> +	sector_t span = 0;
>  	unsigned long maxpages;
>  	unsigned char *swap_map = NULL;
>  	struct page *page = NULL;
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
