Received: from alogconduit1ah.ccr.net (ccr@alogconduit1ah.ccr.net [208.130.159.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA13635
	for <linux-mm@kvack.org>; Thu, 8 Apr 1999 21:31:18 -0400
Subject: Re: persistent heap design advice
References: <013f01be81e4$88f07860$0201a8c0@edison.inter-tax.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
In-Reply-To: "Keith Morgan"'s message of "Thu, 8 Apr 1999 12:23:36 -0500"
Date: 08 Apr 1999 20:42:58 -0500
Message-ID: <m1ogkywov1.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Keith Morgan <kmorgan@inter-tax.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "KM" == Keith Morgan <kmorgan@inter-tax.com> writes:

KM> I am interested in creating a persistent heap library and would
KM> appreciate any suggestions on how to proceed. The 'persistent heap'
KM> would be a region of virtual memory backed by a file and could be
KM> expanded or contracted.

KM> In order to build my 'persistent heap' it seems like I need a
KM> fundamental facility that isn't provided by Linux. Please correct me if
KM> I'm wrong! It would be something like mmap() ... but different. The
KM> facility call it phmap for starters) would:

What do you see missing??
You obviously need a allactor built on top of your mmaped file but
besides that I don't see anything missing.

KM> -map virtual addresses to a user-specified file
mmap MAP_SHARED

KM> -coordinate the expansion/contraction of the file and the virtual
KM> address space
ftruncate, mmap, munmap

KM> -provide ram cache [of user-specified number of pages (cache itself is
KM> nonpagable)]*
why?? mlock

KM> -provide load-on-demand of data from the file into the cache
mmap MAP_SHARED

KM> -swap LRU pages back to the file when cache full
mmap MAP_SHARED


KM> []* I'm not sure if this is the right approach. I want to avoid paging
KM> out user program/data when traversing very large 'persistent heaps'.

Assuming a large persistent heap is larger than memory you can't help
but avoiding paging your heap.  Not paging other things much is to be desired of course.

An implementtion of madvise (so you can say which pages you aren't going to need for a while
and which pages you will be needing soon) is the only piece of the puzzle I see as
missing.

KM> I an interested in writing at the highest possible level to create the
KM> phmap facility. At this point my questions are very broad (I'm not
KM> looking for a cookbook, just trying to prune the search space):

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
