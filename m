Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9EC6B02B4
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 18:44:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v190so76807147pgv.12
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 15:44:52 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z8si503587pll.289.2017.07.21.15.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 15:44:51 -0700 (PDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 1/2] mm/swap: Fix race conditions in swap_slots cache init
Date: Fri, 21 Jul 2017 15:45:00 -0700
Message-Id: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

Memory allocations can happen before the swap_slots cache initialization
is completed during cpu bring up.  If we are low on memory, we could call
get_swap_page and access swap_slots_cache before it is fully initialized.

Add a check in get_swap_page for initialized swap_slots_cache
to prevent this condition.  Similar check already exists in
free_swap_slot.  Also annotate the checks to indicate the likely
condition.

We also added a memory barrier to make sure that the locks
initialization are done before the assignment of cache->slots
and cache->slots_ret pointers. This ensures the assumption
that it is safe to acquire the slots cache locks and use the slots
cache when the corresponding cache->slots or cache->slots_ret
pointers are non null.

Reported-by: Wenwei Tao <wenwei.tww@alibaba-inc.com>
Acked-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/swap_slots.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 58f6c78..4c5457c 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -148,6 +148,14 @@ static int alloc_swap_slot_cache(unsigned int cpu)
 	cache->nr = 0;
 	cache->cur = 0;
 	cache->n_ret = 0;
+	/*
+	 * We intialized alloc_lock and free_lock earlier.
+	 * We use !cache->slots or !cache->slots_ret
+	 * to know if it is safe to acquire the corresponding
+	 * lock and use the cache.  Memory barrier
+	 * below ensures the assumption.
+	 */
+	mb();
 	cache->slots = slots;
 	slots = NULL;
 	cache->slots_ret = slots_ret;
@@ -273,7 +281,7 @@ int free_swap_slot(swp_entry_t entry)
 	struct swap_slots_cache *cache;
 
 	cache = &get_cpu_var(swp_slots);
-	if (use_swap_slot_cache && cache->slots_ret) {
+	if (likely(use_swap_slot_cache && cache->slots_ret)) {
 		spin_lock_irq(&cache->free_lock);
 		/* Swap slots cache may be deactivated before acquiring lock */
 		if (!use_swap_slot_cache) {
@@ -318,7 +326,7 @@ swp_entry_t get_swap_page(void)
 	cache = raw_cpu_ptr(&swp_slots);
 
 	entry.val = 0;
-	if (check_cache_active()) {
+	if (likely(check_cache_active() && cache->slots)) {
 		mutex_lock(&cache->alloc_lock);
 		if (cache->slots) {
 repeat:
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
