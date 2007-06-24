Date: Sun, 24 Jun 2007 03:45:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [RFC] fsblock
Message-ID: <20070624014528.GA17609@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I'm announcing "fsblock" now because it is quite intrusive and so I'd
like to get some thoughts about significantly changing this core part
of the kernel.

fsblock is a rewrite of the "buffer layer" (ding dong the witch is
dead), which I have been working on, on and off and is now at the stage
where some of the basics are working-ish. This email is going to be
long...

Firstly, what is the buffer layer?  The buffer layer isn't really a
buffer layer as in the buffer cache of unix: the block device cache
is unified with the pagecache (in terms of the pagecache, a blkdev
file is just like any other, but with a 1:1 mapping between offset
and block).

There are filesystem APIs to access the block device, but these go
through the block device pagecache as well. These don't exactly
define the buffer layer either.

The buffer layer is a layer between the pagecache and the block
device for block based filesystems. It keeps a translation between
logical offset and physical block number, as well as meta
information such as locks, dirtyness, and IO status of each block.
This information is tracked via the buffer_head structure.

Why rewrite the buffer layer?  Lots of people have had a desire to
completely rip out the buffer layer, but we can't do that[*] because
it does actually serve a useful purpose. Why the bad rap? Because
the code is old and crufty, and buffer_head is an awful name. It must 
be among the oldest code in the core fs/vm, and the main reason is
because of the inertia of so many and such complex filesystems.

[*] About the furthest we could go is use the struct page for the
information otherwise stored in the buffer_head, but this would be
tricky and suboptimal for filesystems with non page sized blocks and
would probably bloat the struct page as well.

So why rewrite rather than incremental improvements? Incremental
improvements are logically the correct way to do this, and we probably
could go from buffer.c to fsblock.c in steps. But I didn't do this
because: a) the blinding pace at which things move in this area would
make me an old man before it would be complete; b) I didn't actually
know exactly what it was going to look like before starting on it; c)
I wanted stable root filesystems and such when testing it; and d) I
found it reasonably easy to have both layers coexist (it uses an extra
page flag, but even that wouldn't be needed if the old buffer layer
was better decoupled from the page cache).

I started this as an exercise to see how the buffer layer could be
improved, and I think it is working out OK so far. The name is fsblock
because it basically ties the fs layer to the block layer. I think
Andrew has wanted to rename buffer_head to block before, but block is
too clashy, and it isn't a great deal more descriptive than buffer_head.
I believe fsblock is.

I'll go through a list of things where I have hopefully improved on the
buffer layer, off the top of my head. The big caveat here is that minix
is the only real filesystem I have converted so far, and complex
journalled filesystems might pose some problems that water down its
goodness (I don't know).

- data structure size. struct fsblock is 20 bytes on 32-bit, and 40 on
  64-bit (could easily be 32 if we can have int bitops). Compare this
  to around 50 and 100ish for struct buffer_head. With a 4K page and 1K
  blocks, IO requires 10% RAM overhead in buffer heads alone. With
  fsblocks you're down to around 3%.

- Structure packing. A page gets a number of buffer heads that are
  allocated in a linked list. fsblocks are allocated contiguously, so
  cacheline footprint is smaller in the above situation.

- Data / metadata separation. I have a struct fsblock and a struct
  fsblock_meta, so we could put more stuff into the usually less used
  fsblock_meta without bloating it up too much. After a few tricks, these
  are no longer any different in my code, and dirty up the typing quite
  a lot (and I'm aware it still has some warnings, thanks). So if not
  useful this could be taken out.

- Locking. fsblocks completely use the pagecache for locking and lookups.
  The page lock is used, but there is no extra per-inode lock that buffer
  has. Would go very nicely with lockless pagecache. RCU is used for one
  non-blocking fsblock lookup (find_get_block), but I'd really rather hope
  filesystems can tolerate that blocking, and get rid of RCU completely.
  (actually this is not quite true because mapping->private_lock is still
  used for mark_buffer_dirty_inode equivalent, but that's a relatively
  rare operation).

- Coupling with pagecache metadata. Pagecache pages contain some metadata
  that is logically redundant because it is tracked in buffers as well
  (eg. a page is dirty if one or more buffers are dirty, or uptodate if
  all buffers are uptodate). This is great because means we can avoid that
  layer in some situations, but they can get out of sync. eg. if a
  filesystem writes a buffer out by hand, its pagecache page will stay
  dirty, and the next "writeout" will notice it has no dirty buffers and
  call it clean. fsblock-based writeout or readin will update page
  metadata too, which is cleaner. It also uses page locking for IO ops
  instead of an extra layer of locking which seems nice.

- No deadlocks (hopefully). The buffer layer is technically deadlocky by
  design, because it can require memory allocations at page writeout-time.
  It also has one path that cannot tolerate memory allocation failures.
  No such problems for fsblock, which keeps fsblock metadata around for as
  long as a page is dirty (this still has problems vs get_user_pages, but
  that's going to require an audit of all get_user_pages sites. Phew).

- In line with the above item, filesystem block allocation is performed
  before a page is dirtied. In the buffer layer, mmap writes can dirty a
  page with no backing blocks which is a problem if the filesystem is
  ENOSPC (patches exist for buffer.c for this).

- Block memory accessors for filesystems. If the buffer layer was to ever
  be replaced completely, this means block device pagecache would not be
  restricted to lowmem. It also doesn't have theoretical CPU cache
  aliasing problems that buffer heads do.

- A real "nobh" mode. nobh was created I think mainly to avoid problems
  with buffer_head memory consumption, especially on lowmem machines. It
  is basically a hack (sorry), which requires special code in filesystems,
  and duplication of quite a bit of tricky buffer layer code (and bugs).
  It also doesn't work so well for buffers with non-trivial private data
  (like most journalling ones). fsblock implements this with basically a
  few lines of code, and it shold work in situations like ext3.

- Similarly, it gets around the circular reference problem where a buffer
  holds a ref on a page and a page holds a ref on a buffer, but the page
  has been removed from pagecache. These occur with some journalled fses
  like ext3 ordered, and eventually fill up memory and have to be
  reclaimed via the LRU (which is often not a problem, but I have seen
  real workloads where the reclaim causes throughput to drop quite a lot).

- An inode's metadata must be tracked per-inode in order for fsync to
  work correctly. buffer contains helpers to do this for basic
  filesystems, but any block can be only the metadata for a single inode.
  This is not really correct for things like inode descriptor blocks.
  fsblock can track multiple inodes per block. (This is non trivial,
  and it may be overkill so it could be reverted to a simpler scheme
  like buffer).

- Large block support. I can mount and run an 8K block size minix3 fs on
  my 4K page system and it didn't require anything special in the fs. We
  can go up to about 32MB blocks now, and gigabyte+ blocks would only
  require  one more bit in the fsblock flags. fsblock_superpage blocks
  are > PAGE_CACHE_SIZE, midpage ==, and subpage <.

  Core pagecache code is pretty creaky with respect to this. I think it is
  mostly race free, but it requires stupid unlocking and relocking hacks
  because the vm usually passes single locked pages to the fs layers, and we
  need to lock all pages of a block in offset ascending order. This could be
  avoided by doing locking on only the first page of a block for locking in
  the fsblock layer, but that's a bit scary too. Probably better would be to
  move towards offset,length rather than page based fs APIs where everything
  can be batched up nicely and this sort of non-trivial locking can be more
  optimal.

  Large blocks also have a performance black spot where an 8K sized and
  aligned write(2) would require an RMW in the filesystem. Again because of
  the page based nature of the fs API, and this too would be fixed if
  the APIs were better.

  Large block memory access via filesystem uses vmap, but it will go back
  to kmap if the access doesn't cross a page. Filesystems really should do
  this because vmap is slow as anything. I've implemented a vmap cache
  which basically wouldn't work on 32-bit systems (because of limited vmap
  space) for performance testing (and yes it sometimes tries to unmap in
  interrupt context, I know, I'm using loop). We could possibly do a self
  limiting cache, but I'd rather build some helpers to hide the raw multi
  page access for things like bitmap scanning and bit setting etc. and
  avoid too much vmaps.

- Code size. I'm sure I'm still missing some things, but at the moment we
  can do this in about the same amount of icache as buffer.c. If we turn
  off large block support, I think it is around 2/3 the size.

That's basically it for now. I have a few more ideas for cool things, but
there are only so many hours in a day. Comments are non-existant so far,
and there is lots of debugging stuff and some things are a little dirty,
but it should be slightly familiar if you understand buffer.c. I'm not so
interested in hearing about trivial nitpicking at this point because things
are far from final or proposed for upstream. There is still a race or two,
but I think they can all be solved.

So. Comments? Is this something we want? If yes, then how would we
transition from buffer.c to fsblock.c?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
