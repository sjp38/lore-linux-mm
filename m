Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B46486B01EF
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 06:29:07 -0400 (EDT)
Received: by wwc33 with SMTP id 33so3691652wwc.14
        for <linux-mm@kvack.org>; Wed, 21 Apr 2010 03:29:05 -0700 (PDT)
Date: Wed, 21 Apr 2010 12:27:59 +0200
From: Dan Carpenter <error27@gmail.com>
Subject: [patch] ksm: check for ERR_PTR from follow_page()
Message-ID: <20100421102759.GA29647@bicker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

The follow_page() function can potentially return -EFAULT so I added 
checks for this.

Also I silenced an uninitialized variable warning on my version of gcc 
(version 4.3.2).

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
I'm not very familiar with this code, so handle with care.

diff --git a/mm/ksm.c b/mm/ksm.c
index 8cdfc2a..956880f 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -365,7 +365,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 	do {
 		cond_resched();
 		page = follow_page(vma, addr, FOLL_GET);
-		if (!page)
+		if (IS_ERR_OR_NULL(page))
 			break;
 		if (PageKsm(page))
 			ret = handle_mm_fault(vma->vm_mm, vma, addr,
@@ -447,7 +447,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 		goto out;
 
 	page = follow_page(vma, addr, FOLL_GET);
-	if (!page)
+	if (IS_ERR_OR_NULL(page))
 		goto out;
 	if (PageAnon(page)) {
 		flush_anon_page(vma, page, addr);
@@ -1086,7 +1086,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 		cond_resched();
 		tree_rmap_item = rb_entry(*new, struct rmap_item, node);
 		tree_page = get_mergeable_page(tree_rmap_item);
-		if (!tree_page)
+		if (IS_ERR_OR_NULL(tree_page))
 			return NULL;
 
 		/*
@@ -1294,7 +1294,7 @@ next_mm:
 			if (ksm_test_exit(mm))
 				break;
 			*page = follow_page(vma, ksm_scan.address, FOLL_GET);
-			if (*page && PageAnon(*page)) {
+			if (!IS_ERR_OR_NULL(*page) && PageAnon(*page)) {
 				flush_anon_page(vma, *page, ksm_scan.address);
 				flush_dcache_page(*page);
 				rmap_item = get_next_rmap_item(slot,
@@ -1308,7 +1308,7 @@ next_mm:
 				up_read(&mm->mmap_sem);
 				return rmap_item;
 			}
-			if (*page)
+			if (!IS_ERR_OR_NULL(*page))
 				put_page(*page);
 			ksm_scan.address += PAGE_SIZE;
 			cond_resched();
@@ -1367,7 +1367,7 @@ next_mm:
 static void ksm_do_scan(unsigned int scan_npages)
 {
 	struct rmap_item *rmap_item;
-	struct page *page;
+	struct page *uninitialized_var(page);
 
 	while (scan_npages--) {
 		cond_resched();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
