Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4B36B0032
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 02:13:53 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so23761481pad.7
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 23:13:52 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id vf8si4541171pbc.191.2015.01.27.23.13.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 27 Jan 2015 23:13:52 -0800 (PST)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NIV00162LF05330@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 28 Jan 2015 16:13:48 +0900 (KST)
Message-id: <54C88C3C.3010604@samsung.com>
Date: Wed, 28 Jan 2015 16:14:04 +0900
From: Heesub Shin <heesub.shin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC PATCH 0/9] mm/zbud: support highmem pages
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
 <20141104163343.GA20974@cerebellum.variantweb.net>
 <20150127202440.GA13103@cerebellum.variantweb.net>
In-reply-to: <20150127202440.GA13103@cerebellum.variantweb.net>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>



On 01/28/2015 05:24 AM, Seth Jennings wrote:
> On Tue, Nov 04, 2014 at 10:33:43AM -0600, Seth Jennings wrote:
>> On Tue, Oct 14, 2014 at 08:59:19PM +0900, Heesub Shin wrote:
>>> zbud is a memory allocator for storing compressed data pages. It keeps
>>> two data objects of arbitrary size on a single page. This simple design
>>> provides very deterministic behavior on reclamation, which is one of
>>> reasons why zswap selected zbud as a default allocator over zsmalloc.
>>>
>>> Unlike zsmalloc, however, zbud does not support highmem. This is
>>> problomatic especially on 32-bit machines having relatively small
>>> lowmem. Compressing anonymous pages from highmem and storing them into
>>> lowmem could eat up lowmem spaces.
>>>
>>> This limitation is due to the fact that zbud manages its internal data
>>> structures on zbud_header which is kept in the head of zbud_page. For
>>> example, zbud_pages are tracked by several lists and have some status
>>> information, which are being referenced at any time by the kernel. Thus,
>>> zbud_pages should be allocated on a memory region directly mapped,
>>> lowmem.
>>>
>>> After some digging out, I found that internal data structures of zbud
>>> can be kept in the struct page, the same way as zsmalloc does. So, this
>>> series moves out all fields in zbud_header to struct page. Though it
>>> alters quite a lot, it does not add any functional differences except
>>> highmem support. I am afraid that this kind of modification abusing
>>> several fields in struct page would be ok.
>>
>> Hi Heesub,
>>
>> Sorry for the very late reply.  The end of October was very busy for me.
>>
>> A little history on zbud.  I didn't put the metadata in the struct
>> page, even though I knew that was an option since we had done it with
>> zsmalloc. At the time, Andrew Morton had concerns about memmap walkers
>> getting messed up with unexpected values in the struct page fields.  In
>> order to smooth zbud's acceptance, I decided to store the metadata
>> inline in the page itself.
>>
>> Later, zsmalloc eventually got accepted, which basically gave the
>> impression that putting the metadata in the struct page was acceptable.
>>
>> I have recently been looking at implementing compaction for zsmalloc,
>> but having the metadata in the struct page and having the handle
>> directly encode the PFN and offset of the data block prevents
>> transparent relocation of the data. zbud has a similar issue as it
>> currently encodes the page address in the handle returned to the user
>> (also the limitation that is preventing use of highmem pages).
>>
>> I would like to implement compaction for zbud too and moving the
>> metadata into the struct page is going to work against that. In fact,
>> I'm looking at the option of converting the current zbud_header into a
>> per-allocation metadata structure, which would provide a layer of
>> indirection between zbud and the user, allowing for transparent
>> relocation and compaction.
>
> I had some downtime and started thinking about this again today (after
> 3 months).
>
> Upon further reflection, I really like this and don't think that it
> inhibits introducing compaction later.
>
> There are just a few places that look messy or problematic to me:
>
> 1. the use of page->private and masking the number of chunks for both
> buddies into it (see suggestion for overlay struct below)
> 2. the use of the second double word &page->index to store a list_head
>
> #2 might be problematic because, IIRC, memmap walkers will check _count
> (or _mapcount).  I think we ran into this in zsmalloc.
>
> Initially, when working on zsmalloc, I just created a structure that
> overlaid the struct page in the memmap, reserving the flags and _count
> areas, so that I wouldn't have to be bound by the field names/boundaries
> in the struct page.
>
> IIRC, Andrew was initially against that, but he was also against the
> whole idea of using the struct page fields for random stuff... I that
> ended up being accepted.
>
> This code looks really good!  I think with a little cleanup and finding
> a way to steer clear of using the _count part of the structure, this
> will be great.

Thanks for your comments! I will try to address problems you pointed and 
post a new patchset hopefully soon.

regards,
heesub

>
> Sorry for dismissing it earlier.  Didn't give it enough credit.
>
> Thanks,
> Seth
>
>>
>> However, I do like the part about letting zbud use highmem pages.
>>
>> I have something in mind that would allow highmem pages _and_ move
>> toward something that would support compaction.  I'll see if I can put
>> it into code today.
>>
>> Thanks,
>> Seth
>>
>>>
>>> Heesub Shin (9):
>>>    mm/zbud: tidy up a bit
>>>    mm/zbud: remove buddied list from zbud_pool
>>>    mm/zbud: remove lru from zbud_header
>>>    mm/zbud: remove first|last_chunks from zbud_header
>>>    mm/zbud: encode zbud handle using struct page
>>>    mm/zbud: remove list_head for buddied list from zbud_header
>>>    mm/zbud: drop zbud_header
>>>    mm/zbud: allow clients to use highmem pages
>>>    mm/zswap: use highmem pages for compressed pool
>>>
>>>   mm/zbud.c  | 244 ++++++++++++++++++++++++++++++-------------------------------
>>>   mm/zswap.c |   4 +-
>>>   2 files changed, 121 insertions(+), 127 deletions(-)
>>>
>>> --
>>> 1.9.1
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
