Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 1D0026B0039
	for <linux-mm@kvack.org>; Sat, 14 Sep 2013 19:45:58 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 15 Sep 2013 05:06:13 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B9738E005A
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:16:46 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8ENls9h45416608
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:17:54 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8ENjpX1019280
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:15:52 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [RESEND PATCH v5 4/4] mm/vmalloc: fix show vmap_area information race with vmap_area tear down 
Date: Sun, 15 Sep 2013 07:45:42 +0800
Message-Id: <1379202342-23140-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 *v4 -> v5: return directly for !VM_VM_AREA case and remove (VM_LAZY_FREE | VM_LAZY_FREEING) check 

There is a race window between vmap_area tear down and show vmap_area information.

	A                                                B

remove_vm_area
spin_lock(&vmap_area_lock);
va->vm = NULL;
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

The assumption !VM_VM_AREA represents vm_map_ram allocation is introduced by 
commit: d4033afd(mm, vmalloc: iterate vmap_area_list, instead of vmlist, in 
vmallocinfo()). However, !VM_VM_AREA also represents vmap_area is being tear 
down in race window mentioned above. This patch fix it by don't dump any 
information for !VM_VM_AREA case and also remove (VM_LAZY_FREE | VM_LAZY_FREEING)
check since they are not possible for !VM_VM_AREA case.

Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/vmalloc.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5368b17..9b75028 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2582,16 +2582,13 @@ static int s_show(struct seq_file *m, void *p)
 {
 	struct vmap_area *va = p;
 	struct vm_struct *v;
-
-	if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEING))
-		return 0;
-
-	if (!(va->flags & VM_VM_AREA)) {
-		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
-			(void *)va->va_start, (void *)va->va_end,
-					va->va_end - va->va_start);
+
+	/*
+	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
+	 * behalf of vmap area is being tear down or vm_map_ram allocation.
+	 */
+	if (!(va->flags & VM_VM_AREA))
 		return 0;
-	}
 
 	v = va->vm;
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
