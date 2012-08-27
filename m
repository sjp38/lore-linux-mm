Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id EFACE6B002B
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 22:02:26 -0400 (EDT)
Received: by qady1 with SMTP id y1so1754305qad.14
        for <linux-mm@kvack.org>; Sun, 26 Aug 2012 19:02:26 -0700 (PDT)
Message-ID: <503AD533.1040307@gmail.com>
Date: Mon, 27 Aug 2012 10:02:27 +0800
From: qiuxishi <qiuxishi@gmail.com>
MIME-Version: 1.0
Subject: [PATCH V2] memory-hotplug: add build zonelists when offline pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, liuj97@gmail.com, Wen Congyang <wency@cn.fujitsu.com>
Cc: paul.gortmaker@windriver.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bessel.wang@huawei.com, wujianguo@huawei.com, qiuxishi@huawei.com, jiang.liu@huawei.com, guohanjun@huawei.com, yinghai@kernel.org

From: Xishi Qiu <qiuxishi@huawei.com>

online_pages() does build_all_zonelists() and zone_pcp_update(),
I think offline_pages() should do it too.
When the zone has no  memory to allocate, remove it form other
nodes' zonelists. zone_batchsize() depends on zone's present pages,
if zone's present pages are changed, zone's pcp should be updated.


Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index bc7e7a2..5f6997f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -973,8 +973,13 @@ repeat:

 	init_per_zone_wmark_min();

-	if (!populated_zone(zone))
+	if (!populated_zone(zone)) {
 		zone_pcp_reset(zone);
+		mutex_lock(&zonelists_mutex);
+		build_all_zonelists(NULL, NULL);
+		mutex_unlock(&zonelists_mutex);
+	} else
+		zone_pcp_update(zone);

 	if (!node_present_pages(node)) {
 		node_clear_state(node, N_HIGH_MEMORY);
-- 
1.7.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
