Date: Wed, 8 Dec 1999 18:54:41 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: sizeof(struct page) from 44 to 32 bytes for 32-bit <256MB
In-Reply-To: <E11vl73-00012G-00@sable.ox.ac.uk>
Message-ID: <Pine.LNX.4.10.9912081845560.596-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Malcolm Beattie <mbeattie@sable.ox.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 1999, Malcolm Beattie wrote:

>too). That means that a lot of uses of struct page only use a single
>cache line per touched struct page instead of two.

Using two cachelines could produce better performances depending on the
layout and on the usage of the entries in the struct. So it's not enough
to tell that it takes only on cacheline to say that it will be faster.

>The idea is to replace the various struct page pointers (4 bytes) with
>a 2 byte page frame number which can then cope with 64K x 4K = 256MB
>physical RAM. The relevant pointers are the struct page * fields (two

IMHO it will decrease too much performacnes. Both ->list and ->lru are
very hot piece of code. When you shrink the cache you want to delete pages
from the page-LRU ASAP and you don't want to spend time in
(pfn<<PAGE_SHIFT)+PAGE_OFFSET. The same is true for malloc(2) and free(2).

>then optimize for other architectures too. For example, Alpha and
>sparc64 could use a 32-bit pfn instead of a 64-bit pointer in all
>those places which would again save cacheline space.

Avoiding the (pfn<<PAGE_SHIFT)+PAGE_OFFSET is an issue for Alpha and
Sparc64 too.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
