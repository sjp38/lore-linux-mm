Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8676B0096
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 15:07:18 -0500 (EST)
Date: Thu, 11 Nov 2010 12:06:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
Message-Id: <20101111120643.22dcda5b.akpm@linux-foundation.org>
In-Reply-To: <1289421759.11149.59.camel@oralap>
References: <1289421759.11149.59.camel@oralap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Nov 2010 21:42:39 +0100
"Ricardo M. Correia" <ricardo.correia@oracle.com> wrote:

> Hi,
> 
> As part of Lustre filesystem development, we are running into a
> situation where we (sporadically) need to call into __vmalloc() from a
> thread that processes I/Os to disk (it's a long story).
> 
> In general, this would be fine as long as we pass GFP_NOFS to
> __vmalloc(), but the problem is that even if we pass this flag, vmalloc
> itself sometimes allocates memory with GFP_KERNEL.
> 
> This is not OK for us because the GFP_KERNEL allocations may go into the
> synchronous reclaim path and try to write out data to disk (in order to
> free memory for the allocation), which leads to a deadlock because those
> reclaims may themselves depend on the thread that is doing the
> allocation to make forward progress (which it can't, because it's
> blocked trying to allocate the memory).
> 
> Andreas suggested that this may be a bug in __vmalloc(), in the sense
> that it's not propagating the gfp_mask that the caller requested to all
> allocations that happen inside it.
> 
> On the latest torvalds git tree, for x86-64, the path for these
> GFP_KERNEL allocations go something like this:
> 
> __vmalloc()
>   __vmalloc_node()
>     __vmalloc_area_node()
>       map_vm_area()
>         vmap_page_range()
>           vmap_pud_range()
>             vmap_pmd_range()
>               pmd_alloc()
>                 __pmd_alloc()
>                   pmd_alloc_one()
>                     get_zeroed_page() <-- GFP_KERNEL
>               vmap_pte_range()
>                 pte_alloc_kernel()
>                   __pte_alloc_kernel()
>                     pte_alloc_one_kernel()
>                       get_free_page() <-- GFP_KERNEL
> 
> We've actually observed these deadlocks during testing (although in an
> older kernel).

Bug.

> Andreas suggested that we should fix __vmalloc() to propagate the
> caller-passed gfp_mask all the way to those allocating functions. This
> may require fixing these interfaces for all architectures.
> 
> I also suggested that it would be nice to have a per-task
> gfp_allowed_mask, similar to the existing gfp_allowed_mask /
> set_gfp_allowed_mask() interface that exists in the kernel, but instead
> of being global to the entire system, it would be stored in the thread's
> task_struct and only apply in the context of the current thread.

Possibly we should have done pass-via-task_struct for the gfp mode
everywhere.  Fifteen years ago...  Sites which modify the mask should
do a save/restore on the stack, so there would be no stack savings, but
I suspect there would be some nice text size savings from all that
pass-it-on-to-the-next-guy stuff we do.  Note that this approach could
perhaps be used to move PF_MEMALLOC, PF_KSWAPD and maybe a few other
things into task_struct.gfp_flags.

But that's history.  Before embarking on that path (and introducing a
mixture of both forms of argument-passing) we should take a look at how
big and ugly it is to fix this bug via the normal passing convention,
so we can make a better-informed decision.  Is that something which
you've looked into in any detail?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
