Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id E21456B0036
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 03:02:03 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 12:20:27 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 4DC98E004F
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 12:32:41 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8373nOp29950050
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 12:33:49 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8371vWB011664
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 12:31:58 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 4/4] mm/vmalloc: don't assume vmap_area w/o VM_VM_AREA flag is vm_map_ram allocation 
Date: Tue,  3 Sep 2013 15:01:46 +0800
Message-Id: <1378191706-29696-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378191706-29696-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1378191706-29696-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

There is a race window between vmap_area free and show vmap_area information.

	A                                                B

remove_vm_area
spin_lock(&vmap_area_lock);
va->flags &= ~VM_VM_AREA;
spin_unlock(&vmap_area_lock);
						spin_lock(&vmap_area_lock);
						if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEZING))
							return 0;
						if (!(va->flags & VM_VM_AREA)) {
							seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
								(void *)va->va_start, (void *)va->va_end,
								va->va_end - va->va_start);
							return 0;
						}
free_unmap_vmap_area(va);
	flush_cache_vunmap
	free_unmap_vmap_area_noflush
		unmap_vmap_area
		free_vmap_area_noflush
			va->flags |= VM_LAZY_FREE 

The assumption is introduced by commit: d4033afd(mm, vmalloc: iterate vmap_area_list, 
instead of vmlist, in vmallocinfo()). This patch fix it by drop the assumption and 
keep not dump vm_map_ram allocation information as the logic before that commit.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5368b17..62b7932 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2586,13 +2586,6 @@ static int s_show(struct seq_file *m, void *p)
 	if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEING))
 		return 0;
 
-	if (!(va->flags & VM_VM_AREA)) {
-		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
-			(void *)va->va_start, (void *)va->va_end,
-					va->va_end - va->va_start);
-		return 0;
-	}
-
 	v = va->vm;
 
 	seq_printf(m, "0x%pK-0x%pK %7ld",
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
