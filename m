Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1FAE96B026C
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 08:30:29 -0400 (EDT)
Received: by mail-qk0-f171.google.com with SMTP id i4so37189535qkc.3
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 05:30:29 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0093.outbound.protection.outlook.com. [104.47.1.93])
        by mx.google.com with ESMTPS id u82si11780707qhu.121.2016.04.01.05.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 05:30:27 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: slub: replace kick_all_cpus_sync with synchronize_sched in kmem_cache_shrink
Date: Fri, 1 Apr 2016 15:30:17 +0300
Message-ID: <1459513817-11853-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When we call __kmem_cache_shrink on memory cgroup removal, we need to
synchronize kmem_cache->cpu_partial update with put_cpu_partial that
might be running on other cpus. Currently, we achieve that by using
kick_all_cpus_sync, which works as a system wide memory barrier. Though
fast it is, this method has a flow - it issues a lot of IPIs, which
might hurt high performance or real-time workloads.

To fix this, let's replace kick_all_cpus_sync with synchronize_sched.
Although the latter one may take much longer to finish, it shouldn't be
a problem in this particular case, because memory cgroups are destroyed
asynchronously from a workqueue so that no user visible effects should
be introduced. OTOH, it will save us from excessive IPIs when someone
removes a cgroup.

Anyway, even if using synchronize_sched turns out to take too long, we
can always introduce a kind of __kmem_cache_shrink batching so that this
method would only be called once per one cgroup destruction (not per
each per memcg kmem cache as it is now).

Reported-and-suggested-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 279e773d80d3..03067f43dcf4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3697,7 +3697,7 @@ int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
 		 * s->cpu_partial is checked locklessly (see put_cpu_partial),
 		 * so we have to make sure the change is visible.
 		 */
-		kick_all_cpus_sync();
+		synchronize_sched();
 	}
 
 	flush_all(s);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
