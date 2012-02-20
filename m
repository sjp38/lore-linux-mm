Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 4FA086B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 11:29:37 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 1/2] staging: ramster: build ramster properly when CONFIG_OCFS2=m|y
Date: Mon, 20 Feb 2012 08:29:30 -0800
Message-Id: <1329755371-5444-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com

Due to some conflicting debug vars, kernel build will warn when
CONFIG_RAMSTER=y and CONFIG_OCFS2=m and will fail when
CONFIG_RAMSTER=y and CONFIG_OCFS2=y (rare).

Rename ramster mlog vars to avoid the name conflict.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/cluster/masklog.c |   28 ++++++++++++++--------------
 drivers/staging/ramster/cluster/masklog.h |   10 +++++-----
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/ramster/cluster/masklog.c b/drivers/staging/ramster/cluster/masklog.c
index c2af3c7..1261d85 100644
--- a/drivers/staging/ramster/cluster/masklog.c
+++ b/drivers/staging/ramster/cluster/masklog.c
@@ -28,18 +28,18 @@
 
 #include "masklog.h"
 
-struct mlog_bits mlog_and_bits = MLOG_BITS_RHS(MLOG_INITIAL_AND_MASK);
-EXPORT_SYMBOL_GPL(mlog_and_bits);
-struct mlog_bits mlog_not_bits = MLOG_BITS_RHS(0);
-EXPORT_SYMBOL_GPL(mlog_not_bits);
+struct mlog_bits r2_mlog_and_bits = MLOG_BITS_RHS(MLOG_INITIAL_AND_MASK);
+EXPORT_SYMBOL_GPL(r2_mlog_and_bits);
+struct mlog_bits r2_mlog_not_bits = MLOG_BITS_RHS(0);
+EXPORT_SYMBOL_GPL(r2_mlog_not_bits);
 
 static ssize_t mlog_mask_show(u64 mask, char *buf)
 {
 	char *state;
 
-	if (__mlog_test_u64(mask, mlog_and_bits))
+	if (__mlog_test_u64(mask, r2_mlog_and_bits))
 		state = "allow";
-	else if (__mlog_test_u64(mask, mlog_not_bits))
+	else if (__mlog_test_u64(mask, r2_mlog_not_bits))
 		state = "deny";
 	else
 		state = "off";
@@ -50,14 +50,14 @@ static ssize_t mlog_mask_show(u64 mask, char *buf)
 static ssize_t mlog_mask_store(u64 mask, const char *buf, size_t count)
 {
 	if (!strnicmp(buf, "allow", 5)) {
-		__mlog_set_u64(mask, mlog_and_bits);
-		__mlog_clear_u64(mask, mlog_not_bits);
+		__mlog_set_u64(mask, r2_mlog_and_bits);
+		__mlog_clear_u64(mask, r2_mlog_not_bits);
 	} else if (!strnicmp(buf, "deny", 4)) {
-		__mlog_set_u64(mask, mlog_not_bits);
-		__mlog_clear_u64(mask, mlog_and_bits);
+		__mlog_set_u64(mask, r2_mlog_not_bits);
+		__mlog_clear_u64(mask, r2_mlog_and_bits);
 	} else if (!strnicmp(buf, "off", 3)) {
-		__mlog_clear_u64(mask, mlog_not_bits);
-		__mlog_clear_u64(mask, mlog_and_bits);
+		__mlog_clear_u64(mask, r2_mlog_not_bits);
+		__mlog_clear_u64(mask, r2_mlog_and_bits);
 	} else
 		return -EINVAL;
 
@@ -134,7 +134,7 @@ static struct kset mlog_kset = {
 	.kobj   = {.ktype = &mlog_ktype},
 };
 
-int mlog_sys_init(struct kset *r2cb_kset)
+int r2_mlog_sys_init(struct kset *r2cb_kset)
 {
 	int i = 0;
 
@@ -149,7 +149,7 @@ int mlog_sys_init(struct kset *r2cb_kset)
 	return kset_register(&mlog_kset);
 }
 
-void mlog_sys_shutdown(void)
+void r2_mlog_sys_shutdown(void)
 {
 	kset_unregister(&mlog_kset);
 }
diff --git a/drivers/staging/ramster/cluster/masklog.h b/drivers/staging/ramster/cluster/masklog.h
index 7609e66..918ae11 100644
--- a/drivers/staging/ramster/cluster/masklog.h
+++ b/drivers/staging/ramster/cluster/masklog.h
@@ -127,7 +127,7 @@ struct mlog_bits {
 	unsigned long words[MLOG_MAX_BITS / BITS_PER_LONG];
 };
 
-extern struct mlog_bits mlog_and_bits, mlog_not_bits;
+extern struct mlog_bits r2_mlog_and_bits, r2_mlog_not_bits;
 
 #if BITS_PER_LONG == 32
 
@@ -186,8 +186,8 @@ extern struct mlog_bits mlog_and_bits, mlog_not_bits;
 #define mlog(mask, fmt, args...) do {					\
 	u64 __m = MLOG_MASK_PREFIX | (mask);				\
 	if ((__m & ML_ALLOWED_BITS) &&					\
-	    __mlog_test_u64(__m, mlog_and_bits) &&			\
-	    !__mlog_test_u64(__m, mlog_not_bits)) {			\
+	    __mlog_test_u64(__m, r2_mlog_and_bits) &&			\
+	    !__mlog_test_u64(__m, r2_mlog_not_bits)) {			\
 		if (__m & ML_ERROR)					\
 			__mlog_printk(KERN_ERR, "ERROR: "fmt , ##args);	\
 		else if (__m & ML_NOTICE)				\
@@ -214,7 +214,7 @@ extern struct mlog_bits mlog_and_bits, mlog_not_bits;
 
 #include <linux/kobject.h>
 #include <linux/sysfs.h>
-int mlog_sys_init(struct kset *r2cb_subsys);
-void mlog_sys_shutdown(void);
+int r2_mlog_sys_init(struct kset *r2cb_subsys);
+void r2_mlog_sys_shutdown(void);
 
 #endif /* R2CLUSTER_MASKLOG_H */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
