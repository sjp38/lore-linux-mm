Message-ID: <48DB3B88.7080609@tungstengraphics.com>
Date: Thu, 25 Sep 2008 09:19:36 +0200
From: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
References: <20080923091017.GB29718@wotan.suse.de> <48D8C326.80909@tungstengraphics.com> <20080925001856.GB23494@wotan.suse.de>
In-Reply-To: <20080925001856.GB23494@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: keith.packard@intel.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Tue, Sep 23, 2008 at 12:21:26PM +0200, Thomas Hellstrom wrote:
>   
>> Nick,
>> From my point of view, this is exactly what's needed, although there 
>> might be some different opinions among the
>> DRM developers. A question:
>>
>> Sometimes it's desirable to indicate that a page / object is "cleaned", 
>> which would mean data has moved and is backed by device memory. In that 
>> case one could either free the object or indicate to it that it can 
>> release it's pages. Is freeing / recreating such an object an expensive 
>> operation? Would it, in that case, be possible to add an object / page 
>> "cleaned" function?
>>     
>
> Ah, interesting... freeing/recreating isn't _too_ expensive, but it is
> going to have to allocate a lot of pages (for a big object) and copy
> a lot of memory. It's strange to say "cleaned", in a sense, because the
> allocator itself doesn't know it is being used as a writeback cache ;)
> (and it might get confusing with the shmem implementation because your
> cleaned != shmem cleaned!).
>
> I understand the operation you need, but it's tricky to make it work in
> the existing shmem / vm infrastructure I think. Let's call it "dontneed",
> and I'll add a hook in there we can play with later to see if it helps?
>
> What I could imagine is to have a second backing store (not shmem), which
> "dontneed" pages go onto, and they simply get discarded rather than swapped
> out (eg. via the ->shrinker() memory pressure indicator). You could then
> also register a callback to recreate these parts of memory if they have been
> discarded then become used again. It wouldn't be terribly difficult come to
> think of it... would that be useful?
>
>   
Well, the typical usage pattern is:

1) User creates a texture object, the data of which lives in a pageable 
object.
2) DRM decides it needs to go into V(ideo)RAM, and doesn't need a 
backing store. It indicates "dontneed" status on the object.
3) Data is evicted from VRAM. If it's not dirtied in VRAM and the 
"dontneed" pages are still around in the
old backing object, fine. We can and should reuse them. If data is 
dirtied in VRAM or the page(s) got discarded
 we need new pages and to set up a copy operation.

So yes, that would indeed be very useful,
I think one way is to have the callback happen on a per-page basis.
 DRM can then collect a list of what pages need to be copied from VRAM 
based on the callback and its knowledge of VRAM data status and set up a 
single DMA operation. So the callback shouldn't implicitly mark the 
newly allocated pages dirty.

Another useful thing I come to think of looking through the interface 
specification again is to have a pgprot_t argument to the pageable 
object vmap function, so that the VMAP mapping can be set to uncached / 
write-combined.
This of course would imply that the caller has pinned the pages and had 
the default kernel mapping caching status changed as well.

/Thomas





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
