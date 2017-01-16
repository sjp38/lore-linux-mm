Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3006B0069
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 17:59:39 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so268414519pfy.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 14:59:39 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id q7si1291891pfb.281.2017.01.16.14.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 14:59:37 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] Memory hotplug, ZONE_DEVICE, and the future of
 struct page
References: <CAPcyv4hWNL7=MmnUj65A+gz=eHAnUrVzqV+24QiNQDW--ag8WQ@mail.gmail.com>
 <729bbe0c-d305-f4bd-7fed-b937dafd16ef@linux.vnet.ibm.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <ff9d7b04-e13e-bc17-d95b-1e19dd172e69@nvidia.com>
Date: Mon, 16 Jan 2017 14:59:36 -0800
MIME-Version: 1.0
In-Reply-To: <729bbe0c-d305-f4bd-7fed-b937dafd16ef@linux.vnet.ibm.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-block@vger.kernel.org
Cc: Stephen Bates <sbates@raithlin.com>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>



On 01/16/2017 04:58 AM, Anshuman Khandual wrote:
> On 01/13/2017 04:13 AM, Dan Williams wrote:
>> Back when we were first attempting to support DMA for DAX mappings of
>> persistent memory the plan was to forgo 'struct page' completely and
>> develop a pfn-to-scatterlist capability for the dma-mapping-api. That
>> effort died in this thread:
>>
>>     https://lkml.org/lkml/2015/8/14/3
>>
>> ...where we learned that the dependencies on struct page for dma
>> mapping are deeper than a PFN_PHYS() conversion for some
>> architectures. That was the moment we pivoted to ZONE_DEVICE and
>> arranged for a 'struct page' to be available for any persistent memory
>> range that needs to be the target of DMA. ZONE_DEVICE enables any
>> device-driver that can target "System RAM" to also be able to target
>> persistent memory through a DAX mapping.
>>
>> Since that time the "page-less" DAX path has continued to mature [1]
>> without growing new dependencies on struct page, but at the same time
>> continuing to rely on ZONE_DEVICE to satisfy get_user_pages().
>>
>> Peer-to-peer DMA appears to be evolving from a niche embedded use case
>> to something general purpose platforms will need to comprehend. The
>> "map_peer_resource" [2] approach looks to be headed to the same
>> destination as the pfn-to-scatterlist effort. It's difficult to avoid
>> 'struct page' for describing DMA operations without custom driver
>> code.
>>
>> With that background, a statement and a question to discuss at LSF/MM:
>>
>> General purpose DMA, i.e. any DMA setup through the dma-mapping-api,
>> requires pfn_to_page() support across the entire physical address
>> range mapped.
>>
>> Is ZONE_DEVICE the proper vehicle for this? We've already seen that it
>> collides with platform alignment assumptions [3], and if there's a
>> wider effort to rework memory hotplug [4] it seems DMA support should
>> be part of the discussion.
>
> I had experimented with ZONE_DEVICE representation from migration point of
> view. Tried migration of both anonymous pages as well as file cache pages
> into and away from ZONE_DEVICE memory. Learned that the lack of 'page->lru'
> element in the struct page of the ZONE_DEVICE memory makes it difficult
> for it to represent file backed mapping in it's present form. But given

That reminds me: while testing out HMM in our device driver, we had some early difficulties with the 
LRU system (including pagevec) in general. For example, sometimes HMM was forced to say "I cannot 
migrate your page range, because a page is still on the very most recently used list". If the number 
of pages was very small, then *all* the pages might be on that list. :)  HMM avoids the problem by 
forcing it, but it reminds me that the LRU and pagevec were never really intended to intersect with 
device memory.

Another point that may seem unrelated at first: using struct pages and pfns to back device memory is 
still under discussion:

    a)  Need to avoid using pfns that can ever be needed for other hotpluggable memory

    b) *Very* hard to justify adding any fields to struct page, or flags for it, of course.

...but given this new-ish requirement to support these types of devices, maybe (b) actually makes 
sense. Something to discuss.

thanks,
John Hubbard
NVIDIA


> that ZONE_DEVICE was created to enable direct mapping (DAX) bypassing page
> cache, it came as no surprise. My objective has been how ZONE_DEVICE can
> accommodate movable coherent device memory. In our HMM discussions I had
> brought to the attention how ZONE_DEVICE going forward should evolve to
> represent all these three types of device memory.
>
> * Unmovable addressable device memory   (persistent memory)
> * Movable addressable device memory     (similar memory represented as CDM)
> * Movable un-addressable device memory  (similar memory represented as HMM)
>
> I would like to attend to discuss on the road map for ZONE_DEVICE, struct
> pages and device memory in general.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
