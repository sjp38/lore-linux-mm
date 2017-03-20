Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7089F6B0389
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 02:27:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 81so243748562pgh.3
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 23:27:37 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p89si6078744pfa.239.2017.03.19.23.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 23:27:36 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH] mm, swap: Remove WARN_ON_ONCE() in free_swap_slot()
Date: Mon, 20 Mar 2017 14:26:42 +0800
Message-Id: <20170320062657.26683-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

Before commit 452b94b8c8c7 ("mm/swap: don't BUG_ON() due to
uninitialized swap slot cache"), the following bug is reported,

  ------------[ cut here ]------------
  kernel BUG at mm/swap_slots.c:270!
  invalid opcode: 0000 [#1] SMP
  CPU: 5 PID: 1745 Comm: (sd-pam) Not tainted 4.11.0-rc1-00243-g24c534bb161b #1
  Hardware name: System manufacturer System Product Name/Z170-K, BIOS
1803 05/06/2016
  RIP: 0010:free_swap_slot+0xba/0xd0
  Call Trace:
   swap_free+0x36/0x40
   do_swap_page+0x360/0x6d0
   __handle_mm_fault+0x880/0x1080
   handle_mm_fault+0xd0/0x240
   __do_page_fault+0x232/0x4d0
   do_page_fault+0x20/0x70
   page_fault+0x22/0x30
  ---[ end trace aefc9ede53e0ab21 ]---

This is raised by the BUG_ON(!swap_slot_cache_initialized) in
free_swap_slot().  This is incorrect, because even if the swap slots
cache fails to be initialized, the swap should operate properly
without the swap slots cache.  And the use_swap_slot_cache check later
in the function will protect the uninitialized swap slots cache case.

In commit 452b94b8c8c7, the BUG_ON() is replaced by WARN_ON_ONCE().
In the patch, the WARN_ON_ONCE() is removed too.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swap_slots.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 7ebb23836f68..b1ccb58ad397 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -267,8 +267,6 @@ int free_swap_slot(swp_entry_t entry)
 {
 	struct swap_slots_cache *cache;
 
-	WARN_ON_ONCE(!swap_slot_cache_initialized);
-
 	cache = &get_cpu_var(swp_slots);
 	if (use_swap_slot_cache && cache->slots_ret) {
 		spin_lock_irq(&cache->free_lock);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
