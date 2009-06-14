Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B518E6B004F
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 09:31:12 -0400 (EDT)
Received: by pzk34 with SMTP id 34so1335803pzk.12
        for <linux-mm@kvack.org>; Sun, 14 Jun 2009 06:32:10 -0700 (PDT)
From: Magnus Damm <magnus.damm@gmail.com>
Date: Sun, 14 Jun 2009 22:28:45 +0900
Message-Id: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se>
Subject: [PATCH][RFC] mm: uncached vma support with writenotify
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org, jayakumar.lkml@gmail.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Magnus Damm <damm@igel.co.jp>

This patch modifies the generic mmap() code to keep the cache
attribute in vma->vm_page_prot regardless if writenotify is 
enabled or not. Without this patch the cache configuration
selected by f_op->mmap() is overwritten if writenotify is
enabled, making it impossible to keep the vma uncached.

Needed by drivers such as drivers/video/sh_mobile_lcdcfb.c
which uses deferred io together with uncached memory.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 Everyone: Maybe there is a cleaner way to do this?

 Jaya: Will post a patch for deferred io to use fb_pgprotect()
 in the non-vmalloc mmap() case. That patch together with this
 allow architectures to use uncached memory with deferred io.

 mm/mmap.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

--- 0001/mm/mmap.c
+++ work/mm/mmap.c	2009-06-11 21:43:16.000000000 +0900
@@ -1209,8 +1209,20 @@ munmap_back:
 	pgoff = vma->vm_pgoff;
 	vm_flags = vma->vm_flags;
 
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
