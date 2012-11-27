Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C2B7E6B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:19:43 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v6 5/6] PM / Runtime: force memory allocation with no I/O during Runtime PM callbcack
Date: Tue, 27 Nov 2012 22:24:27 +0100
Message-ID: <1354069667.BsTEhItmLz@vostro.rjw.lan>
In-Reply-To: <1353761958-12810-6-git-send-email-ming.lei@canonical.com>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com> <1353761958-12810-6-git-send-email-ming.lei@canonical.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-pm@vger.kernel.org
Cc: Ming Lei <ming.lei@canonical.com>, linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org

On Saturday, November 24, 2012 08:59:17 PM Ming Lei wrote:
> This patch applies the introduced memalloc_noio_save() and
> memalloc_noio_restore() to force memory allocation with no I/O
> during runtime_resume/runtime_suspend callback on device with
> the flag of 'memalloc_noio' set.
> 
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Cc: Oliver Neukum <oneukum@suse.de>
> Cc: Rafael J. Wysocki <rjw@sisk.pl>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
> v5:
> 	- use inline memalloc_noio_save()
> v4:
> 	- runtime_suspend need this too because rpm_resume may wait for
> 	completion of concurrent runtime_suspend, so deadlock still may
> 	be triggered in runtime_suspend path.
> ---
>  drivers/base/power/runtime.c |   32 ++++++++++++++++++++++++++++++--
>  1 file changed, 30 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
> index 3e198a0..96d99ea 100644
> --- a/drivers/base/power/runtime.c
> +++ b/drivers/base/power/runtime.c
> @@ -371,6 +371,7 @@ static int rpm_suspend(struct device *dev, int rpmflags)
>  	int (*callback)(struct device *);
>  	struct device *parent = NULL;
>  	int retval;
> +	unsigned int noio_flag;
>  
>  	trace_rpm_suspend(dev, rpmflags);
>  
> @@ -480,7 +481,20 @@ static int rpm_suspend(struct device *dev, int rpmflags)
>  	if (!callback && dev->driver && dev->driver->pm)
>  		callback = dev->driver->pm->runtime_suspend;
>  
> -	retval = rpm_callback(callback, dev);
> +	/*
> +	 * Deadlock might be caused if memory allocation with GFP_KERNEL
> +	 * happens inside runtime_suspend callback of one block device's
> +	 * ancestor or the block device itself. Network device might be
> +	 * thought as part of iSCSI block device, so network device and
> +	 * its ancestor should be marked as memalloc_noio.
> +	 */
> +	if (dev->power.memalloc_noio) {
> +		noio_flag = memalloc_noio_save();
> +		retval = rpm_callback(callback, dev);
> +		memalloc_noio_restore(noio_flag);
> +	} else {
> +		retval = rpm_callback(callback, dev);
> +	}
>  	if (retval)
>  		goto fail;
>  
> @@ -563,6 +577,7 @@ static int rpm_resume(struct device *dev, int rpmflags)
>  	int (*callback)(struct device *);
>  	struct device *parent = NULL;
>  	int retval = 0;
> +	unsigned int noio_flag;
>  
>  	trace_rpm_resume(dev, rpmflags);
>  
> @@ -712,7 +727,20 @@ static int rpm_resume(struct device *dev, int rpmflags)
>  	if (!callback && dev->driver && dev->driver->pm)
>  		callback = dev->driver->pm->runtime_resume;
>  
> -	retval = rpm_callback(callback, dev);
> +	/*
> +	 * Deadlock might be caused if memory allocation with GFP_KERNEL
> +	 * happens inside runtime_resume callback of one block device's
> +	 * ancestor or the block device itself. Network device might be
> +	 * thought as part of iSCSI block device, so network device and
> +	 * its ancestor should be marked as memalloc_noio.
> +	 */
> +	if (dev->power.memalloc_noio) {
> +		noio_flag = memalloc_noio_save();
> +		retval = rpm_callback(callback, dev);
> +		memalloc_noio_restore(noio_flag);
> +	} else {
> +		retval = rpm_callback(callback, dev);
> +	}

Please don't duplicate code this way.

You can move that whole thing to rpm_callback().  Yes, you'll probably need to
check dev->power.memalloc_noio twice in there, but that's OK.


>  	if (retval) {
>  		__update_runtime_status(dev, RPM_SUSPENDED);
>  		pm_runtime_cancel_pending(dev);
> 

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
