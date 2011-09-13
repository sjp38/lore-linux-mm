Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 16B0D900136
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 17:18:33 -0400 (EDT)
Received: by qyl38 with SMTP id 38so2424470qyl.14
        for <linux-mm@kvack.org>; Tue, 13 Sep 2011 14:18:30 -0700 (PDT)
Message-ID: <4E6FC8A1.8070902@vflare.org>
Date: Tue, 13 Sep 2011 17:18:25 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com> <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org> <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org> <4E6F7DA7.9000706@linux.vnet.ibm.com>
In-Reply-To: <4E6F7DA7.9000706@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, dan.magenheimer@oracle.com, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On 09/13/2011 11:58 AM, Seth Jennings wrote:
> On 09/12/2011 08:55 PM, Nitin Gupta wrote:

>>>>
>>>> With slab based approach, we can almost eliminate any metadata overhead,
>>>> remove any free chunk merging logic, simplify compaction and so on.
>>>>
>>>
>>> Just to align my understanding with yours, when I hear slab-based,
>>> I'm thinking each page in the compressed memory pool will contain
>>> 1 or more blocks that are all the same size.  Is this what you mean?
>>>
>>
>>
>> Yes, exactly.  The memory pool will consist of "superblocks" (typically
>> 16K or 64K).
> 
> A fixed superblock size would be an issue.  If you have a fixed superblock
> size of 64k on a system that has 64k hardware pages, then we'll find 
> ourselves in the same fragmentation mess as xvmalloc.  It needs to be 
> relative to the hardware page size; say 4*PAGE_SIZE or 8*PAGE_SIZE.
>

Yes, I meant some multiple of actual PAGE_SIZE.
 
>> Each of these superblocks will contain objects of only one
>> particular size (which is its size class).  This is the general
>> structure of all slab allocators. In particular, I'm planning to use
>> many of the ideas discussed in this paper:
>> http://www.cs.umass.edu/~emery/hoard/asplos2000.pdf
>>
>> One major point to consider would be that these superblocks cannot be
>> physically contiguous in our case, so we will have to do some map/unmap
>> trickery.
> 
> I assume you mean vm_map_ram() by "trickery".
> 
> In my own experiments, I can tell you that vm_map_ram() is VERY expensive
> wrt kmap_atomic().  I made a version of xvmalloc (affectionately called
> "chunky xvmalloc") where I modified grow_pool() to allocate 4 0-order pages,
> if it could, and group them into a "chunk" (what you are calling a
> "superblock").  The first page in the chunk had a chunk header that contained
> the array of page pointers that vm_map_ram() expects.  A block was 
> identified by a page pointer to the first page in the chunk, and an offset
> within the mapped area of the chunk.
> 
> It... was... slow...
> 
> Additionally, vm_map_ram() failed a lot because it actually allocates
> memory of its own for the vmap_area.  In my tests, many pages slipped
> through zcache because of this failure.
> 
> Even worse, it uses GFP_KERNEL when alloc'ing the vmap_area which 
> isn't safe under spinlock.
> 
> It seems that the use of vm_map_ram() is a linchpin in this design.
> 

Real bad. So, we simply cannot use vm_map_ram().  Maybe we can come-up with
something that can map just two pages contiguously and provide kmap_atomic()
like characteristics?

>> The basic idea is to link together individual pages
>> (typically 4k) using underlying struct_page->lru to form superblocks and
>> map/unmap objects on demand.
>>
>>> If so, I'm not sure how changing to a slab-based system would eliminate
>>> metadata overhead or do away with memcpy()s.
>>>
>>
>>
>> With slab based approach, the allocator itself need not store any
>> metadata with allocated objects.  However, considering zcache and zram
>> use-cases, the caller will still have to request additional space for
>> per-object header: actual object size and back-reference (which
>> inode/page-idx this object belongs to) needed for compaction.
>>
> 
> So the metadata still exists.  It's just zcache's metadata vs the
> allocator's metadata.
> 

Yes, some little metadata still exists but we save storing previous, next
pointers in used objects.

>> For free-list management, the underlying struct page and the free object
>> space itself can be used. Some field in the struct page can point to the
>> first free object in a page and free slab objects themselves will
>> contain links to next/previous free objects in the page.
>>
>>> The memcpy()s are a side effect of having an allocation spread over
>>> blocks in different pages.  I'm not seeing a way around this.
>>>
>>
>>
>> For slab objects than span 2 pages, we can use vm_map_ram() to
>> temporarily map pages involved and read/write to objects directly. For
>> objects lying entirely within a page, we can use much faster
>> kmap_atomic() for access.
>>
>>
> 
> See previous comment about vm_map_ram().  There is also an issue
> here with a slab object being unreadable do to vm_map_ram() failing.
>

I will try coming-up with some variant of kmap_atomic() which allows mapping
just two pages contiguously which is sufficient for our purpose.
 
>>> It also follows that the blocks that make up an allocation must be in
>>> a list of some kind, leading to some amount of metadata overhead.
>>>
>>
>>
>> Used objects need not be placed in any list.  For free objects we can use
>> underlying struct page and free object space itself to manage free list,
>> as described above.
>>
> 
> I assume this means that allocations consist of only one slab object as
> opposed to multiple objects in slabs with different class sizes.
> 
> In other words, if you have a 3k allocation and your slab
> class sizes are 1k, 2k, and 4k, the allocation would have to
> be in a single 4k object (with 25% fragmentation), not spanning
> a 1k and 2k object, correct?
> 
> This is something that I'm inferring from your description, but is key
> to the design.  Please confirm that I'm understanding correctly.
> 

To rephrase the slab design: the memory pool is grown in units of superblocks
which is a (virtually) contiguous region of say, 4*PAGE_SIZE or 8*PAGE_SIZE.
Each of these superblocks is assigned to exactly one size class which is the
size of objects this superblock will store. For example, a superblock of size
64K assigned to size-class 512B can store 64K/512B = 128 objects of size 512B;
it cannot store objects of any other size.

Considering your example, if we have size classes of say 1K, 2K and 4K and
superblock size is say 16K and we get allocation request for 3K, we will use
superblocks assigned to 4K size class. If we selected, say, an empty superblock,
the object will take 4K (1K wasted) leaving 16K-4K = 12K of free space in that
superblock.

To reduce such internal fragmentation, we can have closely spaced size-classes
(say, separated by 32 bytes) but there is a tradeoff here: if there are too many
size classes, we can waste lot of memory due to partially filled superblocks
in each of size classes and if they are too widely spaced, we can lot of
internal fragmentation.

>>> If you want to do compaction, it follows that you can't give the user
>>> a direct pointer to the data, since the location of that data may change.
>>> In this case, an indirection layer is required (i.e. xcf_blkdesc and
>>> xcf_read()/xcf_write()).
>>>
>>
>>
>> Yes, we can't give a direct pointer anyways since pages used by the
>> allocator are not permanently mapped (to save precious VA spave on
>> 32-bit).  Still, we can save on much of metadata overhead and extra
>> memcpy() as described above.
>>
>>
> 
> This isn't clear to me.  What would be returned by the malloc() call
> in this design?  In other words, how does the caller access the
> allocation?  You just said we can't give a direct access to the data
> via a page pointer and an offset. What else is there to return other
> than a pointer to metadata?
> 

I meant that, since we cannot have allocator pages always mapped, we cannot
return a direct pointer (VA) to the allocated object. Instead, we can combine
page frame number (PFN) and offset within the page as a single 64-bit unsigned
number and return this as "object handle".

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
