Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7332D6B0254
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:01:29 -0500 (EST)
Received: by wicfv8 with SMTP id fv8so34012113wic.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:01:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd8si2028464wjb.183.2015.11.04.07.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 07:01:25 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/5] mm, page_owner: track last migrate reason
Date: Wed,  4 Nov 2015 16:01:00 +0100
Message-Id: <1446649261-27122-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

During migration, page_owner info is now copied with the rest of the page, so
the stacktrace leading to free page allocation during migration is overwritten.
For debugging purposes, it might be however useful to know that the page has
been migrated since its initial allocation. This might happen many times during
the lifetime for different reasons, and fully tracking this, especially with
stacktraces would incur extra memory costs. As a compromise, store the
migrate_reason of the last migration that occurred to the page. This is enough
to distinguish compaction, numa balancing etc.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/page_ext.h   |  1 +
 include/linux/page_owner.h |  9 +++++++++
 mm/migrate.c               |  9 ++++++---
 mm/page_owner.c            | 16 ++++++++++++++++
 4 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 17f118a..e1fe7cf 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -45,6 +45,7 @@ struct page_ext {
 	unsigned int order;
 	gfp_t gfp_mask;
 	unsigned int nr_entries;
+	int last_migrate_reason;
 	unsigned long trace_entries[8];
 #endif
 };
diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 6440daa..555893b 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -12,6 +12,7 @@ extern void __set_page_owner(struct page *page,
 			unsigned int order, gfp_t gfp_mask);
 extern gfp_t __get_page_owner_gfp(struct page *page);
 extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
+extern void __set_page_owner_migrate_reason(struct page *page, int reason);
 
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -38,6 +39,11 @@ static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
 	if (static_branch_unlikely(&page_owner_inited))
 		__copy_page_owner(oldpage, newpage);
 }
+static inline void set_page_owner_migrate_reason(struct page *page, int reason)
+{
+	if (static_branch_unlikely(&page_owner_inited))
+		__set_page_owner_migrate_reason(page, reason);
+}
 #else
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -53,5 +59,8 @@ static inline gfp_t get_page_owner_gfp(struct page *page)
 static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
 {
 }
+static inline void set_page_owner_migrate_reason(struct page *page, int reason)
+{
+}
 #endif /* CONFIG_PAGE_OWNER */
 #endif /* __LINUX_PAGE_OWNER_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 9f82e03..5a4fb1f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -954,8 +954,10 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	}
 
 	rc = __unmap_and_move(page, newpage, force, mode);
-	if (rc == MIGRATEPAGE_SUCCESS)
+	if (rc == MIGRATEPAGE_SUCCESS) {
 		put_new_page = NULL;
+		set_page_owner_migrate_reason(newpage, reason);
+	}
 
 out:
 	if (rc != -EAGAIN) {
@@ -1020,7 +1022,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 static int unmap_and_move_huge_page(new_page_t get_new_page,
 				free_page_t put_new_page, unsigned long private,
 				struct page *hpage, int force,
-				enum migrate_mode mode)
+				enum migrate_mode mode, int reason)
 {
 	int rc = -EAGAIN;
 	int *result = NULL;
@@ -1078,6 +1080,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	if (rc == MIGRATEPAGE_SUCCESS) {
 		hugetlb_cgroup_migrate(hpage, new_hpage);
 		put_new_page = NULL;
+		set_page_owner_migrate_reason(new_hpage, reason);
 	}
 
 	unlock_page(hpage);
@@ -1150,7 +1153,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 			if (PageHuge(page))
 				rc = unmap_and_move_huge_page(get_new_page,
 						put_new_page, private, page,
-						pass > 2, mode);
+						pass > 2, mode, reason);
 			else
 				rc = unmap_and_move(get_new_page, put_new_page,
 						private, page, pass > 2, mode,
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 7ebd3d0..388898f 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -73,10 +73,18 @@ void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
 	page_ext->order = order;
 	page_ext->gfp_mask = gfp_mask;
 	page_ext->nr_entries = trace.nr_entries;
+	page_ext->last_migrate_reason = -1;
 
 	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
 }
 
+void __set_page_owner_migrate_reason(struct page *page, int reason)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
+
+	page_ext->last_migrate_reason = reason;
+}
+
 gfp_t __get_page_owner_gfp(struct page *page)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
@@ -152,6 +160,14 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	if (ret >= count)
 		goto err;
 
+	if (page_ext->last_migrate_reason != -1) {
+		ret += snprintf(kbuf + ret, count - ret,
+			"Page has been migrated, last migrate reason: %d\n",
+			page_ext->last_migrate_reason);
+		if (ret >= count)
+			goto err;
+	}
+
 	ret += snprintf(kbuf + ret, count - ret, "\n");
 	if (ret >= count)
 		goto err;
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
