Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 379716B0098
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 19:13:55 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rl12so5005712iec.7
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:13:55 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id l9si23789047igv.4.2014.06.02.16.13.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 16:13:54 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id tp5so5213682ieb.3
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:13:54 -0700 (PDT)
Date: Mon, 2 Jun 2014 16:13:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: periodically schedule when emptying page list
Message-ID: <alpine.DEB.2.02.1406021612550.6487@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

mem_cgroup_force_empty_list() can iterate a large number of pages on an lru and 
mem_cgroup_move_parent() doesn't return an errno unless certain criteria, none 
of which indicate that the iteration may be taking too long, is met.

We have encountered the following stack trace many times indicating
"need_resched set for > 51000020 ns (51 ticks) without schedule", for example:

	scheduler_tick()
	<timer irq>
	mem_cgroup_move_account+0x4d/0x1d5
	mem_cgroup_move_parent+0x8d/0x109
	mem_cgroup_reparent_charges+0x149/0x2ba
	mem_cgroup_css_offline+0xeb/0x11b
	cgroup_offline_fn+0x68/0x16b
	process_one_work+0x129/0x350

If this iteration is taking too long, indicated by need_resched(), then 
periodically schedule and continue from where we last left off.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4764,6 +4764,7 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 	do {
 		struct page_cgroup *pc;
 		struct page *page;
+		int ret;
 
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		if (list_empty(list)) {
@@ -4781,8 +4782,13 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 
 		pc = lookup_page_cgroup(page);
 
-		if (mem_cgroup_move_parent(page, pc, memcg)) {
-			/* found lock contention or "pc" is obsolete. */
+		ret = mem_cgroup_move_parent(page, pc, memcg);
+		if (ret || need_resched()) {
+			/*
+			 * Couldn't grab the page reference, isolate the page,
+			 * there was a pc mismatch, or we simply need to
+			 * schedule because this is taking too long.
+			 */
 			busy = page;
 			cond_resched();
 		} else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
