Date: Tue, 24 Jul 2007 16:00:32 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: [PATCH RFC] extent mapped page cache
Message-ID: <20070724160032.7a7097db@think.oraclecorp.com>
In-Reply-To: <20070710210326.GA29963@think.oraclecorp.com>
References: <20070710210326.GA29963@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007 17:03:26 -0400
Chris Mason <chris.mason@oracle.com> wrote:

> This patch aims to demonstrate one way to replace buffer heads with a
> few extent trees.  Buffer heads provide a few different features:
> 
> 1) Mapping of logical file offset to blocks on disk
> 2) Recording state (dirty, locked etc)
> 3) Providing a mechanism to access sub-page sized blocks.
> 
> This patch covers #1 and #2, I'll start on #3 a little later next
> week.
> 
Well, almost.  I decided to try out an rbtree instead of the radix,
which turned out to be much faster.  Even though individual operations
are slower, the rbtree was able to do many fewer ops to accomplish the
same thing, especially for merging extents together.  It also uses much
less ram.

This code still has lots of room for optimization, but it comes in at
around 2-5% more cpu time for ext2 streaming reads and writes.  I
haven't done readpages or writepages yet, so this is more or less a
worst case setup.  I'm comparing against ext2 with readpages and
writepages disabled.

The new code has the added benefit of passing fsx-linux, and not
triggering MCE's on my poor little test box.

The basic idea is to store state in byte ranges in an rbtree, and to
mirror that state down into individual pages.  This allows us to store
arbitrary state outside of the page struct, so we could include the pid
of the process that dirtied a page range for cfq purposes.  The example
readpage and writepage code is probably the easiest way to understand
the basic API.

A separate rbtree stores a mapping of byte offset in the file to byte
offset on disk.  This allows the filesystem to fill in mapping
information in bulk, and reduces the number of metadata lookups
required to do common operations.

Because the state and mapping information are separate from the page,
pages can come and go and their corresponding metadata can still be
cached (the current code drops mappings as the last page corresponding
to that mapping disappears).

Two patches follow, the core extent_map implementation and a sample
user (ext2).  This is pretty basic, implementing prepare/commit_write,
read/writepage and a few other funcs to exercise the new code.  Longer
term, it should fit in with Nick's other extent work instead of
prepare/commit_write.

My patch sets page->private to 1, really for no good reason.  It is
just a debugging aid I was using to make sure the page took the right
path down the line.  If this catches on, we might set it to a magic
value so you can if (ExtentPage(page)) or just leave it as null.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
