Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id AC50B6B0038
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:26:00 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so603163eek.7
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:26:00 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id g47si32027118eet.174.2014.04.30.13.25.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 13:25:59 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/9] mm: memcontrol: catch root bypass in move precharge
Date: Wed, 30 Apr 2014 16:25:38 -0400
Message-Id: <1398889543-23671-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

When mem_cgroup_try_charge() returns -EINTR, it bypassed the charge to
the root memcg.  But move precharging does not catch this and treats
this case as if no charge had happened, thus leaking a charge against
root.  Because of an old optimization, the root memcg's res_counter is
not actually charged right now, but it's still an imbalance and
subsequent patches will charge the root memcg again.

Thus, catch those bypasses to the root memcg and properly cancel them
before giving up the move.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c431a30280ac..788be26103f9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6546,8 +6546,9 @@ one_by_one:
 			cond_resched();
 		}
 		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
+		if (ret == -EINTR)
+			__mem_cgroup_cancel_charge(root_mem_cgroup, 1);
 		if (ret)
-			/* mem_cgroup_clear_mc() will do uncharge later */
 			return ret;
 		mc.precharge++;
 	}
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
