Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id B0D396B0070
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 11:12:26 -0400 (EDT)
Received: by obcnx10 with SMTP id nx10so124483162obc.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 08:12:26 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id p3si11060380obi.43.2015.06.02.08.12.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 08:12:25 -0700 (PDT)
Received: by obbea2 with SMTP id ea2so130058231obb.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 08:12:24 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 3/5] zswap: runtime enable/disable
Date: Tue,  2 Jun 2015 11:11:55 -0400
Message-Id: <1433257917-13090-4-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1433257917-13090-1-git-send-email-ddstreet@ieee.org>
References: <1433257917-13090-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

Change the "enabled" parameter to be configurable at runtime.  Remove
the enabled check from init(), and move it to the frontswap store()
function; when enabled, pages will be stored, and when disabled, pages
won't be stored.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 4249e82..e070b10 100644
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
@@ -648,6 +649,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	u8 *src, *dst;
 	struct zswap_header *zhdr;
 
+	if (!zswap_enabled)
+		return -EPERM;
+
 	if (!tree) {
 		ret = -ENODEV;
 		goto reject;
@@ -901,9 +905,6 @@ static int __init init_zswap(void)
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
