Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8CB6B0036
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 04:57:08 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so2940896pbc.30
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 01:57:07 -0700 (PDT)
Message-ID: <5240023D.6040606@huawei.com>
Date: Mon, 23 Sep 2013 16:56:29 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v6 3/5] memcg: fail to create cgroup if the cgroup id is too
 big
References: <524001F8.6070205@huawei.com>
In-Reply-To: <524001F8.6070205@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA
 Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

memcg requires the cgroup id to be smaller than 65536.

This is a preparation to kill css id.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6719e2c..4e40ebe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -498,6 +498,12 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 	return (memcg == root_mem_cgroup);
 }
 
+/*
+ * We restrict the id in the range of [1, 65535], so it can fit into
+ * an unsigned short.
+ */
+#define MEM_CGROUP_ID_MAX	USHRT_MAX
+
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
 	/*
@@ -6312,6 +6318,9 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(css));
 	int error = 0;
 
+	if (css->cgroup->id > MEM_CGROUP_ID_MAX)
+		return -ENOSPC;
+
 	if (!parent)
 		return 0;
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
