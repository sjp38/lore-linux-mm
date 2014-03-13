Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 061546B0062
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 11:07:05 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id u14so778442lbd.19
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 08:07:05 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g7si958411lab.40.2014.03.13.08.07.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Mar 2014 08:07:04 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND -mm 12/12] slub: make sure all memcg caches have unique names on sysfs
Date: Thu, 13 Mar 2014 19:06:50 +0400
Message-ID: <060fdfeb4dc2b2aa49ff84599ba8e70d49b45688.1394708827.git.vdavydov@parallels.com>
In-Reply-To: <cover.1394708827.git.vdavydov@parallels.com>
References: <cover.1394708827.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

Since memcg caches are now reparented on memcg offline, a memcg cache
can outlive its cgroup. If the memcg id is then reused for a new cgroup
with the same name, we can get cache name collision, which will result
in failures while trying to add a sysfs entry for a new cgroup's cache.
Let's fix this by appending the cache address to sysfs names of all
memcg caches so that they are guaranteed to have unique names.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
---
 mm/slub.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 3ea91fb54f41..f5c74daeb46d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5236,7 +5236,18 @@ static int sysfs_slab_add(struct kmem_cache *s)
 	}
 
 	s->kobj.kset = cache_kset(s);
-	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, "%s", name);
+	/*
+	 * A memcg cache can outlive its cgroup. If the memcg id is then reused
+	 * for a new cgroup with the same name, we can get cache name
+	 * collision. To make sure all memcg caches have unique names on sysfs,
+	 * we append the cache address to its name.
+	 */
+	if (is_root_cache(s))
+		err = kobject_init_and_add(&s->kobj, &slab_ktype,
+					   NULL, "%s", name);
+	else
+		err = kobject_init_and_add(&s->kobj, &slab_ktype,
+					   NULL, "%s-%p", name, s);
 	if (err)
 		goto out_put_kobj;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
