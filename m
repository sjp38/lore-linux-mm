Date: Sun, 21 Feb 1999 16:34:32 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: MM question
In-Reply-To: <ixdpv73a5z2.fsf@turbot.pdc.kth.se>
Message-ID: <Pine.LNX.3.95.990221161643.24011A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Magnus Ahltorp <map@stacken.kth.se>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 21 Feb 1999, Magnus Ahltorp wrote:
...
> I inserted this piece of code, and things worked quite well. After a
> while, I was seeing new problems. Writes were not propagating properly
> to the cache file.

The code listed is just plain wrong -- it doesn't take into account pages
that are already present in the page cache.  If you need to use this
technique, take a look at mm/filemap.c:generic_file_write for an example
of how to do this properly (mostly, find the page in the page cache, if
not found add it; lock page in page cache). 

> Does anyone have any suggestions on how this really should be done?

Could you clairify how you're doing things?  Are pages cached in the
kernel owned by your filesystem's inode or ext2's?  The hint I'm getting
from the code you quoted is the both are storing the data, which is
inefficient.  The easiest thing to do would be to tunnel all operations to
the ext2 inode -- your filesystem should not have a readpage function.
Rather, mmap(), read() and write() all receive the ext2 inode of the file,
so that all pages in memory are owned by the ext2 inode, and your inode is
merely an indirect handle that validates the cache.  How's that sound?

		-ben



--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
