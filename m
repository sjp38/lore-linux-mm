Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA12239
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 03:45:18 -0500
Subject: Re: naive questions, docs, etc.
References: <199901050031.SAA06940@disco.cs.utexas.edu>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 05 Jan 1999 02:39:53 -0600
In-Reply-To: "Paul R. Wilson"'s message of "Mon, 4 Jan 1999 18:31:25 -0600"
Message-ID: <m1vhimi04m.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Paul R. Wilson" <wilson@cs.utexas.edu>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "PW" == Paul R Wilson <wilson@cs.utexas.edu> writes:

PW> Here's my first batch of notes on the VM system.  It's mostly 
PW> introductory, overall-picture kinds of things, but I need
PW> feedback on it before I can write nitty-gritty stuff.


Here are some more or less randomly structured answers to help
you along.  I believe I have touched upon most of your questions,
and the things I believe you got wrong.

Eric
----- 


The main memory allocator is get_free_page/ __get_free_pages 
kmalloc is built on top of the slab allocator.

The address space of a linux process is basically broken up into 3 sections.

user process space
direct mapping of physical memory (with a fixed offset (usally 3GB))
extra vm space for vmalloc.

vmalloc is the only memory allocator in the whole kernel that will
give you a block of virtual memory, that isn't physically contiguous.



For the basic memory alloctor,  linux mostly implements a classic
two handed clock algorithm.    The first hand is swap_out which 
unmaps pages.  The second hand is shrink_mmap.  Which takes pages
which we are sure no one else is using and puts them in the free page pool.


The referenced bit on the on the on a page makes up for any mismatch 
between swap_out, and shrink_mmap.  Ensuring a page will stay if it
has been recently referenced, or in the case of newly allocated readahead,
not be expelled before the readahead is needed. 

This as far as I can tell is the first implementation of true aging
in linux despite the old ``page aging'' code, that just made it 
hard to get rid of pages.


The goofy part of implementing default actions inline is probably questionable
from a design perspective.  However there is no real loss, and further it
is a technique as branches, and icache misses get progressively more expensive
compiler writers are contemplating seriously considering.  In truth it is a
weak of VLIW optimizing.


SysV shm is a wart on the system that was orginally implemented as
a special case and no one has put in the time to clean it up since.
I have work underway that will probably do some of that for 2.3 however.


One of the really important cases it has been found to optimize for in
linux is the case of no extra seeks.   The observation is that when reading
at  a spot on the disk, it is barely more expensive to read/write many pages
at a time then a single page.  This optimization has been implemented
in filemap_nopage, swapin_readahead, and swap_out.


Currently for lack of a unified cache writing structure swap pages
are written when they are removed from the page tables if they are dirty.
Where as most filesystems use the buffer cache which has an eventual timeout
on buffers.

The buffer cache can have buffers up to 1 PAGE in size, and there
is no limit as to what can be held on a buffers can be held on a single page
except they must be the same size.  

Note: for x86 linux the practical buffer cache sizes are
512k 1024k 2048k 4096k

Note:  The swap_cache isn't quite as well integrated with the page
cache as it should be (on my todo for 2.3). Implementation rough spots aside,
the swap cache refers to that subset of the page cache that is used to cache
the ``pseudo swap file''.  It used exactly as the page cache is for managing
blocks.

As a consequence of the fact that it is currently safe (except for sysv shm
to remove the swap lock map and save some memory there).

An aside you have called what I would call a software TLB, an inverse
page map.  

As far as copy data from user the kernel can directly see it.
There are special wrapper macros, and a special exception handling
mechanism to handle the case of bad addresses, to no memory being passed
into the kernel.  And of course this is the only time kernel code
can touch pageable memory.


struct page is the structure mem_map_t is the rarely used typedef...
Don't forget the importance of keeping the per page data down, as
anything in struct page must be maintained for every page.

At last look linux's struct page is about 1/2 integers larger than
that of netbsd, until you start factoring all of the other structures
netbsd has per page in which case linux comes up massively thinner.  
One of which is are the reverse virtual page table lists per page.

That is a piece of functionality that would be really handy to have in
linux but we have never been willing to pay the price.  And with swap_out
traversing the page maps, and the swap cache giving us a chance to reclaim,
after they have been unmapped, but before they are discarded.
It is likely won't ever have to pay that price.

The shmid is actually in the vm_area_struct.
I have plans for my 2.3 overhaul to work on that, but the code
hasn't quite been written yet.

As far as AVL tree's I believe someone looked at the general case
and figured they wern't needed.


To help answer your confusion.  The page cache holds clean data for
pages.  And the clean data for process pages.  Further shrink_mmap
can find the clean unused buffer cache pages.  Note, the in memory order
scan by shrink mmap would appear to be good at encouraging continous areas
of memory to be free.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
