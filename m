Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E2CBB6B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 08:04:28 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5885935dak.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 05:04:28 -0700 (PDT)
Date: Sat, 12 May 2012 05:04:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/10] tmpfs: optimize clearing when writing
In-Reply-To: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205120502370.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Nick proposed years ago that tmpfs should avoid clearing its pages where
write will overwrite them with new data, as ramfs has long done.  But I
messed it up and just got bad data.  Tried again recently, it works fine.

Here's time output for writing 4GiB 16 times on this Core i5 laptop:

before: real	0m21.169s user	0m0.028s sys	0m21.057s
        real	0m21.382s user	0m0.016s sys	0m21.289s
        real	0m21.311s user	0m0.020s sys	0m21.217s

after:  real	0m18.273s user	0m0.032s sys	0m18.165s 
        real	0m18.354s user	0m0.020s sys	0m18.265s 
        real	0m18.440s user	0m0.032s sys	0m18.337s 

ramfs:  real	0m16.860s user	0m0.028s sys	0m16.765s
        real	0m17.382s user	0m0.040s sys	0m17.273s
        real	0m17.133s user	0m0.044s sys	0m17.021s

Yes, I have done perf reports, but they need more explanation than they
deserve: in summary, clear_page vanishes, its cache loading shifts into
copy_user_generic_unrolled; shmem_getpage_gfp goes down, and surprisingly
mark_page_accessed goes way up - I think because they are respectively
where the cache gets to be reloaded after being purged by clear or copy.

Suggested-by: Nick Piggin <npiggin@gmail.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |   20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

--- 3045N.orig/mm/shmem.c	2012-05-05 10:46:05.732062006 -0700
+++ 3045N/mm/shmem.c	2012-05-05 10:46:12.316062172 -0700
@@ -1095,9 +1095,14 @@ repeat:
 		shmem_recalc_inode(inode);
 		spin_unlock(&info->lock);
 
-		clear_highpage(page);
-		flush_dcache_page(page);
-		SetPageUptodate(page);
+		/*
+		 * Let SGP_WRITE caller clear ends if write does not fill page
+		 */
+		if (sgp != SGP_WRITE) {
+			clear_highpage(page);
+			flush_dcache_page(page);
+			SetPageUptodate(page);
+		}
 		if (sgp == SGP_DIRTY)
 			set_page_dirty(page);
 	}
@@ -1307,6 +1312,14 @@ shmem_write_end(struct file *file, struc
 	if (pos + copied > inode->i_size)
 		i_size_write(inode, pos + copied);
 
+	if (!PageUptodate(page)) {
+		if (copied < PAGE_CACHE_SIZE) {
+			unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+			zero_user_segments(page, 0, from,
+					from + copied, PAGE_CACHE_SIZE);
+		}
+		SetPageUptodate(page);
+	}
 	set_page_dirty(page);
 	unlock_page(page);
 	page_cache_release(page);
@@ -1768,6 +1781,7 @@ static int shmem_symlink(struct inode *d
 		kaddr = kmap_atomic(page);
 		memcpy(kaddr, symname, len);
 		kunmap_atomic(kaddr);
+		SetPageUptodate(page);
 		set_page_dirty(page);
 		unlock_page(page);
 		page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
