Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 7FA216B0037
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 13:39:39 -0400 (EDT)
Date: Sat, 16 Mar 2013 13:39:38 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
In-Reply-To: <5143D4A5.4080002@web.de>
Message-ID: <Pine.LNX.4.44L0.1303161303500.7276-100000@netrider.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org

On Sat, 16 Mar 2013, Soeren Moch wrote:

> I implemented the counter. The max value is sampled at the beginning of 
> end_free_itds(), the current counter value is sampled at the end of this 
> function. Counter values w/o a max number are from the error path in 
> itd_urb_transaction().
> The number of allocated iTDs can grow to higher values (why?), but 
> normally the iTDs are freed during normal operation. Due to some reason 
> the number of iTDs suddenly increases until coherent pool exhaustion. 
> There is no permanent memory leak, all iTDs are released when the user 
> application ends. But imho several thousands of iTDs cannot be the 
> intended behavior...

No, it's not.  Here's how it's supposed to work:

Each ehci_iso_stream structure corresponds to a single isochronous
endpoint.  The structure has a free list of iTDs that aren't currently
in use; when an URB is submitted, its iTDs are taken from the start of
this free list if possible.  Otherwise new iTDs are allocated from the
DMA pool.

iTDs on the free list aren't always available.  This is because the 
hardware can continue to access an iTD for up to 1 ms after the iTD has 
completed.  itd->frame stores the frame number (one frame per ms) for 
when the iTD completes, and ehci->now_frame contains a best estimate of 
the current frame number.  This explains the logic in 
itd_urb_transaction().  Near the end of itd_complete() you can see 
where a completed iTD gets added back to the end of the free list.

At the very end of itd_complete() is a section of code that takes the
entries on the iso_stream's free list and moves them to a global free
list (ehci->cached_itd_list).  This happens only when the endpoint is
no longer in use, i.e., no iTDs are queued for it.  The end_free_itds()  
routine in ehci_timer.c takes iTDs from this global list and releases
them back to the DMA pool.  The routine doesn't run until at least 1 ms
after start_free_itds() is called, to wait for the hardware to stop
accessing the iTDs on the list.

The idea is that during normal use we will quickly reach a steady
state, where an endpoint always has about N URBs queued for it, each
URB uses about M iTDs, and there are one or two URB's worth of unused
iTDs.  Thus there will be N*M iTDs in use plus maybe another 2*M iTDs
on the iso_stream's free list.  Once we reach this point, every new URB
should be able to get the iTDs it needs from the free list (assuming a
new URB is submitted every time an URB completes).  When the URBs stop
being submitted, the pipeline will empty out and after a couple more
milliseconds, all (N+2)*M iTDs should be released back to the pool.

In your case the situation is complicated by the fact that you're using
two devices, each of which has up to four isochronous endpoints.  This
makes it harder to see what's going on.  Probably not all of the 
endpoints were being used for data transfers.  But even if they were, 
there should not have been more then 800 iTDs allocated at any time 
(figure that N is around 5 and M is 9).  You could simplify the testing 
by using only one device -- it might not exhaust the pool but your iTD
counter would still indicate if something wasn't right.

I'm not sure how to figure out what's causing the problem.  Maybe you
can think of a good way to see where the actual operation differs from
the description above.  Perhaps start by keeping track of the number of
iTDs on each iso_stream's free list and the number in use by each
iso_stream.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
