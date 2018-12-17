Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2BA48E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:45:18 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z126so15670958qka.10
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:45:18 -0800 (PST)
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id e5si2674637qtq.387.2018.12.17.07.45.17
        for <linux-mm@kvack.org>;
        Mon, 17 Dec 2018 07:45:18 -0800 (PST)
Date: Mon, 17 Dec 2018 10:45:17 -0500 (EST)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: cma: deadlock using usb-storage and fs
In-Reply-To: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
Message-ID: <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
Cc: linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

On Sun, 16 Dec 2018, Gaël PORTAY wrote:

> Dear kernel hackers,
> 
> I faced a deadlock in CMA (using usb-storage and FAT) between two tasks that
> want to allocate CMA. All task involved are in D-state. I am running 4.19.1
> mainline on an imx6q platform.
> 
> My understanding of that issue is as follow:
> 
> The first task gets in cma_alloc(), acquires the mutex, triggers page
> migrations and yields.

...

> The second task wants to writeback/flush the pages through USB, which, I
> assume, is due to the page migration. The usb-storage triggers a CMA allocation
> but get locked in cma_alloc since the first task hold the mutex (It is a FAT
> formatted partition, if it helps).
> 
> 	usb-storage     D    0   349      2 0x00000000
> 	Backtrace: 
...
> 	[<bf1c7550>] (usb_sg_wait [usbcore]) from [<bf2bd618>] (usb_stor_bulk_transfer_sglist.part.2+0x80/0xdc [usb_storage]) r9:0001e000 r8:eca594ac r7:0001e000 r6:c0008200 r5:eca59514 r4:eca59488

It looks like there is a logical problem in the CMA allocator.  The
call in usb_sg_wait() specifies GFP_NOIO, which is supposed to prevent
allocations from blocking on any I/O operations.  Therefore we
shouldn't be waiting for the CMA mutex.

Perhaps the CMA allocator needs to drop the mutex while doing 
writebacks/flushes, or perhaps it needs to be reorganized some other 
way.  I don't know anything about it.

Does the CMA code have any maintainers who might need to know about 
this, or is it all handled by the MM maintainers?

Alan Stern
