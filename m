Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA6876B0390
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:10:43 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u62so84672275pfk.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:10:43 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 1si6849203pgt.210.2017.03.02.07.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:10:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] thp: fix MADV_DONTNEED vs clear soft dirty race
Date: Thu,  2 Mar 2017 18:10:34 +0300
Message-Id: <20170302151034.27829-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Yet another instance of the same race.

Fix is identical to change_huge_pmd().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ee3efb229ef6..0ce5294abc2c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -899,7 +899,14 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmdp)
 {
-	pmd_t pmd = pmdp_huge_get_and_clear(vma->vm_mm, addr, pmdp);
+	pmd_t pmd = *pmdp;
+
+	/* See comment in change_huge_pmd() */
+	pmdp_invalidate(vma, addr, pmdp);
+	if (pmd_dirty(*pmdp))
+		pmd = pmd_mkdirty(pmd);
+	if (pmd_young(*pmdp))
+		pmd = pmd_mkyoung(pmd);
 
 	pmd = pmd_wrprotect(pmd);
 	pmd = pmd_clear_soft_dirty(pmd);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
