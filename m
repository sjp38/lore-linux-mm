Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0F562800CA
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 03:12:53 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id fp1so9280844pdb.15
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 00:12:52 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gw3si20050621pbc.159.2014.11.24.00.12.46
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 00:12:48 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 8/8] Documentation: add new page_owner document
Date: Mon, 24 Nov 2014 17:15:26 +0900
Message-Id: <1416816926-7756-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

page owner is for the tracking about who allocated each page.
This document explains what is the page owner feature and what is
the merit of it. And, simple HOW-TO is also explained. See the document
for detailed information.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 Documentation/vm/page_owner.txt |   81 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 81 insertions(+)
 create mode 100644 Documentation/vm/page_owner.txt

diff --git a/Documentation/vm/page_owner.txt b/Documentation/vm/page_owner.txt
new file mode 100644
index 0000000..8f3ce9b
--- /dev/null
+++ b/Documentation/vm/page_owner.txt
@@ -0,0 +1,81 @@
+page owner: Tracking about who allocated each page
+-----------------------------------------------------------
+
+* Introduction
+
+page owner is for the tracking about who allocated each page.
+It can be used to debug memory leak or to find a memory hogger.
+When allocation happens, information about allocation such as call stack
+and order of pages is stored into certain storage for each page.
+When we need to know about status of all pages, we can get and analyze
+this information.
+
+Although we already have tracepoint for tracing page allocation/free,
+using it for analyzing who allocate each page is rather complex. We need
+to enlarge the trace buffer for preventing overlapping until userspace
+program launched. And, launched program continually dump out the trace
+buffer for later analysis and it would change system behviour with more
+possibility rather than just keeping it in memory, so bad for debugging.
+
+page owner can also be used for various purposes. For example, accurate
+fragmentation statistics can be obtained through gfp flag information of
+each page. It is already implemented and activated if page owner is
+enabled. Other usages are more than welcome.
+
+page owner is disabled in default. So, if you'd like to use it, you need
+to add "page_owner=on" into your boot cmdline. If the kernel is built
+with page owner and page owner is disabled in runtime due to no enabling
+boot option, runtime overhead is marginal. If disabled in runtime, it
+doesn't require memory to store owner information, so there is no runtime
+memory overhead. And, page owner inserts just two unlikely branches into
+the page allocator hotpath and if it returns false then allocation is
+done like as the kernel without page owner. These two unlikely branches
+would not affect to allocation performance. Following is the kernel's
+code size change due to this facility.
+
+- Without page owner
+   text    data     bss     dec     hex filename
+  40662    1493     644   42799    a72f mm/page_alloc.o
+
+- With page owner
+   text    data     bss     dec     hex filename
+  40892    1493     644   43029    a815 mm/page_alloc.o
+   1427      24       8    1459     5b3 mm/page_ext.o
+   2722      50       0    2772     ad4 mm/page_owner.o
+
+Although, roughly, 4 KB code is added in total, page_alloc.o increase by
+230 bytes and only half of it is in hotpath. Building the kernel with
+page owner and turning it on if needed would be great option to debug
+kernel memory problem.
+
+There is one notice that is caused by implementation detail. page owner
+stores information into the memory from struct page extension. This memory
+is initialized some time later than that page allocator starts in sparse
+memory system, so, until initialization, many pages can be allocated and
+they would have no owner information. To fix it up, these early allocated
+pages are investigated and marked as allocated in initialization phase.
+Although it doesn't mean that they have the right owner information,
+at least, we can tell whether the page is allocated or not,
+more accurately. On 2GB memory x86-64 VM box, 13343 early allocated pages
+are catched and marked, although they are mostly allocated from struct
+page extension feature. Anyway, after that, no page is left in
+un-tracking state.
+
+* Usage
+
+1) Build user-space helper
+	cd tools/vm
+	make page_owner_sort
+
+2) Enable page owner
+	Add "page_owner=on" to boot cmdline.
+
+3) Do the job what you want to debug
+
+4) Analyze information from page owner
+	cat /sys/kernel/debug/page_owner > page_owner_full.txt
+	grep -v ^PFN page_owner_full.txt > page_owner.txt
+	./page_owner_sort page_owner.txt sorted_page_owner.txt
+
+	See the result about who allocated each page
+	in the sorted_page_owner.txt.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
