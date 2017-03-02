Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 821F86B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:10:43 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 10so11024522pgb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:10:43 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n185si7655951pfn.268.2017.03.02.07.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:10:42 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] thp: fix MADV_DONTNEED vs. numa balancing race
Date: Thu,  2 Mar 2017 18:10:32 +0300
Message-Id: <20170302151034.27829-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

In case prot_numa, we are under down_read(mmap_sem). It's critical
to not clear pmd intermittently to avoid race with MADV_DONTNEED
which is also under down_read(mmap_sem):

	CPU0:				CPU1:
				change_huge_pmd(prot_numa=1)
				 pmdp_huge_get_and_clear_notify()
madvise_dontneed()
 zap_pmd_range()
  pmd_trans_huge(*pmd) == 0 (without ptl)
  // skip the pmd
				 set_pmd_at();
				 // pmd is re-established

The race makes MADV_DONTNEED miss the huge pmd and don't clear it
which may break userspace.

Found by code analysis, never saw triggered.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e7ce73b2b208..bb2b3646bd78 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1744,7 +1744,39 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	if (prot_numa && pmd_protnone(*pmd))
 		goto unlock;
 
-	entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
+	/*
+	 * In case prot_numa, we are under down_read(mmap_sem). It's critical
+	 * to not clear pmd intermittently to avoid race with MADV_DONTNEED
+	 * which is also under down_read(mmap_sem):
+	 *
+	 *	CPU0:				CPU1:
+	 *				change_huge_pmd(prot_numa=1)
+	 *				 pmdp_huge_get_and_clear_notify()
+	 * madvise_dontneed()
+	 *  zap_pmd_range()
+	 *   pmd_trans_huge(*pmd) == 0 (without ptl)
+	 *   // skip the pmd
+	 *				 set_pmd_at();
+	 *				 // pmd is re-established
+	 *
+	 * The race makes MADV_DONTNEED miss the huge pmd and don't clear it
+	 * which may break userspace.
+	 *
+	 * pmdp_invalidate() is required to make sure we don't miss
+	 * dirty/young flags set by hardware.
+	 */
+	entry = *pmd;
+	pmdp_invalidate(vma, addr, pmd);
+
+	/*
+	 * Recover dirty/young flags.  It relies on pmdp_invalidate to not
+	 * corrupt them.
+	 */
+	if (pmd_dirty(*pmd))
+		entry = pmd_mkdirty(entry);
+	if (pmd_young(*pmd))
+		entry = pmd_mkyoung(entry);
+
 	entry = pmd_modify(entry, newprot);
 	if (preserve_write)
 		entry = pmd_mk_savedwrite(entry);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
