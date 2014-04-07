Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2F86B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 06:50:12 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id q8so4696301lbi.28
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 03:50:11 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id pw3si11928976lbb.169.2014.04.07.03.50.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Apr 2014 03:50:10 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] slub: fix memcg_propagate_slab_attrs
Date: Mon, 7 Apr 2014 14:50:07 +0400
Message-ID: <1396867807-22824-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

After creating a cache for a memcg we should initialize its sysfs attrs
with the values from its parent. That's what memcg_propagate_slab_attrs
is for. Currently it's broken - we clearly muddled root-vs-memcg caches
there. Let's fix it up.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 09660b9ff5bd..9fc144f9a542 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5070,15 +5070,18 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 #ifdef CONFIG_MEMCG_KMEM
 	int i;
 	char *buffer = NULL;
+	struct kmem_cache *root_cache;
 
-	if (!is_root_cache(s))
+	if (is_root_cache(s))
 		return;
 
+	root_cache = s->memcg_params->root_cache;
+
 	/*
 	 * This mean this cache had no attribute written. Therefore, no point
 	 * in copying default values around
 	 */
-	if (!s->max_attr_size)
+	if (!root_cache->max_attr_size)
 		return;
 
 	for (i = 0; i < ARRAY_SIZE(slab_attrs); i++) {
@@ -5100,7 +5103,7 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 		 */
 		if (buffer)
 			buf = buffer;
-		else if (s->max_attr_size < ARRAY_SIZE(mbuf))
+		else if (root_cache->max_attr_size < ARRAY_SIZE(mbuf))
 			buf = mbuf;
 		else {
 			buffer = (char *) get_zeroed_page(GFP_KERNEL);
@@ -5109,7 +5112,7 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 			buf = buffer;
 		}
 
-		attr->show(s->memcg_params->root_cache, buf);
+		attr->show(root_cache, buf);
 		attr->store(s, buf, strlen(buf));
 	}
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
