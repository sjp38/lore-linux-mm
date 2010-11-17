Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B71F98D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 07:24:59 -0500 (EST)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id oAHCOvM7029262
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:57 -0800
Received: from gxk2 (gxk2.prod.google.com [10.202.11.2])
	by kpbe15.cbf.corp.google.com with ESMTP id oAHCOI5K007287
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:45 -0800
Received: by gxk2 with SMTP id 2so1066576gxk.6
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:18 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/3] do_wp_page: remove the 'reuse' flag
Date: Wed, 17 Nov 2010 04:23:56 -0800
Message-Id: <1289996638-21439-2-git-send-email-walken@google.com>
In-Reply-To: <1289996638-21439-1-git-send-email-walken@google.com>
References: <1289996638-21439-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

Reorganize the code to remove the 'reuse' flag. No behavior changes.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/memory.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 0e18b4d..810a75f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2110,7 +2110,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *old_page, *new_page;
 	pte_t entry;
-	int reuse = 0, ret = 0;
+	int ret = 0;
 	int page_mkwrite = 0;
 	struct page *dirty_page = NULL;
 
@@ -2147,14 +2147,16 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			}
 			page_cache_release(old_page);
 		}
-		reuse = reuse_swap_page(old_page);
-		if (reuse)
+		if (reuse_swap_page(old_page)) {
 			/*
 			 * The page is all ours.  Move it to our anon_vma so
 			 * the rmap code will not search our parent or siblings.
 			 * Protected against the rmap code by the page lock.
 			 */
 			page_move_anon_rmap(old_page, vma, address);
+			unlock_page(old_page);
+			goto reuse;
+		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
@@ -2218,10 +2220,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		dirty_page = old_page;
 		get_page(dirty_page);
-		reuse = 1;
-	}
 
-	if (reuse) {
 reuse:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = pte_mkyoung(orig_pte);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
