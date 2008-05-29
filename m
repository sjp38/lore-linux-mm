Message-Id: <20080529122602.443815000@nick.local0.net>
References: <20080529122050.823438000@nick.local0.net>
Date: Thu, 29 May 2008 22:20:54 +1000
From: npiggin@suse.de
Subject: [patch 4/5] dio: use get_user_pages_fast
Content-Disposition: inline; filename=dio-get_user_pages_fast.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: shaggy@austin.ibm.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Use get_user_pages_fast in the common/generic block and fs direct IO paths.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: shaggy@austin.ibm.com
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: apw@shadowen.org

---
 fs/bio.c       |    8 ++------
 fs/direct-io.c |   10 ++--------
 2 files changed, 4 insertions(+), 14 deletions(-)

Index: linux-2.6/fs/bio.c
===================================================================
--- linux-2.6.orig/fs/bio.c
+++ linux-2.6/fs/bio.c
@@ -713,12 +713,8 @@ static struct bio *__bio_map_user_iov(st
 		const int local_nr_pages = end - start;
 		const int page_limit = cur_page + local_nr_pages;
 		
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(current, current->mm, uaddr,
-				     local_nr_pages,
-				     write_to_vm, 0, &pages[cur_page], NULL);
-		up_read(&current->mm->mmap_sem);
-
+		ret = get_user_pages_fast(uaddr, local_nr_pages,
+				write_to_vm, &pages[cur_page]);
 		if (ret < local_nr_pages) {
 			ret = -EFAULT;
 			goto out_unmap;
Index: linux-2.6/fs/direct-io.c
===================================================================
--- linux-2.6.orig/fs/direct-io.c
+++ linux-2.6/fs/direct-io.c
@@ -150,17 +150,11 @@ static int dio_refill_pages(struct dio *
 	int nr_pages;
 
 	nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(
-		current,			/* Task for fault acounting */
-		current->mm,			/* whose pages? */
+	ret = get_user_pages_fast(
 		dio->curr_user_address,		/* Where from? */
 		nr_pages,			/* How many pages? */
 		dio->rw == READ,		/* Write to memory? */
-		0,				/* force (?) */
-		&dio->pages[0],
-		NULL);				/* vmas */
-	up_read(&current->mm->mmap_sem);
+		&dio->pages[0]);		/* Put results here */
 
 	if (ret < 0 && dio->blocks_available && (dio->rw & WRITE)) {
 		struct page *page = ZERO_PAGE(0);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
