Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3326B03A3
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:36:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b13so73904691pgn.4
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:36:54 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v1si3355734plb.188.2017.06.13.03.28.36
        for <linux-mm@kvack.org>;
        Tue, 13 Jun 2017 03:28:36 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 1/3] mm: numa: avoid waiting on freed migrated pages
Date: Tue, 13 Jun 2017 11:28:40 +0100
Message-Id: <1497349722-6731-2-git-send-email-will.deacon@arm.com>
In-Reply-To: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
References: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com, vbabka@suse.cz, Will Deacon <will.deacon@arm.com>

From: Mark Rutland <mark.rutland@arm.com>

In do_huge_pmd_numa_page(), we attempt to handle a migrating thp pmd by
waiting until the pmd is unlocked before we return and retry. However,
we can race with migrate_misplaced_transhuge_page():

// do_huge_pmd_numa_page                // migrate_misplaced_transhuge_page()
// Holds 0 refs on page                 // Holds 2 refs on page

vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
/* ... */
if (pmd_trans_migrating(*vmf->pmd)) {
        page = pmd_page(*vmf->pmd);
        spin_unlock(vmf->ptl);
                                        ptl = pmd_lock(mm, pmd);
                                        if (page_count(page) != 2)) {
                                                /* roll back */
                                        }
                                        /* ... */
                                        mlock_migrate_page(new_page, page);
                                        /* ... */
                                        spin_unlock(ptl);
                                        put_page(page);
                                        put_page(page); // page freed here
        wait_on_page_locked(page);
        goto out;
}

This can result in the freed page having its waiters flag set
unexpectedly, which trips the PAGE_FLAGS_CHECK_AT_PREP checks in the
page alloc/free functions. This has been observed on arm64 KVM guests.

We can avoid this by having do_huge_pmd_numa_page() take a reference on
the page before dropping the pmd lock, mirroring what we do in
__migration_entry_wait().

When we hit the race, migrate_misplaced_transhuge_page() will see the
reference and abort the migration, as it may do today in other cases.

Acked-by: Steve Capper <steve.capper@arm.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Fixes: b8916634b77bffb2 ("mm: Prevent parallel splits during THP migration")
Signed-off-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 mm/huge_memory.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a84909cf20d3..88c6167f194d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1426,8 +1426,11 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	 */
 	if (unlikely(pmd_trans_migrating(*vmf->pmd))) {
 		page = pmd_page(*vmf->pmd);
+		if (!get_page_unless_zero(page))
+			goto out_unlock;
 		spin_unlock(vmf->ptl);
 		wait_on_page_locked(page);
+		put_page(page);
 		goto out;
 	}
 
@@ -1459,9 +1462,12 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 
 	/* Migration could have started since the pmd_trans_migrating check */
 	if (!page_locked) {
+		page_nid = -1;
+		if (!get_page_unless_zero(page))
+			goto out_unlock;
 		spin_unlock(vmf->ptl);
 		wait_on_page_locked(page);
-		page_nid = -1;
+		put_page(page);
 		goto out;
 	}
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
