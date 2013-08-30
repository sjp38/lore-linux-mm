Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 4DE186B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 04:49:58 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 18:46:37 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 7C2092CE8055
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 18:49:53 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7U8nggw4194762
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 18:49:42 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7U8nquu023149
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 18:49:52 +1000
Date: Fri, 30 Aug 2013 16:49:49 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/vmalloc: use help function to get vmalloc area size
Message-ID: <20130830084949.GA11778@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52205B09.4020800@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52205B09.4020800@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, zhangyanfei@cn.fujitsu.com, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 30, 2013 at 04:42:49PM +0800, Jianguo Wu wrote:
>Use get_vm_area_size() to get vmalloc area's actual size without guard page.
>

Do you see this?

http://marc.info/?l=linux-mm&m=137698172417316&w=2

>Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>---
> mm/vmalloc.c |   12 ++++++------
> 1 files changed, 6 insertions(+), 6 deletions(-)
>
>diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>index 13a5495..abe13bc 100644
>--- a/mm/vmalloc.c
>+++ b/mm/vmalloc.c
>@@ -1263,7 +1263,7 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
> int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
> {
> 	unsigned long addr = (unsigned long)area->addr;
>-	unsigned long end = addr + area->size - PAGE_SIZE;
>+	unsigned long end = addr + get_vm_area_size(area);
> 	int err;
>
> 	err = vmap_page_range(addr, end, prot, *pages);
>@@ -1558,7 +1558,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
> 	unsigned int nr_pages, array_size, i;
> 	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
>
>-	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
>+	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
> 	array_size = (nr_pages * sizeof(struct page *));
>
> 	area->nr_pages = nr_pages;
>@@ -1990,7 +1990,7 @@ long vread(char *buf, char *addr, unsigned long count)
>
> 		vm = va->vm;
> 		vaddr = (char *) vm->addr;
>-		if (addr >= vaddr + vm->size - PAGE_SIZE)
>+		if (addr >= vaddr + get_vm_area_size(vm))
> 			continue;
> 		while (addr < vaddr) {
> 			if (count == 0)
>@@ -2000,7 +2000,7 @@ long vread(char *buf, char *addr, unsigned long count)
> 			addr++;
> 			count--;
> 		}
>-		n = vaddr + vm->size - PAGE_SIZE - addr;
>+		n = vaddr + get_vm_area_size(vm) - addr;
> 		if (n > count)
> 			n = count;
> 		if (!(vm->flags & VM_IOREMAP))
>@@ -2072,7 +2072,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
>
> 		vm = va->vm;
> 		vaddr = (char *) vm->addr;
>-		if (addr >= vaddr + vm->size - PAGE_SIZE)
>+		if (addr >= vaddr + get_vm_area_size(vm))
> 			continue;
> 		while (addr < vaddr) {
> 			if (count == 0)
>@@ -2081,7 +2081,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
> 			addr++;
> 			count--;
> 		}
>-		n = vaddr + vm->size - PAGE_SIZE - addr;
>+		n = vaddr + get_vm_area_size(vm) - addr;
> 		if (n > count)
> 			n = count;
> 		if (!(vm->flags & VM_IOREMAP)) {
>-- 
>1.7.1
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
