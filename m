Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 4F1AD6B0071
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 11:38:49 -0400 (EDT)
Date: Tue, 30 Oct 2012 11:38:46 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
In-Reply-To: <CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com>
Message-ID: <Pine.LNX.4.44L0.1210301112270.1363-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Tue, 30 Oct 2012, Ming Lei wrote:

> >> +bool pm_runtime_get_memalloc_noio(struct device *dev)
> >> +{
> >> +     bool ret;
> >> +     spin_lock_irq(&dev->power.lock);
> >> +     ret = dev->power.memalloc_noio_resume;
> >> +     spin_unlock_irq(&dev->power.lock);
> >> +     return ret;
> >> +}
> >
> > You don't need to acquire and release a spinlock just to read the
> > value.  Reading bitfields _is_ SMP-safe; writing them is not.
> 
> Thanks for your review.
> 
> As you pointed out before, the flag need to be checked before
> resetting usb devices, so the lock should be held to make another
> context(CPU) see the updated value suppose one context(CPU)
> call pm_runtime_set_memalloc_noio() to change the flag at the
> same time.

Okay, I see your point.  But acquiring the lock here doesn't solve the 
problem.  Suppose a thread is about to reset a USB mass-storage device.  
It acquires the lock and sees that the noio flag is clear.  But before 
it can issue the reset, another thread sets the noio flag.

I'm not sure what the best solution is.

> The lock needn't to be held when the function is called inside
> pm_runtime_set_memalloc_noio(),  so the bitfield flag should
> be checked directly without holding power lock in dev_memalloc_noio().

Yes.

A couple of other things...  Runtime resume can be blocked by runtime
suspend, if a resume is requested while the suspend is in progress.  
Therefore the runtime suspend code also needs to save-set-restore the
noio flag.

Also, we should set the noio flag at the start of 
usb_stor_control_thread, because everything that thread does can 
potentially block an I/O operation.

Lastly, pm_runtime_get_memalloc_noio always returns false when 
CONFIG_PM_RUNTIME is disabled.  But we still need to prevent I/O during 
usb_reset_device even when there's no runtime PM.  Maybe the simplest 
answer is always to set noio during resets.  That would also help with 
the race described above.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
