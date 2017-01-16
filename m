Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF6A06B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 02:05:25 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id f4so90169378qte.1
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 23:05:25 -0800 (PST)
Received: from sender163-mail.zoho.com (sender163-mail.zoho.com. [74.201.84.163])
        by mx.google.com with ESMTPS id 31si5466329qtz.162.2017.01.15.23.05.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 15 Jan 2017 23:05:25 -0800 (PST)
From: Kyunghwan Kwon <kwon@toanyone.net>
Subject: [PATCH] slab: add a check for the first kmem_cache not to be destroyed
Date: Mon, 16 Jan 2017 16:04:59 +0900
Message-Id: <20170116070459.43540-1-kwon@toanyone.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyunghwan Kwon <kwon@toanyone.net>

The first kmem_cache created at booting up is supposed neither mergeable
nor destroyable but was possible to destroy. So prevent it.

Signed-off-by: Kyunghwan Kwon <kwon@toanyone.net>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 1dfc209..2d30ace 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -744,7 +744,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	bool need_rcu_barrier = false;
 	int err;
 
-	if (unlikely(!s))
+	if (unlikely(!s) || s->refcount == -1)
 		return;
 
 	get_online_cpus();
-- 
2.9.3 (Apple Git-75)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
