Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1D76B0261
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:36:57 -0500 (EST)
Received: by wmec201 with SMTP id c201so24568164wme.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:36:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g132si26399291wma.124.2015.11.24.04.36.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 04:36:44 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 9/9] mm, oom: print symbolic gfp_flags in oom warning
Date: Tue, 24 Nov 2015 13:36:21 +0100
Message-Id: <1448368581-6923-10-git-send-email-vbabka@suse.cz>
In-Reply-To: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

It would be useful to translate gfp_flags into string representation when
printing in case of an OOM, especially as the flags have been undergoing some
changes recently and the script ./scripts/gfp-translate needs a matching source
version to be accurate.

Example output:

a.out invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/oom_kill.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5314b20..542d56c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -386,10 +386,12 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 static void dump_header(struct oom_control *oc, struct task_struct *p,
 			struct mem_cgroup *memcg)
 {
-	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
-		"oom_score_adj=%hd\n",
-		current->comm, oc->gfp_mask, oc->order,
-		current->signal->oom_score_adj);
+	pr_warning("%s invoked oom-killer: order=%d, oom_score_adj=%hd, "
+			"gfp_mask=0x%x",
+		current->comm, oc->order, current->signal->oom_score_adj,
+		oc->gfp_mask);
+	dump_gfpflag_names(oc->gfp_mask);
+
 	cpuset_print_current_mems_allowed();
 	dump_stack();
 	if (memcg)
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
