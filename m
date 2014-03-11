Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 70F026B0095
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 09:22:36 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so8755949pab.23
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 06:22:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id xe9si20182254pab.315.2014.03.11.06.22.34
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 06:22:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: use 'const char *' insted of 'char *' for reason in dump_page()
Date: Tue, 11 Mar 2014 15:18:41 +0200
Message-Id: <1394543921-8294-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I tried to use 'dump_page(page, __func__)' for debugging, but it
triggers warning:

  warning: passing argument 2 of a??dump_pagea?? discards a??consta?? qualifier from pointer target type [enabled by default]

Let's convert 'reason' to 'const char *' in dump_page() and friends:
we shouldn't modify it anyway.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mmdebug.h |  4 ++--
 mm/page_alloc.c         | 12 +++++++-----
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 5042c036dda9..2d57efa64cc1 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -3,8 +3,8 @@
 
 struct page;
 
-extern void dump_page(struct page *page, char *reason);
-extern void dump_page_badflags(struct page *page, char *reason,
+extern void dump_page(struct page *page, const char *reason);
+extern void dump_page_badflags(struct page *page, const char *reason,
 			       unsigned long badflags);
 
 #ifdef CONFIG_DEBUG_VM
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3758a09a009..a648a11f1108 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -295,7 +295,8 @@ static inline int bad_range(struct zone *zone, struct page *page)
 }
 #endif
 
-static void bad_page(struct page *page, char *reason, unsigned long bad_flags)
+static void bad_page(struct page *page, const char *reason,
+		unsigned long bad_flags)
 {
 	static unsigned long resume;
 	static unsigned long nr_shown;
@@ -621,7 +622,7 @@ out:
 
 static inline int free_pages_check(struct page *page)
 {
-	char *bad_reason = NULL;
+	const char *bad_reason = NULL;
 	unsigned long bad_flags = 0;
 
 	if (unlikely(page_mapcount(page)))
@@ -857,7 +858,7 @@ static inline void expand(struct zone *zone, struct page *page,
  */
 static inline int check_new_page(struct page *page)
 {
-	char *bad_reason = NULL;
+	const char *bad_reason = NULL;
 	unsigned long bad_flags = 0;
 
 	if (unlikely(page_mapcount(page)))
@@ -6524,7 +6525,8 @@ static void dump_page_flags(unsigned long flags)
 	printk(")\n");
 }
 
-void dump_page_badflags(struct page *page, char *reason, unsigned long badflags)
+void dump_page_badflags(struct page *page, const char *reason,
+		unsigned long badflags)
 {
 	printk(KERN_ALERT
 	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
@@ -6540,7 +6542,7 @@ void dump_page_badflags(struct page *page, char *reason, unsigned long badflags)
 	mem_cgroup_print_bad_page(page);
 }
 
-void dump_page(struct page *page, char *reason)
+void dump_page(struct page *page, const char *reason)
 {
 	dump_page_badflags(page, reason, 0);
 }
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
