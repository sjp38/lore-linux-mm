Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 255C66B025E
	for <linux-mm@kvack.org>; Sun, 27 Mar 2016 15:47:50 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 4so121253641pfd.0
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 12:47:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 16si18201993pfo.244.2016.03.27.12.47.48
        for <linux-mm@kvack.org>;
        Sun, 27 Mar 2016 12:47:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] mm: introduce struct head_page and compound_head_t
Date: Sun, 27 Mar 2016 22:47:38 +0300
Message-Id: <1459108060-69891-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459108060-69891-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20160327194649.GA9638@node.shutemov.name>
 <1459108060-69891-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch creates new type that is compatible with struct page on
memory layout, but distinct from C point of view.

compound_head_t() has the same functionality as compound_head(), but
returns pointer on struct head_page.

Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h   | 4 ++++
 include/linux/page-flags.h | 9 ++++++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 944b2b37313b..247e86adaa1c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -225,6 +225,10 @@ struct page {
 #endif
 ;
 
+struct head_page {
+	struct page page;
+};
+
 struct page_frag {
 	struct page *page;
 #if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d111caad2a22..54801253b85c 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -133,7 +133,9 @@ enum pageflags {
 
 #ifndef __GENERATING_BOUNDS_H
 
-struct page;	/* forward declaration */
+/* forward declaration */
+struct page;
+struct head_page;
 
 static inline struct page *compound_head(struct page *page)
 {
@@ -144,6 +146,11 @@ static inline struct page *compound_head(struct page *page)
 	return page;
 }
 
+static inline struct head_page *compound_head_t(struct page *page)
+{
+	return (struct head_page *)compound_head(page);
+}
+
 static __always_inline int PageTail(struct page *page)
 {
 	return READ_ONCE(page->compound_head) & 1;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
