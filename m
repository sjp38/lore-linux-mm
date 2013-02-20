Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id C2BA86B0007
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 12:28:33 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kq12so4153530pab.1
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 09:28:33 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2] mm: let /proc/meminfo report physical memory installed as "MemTotal"
Date: Thu, 21 Feb 2013 01:27:25 +0800
Message-Id: <1361381245-14664-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <alpine.DEB.2.02.1302191326150.6322@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1302191326150.6322@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com
Cc: Jiang Liu <jiang.liu@huawei.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

As reported by https://bugzilla.kernel.org/show_bug.cgi?id=53501,
"MemTotal" from /proc/meminfo means memory pages managed by the buddy
system (managed_pages), but "MemTotal" from /sys/.../node/nodex/meminfo
means phsical pages present (present_pages) within the NUMA node.
There's a difference between managed_pages and present_pages due to
bootmem allocator and reserved pages.

So change /proc/meminfo to report physical memory installed as
"MemTotal", which is
MemTotal = sum(pgdat->present_pages)

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Reported-by: sworddragon2@aol.com
---
Hi David,
	How about this simpilified version?
	Regards!
	Gerry
---
 mm/page_alloc.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e4e8bf1..8e53d6e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2835,7 +2835,13 @@ static inline void show_node(struct zone *zone)
 
 void si_meminfo(struct sysinfo *val)
 {
-	val->totalram = totalram_pages;
+	int nid;
+	unsigned long present_pages = 0;
+
+	for_each_node_state(nid, N_MEMORY)
+		present_pages += node_present_pages(nid);
+
+	val->totalram = present_pages;
 	val->sharedram = 0;
 	val->freeram = global_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
