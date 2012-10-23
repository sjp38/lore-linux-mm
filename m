Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 2BBFB6B005A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 10:46:50 -0400 (EDT)
Date: Tue, 23 Oct 2012 10:46:49 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [RFC PATCH v2 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
In-Reply-To: <CACVXFVMmszZWHaeNS6LSG4nHR4wWBLwM_BvynRwUW8X=nO+JWA@mail.gmail.com>
Message-ID: <Pine.LNX.4.44L0.1210231022230.1635-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Tue, 23 Oct 2012, Ming Lei wrote:

> On Mon, Oct 22, 2012 at 10:33 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
> >
> > Tail recursion should be implemented as a loop, not as an explicit
> > recursion.  That is, the function should be:
> >
> > void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
> > {
> >         do {
> >                 dev->power.memalloc_noio_resume = enable;
> >
> >                 if (!enable) {
> >                         /*
> >                          * Don't clear the parent's flag if any of the
> >                          * parent's children have their flag set.
> >                          */
> >                         if (device_for_each_child(dev->parent, NULL,
> >                                           dev_memalloc_noio))
> >                                 return;
> >                 }
> >                 dev = dev->parent;
> >         } while (dev);
> > }
> 
> OK, will take the non-recursion implementation for saving kernel
> stack space.
> 
> >
> > except that you need to add locking, for two reasons:
> >
> >         There's a race.  What happens if another child sets the flag
> >         between the time device_for_each_child() runs and the next loop
> >         iteration?
> 
> Yes, I know the race, and not adding a lock because the function
> is mostly called in .probe() or .remove() callback and its parent's device
> lock is held to avoid this race.
> 
> Considered that it may be called in async probe() (scsi disk), one lock
> is needed, the simplest way is to add a global lock. Any suggestion?

No.  Because of where you put the new flag, it must be protected by
dev->power.lock.  And this means the iterative implementation shown
above can't be used as is.  It will have to be more like this:

void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
{
	spin_lock_irq(&dev->power.lock);
	dev->power.memalloc_noio_resume = enable;

	while (dev->parent) {
		spin_unlock_irq(&dev->power.lock);
		dev = dev->parent;

		spin_lock_irq(&dev->power.lock);
		/*
		 * Don't clear the parent's flag if any of the
		 * parent's children have their flag set.
		 */
		if (!enable && device_for_each_child(dev->parent, NULL,
				dev_memalloc_noio))
			break;
		dev->power.memalloc_noio_resume = enable;
	}
	spin_unlock_irq(&dev->power.lock);
}

> >         Even without a race, access to bitfields is not SMP-safe
> >         without locking.
> 
> You mean one ancestor device might not be in active when
> one of its descendants is being probed or removed?

No.  Consider this example:

	struct foo {
		int a:1;
		int b:1;
	} x;

Consider what happens if CPU 0 does "x.a = 1" at the same time as 
another CPU 1 does "x.b = 1".  The compiler might produce object code 
looking like this for CPU 0:

	move	x, reg1
	or	0x1, reg1
	move	reg1, x

and this for CPU 1:

	move	x, reg2
	or	0x2, reg2
	move	reg2, x

With no locking, the two "or" instructions could execute 
simultaneously.  What will the final value of x be?

The two CPUs will interfere, even though they are touching different 
bitfields.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
