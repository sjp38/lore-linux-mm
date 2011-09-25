Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 78E1E9000BD
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 07:00:33 -0400 (EDT)
Received: by pzk4 with SMTP id 4so12769970pzk.6
        for <linux-mm@kvack.org>; Sun, 25 Sep 2011 04:00:29 -0700 (PDT)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] vmscan.c: Invalid strict_strtoul check in write_scan_unevictable_node
Date: Sun, 25 Sep 2011 16:29:40 +0530
Message-Id: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

write_scan_unavictable_node checks the value req returned by
strict_strtoul and returns 1 if req is 0.

However, when strict_strtoul returns 0, it means successful conversion
of buf to unsigned long.

Due to this, the function was not proceeding to scan the zones for
unevictable pages even though we write a valid value to the 
scan_unevictable_pages sys file.

Changing this if check slightly to check for invalid value 
in buf as well as 0 value stored in res after successful conversion
via strict_strtoul.
In both cases, we do not perform the scanning of this node's zones.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/vmscan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b55699c..73996e6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3450,8 +3450,8 @@ static ssize_t write_scan_unevictable_node(struct sys_device *dev,
 	unsigned long res;
 	unsigned long req = strict_strtoul(buf, 10, &res);
 
-	if (!req)
-		return 1;	/* zero is no-op */
+	if (req || !res)
+		return 1; /* Invalid input or zero is no-op */
 
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
 		if (!populated_zone(zone))
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
