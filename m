Received: from flinx.npwt.net (npwt@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA32405
	for <linux-mm@kvack.org>; Sun, 2 Aug 1998 04:18:03 -0400
Date: Sun, 2 Aug 1998 00:19:52 -0500 (CDT)
From: Eric W Biederman <eric@flinx.npwt.net>
Reply-To: ebiederm+eric@npwt.net
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <199807271102.MAA00713@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.4.02.9808020002110.424-100000@iddi.npwt.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 27 Jul 1998, Stephen C. Tweedie wrote:

> Hi,
> 
> On Sun, 26 Jul 1998 09:49:02 -0500 (CDT), Eric W Biederman
> <eric@flinx.npwt.net> said:
> 
> > From where I sit it looks completly possible to give the buffer cache a
> > fake inode, and have it use the same mechanisms that I have developed for
> > handling other dirty data in the page cache.  It should also be possible
> > in this effort to simplify the buffer_head structure as well.
> 
> > As time permits I'll move in that direction.
> 
> You'd still have to persuade people that it's a good idea.  I'm not
> convinced.
> 
> The reason for having things in the page cache is for fast lookup.
> For this to make sense for the buffer cache, you'd have to align the
> buffer cache on page boundaries, but buffers on disk are not naturally
> aligned this way.  You'd end up wasting a lot of space as perhaps only
> a few of the buffers in any page were useful, and you'd also have to
> keep track of which buffers within the page were valid/dirty.
> 

That wasn't actually how I was envisioning it.  Though it is a possibility
I have kicked around.  For direct device I/O and mmaping of devices it is
exactly how we should do it.  

What I was envisioning is using a single write-out daemon 
instead of 2 (one for buffer cache, one for page cache).  Using the same
tests in shrink_mmap.  Reducing the size of a buffer_head by a lot because
consolidating the two would reduce the number of lists needed.  
To sit the buffer cache upon a single pseudo inode, and keep it's current
hashing scheme.

In general allowing the management to be consolidated between the two, but
nothing more.

At this point it is not a major point, but the buffer cache is
quite likely to shrink into something barely noticeable, assuming
regular files will write buffer themselves in the page cache preventing
double buffering.

When the buffer cache becomes a shrunken appendage then we will know what
we really need it for, and how much a performance hit we will take, and
we can worry about it then.

> We *need* a mechanism which is block-aligned, not page-aligned.  The
> buffer cache is a good way of doing it.  Forcing block device caching
> into a page-aligned cache is not necessarily going to simplify things.

The page-aligned property is only a matter of the inode,offset hash
table, and virtually nothing else really cares.  Shrink_mmap, or
pgflush, the most universall parts of the page cache do not.

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
