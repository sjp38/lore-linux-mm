Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 093F06B0003
	for <linux-mm@kvack.org>; Thu,  3 May 2018 16:32:11 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w3-v6so12637796pgv.17
        for <linux-mm@kvack.org>; Thu, 03 May 2018 13:32:11 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y23si14539916pff.177.2018.05.03.13.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 13:32:09 -0700 (PDT)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] mm, vmpressure: Convert to use match_string() helper
Date: Thu,  3 May 2018 23:32:06 +0300
Message-Id: <20180503203206.44046-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

The new helper returns index of the matching string in an array.
We are going to use it here.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 mm/vmpressure.c | 32 ++++++--------------------------
 1 file changed, 6 insertions(+), 26 deletions(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 7142207224d3..4854584ec436 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -342,26 +342,6 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
 	vmpressure(gfp, memcg, true, vmpressure_win, 0);
 }
 
-static enum vmpressure_levels str_to_level(const char *arg)
-{
-	enum vmpressure_levels level;
-
-	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++)
-		if (!strcmp(vmpressure_str_levels[level], arg))
-			return level;
-	return -1;
-}
-
-static enum vmpressure_modes str_to_mode(const char *arg)
-{
-	enum vmpressure_modes mode;
-
-	for (mode = 0; mode < VMPRESSURE_NUM_MODES; mode++)
-		if (!strcmp(vmpressure_str_modes[mode], arg))
-			return mode;
-	return -1;
-}
-
 #define MAX_VMPRESSURE_ARGS_LEN	(strlen("critical") + strlen("hierarchy") + 2)
 
 /**
@@ -398,18 +378,18 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
 
 	/* Find required level */
 	token = strsep(&spec, ",");
-	level = str_to_level(token);
-	if (level == -1) {
-		ret = -EINVAL;
+	level = match_string(vmpressure_str_levels, VMPRESSURE_NUM_LEVELS, token);
+	if (level < 0) {
+		ret = level;
 		goto out;
 	}
 
 	/* Find optional mode */
 	token = strsep(&spec, ",");
 	if (token) {
-		mode = str_to_mode(token);
-		if (mode == -1) {
-			ret = -EINVAL;
+		mode = match_string(vmpressure_str_modes, VMPRESSURE_NUM_MODES, token);
+		if (mode < 0) {
+			ret = mode;
 			goto out;
 		}
 	}
-- 
2.17.0
