Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A47FA8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 16:57:40 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u20so18734708qtk.6
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 13:57:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y29sor18499981qvc.49.2018.12.17.13.57.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 13:57:39 -0800 (PST)
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
Date: Mon, 17 Dec 2018 13:57:37 -0800
MIME-Version: 1.0
In-Reply-To: <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Ga=c3=abl_PORTAY?= <gael.portay@collabora.com>, Alan Stern <stern@rowland.harvard.edu>
Cc: linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

On 12/17/18 10:29 AM, Gaël PORTAY wrote:
> Alan,
> 
> On Mon, Dec 17, 2018 at 10:45:17AM -0500, Alan Stern wrote:
>> On Sun, 16 Dec 2018, Gaël PORTAY wrote:
>> ...
>>
>>> The second task wants to writeback/flush the pages through USB, which, I
>>> assume, is due to the page migration. The usb-storage triggers a CMA allocation
>>> but get locked in cma_alloc since the first task hold the mutex (It is a FAT
>>> formatted partition, if it helps).
>>>
>>> 	usb-storage     D    0   349      2 0x00000000
>>> 	Backtrace:
>> ...
>>> 	[<bf1c7550>] (usb_sg_wait [usbcore]) from [<bf2bd618>] (usb_stor_bulk_transfer_sglist.part.2+0x80/0xdc [usb_storage]) r9:0001e000 r8:eca594ac r7:0001e000 r6:c0008200 r5:eca59514 r4:eca59488
>>
>> It looks like there is a logical problem in the CMA allocator.  The
>> call in usb_sg_wait() specifies GFP_NOIO, which is supposed to prevent
>> allocations from blocking on any I/O operations.  Therefore we
>> shouldn't be waiting for the CMA mutex.
>>
> 
> Right.
> 
>> Perhaps the CMA allocator needs to drop the mutex while doing
>> writebacks/flushes, or perhaps it needs to be reorganized some other
>> way.  I don't know anything about it.
>>
>> Does the CMA code have any maintainers who might need to know about
>> this, or is it all handled by the MM maintainers?
> 
> I did not find maintainers neither for CMA nor MM.
> 
> That is why I have sent this mail to mm mailing list but to no one in
> particular.
> 

Last time I looked at this, we needed the cma_mutex for serialization
so unless we want to rework that, I think we need to not use CMA in the
writeback case (i.e. GFP_IO).

The ARM dma layer uses gfpflags_allow_blocking to decide if it should
use CMA vs. the atomic pool:

static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
{
         return !!(gfp_flags & __GFP_DIRECT_RECLAIM);
}

That's not sufficient to cover the writeback case. This is
used in multiple DMA allocations (arm64 and intel-iommu at
first pass) so I think we need a new gfpflags_allow_writeback
for deciding if CMA should be used.

Thanks,
Laura
