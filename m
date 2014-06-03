Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id AE93D6B00AC
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 20:51:28 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id to1so4072867ieb.15
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 17:51:28 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id y5si15727762igl.3.2014.06.02.17.51.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 17:51:28 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so5098295iec.5
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 17:51:27 -0700 (PDT)
Date: Mon, 2 Jun 2014 17:51:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, memcg: periodically schedule when emptying page
 list
In-Reply-To: <alpine.DEB.2.02.1406021612550.6487@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1406021749590.13910@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1406021612550.6487@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

From: Hugh Dickins <hughd@google.com>

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

If this iteration is taking too long, we still need to do cond_resched() even 
when an individual page is not busy.

[rientjes@google.com: changelog]
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: always reschedule if needed, "page" itself may not have a pc mismatch
     or been unable to isolate.

 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4784,9 +4784,9 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 		if (mem_cgroup_move_parent(page, pc, memcg)) {
 			/* found lock contention or "pc" is obsolete. */
 			busy = page;
-			cond_resched();
 		} else
 			busy = NULL;
+		cond_resched();
 	} while (!list_empty(list));
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
