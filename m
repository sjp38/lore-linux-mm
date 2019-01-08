Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5188E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 21:06:31 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id p139so1179322yba.1
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 18:06:31 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g16si43546523ywk.89.2019.01.07.18.06.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 18:06:30 -0800 (PST)
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <593e3757-6f50-22bc-d5a9-ea5819b9a63d@oracle.com>
 <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
 <20190107181355.qqbdc6pguq4w3z6u@archlinux.localdomain>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <302af0f5-bc42-dcb2-01e3-86865e5581e2@oracle.com>
Date: Mon, 7 Jan 2019 18:06:21 -0800
MIME-Version: 1.0
In-Reply-To: <20190107181355.qqbdc6pguq4w3z6u@archlinux.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Ga=c3=abl_PORTAY?= <gael.portay@collabora.com>, Laura Abbott <labbott@redhat.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

On 1/7/19 10:13 AM, Gaël PORTAY wrote:
> On Tue, Dec 18, 2018 at 01:14:42PM -0800, Laura Abbott wrote:
>> On 12/18/18 11:42 AM, Mike Kravetz wrote:
>>> On 12/17/18 1:57 PM, Laura Abbott wrote:
>>> I am wondering if we still need to hold the cma_mutex while calling
>>> alloc_contig_range().  Looking back at the history, it appears that
>>> the reason for holding the mutex was to prevent two threads from operating
>>> on the same pageblock.
>>>
>>> Commit 2c7452a075d4 ("mm/page_isolation.c: make start_isolate_page_range()
>>> fail if already isolated") will cause alloc_contig_range to return EBUSY
>>> if two callers are attempting to operate on the same pageblock.  This was
>>> added because memory hotplug as well as gigantac page allocation call
>>> alloc_contig_range and could conflict with each other or cma.   cma_alloc
>>> has logic to retry if EBUSY is returned.  Although, IIUC it assumes the
>>> EBUSY is the result of specific pages being busy as opposed to someone
>>> else operating on the pageblock.  Therefore, the retry logic to 'try a
>>> different set of pages' is not what one  would/should attempt in the case
>>> someone else is operating on the pageblock.
>>>
>>> Would it be possible or make sense to remove the mutex and retry when
>>> EBUSY?  Or, am I missing some other reason for holding the mutex.
>>>
>>
>> I had forgotten that start_isolate_page_range had been updated to
>> return -EBUSY. It looks like we would need to update
>> the callback for migrate_pages in __alloc_contig_migrate_range
>> since alloc_migrate_target by default will use __GFP_IO.
>> So I _think_ if we update that to honor GFP_NOIO we could
>> remove the mutex assuming the rest of migrate_pages honors
>> it properly.
>>
> 
> I have also removed the mutex (start_isolate_page_range retunrs -EBUSY),
> and it worked (in my case).
> 
> But I did not do the proper magic because I am not sure of what should
> be done and how: -EBUSY is not handled and __GFP_NOIO is not honored. 

If we remove the mutex, I am pretty sure we would want to distinguish
between the (at least) two types of _EBUSY that can be returned by
alloc_contig_range().  Seems that the retry logic should be different if
a page block is busy as opposed to pages within the range.

I'm busy with other things, but could get to this later this week or early
next week unless someone else has the time.
-- 
Mike Kravetz
