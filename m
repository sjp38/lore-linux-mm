Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0648F6B0135
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:45:59 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id uo1so9290992pbc.1
        for <linux-mm@kvack.org>; Wed, 29 May 2013 07:45:59 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH, v2 13/13] mm/m68k: fix build warning of unused variable
Date: Wed, 29 May 2013 22:44:52 +0800
Message-Id: <1369838692-26860-14-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
References: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@uclinux.org>, Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>, linux-m68k@lists.linux-m68k.org

Fix build warning of unused variable:
arch/m68k/mm/init.c: In function 'mem_init':
arch/m68k/mm/init.c:151:6: warning: unused variable 'i' [-Wunused-variable]

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Greg Ungerer <gerg@uclinux.org>
Cc: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-kernel@vger.kernel.org
---
 arch/m68k/mm/init.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 6e0a938..6b4baa6 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -146,14 +146,11 @@ void __init print_memmap(void)
 		MLK_ROUNDUP(__bss_start, __bss_stop));
 }
 
-void __init mem_init(void)
+static inline void init_pointer_tables(void)
 {
+#if defined(CONFIG_MMU) && !defined(CONFIG_SUN3) && !defined(CONFIG_COLDFIRE)
 	int i;
 
-	/* this will put all memory onto the freelists */
-	free_all_bootmem();
-
-#if defined(CONFIG_MMU) && !defined(CONFIG_SUN3) && !defined(CONFIG_COLDFIRE)
 	/* insert pointer tables allocated so far into the tablelist */
 	init_pointer_table((unsigned long)kernel_pg_dir);
 	for (i = 0; i < PTRS_PER_PGD; i++) {
@@ -165,7 +162,13 @@ void __init mem_init(void)
 	if (zero_pgtable)
 		init_pointer_table((unsigned long)zero_pgtable);
 #endif
+}
 
+void __init mem_init(void)
+{
+	/* this will put all memory onto the freelists */
+	free_all_bootmem();
+	init_pointer_tables();
 	mem_init_print_info(NULL);
 	print_memmap();
 }
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
