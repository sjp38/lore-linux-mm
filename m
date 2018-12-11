Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE7A78E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:13:04 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w1so13548848qta.12
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 21:13:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si1425120qte.125.2018.12.10.21.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 21:13:04 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH v2] mm: thp: fix flags for pmd migration when split
Date: Tue, 11 Dec 2018 13:12:54 +0800
Message-Id: <20181211051254.16633-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterx@redhat.com, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org

When splitting a huge migrating PMD, we'll transfer all the existing
PMD bits and apply them again onto the small PTEs.  However we are
fetching the bits unconditionally via pmd_soft_dirty(), pmd_write()
or pmd_yound() while actually they don't make sense at all when it's
a migration entry.  Fix them up by make it conditional.

Note that if my understanding is correct about the problem then if
without the patch there is chance to lose some of the dirty bits in
the migrating pmd pages (on x86_64 we're fetching bit 11 which is part
of swap offset instead of bit 2) and it could potentially corrupt the
memory of an userspace program which depends on the dirty bit.

CC: Andrea Arcangeli <aarcange@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Michal Hocko <mhocko@suse.com>
CC: Dave Jiang <dave.jiang@intel.com>
CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
CC: Souptick Joarder <jrdr.linux@gmail.com>
CC: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
Signed-off-by: Peter Xu <peterx@redhat.com>
---
v2:
- fix it up for young/write/dirty bits too [Konstantin]
---
 mm/huge_memory.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f2d19e4fe854..b00941b3d342 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2157,11 +2157,16 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		page = pmd_page(old_pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
-	if (pmd_dirty(old_pmd))
-		SetPageDirty(page);
-	write = pmd_write(old_pmd);
-	young = pmd_young(old_pmd);
-	soft_dirty = pmd_soft_dirty(old_pmd);
+	if (unlikely(pmd_migration)) {
+		soft_dirty = pmd_swp_soft_dirty(old_pmd);
+		young = write = false;
+	} else {
+		if (pmd_dirty(old_pmd))
+			SetPageDirty(page);
+		write = pmd_write(old_pmd);
+		young = pmd_young(old_pmd);
+		soft_dirty = pmd_soft_dirty(old_pmd);
+	}
 
 	/*
 	 * Withdraw the table only after we mark the pmd entry invalid.
-- 
2.17.1
