Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id A507C6B0037
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:40:57 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id q11so1866360pdj.11
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:40:56 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 04/19] mm/m32r: prepare for killing free_all_bootmem_node()
Date: Sat, 13 Apr 2013 23:36:24 +0800
Message-Id: <1365867399-21323-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org

Prepare for killing free_all_bootmem_node() by using
free_all_bootmem().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Hirokazu Takata <takata@linux-m32r.org>
Cc: linux-m32r@ml.linux-m32r.org
Cc: linux-m32r-ja@ml.linux-m32r.org
Cc: linux-kernel@vger.kernel.org
---
 arch/m32r/mm/init.c |   17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/arch/m32r/mm/init.c b/arch/m32r/mm/init.c
index 9c94839..3113c85 100644
--- a/arch/m32r/mm/init.c
+++ b/arch/m32r/mm/init.c
@@ -111,28 +111,19 @@ void __init paging_init(void)
  *======================================================================*/
 void __init mem_init(void)
 {
-	int nid;
 #ifndef CONFIG_MMU
 	extern unsigned long memory_end;
-#endif
 
-#ifndef CONFIG_DISCONTIGMEM
-	max_mapnr = get_num_physpages();
-#endif	/* CONFIG_DISCONTIGMEM */
-
-#ifdef CONFIG_MMU
-	high_memory = (void *)__va(PFN_PHYS(MAX_LOW_PFN(0)));
-#else
 	high_memory = (void *)(memory_end & PAGE_MASK);
+#else
+	high_memory = (void *)__va(PFN_PHYS(MAX_LOW_PFN(0)));
 #endif /* CONFIG_MMU */
 
 	/* clear the zero-page */
 	memset(empty_zero_page, 0, PAGE_SIZE);
 
-	/* this will put all low memory onto the freelists */
-	for_each_online_node(nid)
-		free_all_bootmem_node(NODE_DATA(nid));
-
+	set_max_mapnr(get_num_physpages());
+	free_all_bootmem();
 	mem_init_print_info(NULL);
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
