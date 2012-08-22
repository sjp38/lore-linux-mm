Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 344D96B0044
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 23:21:04 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so890943pbb.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 20:21:03 -0700 (PDT)
Date: Tue, 21 Aug 2012 20:20:57 -0700
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH] Re: Repeated fork() causes SLAB to grow without bound
Message-ID: <20120822032057.GA30871@google.com>
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu>
 <502D42E5.7090403@redhat.com>
 <20120818000312.GA4262@evergreen.ssec.wisc.edu>
 <502F100A.1080401@redhat.com>
 <alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
 <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 20, 2012 at 02:39:26AM -0700, Michel Lespinasse wrote:
> Instead of adding an atomic count for page references, we could limit
> the anon_vma stacking depth. In fork, we would only clone anon_vmas
> that have a low enough generation count. I think that's not great
> (adds a special case for the deep-fork-without-exec behavior), but
> still better than the atomic page reference counter.

Here is an attached patch to demonstrate the idea.

anon_vma_clone() is modified to return the length of the existing same_vma
anon vma chain, and we create a new anon_vma in the child only on the first
fork (this could be tweaked to allow up to a set number of forks, but
I think the first fork would cover all the common forking server cases).

Signed-off-by: Michel Lespinasse <walken@google.com>
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
+	else if (length > 1)
+		return 0;
 
-	/* Then add our own anon_vma. */
+	/*
+	 * Then add our own anon_vma. We do this only on the first fork after
+	 * the anon_vma is created, as we don't want the same_vma chain to
+	 * grow arbitrarily large.
+	 */
 	anon_vma = anon_vma_alloc();
 	if (!anon_vma)
 		goto out_error;

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
