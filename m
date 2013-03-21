Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 0A74C6B0036
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 13:05:38 -0400 (EDT)
Message-ID: <514B3DBB.3060302@web.de>
Date: Thu, 21 Mar 2013 18:04:59 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
References: <Pine.LNX.4.44L0.1303171320560.26486-100000@netrider.rowland.org>
In-Reply-To: <Pine.LNX.4.44L0.1303171320560.26486-100000@netrider.rowland.org>
Content-Type: multipart/mixed;
 boundary="------------000000010805030108080409"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, michael@amarulasolutions.com

This is a multi-part message in MIME format.
--------------000000010805030108080409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 03/17/13 18:36, Alan Stern wrote:
> On Sun, 17 Mar 2013, Soeren Moch wrote:
>
>> For each device only one isochronous endpoint is used (EP IN4, 1x 940
>> Bytes, Interval 1).
>> When the ENOMEM error occurs, a huge number of iTDs is in the free_list
>> of one stream. This number is much higher than the 2*M entries, which
>> should be there according to your description.
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
>

Now I found out what is going on here:

In itd_urb_transaction() we allocate 9 iTDs for each URB with 
number_of_packets == 64 in my case. The iTDs are added to 
sched->td_list. For a frame-aligned scheduling we need 8 iTDs, the 9th 
one is released back to the front of the streams free_list in 
iso_sched_free(). This iTD was cleared after allocation and has a frame 
number of 0 now. So for each allocation when now_frame == 0 we allocate 
from the dma_pool, not from the free_list. The attached patch 
invalidates the frame number in each iTD before it is sent to the 
scheduler. This fixes the problem without the need to iterate over a iTD 
list.

Signed-off-by: Soeren Moch <smoch@web.de>




--------------000000010805030108080409
Content-Type: text/x-patch;
 name="ehci.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ehci.diff"

--- linux-3.9.0-rc3-guru/drivers/usb/host/ehci-sched.c.orig	2013-03-21 17:36:21.000000000 +0100
+++ linux-3.9.0-rc3-guru/drivers/usb/host/ehci-sched.c	2013-03-21 17:38:56.000000000 +0100
@@ -1214,6 +1214,7 @@ itd_urb_transaction (
 
 		memset (itd, 0, sizeof *itd);
 		itd->itd_dma = itd_dma;
+		itd->frame = -1;
 		list_add (&itd->itd_list, &sched->td_list);
 	}
 	spin_unlock_irqrestore (&ehci->lock, flags);
@@ -1915,6 +1916,7 @@ sitd_urb_transaction (
 
 		memset (sitd, 0, sizeof *sitd);
 		sitd->sitd_dma = sitd_dma;
+		sitd->frame = -1;
 		list_add (&sitd->sitd_list, &iso_sched->td_list);
 	}
 

--------------000000010805030108080409--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
