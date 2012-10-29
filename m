Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 999496B006E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:41:04 -0400 (EDT)
Date: Mon, 29 Oct 2012 11:41:03 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
In-Reply-To: <1351513440-9286-3-git-send-email-ming.lei@canonical.com>
Message-ID: <Pine.LNX.4.44L0.1210291125590.22882-100000@netrider.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Mon, 29 Oct 2012, Ming Lei wrote:

> The patch introduces the flag of memalloc_noio_resume in
> 'struct dev_pm_info' to help PM core to teach mm not allocating
> memory with GFP_KERNEL flag for avoiding probable deadlock
> problem.
> 
> As explained in the comment, any GFP_KERNEL allocation inside
> runtime_resume on any one of device in the path from one block
> or network device to the root device in the device tree may cause
> deadlock, the introduced pm_runtime_set_memalloc_noio() sets or
> clears the flag on device of the path recursively.
> 
> This patch also introduces pm_runtime_get_memalloc_noio() because
> the flag may be accessed in block device's error handling path
> (for example, usb device reset)

> +/*
> + * pm_runtime_get_memalloc_noio - Get a device's memalloc_noio flag.
> + * @dev: Device to handle.
> + *
> + * Return the device's memalloc_noio flag.
> + *
> + * The device power lock is held because bitfield is not SMP-safe.
> + */
> +bool pm_runtime_get_memalloc_noio(struct device *dev)
> +{
> +	bool ret;
> +	spin_lock_irq(&dev->power.lock);
> +	ret = dev->power.memalloc_noio_resume;
> +	spin_unlock_irq(&dev->power.lock);
> +	return ret;
> +}

You don't need to acquire and release a spinlock just to read the
value.  Reading bitfields _is_ SMP-safe; writing them is not.

> +/*
> + * pm_runtime_set_memalloc_noio - Set a device's memalloc_noio flag.
> + * @dev: Device to handle.
> + * @enable: True for setting the flag and False for clearing the flag.
> + *
> + * Set the flag for all devices in the path from the device to the
> + * root device in the device tree if @enable is true, otherwise clear
> + * the flag for devices in the path which sibliings don't set the flag.

s/which/whose/
s/ii/i

> + *
> + * The function should only be called by block device, or network
> + * device driver for solving the deadlock problem during runtime
> + * resume:
> + * 	if memory allocation with GFP_KERNEL is called inside runtime
> + * 	resume callback of any one of its ancestors(or the block device
> + * 	itself), the deadlock may be triggered inside the memory
> + * 	allocation since it might not complete until the block device
> + * 	becomes active and the involed page I/O finishes. The situation
> + * 	is pointed out first by Alan Stern. Network device are involved
> + * 	in iSCSI kind of situation.
> + *
> + * The lock of dev_hotplug_mutex is held in the function for handling
> + * hotplug race because pm_runtime_set_memalloc_noio() may be called
> + * in async probe().
> + */
> +void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
> +{
> +	static DEFINE_MUTEX(dev_hotplug_mutex);
> +
> +	mutex_lock(&dev_hotplug_mutex);
> +	while (dev) {

Unless you think somebody is likely to call this function with dev 
equal to NULL, this can simply be

	for (;;) {

> +		/* hold power lock since bitfield is not SMP-safe. */
> +		spin_lock_irq(&dev->power.lock);
> +		dev->power.memalloc_noio_resume = enable;
> +		spin_unlock_irq(&dev->power.lock);
> +
> +		dev = dev->parent;
> +
> +		/* only clear the flag for one device if all
> +		 * children of the device don't set the flag.
> +		 */
> +		if (!dev || (!enable &&

... thanks to this test.

> +			     device_for_each_child(dev, NULL,
> +						   dev_memalloc_noio)))
> +			break;
> +	}
> +	mutex_unlock(&dev_hotplug_mutex);
> +}

This might not work if somebody calls pm_runtime_set_memalloc_noio(dev,
true) and then afterwards registers dev at the same time as someone
else calls pm_runtime_set_memalloc_noio(dev2, false), if dev and dev2
have the same parent.

Perhaps the kerneldoc should mention that this function must not be 
called until after dev is registered.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
