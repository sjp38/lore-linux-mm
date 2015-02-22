Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 486516B006C
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 13:32:17 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so21831583pab.0
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 10:32:16 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id nw8si700399pdb.143.2015.02.22.10.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 10:32:15 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/4] cleancache: zap uuid arg of cleancache_init_shared_fs
Date: Sun, 22 Feb 2015 21:31:53 +0300
Message-ID: <1dff560ed464f544ca9e0b1c26ca841b0cd16b0c.1424628280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1424628280.git.vdavydov@parallels.com>
References: <cover.1424628280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use super_block->s_uuid instead. Every shared filesystem using
cleancache must now initialize super_block->s_uuid before calling
cleancache_init_shared_fs. The only one on the tree, ocfs2, already
meets this requirement.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/ocfs2/super.c           |    2 +-
 include/linux/cleancache.h |    6 +++---
 mm/cleancache.c            |    6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/ocfs2/super.c b/fs/ocfs2/super.c
index 43f5a9e71b35..18f830a9df50 100644
--- a/fs/ocfs2/super.c
+++ b/fs/ocfs2/super.c
@@ -2335,7 +2335,7 @@ static int ocfs2_initialize_super(struct super_block *sb,
 		mlog_errno(status);
 		goto bail;
 	}
-	cleancache_init_shared_fs((char *)&di->id2.i_super.s_uuid, sb);
+	cleancache_init_shared_fs(sb);
 
 bail:
 	return status;
diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
index 4ce9056b31a8..29657d1c83fb 100644
--- a/include/linux/cleancache.h
+++ b/include/linux/cleancache.h
@@ -36,7 +36,7 @@ struct cleancache_ops {
 extern struct cleancache_ops *
 	cleancache_register_ops(struct cleancache_ops *ops);
 extern void __cleancache_init_fs(struct super_block *);
-extern void __cleancache_init_shared_fs(char *, struct super_block *);
+extern void __cleancache_init_shared_fs(struct super_block *);
 extern int  __cleancache_get_page(struct page *);
 extern void __cleancache_put_page(struct page *);
 extern void __cleancache_invalidate_page(struct address_space *, struct page *);
@@ -78,10 +78,10 @@ static inline void cleancache_init_fs(struct super_block *sb)
 		__cleancache_init_fs(sb);
 }
 
-static inline void cleancache_init_shared_fs(char *uuid, struct super_block *sb)
+static inline void cleancache_init_shared_fs(struct super_block *sb)
 {
 	if (cleancache_enabled)
-		__cleancache_init_shared_fs(uuid, sb);
+		__cleancache_init_shared_fs(sb);
 }
 
 static inline int cleancache_get_page(struct page *page)
diff --git a/mm/cleancache.c b/mm/cleancache.c
index 053bcd8f12fb..532495f2e4f4 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -155,7 +155,7 @@ void __cleancache_init_fs(struct super_block *sb)
 EXPORT_SYMBOL(__cleancache_init_fs);
 
 /* Called by a cleancache-enabled clustered filesystem at time of mount */
-void __cleancache_init_shared_fs(char *uuid, struct super_block *sb)
+void __cleancache_init_shared_fs(struct super_block *sb)
 {
 	int i;
 
@@ -163,10 +163,10 @@ void __cleancache_init_shared_fs(char *uuid, struct super_block *sb)
 	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
 		if (shared_fs_poolid_map[i] == FS_UNKNOWN) {
 			sb->cleancache_poolid = i + FAKE_SHARED_FS_POOLID_OFFSET;
-			uuids[i] = uuid;
+			uuids[i] = sb->s_uuid;
 			if (cleancache_ops)
 				shared_fs_poolid_map[i] = cleancache_ops->init_shared_fs
-						(uuid, PAGE_SIZE);
+						(sb->s_uuid, PAGE_SIZE);
 			else
 				shared_fs_poolid_map[i] = FS_NO_BACKEND;
 			break;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
