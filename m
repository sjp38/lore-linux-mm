Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7501283096
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 07:14:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u81so13453329wmu.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:14:42 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e8si4047232wmi.30.2016.08.30.04.14.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 04:14:41 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so2668590wme.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:14:41 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] oom: warn if we go OOM for higher order and compaction is disabled
Date: Tue, 30 Aug 2016 13:14:27 +0200
Message-Id: <1472555667-30348-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Since the lumpy reclaim is gone there is no source of higher order pages
if CONFIG_COMPACTION=n except for the order-0 pages reclaim which is
unreliable for that purpose to say the least. Hitting an OOM for !costly
higher order requests is therefore all not that hard to imagine. We are
trying hard to not invoke OOM killer as much as possible but there is
simply no reliable way to detect whether more reclaim retries make sense.

Disabling COMPACTION is not widespread but it seems that some users
might have disable the feature without realizing full consequences
(mostly along with disabling THP because compaction used to be THP
mainly thing). This patch just adds a note if the OOM killer was
triggered by higher order request with compaction disabled. This will
help us identifying possible misconfiguration right from the oom report
which is easier than to always keep in mind that somebody might have
disabled COMPACTION without a good reason.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 10f686969fc4..b3c47072a206 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -406,6 +406,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
 		current->signal->oom_score_adj);
+	if (!IS_ENABLED(COMPACTION) && oc->order)
+		pr_warn("COMPACTION is disabled!!!\n");
 
 	cpuset_print_current_mems_allowed();
 	dump_stack();
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
