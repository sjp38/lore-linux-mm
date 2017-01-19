Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E603D6B02E1
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 17:57:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so73533190pgc.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 14:57:38 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id l19si2553116pgk.240.2017.01.19.14.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 14:57:37 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id y143so16894160pfb.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 14:57:37 -0800 (PST)
Date: Thu, 19 Jan 2017 14:57:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: header nodemask is NULL when cpusets are disabled
In-Reply-To: <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz>
Message-ID: <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com> <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Commit 82e7d3abec86 ("oom: print nodemask in the oom report") implicitly 
sets the allocation nodemask to cpuset_current_mems_allowed when there is 
no effective mempolicy.  cpuset_current_mems_allowed is only effective 
when cpusets are enabled, which is also printed by dump_header(), so 
setting the nodemask to cpuset_current_mems_allowed is redundant and 
prevents debugging issues where ac->nodemask is not set properly in the 
page allocator.

This provides better debugging output since 
cpuset_print_current_mems_allowed() is already provided.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -403,12 +403,14 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 
 static void dump_header(struct oom_control *oc, struct task_struct *p)
 {
-	nodemask_t *nm = (oc->nodemask) ? oc->nodemask : &cpuset_current_mems_allowed;
-
-	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n",
-		current->comm, oc->gfp_mask, &oc->gfp_mask,
-		nodemask_pr_args(nm), oc->order,
-		current->signal->oom_score_adj);
+	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=",
+		current->comm, oc->gfp_mask, &oc->gfp_mask);
+	if (oc->nodemask)
+		pr_cont("%*pbl", nodemask_pr_args(oc->nodemask));
+	else
+		pr_cont("(null)\n");
+	pr_cont(",  order=%d, oom_score_adj=%hd\n",
+		oc->order, current->signal->oom_score_adj);
 	if (!IS_ENABLED(CONFIG_COMPACTION) && oc->order)
 		pr_warn("COMPACTION is disabled!!!\n");
 
@@ -417,7 +419,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	if (oc->memcg)
 		mem_cgroup_print_oom_info(oc->memcg, p);
 	else
-		show_mem(SHOW_MEM_FILTER_NODES, nm);
+		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(oc->memcg, oc->nodemask);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
