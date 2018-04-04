Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB23B6B0008
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v6so5625262qkd.23
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:03 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e127si6606659qkc.124.2018.04.04.12.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:02 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 06/79] mm/page: add helpers to dereference struct page index field
Date: Wed,  4 Apr 2018 15:17:53 -0400
Message-Id: <20180404191831.5378-4-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Regroup all helpers that dereference struct page.index field into one
place and require a the address_space (mapping) against which caller
is looking the index (offset, pgoff, ...)

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mm-page.h | 136 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h      |   5 ++
 2 files changed, 141 insertions(+)
 create mode 100644 include/linux/mm-page.h

diff --git a/include/linux/mm-page.h b/include/linux/mm-page.h
new file mode 100644
index 000000000000..2981db45eeef
--- /dev/null
+++ b/include/linux/mm-page.h
@@ -0,0 +1,136 @@
+/*
+ * Copyright 2018 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/*
+ * This header file regroup everything that deal with struct page and has no
+ * outside dependency except basic types header files.
+ */
+/* Protected against rogue include ... do not include this file directly */
+#ifdef DOT_NOT_INCLUDE___INSIDE_MM
+#ifndef MM_PAGE_H
+#define MM_PAGE_H
+
+/* External struct dependencies: */
+struct address_space;
+
+/* External function dependencies: */
+extern pgoff_t __page_file_index(struct page *page);
+
+
+/*
+ * _page_index() - return page index value (with special case for swap)
+ * @page: page struct pointer for which we want the index value
+ * @mapping: mapping against which we want the page index
+ * Returns: index value for the page in the given mapping
+ *
+ * The index value of a page is against a given mapping and page which belongs
+ * to swap cache need special handling. For swap cache page what we want is the
+ * swap offset which is store encoded with other fields in page->private.
+ */
+static inline unsigned long _page_index(struct page *page,
+		struct address_space *mapping)
+{
+	if (unlikely(PageSwapCache(page)))
+		return __page_file_index(page);
+	return page->index;
+}
+
+/*
+ * _page_set_index() - set page index value against a give mapping
+ * @page: page struct pointer for which we want the index value
+ * @mapping: mapping against which we want the page index
+ * @index: index value to set
+ */
+static inline void _page_set_index(struct page *page,
+		struct address_space *mapping,
+		unsigned long index)
+{
+	page->index = index;
+}
+
+/*
+ * _page_to_index() - page index value against a give mapping
+ * @page: page struct pointer for which we want the index value
+ * @mapping: mapping against which we want the page index
+ * Returns: index value for the page in the given mapping
+ *
+ * The index value of a page is against a given mapping. THP page need special
+ * handling has the index is set in the head page thus the final index value is
+ * the tail page index plus the number of page from current page to head page.
+ */
+static inline unsigned long _page_to_index(struct page *page,
+		struct address_space *mapping)
+{
+	unsigned long pgoff;
+
+	if (likely(!PageTransTail(page)))
+		return page->index;
+
+	/*
+	 *  We don't initialize ->index for tail pages: calculate based on
+	 *  head page
+	 */
+	pgoff = compound_head(page)->index;
+	pgoff += page - compound_head(page);
+	return pgoff;
+}
+
+/*
+ * _page_to_pgoff() - page pgoff value against a give mapping
+ * @page: page struct pointer for which we want the index value
+ * @mapping: mapping against which we want the page index
+ * Returns: pgoff value for the page in the given mapping
+ *
+ * The pgoff value of a page is against a given mapping. Hugetlb pages need
+ * special handling as for they have page->index in size of the huge pages
+ * (PMD_SIZE or  PUD_SIZE), not in PAGE_SIZE as other types of pages.
+ *
+ * FIXME convert hugetlb to multi-order entries.
+ */
+static inline unsigned long _page_to_pgoff(struct page *page,
+		struct address_space *mapping)
+{
+	if (unlikely(PageHeadHuge(page)))
+		return page->index << compound_order(page);
+
+	return _page_to_index(page, mapping);
+}
+
+/*
+ * _page_offset() - page offset (in bytes) against a give mapping
+ * @page: page struct pointer for which we want the index value
+ * @mapping: mapping against which we want the page index
+ * Returns: page offset (in bytes) for the page in the given mapping
+ */
+static inline unsigned long _page_offset(struct page *page,
+		struct address_space *mapping)
+{
+	return page->index << PAGE_SHIFT;
+}
+
+/*
+ * _page_file_offset() - page offset (in bytes) against a give mapping
+ * @page: page struct pointer for which we want the index value
+ * @mapping: mapping against which we want the page index
+ * Returns: page offset (in bytes) for the page in the given mapping
+ */
+static inline unsigned long _page_file_offset(struct page *page,
+		struct address_space *mapping)
+{
+	return page->index << PAGE_SHIFT;
+}
+
+#endif /* MM_PAGE_H */
+#endif /* DOT_NOT_INCLUDE___INSIDE_MM */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42adb1a..874a10f011ee 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2673,5 +2673,10 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+/* Include here while header consolidation process is in progress */
+#define DOT_NOT_INCLUDE___INSIDE_MM
+#include <linux/mm-page.h>
+#undef DOT_NOT_INCLUDE___INSIDE_MM
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
-- 
2.14.3
