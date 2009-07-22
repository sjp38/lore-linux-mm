Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7167B6B005A
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 05:04:09 -0400 (EDT)
From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] slub: sysfs_slab_remove should free kmem_cache when debug is enabled
Date: Wed, 22 Jul 2009 17:03:57 +0800
Message-Id: <1248253437-23313-1-git-send-email-dfeng@redhat.com>
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi, cl@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>
List-ID: <linux-mm.kvack.org>

kmem_cache_destroy use sysfs_slab_remove to release the kmem_cache,
but when CONFIG_SLUB_DEBUG is enabled, sysfs_slab_remove just release
related kobject, the whole kmem_cache is missed to release and cause
a memory leak.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 mm/slub.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b9f1491..05b69fd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4559,6 +4559,7 @@ static void sysfs_slab_remove(struct kmem_cache *s)
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);
+	kfree(s);
 }
 
 /*
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
