Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E3F8B6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 21:53:37 -0400 (EDT)
Date: Thu, 7 Oct 2010 09:53:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] HWPOISON: Stop shrinking at right page count
Message-ID: <20101007015324.GB5482@localhost>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-5-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1286398141-13749-5-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 04:49:01AM +0800, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> When we call the slab shrinker to free a page we need to stop at
> page count one because the caller always holds a single reference, not zero.
> 
> This avoids useless looping over slab shrinkers and freeing too much
> memory.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Good catch!

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

> ---
>  mm/memory-failure.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 886144b..7c1af9b 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -237,7 +237,7 @@ void shake_page(struct page *p, int access)
>  		int nr;
>  		do {
>  			nr = shrink_slab(1000, GFP_KERNEL, 1000);
> -			if (page_count(p) == 0)
> +			if (page_count(p) == 1)
>  				break;
>  		} while (nr > 10);
>  	}
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
