Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2671B6B01EF
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 22:10:01 -0400 (EDT)
Date: Fri, 23 Apr 2010 11:08:27 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] [BUGFIX] rmap: remove anon_vma check in
 page_address_in_vma()
Message-ID: <20100423020827.GB7383@spritzerA.linux.bs1.fc.nec.co.jp>
References: <20100422054241.GB10957@spritzerA.linux.bs1.fc.nec.co.jp>
 <4BD0688A.7050806@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <4BD0688A.7050806@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Currently page_address_in_vma() compares vma->anon_vma and page_anon_vma(page)
for parameter check, but in 2.6.34 a vma can have multiple anon_vmas with
anon_vma_chain, so current check does not work. (For anonymous page shared by
multiple processes, some verified (page,vma) pairs return -EFAULT wrongly.)

We can go to checking all anon_vmas in the "same_vma" chain, but it needs
to meet lock requirement. Instead, we can remove anon_vma check safely
because page_address_in_vma() assumes that page and vma are already checked
to belong to the identical process.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
---
 mm/rmap.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git v2.6.34-rc5:mm/rmap.c v2.6.34-rc5:mm/rmap.c
index 526704e..486fd0a 100644
--- v2.6.34-rc5:mm/rmap.c
+++ v2.6.34-rc5:mm/rmap.c
@@ -335,14 +335,13 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 
 /*
  * At what user virtual address is page expected in vma?
- * checking that the page matches the vma.
+ * Caller should check the page is actually part of the vma.
  */
 unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 {
-	if (PageAnon(page)) {
-		if (vma->anon_vma != page_anon_vma(page))
-			return -EFAULT;
-	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
+	if (PageAnon(page))
+		;
+	else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
 		if (!vma->vm_file ||
 		    vma->vm_file->f_mapping != page->mapping)
 			return -EFAULT;
-- 
1.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
