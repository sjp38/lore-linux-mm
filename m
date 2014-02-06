Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id A52E06B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:38:14 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id c41so2411527yho.34
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:38:14 -0800 (PST)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id d67si1251312qgf.75.2014.02.06.10.15.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 10:16:13 -0800 (PST)
Received: by mail-qa0-f47.google.com with SMTP id j5so3342699qaq.6
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 10:15:43 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [PATCH v5 1/3] mm: Create utility function for accessing a tasks commandline value
Date: Thu,  6 Feb 2014 10:15:26 -0800
Message-Id: <1391710528-23481-1-git-send-email-wroberts@tresys.com>
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
