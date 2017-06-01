Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 873DE6B0311
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:22 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id s131so31846297itd.6
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:22 -0700 (PDT)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id 70si33323332itr.103.2017.06.01.01.17.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:21 -0700 (PDT)
Received: by mail-io0-x244.google.com with SMTP id m4so4195956ioe.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 7/9] mm: hwpoison: dissolve in-use hugepage in unrecoverable memory error
Date: Thu,  1 Jun 2017 17:16:57 +0900
Message-Id: <1496305019-5493-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently me_huge_page() relies on dequeue_hwpoisoned_huge_page() to
keep the error hugepage away from the system, which is OK but not good
enough because the hugepage still has a refcount and unpoison doesn't
work on the error hugepage (PageHWPoison flags are cleared but pages
are still leaked.)  And there's "wasting health subpages" issue too.
This patch reworks on me_huge_page() to solve these issues.

For hugetlb file, recently we have truncating code so let's use it
in hugetlbfs specific ->error_remove_page().

For anonymous hugepage, it's helpful to dissolve the error page after
freeing it into free hugepage list. Migration entry and PageHWPoison
in the head page prevent the access to it.

TODO: dissolve_free_huge_page() can fail but we don't considered it
yet.  It's not critical (and at least no worse that now) because in
such case the error hugepage just stays in free hugepage list without
being dissolved.  By virtue of PageHWPoison in head page, it's never
allocated to processes.

Fixes: 23a003bfd23ea9ea0b7756b920e51f64b284b468 ("mm/madvise: pass return code of memory_failure() to userspace")
Link: http://lkml.kernel.org/r/20170417055948.GM31394@yexl-desktop
Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/hugetlbfs/inode.c | 11 ++++++
 mm/memory-failure.c  | 94 ++++++++++++++++++++++++++++++----------------------
 2 files changed, 66 insertions(+), 39 deletions(-)

diff --git v4.12-rc3/fs/hugetlbfs/inode.c v4.12-rc3_patched/fs/hugetlbfs/inode.c
index dde8613..33b33ec 100644
--- v4.12-rc3/fs/hugetlbfs/inode.c
+++ v4.12-rc3_patched/fs/hugetlbfs/inode.c
@@ -851,6 +851,16 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	return MIGRATEPAGE_SUCCESS;
 }
 
+static int hugetlbfs_error_remove_page(struct address_space *mapping,
+				struct page *page)
+{
+	struct inode *inode = mapping->host;
+
+	remove_huge_page(page);
+	hugetlb_fix_reserve_counts(inode);
+	return 0;
+}
+
 static int hugetlbfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(dentry->d_sb);
@@ -966,6 +976,7 @@ static const struct address_space_operations hugetlbfs_aops = {
 	.write_end	= hugetlbfs_write_end,
 	.set_page_dirty	= hugetlbfs_set_page_dirty,
 	.migratepage    = hugetlbfs_migrate_page,
+	.error_remove_page	= hugetlbfs_error_remove_page,
 };
 
 
diff --git v4.12-rc3/mm/memory-failure.c v4.12-rc3_patched/mm/memory-failure.c
index 31b761a..047867b 100644
--- v4.12-rc3/mm/memory-failure.c
+++ v4.12-rc3_patched/mm/memory-failure.c
@@ -554,6 +554,39 @@ static int delete_from_lru_cache(struct page *p)
 	return -EIO;
 }
 
+static int truncate_error_page(struct page *p, unsigned long pfn,
+				struct address_space *mapping)
+{
+	int ret = MF_FAILED;
+
+	if (mapping->a_ops->error_remove_page) {
+		int err = mapping->a_ops->error_remove_page(mapping, p);
+
+		if (err != 0) {
+			pr_info("Memory failure: %#lx: Failed to punch page: %d\n",
+				pfn, err);
+		} else if (page_has_private(p) &&
+			   !try_to_release_page(p, GFP_NOIO)) {
+			pr_info("Memory failure: %#lx: failed to release buffers\n",
+				pfn);
+		} else {
+			ret = MF_RECOVERED;
+		}
+	} else {
+		/*
+		 * If the file system doesn't support it just invalidate
+		 * This fails on dirty or anything with private pages
+		 */
+		if (invalidate_inode_page(p))
+			ret = MF_RECOVERED;
+		else
+			pr_info("Memory failure: %#lx: Failed to invalidate\n",
+				pfn);
+	}
+
+	return ret;
+}
+
 /*
  * Error hit kernel page.
  * Do nothing, try to be lucky and not touch this instead. For a few cases we
@@ -579,7 +612,6 @@ static int me_unknown(struct page *p, unsigned long pfn)
 static int me_pagecache_clean(struct page *p, unsigned long pfn)
 {
 	int err;
-	int ret = MF_FAILED;
 	struct address_space *mapping;
 
 	delete_from_lru_cache(p);
@@ -611,30 +643,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 	 *
 	 * Open: to take i_mutex or not for this? Right now we don't.
 	 */
-	if (mapping->a_ops->error_remove_page) {
-		err = mapping->a_ops->error_remove_page(mapping, p);
-		if (err != 0) {
-			pr_info("Memory failure: %#lx: Failed to punch page: %d\n",
-				pfn, err);
-		} else if (page_has_private(p) &&
-				!try_to_release_page(p, GFP_NOIO)) {
-			pr_info("Memory failure: %#lx: failed to release buffers\n",
-				pfn);
-		} else {
-			ret = MF_RECOVERED;
-		}
-	} else {
-		/*
-		 * If the file system doesn't support it just invalidate
-		 * This fails on dirty or anything with private pages
-		 */
-		if (invalidate_inode_page(p))
-			ret = MF_RECOVERED;
-		else
-			pr_info("Memory failure: %#lx: Failed to invalidate\n",
-				pfn);
-	}
-	return ret;
+	return truncate_error_page(p, pfn, mapping);
 }
 
 /*
@@ -740,24 +749,31 @@ static int me_huge_page(struct page *p, unsigned long pfn)
 {
 	int res = 0;
 	struct page *hpage = compound_head(p);
+	struct address_space *mapping;
 
 	if (!PageHuge(hpage))
 		return MF_DELAYED;
 
-	/*
-	 * We can safely recover from error on free or reserved (i.e.
-	 * not in-use) hugepage by dequeuing it from freelist.
-	 * To check whether a hugepage is in-use or not, we can't use
-	 * page->lru because it can be used in other hugepage operations,
-	 * such as __unmap_hugepage_range() and gather_surplus_pages().
-	 * So instead we use page_mapping() and PageAnon().
-	 */
-	if (!(page_mapping(hpage) || PageAnon(hpage))) {
-		res = dequeue_hwpoisoned_huge_page(hpage);
-		if (!res)
-			return MF_RECOVERED;
+	mapping = page_mapping(hpage);
+	if (mapping) {
+		res = truncate_error_page(hpage, pfn, mapping);
+	} else {
+		int dissolve_ret;
+
+		unlock_page(hpage);
+		/*
+		 * migration entry prevents later access on error anonymous
+		 * hugepage, so we can free and dissolve it into buddy to
+		 * save healthy subpages.
+		 */
+		if (PageAnon(hpage))
+			put_page(hpage);
+		dissolve_free_huge_page(p);
+		res = MF_RECOVERED;
+		lock_page(hpage);
 	}
-	return MF_DELAYED;
+
+	return res;
 }
 
 /*
@@ -856,7 +872,7 @@ static int page_action(struct page_state *ps, struct page *p,
 	count = page_count(p) - 1;
 	if (ps->action == me_swapcache_dirty && result == MF_DELAYED)
 		count--;
-	if (count != 0) {
+	if (count > 0) {
 		pr_err("Memory failure: %#lx: %s still referenced by %d users\n",
 		       pfn, action_page_types[ps->type], count);
 		result = MF_FAILED;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
