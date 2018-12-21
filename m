Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 811C88E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:33:06 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c34so6246851edb.8
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 07:33:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6-v6si1255180ejo.242.2018.12.21.07.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 07:33:05 -0800 (PST)
Date: Fri, 21 Dec 2018 16:33:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM notification for cgroupsv1 broken in 4.19
Message-ID: <20181221153302.GB6410@dhcp22.suse.cz>
References: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Burt Holzman <burt@fnal.gov>
Cc: "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri 21-12-18 14:49:38, Burt Holzman wrote:
> Hi,
> 
> This patch: 29ef680ae7c21110af8e6416d84d8a72fc147b14
> [PATCH] memcg, oom: move out_of_memory back to the charge path
> 
> has broken the eventfd notification for cgroups-v1. This is because 
> mem_cgroup_oom_notify() is called only in mem_cgroup_oom_synchronize and 
> not with the new, additional call to mem_cgroup_out_of_memory in the 
> charge path.

Yes, you are right and this is a clear regression. Does the following
patch fixes the issue for you? I am not super happy about the code
duplication but I wasn't able to separate this out from
mem_cgroup_oom_synchronize because that one has to handle the oom_killer
disabled case which is not the case in the charge path because we simply
back off and hand over to mem_cgroup_oom_synchronize in that case.
---
>From 51633f683173013741f4d0ab3e31bae575341c55 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Fri, 21 Dec 2018 16:28:29 +0100
Subject: [PATCH] memcg, oom: notify on oom killer invocation from the charge
 path

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
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
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

-- 
Michal Hocko
SUSE Labs
