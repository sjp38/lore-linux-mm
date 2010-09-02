Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9DDC76B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:59:51 -0400 (EDT)
Received: by wwb39 with SMTP id 39so424635wwb.2
        for <linux-mm@kvack.org>; Thu, 02 Sep 2010 06:59:49 -0700 (PDT)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH 2/2] Add mremap trace point
Date: Thu,  2 Sep 2010 14:59:45 +0100
Message-Id: <1283435985-21934-3-git-send-email-emunson@mgebm.net>
In-Reply-To: <1283435985-21934-1-git-send-email-emunson@mgebm.net>
References: <1283435985-21934-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

This patch adds the trace point for mremap which reports relevant addresses
and sizes when mremap exits successfully.

Signed-off-by: Eric B Munson <emunson@mgebm.net>
---
 include/trace/events/mm.h |   22 ++++++++++++++++++++++
 mm/mremap.c               |    4 ++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
index 892bbe3..16f8c36 100644
--- a/include/trace/events/mm.h
+++ b/include/trace/events/mm.h
@@ -69,6 +69,28 @@ TRACE_EVENT(
 		TP_printk("%u bytes at 0x%lx\n", __entry->len, __entry->start)
 );
 
+TRACE_EVENT(
+		mremap,
+		TP_PROTO(unsigned long addr, unsigned long old_len,
+			 unsigned long new_addr, unsigned long new_len),
+		TP_ARGS(addr, old_len, new_addr, new_len),
+		TP_STRUCT__entry(
+			__field(unsigned long, addr)
+			__field(unsigned long, old_len)
+			__field(unsigned long, new_addr)
+			__field(unsigned long, new_len)
+		),
+		TP_fast_assign(
+			__entry->addr = addr;
+			__entry->old_len = old_len;
+			__entry->new_addr = new_addr;
+			__entry->new_len = new_len;
+		),
+		TP_printk("%lu bytes from 0x%lx to %lu bytes at 0x%lx\n",
+			__entry->old_len, __entry->addr, __entry->new_len,
+			__entry->new_addr)
+);
+
 #endif /* _TRACE_MM_H */
 
 #include <trace/define_trace.h>
diff --git a/mm/mremap.c b/mm/mremap.c
index cde56ee..4ef1dd3 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -20,6 +20,8 @@
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
 
+#include <trace/events/mm.h>
+
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
@@ -504,6 +506,8 @@ unsigned long do_mremap(unsigned long addr,
 out:
 	if (ret & ~PAGE_MASK)
 		vm_unacct_memory(charged);
+	else
+		trace_mremap(addr, old_len, new_addr, new_len);
 	return ret;
 }
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
