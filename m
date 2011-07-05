Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1F889900122
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 04:23:09 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p658GkbK002011
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:16:46 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p658N5sX1175634
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:23:05 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p658N443029931
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:23:05 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 4/5] Capture references to page cache pages
Date: Tue,  5 Jul 2011 13:52:38 +0530
Message-Id: <1309854159-8277-5-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Hi,

Page cache accesses may not be mapped, hence fake an access when a
pagecache page is looked up, by marking the corresponding memory
address block as accessed.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 mm/filemap.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index a8251a8..7ae7f36 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,6 +36,7 @@
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
 #include <linux/cleancache.h>
 #include "internal.h"
+#include <linux/memtrace.h>
 
 /*
  * FIXME: remove all knowledge of the buffer layer from the core VM
@@ -730,6 +731,13 @@ repeat:
 			page_cache_release(page);
 			goto repeat;
 		}
+#if defined(CONFIG_MEMTRACE)
+		if(get_pg_trace_pid() != -1 && current->mem_trace) {
+			unsigned long pfn = page_to_pfn(page);
+			if(pfn_valid(pfn))
+				mark_memtrace_block_accessed(pfn << PAGE_SHIFT);
+		}
+#endif
 	}
 out:
 	rcu_read_unlock();
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
