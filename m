Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCF46B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 22:56:33 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so10201538pab.7
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 19:56:33 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id cu3si26882235pbc.108.2014.11.30.19.56.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 30 Nov 2014 19:56:32 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id et14so10300540pad.3
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 19:56:31 -0800 (PST)
Date: Sun, 30 Nov 2014 19:56:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix swapoff hang after page migration and fork
Message-ID: <alpine.LSU.2.11.1411301950450.1043@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kelley Nielsen <kelleynnn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I've been seeing swapoff hangs in recent testing: it's cycling around
trying unsuccessfully to find an mm for some remaining pages of swap.

I have been exercising swap and page migration more heavily recently,
and now notice a long-standing error in copy_one_pte(): it's trying
to add dst_mm to swapoff's mmlist when it finds a swap entry, but is
doing so even when it's a migration entry or an hwpoison entry.

Which wouldn't matter much, except it adds dst_mm next to src_mm,
assuming src_mm is already on the mmlist: which may not be so.  Then
if pages are later swapped out from dst_mm, swapoff won't be able to
find where to replace them.

There's already a !non_swap_entry() test for stats: move that up
before the swap_duplicate() and the addition to mmlist.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org # 2.6.18+
---

 mm/memory.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

--- 3.18-rc7/mm/memory.c	2014-11-02 20:21:39.929011061 -0800
+++ linux/mm/memory.c	2014-11-27 19:38:52.314801502 -0800
@@ -815,20 +815,20 @@ copy_one_pte(struct mm_struct *dst_mm, s
 		if (!pte_file(pte)) {
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
-			if (swap_duplicate(entry) < 0)
-				return entry.val;
+			if (likely(!non_swap_entry(entry))) {
+				if (swap_duplicate(entry) < 0)
+					return entry.val;
 
-			/* make sure dst_mm is on swapoff's mmlist. */
-			if (unlikely(list_empty(&dst_mm->mmlist))) {
-				spin_lock(&mmlist_lock);
-				if (list_empty(&dst_mm->mmlist))
-					list_add(&dst_mm->mmlist,
-						 &src_mm->mmlist);
-				spin_unlock(&mmlist_lock);
-			}
-			if (likely(!non_swap_entry(entry)))
+				/* make sure dst_mm is on swapoff's mmlist. */
+				if (unlikely(list_empty(&dst_mm->mmlist))) {
+					spin_lock(&mmlist_lock);
+					if (list_empty(&dst_mm->mmlist))
+						list_add(&dst_mm->mmlist,
+							 &src_mm->mmlist);
+					spin_unlock(&mmlist_lock);
+				}
 				rss[MM_SWAPENTS]++;
-			else if (is_migration_entry(entry)) {
+			} else if (is_migration_entry(entry)) {
 				page = migration_entry_to_page(entry);
 
 				if (PageAnon(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
