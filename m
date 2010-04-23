Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 812FA6B01F0
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 05:59:45 -0400 (EDT)
Date: Fri, 23 Apr 2010 10:59:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-ID: <20100423095922.GJ30306@csn.ul.ie>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 12:01:48PM +0900, KAMEZAWA Hiroyuki wrote:
> This patch itself is for -mm ..but may need to go -stable tree for memory
> hotplug. (but we've got no report to hit this race...)
> 

Only because it's very difficult to hit. Even when running compaction
constantly, it can take anywhere between 10 minutes and 2 hours for me
to reproduce it.

> This one is the simplest, I think and works well on my test set.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In rmap.c, at checking rmap in vma chain in page->mapping, anon_vma->lock
> or mapping->i_mmap_lock is held and enter following loop.
> 
> 	for_each_vma_in_this_rmap_link(list from page->mapping) {
> 		unsigned long address = vma_address(page, vma);
> 		if (address == -EFAULT)
> 			continue;
> 		....
> 	}
> 
> vma_address is checking [start, end, pgoff] v.s. page->index.
> 
> But vma's [start, end, pgoff] is updated without locks. vma_address()
> can hit a race and may return wrong result.
> 
> This bahavior is no problem in usual routine as try_to_unmap() etc...
> But for page migration, rmap_walk() has to find all migration_ptes
> which migration code overwritten valid ptes. This race is critical and cause
> BUG that a migration_pte is sometimes not removed.
> 
> pr 21 17:27:47 localhost kernel: ------------[ cut here ]------------
> Apr 21 17:27:47 localhost kernel: kernel BUG at include/linux/swapops.h:105!
> Apr 21 17:27:47 localhost kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> Apr 21 17:27:47 localhost kernel: last sysfs file: /sys/devices/virtual/net/br0/statistics/collisions
> Apr 21 17:27:47 localhost kernel: CPU 3
> Apr 21 17:27:47 localhost kernel: Modules linked in: fuse sit tunnel4 ipt_MASQUERADE iptable_nat nf_nat bridge stp llc sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf xt_physdev ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 dm_multipath uinput ioatdma ppdev parport_pc i5000_edac bnx2 iTCO_wdt edac_core iTCO_vendor_support shpchp parport e1000e kvm_intel dca kvm i2c_i801 i2c_core i5k_amb pcspkr megaraid_sas [last unloaded: microcode]
> Apr 21 17:27:47 localhost kernel:
> Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G        W   2.6.34-rc4-mm1+ #4 D2519/PRIMERGY          
> Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>]  [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08  EFLAGS: 00010246
> Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea0000241100 RCX: 0000000000000001
> Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff880621a4ab00 RDI: 000000000149c03e
> Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 0000000000000000 R09: 0000000000000000
> Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 0000000000000001 R12: ffff880621a4aae8
> Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 000000000149c03e R15: 0000000000000000
> Apr 21 17:27:47 localhost kernel: FS:  00007fe6abc90700(0000) GS:ffff880005a00000(0000) knlGS:0000000000000000
> Apr 21 17:27:47 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> Apr 21 17:27:47 localhost kernel: CR2: 00007fe6a37279a0 CR3: 000000008d942000 CR4: 00000000000006e0
> Apr 21 17:27:47 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Apr 21 17:27:47 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Apr 21 17:27:47 localhost kernel: Process cc1 (pid: 27892, threadinfo ffff88008d9ee000, task ffff8800b23ec820)
> Apr 21 17:27:47 localhost kernel: Stack:
> Apr 21 17:27:47 localhost kernel: ffffea000101aee8 ffff880621a4aae8 ffff88008d9efe38 00007fe6a37279a0
> Apr 21 17:27:47 localhost kernel: <0> ffff8805d9706d90 ffff880621a4aa00 ffff88008d9efef8 ffffffff81126d05
> Apr 21 17:27:47 localhost kernel: <0> ffff88008d9efec8 0000000000000246 0000000000000000 ffffffff81586533
> Apr 21 17:27:47 localhost kernel: Call Trace:
> Apr 21 17:27:47 localhost kernel: [<ffffffff81126d05>] handle_mm_fault+0x995/0x9b0
> Apr 21 17:27:47 localhost kernel: [<ffffffff81586533>] ? do_page_fault+0x103/0x330
> Apr 21 17:27:47 localhost kernel: [<ffffffff8104bf40>] ? finish_task_switch+0x0/0xf0
> Apr 21 17:27:47 localhost kernel: [<ffffffff8158659e>] do_page_fault+0x16e/0x330
> Apr 21 17:27:47 localhost kernel: [<ffffffff81582f35>] page_fault+0x25/0x30
> Apr 21 17:27:47 localhost kernel: Code: 53 08 85 c9 0f 84 32 ff ff ff 8d 41 01 89 4d d8 89 45 d4 8b 75 d4 8b 45 d8 f0 0f b1 32 89 45 dc 8b 45 dc 39 c8 74 aa 89 c1 eb d7 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5
> Apr 21 17:27:47 localhost kernel: RIP  [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
> Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]---
> 
> This patch adds vma_address_safe(). And update [start, end, pgoff]
> under seq counter. 
> 

I had considered this idea as well as it is vaguely similar to how zones get
resized with a seqlock. I was hoping that the existing locking on anon_vma
would be usable by backing off until uncontended but maybe not so lets
check out this approach.

> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/mm_types.h |    2 ++
>  mm/mmap.c                |   15 ++++++++++++++-
>  mm/rmap.c                |   25 ++++++++++++++++++++++++-
>  3 files changed, 40 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.34-rc5-mm1/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.34-rc5-mm1.orig/include/linux/mm_types.h
> +++ linux-2.6.34-rc5-mm1/include/linux/mm_types.h
> @@ -12,6 +12,7 @@
>  #include <linux/completion.h>
>  #include <linux/cpumask.h>
>  #include <linux/page-debug-flags.h>
> +#include <linux/seqlock.h>
>  #include <asm/page.h>
>  #include <asm/mmu.h>
>  
> @@ -183,6 +184,7 @@ struct vm_area_struct {
>  #ifdef CONFIG_NUMA
>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>  #endif
> +	seqcount_t updating;	/* works like seqlock for updating vma info. */
>  };
>  

#ifdef CONFIG_MIGRATION ?

Minor issue, but would you consider matching the making used when altering
the size of zones? e.g. seqcount_t span_seqcounter, vma_span_seqbegin,
vma_span_seqend etc?

>  struct core_thread {
> Index: linux-2.6.34-rc5-mm1/mm/mmap.c
> ===================================================================
> --- linux-2.6.34-rc5-mm1.orig/mm/mmap.c
> +++ linux-2.6.34-rc5-mm1/mm/mmap.c
> @@ -491,6 +491,16 @@ __vma_unlink(struct mm_struct *mm, struc
>  		mm->mmap_cache = prev;
>  }
>  
> +static void adjust_start_vma(struct vm_area_struct *vma)
> +{
> +	write_seqcount_begin(&vma->updating);
> +}
> +
> +static void adjust_end_vma(struct vm_area_struct *vma)
> +{
> +	write_seqcount_end(&vma->updating);
> +}
> +
>  /*
>   * We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that
>   * is already present in an i_mmap tree without adjusting the tree.
> @@ -584,13 +594,16 @@ again:			remove_next = 1 + (end > next->
>  		if (adjust_next)
>  			vma_prio_tree_remove(next, root);
>  	}
> -
> +	adjust_start_vma(vma);
>  	vma->vm_start = start;
>  	vma->vm_end = end;
>  	vma->vm_pgoff = pgoff;
> +	adjust_end_vma(vma);
>  	if (adjust_next) {
> +		adjust_start_vma(next);
>  		next->vm_start += adjust_next << PAGE_SHIFT;
>  		next->vm_pgoff += adjust_next;
> +		adjust_end_vma(next);
>  	}

I'm not 100% sure about this, I think either the seqcounter needs
a larger span and possibly to be based on the mm instead of the VMA or
rmap_walk_[anon|ksm] has to do a full restart if there is a simultaneous
update.

Lets take the case;

VMA A		- Any given VMA with a page being migrated

During migration, munmap() is called so the VMA is now being split to
give

VMA A-lower	- The lower part of the VMA
hole		- A hole due to munmap
VMA A-upper	- The new VMA inserted as a result of munmap that
		  spans the page being migrated.

vma_adjust() takes the seq counters when updating the range of VMA
A-lower but VMA a-upper is not linked in yet and rmap_walk_[anon|ksm] is
now looking at the wrong VMA.

In this case, rmap_walk_anon() would correct check the range of
VMA A-lower but still get the wrong answer because it should have been
checking the new VMA A-upper.

I believe my backoff-if-lock-contended patch caught this situation
by always restarting the entire operation if there was lock contention.
Once the lock was acquired the VMA list could be different so had
to be restarted to be sure we were checking the right VMA.

For the seqcounter, the adjust_start_vma() needs to be at the beginning
of the operation and adjust_end_vma() must be after all the VMA updates
have completed, including any adjustments of the prio trees, the anon_vma
lists etc. However, to avoid deadlocks rmap_walk_anon() needs to release is
anon_vma->lock otherwise the VMA list update will deadlock waiting on the
same lock.

>  
>  	if (root) {
> Index: linux-2.6.34-rc5-mm1/mm/rmap.c
> ===================================================================
> --- linux-2.6.34-rc5-mm1.orig/mm/rmap.c
> +++ linux-2.6.34-rc5-mm1/mm/rmap.c
> @@ -342,6 +342,23 @@ vma_address(struct page *page, struct vm
>  }
>  
>  /*
> + * vma's address check is racy if we don't hold mmap_sem. This function
> + * gives a safe way for accessing the [start, end, pgoff] tuple of vma.
> + */
> +
> +static inline unsigned long vma_address_safe(struct page *page,
> +		struct vm_area_struct *vma)
> +{
> +	unsigned long ret, safety;
> +
> +	do {
> +		safety = read_seqcount_begin(&vma->updating);
> +		ret = vma_address(page, vma);
> +	} while (read_seqcount_retry(&vma->updating, safety));
> +	return ret;
> +}
> +
> +/*
>   * At what user virtual address is page expected in vma?
>   * checking that the page matches the vma.
>   */
> @@ -1372,7 +1389,13 @@ static int rmap_walk_anon(struct page *p
>  	spin_lock(&anon_vma->lock);
>  	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
>  		struct vm_area_struct *vma = avc->vma;
> -		unsigned long address = vma_address(page, vma);
> +		unsigned long address;
> +
> +		/*
> +		 * In page migration, this race is critical. So, use
> +		 * safe version.
> +		 */
> +		address = vma_address_safe(page, vma);

If I'm right above about maybe checking the wrong VMA due to an munmap,
vma_address_safe isn't the right thing as such. Once the seqcounter covers
the entire VMA updates, it would then look like

unsigned long safety = read_seqcount_begin(&vma->updating);
address = vma_address(page, vma);
if (read_seqcount_retry(&vma->updating, safety)) {
	/*
	 * We raced against an updater of the VMA without mmap_sem held.
	 * Release the anon_vma lock to allow the update to complete and
	 * restart the operation
	 */
	spin_unlock(&anon_vma->lock);
	goto restart;
}

where the restart label lookup up the pages anon_vma again, reacquires
the lock and starts a walk on the anon_vma_chain list again.

What do you think?

>  		if (address == -EFAULT)
>  			continue;
>  		ret = rmap_one(page, vma, address, arg);
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
