Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 284BE6B000E
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 00:02:33 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h9-v6so5860384pgs.11
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 21:02:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c195-v6sor6142756pfc.33.2018.10.04.21.02.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 21:02:31 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH v2 2/3] mm: introduce put_user_page[s](), placeholder versions
Date: Thu,  4 Oct 2018 21:02:24 -0700
Message-Id: <20181005040225.14292-3-jhubbard@nvidia.com>
In-Reply-To: <20181005040225.14292-1-jhubbard@nvidia.com>
References: <20181005040225.14292-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>

From: John Hubbard <jhubbard@nvidia.com>

Introduces put_user_page(), which simply calls put_page().
This provides a way to update all get_user_pages*() callers,
so that they call put_user_page(), instead of put_page().

Also introduces put_user_pages(), and a few dirty/locked variations,
as a replacement for release_pages(), for the same reasons.
These may be used for subsequent performance improvements,
via batching of pages to be released.

This prepares for eventually fixing the problem described
in [1], and is following a plan listed in [2], [3], [4].

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

[2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
    Proposed steps for fixing get_user_pages() + DMA problems.

[3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
    Bounce buffers (otherwise [2] is not really viable).

[4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
    Follow-up discussions.

CC: Matthew Wilcox <willy@infradead.org>
CC: Michal Hocko <mhocko@kernel.org>
CC: Christopher Lameter <cl@linux.com>
CC: Jason Gunthorpe <jgg@ziepe.ca>
CC: Dan Williams <dan.j.williams@intel.com>
CC: Jan Kara <jack@suse.cz>
CC: Al Viro <viro@zeniv.linux.org.uk>
CC: Jerome Glisse <jglisse@redhat.com>
CC: Christoph Hellwig <hch@infradead.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h | 42 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..1a9aae7c659f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -137,6 +137,8 @@ extern int overcommit_ratio_handler(struct ctl_table *, int, void __user *,
 				    size_t *, loff_t *);
 extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 				    size_t *, loff_t *);
+int set_page_dirty(struct page *page);
+int set_page_dirty_lock(struct page *page);
 
 #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
 
@@ -943,6 +945,44 @@ static inline void put_page(struct page *page)
 		__put_page(page);
 }
 
+/* Placeholder version, until all get_user_pages*() callers are updated. */
+static inline void put_user_page(struct page *page)
+{
+	put_page(page);
+}
+
+/* For get_user_pages*()-pinned pages, use these variants instead of
+ * release_pages():
+ */
+static inline void put_user_pages_dirty(struct page **pages,
+					unsigned long npages)
+{
+	while (npages) {
+		set_page_dirty(pages[npages]);
+		put_user_page(pages[npages]);
+		--npages;
+	}
+}
+
+static inline void put_user_pages_dirty_lock(struct page **pages,
+					     unsigned long npages)
+{
+	while (npages) {
+		set_page_dirty_lock(pages[npages]);
+		put_user_page(pages[npages]);
+		--npages;
+	}
+}
+
+static inline void put_user_pages(struct page **pages,
+				  unsigned long npages)
+{
+	while (npages) {
+		put_user_page(pages[npages]);
+		--npages;
+	}
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
@@ -1534,8 +1574,6 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
 void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb);
-int set_page_dirty(struct page *page);
-int set_page_dirty_lock(struct page *page);
 void __cancel_dirty_page(struct page *page);
 static inline void cancel_dirty_page(struct page *page)
 {
-- 
2.19.0
