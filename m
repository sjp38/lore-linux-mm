Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31BD76B1F83
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 12:04:12 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f126-v6so2553129ywh.4
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 09:04:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a81-v6sor3617174yba.146.2018.08.21.09.04.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 09:04:08 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: print proper OOM header when no eligible victim left
Date: Tue, 21 Aug 2018 12:04:06 -0400
Message-Id: <20180821160406.22578-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

When the memcg OOM killer runs out of killable tasks, it currently
prints a WARN with no further OOM context. This has caused some user
confusion.

Warnings indicate a kernel problem. In a reported case, however, the
situation was triggered by a non-sensical memcg configuration (hard
limit set to 0). But without any VM context this wasn't obvious from
the report, and it took some back and forth on the mailing list to
identify what is actually a trivial issue.

Handle this OOM condition like we handle it in the global OOM killer:
dump the full OOM context and tell the user we ran out of tasks.

This way the user can identify misconfigurations easily by themselves
and rectify the problem - without having to go through the hassle of
running into an obscure but unsettling warning, finding the
appropriate kernel mailing list and waiting for a kernel developer to
remote-analyze that the memcg configuration caused this.

If users cannot make sense of why the OOM killer was triggered or why
it failed, they will still report it to the mailing list, we know that
from experience. So in case there is an actual kernel bug causing
this, kernel developers will very likely hear about it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c |  2 --
 mm/oom_kill.c   | 13 ++++++++++---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4e3c1315b1de..29d9d1a69b36 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1701,8 +1701,6 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 	if (mem_cgroup_out_of_memory(memcg, mask, order))
 		return OOM_SUCCESS;
 
-	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
-		"This looks like a misconfiguration or a kernel bug.");
 	return OOM_FAILED;
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b5b25e4dcbbb..95fbbc46f68f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1103,10 +1103,17 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	select_bad_process(oc);
-	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+	/* Found nothing?!?! */
+	if (!oc->chosen) {
 		dump_header(oc, NULL);
-		panic("Out of memory and no killable processes...\n");
+		pr_warn("Out of memory and no killable processes...\n");
+		/*
+		 * If we got here due to an actual allocation at the
+		 * system level, we cannot survive this and will enter
+		 * an endless loop in the allocator. Bail out now.
+		 */
+		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc))
+			panic("System is deadlocked on memory\n");
 	}
 	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
-- 
2.18.0
