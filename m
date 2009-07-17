Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 42B746B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 07:08:41 -0400 (EDT)
From: Xiaotian Feng <dfeng@redhat.com>
Subject: [RFC PATCH] slub: release kobject if sysfs_create_group failed in sysfs_slab_add
Date: Fri, 17 Jul 2009 19:08:28 +0800
Message-Id: <1247828908-13921-1-git-send-email-dfeng@redhat.com>
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>
List-ID: <linux-mm.kvack.org>

In sysfs_slab_add, after kobject_init_and_add, kobject is inited and added.
Later, if sysfs_create_group fails, just simply return an error. This may
cause a memory leak. unlink and put the kobject if sysfs_create_group failed.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 mm/slub.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b9f1491..f910964 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4543,8 +4543,11 @@ static int sysfs_slab_add(struct kmem_cache *s)
 	}
 
 	err = sysfs_create_group(&s->kobj, &slab_attr_group);
-	if (err)
+	if (err) {
+		kobject_del(&s->kobj);
+		kobject_put(&s->kobj);
 		return err;
+	}
 	kobject_uevent(&s->kobj, KOBJ_ADD);
 	if (!unmergeable) {
 		/* Setup first alias */
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
