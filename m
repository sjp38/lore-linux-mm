Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 5574A6B0039
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 21:52:57 -0400 (EDT)
Message-ID: <51F86DDD.3030809@huawei.com>
Date: Wed, 31 Jul 2013 09:52:29 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v4 6/8] memcg: fail to create cgroup if the cgroup id is too
 big
References: <51F86D69.2030907@huawei.com>
In-Reply-To: <51F86D69.2030907@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

memcg requires the cgroup id to be smaller than 65536.

This is a preparation to kill css id.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 62541f5..ad7d7c9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -512,6 +512,12 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
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
@@ -6248,6 +6254,9 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 	long error = -ENOMEM;
 	int node;
 
+	if (cont->id > MEM_CGROUP_ID_MAX)
+		return ERR_PTR(-ENOSPC);
+
 	memcg = mem_cgroup_alloc();
 	if (!memcg)
 		return ERR_PTR(error);
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
