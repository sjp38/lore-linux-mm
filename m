Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 327A16B0087
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:28:36 -0400 (EDT)
Date: Fri, 8 May 2009 13:28:46 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 3/7] proc: kpagecount/kpageflags code cleanup
Message-ID: <20090508182845.GX31071@waste.org>
References: <20090507012116.996644836@intel.com> <20090507014914.244032831@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507014914.244032831@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 09:21:20AM +0800, Wu Fengguang wrote:
> Move increments of pfn/out to bottom of the loop.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Matt Mackall <mpm@selenic.com>

> ---
>  fs/proc/page.c |   17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
> 
> --- linux.orig/fs/proc/page.c
> +++ linux/fs/proc/page.c
> @@ -11,6 +11,7 @@
>  
>  #define KPMSIZE sizeof(u64)
>  #define KPMMASK (KPMSIZE - 1)
> +
>  /* /proc/kpagecount - an array exposing page counts
>   *
>   * Each entry is a u64 representing the corresponding
> @@ -32,20 +33,22 @@ static ssize_t kpagecount_read(struct fi
>  		return -EINVAL;
>  
>  	while (count > 0) {
> -		ppage = NULL;
>  		if (pfn_valid(pfn))
>  			ppage = pfn_to_page(pfn);
> -		pfn++;
> +		else
> +			ppage = NULL;
>  		if (!ppage)
>  			pcount = 0;
>  		else
>  			pcount = page_mapcount(ppage);
>  
> -		if (put_user(pcount, out++)) {
> +		if (put_user(pcount, out)) {
>  			ret = -EFAULT;
>  			break;
>  		}
>  
> +		pfn++;
> +		out++;
>  		count -= KPMSIZE;
>  	}
>  
> @@ -98,10 +101,10 @@ static ssize_t kpageflags_read(struct fi
>  		return -EINVAL;
>  
>  	while (count > 0) {
> -		ppage = NULL;
>  		if (pfn_valid(pfn))
>  			ppage = pfn_to_page(pfn);
> -		pfn++;
> +		else
> +			ppage = NULL;
>  		if (!ppage)
>  			kflags = 0;
>  		else
> @@ -119,11 +122,13 @@ static ssize_t kpageflags_read(struct fi
>  			kpf_copy_bit(kflags, KPF_RECLAIM, PG_reclaim) |
>  			kpf_copy_bit(kflags, KPF_BUDDY, PG_buddy);
>  
> -		if (put_user(uflags, out++)) {
> +		if (put_user(uflags, out)) {
>  			ret = -EFAULT;
>  			break;
>  		}
>  
> +		pfn++;
> +		out++;
>  		count -= KPMSIZE;
>  	}
>  
> 
> -- 

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
