Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 199F46B0256
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 08:56:26 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id mw1so12064668igb.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 05:56:26 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id m8si23107792igv.95.2016.02.09.05.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 05:56:25 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 5/6] mm: workingset: size shadow nodes lru basing on file cache size
Date: Tue, 9 Feb 2016 16:55:53 +0300
Message-ID: <26fb2cef8be75a27eae79e91b0f8351b468ab9d0.1455025246.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1455025246.git.vdavydov@virtuozzo.com>
References: <cover.1455025246.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A page is activated on refault if the refault distance stored in the
corresponding shadow entry is less than the number of active file pages.
Since active file pages can't occupy more than half memory, we assume
that the maximal effective refault distance can't be greater than half
the number of present pages and size the shadow nodes lru list
appropriately. Generally speaking, this assumption is correct, but it
can result in wasting a considerable chunk of memory on stale shadow
nodes in case the portion of file pages is small, e.g. if a workload
mostly uses anonymous memory.

To sort this out, we need to compute the size of shadow nodes lru basing
not on the maximal possible, but the current size of file cache. We
could take the size of active file lru for the maximal refault distance,
but active lru is pretty unstable - it can shrink dramatically at
runtime possibly disrupting workingset detection logic.

Instead we assume that the maximal refault distance equals half the
total number of file cache pages. This will protect us against active
file lru size fluctuations while still being correct, because size of
active lru is normally maintained lower than size of inactive lru.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/workingset.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 6130ba0b2641..68e8cd94ebe4 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -349,7 +349,9 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
 	local_irq_enable();
 
-	pages = node_present_pages(sc->nid);
+	pages = node_page_state(sc->nid, NR_ACTIVE_FILE) +
+		node_page_state(sc->nid, NR_INACTIVE_FILE);
+
 	/*
 	 * Active cache pages are limited to 50% of memory, and shadow
 	 * entries that represent a refault distance bigger than that
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
