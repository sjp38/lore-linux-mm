Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 99DD86B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 11:54:00 -0400 (EDT)
Received: by wyj26 with SMTP id 26so1846761wyj.14
        for <linux-mm@kvack.org>; Fri, 09 Jul 2010 08:53:57 -0700 (PDT)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH 1/2] Add trace events to mmap and brk
Date: Fri,  9 Jul 2010 16:53:49 +0100
Message-Id: <1278690830-22145-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

As requested by Peter Zijlstra, this patch builds on my earlier patch
and adds the corresponding trace points to mmap and brk.

Signed-off-by: Eric B Munson <emunson@mgebm.net>
---
 include/trace/events/mm.h |   38 ++++++++++++++++++++++++++++++++++++++
 mm/mmap.c                 |   10 +++++++++-
 2 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
index c3a3857..1563988 100644
--- a/include/trace/events/mm.h
+++ b/include/trace/events/mm.h
@@ -24,6 +24,44 @@ TRACE_EVENT(munmap,
 	TP_printk("unmapping %u bytes at %lu\n", __entry->len, __entry->start)
 );
 
+TRACE_EVENT(brk,
+	TP_PROTO(unsigned long addr, unsigned long len),
+
+	TP_ARGS(addr, len),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, addr)
+		__field(unsigned long, len)
+	),
+
+	TP_fast_assign(
+		__entry->addr = addr;
+		__entry->len = len;
+	),
+
+	TP_printk("brk mmapping %lu bytes at %lu\n", __entry->len,
+		   __entry->addr)
+);
+
+TRACE_EVENT(mmap,
+	TP_PROTO(unsigned long addr, unsigned long len),
+
+	TP_ARGS(addr, len),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, addr)
+		__field(unsigned long, len)
+	),
+
+	TP_fast_assign(
+		__entry->addr = addr;
+		__entry->len = len;
+	),
+
+	TP_printk("mmapping %lu bytes at %lu\n", __entry->len,
+		   __entry->addr)
+);
+
 #endif /* _TRACE_MM_H_ */
 
 /* This part must be outside protection */
diff --git a/mm/mmap.c b/mm/mmap.c
index 0775a30..252e3e0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -952,6 +952,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned int vm_flags;
 	int error;
 	unsigned long reqprot = prot;
+	unsigned long ret;
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1077,7 +1078,12 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	if (error)
 		return error;
 
-	return mmap_region(file, addr, len, flags, vm_flags, pgoff);
+	ret =  mmap_region(file, addr, len, flags, vm_flags, pgoff);
+
+	if (!(ret & ~PAGE_MASK))
+		trace_mmap(addr, len);
+
+	return ret;
 }
 EXPORT_SYMBOL(do_mmap_pgoff);
 
@@ -2218,6 +2224,8 @@ out:
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
