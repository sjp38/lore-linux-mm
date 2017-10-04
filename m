Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC0956B0261
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 13:36:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 43so11306128qtr.6
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 10:36:01 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y40si76155qtj.293.2017.10.04.10.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 10:36:00 -0700 (PDT)
Subject: Re: [RFC] mmap(MAP_CONTIG)
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <97c81533-5206-b130-1aeb-c5b9bfd93287@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c0f5808f-3ba7-4737-b0e1-b2bfddf9384c@oracle.com>
Date: Wed, 4 Oct 2017 10:35:52 -0700
MIME-Version: 1.0
In-Reply-To: <97c81533-5206-b130-1aeb-c5b9bfd93287@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>

On 10/04/2017 06:49 AM, Anshuman Khandual wrote:
> On 10/04/2017 05:26 AM, Mike Kravetz wrote:
>> At Plumbers this year, Guy Shattah and Christoph Lameter gave a presentation
>> titled 'User space contiguous memory allocation for DMA' [1].  The slides
>> point out the performance benefits of devices that can take advantage of
>> larger physically contiguous areas.
>>
>> When such physically contiguous allocations are done today, they are done
>> within drivers themselves in an ad-hoc manner.  In addition to allocations
>> for DMA, allocations of this type are also performed for buffers used by
>> coprocessors and other acceleration engines.
> 
> Right.
> 
>>
>> As mentioned in the presentation, posix specifies an interface to obtain
>> physically contiguous memory.  This is via typed memory objects as described
>> in the posix_typed_mem_open() man page.  Since Linux today does not follow
>> the posix typed memory object model, adding infrastructure for contiguous
>> memory allocations seems to be overkill.  Instead, a proposal was suggested
>> to add support via a mmap flag: MAP_CONTIG.
> 
> Right.
> 
>>
>> mmap(MAP_CONTIG) would have the following semantics:
>> - The entire mapping (length size) would be backed by physically contiguous
>>   pages.
>> - If 'length' physically contiguous pages can not be allocated, then mmap
>>   will fail.
>> - MAP_CONTIG only works with MAP_ANONYMOUS mappings.
>> - MAP_CONTIG will lock the associated pages in memory.  As such, the same
>>   privileges and limits that apply to mlock will also apply to MAP_CONTIG.
>> - A MAP_CONTIG mapping can not be expanded.
> 
> Why ? May be we have memory around the edge of the existing mapping. Why
> give up before trying ?

Just a simplification.  If not to complicated, we could add support for
expansion.  But, it may not be worth the cost and I do not know if there
would be any real use cases.

>> - At fork time, private MAP_CONTIG mappings will be converted to regular
>>   (non-MAP_CONTIG) mapping in the child.  As such a COW fault in the child
>>   will not require a contiguous allocation.
> 
> Makes sense but need to be documented as the child still knows that the buffer
> came from a mmap(MAP_CONTIG) call in the parent.
> 
>>
>> Some implementation considerations:
>> - alloc_contig_range() or similar will be used for allocations larger
>>   than MAX_ORDER.
> 
> As I had also mentioned during the presentation at Plumbers, there should be
> a fallback approach while attempting to allocate the contiguous memory.
> 
> - If order < MAX_ORDER -> alloc_pages()
> - If order > MAX_ORDER -> alloc_contig_range()
> - If alloc_contig_range() fails attempt a CMA based allocation scheme
>   The CMA area should have been initialized at the boot exclusively for
>   this purpose (may be with a CONFIG option if some one wants to go for
>   this fallback at all) and use cma_alloc() on that area when we need
>   to service MAP_CONTIG requests.

I am not sure about the use of CMA and requiring admin setup.  It is
something that can be considered.  However, I suspect people would want
to avoid admin interaction/requirements if possible.

>> - MAP_CONTIG should imply MAP_POPULATE.  At mmap time, all pages for the
>>   mapping must be 'pre-allocated', and they can only be used for the mapping,
>>   so it makes sense to 'fault in' all pages.
> 
> 
>> - Using 'pre-allocated' pages in the fault paths may be intrusive.
> 
> But we have already faulted in all of them for the mapping and they
> are also locked. Hence there should not be any page faults any more
> for the VMA. Am I missing something here ?

I was referring to the action of pre-populating the mapping.  Today that
is done via the normal fault paths.  So, if we use this same scheme for
MAP_CONTIG, the fault paths would need to know about pre-allocated pages.

Sorry for not being more clear as that may have been a source of confusion.

>> - We need to keep keep track of those pre-allocated pages until the vma is
>>   tore down, especially if free_contig_range() must be called
> 
> Right, probably tracking them as part of the vm_area_struct itself. 
> 
>>
>> Thoughts?
>> - Is such an interface useful?
>> - Any other ideas on how to achieve the same functionality?
>> - Any thoughts on implementation?
>>
>> I have started down the path of pre-allocating contiguous pages at mmap
>> time and hanging those off the vma(vm_private_data) with some kludges to
>> use the pages at fault time.  It is really ugly, which is why I am not
>> sharing the code.  Hoping for some comments/suggestions.
> 
> I am still wondering why wait till fault time not pre fault all of them
> and populate the page tables.

Yes, that is the idea.  I just did not state clearly above.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
