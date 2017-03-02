Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A718F6B038E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:10:43 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so94022853pgc.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:10:43 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b14si7649941pge.221.2017.03.02.07.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:10:42 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/4] thp: reduce indentation level in change_huge_pmd()
Date: Thu,  2 Mar 2017 18:10:31 +0300
Message-Id: <20170302151034.27829-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Restructure code in preparation for a fix.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 52 ++++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 71e3dede95b4..e7ce73b2b208 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1722,37 +1722,37 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
-	int ret = 0;
+	pmd_t entry;
+	bool preserve_write;
+	int ret;
 
 	ptl = __pmd_trans_huge_lock(pmd, vma);
-	if (ptl) {
-		pmd_t entry;
-		bool preserve_write = prot_numa && pmd_write(*pmd);
-		ret = 1;
+	if (!ptl)
+		return 0;
 
-		/*
-		 * Avoid trapping faults against the zero page. The read-only
-		 * data is likely to be read-cached on the local CPU and
-		 * local/remote hits to the zero page are not interesting.
-		 */
-		if (prot_numa && is_huge_zero_pmd(*pmd)) {
-			spin_unlock(ptl);
-			return ret;
-		}
+	preserve_write = prot_numa && pmd_write(*pmd);
+	ret = 1;
 
-		if (!prot_numa || !pmd_protnone(*pmd)) {
-			entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
-			entry = pmd_modify(entry, newprot);
-			if (preserve_write)
-				entry = pmd_mk_savedwrite(entry);
-			ret = HPAGE_PMD_NR;
-			set_pmd_at(mm, addr, pmd, entry);
-			BUG_ON(vma_is_anonymous(vma) && !preserve_write &&
-					pmd_write(entry));
-		}
-		spin_unlock(ptl);
-	}
+	/*
+	 * Avoid trapping faults against the zero page. The read-only
+	 * data is likely to be read-cached on the local CPU and
+	 * local/remote hits to the zero page are not interesting.
+	 */
+	if (prot_numa && is_huge_zero_pmd(*pmd))
+		goto unlock;
 
+	if (prot_numa && pmd_protnone(*pmd))
+		goto unlock;
+
+	entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
+	entry = pmd_modify(entry, newprot);
+	if (preserve_write)
+		entry = pmd_mk_savedwrite(entry);
+	ret = HPAGE_PMD_NR;
+	set_pmd_at(mm, addr, pmd, entry);
+	BUG_ON(vma_is_anonymous(vma) && !preserve_write && pmd_write(entry));
+unlock:
+	spin_unlock(ptl);
 	return ret;
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
