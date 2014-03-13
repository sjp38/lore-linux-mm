Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id ED25C6B003B
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 11:06:58 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so774501lab.41
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 08:06:58 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h8si1843911lam.11.2014.03.13.08.06.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Mar 2014 08:06:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND -mm 04/12] memcg: move slab caches list/mutex init to memcg creation
Date: Thu, 13 Mar 2014 19:06:42 +0400
Message-ID: <0da16031316cf06d622e891f4afc8740c478d674.1394708827.git.vdavydov@parallels.com>
In-Reply-To: <cover.1394708827.git.vdavydov@parallels.com>
References: <cover.1394708827.git.vdavydov@parallels.com>
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
index 21974ec406bb..3659d90d5a40 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5043,8 +5043,6 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 		goto out_rmid;
 
 	memcg->kmemcg_id = memcg_id;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
-	mutex_init(&memcg->slab_caches_mutex);
 
 	/*
 	 * We couldn't have accounted to this cgroup, because it hasn't got the
@@ -5791,6 +5789,9 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
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
