Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B7D0B6B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 03:22:06 -0500 (EST)
Received: by ywh3 with SMTP id 3so1201496ywh.22
        for <linux-mm@kvack.org>; Fri, 27 Nov 2009 00:22:00 -0800 (PST)
From: Magnus Damm <magnus.damm@gmail.com>
Date: Fri, 27 Nov 2009 17:16:34 +0900
Message-Id: <20091127081634.29712.67793.sendpatchset@rxone.opensource.se>
Subject: [PATCH][RESEND] mm: uncached vma support with writenotify
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org, jayakumar.lkml@gmail.com, akpm@linux-foundation.org, arnd@arndb.de
List-ID: <linux-mm.kvack.org>

From: Magnus Damm <damm@opensource.se>

This patch modifies the generic mmap() code to keep the cache
attribute in vma->vm_page_prot regardless if writenotify is 
enabled or not. Without this patch the cache configuration
selected by f_op->mmap() is overwritten if writenotify is
enabled, making it impossible to keep the vma uncached.

Needed by drivers such as drivers/video/sh_mobile_lcdcfb.c
which uses deferred io together with uncached memory.

Signed-off-by: Magnus Damm <damm@opensource.se>
---

 Identical to the patch sent 20090614.
 It's been a while since then, is it now safe to use
 pgprot_noncached() without #ifdefs?

 mm/mmap.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

--- 0001/mm/mmap.c
+++ work/mm/mmap.c	2009-11-27 16:44:40.000000000 +0900
@@ -1220,8 +1220,20 @@ munmap_back:
 			goto free_vma;
 	}
 
-	if (vma_wants_writenotify(vma))
+	if (vma_wants_writenotify(vma)) {
+		pgprot_t pprot = vma->vm_page_prot;
+
+		/* Can vma->vm_page_prot have changed??
+		 *
+		 * Answer: Yes, drivers may have changed it in their
+		 *         f_op->mmap method.
+		 *
+		 * Ensures that vmas marked as uncached stay that way.
+		 */
 		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
+		if (pgprot_val(pprot) == pgprot_val(pgprot_noncached(pprot)))
+			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	}
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	file = vma->vm_file;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
