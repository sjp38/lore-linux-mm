Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7212803C1
	for <linux-mm@kvack.org>; Fri, 19 May 2017 07:26:19 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i63so56643493pgd.15
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:26:19 -0700 (PDT)
Received: from mail-pg0-f66.google.com (mail-pg0-f66.google.com. [74.125.83.66])
        by mx.google.com with ESMTPS id w125si7959205pfb.368.2017.05.19.04.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 04:26:18 -0700 (PDT)
Received: by mail-pg0-f66.google.com with SMTP id h64so9480333pge.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:26:18 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the #PF
Date: Fri, 19 May 2017 13:26:04 +0200
Message-Id: <20170519112604.29090-3-mhocko@kernel.org>
In-Reply-To: <20170519112604.29090-1-mhocko@kernel.org>
References: <20170519112604.29090-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Any allocation failure during the #PF path will return with VM_FAULT_OOM
which in turn results in pagefault_out_of_memory. This can happen for
2 different reasons. a) Memcg is out of memory and we rely on
mem_cgroup_oom_synchronize to perform the memcg OOM handling or b)
normal allocation fails.

The later is quite problematic because allocation paths already trigger
out_of_memory and the page allocator tries really hard to not fail
allocations. Anyway, if the OOM killer has been already invoked there
is no reason to invoke it again from the #PF path. Especially when the
OOM condition might be gone by that time and we have no way to find out
other than allocate.

Moreover if the allocation failed and the OOM killer hasn't been
invoked then we are unlikely to do the right thing from the #PF context
because we have already lost the allocation context and restictions and
therefore might oom kill a task from a different NUMA domain.

An allocation might fail also when the current task is the oom victim
and there are no memory reserves left and we should simply bail out
from the #PF rather than invoking out_of_memory.

This all suggests that there is no legitimate reason to trigger
out_of_memory from pagefault_out_of_memory so drop it. Just to be sure
that no #PF path returns with VM_FAULT_OOM without allocation print a
warning that this is happening before we restart the #PF.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143a8625..0f24bdfaadfd 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1051,25 +1051,22 @@ bool out_of_memory(struct oom_control *oc)
 }
 
 /*
- * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
- * killing is already in progress so do nothing.
+ * The pagefault handler calls here because some allocation has failed. We have
+ * to take care of the memcg OOM here because this is the only safe context without
+ * any locks held but let the oom killer triggered from the allocation context care
+ * about the global OOM.
  */
 void pagefault_out_of_memory(void)
 {
-	struct oom_control oc = {
-		.zonelist = NULL,
-		.nodemask = NULL,
-		.memcg = NULL,
-		.gfp_mask = 0,
-		.order = 0,
-	};
+	static DEFINE_RATELIMIT_STATE(pfoom_rs, DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
 
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
+	if (fatal_signal_pending)
 		return;
-	out_of_memory(&oc);
-	mutex_unlock(&oom_lock);
+
+	if (__ratelimit(&pfoom_rs))
+		pr_warn("Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF\n");
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
