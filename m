Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 447DA6B0080
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 03:57:41 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gm9so12582384lab.26
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 00:57:40 -0800 (PST)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id am7si3148491lac.98.2014.12.17.00.57.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 00:57:39 -0800 (PST)
Received: by mail-lb0-f178.google.com with SMTP id f15so13782826lbj.9
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 00:57:39 -0800 (PST)
Subject: [PATCH v4] mm: prevent endless growth of anon_vma hierarchy
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 17 Dec 2014 11:57:37 +0400
Message-ID: <20141217085737.16381.75639.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Tim Hartrick <tim@edgecast.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>

Constantly forking task causes unlimited grow of anon_vma chain.
Each next child allocates new level of anon_vmas and links vma to all
previous levels because pages might be inherited from any level.

This patch adds heuristic which decides to reuse existing anon_vma instead
of forking new one. It adds counter anon_vma->degree which counts linked
vmas and directly descending anon_vmas and reuses anon_vma if counter is
lower than two. As a result each anon_vma has either vma or at least two
descending anon_vmas. In such trees half of nodes are leafs with alive vmas,
thus count of anon_vmas is no more than two times bigger than count of vmas.
This heuristic reuses anon_vmas as few as possible because each reuse adds
false aliasing among vmas and rmap walker ought to scan more ptes when it
searches where page is might be mapped.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Reported-by: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Tested-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Link: http://lkml.kernel.org/r/20120816024610.GA5350@evergreen.ssec.wisc.edu
Fixes: 5beb49305251 ("mm: change anon_vma linking to fix multi-process server scalability issue")
Cc: Stable <stable@vger.kernel.org> (2.6.34+)

---

v2: update degree in anon_vma_prepare for merged anon_vma
v3: update comment and commit message
v4: reorder anon_vma fields, update commit message, patch for current mmotm
---
 include/linux/rmap.h |   10 ++++++++++
 mm/rmap.c            |   41 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 50 insertions(+), 1 deletion(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 94d5bca..40bf29e 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -37,6 +37,16 @@ struct anon_vma {
 	atomic_t refcount;
 
 	/*
+	 * Count of child anon_vmas and VMAs which points to this anon_vma.
+	 *
+	 * This counter is used for making decision about reusing anon_vma
+	 * instead of forking new one. See comments in function anon_vma_clone.
+	 */
+	unsigned degree;
+
+	struct anon_vma *parent;	/* Parent of this anon_vma */
+
+	/*
 	 * NOTE: the LSB of the rb_root.rb_node is set by
 	 * mm_take_all_locks() _after_ taking the above lock. So the
 	 * rb_root must only be read/written after taking the above lock
diff --git a/mm/rmap.c b/mm/rmap.c
index b404783..355cf70 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -72,6 +72,8 @@ static inline struct anon_vma *anon_vma_alloc(void)
 	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
 	if (anon_vma) {
 		atomic_set(&anon_vma->refcount, 1);
+		anon_vma->degree = 1;	/* Reference for first vma */
+		anon_vma->parent = anon_vma;
 		/*
 		 * Initialise the anon_vma root to point to itself. If called
 		 * from fork, the root will be reset to the parents anon_vma.
@@ -188,6 +190,8 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
 			anon_vma_chain_link(vma, avc, anon_vma);
+			/* vma reference or self-parent link for new root */
+			anon_vma->degree++;
 			allocated = NULL;
 			avc = NULL;
 		}
@@ -236,6 +240,13 @@ static inline void unlock_anon_vma_root(struct anon_vma *root)
 /*
  * Attach the anon_vmas from src to dst.
  * Returns 0 on success, -ENOMEM on failure.
+ *
+ * If dst->anon_vma is NULL this function tries to find and reuse existing
+ * anon_vma which has no vmas and only one child anon_vma. This prevents
+ * degradation of anon_vma hierarchy to endless linear chain in case of
+ * constantly forking task. In other hand anon_vma with more than one child
+ * isn't reused even if was no alive vma, thus rmap walker has a good chance
+ * to avoid scanning whole hieraryhy when it searches where page is mapped.
  */
 int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 {
@@ -256,7 +267,21 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 		anon_vma = pavc->anon_vma;
 		root = lock_anon_vma_root(root, anon_vma);
 		anon_vma_chain_link(dst, avc, anon_vma);
+
+		/*
+		 * Reuse existing anon_vma if its degree lower than two,
+		 * that means it has no vma and only one anon_vma child.
+		 *
+		 * Do not chose parent anon_vma, otherwise first child
+		 * will always reuse it. Root anon_vma is never reused:
+		 * it has self-parent reference and at least one child.
+		 */
+		if (!dst->anon_vma && anon_vma != src->anon_vma &&
+				anon_vma->degree < 2)
+			dst->anon_vma = anon_vma;
 	}
+	if (dst->anon_vma)
+		dst->anon_vma->degree++;
 	unlock_anon_vma_root(root);
 	return 0;
 
@@ -280,6 +305,9 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	if (!pvma->anon_vma)
 		return 0;
 
+	/* Drop inherited anon_vma, we'll reuse existing or allocate new. */
+	vma->anon_vma = NULL;
+
 	/*
 	 * First, attach the new VMA to the parent VMA's anon_vmas,
 	 * so rmap can find non-COWed pages in child processes.
@@ -288,6 +316,10 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	if (error)
 		return error;
 
+	/* An existing anon_vma has been reused, all done then. */
+	if (vma->anon_vma)
+		return 0;
+
 	/* Then add our own anon_vma. */
 	anon_vma = anon_vma_alloc();
 	if (!anon_vma)
@@ -301,6 +333,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	 * lock any of the anon_vmas in this anon_vma tree.
 	 */
 	anon_vma->root = pvma->anon_vma->root;
+	anon_vma->parent = pvma->anon_vma;
 	/*
 	 * With refcounts, an anon_vma can stay around longer than the
 	 * process it belongs to. The root anon_vma needs to be pinned until
@@ -311,6 +344,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	vma->anon_vma = anon_vma;
 	anon_vma_lock_write(anon_vma);
 	anon_vma_chain_link(vma, avc, anon_vma);
+	anon_vma->parent->degree++;
 	anon_vma_unlock_write(anon_vma);
 
 	return 0;
@@ -341,12 +375,16 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
 		 * Leave empty anon_vmas on the list - we'll need
 		 * to free them outside the lock.
 		 */
-		if (RB_EMPTY_ROOT(&anon_vma->rb_root))
+		if (RB_EMPTY_ROOT(&anon_vma->rb_root)) {
+			anon_vma->parent->degree--;
 			continue;
+		}
 
 		list_del(&avc->same_vma);
 		anon_vma_chain_free(avc);
 	}
+	if (vma->anon_vma)
+		vma->anon_vma->degree--;
 	unlock_anon_vma_root(root);
 
 	/*
@@ -357,6 +395,7 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
 		struct anon_vma *anon_vma = avc->anon_vma;
 
+		BUG_ON(anon_vma->degree);
 		put_anon_vma(anon_vma);
 
 		list_del(&avc->same_vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
