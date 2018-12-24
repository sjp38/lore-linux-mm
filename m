Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEC428E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 04:11:20 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id x3so3661640wru.22
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 01:11:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h126sor12667283wmf.21.2018.12.24.01.11.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 01:11:18 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] memcg, oom: notify on oom killer invocation from the charge path
Date: Mon, 24 Dec 2018 10:11:07 +0100
Message-Id: <20181224091107.18354-1-mhocko@kernel.org>
In-Reply-To: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
References: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Burt Holzman <burt@fnal.gov>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>

From: Michal Hocko <mhocko@suse.com>

Burt Holzman has noticed that memcg v1 doesn't notify about OOM events
via eventfd anymore. The reason is that 29ef680ae7c2 ("memcg, oom: move
out_of_memory back to the charge path") has moved the oom handling back
to the charge path. While doing so the notification was left behind in
mem_cgroup_oom_synchronize.

Fix the issue by replicating the oom hierarchy locking and the
notification.

Reported-by: Burt Holzman <burt@fnal.gov>
Fixes: 29ef680ae7c2 ("memcg, oom: move out_of_memory back to the charge path")
Cc: stable # 4.19+
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi Andrew,
I forgot to CC you on the patch sent as a reply to the original bug
report [1] so I am reposting with Ack from Johannes. Burt has confirmed
this is resolving the regression for him [2]. 4.20 is out but I have
marked the patch for stable so it should hit both 4.19 and 4.20.

[1] http://lkml.kernel.org/r/20181221153302.GB6410@dhcp22.suse.cz
[2] http://lkml.kernel.org/r/96D4815C-420F-41B7-B1E9-A741E7523596@services.fnal.gov

 mm/memcontrol.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6e1469b80cb7..7e6bf74ddb1e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1666,6 +1666,9 @@ enum oom_status {
 
 static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
+	enum oom_status ret;
+	bool locked;
+
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		return OOM_SKIPPED;
 
@@ -1700,10 +1703,23 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 		return OOM_ASYNC;
 	}
 
+	mem_cgroup_mark_under_oom(memcg);
+
+	locked = mem_cgroup_oom_trylock(memcg);
+
+	if (locked)
+		mem_cgroup_oom_notify(memcg);
+
+	mem_cgroup_unmark_under_oom(memcg);
 	if (mem_cgroup_out_of_memory(memcg, mask, order))
-		return OOM_SUCCESS;
+		ret = OOM_SUCCESS;
+	else
+		ret = OOM_FAILED;
 
-	return OOM_FAILED;
+	if (locked)
+		mem_cgroup_oom_unlock(memcg);
+
+	return ret;
 }
 
 /**
-- 
2.19.2
