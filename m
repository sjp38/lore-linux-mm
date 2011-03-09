Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 39CCC8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 19:43:30 -0500 (EST)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 2/6] mm: factor out main logic of access_process_vm
Date: Tue,  8 Mar 2011 19:42:19 -0500
Message-Id: <1299631343-4499-3-git-send-email-wilsons@start.ca>
In-Reply-To: <1299631343-4499-1-git-send-email-wilsons@start.ca>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

Introduce an internal helper __access_remote_vm and base access_process_vm on
top of it.  This new method may be called with a NULL task_struct if page fault
accounting is not desired.  This code will be shared with a new address space
accessor that is independent of task_struct.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 mm/memory.c |   35 +++++++++++++++++++++++++----------
 1 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 36445e3..68eec4f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3593,20 +3593,15 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 #endif
 
 /*
- * Access another process' address space.
- * Source/target buffer must be kernel space,
- * Do not walk the page table directly, use get_user_pages
+ * Access another process' address space as given in mm.  If non-NULL, use the
+ * given task for page fault accounting.
  */
-int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write)
+static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long addr, void *buf, int len, int write)
 {
-	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	void *old_buf = buf;
 
-	mm = get_task_mm(tsk);
-	if (!mm)
-		return 0;
-
 	down_read(&mm->mmap_sem);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
@@ -3655,12 +3650,32 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, in
 		addr += bytes;
 	}
 	up_read(&mm->mmap_sem);
-	mmput(mm);
 
 	return buf - old_buf;
 }
 
 /*
+ * Access another process' address space.
+ * Source/target buffer must be kernel space,
+ * Do not walk the page table directly, use get_user_pages
+ */
+int access_process_vm(struct task_struct *tsk, unsigned long addr,
+		void *buf, int len, int write)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	mm = get_task_mm(tsk);
+	if (!mm)
+		return 0;
+
+	ret = __access_remote_vm(tsk, mm, addr, buf, len, write);
+	mmput(mm);
+
+	return ret;
+}
+
+/*
  * Print the name of a VMA.
  */
 void print_vma_addr(char *prefix, unsigned long ip)
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
