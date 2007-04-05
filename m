Message-ID: <46145476.8080504@yahoo.com.au>
Date: Thu, 05 Apr 2007 11:44:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <20070403144948.fe8eede6.akpm@linux-foundation.org> <20070403160231.33aa862d.akpm@linux-foundation.org> <Pine.LNX.4.64.0704040949050.17341@blonde.wat.veritas.com> <4613BC5D.2070404@redhat.com> <Pine.LNX.4.64.0704041610320.19450@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0704041610320.19450@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 4 Apr 2007, Rik van Riel wrote:
> 
>>Hugh Dickins wrote:
>>
>>
>>>(I didn't understand how Rik would achieve his point 5, _no_ lock
>>>contention while repeatedly re-marking these pages, but never mind.)
>>
>>The CPU marks them accessed&dirty when they are reused.
>>
>>The VM only moves the reused pages back to the active list
>>on memory pressure.  This means that when the system is
>>not under memory pressure, the same page can simply stay
>>PG_lazyfree for multiple malloc/free rounds.
> 
> 
> Sure, there's no need for repetitious locking at the LRU end of it;
> but you said "if the system has lots of free memory, pages can go
> through multiple free/malloc cycles while sitting on the dontneed
> list, very lazily with no lock contention".  I took that to mean,
> with userspace repeatedly madvising on the ranges they fall in,
> which will involve mmap_sem and ptl each time - just in order
> to check that no LRU movement is required each time.
> 
> (Of course, there's also the problem that we don't leave our
> systems with lots of free memory: some LRU balancing decisions.)

I don't agree this approach is the best one anyway. I'd rather
just the simple MADV_DONTNEED/MADV_DONEED.

Once you go through the trouble of protecting the memory and
flushing TLBs, unprotecting them afterwards and taking a trap
(even if it is a pure hardware trap), I doubt you've saved much.

You may have saved the cost of zeroing out the page, but that
has to be weighed against the fact that you have left a possibly
cache hot page sitting there to get cold, and your accesses to
initialise the malloced memory might have more cache misses.

If you just free the page, it goes onto a nice LIFO cache hot
list, and when you want to allocate another one, you'll probably
get a cache hot one.

The problem is down_write(mmap_sem) isn't it? We can and should
easily fix that problem now. If we subsequently want to look at
micro optimisations to avoid zeroing using MMU tricks, then we
have a good base to compare with.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
