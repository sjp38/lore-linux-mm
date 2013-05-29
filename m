Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 9377C6B012B
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:45:56 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id uo1so9290930pbc.1
        for <linux-mm@kvack.org>; Wed, 29 May 2013 07:45:55 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH, v2 12/13] mm/alpha: unify mem_init() for both UMA and NUMA architectures
Date: Wed, 29 May 2013 22:44:51 +0800
Message-Id: <1369838692-26860-13-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
References: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org

Now mem_init() for both Alpha UMA and Alpha NUMA are the same,
so unify it to reduce duplicated code.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/alpha/mm/init.c |  7 ++-----
 arch/alpha/mm/numa.c | 10 ----------
 2 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index af91010..a1bea91 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -276,17 +276,14 @@ srm_paging_stop (void)
 }
 #endif
 
-#ifndef CONFIG_DISCONTIGMEM
 void __init
 mem_init(void)
 {
-	max_mapnr = max_low_pfn;
-	free_all_bootmem();
+	set_max_mapnr(max_low_pfn);
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
-
+	free_all_bootmem();
 	mem_init_print_info(NULL);
 }
-#endif /* CONFIG_DISCONTIGMEM */
 
 void
 free_initmem(void)
diff --git a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
index 0894b3a8..d543d71 100644
--- a/arch/alpha/mm/numa.c
+++ b/arch/alpha/mm/numa.c
@@ -319,13 +319,3 @@ void __init paging_init(void)
 	/* Initialize the kernel's ZERO_PGE. */
 	memset((void *)ZERO_PGE, 0, PAGE_SIZE);
 }
-
-void __init mem_init(void)
-{
-	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
-	free_all_bootmem();
-	mem_init_print_info(NULL);
-#if 0
-	mem_stress();
-#endif
-}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
