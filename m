Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1B1B8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 14:42:22 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x14so11656226ywg.18
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 11:42:22 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id o8si9884776ywb.348.2018.12.18.11.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 11:42:21 -0800 (PST)
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <593e3757-6f50-22bc-d5a9-ea5819b9a63d@oracle.com>
Date: Tue, 18 Dec 2018 11:42:12 -0800
MIME-Version: 1.0
In-Reply-To: <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, =?UTF-8?Q?Ga=c3=abl_PORTAY?= <gael.portay@collabora.com>, Alan Stern <stern@rowland.harvard.edu>
Cc: linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

On 12/17/18 1:57 PM, Laura Abbott wrote:
> On 12/17/18 10:29 AM, Gaël PORTAY wrote:
>> Alan,
>>
>> On Mon, Dec 17, 2018 at 10:45:17AM -0500, Alan Stern wrote:
>>> On Sun, 16 Dec 2018, Gaël PORTAY wrote:
>>> ...
>>>
>>>> The second task wants to writeback/flush the pages through USB, which, I
>>>> assume, is due to the page migration. The usb-storage triggers a CMA allocation
>>>> but get locked in cma_alloc since the first task hold the mutex (It is a FAT
>>>> formatted partition, if it helps).
>>>>
>>>>     usb-storage     D    0   349      2 0x00000000
>>>>     Backtrace:
>>> ...
>>>>     [<bf1c7550>] (usb_sg_wait [usbcore]) from [<bf2bd618>]
>>>> (usb_stor_bulk_transfer_sglist.part.2+0x80/0xdc [usb_storage]) r9:0001e000
>>>> r8:eca594ac r7:0001e000 r6:c0008200 r5:eca59514 r4:eca59488
>>>
>>> It looks like there is a logical problem in the CMA allocator.  The
>>> call in usb_sg_wait() specifies GFP_NOIO, which is supposed to prevent
>>> allocations from blocking on any I/O operations.  Therefore we
>>> shouldn't be waiting for the CMA mutex.
>>>
>>
>> Right.
>>
>>> Perhaps the CMA allocator needs to drop the mutex while doing
>>> writebacks/flushes, or perhaps it needs to be reorganized some other
>>> way.  I don't know anything about it.
>>>
>>> Does the CMA code have any maintainers who might need to know about
>>> this, or is it all handled by the MM maintainers?
>>
>> I did not find maintainers neither for CMA nor MM.
>>
>> That is why I have sent this mail to mm mailing list but to no one in
>> particular.
>>
> 
> Last time I looked at this, we needed the cma_mutex for serialization
> so unless we want to rework that, I think we need to not use CMA in the
> writeback case (i.e. GFP_IO).

I am wondering if we still need to hold the cma_mutex while calling
alloc_contig_range().  Looking back at the history, it appears that
the reason for holding the mutex was to prevent two threads from operating
on the same pageblock.

Commit 2c7452a075d4 ("mm/page_isolation.c: make start_isolate_page_range()
fail if already isolated") will cause alloc_contig_range to return EBUSY
if two callers are attempting to operate on the same pageblock.  This was
added because memory hotplug as well as gigantac page allocation call
alloc_contig_range and could conflict with each other or cma.   cma_alloc
has logic to retry if EBUSY is returned.  Although, IIUC it assumes the
EBUSY is the result of specific pages being busy as opposed to someone
else operating on the pageblock.  Therefore, the retry logic to 'try a
different set of pages' is not what one  would/should attempt in the case
someone else is operating on the pageblock.

Would it be possible or make sense to remove the mutex and retry when
EBUSY?  Or, am I missing some other reason for holding the mutex.
-- 
Mike Kravetz
