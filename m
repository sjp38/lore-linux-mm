Message-ID: <461D67A9.5020509@redhat.com>
Date: Wed, 11 Apr 2007 18:56:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] make MADV_FREE lazily free memory
References: <461C6452.1000706@redhat.com> <461D6413.6050605@cosmosbay.com>
In-Reply-To: <461D6413.6050605@cosmosbay.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ulrich Drepper <drepper@redhat.com>
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:
> Rik van Riel a A(C)crit :
>> Make it possible for applications to have the kernel free memory
>> lazily.  This reduces a repeated free/malloc cycle from freeing
>> pages and allocating them, to just marking them freeable.  If the
>> application wants to reuse them before the kernel needs the memory,
>> not even a page fault will happen.

> I dont understand this last sentence. If not even a page fault happens, 
> how the kernel knows that the page was eventually reused by the 
> application, and should not be freed in case of memory pressure ?

Before maybe freeing the page, the kernel checks the referenced
and dirty bits of the page table entries mapping that page.

> ptr = mmap(some space);
> madvise(ptr, length, MADV_FREE);
> /* kernel may free the pages */

All this call does is:
- clear the accessed and dirty bits
- move the page to the far end of the inactive list,
   where it will be the first to be reclaimed

> sleep(10);
> 
> /* what the application must do know before reusing space ? */
> memset(ptr, data, 10000);
> /* kernel should not free ptr[0..10000] now */

Two things can happen here.

If this program used the pages before the kernel needed
them, the program will be reusing its old pages.

If the kernel got there first, you will get page faults
and the kernel will fill in the memory with new pages.

Both of these alternatives are transparent to userspace.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
