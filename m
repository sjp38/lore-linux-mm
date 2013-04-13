Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 698016B0071
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:44:31 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id bj3so1919070pad.34
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:44:30 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 19/19] mm: call register_page_bootmem_info_node() from mm core
Date: Sat, 13 Apr 2013 23:36:39 +0800
Message-Id: <1365867399-21323-20-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, sparclinux@vger.kernel.org

Function register_page_bootmem_info_node() is suitably defined for
both HOTPLUG and non-HOTPLUG configurations, so we could call it
from mm core instead of arch specific code. This could simplify
arch implementations.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: sparclinux@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/sparc/mm/init_64.c |   12 ------------
 arch/x86/mm/init_64.c   |   12 ------------
 mm/bootmem.c            |    6 ++++++
 mm/nobootmem.c          |    6 ++++++
 4 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index b1e35b7..5530c09 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2027,16 +2027,6 @@ static void __init patch_tlb_miss_handler_bitmap(void)
 	flushi(&valid_addr_bitmap_insn[0]);
 }
 
-static void __init register_page_bootmem_info(void)
-{
-#ifdef CONFIG_NEED_MULTIPLE_NODES
-	int i;
-
-	for_each_online_node(i)
-		if (NODE_DATA(i)->node_spanned_pages)
-			register_page_bootmem_info_node(NODE_DATA(i));
-#endif
-}
 void __init mem_init(void)
 {
 	unsigned long addr, last;
@@ -2052,8 +2042,6 @@ void __init mem_init(void)
 	patch_tlb_miss_handler_bitmap();
 
 	high_memory = __va(last_valid_pfn << PAGE_SHIFT);
-
-	register_page_bootmem_info();
 	free_all_bootmem();
 
 	/*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 650264b..72b5141 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1031,24 +1031,12 @@ int __ref arch_remove_memory(u64 start, u64 size)
 
 static struct kcore_list kcore_vsyscall;
 
-static void __init register_page_bootmem_info(void)
-{
-#ifdef CONFIG_NUMA
-	int i;
-
-	for_each_online_node(i)
-		register_page_bootmem_info_node(NODE_DATA(i));
-#endif
-}
-
 void __init mem_init(void)
 {
 	pci_iommu_alloc();
 
 	/* clear_bss() already clear the empty_zero_page */
 
-	register_page_bootmem_info();
-
 	/* this will put all memory onto the freelists */
 	free_all_bootmem();
 	after_bootmem = 1;
diff --git a/mm/bootmem.c b/mm/bootmem.c
index fab8f63..3cf36ac 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -273,6 +273,12 @@ unsigned long __init free_all_bootmem(void)
 {
 	unsigned long total_pages = 0;
 	bootmem_data_t *bdata;
+#ifdef CONFIG_NEED_MULTIPLE_NODES
+	pg_data_t *pgdat;
+
+	for_each_online_pgdat(pgdat)
+		register_page_bootmem_info_node(pgdat);
+#endif
 
 	reset_all_zones_managed_pages();
 
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 6b63cd6..ccc6630 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -166,6 +166,12 @@ void __init reset_all_zones_managed_pages(void)
 unsigned long __init free_all_bootmem(void)
 {
 	unsigned long pages;
+#ifdef CONFIG_NEED_MULTIPLE_NODES
+	pg_data_t *pgdat;
+
+	for_each_online_pgdat(pgdat)
+		register_page_bootmem_info_node(pgdat);
+#endif
 
 	reset_all_zones_managed_pages();
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
