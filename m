Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 2CBC86B005D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 02:24:33 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so3512381pad.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 23:24:32 -0800 (PST)
Date: Tue, 4 Dec 2012 23:24:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: fix shared mempolicy leak
In-Reply-To: <alpine.LNX.2.00.1212042211340.892@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1212042320050.19453@eggly.anvils>
References: <1349801921-16598-1-git-send-email-mgorman@suse.de> <1349801921-16598-6-git-send-email-mgorman@suse.de> <CA+ydwtqQ7iK_1E+7ctLxYe8JZY+SzMfuRagjyHJ12OYsxbMcaA@mail.gmail.com> <20121204141501.GA2797@suse.de> <alpine.LNX.2.00.1212042042130.13895@eggly.anvils>
 <alpine.LNX.2.00.1212042211340.892@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Tommi Rantala <tt.rantala@gmail.com>, Stable <stable@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

From: Mel Gorman <mgorman@suse.de>

Commit 00442ad04a5e ("mempolicy: fix a memory corruption by refcount
imbalance in alloc_pages_vma()") changed get_vma_policy() to raise the
refcount on a shmem shared mempolicy; whereas shmem_alloc_page() went
on expecting alloc_page_vma() to drop the refcount it had acquired.
This deserves a rework: but for now fix the leak in shmem_alloc_page().

Hugh: shmem_swapin() did not need a fix, but surely it's clearer to use
the same refcounting there as in shmem_alloc_page(), delete its onstack
mempolicy, and the strange mpol_cond_copy() and __mpol_cond_copy() -
those were invented to let swapin_readahead() make an unknown number of
calls to alloc_pages_vma() with one mempolicy; but since 00442ad04a5e,
alloc_pages_vma() has kept refcount in balance, so now no problem.

Reported-by: Tommi Rantala <tt.rantala@gmail.com>
Awaiting-signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
---

 include/linux/mempolicy.h |   16 ----------------
 mm/mempolicy.c            |   22 ----------------------
 mm/shmem.c                |   26 ++++++++++++++++----------
 3 files changed, 16 insertions(+), 48 deletions(-)

--- 3.7-rc8/include/linux/mempolicy.h	2012-10-14 16:16:57.637308925 -0700
+++ linux/include/linux/mempolicy.h	2012-12-04 22:38:21.812178829 -0800
@@ -82,16 +82,6 @@ static inline void mpol_cond_put(struct
 		__mpol_put(pol);
 }
 
-extern struct mempolicy *__mpol_cond_copy(struct mempolicy *tompol,
-					  struct mempolicy *frompol);
-static inline struct mempolicy *mpol_cond_copy(struct mempolicy *tompol,
-						struct mempolicy *frompol)
-{
-	if (!frompol)
-		return frompol;
-	return __mpol_cond_copy(tompol, frompol);
-}
-
 extern struct mempolicy *__mpol_dup(struct mempolicy *pol);
 static inline struct mempolicy *mpol_dup(struct mempolicy *pol)
 {
@@ -215,12 +205,6 @@ static inline void mpol_cond_put(struct
 {
 }
 
-static inline struct mempolicy *mpol_cond_copy(struct mempolicy *to,
-						struct mempolicy *from)
-{
-	return from;
-}
-
 static inline void mpol_get(struct mempolicy *pol)
 {
 }
--- 3078/mm/mempolicy.c	2012-10-20 20:56:24.675917367 -0700
+++ 3078X/mm/mempolicy.c	2012-12-04 22:33:31.516171929 -0800
@@ -2037,28 +2037,6 @@ struct mempolicy *__mpol_dup(struct memp
 	return new;
 }
 
-/*
- * If *frompol needs [has] an extra ref, copy *frompol to *tompol ,
- * eliminate the * MPOL_F_* flags that require conditional ref and
- * [NOTE!!!] drop the extra ref.  Not safe to reference *frompol directly
- * after return.  Use the returned value.
- *
- * Allows use of a mempolicy for, e.g., multiple allocations with a single
- * policy lookup, even if the policy needs/has extra ref on lookup.
- * shmem_readahead needs this.
- */
-struct mempolicy *__mpol_cond_copy(struct mempolicy *tompol,
-						struct mempolicy *frompol)
-{
-	if (!mpol_needs_cond_ref(frompol))
-		return frompol;
-
-	*tompol = *frompol;
-	tompol->flags &= ~MPOL_F_SHARED;	/* copy doesn't need unref */
-	__mpol_put(frompol);
-	return tompol;
-}
-
 /* Slow path of a mempolicy comparison */
 bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 {
--- 3078/mm/shmem.c	2012-11-16 19:26:56.388459961 -0800
+++ 3078X/mm/shmem.c	2012-12-04 22:32:35.328170594 -0800
@@ -910,25 +910,29 @@ static struct mempolicy *shmem_get_sbmpo
 static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
 {
-	struct mempolicy mpol, *spol;
 	struct vm_area_struct pvma;
-
-	spol = mpol_cond_copy(&mpol,
-			mpol_shared_policy_lookup(&info->policy, index));
+	struct page *page;
 
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
 	/* Bias interleave by inode number to distribute better across nodes */
 	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
 	pvma.vm_ops = NULL;
-	pvma.vm_policy = spol;
-	return swapin_readahead(swap, gfp, &pvma, 0);
+	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+
+	page = swapin_readahead(swap, gfp, &pvma, 0);
+
+	/* Drop reference taken by mpol_shared_policy_lookup() */
+	mpol_cond_put(pvma.vm_policy);
+
+	return page;
 }
 
 static struct page *shmem_alloc_page(gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
 {
 	struct vm_area_struct pvma;
+	struct page *page;
 
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
@@ -937,10 +941,12 @@ static struct page *shmem_alloc_page(gfp
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 
-	/*
-	 * alloc_page_vma() will drop the shared policy reference
-	 */
-	return alloc_page_vma(gfp, &pvma, 0);
+	page = alloc_page_vma(gfp, &pvma, 0);
+
+	/* Drop reference taken by mpol_shared_policy_lookup() */
+	mpol_cond_put(pvma.vm_policy);
+
+	return page;
 }
 #else /* !CONFIG_NUMA */
 #ifdef CONFIG_TMPFS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
