Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D880B6B00E8
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 02:10:33 -0500 (EST)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p0B7AUJ7009646
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:10:30 -0800
Received: from iwb12 (iwb12.prod.google.com [10.241.65.76])
	by hpaq6.eem.corp.google.com with ESMTP id p0B7ASRH029183
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:10:29 -0800
Received: by iwb12 with SMTP id 12so3707449iwb.10
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:10:28 -0800 (PST)
Date: Mon, 10 Jan 2011 23:10:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix hugepage migration in the same way
In-Reply-To: <alpine.LSU.2.00.1101102259160.24988@sister.anvils>
Message-ID: <alpine.LSU.2.00.1101102308310.24988@sister.anvils>
References: <alpine.LSU.2.00.1101102259160.24988@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2.6.37 added an unmap_and_move_huge_page() for memory failure recovery,
but its anon_vma handling was still based around the 2.6.35 conventions.
Update it to use page_lock_anon_vma, get_anon_vma, page_unlock_anon_vma,
drop_anon_vma in the same way as we're now changing unmap_and_move().

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org [2.6.37]
---
I don't particularly like to propose this for stable when I've not seen
its problems in practice nor tested the solution: but it's clearly
out of synch at present.

 mm/migrate.c |   23 ++++++-----------------
 1 file changed, 6 insertions(+), 17 deletions(-)

--- 2.6.37/mm/migrate.c	2011-01-10 17:23:39.000000000 -0800
+++ linux/mm/migrate.c	2011-01-10 22:01:16.000000000 -0800
@@ -806,7 +806,6 @@ static int unmap_and_move_huge_page(new_
 	int rc = 0;
 	int *result = NULL;
 	struct page *new_hpage = get_new_page(hpage, private, &result);
-	int rcu_locked = 0;
 	struct anon_vma *anon_vma = NULL;
 
 	if (!new_hpage)
@@ -821,12 +820,10 @@ static int unmap_and_move_huge_page(new_
 	}
 
 	if (PageAnon(hpage)) {
-		rcu_read_lock();
-		rcu_locked = 1;
-
-		if (page_mapped(hpage)) {
-			anon_vma = page_anon_vma(hpage);
-			atomic_inc(&anon_vma->external_refcount);
+		anon_vma = page_lock_anon_vma(hpage);
+		if (anon_vma) {
+			get_anon_vma(anon_vma);
+			page_unlock_anon_vma(anon_vma);
 		}
 	}
 
@@ -838,16 +835,8 @@ static int unmap_and_move_huge_page(new_
 	if (rc)
 		remove_migration_ptes(hpage, hpage);
 
-	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount,
-					    &anon_vma->lock)) {
-		int empty = list_empty(&anon_vma->head);
-		spin_unlock(&anon_vma->lock);
-		if (empty)
-			anon_vma_free(anon_vma);
-	}
-
-	if (rcu_locked)
-		rcu_read_unlock();
+	if (anon_vma)
+		drop_anon_vma(anon_vma);
 out:
 	unlock_page(hpage);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
