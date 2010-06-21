Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1D5A86B01B6
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:39:44 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:39:32 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 6/6] add anon_vma bug checks
Message-ID: <20100621163932.75d26175@annuminas.surriel.com>
In-Reply-To: <20100621163146.4e4e30cb@annuminas.surriel.com>
References: <20100621163146.4e4e30cb@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>
Subject: add anon_vma bug checks

Verify the refcounting doesn't go wrong, and resurrect the check in
__page_check_anon_rmap as in old anon-vma code.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -815,6 +815,7 @@ static void __page_check_anon_rmap(struc
 	 * are initially only visible via the pagetables, and the pte is locked
 	 * over the call to page_add_new_anon_rmap.
 	 */
+	BUG_ON(page_anon_vma(page)->root != vma->anon_vma->root);
 	BUG_ON(page->index != linear_page_index(vma, address));
 #endif
 }
@@ -1405,6 +1406,7 @@ int try_to_munlock(struct page *page)
  */
 void drop_anon_vma(struct anon_vma *anon_vma)
 {
+	BUG_ON(atomic_read(&anon_vma->external_refcount) <= 0);
 	if (atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->root->lock)) {
 		struct anon_vma *root = anon_vma->root;
 		int empty = list_empty(&anon_vma->head);
@@ -1416,6 +1418,7 @@ void drop_anon_vma(struct anon_vma *anon
 		 * the refcount on the root and check if we need to free it.
 		 */
 		if (empty && anon_vma != root) {
+			BUG_ON(atomic_read(&root->external_refcount) <= 0);
 			last_root_user = atomic_dec_and_test(&root->external_refcount);
 			root_empty = list_empty(&root->head);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
