Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 30ACE6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 18:58:47 -0500 (EST)
Date: Sat, 6 Mar 2010 00:58:12 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
Message-ID: <20100305235812.GA15249@cmpxchg.org>
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> <20100305032106.GA12065@cmpxchg.org> <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com> <4B915074.4020704@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B915074.4020704@kernel.org>
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yinghai@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello Yinghai,

On Fri, Mar 05, 2010 at 10:41:56AM -0800, Yinghai Lu wrote:
> On 03/04/2010 09:17 PM, Greg Thelen wrote:
> > On Thu, Mar 4, 2010 at 7:21 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> On Thu, Mar 04, 2010 at 01:21:41PM -0800, Greg Thelen wrote:
> >>> On several systems I am seeing a boot panic if I use mmotm
> >>> (stamp-2010-03-02-18-38).  If I remove
> >>> bootmem-avoid-dma32-zone-by-default.patch then no panic is seen.  I
> >>> find that:
> >>> * 2.6.33 boots fine.
> >>> * 2.6.33 + mmotm w/o bootmem-avoid-dma32-zone-by-default.patch: boots fine.
> >>> * 2.6.33 + mmotm (including
> >>> bootmem-avoid-dma32-zone-by-default.patch): panics.
> ...
> > 
> > Note: mmotm has been recently updated to stamp-2010-03-04-18-05.  I
> > re-tested with 'make defconfig' to confirm the panic with this later
> > mmotm.
> 
> please check
> 
> [PATCH] early_res: double check with updated goal in alloc_memory_core_early
> 
> Johannes Weiner pointed out that new early_res replacement for alloc_bootmem_node
> change the behavoir about goal.
> original bootmem one will try go further regardless of goal.
> 
> and it will break his patch about default goal from MAX_DMA to MAX_DMA32...
> also broke uncommon machines with <=16M of memory.
> (really? our x86 kernel still can run on 16M system?)
> 
> so try again with update goal.

Thanks for the patch, it seems to be correct.

However, I have a more generic question about it, regarding the future of the
early_res allocator.

Did you plan on keeping the bootmem API for longer?  Because my impression was,
emulating it is a temporary measure until all users are gone and bootmem can
be finally dropped.

But then this would require some sort of handling of 'user does not need DMA[32]
memory, so avoid it' and 'user can only use DMA[32] memory' in the early_res
allocator as well.

I ask this specifically because you move this fix into the bootmem compatibility
code while there is not yet a way to tell early_res the same thing, so switching
a user that _needs_ to specify this requirement from bootmem to early_res is not
yet possible, is it?

> Reported-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> 
> ---
>  mm/bootmem.c |   28 +++++++++++++++++++++++++---
>  1 file changed, 25 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/mm/bootmem.c
> ===================================================================
> --- linux-2.6.orig/mm/bootmem.c
> +++ linux-2.6/mm/bootmem.c
> @@ -170,6 +170,28 @@ void __init free_bootmem_late(unsigned l
>  }
>  
>  #ifdef CONFIG_NO_BOOTMEM
> +static void * __init ___alloc_memory_core_early(pg_data_t *pgdat, u64 size,
> +						 u64 align, u64 goal, u64 limit)
> +{
> +	void *ptr;
> +	unsigned long end_pfn;
> +
> +	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
> +					 goal, limit);
> +	if (ptr)
> +		return ptr;
> +
> +	/* check goal according  */
> +	end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
> +	if ((end_pfn << PAGE_SHIFT) < (goal + size)) {
> +		goal = pgdat->node_start_pfn << PAGE_SHIFT;
> +		ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
> +						 goal, limit);
> +	}
> +
> +	return ptr;

I think it would make sense to move the parameter check before doing the
allocation.  Then you save the second call.

And a second nitpick: naming the inner function __foo and the outer one ___foo seems
confusing to me.  Could you maybe rename the wrapper? bootmem_compat_alloc_early() or
something like that?

Thanks,
	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
