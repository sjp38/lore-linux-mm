Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id A45BD6B004D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 18:24:20 -0500 (EST)
Date: Tue, 6 Nov 2012 15:24:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/6] PM / Runtime: introduce
 pm_runtime_set_memalloc_noio()
Message-Id: <20121106152419.9155a366.akpm@linux-foundation.org>
In-Reply-To: <1351931714-11689-3-git-send-email-ming.lei@canonical.com>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<1351931714-11689-3-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Sat,  3 Nov 2012 16:35:10 +0800
Ming Lei <ming.lei@canonical.com> wrote:

> The patch introduces the flag of memalloc_noio in 'struct dev_pm_info'
> to help PM core to teach mm not allocating memory with GFP_KERNEL
> flag for avoiding probable deadlock.
> 
> As explained in the comment, any GFP_KERNEL allocation inside
> runtime_resume() or runtime_suspend() on any one of device in
> the path from one block or network device to the root device
> in the device tree may cause deadlock, the introduced
> pm_runtime_set_memalloc_noio() sets or clears the flag on
> device in the path recursively.
> 

checkpatch finds a number of problems with this patch, all of which
should be fixed.  Please always use checkpatch.

> index 3148b10..d477924 100644
> --- a/drivers/base/power/runtime.c
> +++ b/drivers/base/power/runtime.c
> @@ -124,6 +124,63 @@ unsigned long pm_runtime_autosuspend_expiration(struct device *dev)
>  }
>  EXPORT_SYMBOL_GPL(pm_runtime_autosuspend_expiration);
>  
> +static int dev_memalloc_noio(struct device *dev, void *data)
> +{
> +	return dev->power.memalloc_noio;
> +}
> +
> +/*
> + * pm_runtime_set_memalloc_noio - Set a device's memalloc_noio flag.
> + * @dev: Device to handle.
> + * @enable: True for setting the flag and False for clearing the flag.
> + *
> + * Set the flag for all devices in the path from the device to the
> + * root device in the device tree if @enable is true, otherwise clear
> + * the flag for devices in the path whose siblings don't set the flag.
> + *
> + * The function should only be called by block device, or network
> + * device driver for solving the deadlock problem during runtime
> + * resume/suspend:
> + * 	if memory allocation with GFP_KERNEL is called inside runtime
> + * 	resume/suspend callback of any one of its ancestors(or the
> + * 	block device itself), the deadlock may be triggered inside the
> + * 	memory allocation since it might not complete until the block
> + * 	device becomes active and the involed page I/O finishes. The
> + * 	situation is pointed out first by Alan Stern. Network device
> + * 	are involved in iSCSI kind of situation.
> + *
> + * The lock of dev_hotplug_mutex is held in the function for handling
> + * hotplug race because pm_runtime_set_memalloc_noio() may be called
> + * in async probe().
> + *
> + * The function should be called between device_add() and device_del()
> + * on the affected device(block/network device).
> + */
> +void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
> +{
> +	static DEFINE_MUTEX(dev_hotplug_mutex);
> +
> +	mutex_lock(&dev_hotplug_mutex);
> +	for(;;) {
> +		/* hold power lock since bitfield is not SMP-safe. */
> +		spin_lock_irq(&dev->power.lock);
> +		dev->power.memalloc_noio = enable;
> +		spin_unlock_irq(&dev->power.lock);
> +
> +		dev = dev->parent;
> +
> +		/* only clear the flag for one device if all
> +		 * children of the device don't set the flag.
> +		 */

Such a comment is usually laid out as

		/*
		 * Only ...

More significantly, the comment describes what the code is doing but
not why the code is doing it.  The former is (usually) obvious from
reading the C, and the latter is what good code comments address.

And it's needed in this case.  Why does the code do this?

Also, can a device have more than one child?  If so, the code doesn't
do what the comment says it does.

> +		if (!dev || (!enable &&
> +			     device_for_each_child(dev, NULL,
> +						   dev_memalloc_noio)))
> +			break;
> +	}
> +	mutex_unlock(&dev_hotplug_mutex);
> +}
> +EXPORT_SYMBOL_GPL(pm_runtime_set_memalloc_noio);
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
