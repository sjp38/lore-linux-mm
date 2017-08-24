Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8ACA0440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 11:46:37 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l189so4718500pga.7
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:46:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z1si102821pge.213.2017.08.24.08.46.34
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 08:46:35 -0700 (PDT)
Date: Thu, 24 Aug 2017 16:45:19 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170824154518.GB29665@leverpostej>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com>
 <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
 <20170814165047.GB23428@leverpostej>
 <20170823165842.k5lbxom45avvd7g2@smitten>
 <20170823170443.GD12567@leverpostej>
 <20170823171302.ubnv7qyrexhhpbs7@smitten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170823171302.ubnv7qyrexhhpbs7@smitten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On Wed, Aug 23, 2017 at 11:13:02AM -0600, Tycho Andersen wrote:
> On Wed, Aug 23, 2017 at 06:04:43PM +0100, Mark Rutland wrote:
> > On Wed, Aug 23, 2017 at 10:58:42AM -0600, Tycho Andersen wrote:
> > > Hi Mark,
> > > 
> > > On Mon, Aug 14, 2017 at 05:50:47PM +0100, Mark Rutland wrote:
> > > > That said, is there any reason not to use flush_tlb_kernel_range()
> > > > directly?
> > > 
> > > So it turns out that there is a difference between __flush_tlb_one() and
> > > flush_tlb_kernel_range() on x86: flush_tlb_kernel_range() flushes all the TLBs
> > > via on_each_cpu(), where as __flush_tlb_one() only flushes the local TLB (which
> > > I think is enough here).
> > 
> > That sounds suspicious; I don't think that __flush_tlb_one() is
> > sufficient.
> > 
> > If you only do local TLB maintenance, then the page is left accessible
> > to other CPUs via the (stale) kernel mappings. i.e. the page isn't
> > exclusively mapped by userspace.
> 
> I thought so too, so I tried to test it with something like the patch
> below. But it correctly failed for me when using __flush_tlb_one(). I
> suppose I'm doing something wrong in the test, but I'm not sure what.

I suspect the issue is that you use a completion to synchronise the
mapping.

The reader thread will block (i.e. it we go into schedule() and
something else will run), and I guess that on x86, that the
context-switch this entails upon completion happens to invalidate the
TLBs.

Instead, you could serialise the update with the reader doing:

	/* spin until address is published to us */
	addr = smp_cond_load_acquire(arg->virt_addr, VAL != NULL);

	read_map(addr);

... and the writer doing:

	user_addr = do_map(...)

	...

	smp_store_release(arg->virt_addr, user_addr);

There would still be a chance of a context-switch, but it wouldn't be
mandatory.

As an aside, it looks like DEBUG_PAGEALLOC on x86 has the problem w.r.t.
under-invalidating, juding by the comments in x86's
__kernel_map_pages(). It only invalidates the local TLBs, even though
it should do it on all CPUs.

Thanks,
Mark.

> 
> Tycho
> 
> 
> From 1d1b0a18d56cf1634072096231bfbaa96cb2aa16 Mon Sep 17 00:00:00 2001
> From: Tycho Andersen <tycho@docker.com>
> Date: Tue, 22 Aug 2017 18:07:12 -0600
> Subject: [PATCH] add XPFO_SMP test
> 
> Signed-off-by: Tycho Andersen <tycho@docker.com>
> ---
>  drivers/misc/lkdtm.h      |   1 +
>  drivers/misc/lkdtm_core.c |   1 +
>  drivers/misc/lkdtm_xpfo.c | 139 ++++++++++++++++++++++++++++++++++++++++++----
>  3 files changed, 130 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/misc/lkdtm.h b/drivers/misc/lkdtm.h
> index fc53546113c1..34a6ee37f216 100644
> --- a/drivers/misc/lkdtm.h
> +++ b/drivers/misc/lkdtm.h
> @@ -67,5 +67,6 @@ void lkdtm_USERCOPY_KERNEL(void);
>  /* lkdtm_xpfo.c */
>  void lkdtm_XPFO_READ_USER(void);
>  void lkdtm_XPFO_READ_USER_HUGE(void);
> +void lkdtm_XPFO_SMP(void);
>  
>  #endif
> diff --git a/drivers/misc/lkdtm_core.c b/drivers/misc/lkdtm_core.c
> index 164bc404f416..9544e329de4b 100644
> --- a/drivers/misc/lkdtm_core.c
> +++ b/drivers/misc/lkdtm_core.c
> @@ -237,6 +237,7 @@ struct crashtype crashtypes[] = {
>  	CRASHTYPE(USERCOPY_KERNEL),
>  	CRASHTYPE(XPFO_READ_USER),
>  	CRASHTYPE(XPFO_READ_USER_HUGE),
> +	CRASHTYPE(XPFO_SMP),
>  };
>  
>  
> diff --git a/drivers/misc/lkdtm_xpfo.c b/drivers/misc/lkdtm_xpfo.c
> index c72509128eb3..7600fdcae22f 100644
> --- a/drivers/misc/lkdtm_xpfo.c
> +++ b/drivers/misc/lkdtm_xpfo.c
> @@ -4,22 +4,27 @@
>  
>  #include "lkdtm.h"
>  
> +#include <linux/cpumask.h>
>  #include <linux/mman.h>
>  #include <linux/uaccess.h>
>  #include <linux/xpfo.h>
> +#include <linux/kthread.h>
>  
> -void read_user_with_flags(unsigned long flags)
> +#include <linux/delay.h>
> +#include <linux/sched/task.h>
> +
> +#define XPFO_DATA 0xdeadbeef
> +
> +static unsigned long do_map(unsigned long flags)
>  {
> -	unsigned long user_addr, user_data = 0xdeadbeef;
> -	phys_addr_t phys_addr;
> -	void *virt_addr;
> +	unsigned long user_addr, user_data = XPFO_DATA;
>  
>  	user_addr = vm_mmap(NULL, 0, PAGE_SIZE,
>  			    PROT_READ | PROT_WRITE | PROT_EXEC,
>  			    flags, 0);
>  	if (user_addr >= TASK_SIZE) {
>  		pr_warn("Failed to allocate user memory\n");
> -		return;
> +		return 0;
>  	}
>  
>  	if (copy_to_user((void __user *)user_addr, &user_data,
> @@ -28,25 +33,61 @@ void read_user_with_flags(unsigned long flags)
>  		goto free_user;
>  	}
>  
> +	return user_addr;
> +
> +free_user:
> +	vm_munmap(user_addr, PAGE_SIZE);
> +	return 0;
> +}
> +
> +static unsigned long *user_to_kernel(unsigned long user_addr)
> +{
> +	phys_addr_t phys_addr;
> +	void *virt_addr;
> +
>  	phys_addr = user_virt_to_phys(user_addr);
>  	if (!phys_addr) {
>  		pr_warn("Failed to get physical address of user memory\n");
> -		goto free_user;
> +		return 0;
>  	}
>  
>  	virt_addr = phys_to_virt(phys_addr);
>  	if (phys_addr != virt_to_phys(virt_addr)) {
>  		pr_warn("Physical address of user memory seems incorrect\n");
> -		goto free_user;
> +		return 0;
>  	}
>  
> +	return virt_addr;
> +}
> +
> +static void read_map(unsigned long *virt_addr)
> +{
>  	pr_info("Attempting bad read from kernel address %p\n", virt_addr);
> -	if (*(unsigned long *)virt_addr == user_data)
> -		pr_info("Huh? Bad read succeeded?!\n");
> +	if (*(unsigned long *)virt_addr == XPFO_DATA)
> +		pr_err("FAIL: Bad read succeeded?!\n");
>  	else
> -		pr_info("Huh? Bad read didn't fail but data is incorrect?!\n");
> +		pr_err("FAIL: Bad read didn't fail but data is incorrect?!\n");
> +}
> +
> +static void read_user_with_flags(unsigned long flags)
> +{
> +	unsigned long user_addr, *kernel;
> +
> +	user_addr = do_map(flags);
> +	if (!user_addr) {
> +		pr_err("FAIL: map failed\n");
> +		return;
> +	}
> +
> +	kernel = user_to_kernel(user_addr);
> +	if (!kernel) {
> +		pr_err("FAIL: user to kernel conversion failed\n");
> +		goto free_user;
> +	}
> +
> +	read_map(kernel);
>  
> - free_user:
> +free_user:
>  	vm_munmap(user_addr, PAGE_SIZE);
>  }
>  
> @@ -60,3 +101,79 @@ void lkdtm_XPFO_READ_USER_HUGE(void)
>  {
>  	read_user_with_flags(MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB);
>  }
> +
> +struct smp_arg {
> +	struct completion map_done;
> +	unsigned long *virt_addr;
> +	unsigned int cpu;
> +};
> +
> +static int smp_reader(void *parg)
> +{
> +	struct smp_arg *arg = parg;
> +
> +	if (arg->cpu != smp_processor_id()) {
> +		pr_err("FAIL: scheduled on wrong CPU?\n");
> +		return 0;
> +	}
> +
> +	wait_for_completion(&arg->map_done);
> +
> +	if (arg->virt_addr)
> +		read_map(arg->virt_addr);
> +
> +	return 0;
> +}
> +
> +/* The idea here is to read from the kernel's map on a different thread than
> + * did the mapping (and thus the TLB flushing), to make sure that the page
> + * faults on other cores too.
> + */
> +void lkdtm_XPFO_SMP(void)
> +{
> +	unsigned long user_addr;
> +	struct task_struct *thread;
> +	int ret;
> +	struct smp_arg arg;
> +
> +	init_completion(&arg.map_done);
> +
> +	if (num_online_cpus() < 2) {
> +		pr_err("not enough to do a multi cpu test\n");
> +		return;
> +	}
> +
> +	arg.cpu = (smp_processor_id() + 1) % num_online_cpus();
> +	thread = kthread_create(smp_reader, &arg, "lkdtm_xpfo_test");
> +	if (IS_ERR(thread)) {
> +		pr_err("couldn't create kthread? %ld\n", PTR_ERR(thread));
> +		return;
> +	}
> +
> +	kthread_bind(thread, arg.cpu);
> +	get_task_struct(thread);
> +	wake_up_process(thread);
> +
> +	user_addr = do_map(MAP_PRIVATE | MAP_ANONYMOUS);
> +	if (user_addr) {
> +		arg.virt_addr = user_to_kernel(user_addr);
> +		/* child thread checks for failure */
> +	}
> +
> +	complete(&arg.map_done);
> +
> +	/* there must be a better way to do this. */
> +	while (1) {
> +		if (thread->exit_state)
> +			break;
> +		msleep_interruptible(100);
> +	}
> +
> +	ret = kthread_stop(thread);
> +	if (ret != SIGKILL)
> +		pr_err("FAIL: thread wasn't killed: %d\n", ret);
> +	put_task_struct(thread);
> +
> +	if (user_addr)
> +		vm_munmap(user_addr, PAGE_SIZE);
> +}
> -- 
> 2.11.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
