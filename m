Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C17E6B0038
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:38:56 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id yr2so14040264wjc.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:38:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c2si7428083wrc.313.2017.01.20.02.38.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 02:38:55 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 1/4] mm, page_alloc: fix check for NULL preferred_zone
Date: Fri, 20 Jan 2017 11:38:40 +0100
Message-Id: <20170120103843.24587-2-vbabka@suse.cz>
In-Reply-To: <20170120103843.24587-1-vbabka@suse.cz>
References: <20170120103843.24587-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

Since commit c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in
a zonelist twice") we have a wrong check for NULL preferred_zone, which can
theoretically happen due to concurrent cpuset modification. We check the
zoneref pointer which is never NULL and we should check the zone pointer.
Also document this in first_zones_zonelist() comment per Michal Hocko.

Fixes: c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h | 6 +++++-
 mm/page_alloc.c        | 2 +-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 36d9896fbc1e..f4aac87adcc3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -972,12 +972,16 @@ static __always_inline struct zoneref *next_zones_zonelist(struct zoneref *z,
  * @zonelist - The zonelist to search for a suitable zone
  * @highest_zoneidx - The zone index of the highest zone to return
  * @nodes - An optional nodemask to filter the zonelist with
- * @zone - The first suitable zone found is returned via this parameter
+ * @return - Zoneref pointer for the first suitable zone found (see below)
  *
  * This function returns the first zone at or below a given zone index that is
  * within the allowed nodemask. The zoneref returned is a cursor that can be
  * used to iterate the zonelist with next_zones_zonelist by advancing it by
  * one before calling.
+ *
+ * When no eligible zone is found, zoneref->zone is NULL (zoneref itself is
+ * never NULL). This may happen either genuinely, or due to concurrent nodemask
+ * update due to cpuset modification.
  */
 static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d604d2596b7b..0d771f3fb835 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3784,7 +3784,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 */
 	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
 					ac.high_zoneidx, ac.nodemask);
-	if (!ac.preferred_zoneref) {
+	if (!ac.preferred_zoneref->zone) {
 		page = NULL;
 		goto no_zone;
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
