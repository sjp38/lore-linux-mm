Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 77E5C6B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 12:01:32 -0500 (EST)
Date: Thu, 8 Nov 2012 17:01:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC 1/3] mm: Add VM pressure notifications
Message-ID: <20121108170124.GB8218@suse.de>
References: <20121107105348.GA25549@lizard>
 <20121107110128.GA30462@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121107110128.GA30462@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

(Sorry about being very late reviewing this)

On Wed, Nov 07, 2012 at 03:01:28AM -0800, Anton Vorontsov wrote:
> This patch introduces vmpressure_fd() system call. The system call creates
> a new file descriptor that can be used to monitor Linux' virtual memory
> management pressure. There are three discrete levels of the pressure:
> 

Why was eventfd unsuitable? It's a bit trickier to use but there are
examples in the kernel where an application is required to do something like

1. open eventfd
2. open a control file, say /proc/sys/vm/vmpressure or if cgroups
   /sys/fs/cgroup/something/vmpressure
3. write fd_event fd_control [low|medium|oom]. Can be a binary structure
   you write

and then poll the eventfd. The trickiness is awkward but a library
implementation of vmpressure_fd() that mapped onto eventfd properly should
be trivial.

I confess I'm not super familiar with eventfd and if this can actually
work in practice but I found the introduction of a dedicated syscall
surprising. Apologies if this has been discussed already. If it was,
it should be in the changelog to prevent stupid questions from drive-by
reviewers.

> VMPRESSURE_LOW: Notifies that the system is reclaiming memory for new
> allocations. Monitoring reclaiming activity might be useful for
> maintaining overall system's cache level.
> 

If you do another revision, add a caveat that a streaming reader might
be enough to trigger this level. It's not necessarily a problem of
course.

> VMPRESSURE_MEDIUM: The system is experiencing medium memory pressure,
> there might be some mild swapping activity. Upon this event applications
> may decide to free any resources that can be easily reconstructed or
> re-read from a disk.
> 

Good.

> VMPRESSURE_OOM: The system is actively thrashing, it is about to go out of
> memory (OOM) or even the in-kernel OOM killer is on its way to trigger.
> Applications should do whatever they can to help the system.
> 

Good.

> There are four sysctls to tune the behaviour of the levels:
> 
>   vmevent_window
>   vmevent_level_medium
>   vmevent_level_oom
>   vmevent_level_oom_priority
> 

Superficially these feel like the might expose implementation details of
the pressure implementation and therby indirectly expose the internals
of the VM. Should these be debugfs instead of sysctls that spit out a
warning if used so it generates a bug report? That won't stop someone
depending on them anyway but if these values are changed we should
immediately hear why it was necessary.

> Currently vmevent pressure levels are based on the reclaimer inefficiency
> index (range from 0 to 100). The index shows the relative time spent by
> the kernel uselessly scanning pages, or, in other words, the percentage of
> scans of pages (vmevent_window) that were not reclaimed. The higher the
> index, the more it should be evident that new allocations' cost becomes
> higher.
> 

Good.

> The files vmevent_level_medium and vmevent_level_oom accept the index
> values (by default set to 60 and 99 respectively). A non-existent
> vmevent_level_low tunable is always set to 0
> 
> When index equals to 0, this means that the kernel is reclaiming, but
> every scanned page has been successfully reclaimed (so the pressure is
> low). 100 means that the kernel is trying to reclaim, but nothing can be
> reclaimed (OOM).
> 
> Window size is used as a rate-limit tunable for VMPRESSURE_LOW
> notifications and for averaging for VMPRESSURE_{MEDIUM,OOM} levels. So,
> using small window sizes can cause lot of false positives for _MEDIUM and
> _OOM levels, but too big window size may delay notifications. By default
> the window size equals to 256 pages (1MB).
> 

I think it would be reasonable to leave the window as a sysctl but rename
it vmpressure_sensitivity. Tuning it to be very "sensitive" would initially
be implemented as the window shrinking.

> The _OOM level is also attached to the reclaimer's priority. When the
> system is almost OOM, it might be getting the last reclaimable pages
> slowly, scanning all the queues, and so we never catch the OOM case via
> window-size averaging. For this case the priority can be used to determine
> the pre-OOM condition, the pre-OOM priority level can be set via
> vmpressure_level_oom_prio sysctl.
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> ---
>  Documentation/sysctl/vm.txt      |  48 ++++++++
>  arch/x86/syscalls/syscall_64.tbl |   1 +
>  include/linux/syscalls.h         |   2 +
>  include/linux/vmpressure.h       | 128 ++++++++++++++++++++++
>  kernel/sys_ni.c                  |   1 +
>  kernel/sysctl.c                  |  31 ++++++
>  mm/Kconfig                       |  13 +++
>  mm/Makefile                      |   1 +
>  mm/vmpressure.c                  | 231 +++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                      |   5 +
>  10 files changed, 461 insertions(+)
>  create mode 100644 include/linux/vmpressure.h
>  create mode 100644 mm/vmpressure.c
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 078701f..9837fe2 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -44,6 +44,10 @@ Currently, these files are in /proc/sys/vm:
>  - nr_overcommit_hugepages
>  - nr_trim_pages         (only if CONFIG_MMU=n)
>  - numa_zonelist_order
> +- vmpressure_window
> +- vmpressure_level_medium
> +- vmpressure_level_oom
> +- vmpressure_level_oom_priority
>  - oom_dump_tasks
>  - oom_kill_allocating_task
>  - overcommit_memory
> @@ -487,6 +491,50 @@ this is causing problems for your system/application.
>  
>  ==============================================================
>  
> +vmpressure_window
> +vmpressure_level_med
> +vmpressure_level_oom
> +vmpressure_level_oom_priority
> +
> +These sysctls are used to tune vmpressure_fd(2) behaviour.
> +

Ok, I'm ok with FD being the interface. I think it makes sense and means
it can be used with select or poll.

> +Currently vmpressure pressure levels are based on the reclaimer
> +inefficiency index (range from 0 to 100). The files vmpressure_level_med
> +and vmpressure_level_oom accept the index values (by default set to 60 and
> +99 respectively). A non-existent vmpressure_level_low tunable is always
> +set to 0
> +
> +When the system is short on idle pages, the new memory is allocated by
> +reclaiming least recently used resources: kernel scans pages to be
> +reclaimed (e.g. from file caches, mmap(2) volatile ranges, etc.; and
> +potentially swapping some pages out). The index shows the relative time
> +spent by the kernel uselessly scanning pages, or, in other words, the
> +percentage of scans of pages (vmpressure_window) that were not reclaimed.
> +The higher the index, the more it should be evident that new allocations'
> +cost becomes higher.
> +
> +When index equals to 0, this means that the kernel is reclaiming, but
> +every scanned page has been successfully reclaimed (so the pressure is
> +low). 100 means that the kernel is trying to reclaim, but nothing can be
> +reclaimed (close to OOM).
> +
> +Window size is used as a rate-limit tunable for VMPRESSURE_LOW
> +notifications and for averaging for VMPRESSURE_{MEDIUM,OOM} levels. So,
> +using small window sizes can cause lot of false positives for _MEDIUM and
> +_OOM levels, but too big window size may delay notifications. By default
> +the window size equals to 256 pages (1MB).
> +
> +When the system is almost OOM it might be getting the last reclaimable
> +pages slowly, scanning all the queues, and so we never catch the OOM case
> +via window-size averaging. For this case there is another mechanism of
> +detecting the pre-OOM conditions: kernel's reclaimer has a scanning
> +priority, the higest priority is 0 (reclaimer will scan all the available
> +pages). Kernel starts scanning with priority set to 12 (queue_length >>
> +12). So, vmpressure_level_oom_prio should be between 0 and 12 (by default
> +it is set to 4).
> +

Sounds good. Again, be careful on how much implementation detail you expose
to the interface. I think the actual user-visible interface should be low,
medium, high with a sensitivity tunable but the ranges and window sizes
hidden away (or at least in debugfs).

> +==============================================================
> +
>  oom_dump_tasks
>  
>  Enables a system-wide task dump (excluding kernel threads) to be
> diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
> index 316449a..6e4fa6a 100644
> --- a/arch/x86/syscalls/syscall_64.tbl
> +++ b/arch/x86/syscalls/syscall_64.tbl
> @@ -320,6 +320,7 @@
>  311	64	process_vm_writev	sys_process_vm_writev
>  312	common	kcmp			sys_kcmp
>  313	64	vmevent_fd		sys_vmevent_fd
> +314	64	vmpressure_fd		sys_vmpressure_fd
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 19439c7..3d2587d 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -63,6 +63,7 @@ struct getcpu_cache;
>  struct old_linux_dirent;
>  struct perf_event_attr;
>  struct file_handle;
> +struct vmpressure_config;
>  
>  #include <linux/types.h>
>  #include <linux/aio_abi.h>
> @@ -860,4 +861,5 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
>  
>  asmlinkage long sys_kcmp(pid_t pid1, pid_t pid2, int type,
>  			 unsigned long idx1, unsigned long idx2);
> +asmlinkage long sys_vmpressure_fd(struct vmpressure_config __user *config);
>  #endif
> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
> new file mode 100644
> index 0000000..b808b04
> --- /dev/null
> +++ b/include/linux/vmpressure.h
> @@ -0,0 +1,128 @@
> +/*
> + * Linux VM pressure notifications
> + *
> + * Copyright 2011-2012 Pekka Enberg <penberg@kernel.org>
> + * Copyright 2011-2012 Linaro Ltd.
> + *		       Anton Vorontsov <anton.vorontsov@linaro.org>
> + *
> + * Based on ideas from KOSAKI Motohiro, Leonid Moiseichuk, Mel Gorman,
> + * Minchan Kim and Pekka Enberg.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published
> + * by the Free Software Foundation.
> + */
> +
> +#ifndef _LINUX_VMPRESSURE_H
> +#define _LINUX_VMPRESSURE_H
> +
> +#include <linux/types.h>
> +
> +/**
> + * enum vmpressure_level - Memory pressure levels
> + * @VMPRESSURE_LOW:	The system is short on idle pages, losing caches
> + * @VMPRESSURE_MEDIUM:	New allocations' cost becomes high
> + * @VMPRESSURE_OOM:	The system is about to go out-of-memory
> + */
> +enum vmpressure_level {
> +	/* We spread the values, reserving room for new levels. */
> +	VMPRESSURE_LOW		= 1 << 10,
> +	VMPRESSURE_MEDIUM	= 1 << 20,
> +	VMPRESSURE_OOM		= 1 << 30,
> +};
> +

Once again, be careful on what you expose to userspace. Bear in mind these
are compiled to to maintain binary compatability the user-visible structure
should be plain enums.

enum vmpressure_level {
	VM_PRESSURE_LOW,
	VM_PRESSURE_MEDIUM,
	VM_PRESSURE_OOM
};

These should then be mapped to a kernel internal ranges

enum __vmpressure_level_range_internal {
	__VM_PRESSURE_LOW = 1<< 10,
	__VM_PRESSURE_MEDIUM = 1 << 20,
}

That allows the kernel internal ranges to change without worrying about
userspace compatability.

This comment would apply even if you used eventfd.

I don't mean to bitch about exposing implementation details but a stated
goal of this interface was to avoid having applications aware of VM
implementation details.

> +/**
> + * struct vmpressure_config - Configuration structure for vmpressure_fd()
> + * @size:	Size of the struct for ABI extensibility
> + * @threshold:	Minimum pressure level of notifications
> + *
> + * This structure is used to configure the file descriptor that
> + * vmpressure_fd() returns.
> + *
> + * @size is used to "version" the ABI, it must be initialized to
> + * 'sizeof(struct vmpressure_config)'.
> + *
> + * @threshold should be one of @vmpressure_level values, and specifies
> + * minimal level of notification that will be delivered.
> + */
> +struct vmpressure_config {
> +	__u32 size;
> +	__u32 threshold;
> +};
> +

Again I suspect this might be compatible with eventfd. The writing of the
eventfd just needs to handle a binary structure instead of strings without
having to introduce a dedicated system call.

The versioning of the structure is not a bad idea though but don't use
"size". Use a magic value for the high bits and a number of the low bits
and #define it VMPRESSURE_NOTIFY_MAGIC1

> +/**
> + * struct vmpressure_event - An event that is returned via vmpressure fd
> + * @pressure:	Most recent system's pressure level
> + *
> + * Upon notification, this structure must be read from the vmpressure file
> + * descriptor.
> + */
> +struct vmpressure_event {
> +	__u32 pressure;
> +};
> +

What is the meaning of "pressure" as returned to userspace?

Would it be better if userspace just received an event when the requested
threshold was reached but when it reads it just gets a single 0 byte that
should not be interpreted?

I say this because the application can only request low, medium or OOM
but gets a number back. How should it intepret that number? The value of
the number depends on sysctl files and I fear that applications will end
up making decisions on the implementation again.

I think it would be a lot safer for Pressure ABI v1 to return only 0 here
and see how far that gets. If Android has already gone through this process
and *know* they need this number then it should be documented.

If this has already been discussed, it should also be documented :P

I see from a debugging perspective why it might be handy to monitor
pressure over time. If so, then maybe a debugfs file would help with a
CLEAR warning that no application should depend on its existance (make it
depend on CONFIG_DEBUG_VMPRESSURE && CONFIG_DEBUG_VM or something).

> +#ifdef __KERNEL__
> +
> +struct mem_cgroup;
> +
> +#ifdef CONFIG_VMPRESSURE
> +
> +extern uint vmpressure_win;
> +extern uint vmpressure_level_med;
> +extern uint vmpressure_level_oom;
> +extern uint vmpressure_level_oom_prio;
> +
> +extern void __vmpressure(struct mem_cgroup *memcg,
> +			 ulong scanned, ulong reclaimed);
> +static void vmpressure(struct mem_cgroup *memcg,
> +		       ulong scanned, ulong reclaimed);
> +
> +/*
> + * OK, we're cheating. The thing is, we have to average s/r ratio by
> + * gathering a lot of scans (otherwise we might get some local
> + * false-positives index of '100').
> + *
> + * But... when we're almost OOM we might be getting the last reclaimable
> + * pages slowly, scanning all the queues, and so we never catch the OOM
> + * case via averaging. Although the priority will show it for sure. The
> + * pre-OOM priority value is mostly an empirically taken priority: we
> + * never observe it under any load, except for last few allocations before
> + * the OOM (but the exact value is still configurable via sysctl).
> + */
> +static inline void vmpressure_prio(struct mem_cgroup *memcg, int prio)
> +{
> +	if (prio > vmpressure_level_oom_prio)
> +		return;
> +
> +	/* OK, the prio is below the threshold, send the pre-OOM event. */
> +	vmpressure(memcg, vmpressure_win, 0);
> +}
> +
> +#else
> +static inline void __vmpressure(struct mem_cgroup *memcg,
> +				ulong scanned, ulong reclaimed) {}
> +static inline void vmpressure_prio(struct mem_cgroup *memcg, int prio) {}
> +#endif /* CONFIG_VMPRESSURE */
> +
> +static inline void vmpressure(struct mem_cgroup *memcg,
> +			      ulong scanned, ulong reclaimed)
> +{
> +	if (!scanned)
> +		return;
> +
> +	if (IS_BUILTIN(CONFIG_MEMCG) && memcg) {
> +		/*
> +		 * The vmpressure API reports system pressure, for per-cgroup
> +		 * pressure, we'll chain cgroups notifications, this is to
> +		 * be implemented.
> +		 *
> +		 * memcg_vm_pressure(target_mem_cgroup, scanned, reclaimed);
> +		 */
> +		return;
> +	}
> +	__vmpressure(memcg, scanned, reclaimed);
> +}
> +

Ok. Personally I'm ok with memcg support not existing initially. If we
can't get the global case right, then the memcg case is impossible.

> +#endif /* __KERNEL__ */
> +
> +#endif /* _LINUX_VMPRESSURE_H */
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index 3ccdbf4..9573a5a 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -192,6 +192,7 @@ cond_syscall(compat_sys_timerfd_gettime);
>  cond_syscall(sys_eventfd);
>  cond_syscall(sys_eventfd2);
>  cond_syscall(sys_vmevent_fd);
> +cond_syscall(sys_vmpressure_fd);
>  
>  /* performance counters: */
>  cond_syscall(sys_perf_event_open);
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 87174ef..7c9a3be 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -50,6 +50,7 @@
>  #include <linux/dnotify.h>
>  #include <linux/syscalls.h>
>  #include <linux/vmstat.h>
> +#include <linux/vmpressure.h>
>  #include <linux/nfs_fs.h>
>  #include <linux/acpi.h>
>  #include <linux/reboot.h>
> @@ -1317,6 +1318,36 @@ static struct ctl_table vm_table[] = {
>  		.proc_handler	= numa_zonelist_order_handler,
>  	},
>  #endif
> +#ifdef CONFIG_VMPRESSURE
> +	{
> +		.procname	= "vmpressure_window",
> +		.data		= &vmpressure_win,
> +		.maxlen		= sizeof(vmpressure_win),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
> +		.procname	= "vmpressure_level_medium",
> +		.data		= &vmpressure_level_med,
> +		.maxlen		= sizeof(vmpressure_level_med),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
> +		.procname	= "vmpressure_level_oom",
> +		.data		= &vmpressure_level_oom,
> +		.maxlen		= sizeof(vmpressure_level_oom),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
> +		.procname	= "vmpressure_level_oom_priority",
> +		.data		= &vmpressure_level_oom_prio,
> +		.maxlen		= sizeof(vmpressure_level_oom_prio),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +#endif

Talked about this and why I think they should be debugfs already.

>  #if (defined(CONFIG_X86_32) && !defined(CONFIG_UML))|| \
>     (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
>  	{
> diff --git a/mm/Kconfig b/mm/Kconfig
> index cd0ea24e..8a47a5f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -401,6 +401,19 @@ config VMEVENT
>  	help
>  	  If unsure, say N to disable vmevent
>  
> +config VMPRESSURE
> +	bool "Enable vmpressure_fd() notifications"
> +	help
> +	  This option enables vmpressure_fd() system call, it is used to
> +	  notify userland applications about system's virtual memory
> +	  pressure state.
> +
> +	  Upon these notifications, userland programs can cooperate with
> +	  the kernel (e.g. free easily reclaimable resources), and so
> +	  achieving better system's memory management.
> +
> +	  If unsure, say N.
> +

If anything I think this should be default Y. If Android benefits from
it, it's plausible that normal desktops might and failing that,
monitoring applications on server workloads will. With default N, it's
going to be missed by distributions.

I think making it configurable at all is overkill -- maybe the debugfs
parts but otherwise build it.

>  config FRONTSWAP
>  	bool "Enable frontswap to cache swap pages if tmem is present"
>  	depends on SWAP
> diff --git a/mm/Makefile b/mm/Makefile
> index 80debc7..2f08d14 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -57,4 +57,5 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
>  obj-$(CONFIG_VMEVENT) += vmevent.o
> +obj-$(CONFIG_VMPRESSURE) += vmpressure.o
>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> new file mode 100644
> index 0000000..54f35a3
> --- /dev/null
> +++ b/mm/vmpressure.c
> @@ -0,0 +1,231 @@
> +/*
> + * Linux VM pressure notifications
> + *
> + * Copyright 2011-2012 Pekka Enberg <penberg@kernel.org>
> + * Copyright 2011-2012 Linaro Ltd.
> + *		       Anton Vorontsov <anton.vorontsov@linaro.org>
> + *
> + * Based on ideas from KOSAKI Motohiro, Leonid Moiseichuk, Mel Gorman,
> + * Minchan Kim and Pekka Enberg.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published
> + * by the Free Software Foundation.
> + */
> +
> +#include <linux/anon_inodes.h>
> +#include <linux/atomic.h>
> +#include <linux/compiler.h>
> +#include <linux/vmpressure.h>
> +#include <linux/syscalls.h>
> +#include <linux/workqueue.h>
> +#include <linux/mutex.h>
> +#include <linux/file.h>
> +#include <linux/list.h>
> +#include <linux/poll.h>
> +#include <linux/slab.h>
> +#include <linux/swap.h>
> +
> +struct vmpressure_watch {
> +	struct vmpressure_config config;
> +	atomic_t pending;
> +	wait_queue_head_t waitq;
> +	struct list_head node;
> +};
> +
> +static atomic64_t vmpressure_sr;
> +static uint vmpressure_val;
> +
> +static LIST_HEAD(vmpressure_watchers);
> +static DEFINE_MUTEX(vmpressure_watchers_lock);
> +

Superficially, this looks like a custom implementation of a chain notifier
(include/linux/notifier.h). It's not something the VM makes much use of
other than the OOM killer but it's there.

> +/* Our sysctl tunables, see Documentation/sysctl/vm.txt */
> +uint __read_mostly vmpressure_win = SWAP_CLUSTER_MAX * 16;
> +uint vmpressure_level_med = 60;
> +uint vmpressure_level_oom = 99;
> +uint vmpressure_level_oom_prio = 4;
> +
> +/*
> + * This function is called from a workqueue, which can have only one
> + * execution thread, so we don't need to worry about racing w/ ourselves.
> + * And so it possible to implement the lock-free logic, using just the
> + * atomic watch->pending variable.
> + */
> +static void vmpressure_sample(struct vmpressure_watch *watch)
> +{
> +	if (atomic_read(&watch->pending))
> +		return;
> +	if (vmpressure_val < watch->config.threshold)
> +		return;
> +
> +	atomic_set(&watch->pending, 1);
> +	wake_up(&watch->waitq);
> +}
> +
> +static u64 vmpressure_level(uint pressure)
> +{
> +	if (pressure >= vmpressure_level_oom)
> +		return VMPRESSURE_OOM;
> +	else if (pressure >= vmpressure_level_med)
> +		return VMPRESSURE_MEDIUM;
> +	return VMPRESSURE_LOW;
> +}
> +
> +static uint vmpressure_calc_pressure(uint win, uint s, uint r)
> +{
> +	ulong p;
> +
> +	/*
> +	 * We calculate the ratio (in percents) of how many pages were
> +	 * scanned vs. reclaimed in a given time frame (window). Note that
> +	 * time is in VM reclaimer's "ticks", i.e. number of pages
> +	 * scanned. This makes it possible set desired reaction time and
> +	 * serves as a ratelimit.
> +	 */
> +	p = win - (r * win / s);
> +	p = p * 100 / win;
> +
> +	pr_debug("%s: %3lu  (s: %6u  r: %6u)\n", __func__, p, s, r);
> +
> +	return vmpressure_level(p);
> +}
> +

Ok!

> +#define VMPRESSURE_SCANNED_SHIFT (sizeof(u64) * 8 / 2)
> +
> +static void vmpressure_wk_fn(struct work_struct *wk)
> +{
> +	struct vmpressure_watch *watch;
> +	u64 sr = atomic64_xchg(&vmpressure_sr, 0);
> +	u32 s = sr >> VMPRESSURE_SCANNED_SHIFT;
> +	u32 r = sr & (((u64)1 << VMPRESSURE_SCANNED_SHIFT) - 1);
> +
> +	vmpressure_val = vmpressure_calc_pressure(vmpressure_win, s, r);
> +
> +	mutex_lock(&vmpressure_watchers_lock);
> +	list_for_each_entry(watch, &vmpressure_watchers, node)
> +		vmpressure_sample(watch);
> +	mutex_unlock(&vmpressure_watchers_lock);
> +}

So, if you used notifiers I think this would turn into a
blocking_notifier_call_chain() probably. Maybe
atomic_notifier_call_chain() depending.

> +static DECLARE_WORK(vmpressure_wk, vmpressure_wk_fn);
> +
> +void __vmpressure(struct mem_cgroup *memcg, ulong scanned, ulong reclaimed)
> +{
> +	/*
> +	 * Store s/r combined, so we don't have to worry to synchronize
> +	 * them. On modern machines it will be truly atomic; on arches w/o
> +	 * 64 bit atomics it will turn into a spinlock (for a small amount
> +	 * of CPUs it's not a problem).
> +	 *
> +	 * Using int-sized atomics is a bad idea as it would only allow to
> +	 * count (1 << 16) - 1 pages (256MB), which we can scan pretty
> +	 * fast.
> +	 *
> +	 * We can't have per-CPU counters as this will not catch a case
> +	 * when many CPUs scan small amounts (so none of them hit the
> +	 * window size limit, and thus we won't send a notification in
> +	 * time).
> +	 *
> +	 * So we shouldn't place vmpressure() into a very hot path.
> +	 */
> +	atomic64_add(scanned << VMPRESSURE_SCANNED_SHIFT | reclaimed,
> +		     &vmpressure_sr);
> +
> +	scanned = atomic64_read(&vmpressure_sr) >> VMPRESSURE_SCANNED_SHIFT;
> +	if (scanned >= vmpressure_win && !work_pending(&vmpressure_wk))
> +		schedule_work(&vmpressure_wk);
> +}

So after all this, I'm ok with the actual calculation of pressure part
and when userspace gets woken up. I'm *WAY* happier with this than I was
with notifiers based on free memory so for *just* that part

Acked-by: Mel Gorman <mgorman@suse.de>

I'm less keen on the actual interface and have explained why but it's up
to other people to say whether they feel the same way. If Pekka and the
Android people are ok with the interface then I won't object. However,
if eventfd cannot be used and a system call really is required then it
should be explained *very* carefully in the changelog or it'll just get
snagged by another reviewer.

> +
> +static uint vmpressure_poll(struct file *file, poll_table *wait)
> +{
> +	struct vmpressure_watch *watch = file->private_data;
> +
> +	poll_wait(file, &watch->waitq, wait);
> +
> +	return atomic_read(&watch->pending) ? POLLIN : 0;
> +}
> +
> +static ssize_t vmpressure_read(struct file *file, char __user *buf,
> +			       size_t count, loff_t *ppos)
> +{
> +	struct vmpressure_watch *watch = file->private_data;
> +	struct vmpressure_event event;
> +	int ret;
> +
> +	if (count < sizeof(event))
> +		return -EINVAL;
> +
> +	ret = wait_event_interruptible(watch->waitq,
> +				       atomic_read(&watch->pending));
> +	if (ret)
> +		return ret;
> +
> +	event.pressure = vmpressure_val;
> +	if (copy_to_user(buf, &event, sizeof(event)))
> +		return -EFAULT;
> +
> +	atomic_set(&watch->pending, 0);
> +
> +	return count;
> +}
> +
> +static int vmpressure_release(struct inode *inode, struct file *file)
> +{
> +	struct vmpressure_watch *watch = file->private_data;
> +
> +	mutex_lock(&vmpressure_watchers_lock);
> +	list_del(&watch->node);
> +	mutex_unlock(&vmpressure_watchers_lock);
> +
> +	kfree(watch);
> +	return 0;
> +}
> +
> +static const struct file_operations vmpressure_fops = {
> +	.poll		= vmpressure_poll,
> +	.read		= vmpressure_read,
> +	.release	= vmpressure_release,
> +};
> +
> +SYSCALL_DEFINE1(vmpressure_fd, struct vmpressure_config __user *, config)
> +{
> +	struct vmpressure_watch *watch;
> +	struct file *file;
> +	int ret;
> +	int fd;
> +
> +	watch = kzalloc(sizeof(*watch), GFP_KERNEL);
> +	if (!watch)
> +		return -ENOMEM;
> +
> +	ret = copy_from_user(&watch->config, config, sizeof(*config));
> +	if (ret)
> +		goto err_free;
> +
> +	fd = get_unused_fd_flags(O_RDONLY);
> +	if (fd < 0) {
> +		ret = fd;
> +		goto err_free;
> +	}
> +
> +	file = anon_inode_getfile("[vmpressure]", &vmpressure_fops, watch,
> +				  O_RDONLY);
> +	if (IS_ERR(file)) {
> +		ret = PTR_ERR(file);
> +		goto err_fd;
> +	}
> +
> +	fd_install(fd, file);
> +
> +	init_waitqueue_head(&watch->waitq);
> +
> +	mutex_lock(&vmpressure_watchers_lock);
> +	list_add(&watch->node, &vmpressure_watchers);
> +	mutex_unlock(&vmpressure_watchers_lock);
> +
> +	return fd;
> +err_fd:
> +	put_unused_fd(fd);
> +err_free:
> +	kfree(watch);
> +	return ret;
> +}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 99b434b..5439117 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -20,6 +20,7 @@
>  #include <linux/init.h>
>  #include <linux/highmem.h>
>  #include <linux/vmstat.h>
> +#include <linux/vmpressure.h>
>  #include <linux/file.h>
>  #include <linux/writeback.h>
>  #include <linux/blkdev.h>
> @@ -1846,6 +1847,9 @@ restart:
>  		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>  				   sc, LRU_ACTIVE_ANON);
>  
> +	vmpressure(sc->target_mem_cgroup,
> +		   sc->nr_scanned - nr_scanned, nr_reclaimed);
> +
>  	/* reclaim/compaction might need reclaim to continue */
>  	if (should_continue_reclaim(lruvec, nr_reclaimed,
>  				    sc->nr_scanned - nr_scanned, sc))
> @@ -2068,6 +2072,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		count_vm_event(ALLOCSTALL);
>  
>  	do {
> +		vmpressure_prio(sc->target_mem_cgroup, sc->priority);
>  		sc->nr_scanned = 0;
>  		aborted_reclaim = shrink_zones(zonelist, sc);
>  
> -- 
> 1.8.0
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
