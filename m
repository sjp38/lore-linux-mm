Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C89696B003B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 14:36:36 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so139037wiv.1
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:36:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bq14si5767398wib.85.2014.07.11.11.36.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 11:36:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v5 06/13] pagemap: use walk->vma instead of calling find_vma()
Date: Fri, 11 Jul 2014 14:35:42 -0400
Message-Id: <1405103749-23506-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1405103749-23506-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1405103749-23506-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Page table walker has the information of the current vma in mm_walk, so
we don't have to call find_vma() in each pagemap_hugetlb_range() call.

NULL-vma check is omitted because we assume that we never run hugetlb_entry()
callback on the address without vma. And even if it were broken, null pointer
dereference would be detected, so we can get enough information for debugging.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git mmotm-2014-07-09-17-08.orig/fs/proc/task_mmu.c mmotm-2014-07-09-17-08/fs/proc/task_mmu.c
index 4baf34230191..e4c6cdb9647b 100644
--- mmotm-2014-07-09-17-08.orig/fs/proc/task_mmu.c
+++ mmotm-2014-07-09-17-08/fs/proc/task_mmu.c
@@ -1073,15 +1073,12 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma = walk->vma;
 	int err = 0;
 	int flags2;
 	pagemap_entry_t pme;
 
-	vma = find_vma(walk->mm, addr);
-	WARN_ON_ONCE(!vma);
-
-	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
+	if (vma->vm_flags & VM_SOFTDIRTY)
 		flags2 = __PM_SOFT_DIRTY;
 	else
 		flags2 = 0;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
