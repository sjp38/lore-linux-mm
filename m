Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E63F16B005A
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 22:47:50 -0400 (EDT)
Received: by mail-gh0-f180.google.com with SMTP id f13so502171ghb.25
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 19:47:50 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 1/2] drivers: staging: zcache: fix compile error
Date: Tue,  2 Apr 2013 10:47:42 +0800
Message-Id: <1364870864-13888-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: konrad.wilk@oracle.com, dan.magenheimer@oracle.com, fengguang.wu@intel.com, linux-mm@kvack.org, akpm@linux-foundation.org, Bob Liu <bob.liu@oracle.com>

Because 'ramster_debugfs_init' is not defined if !CONFIG_DEBUG_FS, there is
compile error:

$ make drivers/staging/zcache/
staging/zcache/ramster/ramster.c: In function a??ramster_inita??:
staging/zcache/ramster/ramster.c:981:2: error: implicit declaration of
function a??ramster_debugfs_inita?? [-Werror=implicit-function-declaration]

This patch fix it and reduce some #ifdef CONFIG_DEBUG_FS in .c files the same
way.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 drivers/staging/zcache/ramster/ramster.c |    5 +++++
 drivers/staging/zcache/zbud.c            |    7 +++++--
 drivers/staging/zcache/zcache-main.c     |    2 --
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging/zcache/ramster/ramster.c
index 4f715c7..5617590 100644
--- a/drivers/staging/zcache/ramster/ramster.c
+++ b/drivers/staging/zcache/ramster/ramster.c
@@ -134,6 +134,11 @@ static int ramster_debugfs_init(void)
 }
 #undef	zdebugfs
 #undef	zdfs64
+#else
+static inline int ramster_debugfs_init(void)
+{
+	return 0;
+}
 #endif
 
 static LIST_HEAD(ramster_rem_op_list);
diff --git a/drivers/staging/zcache/zbud.c b/drivers/staging/zcache/zbud.c
index fdff5c6..6cda4ed 100644
--- a/drivers/staging/zcache/zbud.c
+++ b/drivers/staging/zcache/zbud.c
@@ -342,6 +342,11 @@ static int zbud_debugfs_init(void)
 }
 #undef	zdfs
 #undef	zdfs64
+#else
+static inline int zbud_debugfs_init(void)
+{
+	return 0;
+}
 #endif
 
 /* protects the buddied list and all unbuddied lists */
@@ -1051,9 +1056,7 @@ void zbud_init(void)
 {
 	int i;
 
-#ifdef CONFIG_DEBUG_FS
 	zbud_debugfs_init();
-#endif
 	BUG_ON((sizeof(struct tmem_handle) * 2 > CHUNK_SIZE));
 	BUG_ON(sizeof(struct zbudpage) > sizeof(struct page));
 	for (i = 0; i < NCHUNKS; i++) {
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 4e52a94..ac75670 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1753,9 +1753,7 @@ static int zcache_init(void)
 		namestr = "ramster";
 		ramster_register_pamops(&zcache_pamops);
 	}
-#ifdef CONFIG_DEBUG_FS
 	zcache_debugfs_init();
-#endif
 	if (zcache_enabled) {
 		unsigned int cpu;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
