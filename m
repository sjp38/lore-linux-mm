Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A678E6B0071
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:20:16 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so30982744pad.13
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:20:16 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ag17si22620298pac.113.2015.01.12.01.20.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 12 Jan 2015 01:20:15 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI200KP94SIA630@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Jan 2015 09:24:18 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 4/5] mm/slab: convert cache name allocations to kstrdup_const
Date: Mon, 12 Jan 2015 10:18:42 +0100
Message-id: <1421054323-14430-5-git-send-email-a.hajda@samsung.com>
In-reply-to: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

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
