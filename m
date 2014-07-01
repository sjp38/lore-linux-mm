Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD9926B0068
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 13:07:58 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so8164976wiw.11
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 10:07:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fv8si16005044wib.73.2014.07.01.10.07.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 10:07:57 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v4 10/13] arch/powerpc/mm/subpage-prot.c: use walk->vma and walk_page_vma()
Date: Tue,  1 Jul 2014 13:07:28 -0400
Message-Id: <1404234451-21695-11-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

We don't have to use mm_walk->private to pass vma to the callback function
because of mm_walk->vma. And walk_page_vma() is useful if we walk over a
single vma.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/powerpc/mm/subpage-prot.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git v3.16-rc3.orig/arch/powerpc/mm/subpage-prot.c v3.16-rc3/arch/powerpc/mm/subpage-prot.c
index 6c0b1f5f8d2c..fa9fb5b4c66c 100644
--- v3.16-rc3.orig/arch/powerpc/mm/subpage-prot.c
+++ v3.16-rc3/arch/powerpc/mm/subpage-prot.c
@@ -134,7 +134,7 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, struct mm_walk *walk)
 {
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	split_huge_page_pmd(vma, addr, pmd);
 	return 0;
 }
@@ -163,9 +163,7 @@ static void subpage_mark_vma_nohuge(struct mm_struct *mm, unsigned long addr,
 		if (vma->vm_start >= (addr + len))
 			break;
 		vma->vm_flags |= VM_NOHUGEPAGE;
-		subpage_proto_walk.private = vma;
-		walk_page_range(vma->vm_start, vma->vm_end,
-				&subpage_proto_walk);
+		walk_page_vma(vma, &subpage_proto_walk);
 		vma = vma->vm_next;
 	}
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
