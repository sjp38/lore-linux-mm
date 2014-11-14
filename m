Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2116E6B00CB
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 11:30:56 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id l13so1932862iga.2
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 08:30:55 -0800 (PST)
Received: from cosmos.ssec.wisc.edu ([2607:f388:1090:0:fab1:56ff:fedf:5d9c])
        by mx.google.com with ESMTP id iv13si39813136icc.88.2014.11.14.08.30.53
        for <linux-mm@kvack.org>;
        Fri, 14 Nov 2014 08:30:54 -0800 (PST)
Date: Fri, 14 Nov 2014 10:30:53 -0600
From: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Subject: [PATCH] Repeated fork() causes SLAB to grow without bound
Message-ID: <20141114163053.GA6547@cosmos.ssec.wisc.edu>
Reply-To: Daniel Forrest <dan.forrest@ssec.wisc.edu>
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu>
 <502D42E5.7090403@redhat.com>
 <20120818000312.GA4262@evergreen.ssec.wisc.edu>
 <502F100A.1080401@redhat.com>
 <alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
 <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
 <20120822032057.GA30871@google.com>
 <50345232.4090002@redhat.com>
 <20130603195003.GA31275@evergreen.ssec.wisc.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603195003.GA31275@evergreen.ssec.wisc.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

There have been a couple of inquiries about the status of this patch
over the last few months, so I am going to try pushing it out.

Andrea Arcangeli has commented:

> Agreed. The only thing I don't like about this patch is the hardcoding
> of number 5: could we make it a variable to tweak with sysfs/sysctl so
> if some weird workload arises we have a tuning tweak? It'd cost one
> cacheline during fork, so it doesn't look excessive overhead.

Adding this is beyond my experience level, so if it is required then
someone else will have to make it so.

Rik van Riel has commented:

> I believe we should just merge that patch.
> 
> I have not seen any better ideas come by.
> 
> The comment should probably be fixed to reflect the
> chain length of 5 though :)

So here is Michel's patch again with "(length > 1)" modified to
"(length > 5)" and fixed comments.

I have been running with this patch (with the threshold set to 5) for
over two years now and it does indeed solve the problem.

---

anon_vma_clone() is modified to return the length of the existing
same_vma anon vma chain, and we create a new anon_vma in the child
if it is more than five forks after the anon_vma was created, as we
don't want the same_vma chain to grow arbitrarily large.

Signed-off-by: Michel Lespinasse <walken@google.com>
Tested-by: Daniel Forrest <dan.forrest@ssec.wisc.edu>
---
 mm/mmap.c |    6 +++---
 mm/rmap.c |   18 ++++++++++++++----
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 3edfcdfa42d9..e14b19a838cb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -539,7 +539,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		 * shrinking vma had, to cover any anon pages imported.
 		 */
 		if (exporter && exporter->anon_vma && !importer->anon_vma) {
-			if (anon_vma_clone(importer, exporter))
+			if (anon_vma_clone(importer, exporter) < 0)
 				return -ENOMEM;
 			importer->anon_vma = exporter->anon_vma;
 		}
@@ -1988,7 +1988,7 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	}
 	vma_set_policy(new, pol);
 
-	if (anon_vma_clone(new, vma))
+	if (anon_vma_clone(new, vma) < 0)
 		goto out_free_mpol;
 
 	if (new->vm_file) {
@@ -2409,7 +2409,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			if (IS_ERR(pol))
 				goto out_free_vma;
 			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
-			if (anon_vma_clone(new_vma, vma))
+			if (anon_vma_clone(new_vma, vma) < 0)
 				goto out_free_mempol;
 			vma_set_policy(new_vma, pol);
 			new_vma->vm_start = addr;
diff --git a/mm/rmap.c b/mm/rmap.c
index 0f3b7cda2a24..ba8a726aaee6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -238,12 +238,13 @@ static inline void unlock_anon_vma_root(struct anon_vma *root)
 
 /*
  * Attach the anon_vmas from src to dst.
- * Returns 0 on success, -ENOMEM on failure.
+ * Returns length of the anon_vma chain on success, -ENOMEM on failure.
  */
 int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 {
 	struct anon_vma_chain *avc, *pavc;
 	struct anon_vma *root = NULL;
+	int length = 0;
 
 	list_for_each_entry_reverse(pavc, &src->anon_vma_chain, same_vma) {
 		struct anon_vma *anon_vma;
@@ -259,9 +260,10 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 		anon_vma = pavc->anon_vma;
 		root = lock_anon_vma_root(root, anon_vma);
 		anon_vma_chain_link(dst, avc, anon_vma);
+		length++;
 	}
 	unlock_anon_vma_root(root);
-	return 0;
+	return length;
 
  enomem_failure:
 	unlink_anon_vmas(dst);
@@ -322,6 +324,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 {
 	struct anon_vma_chain *avc;
 	struct anon_vma *anon_vma;
+	int length;
 
 	/* Don't bother if the parent process has no anon_vma here. */
 	if (!pvma->anon_vma)
@@ -331,10 +334,17 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	 * First, attach the new VMA to the parent VMA's anon_vmas,
 	 * so rmap can find non-COWed pages in child processes.
 	 */
-	if (anon_vma_clone(vma, pvma))
+	length = anon_vma_clone(vma, pvma);
+	if (length < 0)
 		return -ENOMEM;
+	else if (length > 5)
+		return 0;
 
-	/* Then add our own anon_vma. */
+	/*
+	 * Then add our own anon_vma. We do this only for five forks after
+	 * the anon_vma was created, as we don't want the same_vma chain to
+	 * grow arbitrarily large.
+	 */
 	anon_vma = anon_vma_alloc();
 	if (!anon_vma)
 		goto out_error;

-- 
Daniel K. Forrest		Space Science and
dan.forrest@ssec.wisc.edu	Engineering Center
(608) 890 - 0558		University of Wisconsin, Madison

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
