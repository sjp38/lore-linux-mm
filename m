Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F34326B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:40:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so58226026pfy.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:40:16 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id g2si5704278pgp.201.2016.11.07.15.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:24 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id p66so1255524pga.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:23 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 06/12] mm: thp: enable thp migration in generic path
Date: Tue,  8 Nov 2016 08:31:51 +0900
Message-Id: <1478561517-4317-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch makes it possible to support thp migration gradually. If you fail
to allocate a destination page as a thp, you just split the source thp as we
do now, and then enter the normal page migration. If you succeed to allocate
destination thp, you enter thp migration. Subsequent patches actually enable
thp migration for each caller of page migration by allowing its get_new_page()
callback to allocate thps.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 2 +-
 mm/rmap.c    | 7 +++++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/migrate.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/migrate.c
index 54f2eb6..97ab8d9 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/migrate.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/migrate.c
@@ -1142,7 +1142,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		goto out;
 	}
 
-	if (unlikely(PageTransHuge(page))) {
+	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
 		lock_page(page);
 		rc = split_huge_page(page);
 		unlock_page(page);
diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/rmap.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/rmap.c
index a4be307..a0b665c 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/rmap.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/rmap.c
@@ -1443,6 +1443,13 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	struct rmap_private *rp = arg;
 	enum ttu_flags flags = rp->flags;
 
+	if (flags & TTU_MIGRATION) {
+		if (!PageHuge(page) && PageTransCompound(page)) {
+			set_pmd_migration_entry(page, vma, address);
+			goto out;
+		}
+	}
+
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		goto out;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
