Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 03A8E6B016B
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 03:57:34 -0400 (EDT)
Date: Thu, 4 Aug 2011 09:57:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
Message-ID: <20110804075730.GF31039@tiehlicka.suse.cz>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, hannes@cmpxchg.org, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu 04-08-11 11:09:48, Bob Liu wrote:
> This patch also add checking whether alloc frontswap_map memory
> failed.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/swapfile.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index ffdd06a..8fe9e88 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2124,9 +2124,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	}
>  	/* frontswap enabled? set up bit-per-page map for frontswap */
>  	if (frontswap_enabled) {
> -		frontswap_map = vmalloc(maxpages / sizeof(long));
> -		if (frontswap_map)
> -			memset(frontswap_map, 0, maxpages / sizeof(long));
> +		frontswap_map = vzalloc(maxpages / sizeof(long));
> +		if (!frontswap_map)
> +			goto bad_swap;

vzalloc part looks good but shouldn't we disable frontswap rather than
fail?

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
