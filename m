Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C58BA6B0093
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 12:34:22 -0400 (EDT)
Received: by wiga1 with SMTP id a1so24103639wig.0
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 09:34:22 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id hs5si5520682wib.43.2015.06.19.09.34.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 09:34:21 -0700 (PDT)
Date: Fri, 19 Jun 2015 18:34:18 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] mm: memcontrol: correct the comment in mem_cgroup_swapout()
Message-ID: <20150619163418.GA21040@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, rostedt@goodmis.org, williams@redhat.com

Clark stumbled over a VM_BUG_ON() in -RT which was then was removed by
Johannes in commit f371763a79d ("mm: memcontrol: fix false-positive
VM_BUG_ON() on -rt"). The comment before that patch was a tiny bit
better than it is now. While the patch claimed to fix a false-postive on
-RT this was not the case. None of the -RT folks ACKed it and it was not a
false positive report. That was a *real* problem.

This patch updates the comment that is improper because it refers to
"disabled preemption" as a consequence of that lock being taken. A
spin_lock() disables preemption, true, but in this case the code relies on
the fact that the lock _also_ disables interrupts once it is acquired. And
this is the important detail (which was checked the VM_BUG_ON()) which needs
to be pointed out. This is the hint one needs while looking at the code. It
was explained by Johannes on the list that the per-CPU variables are protected
by local_irq_save(). The BUG_ON() was helpful. This code has been workarounded
in -RT in the meantime. I wouldn't mind running into more of those if the code
in question uses *special* kind of locking since now there is no no
verification (in terms of lockdep or BUG_ON()).

The two functions after the comment could also have a "local_irq_save()"
dance around them in order to serialize access to the per-CPU variables.
This has been avoided because the interrupts should be off.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/memcontrol.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a04225d372ba..6e90cf68ff7c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5835,7 +5835,12 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
 
-	/* Caller disabled preemption with mapping->tree_lock */
+	/*
+	 * Interrupts should be disabled here because the caller holds the
+	 * mapping->tree_lock lock which is taken with interrupts-off. It is
+	 * important here to have the interrupts disabled because it is the
+	 * only synchronisation we have for udpating the per-CPU variables.
+	 */
 	mem_cgroup_charge_statistics(memcg, page, -1);
 	memcg_check_events(memcg, page);
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
