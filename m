Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 18A856B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:59:53 -0400 (EDT)
Received: by wyb36 with SMTP id 36so367676wyb.14
        for <linux-mm@kvack.org>; Thu, 02 Sep 2010 06:59:50 -0700 (PDT)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH 1/2] Add trace points to mmap, munmap, and brk
Date: Thu,  2 Sep 2010 14:59:44 +0100
Message-Id: <1283435985-21934-2-git-send-email-emunson@mgebm.net>
In-Reply-To: <1283435985-21934-1-git-send-email-emunson@mgebm.net>
References: <1283435985-21934-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

This patch adds trace points to mmap, munmap, and brk that will report
relevant addresses and sizes before each function exits successfully.

Signed-off-by: Eric B Munson <emunson@mgebm.net>
---
 include/trace/events/mm.h |   75 +++++++++++++++++++++++++++++++++++++++++++++
 mm/mmap.c                 |   15 ++++++++-
 2 files changed, 89 insertions(+), 1 deletions(-)
 create mode 100644 include/trace/events/mm.h

diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
new file mode 100644
index 0000000..892bbe3
--- /dev/null
+++ b/include/trace/events/mm.h
@@ -0,0 +1,75 @@
+/*
+ * Copyright (c) 2010, Eric Munson
+ * All Rights Reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write the Free Software Foundation,
+ * Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mm
+
+#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MM_H
+
+#include <linux/tracepoint.h>
+
+DECLARE_EVENT_CLASS(
+		mm_mmap_class,
+		TP_PROTO(unsigned long addr, unsigned long len),
+		TP_ARGS(addr, len),
+		TP_STRUCT__entry(
+			__field(unsigned long, addr)
+			__field(unsigned long, len)
+		),
+		TP_fast_assign(
+			__entry->addr = addr;
+			__entry->len = len;
+		),
+		TP_printk("%lu bytes at 0x%lx\n", __entry->len, __entry->addr)
+);
+
+DEFINE_EVENT(
+		mm_mmap_class,
+		mmap,
+		TP_PROTO(unsigned long addr, unsigned long len),
+		TP_ARGS(addr, len)
+);
+
+
+DEFINE_EVENT(
+		mm_mmap_class,
+		brk,
+		TP_PROTO(unsigned long addr, unsigned long len),
+		TP_ARGS(addr, len)
+);
+
+TRACE_EVENT(
+		munmap,
+		TP_PROTO(unsigned long start, size_t len),
+		TP_ARGS(start, len),
+		TP_STRUCT__entry(
+			__field(unsigned long, start)
+			__field(size_t, len)
+		),
+		TP_fast_assign(
+			__entry->start = start;
+			__entry->len = len;
+		),
+
+		TP_printk("%u bytes at 0x%lx\n", __entry->len, __entry->start)
+);
+
+#endif /* _TRACE_MM_H */
+
+#include <trace/define_trace.h>
+
diff --git a/mm/mmap.c b/mm/mmap.c
index 6128dc8..03f857b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -29,6 +29,9 @@
 #include <linux/mmu_notifier.h>
 #include <linux/perf_event.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/mm.h>
+
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlb.h>
@@ -971,6 +974,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned int vm_flags;
 	int error;
 	unsigned long reqprot = prot;
+	unsigned long ret;
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1096,7 +1100,12 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	if (error)
 		return error;
 
-	return mmap_region(file, addr, len, flags, vm_flags, pgoff);
+	ret = mmap_region(file, addr, len, flags, vm_flags, pgoff);
+
+	if(!(ret & ~PAGE_MASK))
+		trace_mmap(addr,len);
+
+	return ret;
 }
 EXPORT_SYMBOL(do_mmap_pgoff);
 
@@ -2104,6 +2113,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 		}
 	}
 
+	trace_munmap(start, len);
+
 	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
@@ -2239,6 +2250,8 @@ out:
 		if (!mlock_vma_pages_range(vma, addr, addr + len))
 			mm->locked_vm += (len >> PAGE_SHIFT);
 	}
+
+	trace_brk(addr, len);
 	return addr;
 }
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
