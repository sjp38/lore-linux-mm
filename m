Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF9F6B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 16:36:08 -0500 (EST)
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
In-Reply-To: <1289421759.11149.59.camel@oralap>
References: <1289421759.11149.59.camel@oralap>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Nov 2010 22:35:55 +0100
Message-ID: <1289424955.11149.73.camel@oralap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-10 at 21:42 +0100, Ricardo M. Correia wrote:
> Hi,
> 
> As part of Lustre filesystem development, we are running into a
> situation where we (sporadically) need to call into __vmalloc() from a
> thread that processes I/Os to disk (it's a long story).
> 
> In general, this would be fine as long as we pass GFP_NOFS to
> __vmalloc(), but the problem is that even if we pass this flag, vmalloc
> itself sometimes allocates memory with GFP_KERNEL.

By the way, it seems that existing users in Linus' tree may be
vulnerable to the same bug that we experienced:

In GFS:
    8   1253  fs/gfs2/dir.c <<gfs2_alloc_sort_buffer>>
             ptr = __vmalloc(size, GFP_NOFS, PAGE_KERNEL);

The Ceph filesystem:
  20     22  net/ceph/buffer.c <<ceph_buffer_new>>
             b->vec.iov_base = __vmalloc(len, gfp, PAGE_KERNEL);
.. which can be called from:
   3    560  fs/ceph/inode.c <<fill_inode>>
             xattr_blob = ceph_buffer_new(iinfo->xattr_len, GFP_NOFS);

In the MM code:
  18   5184  mm/page_alloc.c <<alloc_large_system_hash>>
             table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);

All of these seem to be vulnerable to GFP_KERNEL allocations from within
__vmalloc(), at least on x86-64 (as I've detailed below).

Thanks,
Ricardo

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
> 
> Andreas suggested that we should fix __vmalloc() to propagate the
> caller-passed gfp_mask all the way to those allocating functions. This
> may require fixing these interfaces for all architectures.
> 
> I also suggested that it would be nice to have a per-task
> gfp_allowed_mask, similar to the existing gfp_allowed_mask /
> set_gfp_allowed_mask() interface that exists in the kernel, but instead
> of being global to the entire system, it would be stored in the thread's
> task_struct and only apply in the context of the current thread.
> 
> This would allow us to call a function when our I/O threads are created,
> say set_thread_gfp_allowed_mask(~__GFP_IO), to make sure that any kernel
> allocations that happen in the context of those threads would have
> __GFP_IO masked out.
> 
> I am willing to code and send out any of those 2 patches (the vmalloc
> fix and/or the per-thread gfp mask), and I was wondering if this is
> something you'd be willing to accept into the upstream kernel, or if you
> have any other ideas as to how to prevent all __GFP_IO allocations from
> the kernel itself in the context of threads that perform I/O.
> 
> (Please reply-to-all as we are not subscribed to linux-mm).
> 
> Thanks,
> Ricardo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
