Received: from alogconduit1ah.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA14113
	for <linux-mm@kvack.org>; Mon, 10 May 1999 22:42:04 -0400
Subject: Re: [PATCH] dirty pages in memory & co.
References: <Pine.LNX.4.05.9905090427420.1025-100000@laser.random>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 10 May 1999 20:06:25 -0500
In-Reply-To: Andrea Arcangeli's message of "Mon, 10 May 1999 02:57:54 +0200 (CEST)"
Message-ID: <m1g154e7ou.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On 7 May 1999, Eric W. Biederman wrote:
>> 7) Removing the swap lock map, by modify ipc/shm to use the page cache
>> and vm_stores.

AA> I just killed the swap lock map and I just use the swap cache for ipc shm
AA> memory.

Cool.  I'll have to take a look.  It should save some work.

AA> Now I was thinking at the reverse lookup from pagemap to pagetable that
AA> you mentioned. It would be easy to that at least for the page/swap cache
AA> mappings with the interface I added in my tree.

AA> But to support dynamic relocation/defrag of memory on the whole VM we
AA> should do that for _all_ pages. And to do the relocation we should run
AA> with the GFP pages mapped in a separate pte (not in the 4mbyte page table
AA> with the kernel). So I don't know if it would be better to just move all
AA> kernel memory (the one available through GFP) to virtual memory and to
AA> support the reverse lookup for all pages in the system, or if I should
AA> only do the quite-easy backdoor for the page/swap cache. The point is that
AA> supporting the reverse lookup for all kernel memory and having all kernel
AA> memory in virtual memory, will be a _major_ performance hit for all
AA> operations according to me.

Right, and it doesn't buy you very much.
We have some constants.
A) Defragging doesn't need to happen often.
B) We don't have much kernel memory tied up in locked down memory 
   (that we refer to with pointers).
C) For locked down memory there is also internal fragmentation to worry about.
D) The biggest gain is handling memory that isn't locked down.

So I think I would first concentrate on the common case, pages mappable
in user space, the page cache and anonymous memory.

For locked down memory a good solution looks like an incremental copy collector.
Not that we need the garbage collecting properties, but it is the only incremental
memory packing algorithm I currently know.  And we could take advantage of fine
grained smp locks to implement the needed write barrier.

AA> Right now i would need the reverse lookup only for the mapped cache
AA> because I would like to avoid to run swap_out to know if the pte is been
AA> accessed or not and in the case it's an old pte I could unmap the
AA> mmapped-page directly from shrink_mmap. But I am not convinced this will
AA> be an improvement too because I just run swap_out at the right time...

AA> Comments?

The reason I am looking at reverse page entries, is I would like to handle
dirty mapped pages better.  
My thought is basically to trap the fault that dirties the page and mark it dirty.
Then after it has aged long enough I unmap or at least clear the write allow bits of
the pte or ptes.

This does buy an improvement, in when things get written out.  But beyond that I
don't know.

It's certainly something to think about for your other algorithms.
The current scheme seems good enough for the most part however.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
