Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 368E96B004D
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 23:28:57 -0400 (EDT)
From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] slub: release kobject if sysfs_create_group failed in sysfs_slab_add
Date: Wed, 22 Jul 2009 11:28:53 +0800
Message-Id: <1248233333-22563-1-git-send-email-dfeng@redhat.com>
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel.vger.kernel.org@redhat.com, Xiaotian Feng <dfeng@redhat.com>
List-ID: <linux-mm.kvack.org>

When CONFIG_SLUB_DEBUG is enabled, sysfs_slab_add should unlink and put the
kobject if sysfs_create_group failed. Otherwise, sysfs_slab_add returns error
then free kmem_cache s, thus memory of s->kobj is leaked.

Acked-by: Christoph Lameter <cl@linux-foundation.org>
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
