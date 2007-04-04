Message-ID: <461373C4.7050501@yahoo.com.au>
Date: Wed, 04 Apr 2007 19:45:40 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com>	<20070403202937.GE355@devserv.devel.redhat.com>	<20070403144948.fe8eede6.akpm@linux-foundation.org>	<4612DCC6.7000504@cosmosbay.com>	<46130BC8.9050905@yahoo.com.au>	<1175675146.6483.26.camel@twins>	<461367F6.10705@yahoo.com.au> <20070404113447.17ccbefa.dada1@cosmosbay.com>
In-Reply-To: <20070404113447.17ccbefa.dada1@cosmosbay.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:
> On Wed, 04 Apr 2007 18:55:18 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>Peter Zijlstra wrote:
>>
>>>On Wed, 2007-04-04 at 12:22 +1000, Nick Piggin wrote:
>>>
>>>
>>>>Eric Dumazet wrote:
>>>
>>>
>>>>>I do think such workloads might benefit from a vma_cache not shared by 
>>>>>all threads but private to each thread. A sequence could invalidate the 
>>>>>cache(s).
>>>>>
>>>>>ie instead of a mm->mmap_cache, having a mm->sequence, and each thread 
>>>>>having a current->mmap_cache and current->mm_sequence
>>>>
>>>>I have a patchset to do exactly this, btw.
>>>
>>>
>>>/me too
>>>
>>>However, I decided against pushing it because when it does happen that a
>>>task is not involved with a vma lookup for longer than it takes the seq
>>>count to wrap we have a stale pointer...
>>>
>>>We could go and walk the tasks once in a while to reset the pointer, but
>>>it all got a tad involved.
>>
>>Well here is my core patch (against I think 2.6.16 + a set of vma cache
>>cleanups and abstractions). I didn't think the wrapping aspect was
>>terribly involved.
> 
> 
> Well, I believe this one is too expensive. I was thinking of a light one :
> 
> I am not deleting mmap_sem, but adding a sequence number to mm_struct, that is incremented each time a vma is added/deleted, not each time mmap_sem is taken (read or write)

That's exactly what mine does (except IIRC it doesn't invalidate when
you add a vma).


> Each thread has its own copy of the sequence, taken at the time find_vma() had to do a full lookup.
> 
> I believe some optimized paths could call check_vma_cache() without mmap_sem read lock taken, and if it fails, take the mmap_sem lock and do the slow path.

The mmap_sem for read does not only protect the mm_rb rbtree structure, but
the vmas themselves as well as their page tables, so you can't do that.

You could do it if you had a lock-per-vma to synchronise against write
operations, and rcu-freed vmas or some such... but I don't think we should
go down a road like that until we first remove mmap_sem from low hanging
things (like private futexes!) and then see who's complaining.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
