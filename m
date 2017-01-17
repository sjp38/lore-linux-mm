Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECD06B0069
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:16:27 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so36306031wmd.4
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:16:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si11045363wrc.257.2017.01.17.14.16.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 14:16:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/4] mm, page_alloc: fix check for NULL preferred_zone
Date: Tue, 17 Jan 2017 23:16:07 +0100
Message-Id: <20170117221610.22505-2-vbabka@suse.cz>
In-Reply-To: <20170117221610.22505-1-vbabka@suse.cz>
References: <20170117221610.22505-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Since commit c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in
a zonelist twice") we have a wrong check for NULL preferred_zone, which can
theoretically happen due to concurrent cpuset modification. We check the
zoneref pointer which is never NULL and we should check the zone pointer.

Fixes: c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 34ada718ef47..593a11d8bc6b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3763,7 +3763,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
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
