Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C1DF46B000E
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:03:52 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l126so54981399wml.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:03:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 80si10697667wmb.43.2015.12.18.01.03.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 01:03:37 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 08/14] mm, oom: print symbolic gfp_flags in oom warning
Date: Fri, 18 Dec 2015 10:03:20 +0100
Message-Id: <1450429406-7081-9-git-send-email-vbabka@suse.cz>
In-Reply-To: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

It would be useful to translate gfp_flags into string representation when
printing in case of an OOM, especially as the flags have been undergoing some
changes recently and the script ./scripts/gfp-translate needs a matching source
version to be accurate.

Example output:

a.out invoked oom-killer: order=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO), om_score_adj=0

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dc490c06941b..f92b75750fc5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -386,10 +386,11 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 static void dump_header(struct oom_control *oc, struct task_struct *p,
 			struct mem_cgroup *memcg)
 {
-	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
-		"oom_score_adj=%hd\n",
-		current->comm, oc->gfp_mask, oc->order,
+	pr_warn("%s invoked oom-killer: order=%d, gfp_mask=%#x(%pgg), "
+			"oom_score_adj=%hd\n",
+		current->comm, oc->order, oc->gfp_mask, &oc->gfp_mask,
 		current->signal->oom_score_adj);
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
