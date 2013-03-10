Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id D9CEE6B005C
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:08:57 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xa12so2658696pbc.22
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:08:57 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 03/10] mm/FRV: use free_highmem_page() to free highmem pages into buddy system
Date: Sun, 10 Mar 2013 16:01:03 +0800
Message-Id: <1362902470-25787-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>

Use helper function free_highmem_page() to free highmem pages into
the buddy system.

Also fix a bug that totalhigh_pages should be increased when freeing
a highmem page into the buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org
---
 arch/frv/mm/init.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/frv/mm/init.c b/arch/frv/mm/init.c
index 21b9290..dee354f 100644
--- a/arch/frv/mm/init.c
+++ b/arch/frv/mm/init.c
@@ -131,10 +131,8 @@ void __init mem_init(void)
 			datapages++;
 
 #ifdef CONFIG_HIGHMEM
-	for (pfn = num_physpages - 1; pfn >= num_mappedpages; pfn--) {
-		__free_reserved_page(&mem_map[pfn]);
-		totalram_pages++;
-	}
+	for (pfn = num_physpages - 1; pfn >= num_mappedpages; pfn--)
+		free_highmem_page(&mem_map[pfn]);
 #endif
 
 	codek = ((unsigned long) &_etext - (unsigned long) &_stext) >> 10;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
