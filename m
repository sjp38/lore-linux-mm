Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 835136B0260
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:56:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so2918219wme.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:56:34 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id g19si1625645wmc.137.2016.08.12.02.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 02:56:30 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i138so1906777wmf.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:56:29 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-4.4 3/3] mm: memcontrol: fix memcg id ref counter on swap charge move
Date: Fri, 12 Aug 2016 11:56:19 +0200
Message-Id: <1470995779-10064-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1470995779-10064-1-git-send-email-mhocko@kernel.org>
References: <1470995779-10064-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Vladimir Davydov <vdavydov@virtuozzo.com>

commit 615d66c37c755c49ce022c9e5ac0875d27d2603d upstream.

Since commit 73f576c04b94 ("mm: memcontrol: fix cgroup creation failure
after many small jobs") swap entries do not pin memcg->css.refcnt
directly.  Instead, they pin memcg->id.ref.  So we should adjust the
reference counters accordingly when moving swap charges between cgroups.

Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
Link: http://lkml.kernel.org/r/9ce297c64954a42dc90b543bc76106c4a94f07e8.1470219853.git.vdavydov@virtuozzo.com
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org>	[3.19+]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dd6e2d24d9b1..d3e6e4fa61b8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4136,9 +4136,9 @@ static struct cftype mem_cgroup_legacy_files[] = {
 
 static DEFINE_IDR(mem_cgroup_idr);
 
-static void mem_cgroup_id_get(struct mem_cgroup *memcg)
+static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
 {
-	atomic_inc(&memcg->id.ref);
+	atomic_add(n, &memcg->id.ref);
 }
 
 static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
@@ -4159,9 +4159,9 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
 	return memcg;
 }
 
-static void mem_cgroup_id_put(struct mem_cgroup *memcg)
+static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
 {
-	if (atomic_dec_and_test(&memcg->id.ref)) {
+	if (atomic_sub_and_test(n, &memcg->id.ref)) {
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
 		memcg->id.id = 0;
 
@@ -4170,6 +4170,16 @@ static void mem_cgroup_id_put(struct mem_cgroup *memcg)
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
@@ -4856,6 +4866,8 @@ static void __mem_cgroup_clear_mc(void)
 		if (!mem_cgroup_is_root(mc.from))
 			page_counter_uncharge(&mc.from->memsw, mc.moved_swap);
 
+		mem_cgroup_id_put_many(mc.from, mc.moved_swap);
+
 		/*
 		 * we charged both to->memory and to->memsw, so we
 		 * should uncharge to->memory.
@@ -4863,9 +4875,9 @@ static void __mem_cgroup_clear_mc(void)
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
