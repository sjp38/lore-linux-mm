Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AE8D46B0071
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 01:44:38 -0500 (EST)
Date: Thu, 28 Jan 2010 01:43:57 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] rmap: move exclusively owned pages to own anon_vma in
 do_wp_page
Message-ID: <20100128014357.54428c8a@annuminas.surriel.com>
In-Reply-To: <20100128002000.2bf5e365@annuminas.surriel.com>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

When the parent process breaks the COW on a page, both the original
and the new page end up in that same anon_vma.  Generally this won't
be a problem, but for some workloads it could preserve the O(N) rmap
scanning complexity.

A simple fix is to ensure that, when a page gets reused in do_wp_page,
because we already are the exclusive owner, the page gets moved to our
own exclusive anon_vma.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/rmap.h |    1 +
 mm/memory.c          |    7 +++++++
 mm/rmap.c            |   24 ++++++++++++++++++++++++
 3 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index c0a6056..a0eb4e2 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -125,6 +125,7 @@ static inline void anon_vma_merge(struct vm_area_struct *vma,
 /*
  * rmap interfaces called when adding or removing pte of page
  */
+void page_move_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
diff --git a/mm/memory.c b/mm/memory.c
index 6a0f36e..bb7a4e6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2044,6 +2044,13 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			page_cache_release(old_page);
 		}
 		reuse = reuse_swap_page(old_page);
+		if (reuse)
+			/*
+			 * The page is all ours.  Move it to our anon_vma so
+			 * the rmap code will not search our parent or siblings.
+			 * Protected against the rmap code by the page lock.
+			 */
+			page_move_anon_rmap(old_page, vma, address);
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
diff --git a/mm/rmap.c b/mm/rmap.c
index 9e63424..92300df 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -717,6 +717,30 @@ int page_mkclean(struct page *page)
 EXPORT_SYMBOL_GPL(page_mkclean);
 
 /**
+ * page_move_anon_rmap - move a page to our anon_vma
+ * @page:	the page to move to our anon_vma
+ * @vma:	the vma the page belongs to
+ * @address:	the user virtual address mapped
+ *
+ * When a page belongs exclusively to one process after a COW event,
+ * that page can be moved into the anon_vma that belongs to just that
+ * process, so the rmap code will not search the parent or sibling
+ * processes.
+ */
+void page_move_anon_rmap(struct page *page,
+	struct vm_area_struct *vma, unsigned long address)
+{
+	struct anon_vma *anon_vma = vma->anon_vma;
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!anon_vma);
+	VM_BUG_ON(page->index != linear_page_index(vma, address));
+
+	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
+	page->mapping = (struct address_space *) anon_vma;
+}
+
+/**
  * __page_set_anon_rmap - setup new anonymous rmap
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
