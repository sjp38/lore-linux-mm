Date: Sun, 7 May 2000 10:22:06 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] address_space_operations unification
In-Reply-To: <20000507114333.A342@loth.demon.co.uk>
Message-ID: <Pine.LNX.4.10.10005071009080.30202-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Dodd <steved@loth.demon.co.uk>
Cc: Alexander Viro <aviro@redhat.com>, "Roman V. Shaposhnick" <vugluskr@unicorn.math.spbu.ru>, linux-fsdevel@vger.rutgers.edu, linux-kernel@vger.rutgers.edu, trond.myklebust@fys.uio.no, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 7 May 2000, Steve Dodd wrote:
> > 
> > And people then _applaud_ this move?
> 
> Because AFAICS a struct address_space should be usable for caching /anything/
> in the page cache, not just file data.

Note that you can do this already.

You cannot use the VFS operations on it, though. If you want to use the
address-space as a non-VFS thing, then you need can only do lookups, and
we already have the infrastructure for that in place.

So if you want to use the page cache _only_ for caching pages, you already
have __add_to_page_cache{_unique}() and __find_lock_page(), which truly
don't care about any VFS behaviour.

Note that the page cache is really meant to be a support structure for the
UNIX operations: read, write and mmap. You _can_ use it for other things,
but then the onus of using it for those other things should not be on the
regular operations. 

Basically, don't make the normal operations uglier just because you also
want to use the cache for something else.

> Actually, thinking about this, is there any point now where the generic page
> cache code calls address_space methods? I've just looked, and AFAICS all the
> calls are from the filemap code. I thought the original idea was that an
> address_space should contain the data and function ptrs to allow the page
> cache to go about its business without caring what the data was used
> for. We don't actually seem to be doing that, other than the new sync_page.
> Some of the methods also look downright wrong for this - ->bmap at least
> should be an inode op, surely? 

One of the main things with the "address_space" thing is not that it
removes the VFS logic from the path, but the fact that it adds an extra
layer of indirection. And as Knuth (or somebody) said: you can solve any
problem in CS by adding another level of indirection.

The problem the indirection solves is one of multiple inodes sharing the
same address space. Which used to be impossible due to using the inode for
the index. 

Why would you want to share address spaces between inodes? Coda was one
filesystem that wants to do exactly that: it has both the "coda" side of
a file, and then that file is also cached locally on a local filesystem.
So the "coda inode" actually wants to share the address space entirely
with the native (ie ext2 or whatever) filesystem.

This was the thing that convinced me about address spaces as separate
entities from the inode. But it does not mean that I want to entirely
sever the connection.

> I was hoping to use the addr_space stuff to cache fs metadata easily - NTFS
> for example has on-disk structures which span blocks, so using the buffer
> cache is out. Sure, I could code up a private cache, but then the mm subsystem
> has no way to tell me to prune data as memory pressure increases.

This is a longer-term goal. No question about it. It should be doable
right now, albeit probably with some rather ugly hacks (but note that the
ugly hacks would not be in generic code, but in the low-level FS - if
there are ugly hacks I much prefer them that way, thank you). Things like
just creating a fake inode for it (I'm not convinced that is even
required, but I've not tried to actually write the code, so problems that
require it might well crop up).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
