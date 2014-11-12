Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id BE2D56B00EC
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 03:38:07 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so11848438pde.32
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 00:38:07 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id 1si22318631pdr.58.2014.11.12.00.38.05
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 00:38:06 -0800 (PST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 2/2] mem-hotplug: Reset node present pages when hot-adding a new pgdat.
Date: Wed, 12 Nov 2014 16:37:14 +0800
Message-ID: <1415781434-20230-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1415781434-20230-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1415781434-20230-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, grygorii.strashko@ti.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, luto@amacapital.net, hpa@linux.intel.com, aarcange@redhat.com, qiuxishi@huawei.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com, stable@vger.kernel.org.#.3.16+

When memory is hot-added, all the memory is in offline state. So
clear all zones' present_pages because they will be updated in
online_pages() and offline_pages(). Otherwise, /proc/zoneinfo
will corrupt:

When the memory of node2 is offline:
# cat /proc/zoneinfo
......
Node 2, zone   Movable
......
        spanned  8388608
        present  8388608
        managed  0

When we online memory on node2:
# cat /proc/zoneinfo
......
Node 2, zone   Movable
......
        spanned  8388608
        present  16777216
        managed  8388608

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: stable@vger.kernel.org # 3.16+
---
 mm/memory_hotplug.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8aba12b..d0c9b7c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1067,6 +1067,16 @@ out:
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
+static void reset_node_present_pages(pg_data_t *pgdat)
+{
+	struct zone *z;
+
+	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
+		z->present_pages = 0;
+
+	pgdat->node_present_pages = 0;
+}
+
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
 static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 {
@@ -1105,6 +1115,13 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	 */
 	reset_node_managed_pages(pgdat);
 
+	/*
+	 * When memory is hot-added, all the memory is in offline state. So
+	 * clear all zones' present_pages because they will be updated in
+	 * online_pages() and offline_pages().
+	 */
+	reset_node_present_pages(pgdat);
+
 	return pgdat;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
