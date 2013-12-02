Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id D60166B0038
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 16:10:49 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so13862436qeb.25
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:10:49 -0800 (PST)
Received: from mail-qe0-x22a.google.com (mail-qe0-x22a.google.com [2607:f8b0:400d:c02::22a])
        by mx.google.com with ESMTPS id k6si35836726qej.90.2013.12.02.13.10.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 13:10:49 -0800 (PST)
Received: by mail-qe0-f42.google.com with SMTP id b4so13292077qen.15
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:10:48 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [PATCH 1/3] mm: Create utility functions for accessing a tasks commandline value
Date: Mon,  2 Dec 2013 13:10:37 -0800
Message-Id: <1386018639-18916-2-git-send-email-wroberts@tresys.com>
In-Reply-To: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
References: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk
Cc: sds@tycho.nsa.gov, William Roberts <wroberts@tresys.com>

Add two new functions to mm.h:
* copy_cmdline()
* get_cmdline_length()

Signed-off-by: William Roberts <wroberts@tresys.com>
---
 include/linux/mm.h |    7 +++++++
 mm/util.c          |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd00..b4d7c26 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1135,6 +1135,13 @@ int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
 
+extern int copy_cmdline(struct task_struct *task, struct mm_struct *mm,
+			char *buf, unsigned int buflen);
+static inline unsigned int get_cmdline_length(struct mm_struct *mm)
+{
+	return mm->arg_end ? mm->arg_end - mm->arg_start : 0;
+}
+
 /* Is the vma a continuation of the stack vma above it? */
 static inline int vma_growsdown(struct vm_area_struct *vma, unsigned long addr)
 {
diff --git a/mm/util.c b/mm/util.c
index f7bc209..c8cad32 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -9,6 +9,7 @@
 #include <linux/swapops.h>
 #include <linux/mman.h>
 #include <linux/hugetlb.h>
+#include <linux/mm.h>
 
 #include <asm/uaccess.h>
 
@@ -410,6 +411,53 @@ unsigned long vm_commit_limit(void)
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 }
 
+/**
+ * copy_cmdline - Copy's the tasks commandline value to a buffer
+ * @task: The task whose command line to copy
+ * @mm: The mm struct refering to task with proper semaphores held
+ * @buf: The buffer to copy the value into
+ * @buflen: The length og the buffer. It trucates the value to
+ *           buflen.
+ * @return: The number of chars copied.
+ */
+int copy_cmdline(struct task_struct *task, struct mm_struct *mm,
+		 char *buf, unsigned int buflen)
+{
+	int res = 0;
+	unsigned int len;
+
+	if (!task || !mm || !buf)
+		return -1;
+
+	res = access_process_vm(task, mm->arg_start, buf, buflen, 0);
+	if (res <= 0)
+		return 0;
+
+	if (res > buflen)
+		res = buflen;
+	/*
+	 * If the nul at the end of args had been overwritten, then
+	 * assume application is using setproctitle(3).
+	 */
+	if (buf[res-1] != '\0') {
+		/* Nul between start and end of vm space?
+		   If so then truncate */
+		len = strnlen(buf, res);
+		if (len < res) {
+			res = len;
+		} else {
+			/* No nul, truncate buflen if to big */
+			len = mm->env_end - mm->env_start;
+			if (len > buflen - res)
+				len = buflen - res;
+			/* Copy any remaining data */
+			res += access_process_vm(task, mm->env_start, buf+res,
+						 len, 0);
+			res = strnlen(buf, res);
+		}
+	}
+	return res;
+}
 
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
