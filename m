Date: Mon, 11 Oct 1999 20:11:38 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: simple slab alloc question
In-Reply-To: <19991011131021.A952@fred.muc.de>
Message-ID: <Pine.LNX.4.10.9910112007250.26190-100000@imladris.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Oct 1999, Andi Kleen wrote:
> On Mon, Oct 11, 1999 at 12:09:47AM +0200, Jeff Garzik wrote:
> > kmalloc seems to allocate against various kmem_cache sizes: 32,
> > 64...1024...65536...
> > 
> > Does this mean that allocations of various sizes are stored in different
> > "buckets"?  Would that not reduce fragmentation and the need for a zone
> > allocator?
> 
> kmalloc uses these buckets. Other clients use their own slab pool
> (e.g. skb headers etc.). This is a variant of a zone allocator,
> but only for relatively small objects.
> 
> Slab sits on top of the page allocator and is on its mercy.

Indeed.

> Even other major users get their pages from the page allocator
> directly (inodes, dcache). These used to be (still are?) a major
> source of fragmentation, because they tend to wire whole pages
> down even where there is only a single active inode/dentry on it.

A zone allocator would not help in this case. A zone
which has only one active inode/dentry on it is just
as wired down as a normal page.

What we need here is a trick to emergency-recycle the
last two(?) inodes on a page when memory is short. Of
course the real number should be calculated by memory
pressure, but I don't have time to think about that
now :)

> The page allocator uses the buddy algorithm, which is very prone
> to fragmentation.

> The basic idea is to replace the buddy with another zone allocator.

I hope to be working on a design for something like that from
december onwards. With a bit of luck the first code will be
ready just before we begin the 2.5 development cycle.

(doing things earlier doesn't make much sense and we're too
late for 2.4 anyway)

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.
--
work at:	http://www.reseau.nl/
home at:	http://www.nl.linux.org/~riel/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
