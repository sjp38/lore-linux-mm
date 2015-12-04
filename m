Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0BF6B025A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 10:59:06 -0500 (EST)
Received: by wmuu63 with SMTP id u63so67550491wmu.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 07:59:05 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id x9si19345101wje.220.2015.12.04.07.59.04
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 07:59:05 -0800 (PST)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v2 1/2] mm: Export nr_swap_pages
Date: Fri,  4 Dec 2015 15:58:53 +0000
Message-Id: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, "Goel, Akash" <akash.goel@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Some modules, like i915.ko, use swappable objects and may try to swap
them out under memory pressure (via the shrinker). Before doing so, they
want to check using get_nr_swap_pages() to see if any swap space is
available as otherwise they will waste time purging the object from the
device without recovering any memory for the system. This requires the
nr_swap_pages counter to be exported to the modules.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: "Goel, Akash" <akash.goel@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
---
 mm/swapfile.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 58877312cf6b..2d259fdb2347 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -48,6 +48,12 @@ static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 atomic_long_t nr_swap_pages;
+/*
+ * Some modules use swappable objects and may try to swap them out under
+ * memory pressure (via the shrinker). Before doing so, they may wish to
+ * check to see if any swap space is available.
+ */
+EXPORT_SYMBOL_GPL(nr_swap_pages);
 /* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
 long total_swap_pages;
 static int least_priority;
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
