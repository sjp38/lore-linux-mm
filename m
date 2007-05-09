Message-ID: <4641BFCE.6090200@yahoo.com.au>
Date: Wed, 09 May 2007 22:34:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
Content-Type: multipart/mixed;
 boundary="------------060803040002020005060607"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060803040002020005060607
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hugh Dickins wrote:
> On Wed, 2 May 2007, Nick Piggin wrote:

>>>But I'm pretty sure (to use your words!) regular truncate was not racy
>>>before: I believe Andrea's sequence count was handling that case fine,
>>>without a second unmap_mapping_range.
>>
>>OK, I think you're right. I _think_ it should also be OK with the
>>lock_page version as well: we should not be able to have any pages
>>after the first unmap_mapping_range call, because of the i_size
>>write. So if we have no pages, there is nothing to 'cow' from.
> 
> 
> I'd be delighted if you can remove those later unmap_mapping_ranges.
> As I recall, the important thing for the copy pages is to be holding
> the page lock (or whatever other serialization) on the copied page
> still while the copy page is inserted into pagetable: that looks
> to be so in your __do_fault.

Hmm, on second thoughts, I think I was right the first time, and do
need the unmap after the pages are truncated. With the lock_page code,
after the first unmap, we can get new ptes mapping pages, and
subsequently they can be COWed and then the original pte zapped before
the truncate loop checks it.

However, I wonder if we can't test mapping_mapped before the spinlock,
which would make most truncates cheaper?

-- 
SUSE Labs, Novell Inc.

--------------060803040002020005060607
Content-Type: text/plain;
 name="mm-truncate-avoid-rmap-locks"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-truncate-avoid-rmap-locks"

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-04-24 15:02:51.000000000 +1000
+++ linux-2.6/mm/filemap.c	2007-05-09 17:30:47.000000000 +1000
@@ -2579,8 +2579,7 @@
 	if (rw == WRITE) {
 		write_len = iov_length(iov, nr_segs);
 		end = (offset + write_len - 1) >> PAGE_CACHE_SHIFT;
-	       	if (mapping_mapped(mapping))
-			unmap_mapping_range(mapping, offset, write_len, 0);
+		unmap_mapping_range(mapping, offset, write_len, 0);
 	}
 
 	retval = filemap_write_and_wait(mapping);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2007-05-09 17:25:28.000000000 +1000
+++ linux-2.6/mm/memory.c	2007-05-09 17:30:22.000000000 +1000
@@ -1956,6 +1956,9 @@
 	pgoff_t hba = holebegin >> PAGE_SHIFT;
 	pgoff_t hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
+	if (!mapping_mapped(mapping))
+		return;
+
 	/* Check for overflow. */
 	if (sizeof(holelen) > sizeof(hlen)) {
 		long long holeend =

--------------060803040002020005060607--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
