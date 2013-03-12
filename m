Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id B60D36B0006
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 22:43:09 -0400 (EDT)
Message-ID: <513E9626.9080206@huawei.com>
Date: Tue, 12 Mar 2013 10:42:46 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: mm/hotplug: fix build warning when CONFIG_MEMORY_HOTREMOVE=n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, qiuxishi <qiuxishi@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is a warning while building kernel with
CONFIG_MEMORY_HOTPLUG=y && CONFIG_MEMORY_HOTREMOVE=n:
arch/x86/mm/init_64.c:1024: warning:kernel_physical_mapping_remove defined but not used

So move kernel_physical_mapping_remove() into "#ifdef CONFIG_MEMORY_HOTREMOVE" block

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 arch/x86/mm/init_64.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 474e28f..dafdeb2 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1019,6 +1019,7 @@ void __ref vmemmap_free(struct page *memmap, unsigned long nr_pages)
 	remove_pagetable(start, end, false);
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
 static void __meminit
 kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 {
@@ -1028,7 +1029,6 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	remove_pagetable(start, end, true);
 }
 
-#ifdef CONFIG_MEMORY_HOTREMOVE
 int __ref arch_remove_memory(u64 start, u64 size)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
-- 
1.7.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
