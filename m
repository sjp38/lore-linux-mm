Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9549D6B003C
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 11:34:02 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id hr13so4776565lab.15
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 08:34:01 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ya3si8934419lbb.71.2014.02.02.08.33.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Feb 2014 08:33:59 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 5/8] slub: adjust memcg caches when creating cache alias
Date: Sun, 2 Feb 2014 20:33:50 +0400
Message-ID: <d41c465b8d746f575a4a6ae0edf524d391387e02.1391356789.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391356789.git.vdavydov@parallels.com>
References: <cover.1391356789.git.vdavydov@parallels.com>
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
index 962abfdfde06..a33d88afb61d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3737,7 +3737,11 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 
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
@@ -3745,6 +3749,16 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
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
