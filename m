Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 233EA6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 20:45:44 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 03/11] mm: shmem: do not try to uncharge known swapcache pages
Date: Thu,  5 Jul 2012 02:44:55 +0200
Message-Id: <1341449103-1986-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Once charged, swapcache pages can only be uncharged after they are
removed from swapcache again.

Do not try to uncharge pages that are known to be in the swapcache, to
allow future patches to remove checks for that in the uncharge code.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/shmem.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index ee1c5a2..d12b705 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -302,8 +302,6 @@ static int shmem_add_to_page_cache(struct page *page,
 		if (!expected)
 			radix_tree_preload_end();
 	}
-	if (error)
-		mem_cgroup_uncharge_cache_page(page);
 	return error;
 }
 
@@ -1184,11 +1182,14 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		__set_page_locked(page);
 		error = mem_cgroup_cache_charge(page, current->mm,
 						gfp & GFP_RECLAIM_MASK);
-		if (!error)
-			error = shmem_add_to_page_cache(page, mapping, index,
-						gfp, NULL);
 		if (error)
 			goto decused;
+		error = shmem_add_to_page_cache(page, mapping, index,
+						gfp, NULL);
+		if (error) {
+			mem_cgroup_uncharge_cache_page(page);
+			goto decused;
+		}
 		lru_cache_add_anon(page);
 
 		spin_lock(&info->lock);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
