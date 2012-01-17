Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 127526B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 18:20:36 -0500 (EST)
Received: by vcbfl11 with SMTP id fl11so832301vcb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 15:20:35 -0800 (PST)
Date: Wed, 18 Jan 2012 08:20:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
Message-ID: <20120117232025.GB903@barrios-desktop.redhat.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
 <1326788038-29141-2-git-send-email-minchan@kernel.org>
 <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
 <4F15A34F.40808@redhat.com>
 <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Jan 17, 2012 at 08:51:13PM +0200, Pekka Enberg wrote:
> Hello,
> 
> Ok, so here's a proof of concept patch that implements sample-base
> per-process free threshold VM event watching using perf-like syscall
> ABI. I'd really like to see something like this that's much more
> extensible and clean than the /dev based ABIs that people have
> proposed so far.
> 
> 			Pekka
> 
> ------------------->
> 
> From a07f93fdca360b20daef4a5d66f2a5746f31f6a6 Mon Sep 17 00:00:00 2001
> From: Pekka Enberg <penberg@kernel.org>
> Date: Tue, 17 Jan 2012 17:51:48 +0200
> Subject: [PATCH] vmnotify: VM event notification system
> 
> This patch implements a new sys_vmnotify_fd() system call that returns a
> pollable file descriptor that can be used to watch VM events.
> 
> For example, to watch for VM event when free memory is below 99% of available
> memory using 1 second sample period, you'd do something like this:
> 
>     struct vmnotify_config config;
>     struct vmnotify_event event;
>     struct pollfd pollfd;
>     int fd;
> 
>     config = (struct vmnotify_config) {
>             .type                   = VMNOTIFY_TYPE_SAMPLE|VMNOTIFY_TYPE_FREE_THRESHOLD,
>             .sample_period_ns       = 1000000000L,
>             .free_threshold         = 99,
>     };
> 
>     fd = sys_vmnotify_fd(&config);
> 
>     pollfd.fd               = fd;
>     pollfd.events           = POLLIN;
> 
>     if (poll(&pollfd, 1, -1) < 0) {
>             perror("poll failed");
>             exit(1);
>     }
> 
>     memset(&event, 0, sizeof(event));
> 
>     if (read(fd, &event, sizeof(event)) < 0) {
>             perror("read failed");
>             exit(1);
>     }

Hi Pekka,

I didn't look into your code(will do) but as I read description,
still I don't convince we need really some process specific threshold like 99%
I think application can know it by polling /proc/meminfo without this mechanism
if they really want.

I would like to notify when system has a trobule with memory pressure without
some process specific threshold. Of course, applicatoin can't expect it.(ie,
application can know system memory pressure by /proc/meminfo but it can't know
when swapout really happens). Kernel low mem notify have to give such notification
to user space, I think.

> 
> Signed-off-by: Pekka Enberg <penberg@kernel.org>
> ---
>  arch/x86/include/asm/unistd_64.h       |    2 +
>  include/linux/vmnotify.h               |   44 ++++++
>  mm/Kconfig                             |    6 +
>  mm/Makefile                            |    1 +
>  mm/vmnotify.c                          |  235 ++++++++++++++++++++++++++++++++
>  tools/testing/vmnotify/vmnotify-test.c |   68 +++++++++
>  6 files changed, 356 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/vmnotify.h
>  create mode 100644 mm/vmnotify.c
>  create mode 100644 tools/testing/vmnotify/vmnotify-test.c
> 
> diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
> index 0431f19..b0928cd 100644
> --- a/arch/x86/include/asm/unistd_64.h
> +++ b/arch/x86/include/asm/unistd_64.h
> @@ -686,6 +686,8 @@ __SYSCALL(__NR_getcpu, sys_getcpu)
>  __SYSCALL(__NR_process_vm_readv, sys_process_vm_readv)
>  #define __NR_process_vm_writev			311
>  __SYSCALL(__NR_process_vm_writev, sys_process_vm_writev)
> +#define __NR_vmnotify_fd			312
> +__SYSCALL(__NR_vmnotify_fd, sys_vmnotify_fd)
> 
>  #ifndef __NO_STUBS
>  #define __ARCH_WANT_OLD_READDIR
> diff --git a/include/linux/vmnotify.h b/include/linux/vmnotify.h
> new file mode 100644
> index 0000000..8f8642b
> --- /dev/null
> +++ b/include/linux/vmnotify.h
> @@ -0,0 +1,44 @@
> +#ifndef _LINUX_VMNOTIFY_H
> +#define _LINUX_VMNOTIFY_H
> +
> +#include <linux/types.h>
> +
> +enum {
> +	VMNOTIFY_TYPE_FREE_THRESHOLD	= 1ULL << 0,
> +	VMNOTIFY_TYPE_SAMPLE		= 1ULL << 1,
> +};
> +
> +struct vmnotify_config {
> +	/*
> +	 * Size of the struct for ABI extensibility.
> +	 */
> +	__u32		   size;
> +
> +	/*
> +	 * Notification type bitmask
> +	 */
> +	__u64			type;
> +
> +	/*
> +	 * Free memory threshold in percentages [1..99]
> +	 */
> +	__u32			free_threshold;
> +
> +	/*
> +	 * Sample period in nanoseconds
> +	 */
> +	__u64			sample_period_ns;
> +};
> +
> +struct vmnotify_event {
> +	/* Size of the struct for ABI extensibility. */
> +	__u32			size;
> +
> +	__u64			nr_avail_pages;
> +
> +	__u64			nr_swap_pages;
> +
> +	__u64			nr_free_pages;
> +};
> +
> +#endif /* _LINUX_VMNOTIFY_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 011b110..6631167 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -373,3 +373,9 @@ config CLEANCACHE
>  	  in a negligible performance hit.
> 
>  	  If unsure, say Y to enable cleancache
> +
> +config VMNOTIFY
> +	bool "Enable VM event notification system"
> +	default n
> +	help
> +	  If unsure, say N to disable vmnotify
> diff --git a/mm/Makefile b/mm/Makefile
> index 50ec00e..e1b5db3 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -51,3 +51,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
> +obj-$(CONFIG_VMNOTIFY) += vmnotify.o
> diff --git a/mm/vmnotify.c b/mm/vmnotify.c
> new file mode 100644
> index 0000000..6800450
> --- /dev/null
> +++ b/mm/vmnotify.c
> @@ -0,0 +1,235 @@
> +#include <linux/anon_inodes.h>
> +#include <linux/vmnotify.h>
> +#include <linux/syscalls.h>
> +#include <linux/file.h>
> +#include <linux/list.h>
> +#include <linux/poll.h>
> +#include <linux/slab.h>
> +#include <linux/swap.h>
> +
> +#define VMNOTIFY_MAX_FREE_THRESHOD	100
> +
> +struct vmnotify_watch {
> +	struct vmnotify_config		config;
> +
> +	struct mutex			mutex;
> +	bool				pending;
> +	struct vmnotify_event		event;
> +
> +	/* sampling */
> +	struct hrtimer			timer;
> +
> +	/* poll */
> +	wait_queue_head_t		waitq;
> +};
> +
> +static bool vmnotify_match(struct vmnotify_watch *watch, struct vmnotify_event *event)
> +{
> +	if (watch->config.type & VMNOTIFY_TYPE_FREE_THRESHOLD) {
> +		u64 threshold;
> +
> +		if (!event->nr_avail_pages)
> +			return false;
> +
> +		threshold = event->nr_free_pages * 100 / event->nr_avail_pages;
> +		if (threshold > watch->config.free_threshold)
> +			return false;
> +	}
> +
> +	return true;
> +}
> +
> +static void vmnotify_sample(struct vmnotify_watch *watch)
> +{
> +	struct vmnotify_event event;
> +	struct sysinfo si;
> +
> +	memset(&event, 0, sizeof(event));
> +
> +	event.size		= sizeof(event);
> +	event.nr_free_pages	= global_page_state(NR_FREE_PAGES);
> +
> +	si_meminfo(&si);
> +	event.nr_avail_pages	= si.totalram;
> +
> +#ifdef CONFIG_SWAP
> +	si_swapinfo(&si);
> +	event.nr_swap_pages	= si.totalswap;
> +#endif
> +
> +	if (!vmnotify_match(watch, &event))
> +		return;
> +
> +	mutex_lock(&watch->mutex);
> +
> +	watch->pending = true;
> +
> +	memcpy(&watch->event, &event, sizeof(event));
> +
> +	mutex_unlock(&watch->mutex);
> +}
> +
> +static enum hrtimer_restart vmnotify_timer_fn(struct hrtimer *hrtimer)
> +{
> +	struct vmnotify_watch *watch = container_of(hrtimer, struct vmnotify_watch, timer);
> +	u64 sample_period = watch->config.sample_period_ns;
> +
> +	vmnotify_sample(watch);
> +
> +	hrtimer_forward_now(hrtimer, ns_to_ktime(sample_period));
> +
> +	wake_up(&watch->waitq);
> +
> +	return HRTIMER_RESTART;
> +}
> +
> +static void vmnotify_start_timer(struct vmnotify_watch *watch)
> +{
> +	u64 sample_period = watch->config.sample_period_ns;
> +
> +	hrtimer_init(&watch->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
> +	watch->timer.function = vmnotify_timer_fn;
> +
> +	hrtimer_start(&watch->timer, ns_to_ktime(sample_period), HRTIMER_MODE_REL_PINNED);
> +}
> +
> +static unsigned int vmnotify_poll(struct file *file, poll_table *wait)
> +{
> +	struct vmnotify_watch *watch = file->private_data;
> +	unsigned int events = 0;
> +
> +	poll_wait(file, &watch->waitq, wait);
> +
> +	mutex_lock(&watch->mutex);
> +
> +	if (watch->pending)
> +		events |= POLLIN;
> +
> +	mutex_unlock(&watch->mutex);
> +
> +	return events;
> +}
> +
> +static ssize_t vmnotify_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
> +{
> +	struct vmnotify_watch *watch = file->private_data;
> +	int ret = 0;
> +
> +	mutex_lock(&watch->mutex);
> +
> +	if (!watch->pending)
> +		goto out_unlock;
> +
> +	if (copy_to_user(buf, &watch->event, sizeof(struct vmnotify_event))) {
> +		ret = -EFAULT;
> +		goto out_unlock;
> +	}
> +
> +	ret = watch->event.size;
> +
> +	watch->pending = false;
> +
> +out_unlock:
> +	mutex_unlock(&watch->mutex);
> +
> +	return ret;
> +}
> +
> +static int vmnotify_release(struct inode *inode, struct file *file)
> +{
> +	struct vmnotify_watch *watch = file->private_data;
> +
> +	hrtimer_cancel(&watch->timer);
> +
> +	kfree(watch);
> +
> +	return 0;
> +}
> +
> +static const struct file_operations vmnotify_fops = {
> +	.poll		= vmnotify_poll,
> +	.read		= vmnotify_read,
> +	.release	= vmnotify_release,
> +};
> +
> +static struct vmnotify_watch *vmnotify_watch_alloc(void)
> +{
> +	struct vmnotify_watch *watch;
> +
> +	watch = kzalloc(sizeof *watch, GFP_KERNEL);
> +	if (!watch)
> +		return NULL;
> +
> +	mutex_init(&watch->mutex);
> +
> +	init_waitqueue_head(&watch->waitq);
> +
> +	return watch;
> +}
> +
> +static int vmnotify_copy_config(struct vmnotify_config __user *uconfig,
> +				struct vmnotify_config *config)
> +{
> +	int ret;
> +
> +	ret = copy_from_user(config, uconfig, sizeof(struct vmnotify_config));
> +	if (ret)
> +		return -EFAULT;
> +
> +	if (!config->type)
> +		return -EINVAL;
> +
> +	if (config->type & VMNOTIFY_TYPE_SAMPLE) {
> +		if (config->sample_period_ns < NSEC_PER_MSEC)
> +			return -EINVAL;
> +	}
> +
> +	if (config->type & VMNOTIFY_TYPE_FREE_THRESHOLD) {
> +		if (config->free_threshold > VMNOTIFY_MAX_FREE_THRESHOD)
> +			return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +SYSCALL_DEFINE1(vmnotify_fd,
> +		struct vmnotify_config __user *, uconfig)
> +{
> +	struct vmnotify_watch *watch;
> +	struct file *file;
> +	int err;
> +	int fd;
> +
> +	watch = vmnotify_watch_alloc();
> +	if (!watch)
> +		return -ENOMEM;
> +
> +	err = vmnotify_copy_config(uconfig, &watch->config);
> +	if (err)
> +		goto err_free;
> +
> +	fd = get_unused_fd_flags(O_RDONLY);
> +	if (fd < 0) {
> +		err = fd;
> +		goto err_free;
> +	}
> +
> +	file = anon_inode_getfile("[vmnotify]", &vmnotify_fops, watch, O_RDONLY);
> +	if (IS_ERR(file)) {
> +		err = PTR_ERR(file);
> +		goto err_fd;
> +	}
> +
> +	fd_install(fd, file);
> +
> +	if (watch->config.type & VMNOTIFY_TYPE_SAMPLE)
> +		vmnotify_start_timer(watch);
> +
> +	return fd;
> +
> +err_fd:
> +	put_unused_fd(fd);
> +err_free:
> +	kfree(watch);
> +	return err;
> +}
> diff --git a/tools/testing/vmnotify/vmnotify-test.c b/tools/testing/vmnotify/vmnotify-test.c
> new file mode 100644
> index 0000000..3c6b26d
> --- /dev/null
> +++ b/tools/testing/vmnotify/vmnotify-test.c
> @@ -0,0 +1,68 @@
> +#include "../../../include/linux/vmnotify.h"
> +
> +#if defined(__x86_64__)
> +#include "../../../arch/x86/include/asm/unistd.h"
> +#endif
> +
> +#include <stdlib.h>
> +#include <string.h>
> +#include <errno.h>
> +#include <stdio.h>
> +#include <poll.h>
> +
> +static int sys_vmnotify_fd(struct vmnotify_config *config)
> +{
> +	config->size = sizeof(*config);
> +
> +	return syscall(__NR_vmnotify_fd, config);
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +	struct vmnotify_config config;
> +	struct vmnotify_event event;
> +	struct pollfd pollfd;
> +	int i;
> +	int fd;
> +
> +	config = (struct vmnotify_config) {
> +		.type			= VMNOTIFY_TYPE_SAMPLE|VMNOTIFY_TYPE_FREE_THRESHOLD,
> +		.sample_period_ns	= 1000000000L,
> +		.free_threshold		= 99,
> +	};
> +
> +	fd = sys_vmnotify_fd(&config);
> +	if (fd < 0) {
> +		perror("vmnotify_fd failed");
> +		exit(1);
> +	}
> +
> +	for (i = 0; i < 10; i++) {
> +		pollfd.fd		= fd;
> +		pollfd.events		= POLLIN;
> +
> +		if (poll(&pollfd, 1, -1) < 0) {
> +			perror("poll failed");
> +			exit(1);
> +		}
> +
> +		memset(&event, 0, sizeof(event));
> +
> +		if (read(fd, &event, sizeof(event)) < 0) {
> +			perror("read failed");
> +			exit(1);
> +		}
> +
> +		printf("VM event:\n");
> +		printf("\tsize=%lu\n", event.size);
> +		printf("\tnr_avail_pages=%Lu\n", event.nr_avail_pages);
> +		printf("\tnr_swap_pages=%Lu\n", event.nr_swap_pages);
> +		printf("\tnr_free_pages=%Lu\n", event.nr_free_pages);
> +	}
> +	if (close(fd) < 0) {
> +		perror("close failed");
> +		exit(1);
> +	}
> +
> +	return 0;
> +}
> -- 
> 1.7.6.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
