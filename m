Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 180346B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 22:10:58 -0400 (EDT)
Message-ID: <5143D4A5.4080002@web.de>
Date: Sat, 16 Mar 2013 03:10:45 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
References: <Pine.LNX.4.44L0.1303141719450.1194-100000@iolanthe.rowland.org>
In-Reply-To: <Pine.LNX.4.44L0.1303141719450.1194-100000@iolanthe.rowland.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org

On 14.03.2013 22:33, Alan Stern wrote:
> Maybe a better way to go about this is, instead of printing out every
> allocation and deallocation, to keep a running counter.  You could have
> the driver print out the value of this counter every minute or so.  Any
> time the device isn't in use, the counter should be 0.

I implemented the counter. The max value is sampled at the beginning of 
end_free_itds(), the current counter value is sampled at the end of this 
function. Counter values w/o a max number are from the error path in 
itd_urb_transaction().
The number of allocated iTDs can grow to higher values (why?), but 
normally the iTDs are freed during normal operation. Due to some reason 
the number of iTDs suddenly increases until coherent pool exhaustion. 
There is no permanent memory leak, all iTDs are released when the user 
application ends. But imho several thousands of iTDs cannot be the 
intended behavior...

   Soeren


Mar 16 01:12:52 guruvdr kernel: itd_counter:42 (max:174)
Mar 16 01:12:52 guruvdr kernel: itd_counter:0 (max:174)
Mar 16 01:13:13 guruvdr kernel: itd_counter:42 (max:174)
Mar 16 01:13:13 guruvdr kernel: itd_counter:0 (max:174)
Mar 16 01:13:34 guruvdr kernel: itd_counter:87 (max:174)
Mar 16 01:13:34 guruvdr kernel: itd_counter:0 (max:174)
Mar 16 01:13:55 guruvdr kernel: itd_counter:42 (max:426)
Mar 16 01:13:55 guruvdr kernel: itd_counter:0 (max:426)
Mar 16 01:15:14 guruvdr kernel: itd_counter:249 (max:1441)
Mar 16 01:15:14 guruvdr kernel: itd_counter:0 (max:1441)
[...]
Mar 16 02:03:33 guruvdr kernel: itd_counter:0 (max:1441)
Mar 16 02:04:15 guruvdr kernel: itd_counter:150 (max:1441)
Mar 16 02:04:15 guruvdr kernel: itd_counter:0 (max:1441)
Mar 16 02:04:36 guruvdr kernel: itd_counter:42 (max:1441)
Mar 16 02:04:36 guruvdr kernel: itd_counter:0 (max:1441)
Mar 16 02:04:57 guruvdr kernel: itd_counter:42 (max:1441)
Mar 16 02:04:57 guruvdr kernel: itd_counter:0 (max:1441)
Mar 16 02:05:18 guruvdr kernel: itd_counter:42 (max:1441)
Mar 16 02:05:18 guruvdr kernel: itd_counter:0 (max:1441)
Mar 16 02:05:39 guruvdr kernel: itd_counter:42 (max:1441)
Mar 16 02:05:39 guruvdr kernel: itd_counter:0 (max:1441)
Mar 16 02:06:43 guruvdr kernel: itd_counter:254 (max:1441)
Mar 16 02:07:44 guruvdr kernel: itd_counter:968 (max:1469)
Mar 16 02:08:04 guruvdr kernel: itd_counter:1192 (max:1469)
Mar 16 02:08:46 guruvdr kernel: itd_counter:1812 (max:1854)
Mar 16 02:09:07 guruvdr kernel: itd_counter:2117 (max:2159)
Mar 16 02:09:28 guruvdr kernel: itd_counter:2482 (max:2524)
Mar 16 02:09:49 guruvdr kernel: itd_counter:2791 (max:2833)
Mar 16 02:10:10 guruvdr kernel: itd_counter:3088 (max:3409)
Mar 16 02:10:31 guruvdr kernel: itd_counter:3402 (max:3444)
Mar 16 02:10:52 guruvdr kernel: itd_counter:3689 (max:3731)
Mar 16 02:11:13 guruvdr kernel: itd_counter:3950 (max:4073)
Mar 16 02:11:34 guruvdr kernel: itd_counter:4264 (max:4306)
Mar 16 02:11:55 guruvdr kernel: itd_counter:4525 (max:4567)
Mar 16 02:12:16 guruvdr kernel: itd_counter:4803 (max:4845)
Mar 16 02:12:37 guruvdr kernel: itd_counter:5028 (max:5070)
Mar 16 02:13:19 guruvdr kernel: itd_counter:5549 (max:5843)
Mar 16 02:13:40 guruvdr kernel: itd_counter:5836 (max:5878)
Mar 16 02:14:01 guruvdr kernel: itd_counter:6133 (max:6238)
Mar 16 02:14:06 guruvdr kernel: ERROR: 1024 KiB atomic DMA coherent pool 
is too small!
Mar 16 02:14:06 guruvdr kernel: Please increase it with coherent_pool= 
kernel parameter!
Mar 16 02:14:06 guruvdr kernel: itd_counter:6275
Mar 16 02:14:06 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:06 guruvdr kernel: itd_counter:6275
Mar 16 02:14:06 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:06 guruvdr kernel: itd_counter:6275
Mar 16 02:14:06 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:06 guruvdr kernel: itd_counter:6275
Mar 16 02:14:06 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:07 guruvdr kernel: itd_counter:6275
Mar 16 02:14:07 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:07 guruvdr kernel: itd_counter:6275
Mar 16 02:14:07 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:07 guruvdr kernel: itd_counter:6275
Mar 16 02:14:07 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:07 guruvdr kernel: itd_counter:6275
Mar 16 02:14:07 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:08 guruvdr kernel: itd_counter:6275
Mar 16 02:14:08 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 16 02:14:08 guruvdr kernel: itd_counter:78 (max:6275)
Mar 16 02:14:22 guruvdr kernel: itd_counter:0 (max:6275)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
