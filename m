Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E70A68E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 19:21:10 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id ay11so28095314plb.20
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 16:21:10 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id j132si4261668pfc.84.2019.01.04.16.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 16:21:09 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v2 PATCH 4/5] mm: memcontrol: bring force_empty into default hierarchy
Date: Sat,  5 Jan 2019 08:19:19 +0800
Message-Id: <1546647560-40026-5-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org, shakeelb@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The default hierarchy doesn't support force_empty, but there are some
usecases which create and remove memcgs very frequently, and the
tasks in the memcg may just access the files which are unlikely
accessed by anyone else. So, we prefer force_empty the memcg before
rmdir'ing it to reclaim the page cache so that they don't get
accumulated to incur unnecessary memory pressure. Since the memory
pressure may incur direct reclaim to harm some latency sensitive
applications.

There is another patch which introduces asynchronous memory reclaim when
offlining, but the behavior of force_empty is still needed by some
usecases which want to get the memory reclaimed immediately.  So, bring
force_empty interface in default hierarchy too.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/admin-guide/cgroup-v2.rst | 14 ++++++++++++++
 mm/memcontrol.c                         |  4 ++++
 2 files changed, 18 insertions(+)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 7bf3f12..0290c65 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1289,6 +1289,20 @@ PAGE_SIZE multiple when read back.
 	Shows pressure stall information for memory. See
 	Documentation/accounting/psi.txt for details.
 
+  memory.force_empty
+        This interface is provided to make cgroup's memory usage empty.
+        When writing anything to this
+
+        # echo 0 > memory.force_empty
+
+        the cgroup will be reclaimed and as many pages reclaimed as possible.
+
+        The typical use case for this interface is before calling rmdir().
+        Though rmdir() offlines memcg, but the memcg may still stay there due to
+        charged file caches. Some out-of-use page caches may keep charged until
+        memory pressure happens. If you want to avoid that, force_empty will be
+        useful.
+
 
 Usage Guidelines
 ~~~~~~~~~~~~~~~~
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5a13c6b..c4a7dc7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5743,6 +5743,10 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
 		.seq_show = wipe_on_offline_show,
 		.write_u64 = wipe_on_offline_write,
 	},
+	{
+		.name = "force_empty",
+		.write = mem_cgroup_force_empty_write,
+	},
 	{ }	/* terminate */
 };
 
-- 
1.8.3.1
