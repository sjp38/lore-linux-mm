Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31EA66B039F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 18:44:57 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a2so81183378pgn.15
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 15:44:57 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z8si503587pll.289.2017.07.21.15.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 15:44:56 -0700 (PDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 2/2] mm/swap: Remove lock_initialized flag from swap_slots_cache
Date: Fri, 21 Jul 2017 15:45:01 -0700
Message-Id: <867d1fb070644e6d5f0ac7780f63e75259b82cc3.1500677066.git.tim.c.chen@linux.intel.com>
In-Reply-To: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
References: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
In-Reply-To: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
References: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

We will only reach the lock initialization code
in alloc_swap_slot_cache when the cpu's swap_slots_cache's slots
have not been allocated and swap_slots_cache has not been initialized
previously.  So the lock_initialized check is redundant and unnecessary.
Remove lock_initialized flag from swap_slots_cache to save memory.

Reported-by: Wenwei Tao <wenwei.tww@alibaba-inc.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/swap_slots.h | 1 -
 mm/swap_slots.c            | 9 ++++-----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
index 6ef92d1..a75c30b 100644
--- a/include/linux/swap_slots.h
+++ b/include/linux/swap_slots.h
@@ -10,7 +10,6 @@
 #define THRESHOLD_DEACTIVATE_SWAP_SLOTS_CACHE	(2*SWAP_SLOTS_CACHE_SIZE)
 
 struct swap_slots_cache {
-	bool		lock_initialized;
 	struct mutex	alloc_lock; /* protects slots, nr, cur */
 	swp_entry_t	*slots;
 	int		nr;
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 4c5457c..c039e6c 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -140,11 +140,10 @@ static int alloc_swap_slot_cache(unsigned int cpu)
 	if (cache->slots || cache->slots_ret)
 		/* cache already allocated */
 		goto out;
-	if (!cache->lock_initialized) {
-		mutex_init(&cache->alloc_lock);
-		spin_lock_init(&cache->free_lock);
-		cache->lock_initialized = true;
-	}
+
+	mutex_init(&cache->alloc_lock);
+	spin_lock_init(&cache->free_lock);
+
 	cache->nr = 0;
 	cache->cur = 0;
 	cache->n_ret = 0;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
