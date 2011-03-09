Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CF8308D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 19:44:17 -0500 (EST)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 3/6] mm: implement access_remote_vm
Date: Tue,  8 Mar 2011 19:42:20 -0500
Message-Id: <1299631343-4499-4-git-send-email-wilsons@start.ca>
In-Reply-To: <1299631343-4499-1-git-send-email-wilsons@start.ca>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

Provide an alternative to access_process_vm that allows the caller to obtain a
reference to the supplied mm_struct.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 include/linux/mm.h |    2 ++
 mm/memory.c        |   16 ++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 694512d..e5fde8a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -964,6 +964,8 @@ static inline int handle_mm_fault(struct mm_struct *mm,
 
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
+extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
+		void *buf, int len, int write);
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			unsigned long start, int nr_pages, int write, int force,
diff --git a/mm/memory.c b/mm/memory.c
index 68eec4f..c26e4f9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3654,6 +3654,22 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	return buf - old_buf;
 }
 
+/**
+ * @access_remote_vm - access another process' address space
+ * @mm:		the mm_struct of the target address space
+ * @addr:	start address to access
+ * @buf:	source or destination buffer
+ * @len:	number of bytes to transfer
+ * @write:	whether the access is a write
+ *
+ * The caller must hold a reference on @mm.
+ */
+int access_remote_vm(struct mm_struct *mm, unsigned long addr,
+		void *buf, int len, int write)
+{
+	return __access_remote_vm(NULL, mm, addr, buf, len, write);
+}
+
 /*
  * Access another process' address space.
  * Source/target buffer must be kernel space,
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
