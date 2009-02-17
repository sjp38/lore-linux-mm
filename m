Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7526B005A
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 06:05:02 -0500 (EST)
Message-ID: <499A99BC.2080700@bk.jp.nec.com>
Date: Tue, 17 Feb 2009 20:04:28 +0900
From: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
References: <499A7CAD.9030409@bk.jp.nec.com> <1234863220.4744.34.camel@laptop>
In-Reply-To: <1234863220.4744.34.camel@laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, rostedt@goodmis.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Tue, 2009-02-17 at 18:00 +0900, Atsushi Tsuji wrote:
> 
>> The below patch adds instrumentation for pagecache.
> 
> And somehow you forgot to CC any of the mm people.. ;-)

Hi Peter,

Ah, sorry.
Thank you for adding to CC list.

>> +DECLARE_TRACE(filemap_add_to_page_cache,
>> +	TPPROTO(struct address_space *mapping, pgoff_t offset),
>> +	TPARGS(mapping, offset));
>> +DECLARE_TRACE(filemap_remove_from_page_cache,
>> +	TPPROTO(struct address_space *mapping),
>> +	TPARGS(mapping));
> 
> This is rather asymmetric, why don't we care about the offset for the
> removed page?
> 

Indeed.
I added the offset to the argument for the removed page and resend fixed patch.

Signed-off-by: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
---
diff --git a/include/trace/filemap.h b/include/trace/filemap.h
new file mode 100644
index 0000000..a17dc92
--- /dev/null
+++ b/include/trace/filemap.h
@@ -0,0 +1,13 @@
+#ifndef _TRACE_FILEMAP_H
+#define _TRACE_FILEMAP_H
+
+#include <linux/tracepoint.h>
+
+DECLARE_TRACE(filemap_add_to_page_cache,
+	TPPROTO(struct address_space *mapping, pgoff_t offset),
+	TPARGS(mapping, offset));
+DECLARE_TRACE(filemap_remove_from_page_cache,
+	TPPROTO(struct address_space *mapping, pgoff_t offset),
+	TPARGS(mapping, offset));
+
+#endif
diff --git a/mm/filemap.c b/mm/filemap.c
index 23acefe..23f75d2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -34,6 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <trace/filemap.h>
 #include "internal.h"
 
 /*
@@ -43,6 +44,8 @@
 
 #include <asm/mman.h>
 
+DEFINE_TRACE(filemap_add_to_page_cache);
+DEFINE_TRACE(filemap_remove_from_page_cache);
 
 /*
  * Shared mappings implemented 30.11.1994. It's not fully working yet,
@@ -120,6 +123,7 @@ void __remove_from_page_cache(struct page *page)
 	page->mapping = NULL;
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
+	trace_filemap_remove_from_page_cache(mapping, page->index);
 	BUG_ON(page_mapped(page));
 	mem_cgroup_uncharge_cache_page(page);
 
@@ -475,6 +479,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
+			trace_filemap_add_to_page_cache(mapping, offset);
 		} else {
 			page->mapping = NULL;
 			mem_cgroup_uncharge_cache_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
