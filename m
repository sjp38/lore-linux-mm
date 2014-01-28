Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id 060686B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 01:13:46 -0500 (EST)
Received: by mail-bk0-f48.google.com with SMTP id ej10so143196bkb.21
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 22:13:46 -0800 (PST)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id lk6si16679022bkb.132.2014.01.27.22.13.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 22:13:46 -0800 (PST)
Received: by mail-qc0-f172.google.com with SMTP id c9so9599788qcz.3
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 22:13:44 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [PATCH v5 1/3] mm: Create utility function for accessing a tasks commandline value
Date: Mon, 27 Jan 2014 22:13:46 -0800
Message-Id: <1390889628-5543-1-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov
Cc: William Roberts <wroberts@tresys.com>

introduce get_cmdline() for retreiving the value of a processes
proc/self/cmdline value.

Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Stephen Smalley <sds@tycho.nsa.gov>

Signed-off-by: William Roberts <wroberts@tresys.com>
---
 include/linux/mm.h |    1 +
 mm/util.c          |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f28f46e..db89a94 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1175,6 +1175,7 @@ void account_page_writeback(struct page *page);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
+int get_cmdline(struct task_struct *task, char *buffer, int buflen);
 
 /* Is the vma a continuation of the stack vma above it? */
 static inline int vma_growsdown(struct vm_area_struct *vma, unsigned long addr)
diff --git a/mm/util.c b/mm/util.c
index a24aa22..8122710 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -445,6 +445,54 @@ unsigned long vm_commit_limit(void)
 	return allowed;
 }
 
+/**
+ * get_cmdline() - copy the cmdline value to a buffer.
+ * @task:     the task whose cmdline value to copy.
+ * @buffer:   the buffer to copy to.
+ * @buflen:   the length of the buffer. Larger cmdline values are truncated
+ *            to this length.
+ * Returns the size of the cmdline field copied. Note that the copy does
+ * not guarantee an ending NULL byte.
+ */
+int get_cmdline(struct task_struct *task, char *buffer, int buflen)
+{
+	int res = 0;
+	unsigned int len;
+	struct mm_struct *mm = get_task_mm(task);
+	if (!mm)
+		goto out;
+	if (!mm->arg_end)
+		goto out_mm;	/* Shh! No looking before we're done */
+
+	len = mm->arg_end - mm->arg_start;
+
+	if (len > buflen)
+		len = buflen;
+
+	res = access_process_vm(task, mm->arg_start, buffer, len, 0);
+
+	/*
+	 * If the nul at the end of args has been overwritten, then
+	 * assume application is using setproctitle(3).
+	 */
+	if (res > 0 && buffer[res-1] != '\0' && len < buflen) {
+		len = strnlen(buffer, res);
+		if (len < res) {
+			res = len;
+		} else {
+			len = mm->env_end - mm->env_start;
+			if (len > buflen - res)
+				len = buflen - res;
+			res += access_process_vm(task, mm->env_start,
+						 buffer+res, len, 0);
+			res = strnlen(buffer, res);
+		}
+	}
+out_mm:
+	mmput(mm);
+out:
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
