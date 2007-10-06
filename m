Date: Sat, 6 Oct 2007 21:45:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 4/7] shmem: SGP_QUICK and SGP_FAULT redundant
In-Reply-To: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0710062143420.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove SGP_QUICK from the sgp_type enum: it was for shmem_populate and
has no users now.  Remove SGP_FAULT from the enum: SGP_CACHE does just
as well (and shmem_getpage is about to return with page always locked).

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/shmem.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

--- patch3/mm/shmem.c	2007-10-04 19:24:36.000000000 +0100
+++ patch4/mm/shmem.c	2007-10-04 19:24:39.000000000 +0100
@@ -78,11 +78,9 @@
 
 /* Flag allocation requirements to shmem_getpage and shmem_swp_alloc */
 enum sgp_type {
-	SGP_QUICK,	/* don't try more than file page cache lookup */
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
 	SGP_WRITE,	/* may exceed i_size, may allocate page */
-	SGP_FAULT,	/* same as SGP_CACHE, return with page locked */
 };
 
 static int shmem_getpage(struct inode *inode, unsigned long idx,
@@ -1101,8 +1099,6 @@ repeat:
 	if (filepage && PageUptodate(filepage))
 		goto done;
 	error = 0;
-	if (sgp == SGP_QUICK)
-		goto failed;
 	gfp = mapping_gfp_mask(mapping);
 
 	spin_lock(&info->lock);
@@ -1276,7 +1272,7 @@ repeat:
 done:
 	if (*pagep != filepage) {
 		*pagep = filepage;
-		if (sgp != SGP_FAULT)
+		if (sgp != SGP_CACHE)
 			unlock_page(filepage);
 
 	}
@@ -1299,7 +1295,7 @@ static int shmem_fault(struct vm_area_st
 	if (((loff_t)vmf->pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
 		return VM_FAULT_SIGBUS;
 
-	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_FAULT, &ret);
+	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
