Message-ID: <4612C401.3010507@redhat.com>
Date: Tue, 03 Apr 2007 17:15:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com> <20070403135154.61e1b5f3.akpm@linux-foundation.org> <4612C059.8070702@redhat.com> <4612C2B6.3010302@cosmosbay.com>
In-Reply-To: <4612C2B6.3010302@cosmosbay.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:
> Rik van Riel a A(C)crit :
>> Andrew Morton wrote:
>>
>>> Oh.  I was assuming that we'd want to unmap these pages from 
>>> pagetables and
>>> mark then super-easily-reclaimable.  So a later touch would incur a 
>>> minor
>>> fault.
>>>
>>> But you think that we should leave them mapped into pagetables so no 
>>> such
>>> fault occurs.
>>
>>> Leaving the pages mapped into pagetables means that they are 
>>> considerably
>>> less likely to be reclaimed.
>>
>> If we move the pages to a place where they are very likely to be
>> reclaimed quickly (end of the inactive list, or a separate
>> reclaim list) and clear the dirty and referenced lists, we can
>> both reclaim the page easily *and* avoid the page fault penalty.
>>
> 
> There is one possible speedup :
> 
> - If an user app does a madvise(MADV_DONTNEED), we can assume the pages 
> can later be bring back without need to zero them. The application 
> doesnt care.

... however, the application that previously used that page might
care a lot!

> mmap()/brk() must give fresh NULL pages, but maybe 
> madvise(MADV_DONTNEED) can relax this requirement (if the pages were 
> reclaimed, then a page fault could bring a new page with random content)

If we bring in a new page, it has to be zeroed for security
reasons.

You don't want somebody else's process to get a page with
your password in it.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
