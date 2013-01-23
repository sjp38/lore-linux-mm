Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 7464D6B0008
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 20:50:02 -0500 (EST)
Date: Wed, 23 Jan 2013 10:49:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Subtract min_free_kbytes from dirtyable memory
Message-ID: <20130123014959.GB2723@blaptop>
References: <201301210315.r0L3FnGV021298@como.maths.usyd.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301210315.r0L3FnGV021298@como.maths.usyd.edu.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org

On Mon, Jan 21, 2013 at 02:15:49PM +1100, paul.szabo@sydney.edu.au wrote:
> When calculating amount of dirtyable memory, min_free_kbytes should be
> subtracted because it is not intended for dirty pages.

So what's the effect for user?
It would be better to include that in description if possible.

> 
> Using an "extern int" because that is the only interface to some such
> sysctl values.
> 
> (This patch does not solve the PAE OOM issue.)
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia
> 
> Reported-by: Paul Szabo <psz@maths.usyd.edu.au>
> Reference: http://bugs.debian.org/695182
> Signed-off-by: Paul Szabo <psz@maths.usyd.edu.au>
> 
> --- mm/page-writeback.c.old	2012-12-06 22:20:40.000000000 +1100
> +++ mm/page-writeback.c	2013-01-21 13:57:05.000000000 +1100
> @@ -343,12 +343,16 @@
>  unsigned long determine_dirtyable_memory(void)
>  {
>  	unsigned long x;
> +	extern int min_free_kbytes;
>  
>  	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
>  
>  	if (!vm_highmem_is_dirtyable)
>  		x -= highmem_dirtyable_memory(x);
>  
> +	/* Subtract min_free_kbytes */
> +	x -= min(x, min_free_kbytes >> (PAGE_SHIFT - 10));

It seems you saw old kernel.
Current kernel includes following logic.

static unsigned long global_dirtyable_memory(void)
{
        unsigned long x;

        x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
        x -= min(x, dirty_balance_reserve);

        if (!vm_highmem_is_dirtyable)
                x -= highmem_dirtyable_memory(x);

        return x + 1;   /* Ensure that we never return 0 */
}

And dirty_lanace_reserve already includes high_wmark_pages.
Look at calculate_totalreserve_pages.

So I think we don't need this patch.
Thanks.

> +
>  	return x + 1;	/* Ensure that we never return 0 */
>  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
