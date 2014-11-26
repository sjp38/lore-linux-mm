Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id EDD9E6B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 14:11:49 -0500 (EST)
Received: by mail-la0-f54.google.com with SMTP id gf13so3021092lab.27
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 11:11:49 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id ui10si5260160lbb.62.2014.11.26.11.11.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Nov 2014 11:11:48 -0800 (PST)
Received: by mail-lb0-f177.google.com with SMTP id 10so2891662lbg.8
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 11:11:48 -0800 (PST)
Subject: [PATCH v3] mm: prevent endless growth of anon_vma hierarchy
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 26 Nov 2014 22:11:45 +0400
Message-ID: <20141126191145.3089.90947.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Tim Hartrick <tim@edgecast.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>

Constantly forking task causes unlimited grow of anon_vma chain.
Each next child allocate new level of anon_vmas and links vmas to all
previous levels because it inherits pages from them. None of anon_vmas
cannot be freed because there might be pages which points to them.

This patch adds heuristic which decides to reuse existing anon_vma instead
of forking new one. It counts vmas and direct descendants for each anon_vma.
Anon_vma with degree lower than two will be reused at next fork.

As a result each anon_vma has either alive vma or at least two descendants,
endless chains are no longer possible and count of anon_vmas is no more than
two times more than count of vmas.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Reported-by: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Tested-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Link: http://lkml.kernel.org/r/20120816024610.GA5350@evergreen.ssec.wisc.edu
Fixes: 5beb49305251 ("mm: change anon_vma linking to fix multi-process server scalability issue")
Cc: Stable <stable@vger.kernel.org> (2.6.34+)

---

v2: update degree in anon_vma_prepare for merged anon_vma
v3: update comment and tags
---
 include/linux/rmap.h |   16 ++++++++++++++++
 mm/rmap.c            |   30 +++++++++++++++++++++++++++++-
 2 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index c0c2bce..b1d140c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -45,6 +45,22 @@ struct anon_vma {
 	 * mm_take_all_locks() (mm_all_locks_mutex).
 	 */
 	struct rb_root rb_root;	/* Interval tree of private "related" vmas */
+
+	/*
+	 * Count of child anon_vmas and VMAs which points to this anon_vma.
+	 *
+	 * This counter is used for making decision about reusing old anon_vma
+	 * instead of forking new one. It allows to detect anon_vmas which have
+	 * just one direct descendant and no vmas. Reusing such anon_vma not
+	 * leads to significant preformance regression but prevents degradation
+	 * of anon_vma hierarchy to endless linear chain.
+	 *
+	 * Root anon_vma is never reused because it is its own parent and it has
+	 * at leat one vma or child, thus at fork it's degree is at least 2.
+	 */
+	unsigned degree;
+
+	struct anon_vma *parent;	/* Parent of this anon_vma */
 };
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index 19886fb..df5c44e 100644
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
+			/* vma link if merged or child link for new root */
+			anon_vma->degree++;
 			allocated = NULL;
 			avc = NULL;
 		}
@@ -256,7 +260,17 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 		anon_vma = pavc->anon_vma;
 		root = lock_anon_vma_root(root, anon_vma);
 		anon_vma_chain_link(dst, avc, anon_vma);
+
+		/*
+		 * Reuse existing anon_vma if its degree lower than two,
+		 * that means it has no vma and just one anon_vma child.
+		 */
+		if (!dst->anon_vma && anon_vma != src->anon_vma &&
+				anon_vma->degree < 2)
+			dst->anon_vma = anon_vma;
 	}
+	if (dst->anon_vma)
+		dst->anon_vma->degree++;
 	unlock_anon_vma_root(root);
 	return 0;
 
@@ -279,6 +293,9 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	if (!pvma->anon_vma)
 		return 0;
 
+	/* Drop inherited anon_vma, we'll reuse old one or allocate new. */
+	vma->anon_vma = NULL;
+
 	/*
 	 * First, attach the new VMA to the parent VMA's anon_vmas,
 	 * so rmap can find non-COWed pages in child processes.
@@ -286,6 +303,10 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	if (anon_vma_clone(vma, pvma))
 		return -ENOMEM;
 
+	/* An old anon_vma has been reused. */
+	if (vma->anon_vma)
+		return 0;
+
 	/* Then add our own anon_vma. */
 	anon_vma = anon_vma_alloc();
 	if (!anon_vma)
@@ -299,6 +320,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	 * lock any of the anon_vmas in this anon_vma tree.
 	 */
 	anon_vma->root = pvma->anon_vma->root;
+	anon_vma->parent = pvma->anon_vma;
 	/*
 	 * With refcounts, an anon_vma can stay around longer than the
 	 * process it belongs to. The root anon_vma needs to be pinned until
@@ -309,6 +331,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	vma->anon_vma = anon_vma;
 	anon_vma_lock_write(anon_vma);
 	anon_vma_chain_link(vma, avc, anon_vma);
+	anon_vma->parent->degree++;
 	anon_vma_unlock_write(anon_vma);
 
 	return 0;
@@ -339,12 +362,16 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
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
@@ -355,6 +382,7 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
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
