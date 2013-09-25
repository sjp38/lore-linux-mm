Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F2D146B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 22:58:26 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so4551649pad.35
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:58:26 -0700 (PDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so5403290pdj.25
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:58:24 -0700 (PDT)
Date: Tue, 24 Sep 2013 19:58:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, mempolicy: make mpol_to_str robust and always succeed
In-Reply-To: <5227CF48.5080700@asianux.com>
Message-ID: <alpine.DEB.2.02.1309241957280.26415@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chen Gang <gang.chen@asianux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

mpol_to_str() should not fail.  Currently, it either fails because the
string buffer is too small or because a string hasn't been defined for a
mempolicy mode.

If a new mempolicy mode is introduced and no string is defined for it,
just warn and return "unknown".

If the buffer is too small, just truncate the string and return, the same
behavior as snprintf().

This also fixes a bug where there was no NULL-byte termination when doing
*p++ = '=' and *p++ ':' and maxlen has been reached.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/proc/task_mmu.c        | 14 ++++++-------
 include/linux/mempolicy.h |  5 ++---
 mm/mempolicy.c            | 52 +++++++++++++++--------------------------------
 3 files changed, 24 insertions(+), 47 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1385,8 +1385,8 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	struct mm_struct *mm = vma->vm_mm;
 	struct mm_walk walk = {};
 	struct mempolicy *pol;
-	int n;
-	char buffer[50];
+	char buffer[64];
+	int nid;
 
 	if (!mm)
 		return 0;
@@ -1402,10 +1402,8 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	walk.mm = mm;
 
 	pol = get_vma_policy(task, vma, vma->vm_start);
-	n = mpol_to_str(buffer, sizeof(buffer), pol);
+	mpol_to_str(buffer, sizeof(buffer), pol);
 	mpol_cond_put(pol);
-	if (n < 0)
-		return n;
 
 	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
 
@@ -1458,9 +1456,9 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	if (md->writeback)
 		seq_printf(m, " writeback=%lu", md->writeback);
 
-	for_each_node_state(n, N_MEMORY)
-		if (md->node[n])
-			seq_printf(m, " N%d=%lu", n, md->node[n]);
+	for_each_node_state(nid, N_MEMORY)
+		if (md->node[nid])
+			seq_printf(m, " N%d=%lu", nid, md->node[nid]);
 out:
 	seq_putc(m, '\n');
 
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -168,7 +168,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 extern int mpol_parse_str(char *str, struct mempolicy **mpol);
 #endif
 
-extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
+extern void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
 
 /* Check if a vma is migratable */
 static inline int vma_migratable(struct vm_area_struct *vma)
@@ -306,9 +306,8 @@ static inline int mpol_parse_str(char *str, struct mempolicy **mpol)
 }
 #endif
 
-static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
+static inline void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 {
-	return 0;
 }
 
 static inline int mpol_misplaced(struct page *page, struct vm_area_struct *vma,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2840,62 +2840,45 @@ out:
  * @maxlen:  length of @buffer
  * @pol:  pointer to mempolicy to be formatted
  *
- * Convert a mempolicy into a string.
- * Returns the number of characters in buffer (if positive)
- * or an error (negative)
+ * Convert @pol into a string.  If @buffer is too short, truncate the string.
+ * Recommend a @maxlen of at least 32 for the longest mode, "interleave", the
+ * longest flag, "relative", and to display at least a few node ids.
  */
-int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
+void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 {
 	char *p = buffer;
-	int l;
-	nodemask_t nodes;
-	unsigned short mode;
-	unsigned short flags = pol ? pol->flags : 0;
-
-	/*
-	 * Sanity check:  room for longest mode, flag and some nodes
-	 */
-	VM_BUG_ON(maxlen < strlen("interleave") + strlen("relative") + 16);
+	nodemask_t nodes = NODE_MASK_NONE;
+	unsigned short mode = MPOL_DEFAULT;
+	unsigned short flags = 0;
 
-	if (!pol || pol == &default_policy)
-		mode = MPOL_DEFAULT;
-	else
+	if (pol && pol != &default_policy) {
 		mode = pol->mode;
+		flags = pol->flags;
+	}
 
 	switch (mode) {
 	case MPOL_DEFAULT:
-		nodes_clear(nodes);
 		break;
-
 	case MPOL_PREFERRED:
-		nodes_clear(nodes);
 		if (flags & MPOL_F_LOCAL)
 			mode = MPOL_LOCAL;
 		else
 			node_set(pol->v.preferred_node, nodes);
 		break;
-
 	case MPOL_BIND:
-		/* Fall through */
 	case MPOL_INTERLEAVE:
 		nodes = pol->v.nodes;
 		break;
-
 	default:
-		return -EINVAL;
+		WARN_ON_ONCE(1);
+		snprintf(p, maxlen, "unknown");
+		return;
 	}
 
-	l = strlen(policy_modes[mode]);
-	if (buffer + maxlen < p + l + 1)
-		return -ENOSPC;
-
-	strcpy(p, policy_modes[mode]);
-	p += l;
+	p += snprintf(p, maxlen, policy_modes[mode]);
 
 	if (flags & MPOL_MODE_FLAGS) {
-		if (buffer + maxlen < p + 2)
-			return -ENOSPC;
-		*p++ = '=';
+		p += snprintf(p, buffer + maxlen - p, "=");
 
 		/*
 		 * Currently, the only defined flags are mutually exclusive
@@ -2907,10 +2890,7 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 	}
 
 	if (!nodes_empty(nodes)) {
-		if (buffer + maxlen < p + 2)
-			return -ENOSPC;
-		*p++ = ':';
+		p += snprintf(p, buffer + maxlen - p, ":");
 	 	p += nodelist_scnprintf(p, buffer + maxlen - p, nodes);
 	}
-	return p - buffer;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
