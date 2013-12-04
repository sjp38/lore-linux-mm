Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 36E5B6B004D
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 17:45:37 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id e11so6938092bkh.9
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 14:45:36 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id yv6si22837561bkb.169.2013.12.04.14.45.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 14:45:36 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] mm: memcg: do not allow task about to OOM kill to bypass the limit
Date: Wed,  4 Dec 2013 17:45:14 -0500
Message-Id: <1386197114-5317-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1386197114-5317-1-git-send-email-hannes@cmpxchg.org>
References: <1386197114-5317-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

4942642080ea ("mm: memcg: handle non-error OOM situations more
gracefully") allowed tasks that already entered a memcg OOM condition
to bypass the memcg limit on subsequent allocation attempts hoping
this would expedite finishing the page fault and executing the kill.

David Rientjes is worried that this breaks memcg isolation guarantees
and since there is no evidence that the bypass actually speeds up
fault processing just change it so that these subsequent charge
attempts fail outright.  The notable exception being __GFP_NOFAIL
charges which are required to bypass the limit regardless.

Reported-by: David Rientjes <rientjes@google.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f6a63f5b3827..bf5e89457149 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2694,7 +2694,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		goto bypass;
 
 	if (unlikely(task_in_memcg_oom(current)))
-		goto bypass;
+		goto nomem;
 
 	if (gfp_mask & __GFP_NOFAIL)
 		oom = false;
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
