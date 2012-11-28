Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3E5086B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 05:02:13 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v6 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
Date: Wed, 28 Nov 2012 11:06:56 +0100
Message-ID: <2254856.YsOm9y7BK1@vostro.rjw.lan>
In-Reply-To: <CACVXFVP=3s3pawyEbogjb=PfbSeD1B+LFk7g04FAMkGuXDQUbQ@mail.gmail.com>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com> <5434404.G1ERYjuorE@vostro.rjw.lan> <CACVXFVP=3s3pawyEbogjb=PfbSeD1B+LFk7g04FAMkGuXDQUbQ@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org

On Wednesday, November 28, 2012 11:57:19 AM Ming Lei wrote:
> On Wed, Nov 28, 2012 at 5:19 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> > On Saturday, November 24, 2012 08:59:14 PM Ming Lei wrote:
> >> The patch introduces the flag of memalloc_noio in 'struct dev_pm_info'
> >> to help PM core to teach mm not allocating memory with GFP_KERNEL
> >> flag for avoiding probable deadlock.
> >>
> >> As explained in the comment, any GFP_KERNEL allocation inside
> >> runtime_resume() or runtime_suspend() on any one of device in
> >> the path from one block or network device to the root device
> >> in the device tree may cause deadlock, the introduced
> >> pm_runtime_set_memalloc_noio() sets or clears the flag on
> >> device in the path recursively.
> >>
> >> Cc: Alan Stern <stern@rowland.harvard.edu>
> >> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> >> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> >> ---
> >> v5:
> >>       - fix code style error
> >>       - add comment on clear the device memalloc_noio flag
> >> v4:
> >>       - rename memalloc_noio_resume as memalloc_noio
> >>       - remove pm_runtime_get_memalloc_noio()
> >>       - add comments on pm_runtime_set_memalloc_noio
> >> v3:
> >>       - introduce pm_runtime_get_memalloc_noio()
> >>       - hold one global lock on pm_runtime_set_memalloc_noio
> >>       - hold device power lock when accessing memalloc_noio_resume
> >>         flag suggested by Alan Stern
> >>       - implement pm_runtime_set_memalloc_noio without recursion
> >>         suggested by Alan Stern
> >> v2:
> >>       - introduce pm_runtime_set_memalloc_noio()
> >> ---
> >>  drivers/base/power/runtime.c |   60 ++++++++++++++++++++++++++++++++++++++++++
> >>  include/linux/pm.h           |    1 +
> >>  include/linux/pm_runtime.h   |    3 +++
> >>  3 files changed, 64 insertions(+)
> >>
> >> diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
> >> index 3148b10..3e198a0 100644
> >> --- a/drivers/base/power/runtime.c
> >> +++ b/drivers/base/power/runtime.c
> >> @@ -124,6 +124,66 @@ unsigned long pm_runtime_autosuspend_expiration(struct device *dev)
> >>  }
> >>  EXPORT_SYMBOL_GPL(pm_runtime_autosuspend_expiration);
> >>
> >> +static int dev_memalloc_noio(struct device *dev, void *data)
> >> +{
> >> +     return dev->power.memalloc_noio;
> >> +}
> >> +
> >> +/*
> >> + * pm_runtime_set_memalloc_noio - Set a device's memalloc_noio flag.
> >> + * @dev: Device to handle.
> >> + * @enable: True for setting the flag and False for clearing the flag.
> >> + *
> >> + * Set the flag for all devices in the path from the device to the
> >> + * root device in the device tree if @enable is true, otherwise clear
> >> + * the flag for devices in the path whose siblings don't set the flag.
> >> + *
> >
> > Please use counters instead of walking the whole path every time.  Ie. in
> > addition to the flag add a counter to store the number of the device's
> > children having that flag set.
> 
> Thanks for your review.
> 
> IMO, pm_runtime_set_memalloc_noio() is only called in
> probe() and release() of block device and network device, which is
> in a very infrequent path, so I am wondering if it is worthy of introducing
> another counter for all devices.

Well, it may be unfrequent, but does it mean it has to do things that may
be avoided (ie. walking the children of every node in the path in some cases)?

I don't really think that the counters would cost us that much anyway.

> Also looks the current implementation of pm_runtime_set_memalloc_noio()
> is simple and clean enough with the flag, IMO.

I know you always know better. :-)

> > I would use the flag only to store the information that
> > pm_runtime_set_memalloc_noio(dev, true) has been run for this device directly
> > and I'd use a counter for everything else.
> >
> > That is, have power.memalloc_count that would be incremented when (1)
> > pm_runtime_set_memalloc_noio(dev, true) is called for that device and (2) when
> > power.memalloc_count for one of its children changes from 0 to 1 (and
> > analogously for decrementation).  Then, check the counter in rpm_callback().
> 
> Sorry, could you explain in a bit detail why we need the counter? Looks only
> checking the flag in rpm_callback() is enough, doesn't it?

Why would I want to use power.memalloc_count in addition to the
power.memalloc_noio flag?

Consider this:

pm_runtime_set_memalloc_noio(dev):
	return if power.memalloc_noio is set
	set power.memalloc_noio
  loop:
	increment power.memalloc_count
	if power.memalloc_count is 1 now switch to parent and go to loop

pm_runtime_clear_memalloc_noio(dev):
	return if power.memalloc_noio is unset
	unset power.memalloc_noio
  loop:
	decrement power.memalloc_count
	if power.memalloc_count is 0 now switch to parent and go to loop

Looks kind of simpler, doesn't it?

And why rpm_callback() should check power.memalloc_count instead of the count?
Because power.memalloc_noio will only be set for devices that
pm_runtime_set_memalloc_noio(dev) was called for directly (not necessarily for
the parents).

And that works even if someone calls any of them twice in a row for the same
device (presumably by mistake) and doesn't have to make any assumptions
about devices it is called for.

> > Besides, don't you need to check children for the arg device itself?
> 
> It isn't needed since the children of network/block device can't be
> involved of the deadlock in runtime PM path.
> 
> Also, the function is only called by network device or block device
> subsystem, both the two kind of device are class device and should
> have no children.

OK, so not walking the arg device's children is an optimization related to
some assumptions regarding who's supposed to use this routine.  That should
be clearly documented.

However, I'd prefer it not to make such assumptions in the first place.

> >> + * The function should only be called by block device, or network
> >> + * device driver for solving the deadlock problem during runtime
> >> + * resume/suspend:
> >> + *
> >> + *     If memory allocation with GFP_KERNEL is called inside runtime
> >> + *     resume/suspend callback of any one of its ancestors(or the
> >> + *     block device itself), the deadlock may be triggered inside the
> >> + *     memory allocation since it might not complete until the block
> >> + *     device becomes active and the involed page I/O finishes. The
> >> + *     situation is pointed out first by Alan Stern. Network device
> >> + *     are involved in iSCSI kind of situation.
> >> + *
> >> + * The lock of dev_hotplug_mutex is held in the function for handling
> >> + * hotplug race because pm_runtime_set_memalloc_noio() may be called
> >> + * in async probe().
> >> + *
> >> + * The function should be called between device_add() and device_del()
> >> + * on the affected device(block/network device).
> >> + */
> >> +void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
> >> +{
> >> +     static DEFINE_MUTEX(dev_hotplug_mutex);
> >
> > What's the mutex for?
> 
> It is for avoiding hotplug race, for example, without the mutex,
> another child may set the flag between the time device_for_each_child()
> runs and the next loop iteration in pm_runtime_set_memalloc_noio(false).

OK

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
