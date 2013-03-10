Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id DF8C86B0005
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 14:45:47 -0400 (EDT)
Message-ID: <513CD4C3.9060701@web.de>
Date: Sun, 10 Mar 2013 19:45:23 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
References: <Pine.LNX.4.44L0.1302211337580.1529-100000@iolanthe.rowland.org>
In-Reply-To: <Pine.LNX.4.44L0.1302211337580.1529-100000@iolanthe.rowland.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 21.02.2013 19:54, Alan Stern wrote:
> I trust you won't mind if I put this on the public mailing list.  In
> general, problems of this sort should be discussed in public.  In
> addition to creating a permanent record in the various mailing list
> archives, it also gives other people a chance to learn about these
> problems and to chime in if they think of something I have overlooked.

This problem was already discussed on the kernel and mm mailing list. 
(see thread starting here: https://lkml.org/lkml/2012/11/6/408 )

Since this seems to be USB related now, of course it makes sense to 
discuss this problem on the usb mailing list.

> On Wed, 20 Feb 2013, Soeren Moch wrote:
>
>> Ok. I use 2 em2840-based usb sticks (em28xx driver) attached to a
>> Marvell Kirkwood-SoC with a orion-ehci usb controller. These usb sticks
>> stream dvb data (digital TV) employing isochronous usb transfers (user
>> application is vdr).
>>
>> Starting from linux-3.6 I see
>>     ERROR: 1024 KiB atomic DMA coherent pool is too small!
>> in the syslog after several 10 minutes (sometimes hours) of streaming
>> and then streaming stops.
>>
>> In linux-3.6 the memory management for the arm architecture was changed,
>> so that atomic coherent dma allocations are served from a special pool.
>> This pool gets exhausted. The only user of this pool (in my test) is
>> orion-ehci. Although I have only 10 URBs in flight (5 for each stick,
>> resubmitted in the completion handler), I have 256 atomic coherent
>> allocations (memory from the pool is allocated in pages) from orion-ehci
>> when I see this error. So I think there must be a memory leak (memory
>> allocated atomic somewhere below the usb_submit_urb call in em28xx-core.c).
>>
>> With other dvb sticks using usb bulk transfers I never see this error.
>>
>> Since you already found a memory leak in the ehci driver for isoc
>> transfers, I hoped you can help to solve this problem. If there are
>> additional questions, please ask. If there is something I can test, I
>> would be glad to do so.
>
> I guess the first thing is to get a dmesg log showing the problem.  You
> should build a kernel with CONFIG_USB_DEBUG enabled and post the part
> of the dmesg output starting from when you plug in the troublesome DVB
> stick.

Sorry for my late response. Now I built a kernel 3.8.0 with usb_debug 
enabled. See below for the syslog of device plug-in.

> It also might help to have a record of all the isochronous-related
> coherent allocations and deallocations done by the ehci-hcd driver.
> Are you comfortable making your own debugging changes?  The allocations
> are done by a call to dma_pool_alloc() in
> drivers/usb/host/ehci-sched.c:itd_urb_transaction() if the device runs
> at high speed and sitd_urb_transaction() if the device runs at full
> speed.  The deallocations are done by calls to dma_pool_free() in
> ehci-timer.c:end_free_itds().
>

I added a debug message to 
drivers/usb/host/ehci-sched.c:itd_urb_transaction() to log the 
allocation flags, see log below. For me this looks like nothing is 
allocated atomic here, so this function should not be the root cause of 
the dma coherent pool exhaustion. Are there other allocation functions 
which I could track?

Regards,
  Soeren Moch



Mar 10 15:21:05 guruvdr kernel: hub 1-1:1.0: state 7 ports 4 chg 0000 
evt 0008
Mar 10 15:21:05 guruvdr kernel: hub 1-1:1.0: port 3, status 0101, change 
0001, 12 Mb/s
Mar 10 15:21:05 guruvdr kernel: hub 1-1:1.0: debounce: port 3: total 
100ms stable 100ms status 0x101
Mar 10 15:21:05 guruvdr kernel: usb 1-1.3: new high-speed USB device 
number 6 using orion-ehci
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: default language 0x0409
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: udev 6, busnum 1, minor = 5
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: New USB device found, 
idVendor=0ccd, idProduct=00b2
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: New USB device strings: 
Mfr=3, Product=1, SerialNumber=2
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: Product: Cinergy HTC Stick
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: Manufacturer: TERRATEC
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: SerialNumber: 123456789ABCD
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: usb_probe_device
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: configuration #1 chosen from 
1 choice
Mar 10 15:21:06 guruvdr kernel: usb 1-1.3: adding 1-1.3:1.0 (config #1, 
interface 0)
Mar 10 15:21:06 guruvdr kernel: em28xx 1-1.3:1.0: usb_probe_interface
Mar 10 15:21:06 guruvdr kernel: em28xx 1-1.3:1.0: usb_probe_interface - 
got id
Mar 10 15:21:06 guruvdr kernel: em28xx: New device TERRATEC  Cinergy HTC 
Stick @ 480 Mbps (0ccd:00b2, interface 0, class 0)
Mar 10 15:21:06 guruvdr kernel: em28xx: Audio Vendor Class interface 0 found
Mar 10 15:21:06 guruvdr kernel: em28xx: Video interface 0 found
Mar 10 15:21:06 guruvdr kernel: em28xx: DVB interface 0 found
Mar 10 15:21:06 guruvdr kernel: em28xx #0: chip ID is em2884
Mar 10 15:21:06 guruvdr kernel: em28xx #0: Identified as Terratec 
Cinergy HTC Stick (card=82)
Mar 10 15:21:06 guruvdr kernel: em28xx #0: Config register raw data: 0x45
Mar 10 15:21:06 guruvdr kernel: em28xx #0: v4l2 driver version 0.1.3
Mar 10 15:21:06 guruvdr kernel: em28xx #0: V4L2 video device registered 
as video0
Mar 10 15:21:06 guruvdr kernel: usbcore: registered new interface driver 
em28xx
Mar 10 15:21:07 guruvdr kernel: drxk: status = 0x639260d9
Mar 10 15:21:07 guruvdr kernel: drxk: detected a drx-3926k, spin A3, 
xtal 20.250 MHz
Mar 10 15:21:09 guruvdr kernel: hub 1-1:1.0: state 7 ports 4 chg 0000 
evt 0010
Mar 10 15:21:09 guruvdr kernel: hub 1-1:1.0: port 4, status 0101, change 
0001, 12 Mb/s
Mar 10 15:21:09 guruvdr kernel: hub 1-1:1.0: debounce: port 4: total 
100ms stable 100ms status 0x101
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: new high-speed USB device 
number 7 using orion-ehci
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: default language 0x0409
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: udev 7, busnum 1, minor = 6
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: New USB device found, 
idVendor=2304, idProduct=0242
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: New USB device strings: 
Mfr=1, Product=2, SerialNumber=3
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: Product: PCTV 510e
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: Manufacturer: Pinnacle Systems
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: SerialNumber: 123456789012
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: usb_probe_device
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: configuration #1 chosen from 
1 choice
Mar 10 15:21:09 guruvdr kernel: usb 1-1.4: adding 1-1.4:1.0 (config #1, 
interface 0)
Mar 10 15:21:09 guruvdr kernel: em28xx 1-1.4:1.0: usb_probe_interface
Mar 10 15:21:09 guruvdr kernel: em28xx 1-1.4:1.0: usb_probe_interface - 
got id
Mar 10 15:21:09 guruvdr kernel: em28xx: New device Pinnacle Systems PCTV 
510e @ 480 Mbps (2304:0242, interface 0, class 0)
Mar 10 15:21:09 guruvdr kernel: em28xx: Audio Vendor Class interface 0 found
Mar 10 15:21:09 guruvdr kernel: em28xx: Video interface 0 found
Mar 10 15:21:09 guruvdr kernel: em28xx: DVB interface 0 found
Mar 10 15:21:09 guruvdr kernel: em28xx #1: chip ID is em2884
Mar 10 15:21:10 guruvdr kernel: em28xx #1: Identified as PCTV 
QuatroStick (510e) (card=85)
Mar 10 15:21:10 guruvdr kernel: em28xx #1: Config register raw data: 0x31
Mar 10 15:21:10 guruvdr kernel: em28xx #1: I2S Audio (5 sample rates)
Mar 10 15:21:10 guruvdr kernel: em28xx #1: No AC97 audio processor
Mar 10 15:21:10 guruvdr kernel: em28xx #1: v4l2 driver version 0.1.3
Mar 10 15:21:10 guruvdr kernel: em28xx #1: V4L2 video device registered 
as video1
Mar 10 15:21:10 guruvdr kernel: hub 1-1:1.0: state 7 ports 4 chg 0000 
evt 0010
Mar 10 15:21:11 guruvdr kernel: DRXK driver version 0.9.4300
Mar 10 15:21:11 guruvdr kernel: drxk: frontend initialized.
Mar 10 15:21:11 guruvdr kernel: tda18271 2-0060: creating new instance
Mar 10 15:21:11 guruvdr kernel: TDA18271HD/C2 detected @ 2-0060
Mar 10 15:21:12 guruvdr kernel: DVB: registering new adapter (em28xx #0)
Mar 10 15:21:12 guruvdr kernel: usb 1-1.3: DVB: registering adapter 2 
frontend 0 (DRXK DVB-C DVB-T)...
Mar 10 15:21:12 guruvdr kernel: em28xx #0: Successfully loaded em28xx-dvb
Mar 10 15:21:12 guruvdr kernel: Em28xx: Initialized (Em28xx dvb 
Extension) extension
Mar 10 15:21:12 guruvdr kernel: drxk: status = 0x039260d9
Mar 10 15:21:12 guruvdr kernel: drxk: detected a drx-3926k, spin A1, 
xtal 20.250 MHz
Mar 10 15:21:13 guruvdr kernel: DRXK driver version 0.9.4300
Mar 10 15:21:13 guruvdr kernel: drxk: frontend initialized.
Mar 10 15:21:13 guruvdr kernel: tda18271 3-0060: creating new instance
Mar 10 15:21:13 guruvdr kernel: TDA18271HD/C2 detected @ 3-0060
Mar 10 15:21:13 guruvdr kernel: DVB: registering new adapter (em28xx #1)
Mar 10 15:21:13 guruvdr kernel: usb 1-1.4: DVB: registering adapter 3 
frontend 0 (DRXK DVB-C DVB-T)...
Mar 10 15:21:13 guruvdr kernel: em28xx #1: Successfully loaded em28xx-dvb
[...]
Mar 10 18:55:05 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:05 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x80000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x80000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: ERROR: 1024 KiB atomic DMA coherent pool 
is too small!
Mar 10 18:55:06 guruvdr kernel: Please increase it with coherent_pool= 
kernel parameter!
Mar 10 18:55:06 guruvdr kernel: itd dma_pool_alloc flags: 0x20000093
Mar 10 18:55:06 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 10 18:55:07 guruvdr kernel: itd dma_pool_alloc flags: 0x80000093
Mar 10 18:55:07 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 10 18:55:07 guruvdr kernel: itd dma_pool_alloc flags: 0x80000093
Mar 10 18:55:07 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 10 18:55:08 guruvdr kernel: itd dma_pool_alloc flags: 0x80000093
Mar 10 18:55:08 guruvdr kernel: orion-ehci orion-ehci.0: can't init itds
Mar 10 18:55:13 guruvdr kernel: itd dma_pool_alloc flags: 0x80000013
Mar 10 18:55:13 guruvdr kernel: itd dma_pool_alloc flags: 0x20000013
Mar 10 18:55:13 guruvdr kernel: itd dma_pool_alloc flags: 0x20000013

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
