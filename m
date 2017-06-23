Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B14F6B03CF
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:13:08 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z45so11389412wrb.13
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:13:08 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j5si4108455wrj.331.2017.06.23.03.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 03:13:06 -0700 (PDT)
Date: Fri, 23 Jun 2017 12:12:54 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [RFC PATCH] mm, swap: don't disable preemption while taking the
 per-CPU cache
Message-ID: <20170623101254.k4zzbf3dfoukoxkq@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: tglx@linutronix.de, ying.huang@intel.com, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

get_cpu_var() disables preemption and returns the per-CPU version of the
variable. Disabling preemption is useful to ensure atomic access to the
variable within the critical section.
In this case however, after the per-CPU version of the variable is
obtained the ->free_lock is acquired. For that reason it seems the raw
accessor could be used. It only seems that ->slots_ret should be
retested (because with disabled preemption this variable can not be set
to NULL otherwise).

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/swap_slots.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 58f6c78f1dad..51c304477482 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -272,11 +272,11 @@ int free_swap_slot(swp_entry_t entry)
 {
 	struct swap_slots_cache *cache;
 
-	cache = &get_cpu_var(swp_slots);
+	cache = raw_cpu_ptr(&swp_slots);
 	if (use_swap_slot_cache && cache->slots_ret) {
 		spin_lock_irq(&cache->free_lock);
 		/* Swap slots cache may be deactivated before acquiring lock */
-		if (!use_swap_slot_cache) {
+		if (!use_swap_slot_cache || !cache->slots_ret) {
 			spin_unlock_irq(&cache->free_lock);
 			goto direct_free;
 		}
@@ -296,7 +296,6 @@ int free_swap_slot(swp_entry_t entry)
 direct_free:
 		swapcache_free_entries(&entry, 1);
 	}
-	put_cpu_var(swp_slots);
 
 	return 0;
 }
-- 
2.13.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
