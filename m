Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 5082D6B004F
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 14:56:26 -0500 (EST)
Date: Wed, 4 Jan 2012 11:55:21 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
Message-ID: <20120104195521.GA19181@suse.de>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Wed, Jan 04, 2012 at 07:21:56PM +0200, Leonid Moiseichuk wrote:
> The Used Memory Meter (UMM) device tracks level of memory utilization
> and notifies subscribed processes when consumption crossed specified
> threshold up or down. It could be used on embedded devices to
> implementation of performance-cheap memory reacting by using
> e.g. libmemnotify or similar user-space component.
> 
> Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

Note, I don't agree that this code is the correct thing to be doing
here, you'll have to get the buy-in from the mm developers on that, but
I do have some comments on the implementation:

> --- /dev/null
> +++ b/drivers/misc/umm.c
> @@ -0,0 +1,452 @@
> +/*
> + * umm.c - system-wide Used Memory Meter pseudo-device implementation
> + *
> + * Copyright (C) 2011 Nokia Corporation.
> + *      Leonid Moiseichuk
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any
> + * kind, whether express or implied; without even the implied warranty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/module.h>
> +#include <linux/device.h>
> +#include <linux/kernel.h>
> +#include <linux/atomic.h>
> +#include <linux/jiffies.h>
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <linux/poll.h>
> +#include <linux/highmem.h>
> +#include <linux/swap.h>
> +#include <linux/list.h>
> +#include <linux/wait.h>
> +#include <linux/spinlock.h>
> +#include <linux/spinlock_types.h>
> +
> +#include <linux/umm.h>

Why do you need a header file at all?

> +/* subscriber information to be notified when level changed */
> +struct observer {
> +	/* list data to check from notify_memory_usage and wakeup user-space */
> +	struct list_head list;
> +	/* related file structure for open/close/read/write and poll */
> +	struct file	*file;
> +	/* threshold [pages] when we should trigger notification */
> +	unsigned long	threshold;
> +	/* did we crossed theshold on last validation? */
> +	bool		active;
> +	/* flag about new notification is required */
> +	bool		updated;
> +};
> +
> +
> +
> +MODULE_AUTHOR("Leonid Moiseichuk (leonid.moiseichuk@nokia.com)");
> +MODULE_DESCRIPTION("System used memory meter pseudo-device");
> +MODULE_LICENSE("GPL v2");
> +MODULE_VERSION("0.0.2");
> +
> +static int debug __read_mostly;
> +module_param(debug, bool, 0);
> +MODULE_PARM_DESC(debug, "More info about module parameters and operations");
> +
> +static int probe __read_mostly;
> +module_param(probe, bool, 0);
> +MODULE_PARM_DESC(probe, "Probe measurement overhead during loading");
> +
> +static char device_name[64] __read_mostly = UMM_DEVICE_NAME;
> +module_param_string(device_name, device_name, sizeof(device_name), 0);
> +MODULE_PARM_DESC(device_name, "Device name in /dev if need different");

This is pointless, right?

> +static struct device *umm_device __read_mostly;

Enough with the __read_mostly markings, they really aren't needed for
every single variable, right?  Especially for trivial stuff like this
one, and all of the module parameters.

> +static struct class  *umm_class  __read_mostly;

Just use a misc device, as you are only creating/needing one character
device, right?  That will make your init and destroy code a lot cleaner
and smaller.

> +	pr_info("UMM: Used Memory Meter loading to support /dev/%s\n",
> +							device_name);

Not needed.

> +
> +	umm_major = register_chrdev(0, device_name, &umm_fops);
> +	if (umm_major < 0) {
> +		pr_err("UMM: unable to get major number for device %s\n",
> +							device_name);
> +		error = -EBUSY;
> +		goto register_failed;
> +	}
> +
> +	umm_class = class_create(THIS_MODULE, device_name);
> +	if (IS_ERR(umm_class)) {
> +		error = PTR_ERR(umm_class);
> +		pr_err("UMM: unable to create class for device %s - %d\n",
> +						device_name, error);
> +		goto class_failed;
> +	}
> +
> +	umm_device = device_create(
> +			umm_class, NULL,
> +			MKDEV(umm_major, 0),
> +			NULL, device_name);
> +	if (IS_ERR(umm_device)) {
> +		error = PTR_ERR(umm_device);
> +		pr_err("UMM: unable to create device %s - %d\n",
> +						device_name, error);
> +		goto device_failed;
> +	}
> +
> +	update_period_jiffies = msecs_to_jiffies(update_period);
> +	if (!update_period_jiffies)
> +		update_period_jiffies = msecs_to_jiffies(UMM_UPDATE_PERIOD);
> +
> +	/* query amount of available ram and swap, mem_unit is PAGE_SIZE */
> +	si_meminfo(&si);
> +#ifdef CONFIG_SWAP
> +	si_swapinfo(&si);
> +	available_pages = si.totalram + si.totalswap;
> +	available_swap_pages = si.totalswap;
> +#else
> +	available_pages = si.totalram;
> +#endif
> +	/* if autodetect then set granularity to ~1.4% from available memory */
> +	if (update_space)
> +		update_space_pages = update_space >> (PAGE_SHIFT - 10);
> +	else
> +		update_space_pages = available_pages >> 6;
> +	if (!update_space_pages)
> +		update_space_pages = UMM_UPDATE_SPACE >> (PAGE_SHIFT - 10);
> +
> +	update_memory_usage();
> +	old_mm_hook = set_mm_alloc_free_hook(mm_alloc_free_hook);
> +
> +	if (debug) {
> +		pr_info("UMM: /dev/%s got major %d\n", device_name, umm_major);
> +		pr_info("UMM: update period set to %u ms or %lu jiffies\n",
> +					update_period, update_period_jiffies);
> +		pr_info("UMM: update space set to %u kb or %u pages\n",
> +					update_space, update_space_pages);
> +		pr_info("UMM: old mm alloc/free hook is 0x%p\n", old_mm_hook);
> +		pr_info("UMM: now hook set to 0x%p\n", mm_alloc_free_hook);
> +#ifdef CONFIG_SWAP
> +		pr_info("UMM: %lu available pages found (only ram)\n",
> +							available_pages);
> +#else
> +		pr_info("UMM: %lu available pages found (%lu ram + %lu swap)\n",
> +				available_pages, si.totalram, si.totalswap);
> +#endif
> +		pr_info("UMM: %lu used pages, utilization %lu percents\n",
> +					atomic_long_read(&last_used_pages),
> +			(100 * atomic_long_read(&last_used_pages)) /
> +							available_pages);
> +		pr_info("UMM: overhead per client connection is %lu bytes\n",
> +						sizeof(struct observer));

Please use the dev_dbg() macro instead, that removes the debug flag
here, and properly identifies your code/device in the kernel log.  Same
goes for other pr_* usages in the file, just use the appropriate dev_*
call instead.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
