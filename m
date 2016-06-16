Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE546B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 17:26:26 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id jf8so32530003lbc.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 14:26:26 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id f10si19095456wmi.72.2016.06.16.14.26.25
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 14:26:25 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 1/3] mm: Don't blindly assign fallback_migrate_page()
Date: Thu, 16 Jun 2016 23:26:13 +0200
Message-Id: <1466112375-1717-2-git-send-email-richard@nod.at>
In-Reply-To: <1466112375-1717-1-git-send-email-richard@nod.at>
References: <1466112375-1717-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, hughd@google.com, vbabka@suse.cz, akpm@linux-foundation.org, adrian.hunter@intel.com, dedekind1@gmail.com, richard@nod.at, hch@infradead.org, linux-fsdevel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, alex@nextthing.co, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com

While block oriented filesystems use buffer_migrate_page()
as page migration function other filesystems which don't
implement ->migratepage() will automatically get fallback_migrate_page()
assigned. fallback_migrate_page() is not as generic as is should
be. Page migration is filesystem specific and a one-fits-all function
is hard to achieve. UBIFS leaned this lection the hard way.
It uses various page flags and fallback_migrate_page() does not
handle these flags as UBIFS expected.

To make sure that no further filesystem will get confused by
fallback_migrate_page() disable the automatic assignment and
allow filesystems to use this function explicitly if it is
really suitable.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/migrate.h |  9 +++++++++
 mm/migrate.c            | 16 ++++++++++++----
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 9b50325..aba86d4 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -47,6 +47,9 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
 		struct buffer_head *head, enum migrate_mode mode,
 		int extra_count);
+extern int generic_migrate_page(struct address_space *mapping,
+				struct page *newpage, struct page *page,
+				enum migrate_mode mode);
 #else
 
 static inline void putback_movable_pages(struct list_head *l) {}
@@ -67,6 +70,12 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 	return -ENOSYS;
 }
 
+static inline int generic_migrate_page(struct address_space *mapping,
+				       struct page *newpage, struct page *page,
+				       enum migrate_mode mode)
+{
+	return -ENOSYS;
+}
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/migrate.c b/mm/migrate.c
index 9baf41c..5129143 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -719,8 +719,9 @@ static int writeout(struct address_space *mapping, struct page *page)
 /*
  * Default handling if a filesystem does not provide a migration function.
  */
-static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page, enum migrate_mode mode)
+int generic_migrate_page(struct address_space *mapping,
+			 struct page *newpage, struct page *page,
+			 enum migrate_mode mode)
 {
 	if (PageDirty(page)) {
 		/* Only writeback pages in full synchronous migration */
@@ -771,8 +772,15 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		 * is the most common path for page migration.
 		 */
 		rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
-	else
-		rc = fallback_migrate_page(mapping, newpage, page, mode);
+	else {
+		/*
+		 * Dear filesystem maintainer, please verify whether
+		 * generic_migrate_page() is suitable for your
+		 * filesystem, especially wrt. page flag handling.
+		 */
+		WARN_ON_ONCE(1);
+		rc = -EINVAL;
+	}
 
 	/*
 	 * When successful, old pagecache page->mapping must be cleared before
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
