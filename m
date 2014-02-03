Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD206B0038
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 10:54:48 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id l4so5367807lbv.24
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 07:54:48 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ml5si10645965lbc.140.2014.02.03.07.54.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 07:54:47 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 6/7] slub: adjust memcg caches when creating cache alias
Date: Mon, 3 Feb 2014 19:54:41 +0400
Message-ID: <83029acb31807645496a6ccb826a6af7bb56e259.1391441746.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391441746.git.vdavydov@parallels.com>
References: <cover.1391441746.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Otherwise, kzalloc() called from a memcg won't clear the whole object.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 8659e7184338..f3d2ef725ed6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3743,7 +3743,11 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
+		int i;
+		struct kmem_cache *c;
+
 		s->refcount++;
+
 		/*
 		 * Adjust the object sizes so that we clear
 		 * the complete object on kzalloc.
@@ -3751,6 +3755,16 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 		s->object_size = max(s->object_size, (int)size);
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 
+		BUG_ON(!is_root_cache(s));
+		for_each_memcg_cache_index(i) {
+			c = cache_from_memcg_idx(s, i);
+			if (!c)
+				continue;
+			c->object_size = s->object_size;
+			c->inuse = max_t(int, c->inuse,
+					 ALIGN(size, sizeof(void *)));
+		}
+
 		if (sysfs_slab_alias(s, name)) {
 			s->refcount--;
 			s = NULL;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
