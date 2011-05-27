Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A284E6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 23:46:49 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mm: nommu: fix remap_pfn_range()
Date: Fri, 27 May 2011 11:50:03 +0800
Message-ID: <1306468203-8683-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: gerg@snapgear.com, dhowells@redhat.com, lethal@linux-sh.org, geert@linux-m68k.org, vapier@gentoo.org, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

remap_pfn_range() does not update vma->end on no mmu arch which will
cause munmap() fail because it can't match the vma.

eg. fb_mmap() in fbmem.c will call io_remap_pfn_range() which is
remap_pfn_range() on nommu arch, if an address is not page aligned vma->start
will be changed in remap_pfn_range(), but neither size nor vma->end will be
updated. Then munmap(start, len) can't find the vma to free, because it need to
compare (start + len) with vma->end.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/nommu.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 1fd0c51..829848a 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1817,6 +1817,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long from,
 		unsigned long to, unsigned long size, pgprot_t prot)
 {
 	vma->vm_start = vma->vm_pgoff << PAGE_SHIFT;
+	vma->vm_end = vma->vm_start + size;
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
