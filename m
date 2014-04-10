Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 32C736B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:09:29 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so2867613eek.6
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 04:09:27 -0700 (PDT)
Received: from smtp-vbr8.xs4all.nl (smtp-vbr8.xs4all.nl. [194.109.24.28])
        by mx.google.com with ESMTPS id 49si5483727een.335.2014.04.10.04.09.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 04:09:26 -0700 (PDT)
Message-ID: <53467B7E.5060408@xs4all.nl>
Date: Thu, 10 Apr 2014 13:07:42 +0200
From: Hans Verkuil <hverkuil@xs4all.nl>
MIME-Version: 1.0
Subject: Re: [RFC] Helper to abstract vma handling in media layer
References: <1395085776-8626-1-git-send-email-jack@suse.cz> <53466C4A.2030107@samsung.com> <20140410103220.GB28404@quack.suse.cz>
In-Reply-To: <20140410103220.GB28404@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-media@vger.kernel.org, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, 'Tomasz Stanislawski' <t.stanislaws@samsung.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

On 04/10/14 12:32, Jan Kara wrote:
>   Hello,
> 
> On Thu 10-04-14 12:02:50, Marek Szyprowski wrote:
>> On 2014-03-17 20:49, Jan Kara wrote:
>>>   The following patch series is my first stab at abstracting vma handling
>> >from the various media drivers. After this patch set drivers have to know
>>> much less details about vmas, their types, and locking. My motivation for
>>> the series is that I want to change get_user_pages() locking and I want
>>> to handle subtle locking details in as few places as possible.
>>>
>>> The core of the series is the new helper get_vaddr_pfns() which is given a
>>> virtual address and it fills in PFNs into provided array. If PFNs correspond to
>>> normal pages it also grabs references to these pages. The difference from
>>> get_user_pages() is that this function can also deal with pfnmap, mixed, and io
>>> mappings which is what the media drivers need.
>>>
>>> The patches are just compile tested (since I don't have any of the hardware
>>> I'm afraid I won't be able to do any more testing anyway) so please handle
>>> with care. I'm grateful for any comments.
>>
>> Thanks for posting this series! I will check if it works with our
>> hardware soon.  This is something I wanted to introduce some time ago to
>> simplify buffer handling in dma-buf, but I had no time to start working.
>   Thanks for having a look in the series.
> 
>> However I would like to go even further with integration of your pfn
>> vector idea.  This structure looks like a best solution for a compact
>> representation of the memory buffer, which should be considered by the
>> hardware as contiguous (either contiguous in physical memory or mapped
>> contiguously into dma address space by the respective iommu). As you
>> already noticed it is widely used by graphics and video drivers.
>>
>> I would also like to add support for pfn vector directly to the
>> dma-mapping subsystem. This can be done quite easily (even with a
>> fallback for architectures which don't provide method for it). I will try
>> to prepare rfc soon.  This will finally remove the need for hacks in
>> media/v4l2-core/videobuf2-dma-contig.c
>   That would be a worthwhile thing to do. When I was reading the code this
> seemed like something which could be done but I delibrately avoided doing
> more unification than necessary for my purposes as I don't have any
> hardware to test and don't know all the subtleties in the code... BTW, is
> there some way to test the drivers without the physical video HW?

You can use the vivi driver (drivers/media/platform/vivi) for this.
However, while the vivi driver can import dma buffers it cannot export
them. If you want that, then you have to use this tree:

http://git.linuxtv.org/cgit.cgi/hverkuil/media_tree.git/log/?h=vb2-part4

Regards,

	Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
