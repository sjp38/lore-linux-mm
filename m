Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBAB88E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 13:29:27 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id p16so59271wmc.5
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:29:27 -0800 (PST)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id r6si675197wrw.212.2018.12.17.10.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 10:29:26 -0800 (PST)
Date: Mon, 17 Dec 2018 13:29:22 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

Alan,

On Mon, Dec 17, 2018 at 10:45:17AM -0500, Alan Stern wrote:
> On Sun, 16 Dec 2018, Ga�l PORTAY wrote:
> ...
>
> > The second task wants to writeback/flush the pages through USB, which, I
> > assume, is due to the page migration. The usb-storage triggers a CMA allocation
> > but get locked in cma_alloc since the first task hold the mutex (It is a FAT
> > formatted partition, if it helps).
> > 
> > 	usb-storage     D    0   349      2 0x00000000
> > 	Backtrace: 
> ...
> > 	[<bf1c7550>] (usb_sg_wait [usbcore]) from [<bf2bd618>] (usb_stor_bulk_transfer_sglist.part.2+0x80/0xdc [usb_storage]) r9:0001e000 r8:eca594ac r7:0001e000 r6:c0008200 r5:eca59514 r4:eca59488
> 
> It looks like there is a logical problem in the CMA allocator.  The
> call in usb_sg_wait() specifies GFP_NOIO, which is supposed to prevent
> allocations from blocking on any I/O operations.  Therefore we
> shouldn't be waiting for the CMA mutex.
> 

Right.

> Perhaps the CMA allocator needs to drop the mutex while doing 
> writebacks/flushes, or perhaps it needs to be reorganized some other 
> way.  I don't know anything about it.
> 
> Does the CMA code have any maintainers who might need to know about 
> this, or is it all handled by the MM maintainers?

I did not find maintainers neither for CMA nor MM.

That is why I have sent this mail to mm mailing list but to no one in
particular.

> 
> Alan Stern
> 

Thanks.

Regards,
Gael
