Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA26009
	for <linux-mm@kvack.org>; Wed, 19 May 1999 12:33:27 -0400
Date: Wed, 19 May 1999 18:28:04 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [VFS] move active filesystem
In-Reply-To: <19990518183725.B30692@caffeine.ix.net.nz>
Message-ID: <Pine.LNX.4.05.9905191820290.3829-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Wedgwood <cw@ix.net.nz>
Cc: Gabor Lenart <lgb@oxygene.terra.vein.hu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 May 1999, Chris Wedgwood wrote:

>> And what about a more inteligent DMA memory allocator ? I mean, in
>> case of fragmented memory it's very frequent not to success to
>> allocate DMA memory by kernel (eg by sound/floppy modules). Why
>> does not kernel moves some memory, changing some pagetable entries
>> etc to create contigous memory area suitable for DMA (in low 16M
>> for ISA DMA, care of page boundaries etc). If there's enough memory
>> to do it, it would be only some memory moving action to get the
>> suitable place.
>> 
>> (I don't know too much about Linux kernel internals, maybe DMA
>> memory allocating is something atomic operation which blocks the
>> kernel too long to do such an operation I described below ?)
>
>Right now, we can't tell which pages are in use by what, so moving

Not really. We obviously can, but not in O(1). I could just add the logic
to have the information in O(1), but then you must know that at every
allocation you'll have to insert a entry in a queue, and remove an entry
from a queue at every umapping/freeing of memory. Anyway I'll think I'll
do that very soon to improve and simplify a lot my update_shared_mappings
and many other similar thing in order to handle all such things in O(1).
(and btw with such info my new shrink_mmap will be also able to unmap and
free page/swap cache directly from the pagemap-lru (I am talking about my
current code, the stock kernel doesn't have a real lru))

BTW, allowing dirty pages in the page cache may avoid I/O to disk but
won't avoid memcpy data to the page cache even if the page cache was just
uptdate. So I am convinced right now update_shared_mappings() is the right
thing to do and it's not an dirty hack. It's only a not very efficient
implementation that has to play with pgd/pmd/pte because we don't have
enough information (yet) from the pagemap.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
