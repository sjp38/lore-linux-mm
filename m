Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id F3A016B0036
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 13:39:37 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id l4so638861lbv.19
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 10:39:37 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id n3si15540592lae.49.2014.02.05.10.39.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Feb 2014 10:39:35 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v15 03/13] memcg: move initialization to memcg creation
Date: Wed, 5 Feb 2014 22:39:19 +0400
Message-ID: <bcb50b8fafbb284f3bfcbf083630aa38154faf16.1391624021.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391624021.git.vdavydov@parallels.com>
References: <cover.1391624021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

Those structures are only used for memcgs that are effectively using
kmemcg. However, in a later patch I intend to use scan that list
inconditionally (list empty meaning no kmem caches present), which
simplifies the code a lot.

So move the initialization to early kmem creation.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9d1245dc993a..deb5b9bb6188 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5210,8 +5210,6 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 		goto out_rmid;
 
 	memcg->kmemcg_id = memcg_id;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
-	mutex_init(&memcg->slab_caches_mutex);
 
 	/*
 	 * We couldn't have accounted to this cgroup, because it hasn't got the
@@ -5958,6 +5956,9 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
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
