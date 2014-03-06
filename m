Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id DE13B6B0035
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:11:53 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id a15so1939427eae.37
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:11:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s46si12045392eeg.120.2014.03.06.13.11.51
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 13:11:52 -0800 (PST)
Date: Thu, 6 Mar 2014 16:11:41 -0500
From: Dave Jones <davej@redhat.com>
Subject: slub: fix leak of 'name' in sysfs_slab_add
Message-ID: <20140306211141.GA17009@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, cl@linux-foundation.org, penberg@kernel.org

The failure paths of sysfs_slab_add don't release the allocation of 'name'
made by create_unique_id() a few lines above the context of the diff below.
Create a common exit path to make it more obvious what needs freeing.

Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/mm/slub.c b/mm/slub.c
index 25f14ad8f817..b2181d2682ac 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5197,17 +5197,13 @@ static int sysfs_slab_add(struct kmem_cache *s)
 
 	s->kobj.kset = slab_kset;
 	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, "%s", name);
-	if (err) {
-		kobject_put(&s->kobj);
-		return err;
-	}
+	if (err)
+		goto err_out;
 
 	err = sysfs_create_group(&s->kobj, &slab_attr_group);
-	if (err) {
-		kobject_del(&s->kobj);
-		kobject_put(&s->kobj);
-		return err;
-	}
+	if (err)
+		goto err_sysfs;
+
 	kobject_uevent(&s->kobj, KOBJ_ADD);
 	if (!unmergeable) {
 		/* Setup first alias */
@@ -5215,6 +5211,13 @@ static int sysfs_slab_add(struct kmem_cache *s)
 		kfree(name);
 	}
 	return 0;
+
+err_sysfs:
+	kobject_del(&s->kobj);
+err_out:
+	kobject_put(&s->kobj);
+	kfree(name);
+	return err;
 }
 
 static void sysfs_slab_remove(struct kmem_cache *s)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
