Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDF66B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:13:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b192so933997pga.14
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 01:13:36 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q190si1126829pga.462.2017.10.17.01.13.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 01:13:34 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, swap: Fix race between swap count continuation operations
Date: Tue, 17 Oct 2017 16:13:20 +0800
Message-Id: <20171017081320.28133-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Tim Chen <tim.c.chen@intel.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, Minchan Kim <minchan@kernel.org>

From: Huang Ying <ying.huang@intel.com>

One page may store a set of entries of the
sis->swap_map (swap_info_struct->swap_map) in multiple swap clusters.
If some of the entries has sis->swap_map[offset] > SWAP_MAP_MAX,
multiple pages will be used to store the set of entries of the
sis->swap_map.  And the pages are linked with page->lru.  This is
called swap count continuation.  To access the pages which store the
set of entries of the sis->swap_map simultaneously, previously,
sis->lock is used.  But to improve the scalability of
__swap_duplicate(), swap cluster lock may be used in
swap_count_continued() now.  This may race with
add_swap_count_continuation() which operates on a nearby swap cluster,
in which the sis->swap_map entries are stored in the same page.

To fix the race, a new spin lock called cont_lock is added to struct
swap_info_struct to protect the swap count continuation page list.
This is a lock at the swap device level, so the scalability isn't very
well.  But it is still much better than the original sis->lock,
because it is only acquired/released when swap count continuation is
used.  Which is considered rare in practice.  If it turns out that the
scalability becomes an issue for some workloads, we can split the lock
into some more fine grained locks.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |  4 ++++
 mm/swapfile.c        | 23 +++++++++++++++++------
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1f5c52313890..9e8e11be7e0b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -266,6 +266,10 @@ struct swap_info_struct {
 					 * both locks need hold, hold swap_lock
 					 * first.
 					 */
+	spinlock_t cont_lock;		/*
+					 * protect swap count continuation page
+					 * list.
+					 */
 	struct work_struct discard_work; /* discard worker */
 	struct swap_cluster_list discard_clusters; /* discard clusters list */
 };
diff --git a/mm/swapfile.c b/mm/swapfile.c
index d67715ffc194..3074b02eaa09 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2876,6 +2876,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 	p->flags = SWP_USED;
 	spin_unlock(&swap_lock);
 	spin_lock_init(&p->lock);
+	spin_lock_init(&p->cont_lock);
 
 	return p;
 }
@@ -3558,6 +3559,7 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	head = vmalloc_to_page(si->swap_map + offset);
 	offset &= ~PAGE_MASK;
 
+	spin_lock(&si->cont_lock);
 	/*
 	 * Page allocation does not initialize the page's lru field,
 	 * but it does always reset its private field.
@@ -3577,7 +3579,7 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 		 * a continuation page, free our allocation and use this one.
 		 */
 		if (!(count & COUNT_CONTINUED))
-			goto out;
+			goto out_unlock_cont;
 
 		map = kmap_atomic(list_page) + offset;
 		count = *map;
@@ -3588,11 +3590,13 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 		 * free our allocation and use this one.
 		 */
 		if ((count & ~COUNT_CONTINUED) != SWAP_CONT_MAX)
-			goto out;
+			goto out_unlock_cont;
 	}
 
 	list_add_tail(&page->lru, &head->lru);
 	page = NULL;			/* now it's attached, don't free it */
+out_unlock_cont:
+	spin_unlock(&si->cont_lock);
 out:
 	unlock_cluster(ci);
 	spin_unlock(&si->lock);
@@ -3617,6 +3621,7 @@ static bool swap_count_continued(struct swap_info_struct *si,
 	struct page *head;
 	struct page *page;
 	unsigned char *map;
+	bool ret;
 
 	head = vmalloc_to_page(si->swap_map + offset);
 	if (page_private(head) != SWP_CONTINUED) {
@@ -3624,6 +3629,7 @@ static bool swap_count_continued(struct swap_info_struct *si,
 		return false;		/* need to add count continuation */
 	}
 
+	spin_lock(&si->cont_lock);
 	offset &= ~PAGE_MASK;
 	page = list_entry(head->lru.next, struct page, lru);
 	map = kmap_atomic(page) + offset;
@@ -3644,8 +3650,10 @@ static bool swap_count_continued(struct swap_info_struct *si,
 		if (*map == SWAP_CONT_MAX) {
 			kunmap_atomic(map);
 			page = list_entry(page->lru.next, struct page, lru);
-			if (page == head)
-				return false;	/* add count continuation */
+			if (page == head) {
+				ret = false;	/* add count continuation */
+				goto out;
+			}
 			map = kmap_atomic(page) + offset;
 init_map:		*map = 0;		/* we didn't zero the page */
 		}
@@ -3658,7 +3666,7 @@ init_map:		*map = 0;		/* we didn't zero the page */
 			kunmap_atomic(map);
 			page = list_entry(page->lru.prev, struct page, lru);
 		}
-		return true;			/* incremented */
+		ret = true;			/* incremented */
 
 	} else {				/* decrementing */
 		/*
@@ -3684,8 +3692,11 @@ init_map:		*map = 0;		/* we didn't zero the page */
 			kunmap_atomic(map);
 			page = list_entry(page->lru.prev, struct page, lru);
 		}
-		return count == COUNT_CONTINUED;
+		ret = count == COUNT_CONTINUED;
 	}
+out:
+	spin_unlock(&si->cont_lock);
+	return ret;
 }
 
 /*
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
