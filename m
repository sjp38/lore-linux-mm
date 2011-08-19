Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC9B2900138
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:48:58 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p7J7mt5T017039
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:55 -0700
Received: from gwj15 (gwj15.prod.google.com [10.200.10.15])
	by wpaz1.hot.corp.google.com with ESMTP id p7J7movK000616
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:54 -0700
Received: by gwj15 with SMTP id 15so1944924gwj.39
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:50 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/9] mm: rcu read lock for getting reference on pages in migration_entry_wait()
Date: Fri, 19 Aug 2011 00:48:23 -0700
Message-Id: <1313740111-27446-2-git-send-email-walken@google.com>
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

migration_entry_wait() needs to take the rcu read lock so that page counts
can be guaranteed to be stable after one rcu grace period.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/migrate.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 666e4e6..6f3b5db 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -193,6 +193,7 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 	struct page *page;
 
 	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	rcu_read_lock();
 	pte = *ptep;
 	if (!is_swap_pte(pte))
 		goto out;
@@ -212,11 +213,13 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 	 */
 	if (!get_page_unless_zero(page))
 		goto out;
+	rcu_read_unlock();
 	pte_unmap_unlock(ptep, ptl);
 	wait_on_page_locked(page);
 	put_page(page);
 	return;
 out:
+	rcu_read_unlock();
 	pte_unmap_unlock(ptep, ptl);
 }
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
