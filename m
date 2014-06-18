Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5116B0044
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:41:07 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n3so8317839wiv.3
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:41:07 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ft19si4165584wic.27.2014.06.18.13.41.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:41:07 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 08/13] mm: memcontrol: catch root bypass in move precharge
Date: Wed, 18 Jun 2014 16:40:40 -0400
Message-Id: <1403124045-24361-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

When mem_cgroup_try_charge() returns -EINTR, it bypassed the charge to
the root memcg.  But move precharging does not catch this and treats
this case as if no charge had happened, thus leaking a charge against
root.  Because of an old optimization, the root memcg's res_counter is
not actually charged right now, but it's still an imbalance and
subsequent patches will charge the root memcg again.

Catch those bypasses to the root memcg and properly cancel them before
giving up the move.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 382af03a040a..b6b5f7f98618 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6375,6 +6375,10 @@ static int mem_cgroup_do_precharge(unsigned long count)
 		mc.precharge += count;
 		return ret;
 	}
+	if (ret == -EINTR) {
+		__mem_cgroup_cancel_charge(root_mem_cgroup, count);
+		return ret;
+	}
 
 	/* Try charges one by one with reclaim */
 	while (count--) {
@@ -6383,8 +6387,11 @@ static int mem_cgroup_do_precharge(unsigned long count)
 		/*
 		 * In case of failure, any residual charges against
 		 * mc.to will be dropped by mem_cgroup_clear_mc()
-		 * later on.
+		 * later on.  However, cancel any charges that are
+		 * bypassed to root right away or they'll be lost.
 		 */
+		if (ret == -EINTR)
+			__mem_cgroup_cancel_charge(root_mem_cgroup, 1);
 		if (ret)
 			return ret;
 		mc.precharge++;
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
