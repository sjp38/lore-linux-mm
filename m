Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64C94828E2
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 09:26:35 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d65so10737524ith.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:26:35 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0093.outbound.protection.outlook.com. [104.47.1.93])
        by mx.google.com with ESMTPS id d124si19412646oig.35.2016.08.01.06.26.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 06:26:33 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 3/3] mm: memcontrol: add sanity checks for memcg->id.ref on get/put
Date: Mon, 1 Aug 2016 16:26:26 +0300
Message-ID: <ad702144f24374cbfb3a35b71658a0ae24ba7d84.1470057819.git.vdavydov@virtuozzo.com>
In-Reply-To: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
References: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 58c229071fb1..cf7fb63860e5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4032,18 +4032,22 @@ static DEFINE_IDR(mem_cgroup_idr);
 
 static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
 {
+	VM_BUG_ON(atomic_read(&memcg->id.ref) <= 0);
 	atomic_add(n, &memcg->id.ref);
 }
 
 static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
 {
-	while (!atomic_inc_not_zero(&memcg->id.ref))
+	while (!atomic_inc_not_zero(&memcg->id.ref)) {
+		VM_BUG_ON(mem_cgroup_is_root(memcg));
 		memcg = parent_mem_cgroup(memcg);
+	}
 	return memcg;
 }
 
 static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
 {
+	VM_BUG_ON(atomic_read(&memcg->id.ref) < n);
 	if (atomic_sub_and_test(n, &memcg->id.ref)) {
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
 		memcg->id.id = 0;
@@ -4164,6 +4168,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
+	atomic_set(&memcg->id.ref, 1);
 	return memcg;
 fail:
 	if (memcg->id.id > 0)
@@ -4233,7 +4238,6 @@ fail:
 static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	/* Online state pins memcg ID, memcg ID pins CSS */
-	mem_cgroup_id_get(mem_cgroup_from_css(css));
 	css_get(css);
 	return 0;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
