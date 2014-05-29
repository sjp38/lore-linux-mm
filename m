Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id BA59B6B0037
	for <linux-mm@kvack.org>; Thu, 29 May 2014 12:16:28 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id x48so667978wes.36
        for <linux-mm@kvack.org>; Thu, 29 May 2014 09:16:28 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id o12si21660890wiv.36.2014.05.29.09.16.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 May 2014 09:16:27 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 05/10] mm: memcontrol: catch root bypass in move precharge
Date: Thu, 29 May 2014 12:15:57 -0400
Message-Id: <1401380162-24121-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
References: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When mem_cgroup_try_charge() returns -EINTR, it bypassed the charge to
the root memcg.  But move precharging does not catch this and treats
this case as if no charge had happened, thus leaking a charge against
root.  Because of an old optimization, the root memcg's res_counter is
not actually charged right now, but it's still an imbalance and
subsequent patches will charge the root memcg again.

Catch those bypasses to the root memcg and properly cancel them before
giving up the move.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8957d6c945b8..184e67cce4e4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6485,8 +6485,15 @@ one_by_one:
 			cond_resched();
 		}
 		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
+		/*
+		 * In case of failure, any residual charges against
+		 * mc.to will be dropped by mem_cgroup_clear_mc()
+		 * later on.  However, cancel any charges that are
+		 * bypassed to root right away or they'll be lost.
+		 */
+		if (ret == -EINTR)
+			__mem_cgroup_cancel_charge(root_mem_cgroup, 1);
 		if (ret)
-			/* mem_cgroup_clear_mc() will do uncharge later */
 			return ret;
 		mc.precharge++;
 	}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
