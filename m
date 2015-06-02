Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 45DDF900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 17:11:03 -0400 (EDT)
Received: by obcnx10 with SMTP id nx10so132513757obc.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 14:11:03 -0700 (PDT)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id z67si340894oie.3.2015.06.02.14.11.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 14:11:02 -0700 (PDT)
Received: by obew15 with SMTP id w15so138707863obe.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 14:11:02 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zswap: runtime enable/disable
Date: Tue,  2 Jun 2015 17:10:54 -0400
Message-Id: <1433279454-10366-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

Change the "enabled" parameter to be configurable at runtime.  Remove
the enabled check from init(), and move it to the frontswap store()
function; when enabled, pages will be stored, and when disabled, pages
won't be stored.

This is almost identical to Seth's patch from 2 years ago:
http://lkml.iu.edu/hypermail/linux/kernel/1307.2/04289.html

Suggested-by: Seth Jennings <sjennings@variantweb.net>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 Documentation/vm/zswap.txt | 18 ++++++++++++++++--
 mm/zswap.c                 | 12 +++++-------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
index 00c3d31..9e7d434 100644
--- a/Documentation/vm/zswap.txt
+++ b/Documentation/vm/zswap.txt
@@ -26,8 +26,22 @@ Zswap evicts pages from compressed cache on an LRU basis to the backing swap
 device when the compressed pool reaches its size limit.  This requirement had
 been identified in prior community discussions.
 
-To enabled zswap, the "enabled" attribute must be set to 1 at boot time.  e.g.
-zswap.enabled=1
+Zswap is disabled by default but can be enabled at boot time by setting
+the "enabled" attribute to 1 at boot time. e.g. zswap.enabled=1. Zswap
+can also be enabled and disabled at runtime using the sysfs interface.
+An exmaple command to enable zswap at runtime, assuming sysfs is mounted
+at /sys, is:
+
+echo 1 > /sys/modules/zswap/parameters/enabled
+
+When zswap is disabled at runtime, it will stop storing pages that are
+being swapped out. However, it will _not_ immediately write out or
+fault back into memory all of the pages stored in the compressed pool.
+The pages stored in zswap will continue to remain in the compressed pool
+until they are either invalidated or faulted back into memory. In order
+to force all pages out of the compressed pool, a swapoff on the swap
+device(s) will fault all swapped out pages, included those in the
+compressed pool, back into memory.
 
 Design:
 
diff --git a/mm/zswap.c b/mm/zswap.c
index 4249e82..2d5727b 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -75,9 +75,10 @@ static u64 zswap_duplicate_entry;
 /*********************************
 * tunables
 **********************************/
-/* Enable/disable zswap (disabled by default, fixed at boot for now) */
-static bool zswap_enabled __read_mostly;
-module_param_named(enabled, zswap_enabled, bool, 0444);
+
+/* Enable/disable zswap (disabled by default) */
+static bool zswap_enabled;
+module_param_named(enabled, zswap_enabled, bool, 0644);
 
 /* Compressor to be used by zswap (fixed at boot for now) */
 #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
@@ -648,7 +649,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	u8 *src, *dst;
 	struct zswap_header *zhdr;
 
-	if (!tree) {
+	if (!zswap_enabled || !tree) {
 		ret = -ENODEV;
 		goto reject;
 	}
@@ -901,9 +902,6 @@ static int __init init_zswap(void)
 {
 	gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN;
 
-	if (!zswap_enabled)
-		return 0;
-
 	pr_info("loading zswap\n");
 
 	zswap_pool = zpool_create_pool(zswap_zpool_type, "zswap", gfp,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
