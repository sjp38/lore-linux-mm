Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2AA6E6B0069
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 06:51:47 -0400 (EDT)
From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
Date: Tue, 30 Oct 2012 11:57:35 +0100
Message-ID: <2149424.HsnQpSLjK5@linux-lqwf.site>
In-Reply-To: <CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com>
References: <1351513440-9286-3-git-send-email-ming.lei@canonical.com> <Pine.LNX.4.44L0.1210291125590.22882-100000@netrider.rowland.org> <CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Tuesday 30 October 2012 11:21:33 Ming Lei wrote:
> On Mon, Oct 29, 2012 at 11:41 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
> > On Mon, 29 Oct 2012, Ming Lei wrote:
> >
> >> The patch introduces the flag of memalloc_noio_resume in
> >> 'struct dev_pm_info' to help PM core to teach mm not allocating
> >> memory with GFP_KERNEL flag for avoiding probable deadlock
> >> problem.
> >>
> >> As explained in the comment, any GFP_KERNEL allocation inside
> >> runtime_resume on any one of device in the path from one block
> >> or network device to the root device in the device tree may cause
> >> deadlock, the introduced pm_runtime_set_memalloc_noio() sets or
> >> clears the flag on device of the path recursively.
> >>
> >> This patch also introduces pm_runtime_get_memalloc_noio() because
> >> the flag may be accessed in block device's error handling path
> >> (for example, usb device reset)
> >
> >> +/*
> >> + * pm_runtime_get_memalloc_noio - Get a device's memalloc_noio flag.
> >> + * @dev: Device to handle.
> >> + *
> >> + * Return the device's memalloc_noio flag.
> >> + *
> >> + * The device power lock is held because bitfield is not SMP-safe.
> >> + */
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
> 
> The lock needn't to be held when the function is called inside
> pm_runtime_set_memalloc_noio(),  so the bitfield flag should
> be checked directly without holding power lock in dev_memalloc_noio().

Hi,

how is this to work with power management domains?
And I may be dense, but disks are added in slave_configure().
This seems to be a race to me.

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
