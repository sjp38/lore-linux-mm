Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A83A8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 14:29:45 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id e17so8462741wrw.13
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 11:29:45 -0800 (PST)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id j2si19081780wrv.348.2018.12.27.11.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Dec 2018 11:29:43 -0800 (PST)
Date: Thu, 27 Dec 2018 14:29:40 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20181227192940.77p5gj3garpgahnm@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <593e3757-6f50-22bc-d5a9-ea5819b9a63d@oracle.com>
 <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

Laura, Mike,

On Tue, Dec 18, 2018 at 01:14:42PM -0800, Laura Abbott wrote:
> On 12/18/18 11:42 AM, Mike Kravetz wrote:
> > On 12/17/18 1:57 PM, Laura Abbott wrote:
> > > On 12/17/18 10:29 AM, Ga�l PORTAY wrote:
> > > > Alan,
> > > > 
> > > > On Mon, Dec 17, 2018 at 10:45:17AM -0500, Alan Stern wrote:
> > > > > On Sun, 16 Dec 2018, Ga�l PORTAY wrote:
> > > > > ...
> > > > > 
> > > > > > The second task wants to writeback/flush the pages through USB, which, I
> > > > > > assume, is due to the page migration. The usb-storage triggers a CMA allocation
> > > > > > but get locked in cma_alloc since the first task hold the mutex (It is a FAT
> > > > > > formatted partition, if it helps).
> > > > > > 
> > > > > >      usb-storage     D    0   349      2 0x00000000
> > > > > >      Backtrace:
> > > > > ...
> > > > > >      [<bf1c7550>] (usb_sg_wait [usbcore]) from [<bf2bd618>]
> > > > > > (usb_stor_bulk_transfer_sglist.part.2+0x80/0xdc [usb_storage]) r9:0001e000
> > > > > > r8:eca594ac r7:0001e000 r6:c0008200 r5:eca59514 r4:eca59488
> > > > > 
> > > > > It looks like there is a logical problem in the CMA allocator.  The
> > > > > call in usb_sg_wait() specifies GFP_NOIO, which is supposed to prevent
> > > > > allocations from blocking on any I/O operations.  Therefore we
> > > > > shouldn't be waiting for the CMA mutex.
> > > > > 
> > > > 
> > > > Right.
> > > > 
> > > > > Perhaps the CMA allocator needs to drop the mutex while doing
> > > > > writebacks/flushes, or perhaps it needs to be reorganized some other
> > > > > way.  I don't know anything about it.
> > > > > 
> > > > > Does the CMA code have any maintainers who might need to know about
> > > > > this, or is it all handled by the MM maintainers?
> > > > 
> > > > I did not find maintainers neither for CMA nor MM.
> > > > 
> > > > That is why I have sent this mail to mm mailing list but to no one in
> > > > particular.
> > > > 
> > > 
> > > Last time I looked at this, we needed the cma_mutex for serialization
> > > so unless we want to rework that, I think we need to not use CMA in the
> > > writeback case (i.e. GFP_IO).
> > 
> > I am wondering if we still need to hold the cma_mutex while calling
> > alloc_contig_range().  Looking back at the history, it appears that
> > the reason for holding the mutex was to prevent two threads from operating
> > on the same pageblock.
> > 
> > Commit 2c7452a075d4 ("mm/page_isolation.c: make start_isolate_page_range()
> > fail if already isolated") will cause alloc_contig_range to return EBUSY
> > if two callers are attempting to operate on the same pageblock.  This was
> > added because memory hotplug as well as gigantac page allocation call
> > alloc_contig_range and could conflict with each other or cma.   cma_alloc
> > has logic to retry if EBUSY is returned.  Although, IIUC it assumes the
> > EBUSY is the result of specific pages being busy as opposed to someone
> > else operating on the pageblock.  Therefore, the retry logic to 'try a
> > different set of pages' is not what one  would/should attempt in the case
> > someone else is operating on the pageblock.
> > 
> > Would it be possible or make sense to remove the mutex and retry when
> > EBUSY?  Or, am I missing some other reason for holding the mutex.
> > 
> 
> I had forgotten that start_isolate_page_range had been updated to
> return -EBUSY. It looks like we would need to update
> the callback for migrate_pages in __alloc_contig_migrate_range
> since alloc_migrate_target by default will use __GFP_IO.
> So I _think_ if we update that to honor GFP_NOIO we could
> remove the mutex assuming the rest of migrate_pages honors
> it properly.
> 

I would be pleased to help and test things.

I had a look to the code but I do not know how to hack the callback.

Laura: Could you tell me more about how to update the callback to take
the GFP_NOIO flag into consideration properly?

Regards,
Gael
