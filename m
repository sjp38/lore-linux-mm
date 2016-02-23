Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id E277F6B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:04:55 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id c200so225011806wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:04:55 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id 8si40059338wmi.102.2016.02.23.07.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:04:51 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 4680A1C18A8
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:04:51 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 02/27] mm, vmscan: Check if cpusets are enabled during direct reclaim
Date: Tue, 23 Feb 2016 15:04:25 +0000
Message-Id: <1456239890-20737-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Direct reclaim obeys cpusets but misses the cpusets_enabled() check.
The overhead is unlikely to be measurable in the direct reclaim
path which is expensive but there is no harm is doing it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 86eb21491867..de8d6226e026 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2566,7 +2566,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		 * to global LRU.
 		 */
 		if (global_reclaim(sc)) {
-			if (!cpuset_zone_allowed(zone,
+			if (cpusets_enabled() && !cpuset_zone_allowed(zone,
 						 GFP_KERNEL | __GFP_HARDWALL))
 				continue;
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
