Subject: Re: MM question
References: <Pine.LNX.3.95.990221161643.24011A-100000@as200.spellcast.com>
From: Magnus Ahltorp <map@stacken.kth.se>
Date: 22 Feb 1999 22:13:09 +0100
In-Reply-To: "Benjamin C.R. LaHaise"'s message of "Sun, 21 Feb 1999 16:34:32 -0500 (EST)"
Message-ID: <ixdn2266t22.fsf@turbot.pdc.kth.se>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The code listed is just plain wrong -- it doesn't take into account pages
> that are already present in the page cache.  If you need to use this
> technique, take a look at mm/filemap.c:generic_file_write for an example
> of how to do this properly (mostly, find the page in the page cache, if
> not found add it; lock page in page cache). 

Since I didn't write the code myself, it doesn't express my
intentions, but rather someone else's, so don't look at it too much.

> Could you clairify how you're doing things?  Are pages cached in the
> kernel owned by your filesystem's inode or ext2's?  The hint I'm getting
> from the code you quoted is the both are storing the data, which is
> inefficient.  The easiest thing to do would be to tunnel all operations to
> the ext2 inode -- your filesystem should not have a readpage function.
> Rather, mmap(), read() and write() all receive the ext2 inode of the file,
> so that all pages in memory are owned by the ext2 inode, and your inode is
> merely an indirect handle that validates the cache.  How's that sound?

Right now, an Arla inode has some extra information, containing a
dentry for the cache file. The readpage() function just validates the
cache information, fills in a struct file (with the ext2 inode) and
calls ext2's readpage(). The struct page pointer is passed along to
ext2's readpage() without any modifications.

The write() does pretty much the same thing, just that here the data
is passed via a pointer and a length.

I don't really know what's supposed to happen during a readpage()
call, and what I want is a way to make write() affect the pages that
readpage() has read.

(I might sound somewhat disoriented, but that is because I am)

If you want to have a look at the particular source, the relevant file
is http://www.stacken.kth.se/~map/src/cvs/arla/xfs/linux/xfs_inodeops.c
(xfs_readpage() and xfs_write_file()).

/Magnus
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
