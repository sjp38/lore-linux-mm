Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 2F0D06B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 23:21:36 -0400 (EDT)
Received: from mail-ee0-f41.google.com ([74.125.83.41])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TT2OU-0000vB-81
	for linux-mm@kvack.org; Tue, 30 Oct 2012 03:21:34 +0000
Received: by mail-ee0-f41.google.com with SMTP id c4so3065143eek.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 20:21:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.44L0.1210291125590.22882-100000@netrider.rowland.org>
References: <1351513440-9286-3-git-send-email-ming.lei@canonical.com>
	<Pine.LNX.4.44L0.1210291125590.22882-100000@netrider.rowland.org>
Date: Tue, 30 Oct 2012 11:21:33 +0800
Message-ID: <CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 29, 2012 at 11:41 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
> On Mon, 29 Oct 2012, Ming Lei wrote:
>
>> The patch introduces the flag of memalloc_noio_resume in
>> 'struct dev_pm_info' to help PM core to teach mm not allocating
>> memory with GFP_KERNEL flag for avoiding probable deadlock
>> problem.
>>
>> As explained in the comment, any GFP_KERNEL allocation inside
>> runtime_resume on any one of device in the path from one block
>> or network device to the root device in the device tree may cause
>> deadlock, the introduced pm_runtime_set_memalloc_noio() sets or
>> clears the flag on device of the path recursively.
>>
>> This patch also introduces pm_runtime_get_memalloc_noio() because
>> the flag may be accessed in block device's error handling path
>> (for example, usb device reset)
>
>> +/*
>> + * pm_runtime_get_memalloc_noio - Get a device's memalloc_noio flag.
>> + * @dev: Device to handle.
>> + *
>> + * Return the device's memalloc_noio flag.
>> + *
>> + * The device power lock is held because bitfield is not SMP-safe.
>> + */
>> +bool pm_runtime_get_memalloc_noio(struct device *dev)
>> +{
>> +     bool ret;
>> +     spin_lock_irq(&dev->power.lock);
>> +     ret = dev->power.memalloc_noio_resume;
>> +     spin_unlock_irq(&dev->power.lock);
>> +     return ret;
>> +}
>
> You don't need to acquire and release a spinlock just to read the
> value.  Reading bitfields _is_ SMP-safe; writing them is not.

Thanks for your review.

As you pointed out before, the flag need to be checked before
resetting usb devices, so the lock should be held to make another
context(CPU) see the updated value suppose one context(CPU)
call pm_runtime_set_memalloc_noio() to change the flag at the
same time.

The lock needn't to be held when the function is called inside
pm_runtime_set_memalloc_noio(),  so the bitfield flag should
be checked directly without holding power lock in dev_memalloc_noio().

>
>> +/*
>> + * pm_runtime_set_memalloc_noio - Set a device's memalloc_noio flag.
>> + * @dev: Device to handle.
>> + * @enable: True for setting the flag and False for clearing the flag.
>> + *
>> + * Set the flag for all devices in the path from the device to the
>> + * root device in the device tree if @enable is true, otherwise clear
>> + * the flag for devices in the path which sibliings don't set the flag.
>
> s/which/whose/
> s/ii/i

Will fix it in -v4.

>> + *
>> + * The function should only be called by block device, or network
>> + * device driver for solving the deadlock problem during runtime
>> + * resume:
>> + *   if memory allocation with GFP_KERNEL is called inside runtime
>> + *   resume callback of any one of its ancestors(or the block device
>> + *   itself), the deadlock may be triggered inside the memory
>> + *   allocation since it might not complete until the block device
>> + *   becomes active and the involed page I/O finishes. The situation
>> + *   is pointed out first by Alan Stern. Network device are involved
>> + *   in iSCSI kind of situation.
>> + *
>> + * The lock of dev_hotplug_mutex is held in the function for handling
>> + * hotplug race because pm_runtime_set_memalloc_noio() may be called
>> + * in async probe().
>> + */
>> +void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
>> +{
>> +     static DEFINE_MUTEX(dev_hotplug_mutex);
>> +
>> +     mutex_lock(&dev_hotplug_mutex);
>> +     while (dev) {
>
> Unless you think somebody is likely to call this function with dev
> equal to NULL, this can simply be
>
>         for (;;) {
>
>> +             /* hold power lock since bitfield is not SMP-safe. */
>> +             spin_lock_irq(&dev->power.lock);
>> +             dev->power.memalloc_noio_resume = enable;
>> +             spin_unlock_irq(&dev->power.lock);
>> +
>> +             dev = dev->parent;
>> +
>> +             /* only clear the flag for one device if all
>> +              * children of the device don't set the flag.
>> +              */
>> +             if (!dev || (!enable &&
>
> ... thanks to this test.
>
>> +                          device_for_each_child(dev, NULL,
>> +                                                dev_memalloc_noio)))
>> +                     break;
>> +     }
>> +     mutex_unlock(&dev_hotplug_mutex);
>> +}
>
> This might not work if somebody calls pm_runtime_set_memalloc_noio(dev,
> true) and then afterwards registers dev at the same time as someone
> else calls pm_runtime_set_memalloc_noio(dev2, false), if dev and dev2
> have the same parent.

Good catch, pm_runtime_set_memalloc_noio() should be called between
device_add() and device_del() on block/network device.

> Perhaps the kerneldoc should mention that this function must not be
> called until after dev is registered.

Yes,  it should be added in -v4.


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
