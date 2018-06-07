Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBA46B0008
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:01:21 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i1-v6so7158944ioh.15
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:01:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n75-v6si6581992ion.86.2018.06.07.04.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 04:01:20 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/4] mm,oom: Simplify exception case handling in out_of_memory().
Date: Thu,  7 Jun 2018 20:00:22 +0900
Message-Id: <1528369223-7571-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

To avoid oversights when adding the "mm, oom: cgroup-aware OOM killer"
patchset, simplify the exception case handling in out_of_memory().
This patch makes no functional changes.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 23ce67f..5a6f1b1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1073,15 +1073,18 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	select_bad_process(oc);
+	if (oc->chosen == (void *)-1UL)
+		return true;
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+	if (!oc->chosen) {
+		if (is_sysrq_oom(oc) || is_memcg_oom(oc))
+			return false;
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL)
-		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
-				 "Memory cgroup out of memory");
-	return !!oc->chosen;
+	oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
+			 "Memory cgroup out of memory");
+	return true;
 }
 
 /*
-- 
1.8.3.1
