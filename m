Message-ID: <46D4DBF7.7060102@yahoo.com.au>
Date: Wed, 29 Aug 2007 12:37:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Selective swap out of processes
References: <1188320070.11543.85.camel@bastion-laptop>
In-Reply-To: <1188320070.11543.85.camel@bastion-laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?UTF-8?B?SmF2aWVyIENhYmV6YXMg77+9?= <jcabezas@ac.upc.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Javier Cabezas RodrA-guez wrote:
> Hi all,
> 
> I am trying to reduce the main memory power consumption when the system
> is idle. In order to achieve it, I want to freeze some processes
> (user-defined) when the system enters a long idle period and swap them
> out to the disk. After that, more memory is free and then, the remaining
> used memory can be moved to a minimal set of memory ranks so the rest of
> ranks can be switched off.
> 
> To the best of my knowledge, a process can own the following types of
> memory pages:
> - Mapped pages
>         A. Executable and Read-only mapped pages that are backed by a
>         file in the disk. These pages can be directly unmapped (if they
>         are not shared) -> UNMAP
>         A. Writable file mapped pages that must be flushed to disk
>         (synced) before they are unmapped -> SYNC + UNMAP
> - Anonymous pages in User Mode address spaces -> SWAP
> -  Mapped pages of tmpfs filesystem -> SWAP
> 
> I have implemented the process selection mechanism (using an entry for
> each PID in proc), and the process freezing/resume (using the
> refrigerator function, like in the hibernation code).
> 
> Now I am implementing the memory freeing. The biggest problem here is
> that the regular swapping out algorithm of the kernel only frees memory
> when it is needed, so I don't know which is the behaviour of the
> standard routines in this situation.  I have looked at the standard
> swapping functions (shrink_zones, shrink_zone, ...) and I think they
> handle all the  process page types I enumerated previously. So, for each
> VMA of the process,  I build a page list with all the pages and pass it
> as a parameter to shrink_page_list (before that I remove them from the
> LRU active/inactive lists with del_page_from_lru).
> 
> First I have tried with the executable VMA (of a lynx process) mapped to
> the executable file. However none of the pages is freed.
> shrink_page_list skips each page due to this check:
> 
> referenced = page_referenced(page, 1);
> /* In active use or really unfreeable?  Activate it. */
> if (referenced && page_mapping_inuse(page))
> 	goto activate_locked;
> 
> It seems they are mapped somewhere else and they cannot be freed. So,
> which operations should I perform on the pages (try_to_unmap,
> pte_mkold, ...) before I call shrink_page_list?


Simplest will be just to set referenced to 0 right after calling
page_referenced, in the case you want to forcefully swap out the
page.

try_to_unmap will get called later in the same function.


unmapped pagecache, and other caches are going to take up a fair
bit of memory as well, and fragmentation might mean it is hard to
get large enough regions of contiguous memory to switch off chips,
though.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
