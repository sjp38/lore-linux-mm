Received: from hermes.rz.uni-sb.de (hermes.rz.uni-sb.de [134.96.7.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA24745
	for <linux-mm@kvack.org>; Wed, 10 Feb 1999 12:08:09 -0500
Message-ID: <005001be5517$e06903e0$c80c17ac@clmsdev>
From: "Manfred Spraul" <masp0008@stud.uni-sb.de>
Subject: Re: Large memory system
Date: Wed, 10 Feb 1999 18:02:32 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>The primary reason for adding more memory is for process anonymous
>pages, not for cache, so this is really of limited value on its own.


This was not intended as a solution, but as a new idea:
- the memory > 1 GB is allocated one page at a time.
- some 'struct page' fields are useless for high memory.
- if someone who is not prepared to handle high memory finds such a page,
the computer will crash anyway.
- high memory needs bounce buffers, so a special if(highmem()) is required.
---> no need to use mem_map, add an independant array for high_mem.

The advantage is that you can add new fields to such an array (e.g. true
LRU for a cache), without causing problems in the remaining kernel.

If you restrict the remaining memory to unshared pages (i.e. no COW), then
the implementation should be really simple:

* all page-in's go to normal memory (i.e. < 1 GB) (swap cache compatible)
* if try_to_swap_out() want's to discard a page, it is first moved to high
memory.
(this break's any COW links.)
* if <shrink_highmem> decides that a page should be discarded, then the page
is removed from the vma, a bounce buffer is created, written out & added to
the swap cache.

I'm sure that this could be extended to COW pages, but I haven't yet
understood the COW implementation :=)

Regards,
    Manfred




--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
