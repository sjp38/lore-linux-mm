Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 36CBB6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 15:34:56 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 22 Jul 2013 13:34:25 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DD1973E40039
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 13:33:59 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6MJYAbk121020
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 13:34:10 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6MJY7QA005476
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 13:34:07 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] mm: zswap: add runtime enable/disable
Date: Mon, 22 Jul 2013 14:34:02 -0500
Message-Id: <1374521642-25478-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Bob Liu <lliubbo@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Right now, zswap can only be enabled at boot time.  This patch
modifies zswap so that it can be dynamically enabled or disabled
at runtime.

In order to allow this ability, zswap unconditionally registers as a
frontswap backend regardless of whether or not zswap.enabled=1 is passed
in the boot parameters or not.  This introduces a very small overhead
for systems that have zswap disabled as calls to frontswap_store() will
call zswap_frontswap_store(), but there is a fast path to immediately
return if zswap is disabled.

Disabling zswap does not unregister zswap from frontswap.  It simply
blocks all future stores.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 Documentation/vm/zswap.txt | 18 ++++++++++++++++--
 mm/zswap.c                 |  9 +++------
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
index 7e492d8..d588477 100644
--- a/Documentation/vm/zswap.txt
+++ b/Documentation/vm/zswap.txt
@@ -26,8 +26,22 @@ Zswap evicts pages from compressed cache on an LRU basis to the backing swap
 device when the compressed pool reaches it size limit.  This requirement had
 been identified in prior community discussions.
 
-To enabled zswap, the "enabled" attribute must be set to 1 at boot time.  e.g.
-zswap.enabled=1
+Zswap is disabled by default but can be enabled at boot time by setting
+the "enabled" attribute to 1 at boot time. e.g. zswap.enabled=1.  Zswap
+can also be enabled and disabled at runtime using the sysfs interface.
+An exmaple command to enable zswap at runtime, assuming sysfs is mounted
+at /sys, is:
+
+echo 1 > /sys/modules/zswap/parameters/enabled
+
+When zswap is disabled at runtime, it will stop storing pages that are
+being swapped out.  However, it will _not_ immediately write out or
+fault back into memory all of the pages stored in the compressed pool.
+The pages stored in zswap will continue to remain in the compressed pool
+until they are either invalidated or faulted back into memory.  In order
+to force all pages out of the compressed pool, a swapoff on the swap
+device(s) will fault all swapped out pages, included those in the
+compressed pool, back into memory.
 
 Design:
 
diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..199b1b0 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -75,9 +75,9 @@ static u64 zswap_duplicate_entry;
 /*********************************
 * tunables
 **********************************/
-/* Enable/disable zswap (disabled by default, fixed at boot for now) */
+/* Enable/disable zswap (disabled by default) */
 static bool zswap_enabled __read_mostly;
-module_param_named(enabled, zswap_enabled, bool, 0);
+module_param_named(enabled, zswap_enabled, bool, 0644);
 
 /* Compressor to be used by zswap (fixed at boot for now) */
 #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
@@ -612,7 +612,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	u8 *src, *dst;
 	struct zswap_header *zhdr;
 
-	if (!tree) {
+	if (!zswap_enabled || !tree) {
 		ret = -ENODEV;
 		goto reject;
 	}
@@ -908,9 +908,6 @@ static void __exit zswap_debugfs_exit(void) { }
 **********************************/
 static int __init init_zswap(void)
 {
-	if (!zswap_enabled)
-		return 0;
-
 	pr_info("loading zswap\n");
 	if (zswap_entry_cache_create()) {
 		pr_err("entry cache creation failed\n");
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
