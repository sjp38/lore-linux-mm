Received: from sable.ox.ac.uk ([163.1.2.4])
	by oxmail.ox.ac.uk with esmtp (Exim 2.10 #1)
	id 11vl73-000661-00
	for linux-mm@kvack.org; Wed, 8 Dec 1999 17:42:49 +0000
Received: from mbeattie by sable.ox.ac.uk with local (Exim 2.12 #1)
	id 11vl73-00012G-00
	for linux-mm@kvack.org; Wed, 8 Dec 1999 17:42:49 +0000
Subject: sizeof(struct page) from 44 to 32 bytes for 32-bit <256MB
Date: Wed, 8 Dec 1999 17:42:49 +0000 (GMT)
From: Malcolm Beattie <mbeattie@sable.ox.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <E11vl73-00012G-00@sable.ox.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I sent this to linux-kernel a week ago but got zero responses so I
thought I'd try sending it to linux-mm. Apologies to anyone who
reads this twice.

Has anyone thought/tried/benchmarked the following optimisation for
32-bit systems with less than 256 MB physical RAM? Currently,
struct page takes up 40 or 48 bytes (2.2 v. 2.3) on such systems.
That can be reduced by at least 10 bytes (for 2.3) which brings the
next_hash field into the first cache line (and flags can fit in there
too). That means that a lot of uses of struct page only use a single
cache line per touched struct page instead of two.

The idea is to replace the various struct page pointers (4 bytes) with
a 2 byte page frame number which can then cope with 64K x 4K = 256MB
physical RAM. The relevant pointers are the struct page * fields (two
each hidden in struct list_head list and lru and one in next_hash
along with a reduction of unsigned long flags to 16 bits if flags is
wanted in the first cache line instead of just next_hash. Intead of
following pointers, you just use mem_map[new_pfn] and the changes
should only affect a few places in mm/*.c.

Since this involves modifying the supposedly architecture independent
mm code and also only applies to machines with < 256 MB RAM it could
be considered a bit nasty but if it improved performance enough, it
may be worth having as a "compile your kernel with
CONFIG_OPIMIZE_32BIT_UNDER_256MB if you wish" option. (It saves a few
KB by having a smaller mem_map array too but perhaps that's less
likely to affect performance).

It could even be done by modifying struct page to use pfns always for
every architecture which would make it rather cleaner since you could
then optimize for other architectures too. For example, Alpha and
sparc64 could use a 32-bit pfn instead of a 64-bit pointer in all
those places which would again save cacheline space.

--Malcolm

-- 
Malcolm Beattie <mbeattie@sable.ox.ac.uk>
Unix Systems Programmer
Oxford University Computing Services
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
