Message-ID: <00db01c0a066$dfc7de60$0beda8c0@netapp.com>
From: "Chuck Lever" <Charles.Lever@netapp.com>
References: <Pine.LNX.4.30.0102261829330.5576-100000@today.toronto.redhat.com>
Subject: Re: 2.5 page cache improvement idea
Date: Mon, 26 Feb 2001 21:42:05 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

didn't andrea archangeli try this with red-black trees a couple of years
ago?

instead of hashing or b*trees, let me recommend self-organizing data
structures.
using a splay tree might improve locality of reference and optimize the tree
so
that frequently used pages appear close to the root.

----- Original Message -----
From: Ben LaHaise <bcrl@redhat.com>
To: <linux-mm@kvack.org>
Sent: Monday, February 26, 2001 6:46 PM
Subject: 2.5 page cache improvement idea


> Hey folks,
>
> Here's an idea I just bounced off of Rik that seems like it would be
> pretty useful.  Currently the page cache hash is system wide.  For 2.5,
> I'm suggesting that we make the page cache hash a per-inode structure and
> possibly move the page index and mapping into the structure's information.
> Also, for dealing with hash collisions (which are going to happen under
> certain well known circumstances), we could move to a b*tree structure
> hanging off of the hashes.  So we'd have a data structure that looks like
> the following:
>
>
> inode
> -> hash table
> -> struct page, index, mapping
> -> head of b*tree for overflow
>
> page
> -> pointer back to hash bucket/b*tree entry
>
> These changes would replace ~20 bytes in struct page with one pointer.
> Now, continuing along with making struct page smaller, we can blast away
> the wait queue and replace it with either a tiny-waitqueue (4 bytes) or
> make use of hashed wait queues (0 bytes per page).  That would save
> another 8-12 bytes.  Now, add in a couple of additional space savers like
> making the zone pointer an index, and eliminating the virtual pointer, and
> we have a struct page that's less than 32 bytes (we could even leave the
> index/mapping in that way).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
