Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id EC6526B0027
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 13:39:54 -0400 (EDT)
Date: Sun, 17 Mar 2013 13:39:53 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
In-Reply-To: <Pine.LNX.4.44L0.1303171320560.26486-100000@netrider.rowland.org>
Message-ID: <Pine.LNX.4.44L0.1303171338270.26486-100000@netrider.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org

On Sun, 17 Mar 2013, Alan Stern wrote:

> On Sun, 17 Mar 2013, Soeren Moch wrote:
> 
> > For each device only one isochronous endpoint is used (EP IN4, 1x 940 
> > Bytes, Interval 1).
> > When the ENOMEM error occurs, a huge number of iTDs is in the free_list 
> > of one stream. This number is much higher than the 2*M entries, which 
> > should be there according to your description.
> 
> Okay, but how did they get there?  With each URB requiring 9 iTDs, and
> about 5 URBs active at any time, there should be about 5*9 = 45 iTDs in
> use and 2*9 = 18 iTDs on the free list.  By the time each URB
> completes, it should have released all 9 iTDs back to the free list,
> and each time an URB is submitted, it should be able to acquire all 9
> of the iTDs that it needs from the free list -- it shouldn't have to 
> allocate any from the DMA pool.
> 
> Looks like you'll have to investigate what's going on inside
> itd_urb_transaction().  Print out some useful information whenever the
> size of stream->free_list is above 50, such as the value of num_itds,
> how many of the loop iterations could get an iTD from the free list,
> and the value of itd->frame in the case where the "goto alloc_itd"
> statement is followed.
> 
> It might be a good idea also to print out the size of the free list in
> itd_complete(), where it calls ehci_urb_done(), and include the value
> of ehci->now_frame.

One thing I forgot to mention: It would help to have millisecond
precision for the timestamps in the system log, for comparison of frame
number values.  Please enable CONFIG_PRINTK_TIME for the next test.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
