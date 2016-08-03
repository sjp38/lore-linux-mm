Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3256B025F
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 06:35:19 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q62so423428518oih.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 03:35:19 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0094.outbound.protection.outlook.com. [104.47.1.94])
        by mx.google.com with ESMTPS id h67si4097115oia.97.2016.08.03.03.35.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Aug 2016 03:35:17 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v3 3/3] mm: memcontrol: add sanity checks for memcg->id.ref on get/put
Date: Wed, 3 Aug 2016 13:35:08 +0300
Message-ID: <1c5ddb1c171dbdfc3262252769d6138a29b35b70.1470219853.git.vdavydov@virtuozzo.com>
In-Reply-To: <5336daa5c9a32e776067773d9da655d2dc126491.1470219853.git.vdavydov@virtuozzo.com>
References: <5336daa5c9a32e776067773d9da655d2dc126491.1470219853.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
Changes in v3:
 - move memcg->id.ref initialization to mem_cgroup_css_online to make the code
   easier to follow (Johannes)

 mm/memcontrol.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18db8a490a93..1c0aa59fd333 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4033,6 +4033,7 @@ static DEFINE_IDR(mem_cgroup_idr);
 
 static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
 {
+	VM_BUG_ON(atomic_read(&memcg->id.ref) <= 0);
 	atomic_add(n, &memcg->id.ref);
 }
 
@@ -4056,6 +4057,7 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
 
 static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
 {
+	VM_BUG_ON(atomic_read(&memcg->id.ref) < n);
 	if (atomic_sub_and_test(n, &memcg->id.ref)) {
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
 		memcg->id.id = 0;
@@ -4244,8 +4246,10 @@ fail:
 
 static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
 	/* Online state pins memcg ID, memcg ID pins CSS */
-	mem_cgroup_id_get(mem_cgroup_from_css(css));
+	atomic_set(&memcg->id.ref, 1);
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
