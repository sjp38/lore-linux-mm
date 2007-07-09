Date: Mon, 9 Jul 2007 10:14:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] fsblock
In-Reply-To: <20070624014528.GA17609@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0707091002170.15696@schroedinger.engr.sgi.com>
References: <20070624014528.GA17609@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Jun 2007, Nick Piggin wrote:

> Firstly, what is the buffer layer?  The buffer layer isn't really a
> buffer layer as in the buffer cache of unix: the block device cache
> is unified with the pagecache (in terms of the pagecache, a blkdev
> file is just like any other, but with a 1:1 mapping between offset
> and block).

I thought that the buffer layer is essentially a method to index to sub 
section of a page?

> Why rewrite the buffer layer?  Lots of people have had a desire to
> completely rip out the buffer layer, but we can't do that[*] because
> it does actually serve a useful purpose. Why the bad rap? Because
> the code is old and crufty, and buffer_head is an awful name. It must 
> be among the oldest code in the core fs/vm, and the main reason is
> because of the inertia of so many and such complex filesystems.

Hmmm.... I did not notice that yet but then I have not done much work 
there.

> - data structure size. struct fsblock is 20 bytes on 32-bit, and 40 on
>   64-bit (could easily be 32 if we can have int bitops). Compare this
>   to around 50 and 100ish for struct buffer_head. With a 4K page and 1K
>   blocks, IO requires 10% RAM overhead in buffer heads alone. With
>   fsblocks you're down to around 3%.

I thought we were going to simply use the page struct instead of having
buffer heads? Would that not reduce the overhead to zero?

> - Structure packing. A page gets a number of buffer heads that are
>   allocated in a linked list. fsblocks are allocated contiguously, so
>   cacheline footprint is smaller in the above situation.

Good idea.

> - A real "nobh" mode. nobh was created I think mainly to avoid problems
>   with buffer_head memory consumption, especially on lowmem machines. It
>   is basically a hack (sorry), which requires special code in filesystems,
>   and duplication of quite a bit of tricky buffer layer code (and bugs).
>   It also doesn't work so well for buffers with non-trivial private data
>   (like most journalling ones). fsblock implements this with basically a
>   few lines of code, and it shold work in situations like ext3.

Hmmm.... That means simply page struct are not working...
 
> - Large block support. I can mount and run an 8K block size minix3 fs on
>   my 4K page system and it didn't require anything special in the fs. We
>   can go up to about 32MB blocks now, and gigabyte+ blocks would only
>   require  one more bit in the fsblock flags. fsblock_superpage blocks
>   are > PAGE_CACHE_SIZE, midpage ==, and subpage <.
> 
>   Core pagecache code is pretty creaky with respect to this. I think it is
>   mostly race free, but it requires stupid unlocking and relocking hacks
>   because the vm usually passes single locked pages to the fs layers, and we
>   need to lock all pages of a block in offset ascending order. This could be
>   avoided by doing locking on only the first page of a block for locking in
>   the fsblock layer, but that's a bit scary too. Probably better would be to
>   move towards offset,length rather than page based fs APIs where everything
>   can be batched up nicely and this sort of non-trivial locking can be more
>   optimal.
> 
>   Large blocks also have a performance black spot where an 8K sized and
>   aligned write(2) would require an RMW in the filesystem. Again because of
>   the page based nature of the fs API, and this too would be fixed if
>   the APIs were better.

The simple solution would be to use a compound page and make the head page
represent the status of all the pages in the vm. Logic for that is already 
in place.

>   Large block memory access via filesystem uses vmap, but it will go back
>   to kmap if the access doesn't cross a page. Filesystems really should do
>   this because vmap is slow as anything. I've implemented a vmap cache
>   which basically wouldn't work on 32-bit systems (because of limited vmap
>   space) for performance testing (and yes it sometimes tries to unmap in
>   interrupt context, I know, I'm using loop). We could possibly do a self
>   limiting cache, but I'd rather build some helpers to hide the raw multi
>   page access for things like bitmap scanning and bit setting etc. and
>   avoid too much vmaps.

Argh. No. Too much overhead.
 
> So. Comments? Is this something we want? If yes, then how would we
> transition from buffer.c to fsblock.c?

I think many of the ideas are great but the handling of large pages is 
rather strange. I would suggest to use compound pages to represent larger 
pages and rely on Mel Gorman's antifrag/compaction work to get you the 
contiguous memory locations instead of using vmap. This may significantly 
simplify your patchset and avoid changes to the filesytesm API. Its still 
pretty invasive though and I am not sure that there is enough benefit from 
this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
