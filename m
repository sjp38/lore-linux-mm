Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC5A5900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 21:55:19 -0400 (EDT)
Received: by vws14 with SMTP id 14so119730vws.9
        for <linux-mm@kvack.org>; Mon, 12 Sep 2011 18:55:17 -0700 (PDT)
Message-ID: <4E6EB802.4070109@vflare.org>
Date: Mon, 12 Sep 2011 21:55:14 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com> <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org> <4E6E18C6.8080900@linux.vnet.ibm.com>
In-Reply-To: <4E6E18C6.8080900@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, dan.magenheimer@oracle.com, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

Hi Seth,

I revised some of the original plans for xcfmalloc and below are some
details.  I had few nits regarding the current implementation but I'm
avoiding them here since we may have to change the design itself
significantly.

On 09/12/2011 10:35 AM, Seth Jennings wrote:

> On 09/09/2011 09:41 PM, Nitin Gupta wrote:
>> On 09/09/2011 04:34 PM, Greg KH wrote:
>>
>>> On Wed, Sep 07, 2011 at 09:09:04AM -0500, Seth Jennings wrote:
>>>> Changelog:
>>>> v2: fix bug in find_remove_block()
>>>>     fix whitespace warning at EOF
>>>>
>>>> This patchset introduces a new memory allocator for persistent
>>>> pages for zcache.  The current allocator is xvmalloc.  xvmalloc
>>>> has two notable limitations:
>>>> * High (up to 50%) external fragmentation on allocation sets > PAGE_SIZE/2
>>>> * No compaction support which reduces page reclaimation
>>>
>>> I need some acks from other zcache developers before I can accept this.
>>>
>>
>> First, thanks for this new allocator; xvmalloc badly needed a replacement :)
>>
> 
> Hey Nitin, I hope your internship went well :)  It's good to hear from you.
>


Yes, it went well and now I can spend more time on this project :)

 
>> I went through xcfmalloc in detail and would be posting detailed
>> comments tomorrow.  In general, it seems to be quite similar to the
>> "chunk based" allocator used in initial implementation of "compcache" --
>> please see section 2.3.1 in this paper:
>> http://www.linuxsymposium.org/archives/OLS/Reprints-2007/briglia-Reprint.pdf
>>
> 
> Ah, indeed they look similar.  I didn't know that this approach
> had already been done before in the history of this project.
> 
>> I'm really looking forward to a slab based allocator as I mentioned in
>> the initial mail:
>> http://permalink.gmane.org/gmane.linux.kernel.mm/65467
>>
>> With the current design xcfmalloc suffers from issues similar to the
>> allocator described in the paper:
>>  - High metadata overhead
>>  - Difficult implementation of compaction
>>  - Need for extra memcpy()s  etc.
>>
>> With slab based approach, we can almost eliminate any metadata overhead,
>> remove any free chunk merging logic, simplify compaction and so on.
>>
> 
> Just to align my understanding with yours, when I hear slab-based,
> I'm thinking each page in the compressed memory pool will contain
> 1 or more blocks that are all the same size.  Is this what you mean?
> 


Yes, exactly.  The memory pool will consist of "superblocks" (typically
16K or 64K). Each of these superblocks will contain objects of only one
particular size (which is its size class).  This is the general
structure of all slab allocators. In particular, I'm planning to use
many of the ideas discussed in this paper:
http://www.cs.umass.edu/~emery/hoard/asplos2000.pdf

One major point to consider would be that these superblocks cannot be
physically contiguous in our case, so we will have to do some map/unmap
trickery.  The basic idea is to link together individual pages
(typically 4k) using underlying struct_page->lru to form superblocks and
map/unmap objects on demand.

> If so, I'm not sure how changing to a slab-based system would eliminate
> metadata overhead or do away with memcpy()s.
>


With slab based approach, the allocator itself need not store any
metadata with allocated objects.  However, considering zcache and zram
use-cases, the caller will still have to request additional space for
per-object header: actual object size and back-reference (which
inode/page-idx this object belongs to) needed for compaction.

For free-list management, the underlying struct page and the free object
space itself can be used. Some field in the struct page can point to the
first free object in a page and free slab objects themselves will
contain links to next/previous free objects in the page.

> The memcpy()s are a side effect of having an allocation spread over
> blocks in different pages.  I'm not seeing a way around this.
>


For slab objects than span 2 pages, we can use vm_map_ram() to
temporarily map pages involved and read/write to objects directly. For
objects lying entirely within a page, we can use much faster
kmap_atomic() for access.

 
> It also follows that the blocks that make up an allocation must be in
> a list of some kind, leading to some amount of metadata overhead.
> 


Used objects need not be placed in any list. For free objects we can use
underlying struct page and free object space itself to manage free list,
as described above.

> If you want to do compaction, it follows that you can't give the user
> a direct pointer to the data, since the location of that data may change.
> In this case, an indirection layer is required (i.e. xcf_blkdesc and
> xcf_read()/xcf_write()).
> 


Yes, we can't give a direct pointer anyways since pages used by the
allocator are not permanently mapped (to save precious VA spave on
32-bit).  Still, we can save on much of metadata overhead and extra
memcpy() as described above.


> The only part of the metadata that could be done away with in a slab-
> based approach, as far as I can see, is the prevoffset field in xcf_blkhdr,
> since the size of the previous block in the page (or the previous object
> in the slab) can be inferred from the size of the current block/object.
> 
> I do agree that we don't have to worry about free block merging in a
> slab-based system.
> 
> I didn't implement compaction so a slab-based system could very well
> make it easier.  I guess it depends on how one ends up doing it.
>


I expect compaction to be much easier with slab like design since
finding target for relocating objects is so simple. You don't have to
deal with all those little unusable holes created throughout the heap
when mix-all-object-sizes-together approach is used.


For compaction, I plan to have a scheme where the user (zcache/zram)
would "cooperate" with the process.  Here is a rough outline for
relocating an object:
 - For any size class, when emptiness threshold (=total space allocated
/ actual used) exceeds some threshold, the allocator will copy objects
from least used slab superblocks to the most used ones.
 - It will then issue a callback, registered by the user during pool
creation, informing about the new object location,
 - Due to various cases, this callback may return failure in which case
the relocation is considered failed and we will disk newly created copy.
 - If callback succeeds, it means that the user successfully updated its
object reference and we can now mark the original copy as free.


We can also batch this process (copy all objects in victim superblock at
once to other superblocks and issue a single callback) for better
efficiency.


Please let me know if you have any comments. I plan to start with its
implementation sometime this week.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
