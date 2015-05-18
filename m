Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2506B0070
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:50:05 -0400 (EDT)
Received: by qkgw4 with SMTP id w4so76329580qkg.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:05 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id t4si519202qcf.14.2015.05.18.12.50.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:50:04 -0700 (PDT)
Received: by qgew3 with SMTP id w3so47391413qge.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:04 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/7] memcg: immigrate charges only when a threadgroup leader is moved
Date: Mon, 18 May 2015 15:49:51 -0400
Message-Id: <1431978595-12176-4-git-send-email-tj@kernel.org>
In-Reply-To: <1431978595-12176-1-git-send-email-tj@kernel.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

If move_charge flag is set, memcg tries to move memory charges to the
destnation css.  The current implementation migrates memory whenever
any thread of a process is migrated making the behavior somewhat
arbitrary.  Let's tie memory operations to the threadgroup leader so
that memory is migrated only when the leader is migrated.

While this is a behavior change, given the inherent fuziness, this
change is not too likely to be noticed and allows us to clearly define
who owns the memory (always the leader) and helps the planned atomic
multi-process migration.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b1b834d..74fcea3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5014,6 +5014,9 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 		return 0;
 
 	p = cgroup_taskset_first(tset);
+	if (!thread_group_leader(p))
+		return 0;
+
 	from = mem_cgroup_from_task(p);
 
 	VM_BUG_ON(from == memcg);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
