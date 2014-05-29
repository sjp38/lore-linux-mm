Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0304C6B004D
	for <linux-mm@kvack.org>; Thu, 29 May 2014 12:17:08 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n15so5977196wiw.3
        for <linux-mm@kvack.org>; Thu, 29 May 2014 09:17:08 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id i1si3037580wie.45.2014.05.29.09.16.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 May 2014 09:16:52 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 04/10] mm: memcontrol: reclaim at least once for __GFP_NORETRY
Date: Thu, 29 May 2014 12:15:56 -0400
Message-Id: <1401380162-24121-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
References: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, __GFP_NORETRY tries charging once and gives up before even
trying to reclaim.  Bring the behavior on par with the page allocator
and reclaim at least once before giving up.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e8d5075c081f..8957d6c945b8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2614,13 +2614,13 @@ retry:
 	if (!(gfp_mask & __GFP_WAIT))
 		goto nomem;
 
-	if (gfp_mask & __GFP_NORETRY)
-		goto nomem;
-
 	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
 
 	if (mem_cgroup_margin(mem_over_limit) >= batch)
 		goto retry;
+
+	if (gfp_mask & __GFP_NORETRY)
+		goto nomem;
 	/*
 	 * Even though the limit is exceeded at this point, reclaim
 	 * may have been able to free some pages.  Retry the charge
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
