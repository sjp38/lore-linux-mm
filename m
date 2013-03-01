Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 60A356B0002
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 01:47:24 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id o17so5072674oag.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 22:47:23 -0800 (PST)
Message-ID: <51304EF0.5050201@gmail.com>
Date: Fri, 01 Mar 2013 14:47:12 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 2/8] zsmalloc: add documentation
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-3-git-send-email-sjenning@linux.vnet.ibm.com> <511F254D.2010909@gmail.com> <51227DF4.9020900@linux.vnet.ibm.com> <5125DFAA.4050706@gmail.com> <5126423F.7040705@linux.vnet.ibm.com> <5126DE7B.2010203@gmail.com> <5127DD01.4080003@linux.vnet.ibm.com> <512960CD.4080008@gmail.com> <512B80B6.6090401@linux.vnet.ibm.com>
In-Reply-To: <512B80B6.6090401@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/25/2013 11:18 PM, Seth Jennings wrote:
> On 02/23/2013 06:37 PM, Ric Mason wrote:
>> On 02/23/2013 05:02 AM, Seth Jennings wrote:
>>> On 02/21/2013 08:56 PM, Ric Mason wrote:
>>>> On 02/21/2013 11:50 PM, Seth Jennings wrote:
>>>>> On 02/21/2013 02:49 AM, Ric Mason wrote:
>>>>>> On 02/19/2013 03:16 AM, Seth Jennings wrote:
>>>>>>> On 02/16/2013 12:21 AM, Ric Mason wrote:
>>>>>>>> On 02/14/2013 02:38 AM, Seth Jennings wrote:
>>>>>>>>> This patch adds a documentation file for zsmalloc at
>>>>>>>>> Documentation/vm/zsmalloc.txt
>>>>>>>>>
>>>>>>>>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>>>>>>>> ---
>>>>>>>>>       Documentation/vm/zsmalloc.txt |   68
>>>>>>>>> +++++++++++++++++++++++++++++++++++++++++
>>>>>>>>>       1 file changed, 68 insertions(+)
>>>>>>>>>       create mode 100644 Documentation/vm/zsmalloc.txt
>>>>>>>>>
>>>>>>>>> diff --git a/Documentation/vm/zsmalloc.txt
>>>>>>>>> b/Documentation/vm/zsmalloc.txt
>>>>>>>>> new file mode 100644
>>>>>>>>> index 0000000..85aa617
>>>>>>>>> --- /dev/null
>>>>>>>>> +++ b/Documentation/vm/zsmalloc.txt
>>>>>>>>> @@ -0,0 +1,68 @@
>>>>>>>>> +zsmalloc Memory Allocator
>>>>>>>>> +
>>>>>>>>> +Overview
>>>>>>>>> +
>>>>>>>>> +zmalloc a new slab-based memory allocator,
>>>>>>>>> +zsmalloc, for storing compressed pages.  It is designed for
>>>>>>>>> +low fragmentation and high allocation success rate on
>>>>>>>>> +large object, but <= PAGE_SIZE allocations.
>>>>>>>>> +
>>>>>>>>> +zsmalloc differs from the kernel slab allocator in two primary
>>>>>>>>> +ways to achieve these design goals.
>>>>>>>>> +
>>>>>>>>> +zsmalloc never requires high order page allocations to back
>>>>>>>>> +slabs, or "size classes" in zsmalloc terms. Instead it allows
>>>>>>>>> +multiple single-order pages to be stitched together into a
>>>>>>>>> +"zspage" which backs the slab.  This allows for higher
>>>>>>>>> allocation
>>>>>>>>> +success rate under memory pressure.
>>>>>>>>> +
>>>>>>>>> +Also, zsmalloc allows objects to span page boundaries within the
>>>>>>>>> +zspage.  This allows for lower fragmentation than could be had
>>>>>>>>> +with the kernel slab allocator for objects between PAGE_SIZE/2
>>>>>>>>> +and PAGE_SIZE.  With the kernel slab allocator, if a page
>>>>>>>>> compresses
>>>>>>>>> +to 60% of it original size, the memory savings gained through
>>>>>>>>> +compression is lost in fragmentation because another object of
>>>>>>>>> +the same size can't be stored in the leftover space.
>>>>>>>>> +
>>>>>>>>> +This ability to span pages results in zsmalloc allocations not
>>>>>>>>> being
>>>>>>>>> +directly addressable by the user.  The user is given an
>>>>>>>>> +non-dereferencable handle in response to an allocation request.
>>>>>>>>> +That handle must be mapped, using zs_map_object(), which returns
>>>>>>>>> +a pointer to the mapped region that can be used.  The mapping is
>>>>>>>>> +necessary since the object data may reside in two different
>>>>>>>>> +noncontigious pages.
>>>>>>>> Do you mean the reason of  to use a zsmalloc object must map after
>>>>>>>> malloc is object data maybe reside in two different nocontiguous
>>>>>>>> pages?
>>>>>>> Yes, that is one reason for the mapping.  The other reason (more
>>>>>>> of an
>>>>>>> added bonus) is below.
>>>>>>>
>>>>>>>>> +
>>>>>>>>> +For 32-bit systems, zsmalloc has the added benefit of being
>>>>>>>>> +able to back slabs with HIGHMEM pages, something not possible
>>>>>>>> What's the meaning of "back slabs with HIGHMEM pages"?
>>>>>>> By HIGHMEM, I'm referring to the HIGHMEM memory zone on 32-bit
>>>>>>> systems
>>>>>>> with larger that 1GB (actually a little less) of RAM.  The upper
>>>>>>> 3GB
>>>>>>> of the 4GB address space, depending on kernel build options, is not
>>>>>>> directly addressable by the kernel, but can be mapped into the
>>>>>>> kernel
>>>>>>> address space with functions like kmap() or kmap_atomic().
>>>>>>>
>>>>>>> These pages can't be used by slab/slub because they are not
>>>>>>> continuously mapped into the kernel address space.  However, since
>>>>>>> zsmalloc requires a mapping anyway to handle objects that span
>>>>>>> non-contiguous page boundaries, we do the kernel mapping as part of
>>>>>>> the process.
>>>>>>>
>>>>>>> So zspages, the conceptual slab in zsmalloc backed by single-order
>>>>>>> pages can include pages from the HIGHMEM zone as well.
>>>>>> Thanks for your clarify,
>>>>>>     http://lwn.net/Articles/537422/, your article about zswap in lwn.
>>>>>>     "Additionally, the kernel slab allocator does not allow
>>>>>> objects that
>>>>>> are less
>>>>>> than a page in size to span a page boundary. This means that if an
>>>>>> object is
>>>>>> PAGE_SIZE/2 + 1 bytes in size, it effectively use an entire page,
>>>>>> resulting in
>>>>>> ~50% waste. Hense there are *no kmalloc() cache size* between
>>>>>> PAGE_SIZE/2 and
>>>>>> PAGE_SIZE."
>>>>>> Are your sure? It seems that kmalloc cache support big size, your
>>>>>> can
>>>>>> check in
>>>>>> include/linux/kmalloc_sizes.h
>>>>> Yes, kmalloc can allocate large objects > PAGE_SIZE, but there are no
>>>>> cache sizes _between_ PAGE_SIZE/2 and PAGE_SIZE.  For example, on a
>>>>> system with 4k pages, there are no caches between kmalloc-2048 and
>>>>> kmalloc-4096.
>>>> kmalloc object > PAGE_SIZE/2 or > PAGE_SIZE should also allocate from
>>>> slab cache, correct? Then how can alloc object w/o slab cache which?
>>>> contains this object size objects?
>>> I have to admit, I didn't understand the question.
>> object is allocated from slab cache, correct? There two kinds of slab
>> cache, one is for general purpose, eg. kmalloc slab cache, the other
>> is for special purpose, eg. mm_struct, task_struct. kmalloc object >
>> PAGE_SIZE/2 or > PAGE_SIZE should also allocated from slab cache,
>> correct? then why you said that there are no caches between
>> kmalloc-2048 and kmalloc-4096?
> Ok, now I get it.  Yes, I guess I should qualified here that there are
> no _kmalloc_ caches between PAGE_SIZE/2 and PAGE_SIZE.

Why I have?

dma-kmalloc-8192       0      0   8192    4    8 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-4096       0      0   4096    8    8 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-2048       0      0   2048   16    8 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-1024       0      0   1024   32    8 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-512       32     32    512   32    4 : tunables    0 0    0 
: slabdata      1      1      0
dma-kmalloc-256        0      0    256   32    2 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-128        0      0    128   32    1 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-64         0      0     64   64    1 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-32         0      0     32  128    1 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-16         0      0     16  256    1 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-8          0      0      8  512    1 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-192        0      0    192   21    1 : tunables    0 0    0 
: slabdata      0      0      0
dma-kmalloc-96         0      0     96   42    1 : tunables    0 0    0 
: slabdata      0      0      0
kmalloc-8192         100    100   8192    4    8 : tunables    0 0    0 
: slabdata     25     25      0
kmalloc-4096         178    216   4096    8    8 : tunables    0 0    0 
: slabdata     27     27      0
kmalloc-2048         229    304   2048   16    8 : tunables    0 0    0 
: slabdata     19     19      0
kmalloc-1024         832    832   1024   32    8 : tunables    0 0    0 
: slabdata     26     26      0
kmalloc-512         2016   2016    512   32    4 : tunables    0 0    0 
: slabdata     63     63      0
kmalloc-256         2203   2368    256   32    2 : tunables    0 0    0 
: slabdata     74     74      0
kmalloc-128         2026   2464    128   32    1 : tunables    0 0    0 
: slabdata     77     77      0
kmalloc-64         27584  27584     64   64    1 : tunables    0 0    0 
: slabdata    431    431      0
kmalloc-32         19334  20864     32  128    1 : tunables    0 0    0 
: slabdata    163    163      0
kmalloc-16          6912   6912     16  256    1 : tunables    0 0    0 
: slabdata     27     27      0
kmalloc-8          17408  17408      8  512    1 : tunables    0 0    0 
: slabdata     34     34      0
kmalloc-192         8006   8946    192   21    1 : tunables    0 0    0 
: slabdata    426    426      0
kmalloc-96         19828  19992     96   42    1 : tunables    0 0    0 
: slabdata    476    476      0
kmem_cache_node      384    384     32  128    1 : tunables    0 0    0 
: slabdata      3      3      0
kmem_cache           160    160    128   32    1 : tunables    0 0    0 
: slabdata      5      5      0


>
> Yes, one can create caches of a particular size.  However that doesn't
> work well for zswap because the compressed pages vary widely and size
> and, imo, it doesn't make sense to create a bunch of caches very
> granular in size.
>
> Plus having granular caches doesn't solve the fragmentation issue
> caused by the storage of large objects.
>
> Thanks,
> Seth
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
