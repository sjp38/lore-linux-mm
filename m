Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 59E926B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 04:43:12 -0400 (EDT)
Message-ID: <52205B09.4020800@huawei.com>
Date: Fri, 30 Aug 2013 16:42:49 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/vmalloc: use help function to get vmalloc area size
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, zhangyanfei@cn.fujitsu.com, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use get_vm_area_size() to get vmalloc area's actual size without guard page.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/vmalloc.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 13a5495..abe13bc 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1263,7 +1263,7 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 {
 	unsigned long addr = (unsigned long)area->addr;
-	unsigned long end = addr + area->size - PAGE_SIZE;
+	unsigned long end = addr + get_vm_area_size(area);
 	int err;
 
 	err = vmap_page_range(addr, end, prot, *pages);
@@ -1558,7 +1558,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	unsigned int nr_pages, array_size, i;
 	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
 
-	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
+	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
 
 	area->nr_pages = nr_pages;
@@ -1990,7 +1990,7 @@ long vread(char *buf, char *addr, unsigned long count)
 
 		vm = va->vm;
 		vaddr = (char *) vm->addr;
-		if (addr >= vaddr + vm->size - PAGE_SIZE)
+		if (addr >= vaddr + get_vm_area_size(vm))
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -2000,7 +2000,7 @@ long vread(char *buf, char *addr, unsigned long count)
 			addr++;
 			count--;
 		}
-		n = vaddr + vm->size - PAGE_SIZE - addr;
+		n = vaddr + get_vm_area_size(vm) - addr;
 		if (n > count)
 			n = count;
 		if (!(vm->flags & VM_IOREMAP))
@@ -2072,7 +2072,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 
 		vm = va->vm;
 		vaddr = (char *) vm->addr;
-		if (addr >= vaddr + vm->size - PAGE_SIZE)
+		if (addr >= vaddr + get_vm_area_size(vm))
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -2081,7 +2081,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 			addr++;
 			count--;
 		}
-		n = vaddr + vm->size - PAGE_SIZE - addr;
+		n = vaddr + get_vm_area_size(vm) - addr;
 		if (n > count)
 			n = count;
 		if (!(vm->flags & VM_IOREMAP)) {
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
