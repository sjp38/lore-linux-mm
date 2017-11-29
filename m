Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2E206B0069
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:22:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i83so1134025wma.4
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:22:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36si1215850edf.188.2017.11.29.01.22.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 01:22:35 -0800 (PST)
Date: Wed, 29 Nov 2017 10:22:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
Message-ID: <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128141211.11117-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

What about this on top. I haven't tested this yet though.
---
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 1b6d7783c717..f5fcd4e355dc 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -119,6 +119,7 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
 						long freed);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
+void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason);
 void free_huge_page(struct page *page);
 void hugetlb_fix_reserve_counts(struct inode *inode);
 extern struct mutex *hugetlb_fault_mutex_table;
@@ -232,6 +233,7 @@ static inline bool isolate_huge_page(struct page *page, struct list_head *list)
 	return false;
 }
 #define putback_active_hugepage(p)	do {} while (0)
+#define move_hugetlb_state(old, new, reason)	do {} while (0)
 
 static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 037bf0f89463..30601c1c62f3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -34,6 +34,7 @@
 #include <linux/hugetlb_cgroup.h>
 #include <linux/node.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/page_owner.h>
 #include "internal.h"
 
 int hugetlb_max_hstate __read_mostly;
@@ -4830,3 +4831,34 @@ void putback_active_hugepage(struct page *page)
 	spin_unlock(&hugetlb_lock);
 	put_page(page);
 }
+
+void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason)
+{
+	struct hstate *h = page_hstate(oldpage);
+
+	hugetlb_cgroup_migrate(oldpage, newpage);
+	set_page_owner_migrate_reason(newpage, reason);
+
+	/*
+	 * transfer temporary state of the new huge page. This is
+	 * reverse to other transitions because the newpage is going to
+	 * be final while the old one will be freed so it takes over
+	 * the temporary status.
+	 *
+	 * Also note that we have to transfer the per-node surplus state
+	 * here as well otherwise the global surplus count will not match
+	 * the per-node's.
+	 */
+	if (PageHugeTemporary(newpage)) {
+		int old_nid = page_to_nid(oldpage);
+		int new_nid = page_to_nid(newpage);
+
+		SetPageHugeTemporary(oldpage);
+		ClearPageHugeTemporary(newpage);
+
+		if (h->surplus_huge_pages_node[old_nid]) {
+			h->surplus_huge_pages_node[old_nid]--;
+			h->surplus_huge_pages_node[new_nid]++;
+		}
+	}
+}
diff --git a/mm/migrate.c b/mm/migrate.c
index b3345f8174a9..1e5525a25691 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1323,22 +1323,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		put_anon_vma(anon_vma);
 
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		hugetlb_cgroup_migrate(hpage, new_hpage);
+		move_hugetlb_state(hpage, new_hpage, reason);
 		put_new_page = NULL;
-		set_page_owner_migrate_reason(new_hpage, reason);
-
-		/*
-		 * transfer temporary state of the new huge page. This is
-		 * reverse to other transitions because the newpage is going to
-		 * be final while the old one will be freed so it takes over
-		 * the temporary status.
-		 * No need for any locking here because destructor cannot race
-		 * with us.
-		 */
-		if (PageHugeTemporary(new_hpage)) {
-			SetPageHugeTemporary(hpage);
-			ClearPageHugeTemporary(new_hpage);
-		}
 	}
 
 	unlock_page(hpage);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
