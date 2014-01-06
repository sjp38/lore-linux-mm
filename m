Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1BA6B0036
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 03:45:32 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id w7so9585375lbi.38
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 00:45:31 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si35743947laz.50.2014.01.06.00.45.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 00:45:30 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 08/11] slab: do not panic if we fail to create memcg cache
Date: Mon, 6 Jan 2014 12:44:59 +0400
Message-ID: <29a9a13bff7912fe9e9bedaba3601bcc785c6180.1388996525.git.vdavydov@parallels.com>
In-Reply-To: <cover.1388996525.git.vdavydov@parallels.com>
References: <cover.1388996525.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

There is no point in flooding logs with warnings or especially crashing
the system if we fail to create a cache for a memcg. In this case we
will be accounting the memcg allocation to the root cgroup until we
succeed to create its own cache, but it isn't that critical.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab_common.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index f34707e..8e40321 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -233,7 +233,14 @@ out_unlock:
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 
-	if (err) {
+	/*
+	 * There is no point in flooding logs with warnings or especially
+	 * crashing the system if we fail to create a cache for a memcg. In
+	 * this case we will be accounting the memcg allocation to the root
+	 * cgroup until we succeed to create its own cache, but it isn't that
+	 * critical.
+	 */
+	if (err && !memcg) {
 		if (flags & SLAB_PANIC)
 			panic("kmem_cache_create: Failed to create slab '%s'. Error %d\n",
 				name, err);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
