Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B78016B0005
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 16:59:51 -0400 (EDT)
Date: Sun, 10 Mar 2013 16:59:50 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
In-Reply-To: <513CD4C3.9060701@web.de>
Message-ID: <Pine.LNX.4.44L0.1303101638330.3146-100000@netrider.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Sun, 10 Mar 2013, Soeren Moch wrote:

> > On Wed, 20 Feb 2013, Soeren Moch wrote:
> >
> >> Ok. I use 2 em2840-based usb sticks (em28xx driver) attached to a
> >> Marvell Kirkwood-SoC with a orion-ehci usb controller. These usb sticks
> >> stream dvb data (digital TV) employing isochronous usb transfers (user
> >> application is vdr).
> >>
> >> Starting from linux-3.6 I see
> >>     ERROR: 1024 KiB atomic DMA coherent pool is too small!
> >> in the syslog after several 10 minutes (sometimes hours) of streaming
> >> and then streaming stops.
> >>
> >> In linux-3.6 the memory management for the arm architecture was changed,
> >> so that atomic coherent dma allocations are served from a special pool.
> >> This pool gets exhausted. The only user of this pool (in my test) is
> >> orion-ehci. Although I have only 10 URBs in flight (5 for each stick,
> >> resubmitted in the completion handler), I have 256 atomic coherent
> >> allocations (memory from the pool is allocated in pages) from orion-ehci
> >> when I see this error. So I think there must be a memory leak (memory
> >> allocated atomic somewhere below the usb_submit_urb call in em28xx-core.c).
> >>
> >> With other dvb sticks using usb bulk transfers I never see this error.
> >>
> >> Since you already found a memory leak in the ehci driver for isoc
> >> transfers, I hoped you can help to solve this problem. If there are
> >> additional questions, please ask. If there is something I can test, I
> >> would be glad to do so.
> >
> > I guess the first thing is to get a dmesg log showing the problem.  You
> > should build a kernel with CONFIG_USB_DEBUG enabled and post the part
> > of the dmesg output starting from when you plug in the troublesome DVB
> > stick.
> 
> Sorry for my late response. Now I built a kernel 3.8.0 with usb_debug 
> enabled. See below for the syslog of device plug-in.
> 
> > It also might help to have a record of all the isochronous-related
> > coherent allocations and deallocations done by the ehci-hcd driver.
> > Are you comfortable making your own debugging changes?  The allocations
> > are done by a call to dma_pool_alloc() in
> > drivers/usb/host/ehci-sched.c:itd_urb_transaction() if the device runs
> > at high speed and sitd_urb_transaction() if the device runs at full
> > speed.  The deallocations are done by calls to dma_pool_free() in
> > ehci-timer.c:end_free_itds().
> >
> 
> I added a debug message to 
> drivers/usb/host/ehci-sched.c:itd_urb_transaction() to log the 
> allocation flags, see log below.

But it looks like you didn't add a message to end_free_itds(), so we
don't know when the memory gets deallocated.  And you didn't print out
the values of urb, num_itds, and i, or the value of itd (so we can
match up allocations against deallocations).

> For me this looks like nothing is 
> allocated atomic here, so this function should not be the root cause of 
> the dma coherent pool exhaustion.

I don't understand.  If non-atomic allocations can't exhaust the pool, 
why do we see these allocations fail?

> Are there other allocation functions 
> which I could track?

Yes, but they wouldn't be used for isochronous transfers.  See 
ehci_qtd_alloc(), ehci_qtd_free(), ehci_qh_alloc(), and qh_destroy() in 
ehci-mem.c, as well as some other one-time-only coherent allocations in 
that file.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
