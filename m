Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA00492
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 15:54:05 -0500
Date: Fri, 27 Nov 1998 16:02:51 GMT
Message-Id: <199811271602.QAA00642@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com>
References: <199811261236.MAA14785@dax.scot.redhat.com>
	<Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Looks like I have a handle on what's wrong with the 2.1.130 vm (in
particular, its tendency to cache too much at the expense of
swapping).

The real problem seems to be that shrink_mmap() can fail for two
completely separate reasons.  First of all, we might fail to find a
free page because all of the cache pages we find are recently
referenced.  Secondly, we might fail to find a cache page at all.

The first case is an example of an overactive, large cache; the second
is an example of a very small cache.  Currently, however, we treat
these two cases pretty much the same.  In the second case, the correct
reaction is to swap, and 2.1.130 is sufficiently good at swapping that
we do so, heavily.  In the first case, high cache throughput, what we
really _should_ be doing is to age the pages more quickly.  What we
actually do is to swap.

On reflection, there is a completely natural way of distinguishing
between these two cases, and that is to extend the size of the
shrink_mmap() pass whenever we encounter many recently touched pages.
This is easy to do: simply restricting the "count_min" accounting in
shrink_mmap to avoid including salvageable but recently-touched pages
will automatically cause us to age faster as we encounter more touched
pages in the cache.

The patch below both makes sense from this perspective and seems to
work, which is always a good sign!  Moreover, it is inherently
self-tuning.  The more recently-accessed cache pages we encounter, the
faster we will age the cache.

On an 8MB boot, it is just as fast as plain 2.1.130 at doing a make
defrag over NFS (which means it is still 25% faster than 2.0.36 at
this job even on low-memory NFS).  On 64MB, I've been running emacs
with two or three 10MB mail folders loaded, netscape running a bunch
of pages, a couple of large 16-bit images under xv and a kernel build
all on different X pages, and switching between them is all extremely
fast.  It still has the great responsiveness under this sort of load
that first came with 2.1.130.  

The good news, however, is that an extra filesystem load of "wc
/usr/bin/*" does not cause a swap storm on the new kernel: it is
finally able to distinguish a cache which is too active and a cache
which is too small.  The system does still swap well once it decides
it needs to, giving swapout burst rates of 2--3MB/sec during this
test.

Note that older kernels did not have this problem because in 1.2, the
buffer cache would never ever grow into the space used by the rest of
the kernel, and in 2.0, the presence of page aging in the swapper but
not in the cache caused us to run around the shrink_mmap() loop far
too much anyway, at the expense of good swap performance.

--Stephen

----------------------------------------------------------------
--- mm/filemap.c.~1~	Thu Nov 26 18:48:52 1998
+++ mm/filemap.c	Fri Nov 27 12:45:03 1998
@@ -200,8 +200,8 @@
 	struct page * page;
 	int count_max, count_min;
 
-	count_max = (limit<<1) >> (priority>>1);
-	count_min = (limit<<1) >> (priority);
+	count_max = limit;
+	count_min = (limit<<2) >> (priority);
 
 	page = mem_map + clock;
 	do {
@@ -214,7 +214,15 @@
 		if (shrink_one_page(page, gfp_mask))
 			return 1;
 		count_max--;
-		if (page->inode || page->buffers)
+		/* 
+		 * If the page we looked at was recyclable but we didn't
+		 * reclaim it (presumably due to PG_referenced), don't
+		 * count it as scanned.  This way, the more referenced
+		 * page cache pages we encounter, the more rapidly we
+		 * will age them. 
+		 */
+		if (atomic_read(&page->count) != 1 ||
+		    (!page->inode && !page->buffers))
 			count_min--;
 		page++;
 		clock++;
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
