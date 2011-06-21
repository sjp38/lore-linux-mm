Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 88BFF9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 23:45:20 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH v2] nommu: fix remap_pfn_range()implemention
Date: Tue, 21 Jun 2011 11:56:20 +0800
Message-ID: <1308628580-3027-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, gerg@snapgear.com, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, uclinux-dist-devel@blackfin.uclinux.org, geert@linux-m68k.org, vapier.adi@gmail.com, Bob Liu <lliubbo@gmail.com>

remap_pfn_range() means map physical address pfn<<PAGE_SHIFT to user addr.

For nommu arch it's implemented by vma->vm_start = pfn << PAGE_SHIFT which is
wrong acroding the original meaning of this function. And some driver
developer using remap_pfn_range() with correct parameter will get unexpected
result because vm_start is changed.
It should be implementd like addr = pfn << PAGE_SHIFT but which is meanless on
nommu arch, this patch just make it simply return.

Parameter name and setting of vma->vm_flags also be fixed.

Reported-by: Scott Jiang <scott.jiang.linux@gmail.com>
Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/nommu.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 1fd0c51..9edc897 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1813,10 +1813,13 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 	return NULL;
 }
 
-int remap_pfn_range(struct vm_area_struct *vma, unsigned long from,
-		unsigned long to, unsigned long size, pgprot_t prot)
+int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
+		unsigned long pfn, unsigned long size, pgprot_t prot)
 {
-	vma->vm_start = vma->vm_pgoff << PAGE_SHIFT;
+	if (addr != (pfn << PAGE_SHIFT))
+		return -EINVAL;
+
+	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
 	return 0;
 }
 EXPORT_SYMBOL(remap_pfn_range);
-- 
1.6.3.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
