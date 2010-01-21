Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9AC2F6B007B
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 01:51:28 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 19 of 30] ensure mapcount is taken on head pages
Message-Id: <8a02c04d705157e09086.1264054843@v2.random>
In-Reply-To: <patchbomb.1264054824@v2.random>
References: <patchbomb.1264054824@v2.random>
Date: Thu, 21 Jan 2010 07:20:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Unlike the page count, the page mapcount cannot be taken on PageTail compound
pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -105,6 +105,7 @@ void page_remove_rmap(struct page *);
 
 static inline void page_dup_rmap(struct page *page)
 {
+	VM_BUG_ON(PageTail(page));
 	atomic_inc(&page->_mapcount);
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -674,6 +674,7 @@ void page_add_anon_rmap(struct page *pag
 	struct vm_area_struct *vma, unsigned long address)
 {
 	int first = atomic_inc_and_test(&page->_mapcount);
+	VM_BUG_ON(PageTail(page));
 	if (first)
 		__inc_zone_page_state(page, NR_ANON_PAGES);
 	if (unlikely(PageKsm(page)))
@@ -701,6 +702,7 @@ void page_add_new_anon_rmap(struct page 
 	struct vm_area_struct *vma, unsigned long address)
 {
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+	VM_BUG_ON(PageTail(page));
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	__inc_zone_page_state(page, NR_ANON_PAGES);
@@ -733,6 +735,7 @@ void page_add_file_rmap(struct page *pag
  */
 void page_remove_rmap(struct page *page)
 {
+	VM_BUG_ON(PageTail(page));
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
 		return;
@@ -1281,6 +1284,7 @@ static int rmap_walk_file(struct page *p
 int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
+	VM_BUG_ON(PageTail(page));
 	VM_BUG_ON(!PageLocked(page));
 
 	if (unlikely(PageKsm(page)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
