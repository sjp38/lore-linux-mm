Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DBCBE900139
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:48:58 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p7J7mtK1030851
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:55 -0700
Received: from yib2 (yib2.prod.google.com [10.243.65.66])
	by wpaz17.hot.corp.google.com with ESMTP id p7J7mqUU021979
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:54 -0700
Received: by yib2 with SMTP id 2so2494376yib.14
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:52 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/9] mm: avoid calling get_page_unless_zero() when charging cgroups
Date: Fri, 19 Aug 2011 00:48:24 -0700
Message-Id: <1313740111-27446-3-git-send-email-walken@google.com>
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

In mem_cgroup_move_parent(), we can avoid the get_page_unless_zero()
call by taking a page reference under protection of the zone LRU lock
in mem_cgroup_force_empty_list().

In mc_handle_present_pte(), the page count is already known to be
nonzero as there is a PTE pointing to it and the page table lock is held.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/memcontrol.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e013b8e..f9439ef 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2649,7 +2649,7 @@ out:
 }
 
 /*
- * move charges to its parent.
+ * move charges to its parent. Caller must hold a reference on page.
  */
 
 static int mem_cgroup_move_parent(struct page *page,
@@ -2669,10 +2669,8 @@ static int mem_cgroup_move_parent(struct page *page,
 		return -EINVAL;
 
 	ret = -EBUSY;
-	if (!get_page_unless_zero(page))
-		goto out;
 	if (isolate_lru_page(page))
-		goto put;
+		goto out;
 
 	nr_pages = hpage_nr_pages(page);
 
@@ -2692,8 +2690,6 @@ static int mem_cgroup_move_parent(struct page *page,
 		compound_unlock_irqrestore(page, flags);
 put_back:
 	putback_lru_page(page);
-put:
-	put_page(page);
 out:
 	return ret;
 }
@@ -3732,11 +3728,12 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			continue;
 		}
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
-
 		page = lookup_cgroup_page(pc);
+		get_page(page);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 		ret = mem_cgroup_move_parent(page, pc, mem, GFP_KERNEL);
+		put_page(page);
 		if (ret == -ENOMEM)
 			break;
 
@@ -5133,9 +5130,12 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
 	} else if (!move_file())
 		/* we ignore mapcount for file pages */
 		return NULL;
-	if (!get_page_unless_zero(page))
-		return NULL;
 
+	/*
+	 * The page reference count is guaranteed to be nonzero since
+	 * ptent points to that page and the page table lock is held.
+	 */
+	get_page(page);
 	return page;
 }
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
