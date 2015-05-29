Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id DEA486B00A2
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:48:31 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so18673256qkh.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:48:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a96si5945268qkh.14.2015.05.29.08.48.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:48:30 -0700 (PDT)
Date: Fri, 29 May 2015 10:48:15 -0500
From: Clark Williams <williams@redhat.com>
Subject: [RFC] mm: change irqs_disabled() test to spin_is_locked() in
 mem_cgroup_swapout
Message-ID: <20150529104815.2d2e880c@sluggy>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Thomas Gleixner <tglx@glx-um.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, RT <linux-rt-users@vger.kernel.org>, Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>, Steven Rostedt <rostedt@goodmis.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Johannes,

We are seeing a panic in the latest RT kernel (4.0.4-rt1) where a
VM_BUG_ON(!irqs_disabled()) in mm/memcontrol.c fires. This is because on
an RT kernel, rt_mutexes (which replace spinlocks) don't disable
interrupts while the lock is held. I talked to Steven and he suggested
that we replace the irqs_disabled() with spin_is_held(). 

Does this patch work for you?

Clark

From: Clark Williams <williams@redhat.com>
Date: Fri, 29 May 2015 10:28:55 -0500
Subject: [PATCH] mm: change irqs_disabled() to spin_is_locked() in mem_cgroup_swapout()

The irqs_disabled() check in mem_cgroup_swapout() fails on the latest
RT kernel because RT mutexes do not disable interrupts when held. Change
the test for the lock being held to use spin_is_locked.

Reported-by: Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>
Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Clark Williams <williams@redhat.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9da0f3e9c1f3..70befa14a8ce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5845,7 +5845,7 @@ void mem_cgroup_swapout(struct page *page,
swp_entry_t entry) page_counter_uncharge(&memcg->memory, 1);
 
 	/* XXX: caller holds IRQ-safe mapping->tree_lock */
-	VM_BUG_ON(!irqs_disabled());
+	VM_BUG_ON(!spin_is_locked(&page_mapping(page)->tree_lock));
 
 	mem_cgroup_charge_statistics(memcg, page, -1);
 	memcg_check_events(memcg, page);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
