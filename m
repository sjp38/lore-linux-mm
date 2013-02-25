Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 99C5A6B0006
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 10:18:50 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Feb 2013 10:18:49 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id AE3C638C801F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 10:18:43 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1PFIeYS210142
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 10:18:41 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1PFIOCc026038
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 08:18:26 -0700
Message-ID: <512B80B6.6090401@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2013 09:18:14 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 2/8] zsmalloc: add documentation
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-3-git-send-email-sjenning@linux.vnet.ibm.com> <511F254D.2010909@gmail.com> <51227DF4.9020900@linux.vnet.ibm.com> <5125DFAA.4050706@gmail.com> <5126423F.7040705@linux.vnet.ibm.com> <5126DE7B.2010203@gmail.com> <5127DD01.4080003@linux.vnet.ibm.com> <512960CD.4080008@gmail.com>
In-Reply-To: <512960CD.4080008@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/23/2013 06:37 PM, Ric Mason wrote:
> On 02/23/2013 05:02 AM, Seth Jennings wrote:
>> On 02/21/2013 08:56 PM, Ric Mason wrote:
>>> On 02/21/2013 11:50 PM, Seth Jennings wrote:
>>>> On 02/21/2013 02:49 AM, Ric Mason wrote:
>>>>> On 02/19/2013 03:16 AM, Seth Jennings wrote:
>>>>>> On 02/16/2013 12:21 AM, Ric Mason wrote:
>>>>>>> On 02/14/2013 02:38 AM, Seth Jennings wrote:
>>>>>>>> This patch adds a documentation file for zsmalloc at
>>>>>>>> Documentation/vm/zsmalloc.txt
>>>>>>>>
>>>>>>>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>>>>>>> ---
>>>>>>>>      Documentation/vm/zsmalloc.txt |   68
>>>>>>>> +++++++++++++++++++++++++++++++++++++++++
>>>>>>>>      1 file changed, 68 insertions(+)
>>>>>>>>      create mode 100644 Documentation/vm/zsmalloc.txt
>>>>>>>>
>>>>>>>> diff --git a/Documentation/vm/zsmalloc.txt
>>>>>>>> b/Documentation/vm/zsmalloc.txt
>>>>>>>> new file mode 100644
>>>>>>>> index 0000000..85aa617
>>>>>>>> --- /dev/null
>>>>>>>> +++ b/Documentation/vm/zsmalloc.txt
>>>>>>>> @@ -0,0 +1,68 @@
>>>>>>>> +zsmalloc Memory Allocator
>>>>>>>> +
>>>>>>>> +Overview
>>>>>>>> +
>>>>>>>> +zmalloc a new slab-based memory allocator,
>>>>>>>> +zsmalloc, for storing compressed pages.  It is designed for
>>>>>>>> +low fragmentation and high allocation success rate on
>>>>>>>> +large object, but <= PAGE_SIZE allocations.
>>>>>>>> +
>>>>>>>> +zsmalloc differs from the kernel slab allocator in two primary
>>>>>>>> +ways to achieve these design goals.
>>>>>>>> +
>>>>>>>> +zsmalloc never requires high order page allocations to back
>>>>>>>> +slabs, or "size classes" in zsmalloc terms. Instead it allows
>>>>>>>> +multiple single-order pages to be stitched together into a
>>>>>>>> +"zspage" which backs the slab.  This allows for higher
>>>>>>>> allocation
>>>>>>>> +success rate under memory pressure.
>>>>>>>> +
>>>>>>>> +Also, zsmalloc allows objects to span page boundaries within the
>>>>>>>> +zspage.  This allows for lower fragmentation than could be had
>>>>>>>> +with the kernel slab allocator for objects between PAGE_SIZE/2
>>>>>>>> +and PAGE_SIZE.  With the kernel slab allocator, if a page
>>>>>>>> compresses
>>>>>>>> +to 60% of it original size, the memory savings gained through
>>>>>>>> +compression is lost in fragmentation because another object of
>>>>>>>> +the same size can't be stored in the leftover space.
>>>>>>>> +
>>>>>>>> +This ability to span pages results in zsmalloc allocations not
>>>>>>>> being
>>>>>>>> +directly addressable by the user.  The user is given an
>>>>>>>> +non-dereferencable handle in response to an allocation request.
>>>>>>>> +That handle must be mapped, using zs_map_object(), which returns
>>>>>>>> +a pointer to the mapped region that can be used.  The mapping is
>>>>>>>> +necessary since the object data may reside in two different
>>>>>>>> +noncontigious pages.
>>>>>>> Do you mean the reason of  to use a zsmalloc object must map after
>>>>>>> malloc is object data maybe reside in two different nocontiguous
>>>>>>> pages?
>>>>>> Yes, that is one reason for the mapping.  The other reason (more
>>>>>> of an
>>>>>> added bonus) is below.
>>>>>>
>>>>>>>> +
>>>>>>>> +For 32-bit systems, zsmalloc has the added benefit of being
>>>>>>>> +able to back slabs with HIGHMEM pages, something not possible
>>>>>>> What's the meaning of "back slabs with HIGHMEM pages"?
>>>>>> By HIGHMEM, I'm referring to the HIGHMEM memory zone on 32-bit
>>>>>> systems
>>>>>> with larger that 1GB (actually a little less) of RAM.  The upper
>>>>>> 3GB
>>>>>> of the 4GB address space, depending on kernel build options, is not
>>>>>> directly addressable by the kernel, but can be mapped into the
>>>>>> kernel
>>>>>> address space with functions like kmap() or kmap_atomic().
>>>>>>
>>>>>> These pages can't be used by slab/slub because they are not
>>>>>> continuously mapped into the kernel address space.  However, since
>>>>>> zsmalloc requires a mapping anyway to handle objects that span
>>>>>> non-contiguous page boundaries, we do the kernel mapping as part of
>>>>>> the process.
>>>>>>
>>>>>> So zspages, the conceptual slab in zsmalloc backed by single-order
>>>>>> pages can include pages from the HIGHMEM zone as well.
>>>>> Thanks for your clarify,
>>>>>    http://lwn.net/Articles/537422/, your article about zswap in lwn.
>>>>>    "Additionally, the kernel slab allocator does not allow
>>>>> objects that
>>>>> are less
>>>>> than a page in size to span a page boundary. This means that if an
>>>>> object is
>>>>> PAGE_SIZE/2 + 1 bytes in size, it effectively use an entire page,
>>>>> resulting in
>>>>> ~50% waste. Hense there are *no kmalloc() cache size* between
>>>>> PAGE_SIZE/2 and
>>>>> PAGE_SIZE."
>>>>> Are your sure? It seems that kmalloc cache support big size, your
>>>>> can
>>>>> check in
>>>>> include/linux/kmalloc_sizes.h
>>>> Yes, kmalloc can allocate large objects > PAGE_SIZE, but there are no
>>>> cache sizes _between_ PAGE_SIZE/2 and PAGE_SIZE.  For example, on a
>>>> system with 4k pages, there are no caches between kmalloc-2048 and
>>>> kmalloc-4096.
>>> kmalloc object > PAGE_SIZE/2 or > PAGE_SIZE should also allocate from
>>> slab cache, correct? Then how can alloc object w/o slab cache which?
>>> contains this object size objects?
>> I have to admit, I didn't understand the question.
> 
> object is allocated from slab cache, correct? There two kinds of slab
> cache, one is for general purpose, eg. kmalloc slab cache, the other
> is for special purpose, eg. mm_struct, task_struct. kmalloc object >
> PAGE_SIZE/2 or > PAGE_SIZE should also allocated from slab cache,
> correct? then why you said that there are no caches between
> kmalloc-2048 and kmalloc-4096?

Ok, now I get it.  Yes, I guess I should qualified here that there are
no _kmalloc_ caches between PAGE_SIZE/2 and PAGE_SIZE.

Yes, one can create caches of a particular size.  However that doesn't
work well for zswap because the compressed pages vary widely and size
and, imo, it doesn't make sense to create a bunch of caches very
granular in size.

Plus having granular caches doesn't solve the fragmentation issue
caused by the storage of large objects.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
