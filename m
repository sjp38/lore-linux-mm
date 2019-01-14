Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id D72A98E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 18:47:16 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id n8so391717ybm.19
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:47:16 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 66si1122865ybb.83.2019.01.14.15.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 15:47:15 -0800 (PST)
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <593e3757-6f50-22bc-d5a9-ea5819b9a63d@oracle.com>
 <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
 <20190107181355.qqbdc6pguq4w3z6u@archlinux.localdomain>
 <302af0f5-bc42-dcb2-01e3-86865e5581e2@oracle.com>
 <20190111135538.iv3vvashdnis5b2s@archlinux.localdomain>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <0a7c10a4-25dc-84a7-744c-d088c4d84e49@oracle.com>
Date: Mon, 14 Jan 2019 15:47:08 -0800
MIME-Version: 1.0
In-Reply-To: <20190111135538.iv3vvashdnis5b2s@archlinux.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Ga=c3=abl_PORTAY?= <gael.portay@collabora.com>
Cc: Laura Abbott <labbott@redhat.com>, Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

On 1/11/19 5:55 AM, Gaël PORTAY wrote:
> On Mon, Jan 07, 2019 at 06:06:21PM -0800, Mike Kravetz wrote:
>> On 1/7/19 10:13 AM, Gaël PORTAY wrote:
>>> (...)
>>> I have also removed the mutex (start_isolate_page_range retunrs -EBUSY),
>>> and it worked (in my case).
>>>
>>> But I did not do the proper magic because I am not sure of what should
>>> be done and how: -EBUSY is not handled and __GFP_NOIO is not honored. 
>>
>> If we remove the mutex, I am pretty sure we would want to distinguish
>> between the (at least) two types of _EBUSY that can be returned by
>> alloc_contig_range().  Seems that the retry logic should be different if
>> a page block is busy as opposed to pages within the range.

Hello Gael,

I spent some time looking into removing cma_mutex.  My initial statement
that it is no longer absolutely necessary is correct.  This is because the
underlying code will not allow two threads to work on same pageblock.

However, removing the mutex causes issues.  If we remove the mutex, then
alloc_contig_range() will return -EBUSY if another thread is operating
on any of the pageblocks in the range.  We could make alloc_contig_range
distinguish between this and the existing -EBUSY case caused by the inability
to migrate pages in the range.  Even if we do this, we need to determine
what should happen if alloc_contig_range fails for this reason.  I can only
think of a few options:
1) Immediately fail the cma_alloc request.  The problem with doing this is
   that it would cause a regression.  Currently, two threads can call
   cma_alloc with ranges that touch the same pageblock.  With the mutex in
   place, the threads will wait for each other to finish with the pageblock.
   Without it, we return an error to one caller where it previously would
   have succeeded.  So, this approach is unacceptable.
2) Notice this new condition and 'retry'.  In theory this sounds possible.
   However, we do not know how long another thread will keep the pageblock(s)
   in question isolated.  It could be quite a long time depending on the
   what the other thread is trying to do.  We really do not want to go into
   a tight loop retrying.  Adding 'delays' between retrys seems like the
   wrong thing to do for a memory allocator.  So, I think this option is out.
3) In some cases, it might be possible to 'intelligently retry' with a
   range that does not touch busy pageblocks.  However, this is highly
   dependent on the cma area and size of allocation.  It may not always be
   possible and is not a suitable option.

Bottom line is that I can not think of a good way to remove cma_mutex without
possibly introducing some other issue.

It appears that you have already found a workaround for the issue you were
seeing.  Is this correct?  If so, I suggest we not go down the path of trying
to eliminate cma_mutex right now.  Or, perhaps someone else has other
suggestions.
-- 
Mike Kravetz
