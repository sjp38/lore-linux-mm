Date: Mon, 16 Aug 1999 18:29:30 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: [bigmem-patch] 4GB with Linux on IA32
Message-ID: <Pine.LNX.4.10.9908161622130.1937-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>, "Gerhard, Winfried" <Winfried.Gerhard@pdb.siemens.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

co-developed by SuSE and Siemens (precisely by me at SuSE and Gerhard
Wichert at Siemens).

Object of the patch:

	Allow you to use close to 4giga of memory as anonymous and shm
	memory on IA32.

Performance degradation:

	Close to zero.

Missing feature:

	The page/buffer cache (and so all shared/private not-anonynous
	mappings) can grow up only close to 4giga-PAGE_OFFSET bytes of
	RAM (2giga if CONFIG_2G is selected, 1giga if CONFIG_1G is
	selected).

Implementation details:

	Basically we allow GFP to return addresses without a valid
	virtual->physical mapping. Such pages are the bigmem pages and they
	have a valid page_map as the regular-pages. The bigmem
	pages have the PG_BIGMEM bigflag set into the page->flags field.
	The bigmem pages are completly equivalent to the regular pages
	with the only difference that we can't access them by only touching
	the virtual address returned by GFP. So to do COW or clear_page with
	bigmem pages we need to first create a proper virt-to-phys mapping
	in the fixmap area and then we'll read or write to such phys-page
	by writing or reading in the virt-fixmap area. After the COW or
	after the shm/anonymous allocation the physical page will be mapped
	in the userspace pte and there won't be any difference for
	userspace between bigmem or regular pages.

	The only tiny performance degradation will be in the
	page-fault handler: a check for the bigmem page, if the page is a 
	bigmem page then remap of the fixmap pte and invlpg the fixmap
	virtual address. I believe this little performance degradation
	will be not even noticeable.
	And once the allocation will be complete there won't be any
	performance degradation at all.

	The reason we don't allow the bigmem pages to live in cache is
	because the cache must be read and written by the buffer/page
	cache code and by the block device lowlevel code. Allowing
	the bigmemory to live in the buffer/page/swap cache would be
	possible but we should change lots of kernel common code.
	Since we can just grow the cache up to 2giga of ram (with
	CONFIG_2G) and at the same time we may be running with 2giga of
	ram allocated in shm or malloced memory, I don't believe that it
	worth to change all such code adding further complexity and
	performance degradation to the I/O layer.

	To solve the swapout/swapin of bigmem pages I remap the bigmempage
	in a regular page or I replace the swapped-in regular page
	with a bigmem page when necessary. At the same time I alloc a
	page, I also release another page. If a page is not available
	in the freelist then the swapout will return as not succesfully
	and we'll continue trying to swapout or unmap some other page in the
	process space. The swapout/swapin of the bigmem pages will be a
	bit slower than the swapin/swapout of regular pages but since I/O is
	almost always far slower than memory I believe that even this
	swapin/swapout performance degradation won't be an issue at all
	(almost sure if the swap-blockdevice is DMA driven ;).

How to use the patch:

1)	Grab and extract the 2.3.13 kernel.
	(ftp://ftp.kernel.org/pub/linux/kernel/v2.3/linux-2.3.13.tar.gz)
2)	Apply the patch in attachment over it.
3)	configure the kernel with CONFIG_BIGMEM enabled.
4)	recompile, install the new binary kernel image, reboot and enjoy ;).

CONFIG_1G/CONFIG_2G settings:

o	If you want to allow a task to grow up to 3giga of shm or
	anonymous virtual memory then select CONFIG_1G. (the remaining giga
	of ram can be still used by the other tasks of course)
	NOTE: Selecting CONFIG_1G will allow you to alloc only 1giga of
	ram as cache and so as private/shared mmaps.
o	If you want to alloc up to 2giga of ram in cache then select
	CONFIG_2G. But then the maximum virtual size of a task will be
	limited to 2giga. (the other 2giga of RAM can be used by other
	processes as usual)

Testing:

	I personally did most of the testing with 32mbyte of ram 8-). To
	test the bigmem code with lowmemory machines you simply need to
	set CONFIG_BIGMEM and recompile, since if your machine have less then
	1giga of ram, then part of your memory will be considered as
	bigmemory even if it could have a valid virtual-physical mapping
	inside the 4mbyte kernel pagetables. So even if you have lowmemory
	machines you'll be able to test the code equally well.

	BTW, the patch has enabled some debugging code, so if you are
	going to run precise benchmarks please #undef KMAP_DEBUG in
	include/asm-i386/bigmem.h .

	Of course the code is been tested also on a 4giga amazing
	hardware:

>2.3.13 with bigmem patch is runnung on the 4GB machine. 
>Meminfo after boot shows
>
>        total:    used:    free:  shared: buffers:  cached:
>Mem:  4079742976 118927360 3960815616        0 12242944 66252800
>Swap: 134209536        0 134209536
>MemTotal:   3984124 kB
>MemFree:    3867984 kB
>MemShared:        0 kB
>Buffers:      11956 kB
>Cached:       64700 kB
>BigTotal:   3128320 kB
>BigFree:    3114564 kB
>SwapTotal:   131064 kB
>SwapFree:    131064 kB
>
>and after launching 55 "animate dna.miff" (did you ever do this on a linux
>machine? ;))
>
>        total:    used:    free:  shared: buffers:  cached:
>Mem:  4079742976 3357941760 721801216        0 12255232 68075520
>Swap: 134209536        0 134209536
>MemTotal:   3984124 kB
>MemFree:     704884 kB
>MemShared:        0 kB
>Buffers:      11968 kB
>Cached:       66480 kB
>BigTotal:   3128320 kB
>BigFree:          0 kB
>SwapTotal:   131064 kB
>SwapFree:    131064 kB
>
>Gerhard.

IMHO it would be nice if our bigmempatch would be included into the
official 2.3.x. It doesn't need heavy common code changes and we could
cleanup the code still more by putting some code out of the #ifdef
CONFIG_BIGMEM.

Comments, questions, or incremental patches are welcome of course :).

Thanks.

Andrea

begin 644 bigmem-2.3.13-L.gz
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
)`RZ2,:1H=0``
`
end

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
