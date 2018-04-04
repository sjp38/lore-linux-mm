Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06AD56B0285
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:34 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a125so15480697qkd.4
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:34 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 6si6741761qtx.305.2018.04.04.12.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:32 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 75/79] mm/page_ronly: add page read only core structure and helpers.
Date: Wed,  4 Apr 2018 15:18:27 -0400
Message-Id: <20180404191831.5378-38-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Page read only is a generic framework for page write protection.
It reuses the same mechanism as KSM by using the lower bit of the
page->mapping fields, and KSM is converted to use this generic
framework.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/page_ronly.h | 169 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 169 insertions(+)
 create mode 100644 include/linux/page_ronly.h

diff --git a/include/linux/page_ronly.h b/include/linux/page_ronly.h
new file mode 100644
index 000000000000..6312d4f015ea
--- /dev/null
+++ b/include/linux/page_ronly.h
@@ -0,0 +1,169 @@
+/*
+ * Copyright 2015 Red Hat Inc.
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
+ * Page read only generic wrapper. This is common struct use to write protect
+ * page by means of forbidding anyone from inserting a pte (page table entry)
+ * with write flag set. It reuse the ksm mecanism (which use lower bit of the
+ * mapping field of struct page).
+ */
+#ifndef LINUX_PAGE_RONLY_H
+#define LINUX_PAGE_RONLY_H
+#ifdef CONFIG_PAGE_RONLY
+
+#include <linux/types.h>
+#include <linux/page-flags.h>
+#include <linux/buffer_head.h>
+#include <linux/mm_types.h>
+
+
+/* enum page_ronly_event - Event that trigger a call to unprotec().
+ *
+ * @PAGE_RONLY_SWAPIN: Page fault on at an address with a swap entry pte.
+ * @PAGE_RONLY_WFAULT: Write page fault.
+ * @PAGE_RONLY_GUP: Get user page.
+ */
+enum page_ronly_event {
+	PAGE_RONLY_SWAPIN,
+	PAGE_RONLY_WFAULT,
+	PAGE_RONLY_GUP,
+};
+
+/* struct page_ronly_ops - Page read only operations.
+ *
+ * @unprotect: Callback to unprotect a page (mandatory).
+ * @rmap_walk: Callback to walk reverse mapping of a page (mandatory).
+ *
+ * Kernel user that want to use the page write protection mechanism have to
+ * provide a number of callback.
+ */
+struct page_ronly_ops {
+	struct page *(*unprotect)(struct page *page,
+				  unsigned long addr,
+				  struct vm_area_struct *vma,
+				  enum page_ronly_event event);
+	int (*rmap_walk)(struct page *page, struct rmap_walk_control *rwc);
+};
+
+/* struct page_ronly - Replace page->mapping when a page is write protected.
+ *
+ * @ops: Pointer to page read only operations.
+ *
+ * Page that are write protect have their page->mapping field pointing to this
+ * wrapper structure. It must be allocated by page read only user and must be
+ * free (if needed) inside unprotect() callback.
+ */
+struct page_ronly {
+	const struct page_ronly_ops	*ops;
+};
+
+
+/* page_ronly() - Return page_ronly struct if any or NULL.
+ *
+ * @page: The page for which to replace the page->mapping field.
+ */
+static inline struct page_ronly *page_ronly(struct page *page)
+{
+	return PageReadOnly(page) ? page_rmapping(page) : NULL;
+}
+
+/* page_ronly_set() - Replace page->mapping with ptr to page_ronly struct.
+ *
+ * @page: The page for which to replace the page->mapping field.
+ * @ronly: The page_ronly structure to set.
+ *
+ * Page must be locked.
+ */
+static inline void page_ronly_set(struct page *page, struct page_ronly *ronly)
+{
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+
+	page->mapping = (void *)ronly + (PAGE_MAPPING_ANON|PAGE_MAPPING_RONLY);
+}
+
+/* page_ronly_unprotect() - Unprotect a read only protected page.
+ *
+ * @page: The page to unprotect.
+ * @addr: Fault address that trigger the unprotect.
+ * @vma: The vma of the fault address.
+ * @event: Event which triggered the unprotect.
+ *
+ * Page must be locked and must be a read only page.
+ */
+static inline struct page *page_ronly_unprotect(struct page *page,
+						unsigned long addr,
+						struct vm_area_struct *vma,
+						enum page_ronly_event event)
+{
+	struct page_ronly *pageronly;
+
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	/*
+	 * Rely on the page lock to protect against concurrent modifications
+	 * to that page's node of the stable tree.
+	 */
+	VM_BUG_ON_PAGE(!PageReadOnly(page), page);
+	pageronly = page_ronly(page);
+	if (pageronly)
+		return pageronly->ops->unprotect(page, addr, vma, event);
+	/* Safest fallback. */
+	return page;
+}
+
+/* page_ronly_rmap_walk() - Walk all CPU page table mapping of a page.
+ *
+ * @page: The page for which to replace the page->mapping field.
+ * @rwc: Private control variable for each reverse walk.
+ *
+ * Page must be locked and must be a read only page.
+ */
+static inline void page_ronly_rmap_walk(struct page *page,
+					struct rmap_walk_control *rwc)
+{
+	struct page_ronly *pageronly;
+
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	/*
+	 * Rely on the page lock to protect against concurrent modifications
+	 * to that page's node of the stable tree.
+	 */
+	VM_BUG_ON_PAGE(!PageReadOnly(page), page);
+	pageronly = page_ronly(page);
+	if (pageronly)
+		pageronly->ops->rmap_walk(page, rwc);
+}
+
+#else /* CONFIG_PAGE_RONLY */
+
+static inline struct page *page_ronly_unprotect(struct page *page,
+						unsigned long addr,
+						struct vm_area_struct *vma,
+						enum page_ronly_event event)
+{
+	/* This should not happen ! */
+	VM_BUG_ON_PAGE(1, page);
+	return page;
+}
+
+static inline int page_ronly_rmap_walk(struct page *page,
+				       struct rmap_walk_control *rwc)
+{
+	/* This should not happen ! */
+	BUG();
+	return 0;
+}
+
+#endif /* CONFIG_PAGE_RONLY */
+#endif /* LINUX_PAGE_RONLY_H */
-- 
2.14.3
