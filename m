Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 206D16B0006
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:38:36 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u68-v6so5166755qku.5
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 12:38:36 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id w31-v6si4610888qtg.3.2018.07.27.12.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 12:38:34 -0700 (PDT)
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
 <20180726194209.GB12992@bombadil.infradead.org>
 <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
 <20180727000708.GA785@bombadil.infradead.org>
 <cae33099-3147-5014-ab4e-c22a4d66dc49@cybernetics.com>
 <20180727152322.GB13348@bombadil.infradead.org>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <acdc2e32-466c-61d3-145f-80bfba2c6739@cybernetics.com>
Date: Fri, 27 Jul 2018 15:38:32 -0400
MIME-Version: 1.0
In-Reply-To: <20180727152322.GB13348@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 07/27/2018 11:23 AM, Matthew Wilcox wrote:
> On Fri, Jul 27, 2018 at 09:23:30AM -0400, Tony Battersby wrote:
>> On 07/26/2018 08:07 PM, Matthew Wilcox wrote:
>>> If you're up for more major surgery, then I think we can put all the
>>> information currently stored in dma_page into struct page.  Something
>>> like this:
>>>
>>> +++ b/include/linux/mm_types.h
>>> @@ -152,6 +152,12 @@ struct page {
>>>                         unsigned long hmm_data;
>>>                         unsigned long _zd_pad_1;        /* uses mapping */
>>>                 };
>>> +               struct {        /* dma_pool pages */
>>> +                       struct list_head dma_list;
>>> +                       unsigned short in_use;
>>> +                       unsigned short offset;
>>> +                       dma_addr_t dma;
>>> +               };
>>>  
>>>                 /** @rcu_head: You can use this to free a page by RCU. */
>>>                 struct rcu_head rcu_head;
>>>
>>> page_list -> dma_list
>>> vaddr goes away (page_to_virt() exists)
>>> dma -> dma
>>> in_use and offset shrink from 4 bytes to 2.
>>>
>>> Some 32-bit systems have a 64-bit dma_addr_t, and on those systems,
>>> this will be 8 + 2 + 2 + 8 = 20 bytes.  On 64-bit systems, it'll be
>>> 16 + 2 + 2 + 4 bytes of padding + 8 = 32 bytes (we have 40 available).
>>>
>>>
>> offset at least needs more bits, since allocations can be multi-page.A 
> Ah, rats.  That means we have to use the mapcount union too:
>

Actually, on second thought, if I understand it correctly, a multi-page
allocation will never be split up and returned as multiple
sub-allocations, so the offset shouldn't be needed for that case.A  The
offset should only be needed when splitting a PAGE_SIZE-allocation into
smaller sub-allocations.A  The current code uses the offset
unconditionally though, so it would need major changes to remove the
dependence.A  So a 16-bit offset might work.

As for sanity checking, I suppose having the dma address in the page
could provide something for dma_pool_free() to check against (in fact it
is already there under DMAPOOL_DEBUG).

But the bigger problem is that my first patch adds another list_head to
the dma_page for the avail_page_link to make allocations faster.A  I
suppose we could make the lists singly-linked instead of doubly-linked
to save space.

Wouldn't using the mapcount union make it problematic for userspace to
mmap() the returned DMA buffers?A  I am not sure if any drivers allow
that to be done or not.A  I have heard of drivers in userspace, drivers
with DMA ring buffers, etc.A  I don't want to audit the whole kernel tree
to know if it would be safe.A  As you have seen, at least mpt3sas is
doing unexpected things with dma pools.

So maybe it could be done, but you are right, it would involve major
surgery.A  My current in-development patch to implement your intial
suggestion is pretty small and it works.A  So I'm not sure if I want to
take it further or not.A  Lots of other things to do...
