Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id DEADB6B0031
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 11:33:59 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id pv20so4766821lab.16
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 08:33:58 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e10si8941608laa.11.2014.02.02.08.33.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Feb 2014 08:33:57 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/8] memcg: export kmemcg cache id via cgroup fs
Date: Sun, 2 Feb 2014 20:33:46 +0400
Message-ID: <570a97e4dfaded0939a9ddbea49055019dcc5803.1391356789.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391356789.git.vdavydov@parallels.com>
References: <cover.1391356789.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Per-memcg kmem caches are named as follows:

  <global-cache-name>(<cgroup-kmem-id>:<cgroup-name>)

where <cgroup-kmem-id> is the unique id of the memcg the cache belongs
to, <cgroup-name> is the relative name of the memcg on the cgroup fs.
Cache names are exposed to userspace for debugging purposes (e.g. via
sysfs in case of slub or via dmesg).

Using relative names makes it impossible in general (in case the cgroup
hierarchy is not flat) to find out which memcg a particular cache
belongs to, because <cgroup-kmem-id> is not known to the user. Since
using absolute cgroup names would be an overkill, let's fix this by
exporting the id of kmem-active memcg via cgroup fs file
"memory.kmem.id".

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 53385cd4e6f0..91d242707404 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3113,6 +3113,14 @@ int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
+static s64 mem_cgroup_cache_id_read(struct cgroup_subsys_state *css,
+				    struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return memcg_can_account_kmem(memcg) ? memcg_cache_id(memcg) : -1;
+}
+
 static size_t memcg_caches_array_size(int num_groups)
 {
 	ssize_t size;
@@ -6301,6 +6309,10 @@ static struct cftype mem_cgroup_files[] = {
 #endif
 #ifdef CONFIG_MEMCG_KMEM
 	{
+		.name = "kmem.id",
+		.read_s64 = mem_cgroup_cache_id_read,
+	},
+	{
 		.name = "kmem.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
 		.write_string = mem_cgroup_write,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
