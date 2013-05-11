Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 1B9B96B0062
	for <linux-mm@kvack.org>; Sat, 11 May 2013 13:42:23 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id rp2so783348pbb.36
        for <linux-mm@kvack.org>; Sat, 11 May 2013 10:42:22 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part3 15/16] mm: report available pages as "MemTotal" for each NUMA node
Date: Sun, 12 May 2013 01:34:48 +0800
Message-Id: <1368293689-16410-16-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
References: <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

As reported by https://bugzilla.kernel.org/show_bug.cgi?id=53501,
"MemTotal" from /proc/meminfo means memory pages managed by the buddy
system (managed_pages), but "MemTotal" from /sys/.../node/nodex/meminfo
means phsical pages present (present_pages) within the NUMA node.
There's a difference between managed_pages and present_pages due to
bootmem allocator and reserved pages.

And Documentation/filesystems/proc.txt says
    MemTotal: Total usable ram (i.e. physical ram minus a few reserved
              bits and the kernel binary code)

So change /sys/.../node/nodex/meminfo to report available pages within
the node as "MemTotal".

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Reported-by: sworddragon2@aol.com
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/page_alloc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 56b0097..e7a517d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2924,9 +2924,13 @@ EXPORT_SYMBOL(si_meminfo);
 #ifdef CONFIG_NUMA
 void si_meminfo_node(struct sysinfo *val, int nid)
 {
+	int zone_type;		/* needs to be signed */
+	unsigned long managed_pages = 0;
 	pg_data_t *pgdat = NODE_DATA(nid);
 
-	val->totalram = pgdat->node_present_pages;
+	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
+		managed_pages += pgdat->node_zones[zone_type].managed_pages;
+	val->totalram = managed_pages;
 	val->freeram = node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
 	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
