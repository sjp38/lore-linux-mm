Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id AE2AB6B00A1
	for <linux-mm@kvack.org>; Tue, 21 May 2013 19:41:56 -0400 (EDT)
Date: Tue, 21 May 2013 16:41:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] Make the batch size of the percpu_counter
 configurable
Message-Id: <20130521164154.bed705c6e117ceb76205cd65@linux-foundation.org>
In-Reply-To: <1369178849.27102.330.camel@schen9-DESK>
References: <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
	<20130521134122.4d8ea920c0f851fc2d97abc9@linux-foundation.org>
	<1369178849.27102.330.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Eric Dumazet <eric.dumazet@gmail.com>, Ric Mason <ric.masonn@gmail.com>, Simon Jeons <simon.jeons@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, 21 May 2013 16:27:29 -0700 Tim Chen <tim.c.chen@linux.intel.com> wrote:

> Will something like the following work if we get rid of the percpu
> counter changes and use __percpu_counter_add(..., batch)?  In
> benchmark with a lot of memory changes via brk, this makes quite
> a difference when we go to a bigger batch size.

That looks pretty close.

> Tim
> 
> Change batch size for memory accounting to be proportional to memory available.
> 
> Currently the per cpu counter's batch size for memory accounting is
> configured as twice the number of cpus in the system.  However,
> for system with very large memory, it is more appropriate to make it
> proportional to the memory size per cpu in the system.
> 
> For example, for a x86_64 system with 64 cpus and 128 GB of memory,
> the batch size is only 2*64 pages (0.5 MB).  So any memory accounting
> changes of more than 0.5MB will overflow the per cpu counter into
> the global counter.  Instead, for the new scheme, the batch size
> is configured to be 0.4% of the memory/cpu = 8MB (128 GB/64 /256),
> which is more inline with the memory size.
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>  include/linux/mman.h |  5 +++++
>  mm/mmap.c            | 14 ++++++++++++++
>  mm/nommu.c           | 14 ++++++++++++++
>  3 files changed, 33 insertions(+)
> 
> diff --git a/include/linux/mman.h b/include/linux/mman.h
> index 9aa863d..11d5ce9 100644
> --- a/include/linux/mman.h
> +++ b/include/linux/mman.h
> @@ -10,12 +10,17 @@
>  extern int sysctl_overcommit_memory;
>  extern int sysctl_overcommit_ratio;
>  extern struct percpu_counter vm_committed_as;
> +extern int vm_committed_as_batch;
>  
>  unsigned long vm_memory_committed(void);
>  
>  static inline void vm_acct_memory(long pages)
>  {
> +#ifdef CONFIG_SMP
> +	__percpu_counter_add(&vm_committed_as, pages, vm_committed_as_batch);
> +#else
>  	percpu_counter_add(&vm_committed_as, pages);
> +#endif
>  }

I think we could use __percpu_counter_add() unconditionally here and
just do

#ifdef CONFIG_SMP
#define vm_committed_as_batch 0
#else
int vm_committed_as_batch;
#endif

The EXPORT_SYMBOL(vm_committed_as_batch) is unneeded.

> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3145,11 +3145,25 @@ void mm_drop_all_locks(struct mm_struct *mm)
>  /*
>   * initialise the VMA slab
>   */
> +
> +int vm_committed_as_batch;
> +EXPORT_SYMBOL(vm_committed_as_batch);
> +
> +static int mm_compute_batch(void)
> +{
> +	int nr = num_present_cpus();
> +	int batch = max(32, nr*2);
> +
> +	/* batch size set to 0.4% of (total memory/#cpus) */
> +	return max((int) (totalram_pages/nr) / 256, batch);
> +}

Change this to do the assignment to vm_committed_as_batch then put this
code inside #ifdef CONFIG_SMP and do

#else	/* CONFIG_SMP */
static inline void mm_compute_batch(void)
{
}
#endif

>  void __init mmap_init(void)
>  {
>  	int ret;
>  
>  	ret = percpu_counter_init(&vm_committed_as, 0);
> +	vm_committed_as_batch = mm_compute_batch();

This becomes just

	mm_compute_batch();

>  	VM_BUG_ON(ret);
>  }
>  
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 298884d..1b7008a 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -527,11 +527,25 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
>  /*
>   * initialise the VMA and region record slabs
>   */
> +
> +int vm_committed_as_batch;
> +EXPORT_SYMBOL(vm_committed_as_batch);
> +
> +static int mm_compute_batch(void)
> +{
> +	int nr = num_present_cpus();
> +	int batch = max(32, nr*2);
> +
> +	/* batch size set to 0.4% of (total memory/#cpus) */
> +	return max((int) (totalram_pages/nr) / 256, batch);
> +}
> +
>  void __init mmap_init(void)
>  {
>  	int ret;
>  
>  	ret = percpu_counter_init(&vm_committed_as, 0);
> +	vm_committed_as_batch = mm_compute_batch();
>  	VM_BUG_ON(ret);
>  	vm_region_jar = KMEM_CACHE(vm_region, SLAB_PANIC);

I'm not sure that CONFIG_MMU=n && CONFIG_SMP=y even exists.  Perhaps it
does.  But there's no point in ruling out that option here.

The nommu code becomes identical to the mmu code so we should put it in
a shared file.  I suppose mmap.c would be as good a place as any.

We could make mm_compute_batch() __init and call it from mm_init(). 
But really it should be __meminit and there should be a memory-hotplug
notifier handler which adjusts vm_committed_as_batch's value.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
