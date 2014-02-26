Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0309B6B00A8
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:05:37 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id e16so491962lan.30
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:05:37 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id zd10si1822488lbb.99.2014.02.26.07.05.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:05:36 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 04/12] memcg: move slab caches list/mutex init to memcg creation
Date: Wed, 26 Feb 2014 19:05:09 +0400
Message-ID: <0bd569d6a70e144d39f6749b5592803ee666367f.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
References: <cover.1393423762.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

I need them initialized for cgroups that haven't got kmem accounting
initialized.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
---
 mm/memcontrol.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1b9634090454..69431f5285cc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5122,8 +5122,6 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 		goto out_rmid;
 
 	memcg->kmemcg_id = memcg_id;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
-	mutex_init(&memcg->slab_caches_mutex);
 
 	/*
 	 * We couldn't have accounted to this cgroup, because it hasn't got the
@@ -5870,6 +5868,9 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	int ret;
 
 	memcg->kmemcg_id = -1;
+	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+	mutex_init(&memcg->slab_caches_mutex);
+
 	ret = memcg_propagate_kmem(memcg);
 	if (ret)
 		return ret;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
