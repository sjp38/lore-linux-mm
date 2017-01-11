Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8E7C6B026B
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 12:55:54 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 194so244220490pgd.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:55:54 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m13si6442061pga.262.2017.01.11.09.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 09:55:53 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v5 9/9] mm/swap: Skip readahead only when swap slot cache is enabled
Date: Wed, 11 Jan 2017 09:55:19 -0800
Message-Id: <5e2c5f6abe8e6eb0797408897b1bba80938e9b9d.1484082593.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim Chen <tim.c.chen@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

Because during swap off, a swap entry may have swap_map[] ==
SWAP_HAS_CACHE (for example, just allocated).  If we return NULL in
__read_swap_cache_async(), the swap off will abort.  So when swap slot
cache is disabled, (for swap off), we will wait for page to be put
into swap cache in such race condition.  This should not be a problem
for swap slot cache, because swap slot cache should be drained after
clearing swap_slot_cache_enabled.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/swap_slots.h |  2 ++
 mm/swap_slots.c            |  2 +-
 mm/swap_state.c            | 11 +++++++++--
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
index a59e6e2..fb90734 100644
--- a/include/linux/swap_slots.h
+++ b/include/linux/swap_slots.h
@@ -25,4 +25,6 @@ void reenable_swap_slots_cache_unlock(void);
 int enable_swap_slots_cache(void);
 int free_swap_slot(swp_entry_t entry);
 
+extern bool swap_slot_cache_enabled;
+
 #endif /* _LINUX_SWAP_SLOTS_H */
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index b816839..8cf941e 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -36,7 +36,7 @@
 
 static DEFINE_PER_CPU(struct swap_slots_cache, swp_slots);
 static bool	swap_slot_cache_active;
-static bool	swap_slot_cache_enabled;
+bool	swap_slot_cache_enabled;
 static bool	swap_slot_cache_initialized;
 DEFINE_MUTEX(swap_slots_cache_mutex);
 /* Serialize swap slots cache enable/disable operations */
diff --git a/mm/swap_state.c b/mm/swap_state.c
index e1f07ca..2126e9b 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -324,8 +324,15 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		if (found_page)
 			break;
 
-		/* Just skip read ahead for unused swap slot */
-		if (!__swp_swapcount(entry))
+		/*
+		 * Just skip read ahead for unused swap slot.
+		 * During swap_off when swap_slot_cache is disabled,
+		 * we have to handle the race between putting
+		 * swap entry in swap cache and marking swap slot
+		 * as SWAP_HAS_CACHE.  That's done in later part of code or
+		 * else swap_off will be aborted if we return NULL.
+		 */
+		if (!__swp_swapcount(entry) && swap_slot_cache_enabled)
 			return NULL;
 
 		/*
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
