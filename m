Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FBB98D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 19:16:38 -0400 (EDT)
Date: Wed, 30 Mar 2011 15:51:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]mmap: improve scalability for updating vm_committed_as
Message-Id: <20110330155114.fa47dd9d.akpm@linux-foundation.org>
In-Reply-To: <1301447847.3981.49.camel@sli10-conroe>
References: <1301447847.3981.49.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 30 Mar 2011 09:17:27 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> In a workload with a lot of mmap/mumap, updating vm_committed_as is
> a scalability issue, because the percpu_counter_batch is too small, and
> the update needs hold percpu_counter lock.
> On the other hand, vm_committed_as is only used in OVERCOMMIT_NEVER case,
> which isn't the default setting.
> We can make the batch bigger in other cases and then switch to small batch
> in OVERCOMMIT_NEVER case, so that we will have no scalability issue with
> default setting. We flush all CPUs' percpu counter when switching
> sysctl_overcommit_memory, so there is no race the counter is incorrect.

The patch is purportedly a performance improvement, but the changelog
didn't tell us how much it improves performance?

> ...
>
> --- linux.orig/include/linux/mman.h	2011-03-29 16:28:57.000000000 +0800
> +++ linux/include/linux/mman.h	2011-03-30 09:01:38.000000000 +0800
> @@ -20,9 +20,17 @@ extern int sysctl_overcommit_memory;
>  extern int sysctl_overcommit_ratio;
>  extern struct percpu_counter vm_committed_as;
>  
> +extern int overcommit_memory_handler(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *lenp, loff_t *ppos);
>  static inline void vm_acct_memory(long pages)
>  {
> -	percpu_counter_add(&vm_committed_as, pages);
> +	/* avoid overflow and the value is big enough */
> +	int batch = INT_MAX/2;
> +
> +	if (sysctl_overcommit_memory == OVERCOMMIT_NEVER)
> +		batch = percpu_counter_batch;
> +
> +	__percpu_counter_add(&vm_committed_as, pages, batch);
>  }

It would be better to create a global __read_mostly variable for this
and alter its value within the sysctl, rather than recalculating it
each time.

This again points at the need to make the batch count a field within
the percpu_counter.

>  static inline void vm_unacct_memory(long pages)
> Index: linux/fs/proc/meminfo.c
> ===================================================================
> --- linux.orig/fs/proc/meminfo.c	2011-03-29 16:28:57.000000000 +0800
> +++ linux/fs/proc/meminfo.c	2011-03-30 09:01:38.000000000 +0800
> @@ -35,7 +35,7 @@ static int meminfo_proc_show(struct seq_
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  	si_meminfo(&i);
>  	si_swapinfo(&i);
> -	committed = percpu_counter_read_positive(&vm_committed_as);
> +	committed = percpu_counter_sum_positive(&vm_committed_as);
>  	allowed = ((totalram_pages - hugetlb_total_pages())
>  		* sysctl_overcommit_ratio / 100) + total_swap_pages;

This is a big change, and it wasn't even changelogged.  It's
potentially a tremendous increase in the expense of a read from
/proc/meminfo, which is a file that lots of tools will be polling. 
Many of those tools we don't even know about or have access to.

The change is unneeded if sysctl_overcommit_memory==OVERCOMMIT_NEVER,
but that's hardly a fix.

Quite worrisome.

Perhaps a better approach would be to carefully tune the batch size
according to the size of the machine.  Going all the way to INT_MAX/2
is surely overkill.


> Index: linux/kernel/sysctl.c
> ===================================================================
> --- linux.orig/kernel/sysctl.c	2011-03-29 16:28:57.000000000 +0800
> +++ linux/kernel/sysctl.c	2011-03-30 09:01:38.000000000 +0800
> @@ -56,6 +56,7 @@
>  #include <linux/kprobes.h>
>  #include <linux/pipe_fs_i.h>
>  #include <linux/oom.h>
> +#include <linux/mman.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/processor.h>
> @@ -86,8 +87,6 @@
>  #if defined(CONFIG_SYSCTL)
>  
>  /* External variables not in a header file. */
> -extern int sysctl_overcommit_memory;
> -extern int sysctl_overcommit_ratio;
>  extern int max_threads;
>  extern int core_uses_pid;
>  extern int suid_dumpable;
> @@ -977,7 +976,7 @@ static struct ctl_table vm_table[] = {
>  		.data		= &sysctl_overcommit_memory,
>  		.maxlen		= sizeof(sysctl_overcommit_memory),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec_minmax,
> +		.proc_handler	= overcommit_memory_handler,
>  		.extra1		= &zero,
>  		.extra2		= &two,
>  	},
> Index: linux/mm/mmap.c
> ===================================================================
> --- linux.orig/mm/mmap.c	2011-03-30 08:59:23.000000000 +0800
> +++ linux/mm/mmap.c	2011-03-30 09:01:38.000000000 +0800
> @@ -93,6 +93,33 @@ int sysctl_max_map_count __read_mostly =
>   */
>  struct percpu_counter vm_committed_as ____cacheline_internodealigned_in_smp;
>  
> +static void overcommit_drain_counter(struct work_struct *dummy)
> +{
> +	/*
> +	 * Flush percpu counter to global counter when batch is changed, see
> +	 * vm_acct_memory for detail
> +	 */
> +	vm_acct_memory(0);
> +}
> +
> +int overcommit_memory_handler(struct ctl_table *table, int write,
> +                void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	int error;
> +
> +	error = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
> +	if (error)
> +		return error;
> +
> +	if (write) {
> +		/* Make sure each CPU sees the new sysctl_overcommit_memory */
> +		smp_wmb();
> +		schedule_on_each_cpu(overcommit_drain_counter);
> +	}
> +
> +	return 0;
> +}

Calling vm_acct_memory(0) is a bit of a hack.

Rather than open-coding this twice, it would be better to introduce a
new percpu_counter core primitive to collapse the counters.

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
