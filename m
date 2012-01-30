Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id EFB0E6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 10:22:40 -0500 (EST)
Date: Mon, 30 Jan 2012 15:22:37 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFCv1 3/6] PASR: mm: Integrate PASR in Buddy allocator
Message-ID: <20120130152237.GS25268@csn.ul.ie>
References: <1327930436-10263-1-git-send-email-maxime.coquelin@stericsson.com>
 <1327930436-10263-4-git-send-email-maxime.coquelin@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327930436-10263-4-git-send-email-maxime.coquelin@stericsson.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Coquelin <maxime.coquelin@stericsson.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ankita Garg <ankita@in.ibm.com>, linux-kernel@vger.kernel.org, linus.walleij@stericsson.com, andrea.gallo@stericsson.com, vincent.guittot@stericsson.com, philippe.langlais@stericsson.com, loic.pallardy@stericsson.com

On Mon, Jan 30, 2012 at 02:33:53PM +0100, Maxime Coquelin wrote:
> Any allocators might call the PASR Framework for DDR power savings. Currently,
> only Linux Buddy allocator is patched, but HWMEM and PMEM physically
> contiguous memory allocators will follow.
> 
> Linux Buddy allocator porting uses Buddy specificities to reduce the overhead
> induced by the PASR Framework counter updates. Indeed, the PASR Framework is
> called only when MAX_ORDER (4MB page blocs by default) buddies are
> inserted/removed from the free lists.
> 
> To port PASR FW into a new allocator:
> 
> * Call pasr_put(phys_addr, size) each time a memory chunk becomes unused.
> * Call pasr_get(phys_addr, size) each time a memory chunk becomes used.
> 
> 
> Signed-off-by: Maxime Coquelin <maxime.coquelin@stericsson.com>
> ---
>  mm/page_alloc.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 03d8c48..c62fe11 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -57,6 +57,7 @@
>  #include <linux/ftrace_event.h>
>  #include <linux/memcontrol.h>
>  #include <linux/prefetch.h>
> +#include <linux/pasr.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -534,6 +535,7 @@ static inline void __free_one_page(struct page *page,
>  		/* Our buddy is free, merge with it and move up one order. */
>  		list_del(&buddy->lru);
>  		zone->free_area[order].nr_free--;
> +		pasr_kget(buddy, order);
>  		rmv_page_order(buddy);
>  		combined_idx = buddy_idx & page_idx;
>  		page = page + (combined_idx - page_idx);

I did not review this series carefully and I know nothing about
how you implemented PASR support but driver hooks like this in the
page allocator are heavily frowned upon. It is subject to abuse but
it adds overhead to the allocator although I note that you avoiding
putting hooks in the per-cpu page allocator. I note that you hardcode
it so only PASR can use the hook but it looks like there is no way
of avoiding that overhead on platforms that do not have PASR if
it is enabled in the config. At a glance, it appears to be doing a
fair amount of work too - looking up maps, taking locks etc. This
potentially creates a new hot lock because in this paths, we have
per-zone locking but you are adding a PASR lock into the mix that
may be more coarse than zone->lock (I didn't check).

You may be able to use the existing arch_alloc_page() hook and
call PASR on architectures that support it if and only if PASR is
present and enabled by the administrator but even this is likely to be
unpopular as it'll have a measurable performance impact on platforms
with PASR (not to mention the PASR lock will be even heavier as it'll
now be also used for per-cpu page allocations). To get the hook you
want, you'd need to show significant benefit before they were happy with
the hook.

What is more likely is that you will get pushed to doing something like
periodically scanning memory as part of a separate power management
module and calling into PASR if regions of memory that are found that
can be powered down in some ways.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
