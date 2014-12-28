Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD786B0038
	for <linux-mm@kvack.org>; Sun, 28 Dec 2014 11:19:30 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so15740307pdj.27
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 08:19:30 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dl1si10330264pbb.67.2014.12.28.08.19.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Dec 2014 08:19:28 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [RFC PATCH 2/2] memcg: add memory and swap knobs to the default cgroup hierarchy
Date: Sun, 28 Dec 2014 19:19:13 +0300
Message-ID: <9aeed65ee700e81abde90c20570415a40acb36e2.1419782051.git.vdavydov@parallels.com>
In-Reply-To: <dd99dc0de2ce6fd9aa18b25851819b71a58dca7d.1419782051.git.vdavydov@parallels.com>
References: <dd99dc0de2ce6fd9aa18b25851819b71a58dca7d.1419782051.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

This patch adds the following files to the default cgroup hierarchy:

  memory.usage:         read memory usage
  memory.limit:         read/set memory limit
  memory.swap.usage:    read swap usage
  memory.swap.limit:    read/set swap limit

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 63 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6b5eaa399b23..bd962c116003 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -430,6 +430,10 @@ enum res_type {
 	_MEMSWAP,
 	_OOM_TYPE,
 	_KMEM,
+
+	/* unified hierarchy resources */
+	_DFL_MEM,
+	_DFL_SWAP,
 };
 
 #define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
@@ -3405,14 +3409,17 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct page_counter *counter;
+	unsigned long nr_pages;
 	int type;
 
 	type = MEMFILE_TYPE(cft->private);
 	switch (type) {
 	case _MEM:
+	case _DFL_MEM:
 		counter = &memcg->memory;
 		break;
 	case _MEMSWAP:
+	case _DFL_SWAP:
 		counter = &memcg->swap;
 		break;
 	case _KMEM:
@@ -3424,11 +3431,21 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 
 	switch (MEMFILE_ATTR(cft->private)) {
 	case RES_USAGE:
-		if (type == _MEM)
-			return mem_cgroup_usage(memcg, false);
 		if (type == _MEMSWAP)
 			return mem_cgroup_usage(memcg, true);
-		return (u64)page_counter_read(counter) * PAGE_SIZE;
+		switch (type) {
+		case _MEM:
+		case _DFL_MEM:
+			nr_pages = read_memory_usage(memcg);
+			break;
+		case _DFL_SWAP:
+			nr_pages = read_swap_usage(memcg);
+			break;
+		default:
+			nr_pages = page_counter_read(counter);
+			break;
+		}
+		return (u64)nr_pages * PAGE_SIZE;
 	case RES_LIMIT:
 		if (type == _MEMSWAP)
 			return min((u64)PAGE_COUNTER_MAX,
@@ -3577,6 +3594,12 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 		case _KMEM:
 			ret = resize_kmem_limit(memcg, nr_pages);
 			break;
+		case _DFL_MEM:
+			ret = resize_memory_limit(memcg, nr_pages);
+			break;
+		case _DFL_SWAP:
+			ret = resize_swap_limit(memcg, nr_pages);
+			break;
 		}
 		mutex_unlock(&memcg_limit_mutex);
 		break;
@@ -4420,7 +4443,7 @@ out_kfree:
 	return ret;
 }
 
-static struct cftype mem_cgroup_files[] = {
+static struct cftype legacy_mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
@@ -4531,6 +4554,21 @@ static struct cftype mem_cgroup_files[] = {
 	{ },	/* terminate */
 };
 
+static struct cftype mem_cgroup_files[] = {
+	{
+		.name = "usage",
+		.private = MEMFILE_PRIVATE(_DFL_MEM, RES_USAGE),
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "limit",
+		.private = MEMFILE_PRIVATE(_DFL_MEM, RES_LIMIT),
+		.write = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{ },	/* terminate */
+};
+
 #ifdef CONFIG_MEMCG_SWAP
 static struct cftype memsw_cgroup_files[] = {
 	{
@@ -4558,6 +4596,21 @@ static struct cftype memsw_cgroup_files[] = {
 	},
 	{ },	/* terminate */
 };
+
+static struct cftype swap_cgroup_files[] = {
+	{
+		.name = "swap.usage",
+		.private = MEMFILE_PRIVATE(_DFL_SWAP, RES_USAGE),
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
+		.name = "swap.limit",
+		.private = MEMFILE_PRIVATE(_DFL_SWAP, RES_LIMIT),
+		.write = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{ },	/* terminate */
+};
 #endif
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
@@ -5433,7 +5486,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
 	.bind = mem_cgroup_bind,
-	.legacy_cftypes = mem_cgroup_files,
+	.dfl_cftypes = mem_cgroup_files,
+	.legacy_cftypes = legacy_mem_cgroup_files,
 	.early_init = 0,
 };
 
@@ -5448,8 +5502,10 @@ static int __init enable_swap_account(char *s)
 }
 __setup("swapaccount=", enable_swap_account);
 
-static void __init memsw_file_init(void)
+static void __init swap_cgroup_file_init(void)
 {
+	WARN_ON(cgroup_add_dfl_cftypes(&memory_cgrp_subsys,
+				       swap_cgroup_files));
 	WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys,
 					  memsw_cgroup_files));
 }
@@ -5458,7 +5514,7 @@ static void __init enable_swap_cgroup(void)
 {
 	if (!mem_cgroup_disabled() && really_do_swap_account) {
 		do_swap_account = 1;
-		memsw_file_init();
+		swap_cgroup_file_init();
 	}
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
