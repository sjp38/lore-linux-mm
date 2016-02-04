Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 775EC4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 15:08:43 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id r129so228628743wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 12:08:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id vt3si19673247wjc.145.2016.02.04.12.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 12:08:42 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/2] mm: migrate: consolidate mem_cgroup_migrate() calls
Date: Thu,  4 Feb 2016 15:07:46 -0500
Message-Id: <1454616467-8994-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Mateusz Guzik <mguzik@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Rather than scattering mem_cgroup_migrate() calls all over the place,
have a single call from a safe place where every migration operation
eventually ends up in - migrate_page_copy().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Suggested-by: Hugh Dickins <hughd@google.com>
---
 mm/migrate.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 17db63b2dd36..90cbf7c65cac 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -331,8 +331,6 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		if (PageSwapBacked(page))
 			SetPageSwapBacked(newpage);
 
-		mem_cgroup_migrate(page, newpage);
-
 		return MIGRATEPAGE_SUCCESS;
 	}
 
@@ -428,8 +426,6 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	}
 	local_irq_enable();
 
-	mem_cgroup_migrate(page, newpage);
-
 	return MIGRATEPAGE_SUCCESS;
 }
 
@@ -471,8 +467,6 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 	spin_unlock_irq(&mapping->tree_lock);
 
-	mem_cgroup_migrate(page, newpage);
-
 	return MIGRATEPAGE_SUCCESS;
 }
 
@@ -586,6 +580,8 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 		end_page_writeback(newpage);
 
 	copy_page_owner(page, newpage);
+
+	mem_cgroup_migrate(page, newpage);
 }
 
 /************************************************************
@@ -1846,7 +1842,6 @@ fail_putback:
 	}
 
 	mlock_migrate_page(new_page, page);
-	mem_cgroup_migrate(page, new_page);
 	page_remove_rmap(page, true);
 	set_page_owner_migrate_reason(new_page, MR_NUMA_MISPLACED);
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
