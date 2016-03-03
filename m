Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF406B0257
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:16 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 4so10238830pfd.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:16 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id hx6si63789234pac.95.2016.03.02.23.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:16 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id 63so10159417pfe.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:15 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 04/11] mm: thp: enable thp migration in generic path
Date: Thu,  3 Mar 2016 16:41:51 +0900
Message-Id: <1456990918-30906-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch makes it possible to support thp migration gradually. If you fail
to allocate a destination page as a thp, you just split the source thp as we
do now, and then enter the normal page migration. If you succeed to allocate
destination thp, you enter thp migration. Subsequent patches actually enable
thp migration for each caller of page migration by allowing its get_new_page()
callback to allocate thps.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 2 +-
 mm/rmap.c    | 7 +++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/migrate.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/migrate.c
index 14164f6..bd8bfa4 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/migrate.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/migrate.c
@@ -969,7 +969,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		goto out;
 	}
 
-	if (unlikely(PageTransHuge(page))) {
+	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
 		lock_page(page);
 		rc = split_huge_page(page);
 		unlock_page(page);
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/rmap.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/rmap.c
index 02f0bfc..49198b8 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/rmap.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/rmap.c
@@ -1427,6 +1427,11 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
@@ -1610,8 +1615,6 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 		.anon_lock = page_lock_anon_vma_read,
 	};
 
-	VM_BUG_ON_PAGE(!PageHuge(page) && PageTransHuge(page), page);
-
 	/*
 	 * During exec, a temporary VMA is setup and later moved.
 	 * The VMA is moved under the anon_vma lock but not the
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
