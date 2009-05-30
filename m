Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EBA5A6B00D9
	for <linux-mm@kvack.org>; Sat, 30 May 2009 13:02:54 -0400 (EDT)
Date: Sat, 30 May 2009 10:00:31 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530170031.GD6535@oblivion.subreption.com>
References: <20090522073436.GA3612@elte.hu> <20090530054856.GG29711@oblivion.subreption.com> <1243679973.6645.131.camel@laptop> <4A211BA8.8585.17B52182@pageexec.freemail.hu> <1243689707.6645.134.camel@laptop> <20090530153023.45600fd2@lxorguk.ukuu.org.uk> <1243694737.6645.142.camel@laptop> <4A214752.7000303@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A214752.7000303@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu, Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Alright, I wrote some small programs to test the data remanence on
memory. It works in a really simple way and functionality is provided by
three different tools:

	scanleak.c
	Scans physical memory (using /dev/mem) looking for the
	ulonglong pattern. Filtered /dev/mem access breaks this, so
	disable it temporarily in your kernel to use it.

	secretleak.c
	Writes the ulonglong pattern to memory (takes two arguments, a size
	in MB, and a number of seconds to delay after free).

	zeromem.c
	Zeroes all or given MBs of memory (allocating blocks of 100M which
	are contiguous). If no argument is given, it allocates more
	blocks to ensure we can zero past the used memory (might hit
	swap). This can be used to simulate memory workload.

I've done the following test (x86 vm, 600M RAM, 2.6.29.4):

	1. ./secretleak 600 1

Will allocate 629145600 bytes (600M).
Zeroing buffer at 0x926bb008... Done.
Writing pattern to 0x926bb008 (402A25246B61654C)... Done.
Freeing buffer at 0x926bb008... Done.
Sleeping for 1 seconds...

	2. (2 minutes afterwards) ./zeromem 700

Zeroing 734003200 bytes of memory
Zeroing block at 0xb1b01008 (104857600 bytes, 102400 kB)
Zeroing block at 0xab700008 (104857600 bytes, 102400 kB)
Zeroing block at 0xa52ff008 (104857600 bytes, 102400 kB)
Zeroing block at 0x9eefe008 (104857600 bytes, 102400 kB)
Zeroing block at 0x98afd008 (104857600 bytes, 102400 kB)
Zeroing block at 0x926fc008 (104857600 bytes, 102400 kB)
Zeroing block at 0x8c2fb008 (104857600 bytes, 102400 kB)
Freeing block at 0xb1b01008.
Freeing block at 0xab700008.
Freeing block at 0xa52ff008.
Freeing block at 0x9eefe008.
Freeing block at 0x98afd008.
Freeing block at 0x926fc008.
Freeing block at 0x8c2fb008.

	3. Immediately afterwards, sudo ./scanleak | grep Found | wc -l
	   Reports 142 occurrences.

	4. Re-issue ./zeromem 700

	5. Re-scan memory, only three occurrences:

Scanning 617398272 bytes of memory from /dev/mem...
 Found pattern at 0x70d41e8 (402A25246B61654C)
 Found pattern at 0xf5931f8 (402A25246B61654C)
 Found pattern at 0xf5e11e8 (402A25246B61654C)

The scanning is PAGE_SIZE aligned, and only one occurrence is considered
per page (otherwise the output would be hideous in kernels without
sanitization).

Those three occurrences will stay there indefinitely... like the PaX
team said, the remanence is proportional to the size of the allocations
and data itself. The more data allocated, the more time it takes for
that memory to be requested back by some other user (kernel or non
kernel). An even more simple test would be to load a file with vim or
nano, which contains a large (of hundred of megabytes magnitude) amount
of text patterns (a md5 hash works), and monitor RAM to see how long it
stays there after you have closed the editor. While most of it will
slowly disappear, at least there will some gaps that will remain for a
long time, possibly days, even under irregular high workloads.

I'm compiling a kernel with my current patches and will report back with
the results of these tools on that one. It will be 2.6.29.4 as well.

I'll make the sources of the tools available somewhere. Because of
corporate policy It might be wiser to find a place where I can make
this stuff available for longer time periods. Does anyone know the
process to request space under pub/linux/kernel/people/?

	Larry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
