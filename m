Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id B60576B0071
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:50:20 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so17375859pde.12
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 06:50:20 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ew2si35848596pdb.190.2014.12.29.06.50.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 29 Dec 2014 06:50:17 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHC00IQEMQF2C30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 29 Dec 2014 14:54:15 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [RFC PATCH 4/4] mm/slab: use kstrdup_const for allocating cache names
Date: Mon, 29 Dec 2014 15:48:30 +0100
Message-id: <1419864510-24834-5-git-send-email-a.hajda@samsung.com>
In-reply-to: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
References: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

slab frequently performs duplication of strings located
in read-only memory section. Replacing kstrdup by kstrdup_const
allows to avoid such operations.

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 mm/slab_common.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index e03dd6f..2d94d1a 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -390,7 +390,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 	if (s)
 		goto out_unlock;
 
-	cache_name = kstrdup(name, GFP_KERNEL);
+	cache_name = kstrdup_const(name, GFP_KERNEL);
 	if (!cache_name) {
 		err = -ENOMEM;
 		goto out_unlock;
@@ -401,7 +401,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 				 flags, ctor, NULL, NULL);
 	if (IS_ERR(s)) {
 		err = PTR_ERR(s);
-		kfree(cache_name);
+		kfree_const(cache_name);
 	}
 
 out_unlock:
@@ -494,7 +494,7 @@ static int memcg_cleanup_cache_params(struct kmem_cache *s)
 
 void slab_kmem_cache_release(struct kmem_cache *s)
 {
-	kfree(s->name);
+	kfree_const(s->name);
 	kmem_cache_free(kmem_cache, s);
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
