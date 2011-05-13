Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CF54190010C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:46:53 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap chain locking v2
Date: Fri, 13 May 2011 16:46:21 -0700
Message-Id: <1305330384-19540-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1305330384-19540-1-git-send-email-andi@firstfloor.org>
References: <1305330384-19540-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>

From: Andi Kleen <ak@linux.intel.com>

In fork and exit it's quite common to take same rmap chain locks
again and again when the whole address space is processed  for a
address space that has a lot of sharing. Also since the locking
has changed to always lock the root anon_vma this can be very
contended.

This patch adds a simple wrapper to batch these lock acquisitions
and only reaquire the lock when another is needed. The main
advantage is that when multiple processes are doing this in
parallel they will avoid a lot of communication overhead
on the lock cache line.

v2: Address review feedback. Drop lockbreak. Rename init function.
Move out of line. Add CONFIG_SMP ifdefs.
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel<riel@redhat.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/rmap.h |   34 ++++++++++++++++++++++++++++++++++
 mm/rmap.c            |   12 ++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 830e65d..44f5bb2 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -113,6 +113,40 @@ static inline void anon_vma_unlock(struct anon_vma *anon_vma)
 	spin_unlock(&anon_vma->root->lock);
 }
 
+/* 
+ * Batched locking for anon VMA chains to avoid too much cache line 
+ * bouncing.
+ */
+
+struct anon_vma_lock_state {
+	struct anon_vma *root_anon_vma;
+};
+
+static inline void anon_vma_lock_batch_init(struct anon_vma_lock_state *avs)
+{
+	avs->root_anon_vma = NULL;
+}
+
+extern void __anon_vma_lock_batch(struct anon_vma *anon_vma,
+				  struct anon_vma_lock_state *state);
+
+static inline void anon_vma_lock_batch(struct anon_vma *anon_vma,
+				       struct anon_vma_lock_state *state)
+{
+#ifdef CONFIG_SMP
+	if (state->root_anon_vma != anon_vma->root)
+		__anon_vma_lock_batch(anon_vma, state);
+#endif
+}
+
+static inline void anon_vma_unlock_batch(struct anon_vma_lock_state *avs)
+{
+#ifdef CONFIG_SMP
+	if (avs->root_anon_vma)
+		spin_unlock(&avs->root_anon_vma->lock);
+#endif
+}
+
 /*
  * anon_vma helper functions.
  */
diff --git a/mm/rmap.c b/mm/rmap.c
index 8da044a..5a2cd65 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1624,3 +1624,15 @@ void hugepage_add_new_anon_rmap(struct page *page,
 	__hugepage_set_anon_rmap(page, vma, address, 1);
 }
 #endif /* CONFIG_HUGETLB_PAGE */
+
+/* 
+ * Batched rmap chain locking
+ */
+void __anon_vma_lock_batch(struct anon_vma *anon_vma,
+			   struct anon_vma_lock_state *state)
+{
+	if (state->root_anon_vma)
+		spin_unlock(&state->root_anon_vma->lock);
+	state->root_anon_vma = anon_vma->root;
+	spin_lock(&state->root_anon_vma->lock);
+}
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
