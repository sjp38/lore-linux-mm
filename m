Received: from today.toronto.redhat.com (today.toronto.redhat.com [172.16.14.234])
	by devserv.devel.redhat.com (8.11.0/8.11.0) with ESMTP id f1QNkOn01064
	for <linux-mm@kvack.org>; Mon, 26 Feb 2001 18:46:24 -0500
Date: Mon, 26 Feb 2001 18:46:24 -0500 (EST)
From: Ben LaHaise <bcrl@redhat.com>
Subject: 2.5 page cache improvement idea
Message-ID: <Pine.LNX.4.30.0102261829330.5576-100000@today.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hey folks,

Here's an idea I just bounced off of Rik that seems like it would be
pretty useful.  Currently the page cache hash is system wide.  For 2.5,
I'm suggesting that we make the page cache hash a per-inode structure and
possibly move the page index and mapping into the structure's information.
Also, for dealing with hash collisions (which are going to happen under
certain well known circumstances), we could move to a b*tree structure
hanging off of the hashes.  So we'd have a data structure that looks like
the following:


inode
	-> hash table
		-> struct page, index, mapping
		-> head of b*tree for overflow

page
	-> pointer back to hash bucket/b*tree entry

These changes would replace ~20 bytes in struct page with one pointer.
Now, continuing along with making struct page smaller, we can blast away
the wait queue and replace it with either a tiny-waitqueue (4 bytes) or
make use of hashed wait queues (0 bytes per page).  That would save
another 8-12 bytes.  Now, add in a couple of additional space savers like
making the zone pointer an index, and eliminating the virtual pointer, and
we have a struct page that's less than 32 bytes (we could even leave the
index/mapping in that way).

Tiny waitqueues are an idea based on the fact that we never have more than
~65536 waiters in the system (typically much less -> ~# of tasks).  They
replace the whole spinlock/next/prev structure with a single long that
contains the index of the wait structure in a table in the high and low
words.  By making use of cmpxchg on x86, one doesn't need spinlocks to
update this structure.

These are just a couple of quick ideas that I'll try to implement at some
point...  Let me know of any thoughts on the matter.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
