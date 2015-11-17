Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 63ED96B0253
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 04:02:52 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so3246505pab.0
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 01:02:52 -0800 (PST)
Received: from cmccmta2.chinamobile.com (cmccmta2.chinamobile.com. [221.176.66.80])
        by mx.google.com with ESMTP id k8si601107pbq.49.2015.11.17.01.02.50
        for <linux-mm@kvack.org>;
        Tue, 17 Nov 2015 01:02:51 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH] mm/zonelist: enumerate zonelists array index
Date: Tue, 17 Nov 2015 17:02:04 +0800
Message-Id: <1447750924-9047-1-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hardcoding index to zonelists array in gfp_zonelist() is not a good idea,
let's enumerate it to improve readability.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/gfp.h    |  4 ++--
 include/linux/mmzone.h | 20 +++++++++-----------
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6523109..14a6249 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -378,9 +378,9 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 static inline int gfp_zonelist(gfp_t flags)
 {
 	if (IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
-		return 1;
+		return ZONELIST_NOFALLBACK;
 
-	return 0;
+	return ZONELIST_FALLBACK;
 }
 
 /*
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e23a9e7..bb31301 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -576,19 +576,17 @@ static inline bool zone_is_empty(struct zone *zone)
 /* Maximum number of zones on a zonelist */
 #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
 
+enum {
+	ZONELIST_FALLBACK,	/* zonelist with fallback */
 #ifdef CONFIG_NUMA
-
-/*
- * The NUMA zonelists are doubled because we need zonelists that restrict the
- * allocations to a single node for __GFP_THISNODE.
- *
- * [0]	: Zonelist with fallback
- * [1]	: No fallback (__GFP_THISNODE)
- */
-#define MAX_ZONELISTS 2
-#else
-#define MAX_ZONELISTS 1
+	/*
+	 * The NUMA zonelists are doubled because we need zonelists that restrict
+	 * the allocations to a single node for __GFP_THISNODE.
+	 */
+	ZONELIST_NOFALLBACK,	/* zonelist without fallback (__GFP_THISNODE) */
 #endif
+	MAX_ZONELISTS
+};
 
 /*
  * This struct contains information about a zone in a zonelist. It is stored
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
