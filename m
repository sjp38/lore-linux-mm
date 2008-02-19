From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
Date: Wed, 20 Feb 2008 10:08:49 +1100
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com>
In-Reply-To: <20080215064932.620773824@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802201008.49933.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Friday 15 February 2008 17:49, Christoph Lameter wrote:
> The invalidation of address ranges in a mm_struct needs to be
> performed when pages are removed or permissions etc change.
>
> If invalidate_range_begin() is called with locks held then we
> pass a flag into invalidate_range() to indicate that no sleeping is
> possible. Locks are only held for truncate and huge pages.

You can't sleep inside rcu_read_lock()!

I must say that for a patch that is up to v8 or whatever and is
posted twice a week to such a big cc list, it is kind of slack to
not even test it and expect other people to review it.

Also, what we are going to need here are not skeleton drivers
that just do all the *easy* bits (of registering their callbacks),
but actual fully working examples that do everything that any
real driver will need to do. If not for the sanity of the driver
writer, then for the sanity of the VM developers (I don't want
to have to understand xpmem or infiniband in order to understand
how the VM works).



> In two cases we use invalidate_range_begin/end to invalidate
> single pages because the pair allows holding off new references
> (idea by Robin Holt).
>
> do_wp_page(): We hold off new references while we update the pte.
>
> xip_unmap: We are not taking the PageLock so we cannot
> use the invalidate_page mmu_rmap_notifier. invalidate_range_begin/end
> stands in.
>
> Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
> Signed-off-by: Robin Holt <holt@sgi.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>
> ---
>  mm/filemap_xip.c |    5 +++++
>  mm/fremap.c      |    3 +++
>  mm/hugetlb.c     |    3 +++
>  mm/memory.c      |   35 +++++++++++++++++++++++++++++------
>  mm/mmap.c        |    2 ++
>  mm/mprotect.c    |    3 +++
>  mm/mremap.c      |    7 ++++++-
>  7 files changed, 51 insertions(+), 7 deletions(-)
>
> Index: linux-2.6/mm/fremap.c
> ===================================================================
> --- linux-2.6.orig/mm/fremap.c	2008-02-14 18:43:31.000000000 -0800
> +++ linux-2.6/mm/fremap.c	2008-02-14 18:45:07.000000000 -0800
> @@ -15,6 +15,7 @@
>  #include <linux/rmap.h>
>  #include <linux/module.h>
>  #include <linux/syscalls.h>
> +#include <linux/mmu_notifier.h>
>
>  #include <asm/mmu_context.h>
>  #include <asm/cacheflush.h>
> @@ -214,7 +215,9 @@ asmlinkage long sys_remap_file_pages(uns
>  		spin_unlock(&mapping->i_mmap_lock);
>  	}
>
> +	mmu_notifier(invalidate_range_begin, mm, start, start + size, 0);
>  	err = populate_range(mm, vma, start, size, pgoff);
> +	mmu_notifier(invalidate_range_end, mm, start, start + size, 0);
>  	if (!err && !(flags & MAP_NONBLOCK)) {
>  		if (unlikely(has_write_lock)) {
>  			downgrade_write(&mm->mmap_sem);
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c	2008-02-14 18:43:31.000000000 -0800
> +++ linux-2.6/mm/memory.c	2008-02-14 18:45:07.000000000 -0800
> @@ -51,6 +51,7 @@
>  #include <linux/init.h>
>  #include <linux/writeback.h>
>  #include <linux/memcontrol.h>
> +#include <linux/mmu_notifier.h>
>
>  #include <asm/pgalloc.h>
>  #include <asm/uaccess.h>
> @@ -611,6 +612,9 @@ int copy_page_range(struct mm_struct *ds
>  	if (is_vm_hugetlb_page(vma))
>  		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
>
> +	if (is_cow_mapping(vma->vm_flags))
> +		mmu_notifier(invalidate_range_begin, src_mm, addr, end, 0);
> +
>  	dst_pgd = pgd_offset(dst_mm, addr);
>  	src_pgd = pgd_offset(src_mm, addr);
>  	do {
> @@ -621,6 +625,11 @@ int copy_page_range(struct mm_struct *ds
>  						vma, addr, next))
>  			return -ENOMEM;
>  	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
> +
> +	if (is_cow_mapping(vma->vm_flags))
> +		mmu_notifier(invalidate_range_end, src_mm,
> +						vma->vm_start, end, 0);
> +
>  	return 0;
>  }
>
> @@ -893,13 +902,16 @@ unsigned long zap_page_range(struct vm_a
>  	struct mmu_gather *tlb;
>  	unsigned long end = address + size;
>  	unsigned long nr_accounted = 0;
> +	int atomic = details ? (details->i_mmap_lock != 0) : 0;
>
>  	lru_add_drain();
>  	tlb = tlb_gather_mmu(mm, 0);
>  	update_hiwater_rss(mm);
> +	mmu_notifier(invalidate_range_begin, mm, address, end, atomic);
>  	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
>  	if (tlb)
>  		tlb_finish_mmu(tlb, address, end);
> +	mmu_notifier(invalidate_range_end, mm, address, end, atomic);
>  	return end;
>  }
>

Where do you invalidate for munmap()?

Also, how to you resolve the case where you are not allowed to sleep?
I would have thought either you have to handle it, in which case nobody
needs to sleep; or you can't handle it, in which case the code is
broken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
