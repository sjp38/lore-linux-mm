Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 760186B006C
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 12:54:34 -0400 (EDT)
Date: Tue, 30 Oct 2012 12:54:33 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
In-Reply-To: <CACVXFVO5-UPNrWsySzDE5AfOv1TMqbyitQX9ViidSJPM36fqAQ@mail.gmail.com>
Message-ID: <Pine.LNX.4.44L0.1210301251050.1363-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Wed, 31 Oct 2012, Ming Lei wrote:

> On Tue, Oct 30, 2012 at 11:38 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
> 
> >
> > Okay, I see your point.  But acquiring the lock here doesn't solve the
> > problem.  Suppose a thread is about to reset a USB mass-storage device.
> > It acquires the lock and sees that the noio flag is clear.  But before
> > it can issue the reset, another thread sets the noio flag.
> 
> If the USB mass-storage device is being reseted, the flag should be set
> already generally.  If the flag is still unset, that means the disk/network
> device isn't added into system(or removed just now), so memory allocation
> with block I/O should be allowed during the reset. Looks it isn't one problem,
> isn't it?

As Oliver said, it can be a problem.

> > Lastly, pm_runtime_get_memalloc_noio always returns false when
> > CONFIG_PM_RUNTIME is disabled.  But we still need to prevent I/O during
> > usb_reset_device even when there's no runtime PM.  Maybe the simplest
> > answer is always to set noio during resets.  That would also help with
> > the race described above.
> 
> I have thought about this. IMO, pm_runtime_get_memalloc_noio should
> return true always if CONFIG_PM_RUNTIME is unset.

That's okay as long as the only user of pm_runtime_get_memalloc_noio
(apart from the runtime PM core) is usbcore.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
