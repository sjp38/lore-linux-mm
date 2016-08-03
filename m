Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9516B025E
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 06:35:17 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n69so436606985ion.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 03:35:17 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0094.outbound.protection.outlook.com. [104.47.1.94])
        by mx.google.com with ESMTPS id h67si4097115oia.97.2016.08.03.03.35.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Aug 2016 03:35:16 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v3 2/3] mm: memcontrol: fix memcg id ref counter on swap charge move
Date: Wed, 3 Aug 2016 13:35:07 +0300
Message-ID: <9ce297c64954a42dc90b543bc76106c4a94f07e8.1470219853.git.vdavydov@virtuozzo.com>
In-Reply-To: <5336daa5c9a32e776067773d9da655d2dc126491.1470219853.git.vdavydov@virtuozzo.com>
References: <5336daa5c9a32e776067773d9da655d2dc126491.1470219853.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit 73f576c04b941 swap entries do not pin memcg->css.refcnt
directly. Instead, they pin memcg->id.ref. So we should adjust the
reference counters accordingly when moving swap charges between cgroups.

Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org>	[3.19+]
---
 mm/memcontrol.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5be9a6ca7540..18db8a490a93 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4031,9 +4031,9 @@ static struct cftype mem_cgroup_legacy_files[] = {
 
 static DEFINE_IDR(mem_cgroup_idr);
 
-static void mem_cgroup_id_get(struct mem_cgroup *memcg)
+static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
 {
-	atomic_inc(&memcg->id.ref);
+	atomic_add(n, &memcg->id.ref);
 }
 
 static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
@@ -4054,9 +4054,9 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
 	return memcg;
 }
 
-static void mem_cgroup_id_put(struct mem_cgroup *memcg)
+static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
 {
-	if (atomic_dec_and_test(&memcg->id.ref)) {
+	if (atomic_sub_and_test(n, &memcg->id.ref)) {
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
 		memcg->id.id = 0;
 
@@ -4065,6 +4065,16 @@ static void mem_cgroup_id_put(struct mem_cgroup *memcg)
 	}
 }
 
+static inline void mem_cgroup_id_get(struct mem_cgroup *memcg)
+{
+	mem_cgroup_id_get_many(memcg, 1);
+}
+
+static inline void mem_cgroup_id_put(struct mem_cgroup *memcg)
+{
+	mem_cgroup_id_put_many(memcg, 1);
+}
+
 /**
  * mem_cgroup_from_id - look up a memcg from a memcg id
  * @id: the memcg id to look up
@@ -4699,6 +4709,8 @@ static void __mem_cgroup_clear_mc(void)
 		if (!mem_cgroup_is_root(mc.from))
 			page_counter_uncharge(&mc.from->memsw, mc.moved_swap);
 
+		mem_cgroup_id_put_many(mc.from, mc.moved_swap);
+
 		/*
 		 * we charged both to->memory and to->memsw, so we
 		 * should uncharge to->memory.
@@ -4706,9 +4718,9 @@ static void __mem_cgroup_clear_mc(void)
 		if (!mem_cgroup_is_root(mc.to))
 			page_counter_uncharge(&mc.to->memory, mc.moved_swap);
 
-		css_put_many(&mc.from->css, mc.moved_swap);
+		mem_cgroup_id_get_many(mc.to, mc.moved_swap);
+		css_put_many(&mc.to->css, mc.moved_swap);
 
-		/* we've already done css_get(mc.to) */
 		mc.moved_swap = 0;
 	}
 	memcg_oom_recover(from);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
