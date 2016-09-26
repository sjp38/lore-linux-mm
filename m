Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 366096B02A7
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:24:09 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 16so306759885qtn.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:24:09 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id u65si14813560qkb.94.2016.09.26.08.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:24:08 -0700 (PDT)
From: zi.yan@sent.com
Subject: [PATCH v1 04/12] mm: thp: enable thp migration in generic path
Date: Mon, 26 Sep 2016 11:22:26 -0400
Message-Id: <20160926152234.14809-5-zi.yan@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch makes it possible to support thp migration gradually. If you fail
to allocate a destination page as a thp, you just split the source thp as we
do now, and then enter the normal page migration. If you succeed to allocate
destination thp, you enter thp migration. Subsequent patches actually enable
thp migration for each caller of page migration by allowing its get_new_page()
callback to allocate thps.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 2 +-
 mm/rmap.c    | 5 +++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 95613e7..dfca530 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1123,7 +1123,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		goto out;
 	}
 
-	if (unlikely(PageTransHuge(page))) {
+	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
 		lock_page(page);
 		rc = split_huge_page(page);
 		unlock_page(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index 1ef3640..d53fff5 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1443,6 +1443,11 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	struct rmap_private *rp = arg;
 	enum ttu_flags flags = rp->flags;
 
+	if (!PageHuge(page) && PageTransHuge(page)) {
+		VM_BUG_ON_PAGE(!(flags & TTU_MIGRATION), page);
+		return set_pmd_migration_entry(page, mm, address);
+	}
+
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		goto out;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
