Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 621966B01C1
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:39:50 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:38:00 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 5/6] resurrect page_address_in_vma anon_vma check
Message-ID: <20100621163800.0ea44021@annuminas.surriel.com>
In-Reply-To: <20100621163146.4e4e30cb@annuminas.surriel.com>
References: <20100621163146.4e4e30cb@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>
Subject: resurrect page_address_in_vma anon_vma check

With root anon-vma it's trivial to keep doing the usual check as in
old-anon-vma code.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -362,9 +362,10 @@ vma_address(struct page *page, struct vm
  */
 unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 {
-	if (PageAnon(page))
-		;
-	else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
+	if (PageAnon(page)) {
+		if (vma->anon_vma->root != page_anon_vma(page)->root)
+			return -EFAULT;
+	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
 		if (!vma->vm_file ||
 		    vma->vm_file->f_mapping != page->mapping)
 			return -EFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
