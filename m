Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 944706B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 11:01:06 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so264765485ith.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 08:01:06 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0120.outbound.protection.outlook.com. [104.47.0.120])
        by mx.google.com with ESMTPS id h197si2110350oic.68.2016.08.02.08.01.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 08:01:03 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 3/3] mm: memcontrol: add sanity checks for memcg->id.ref on get/put
Date: Tue, 2 Aug 2016 18:00:50 +0300
Message-ID: <32402ace75b459c8523f5b237a62061e1df7a3b5.1470149524.git.vdavydov@virtuozzo.com>
In-Reply-To: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 67109d556a4a..32b2f33865f9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4033,6 +4033,7 @@ static DEFINE_IDR(mem_cgroup_idr);
 
 static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
 {
+	VM_BUG_ON(atomic_read(&memcg->id.ref) <= 0);
 	atomic_add(n, &memcg->id.ref);
 }
 
@@ -4056,6 +4057,7 @@ static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
 
 static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
 {
+	VM_BUG_ON(atomic_read(&memcg->id.ref) < n);
 	if (atomic_sub_and_test(n, &memcg->id.ref)) {
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
 		memcg->id.id = 0;
@@ -4176,6 +4178,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
+	atomic_set(&memcg->id.ref, 1);
 	return memcg;
 fail:
 	if (memcg->id.id > 0)
@@ -4245,7 +4248,6 @@ fail:
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
