Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19E0C6B02C3
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 08:38:45 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y39so1426587wry.10
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 05:38:45 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 81si1684694wrc.11.2017.06.07.05.38.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 05:38:43 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 4/4] Make LSM Writable Hooks a command line option
Date: Wed, 7 Jun 2017 15:35:05 +0300
Message-ID: <20170607123505.16629-5-igor.stoppa@huawei.com>
In-Reply-To: <20170607123505.16629-1-igor.stoppa@huawei.com>
References: <20170607123505.16629-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

This patch shows how it is possible to take advantage of pmalloc:
instead of using the build-time option __lsm_ro_after_init, to decide if
it is possible to keep the hooks modifiable, now this becomes a
boot-time decision, based on the kernel command line.

This patch relies on:

"Convert security_hook_heads into explicit array of struct list_head"
Author: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

to break free from the static constraint imposed by the previous
hardening model, based on __ro_after_init.

The default value is disabled, unless SE Linux debugging is turned on.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 security/security.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/security/security.c b/security/security.c
index c492f68..9b8b478 100644
--- a/security/security.c
+++ b/security/security.c
@@ -26,6 +26,7 @@
 #include <linux/personality.h>
 #include <linux/backing-dev.h>
 #include <linux/string.h>
+#include <linux/pmalloc.h>
 #include <net/flow.h>
 
 #define MAX_LSM_EVM_XATTR	2
@@ -33,8 +34,17 @@
 /* Maximum number of letters for an LSM name string */
 #define SECURITY_NAME_MAX	10
 
-static struct list_head hook_heads[LSM_MAX_HOOK_INDEX]
-	__lsm_ro_after_init;
+static int dynamic_lsm = IS_ENABLED(CONFIG_SECURITY_SELINUX_DISABLE);
+
+static __init int set_dynamic_lsm(char *str)
+{
+	get_option(&str, &dynamic_lsm);
+	return 0;
+}
+early_param("dynamic_lsm", set_dynamic_lsm);
+
+static struct list_head *hook_heads;
+static struct pmalloc_pool *sec_pool;
 char *lsm_names;
 /* Boot-time LSM user choice */
 static __initdata char chosen_lsm[SECURITY_NAME_MAX + 1] =
@@ -59,6 +69,11 @@ int __init security_init(void)
 {
 	enum security_hook_index i;
 
+	sec_pool = pmalloc_create_pool("security");
+	BUG_ON(!sec_pool);
+	hook_heads = pmalloc(sizeof(struct list_head) * LSM_MAX_HOOK_INDEX,
+			     sec_pool);
+	BUG_ON(!hook_heads);
 	for (i = 0; i < LSM_MAX_HOOK_INDEX; i++)
 		INIT_LIST_HEAD(&hook_heads[i]);
 	pr_info("Security Framework initialized\n");
@@ -74,7 +89,8 @@ int __init security_init(void)
 	 * Load all the remaining security modules.
 	 */
 	do_security_initcalls();
-
+	if (!dynamic_lsm)
+		pmalloc_protect_pool(sec_pool);
 	return 0;
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
