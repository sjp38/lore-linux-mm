Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4E26B03B6
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:54:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x23so10916866wrb.6
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:03 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id 73si3867702wrl.337.2017.06.23.01.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:54:02 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id z45so10917267wrb.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:01 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/6] mm, migration: do not trigger OOM killer when migrating memory
Date: Fri, 23 Jun 2017 10:53:45 +0200
Message-Id: <20170623085345.11304-7-mhocko@kernel.org>
In-Reply-To: <20170623085345.11304-1-mhocko@kernel.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Page migration (for memory hotplug, soft_offline_page or mbind) needs
to allocate a new memory. This can trigger an oom killer if the target
memory is depleated. Although quite unlikely, still possible, especially
for the memory hotplug (offlining of memoery). Up to now we didn't
really have reasonable means to back off. __GFP_NORETRY can fail just
too easily and __GFP_THISNODE sticks to a single node and that is not
suitable for all callers.

But now that we have __GFP_RETRY_MAYFAIL we should use it.  It is
preferable to fail the migration than disrupt the system by killing some
processes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/migrate.h | 2 +-
 mm/memory-failure.c     | 3 ++-
 mm/mempolicy.c          | 3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f80c9882403a..9f5885dae80e 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -34,7 +34,7 @@ extern char *migrate_reason_names[MR_TYPES];
 static inline struct page *new_page_nodemask(struct page *page, int preferred_nid,
 		nodemask_t *nodemask)
 {
-	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
+	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE | __GFP_RETRY_MAYFAIL;
 
 	if (PageHuge(page))
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e2e0cb0e1d0f..fe0c484c6fdb 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1492,7 +1492,8 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
 
 		return alloc_huge_page_node(hstate, nid);
 	} else {
-		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
+		return __alloc_pages_node(nid,
+				GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL, 0);
 	}
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7d8e56214ac0..d911fa5cb2a7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1078,7 +1078,8 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
 	/*
 	 * if !vma, alloc_page_vma() will use task or system default policy
 	 */
-	return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	return alloc_page_vma(GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL,
+			vma, address);
 }
 #else
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
