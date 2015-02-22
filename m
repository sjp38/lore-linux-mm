Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3D91A6B0070
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 13:32:21 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so20070950pdb.9
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 10:32:20 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id zs7si45747pbc.233.2015.02.22.10.32.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 10:32:16 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 3/4] cleancache: forbid overriding cleancache_ops
Date: Sun, 22 Feb 2015 21:31:54 +0300
Message-ID: <244ef7841dfd25697164049432e0a54b3b938b19.1424628280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1424628280.git.vdavydov@parallels.com>
References: <cover.1424628280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, cleancache_register_ops returns the previous value of
cleancache_ops to allow chaining. However, chaining, as it is
implemented now, is extremely dangerous due to possible pool id
collisions. Suppose, a new cleancache driver is registered after the
previous one assigned an id to a super block. If the new driver assigns
the same id to another super block, which is perfectly possible, we will
have two different filesystems using the same id. No matter if the new
driver implements chaining or not, we are likely to get data corruption
with such a configuration eventually.

This patch therefore disables the ability to override cleancache_ops
altogether as potentially dangerous. If there is already cleancache
driver registered, all further calls to cleancache_register_ops will
return EBUSY. Since no user of cleancache implements chaining, we only
need to make minor changes to the code outside the cleancache core.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 Documentation/vm/cleancache.txt |    4 +---
 drivers/xen/tmem.c              |   16 +++++++++-------
 include/linux/cleancache.h      |    3 +--
 mm/cleancache.c                 |   12 +++++++-----
 4 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/Documentation/vm/cleancache.txt b/Documentation/vm/cleancache.txt
index 01d76282444e..e4b49df7a048 100644
--- a/Documentation/vm/cleancache.txt
+++ b/Documentation/vm/cleancache.txt
@@ -28,9 +28,7 @@ IMPLEMENTATION OVERVIEW
 A cleancache "backend" that provides transcendent memory registers itself
 to the kernel's cleancache "frontend" by calling cleancache_register_ops,
 passing a pointer to a cleancache_ops structure with funcs set appropriately.
-Note that cleancache_register_ops returns the previous settings so that
-chaining can be performed if desired. The functions provided must conform to
-certain semantics as follows:
+The functions provided must conform to certain semantics as follows:
 
 Most important, cleancache is "ephemeral".  Pages which are copied into
 cleancache have an indefinite lifetime which is completely unknowable
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 8a65423bc696..8529e535459e 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -397,13 +397,15 @@ static int __init xen_tmem_init(void)
 #ifdef CONFIG_CLEANCACHE
 	BUG_ON(sizeof(struct cleancache_filekey) != sizeof(struct tmem_oid));
 	if (tmem_enabled && cleancache) {
-		char *s = "";
-		struct cleancache_ops *old_ops =
-			cleancache_register_ops(&tmem_cleancache_ops);
-		if (old_ops)
-			s = " (WARNING: cleancache_ops overridden)";
-		pr_info("cleancache enabled, RAM provided by Xen Transcendent Memory%s\n",
-			s);
+		int err;
+		
+		err = cleancache_register_ops(&tmem_cleancache_ops);
+		if (err)
+			pr_warn("xen-tmem: failed to enable cleancache: %d\n",
+				err);
+		else
+			pr_info("cleancache enabled, RAM provided by "
+				"Xen Transcendent Memory\n");
 	}
 #endif
 #ifdef CONFIG_XEN_SELFBALLOONING
diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
index 29657d1c83fb..b23611f43cfb 100644
--- a/include/linux/cleancache.h
+++ b/include/linux/cleancache.h
@@ -33,8 +33,7 @@ struct cleancache_ops {
 	void (*invalidate_fs)(int);
 };
 
-extern struct cleancache_ops *
-	cleancache_register_ops(struct cleancache_ops *ops);
+extern int cleancache_register_ops(struct cleancache_ops *ops);
 extern void __cleancache_init_fs(struct super_block *);
 extern void __cleancache_init_shared_fs(struct super_block *);
 extern int  __cleancache_get_page(struct page *);
diff --git a/mm/cleancache.c b/mm/cleancache.c
index 532495f2e4f4..aa10f9a3bc88 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -106,15 +106,17 @@ static DEFINE_MUTEX(poolid_mutex);
  */
 
 /*
- * Register operations for cleancache, returning previous thus allowing
- * detection of multiple backends and possible nesting.
+ * Register operations for cleancache. Returns 0 on success.
  */
-struct cleancache_ops *cleancache_register_ops(struct cleancache_ops *ops)
+int cleancache_register_ops(struct cleancache_ops *ops)
 {
-	struct cleancache_ops *old = cleancache_ops;
 	int i;
 
 	mutex_lock(&poolid_mutex);
+	if (cleancache_ops) {
+		mutex_unlock(&poolid_mutex);
+		return -EBUSY;
+	}
 	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
 		if (fs_poolid_map[i] == FS_NO_BACKEND)
 			fs_poolid_map[i] = ops->init_fs(PAGE_SIZE);
@@ -130,7 +132,7 @@ struct cleancache_ops *cleancache_register_ops(struct cleancache_ops *ops)
 	barrier();
 	cleancache_ops = ops;
 	mutex_unlock(&poolid_mutex);
-	return old;
+	return 0;
 }
 EXPORT_SYMBOL(cleancache_register_ops);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
