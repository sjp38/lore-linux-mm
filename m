Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A4FB76B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 02:55:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 20 Aug 2013 12:15:12 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id A98ED1258055
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:24:59 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7K6tBCQ43581690
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:25:11 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7K6tDTw001746
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:25:14 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 4/4] mm/vmalloc: use wrapper function get_vm_area_size to caculate size of vm area
Date: Tue, 20 Aug 2013 14:54:56 +0800
Message-Id: <1376981696-4312-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

v1 -> v2:
 * replace all the spots by function get_vm_area_size().

Use wrapper function get_vm_area_size to calculate size of vm area.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 93d3182..1074543 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1258,7 +1258,7 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 {
 	unsigned long addr = (unsigned long)area->addr;
-	unsigned long end = addr + area->size - PAGE_SIZE;
+	unsigned long end = addr + get_vm_area_size(area);
 	int err;
 
 	err = vmap_page_range(addr, end, prot, *pages);
@@ -1553,7 +1553,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	unsigned int nr_pages, array_size, i;
 	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
 
-	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
+	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
 
 	area->nr_pages = nr_pages;
@@ -1985,7 +1985,7 @@ long vread(char *buf, char *addr, unsigned long count)
 
 		vm = va->vm;
 		vaddr = (char *) vm->addr;
-		if (addr >= vaddr + vm->size - PAGE_SIZE)
+		if (addr >= vaddr + get_vm_area_size(vm))
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -1995,7 +1995,7 @@ long vread(char *buf, char *addr, unsigned long count)
 			addr++;
 			count--;
 		}
-		n = vaddr + vm->size - PAGE_SIZE - addr;
+		n = vaddr + get_vm_area_size(vm) - addr;
 		if (n > count)
 			n = count;
 		if (!(vm->flags & VM_IOREMAP))
@@ -2067,7 +2067,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 
 		vm = va->vm;
 		vaddr = (char *) vm->addr;
-		if (addr >= vaddr + vm->size - PAGE_SIZE)
+		if (addr >= vaddr + get_vm_area_size(vm))
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -2076,7 +2076,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 			addr++;
 			count--;
 		}
-		n = vaddr + vm->size - PAGE_SIZE - addr;
+		n = vaddr + get_vm_area_size(vm) - addr;
 		if (n > count)
 			n = count;
 		if (!(vm->flags & VM_IOREMAP)) {
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
