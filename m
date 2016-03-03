Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 880AF6B0260
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:36 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id bj10so10187477pad.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:36 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id rs4si63813061pac.64.2016.03.02.23.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:35 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id 63so10164411pfe.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:35 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 10/11] mm: migrate: move_pages() supports thp migration
Date: Thu,  3 Mar 2016 16:41:57 +0900
Message-Id: <1456990918-30906-11-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch enables thp migration for move_pages(2).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/migrate.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/migrate.c
index 31bc724..5653d49 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/migrate.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/migrate.c
@@ -1240,7 +1240,17 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 	if (PageHuge(p))
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 					pm->node);
-	else
+	else if (thp_migration_supported() && PageTransHuge(p)) {
+		struct page *thp;
+
+		thp = alloc_pages_node(pm->node,
+			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
+			HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	} else
 		return __alloc_pages_node(pm->node,
 				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
 }
@@ -1267,6 +1277,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	for (pp = pm; pp->node != MAX_NUMNODES; pp++) {
 		struct vm_area_struct *vma;
 		struct page *page;
+		unsigned int follflags;
 
 		err = -EFAULT;
 		vma = find_vma(mm, pp->addr);
@@ -1274,8 +1285,10 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			goto set_status;
 
 		/* FOLL_DUMP to ignore special (like zero) pages */
-		page = follow_page(vma, pp->addr,
-				FOLL_GET | FOLL_SPLIT | FOLL_DUMP);
+		follflags = FOLL_GET | FOLL_SPLIT | FOLL_DUMP;
+		if (thp_migration_supported())
+			follflags &= ~FOLL_SPLIT;
+		page = follow_page(vma, pp->addr, follflags);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -1303,6 +1316,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			if (PageHead(page))
 				isolate_huge_page(page, &pagelist);
 			goto put_and_set;
+		} else if (PageTransCompound(page)) {
+			if (PageTail(page)) {
+				err = pp->node;
+				goto put_and_set;
+			}
 		}
 
 		err = isolate_lru_page(page);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
