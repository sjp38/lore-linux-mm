Date: Sat, 30 Jun 2007 12:05:42 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] fsblock
Message-ID: <20070630110542.GA24584@infradead.org>
References: <20070624014528.GA17609@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070624014528.GA17609@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Warning ahead:  I've only briefly skipped over the pages so the comments
in the mail are very highlevel.

On Sun, Jun 24, 2007 at 03:45:28AM +0200, Nick Piggin wrote:
> fsblock is a rewrite of the "buffer layer" (ding dong the witch is
> dead), which I have been working on, on and off and is now at the stage
> where some of the basics are working-ish. This email is going to be
> long...
> 
> Firstly, what is the buffer layer?  The buffer layer isn't really a
> buffer layer as in the buffer cache of unix: the block device cache
> is unified with the pagecache (in terms of the pagecache, a blkdev
> file is just like any other, but with a 1:1 mapping between offset
> and block).
>
> There are filesystem APIs to access the block device, but these go
> through the block device pagecache as well. These don't exactly
> define the buffer layer either.
> 
> The buffer layer is a layer between the pagecache and the block
> device for block based filesystems. It keeps a translation between
> logical offset and physical block number, as well as meta
> information such as locks, dirtyness, and IO status of each block.
> This information is tracked via the buffer_head structure.
> 

Traditional unix buffer cache is always physical block indexed and
used for all data/metadata/blockdevice node access.  There's been
a lot of variants of schemes where data or some data is in a separate
inode,logial block indexed scheme.  Most modern OSes including Linux
now always do the inode,logial block index with some noop substitute
for the metadata and block device node variants of operation.

Now what you replace is a really crappy hybrid of a traditional
unix buffercache implemented ontop of the pagecache for the block
device node (for metadata) and a lot of abuse of the same data
structure as used in the buffercache for keeping metainformation
about the actual data mapping.

> Why rewrite the buffer layer?  Lots of people have had a desire to
> completely rip out the buffer layer, but we can't do that[*] because
> it does actually serve a useful purpose. Why the bad rap? Because
> the code is old and crufty, and buffer_head is an awful name. It must 
> be among the oldest code in the core fs/vm, and the main reason is
> because of the inertia of so many and such complex filesystems.

Actually most of the code is no older than 10 years.  Just compare
fs/buffer.c in 2.2 and 2.6.  buffer_head is a perfectly fine name
for one of it's uses in the traditional buffercache.

I also thing there is little to no reason to get rid of that use:
This buffercache is what most linux block-based filesystems (except
xfs and jfs most notably) are written to, and it fits them very nicely.

What I'd really like to see is to get rid of the abuse of struct buffer_head
in the data path, and the sometimes to intimate coupling of the buffer cache
with page cache internals.

> - Data / metadata separation. I have a struct fsblock and a struct
>   fsblock_meta, so we could put more stuff into the usually less used
>   fsblock_meta without bloating it up too much. After a few tricks, these
>   are no longer any different in my code, and dirty up the typing quite
>   a lot (and I'm aware it still has some warnings, thanks). So if not
>   useful this could be taken out.


That's what I mean.  And from a quick glimpse at your code they're still
far too deeply coupled in fsblock.  Really, we don't really want to share
anything between the buffer cache and data mapping operations - they are
so deeply different that this sharing is what creates the enormous complexity
we have to deal with.

> - No deadlocks (hopefully). The buffer layer is technically deadlocky by
>   design, because it can require memory allocations at page writeout-time.
>   It also has one path that cannot tolerate memory allocation failures.
>   No such problems for fsblock, which keeps fsblock metadata around for as
>   long as a page is dirty (this still has problems vs get_user_pages, but
>   that's going to require an audit of all get_user_pages sites. Phew).

The whole concept of delayed allocation requires page allocations at
writeout time, as do various network protocols or even storage drivers.

> - In line with the above item, filesystem block allocation is performed
>   before a page is dirtied. In the buffer layer, mmap writes can dirty a
>   page with no backing blocks which is a problem if the filesystem is
>   ENOSPC (patches exist for buffer.c for this).

Not really something that is the block layers fault but rather the lazyness
of the filesystem maintainers.

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

See now why people like large order page cache so much :)

>   Large block memory access via filesystem uses vmap, but it will go back
>   to kmap if the access doesn't cross a page. Filesystems really should do
>   this because vmap is slow as anything. I've implemented a vmap cache
>   which basically wouldn't work on 32-bit systems (because of limited vmap
>   space) for performance testing (and yes it sometimes tries to unmap in
>   interrupt context, I know, I'm using loop). We could possibly do a self
>   limiting cache, but I'd rather build some helpers to hide the raw multi
>   page access for things like bitmap scanning and bit setting etc. and
>   avoid too much vmaps.

And this is a complete pain in the ass.  XFS uses vmap in it's metadata buffer
cache due to requirements carrier over from IRIX (in fact that's why I implemented
vmap in it's current form).  This works okay most of them time, but there are
a lot of scenarios where you run out of vmalloc space as you mention.  What's
also nasy is that you can't call vunmap from irq context, and vunmap beeing
rather bad for system peformance due to the tlb flushing overhead.


So as the closing comment I'd say I'd rather keep buffer_heads for metadata
for now and try to decouple the data path from it.  Your fsblock patches
are a very nice start for this, but I'd rather skip the intermediate step
towards the extent based API Dave has been outlining.  Having deal with the
I/O path of a high performance filesystem for a while per-page or sub-page
structures are a real pain to deal with and I'd really prefer to have data
structures for as much as possible blocks with the same state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
