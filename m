Date: Mon, 11 Oct 1999 13:10:21 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: simple slab alloc question
Message-ID: <19991011131021.A952@fred.muc.de>
References: <38010EAB.ACC45162@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <38010EAB.ACC45162@pobox.com>; from Jeff Garzik on Mon, Oct 11, 1999 at 12:09:47AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@pobox.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 11, 1999 at 12:09:47AM +0200, Jeff Garzik wrote:
> kmalloc seems to allocate against various kmem_cache sizes: 32,
> 64...1024...65536...
> 
> Does this mean that allocations of various sizes are stored in different
> "buckets"?  Would that not reduce fragmentation and the need for a zone
> allocator?

kmalloc uses these buckets. Other clients use their own slab pool (e.g.
skb headers etc.). This is a variant of a zone allocator, but only
for relatively small objects.

Slab sits on top of the page allocator and is on its mercy.

Even other major users get their pages from the page allocator directly
(inodes, dcache). These used to be (still are?) a major source of 
fragmentation, because they tend to wire whole pages down even where there
is only a single active inode/dentry on it.

The page allocator uses the buddy algorithm, which is very prone
to fragmentation. Usually when you suffer from fragmentation there are 
simply not enough continous pages left, and the Linux MM datastructures
are not suited to do some organized effort to get them back.

The basic idea is to replace the buddy with another zone allocator.


> 
> Enlightenment from MM gurus appreciated :)

I'm not a mm guru, but I hope it was helpful.

-Andi

-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
