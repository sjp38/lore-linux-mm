Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9306B0035
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 16:45:56 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so1028983eek.6
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 13:45:55 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.20])
        by mx.google.com with ESMTPS id z2si2778012eeo.184.2014.04.17.13.45.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA bits=256/256);
        Thu, 17 Apr 2014 13:45:55 -0700 (PDT)
Date: Thu, 17 Apr 2014 22:45:45 +0200
From: Helge Deller <deller@gmx.de>
Subject: [RFC,PATCH] mm,parisc: keep track of last mmap'ed address
Message-ID: <20140417204545.GA4567@ls3530.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, James Bottomley <James.Bottomley@HansenPartnership.com>

Would the following patch be acceptable?
It adds an additional field to struct address_space which will most likely only
be used by the parisc arch.

If it's acceptable, I would like to push it through the parisc tree, if not,
I'm of course open to other ideas too.

Thanks,
Helge

PATCH:
[RFC,PATCH] mm,parisc: keep track of last mmap'ed address

Because of parisc's cache aliasing constraints we need to map shared pages at a
multiple of 4MB while most other architectures can map files at any multiple of
PAGE_SIZE. In the past this constraint was ensured by calculating a virtual
offset into this 4MB region which is based on the physical address of the
kernel mapping variable (right-shift value of filp->f_mapping by 8 bits).
Since we only have a 32bit userspace (even when running on a 64bit kernel) this
often leads to large gaps in the maps of the userspace processes and to out of
memory situations even if physical memory was still free.  Of course I did
played with other variants of shifting the f_mapping value to find better
offsets but this didn't helped either.

This patch chooses a different approach.
It adds the additional field i_mmap_lastmmap to the address_space struct to
keep track of the last mapping of a shared file. With this bookkeeping it's
possible for the parisc memory allocator to 
a) choose a new mapping offset if the file hasn't been mapped yet, and
b) take the last-used mapping if it was already mapped by another process.

Overall this approach leads to a more condensed memory usage on parisc because
the shared files will now be mapped much closer to each other. This is e.g.
visible with shared libraries which are now not any longer cluttered around
in the userspace process but close to each other at the top of the userspace
memory.

Signed-off-by: Helge Deller <deller@gmx.de>

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 81048f9..f757a5c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -416,6 +416,9 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
+#ifdef CONFIG_MMAP_TRACKING
+	unsigned long		i_mmap_lastmmap; /* address of last mmap */
+#endif
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
diff --git a/mm/mmap.c b/mm/mmap.c
index b1202cf..e2659c3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -212,8 +212,13 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 {
 	if (vma->vm_flags & VM_DENYWRITE)
 		atomic_inc(&file_inode(file)->i_writecount);
-	if (vma->vm_flags & VM_SHARED)
+	if (vma->vm_flags & VM_SHARED) {
 		mapping->i_mmap_writable--;
+#ifdef CONFIG_MMAP_TRACKING
+		if (mapping->i_mmap_writable == 0)
+			mapping->i_mmap_lastmmap = 0;
+#endif
+	}
 
 	flush_dcache_mmap_lock(mapping);
 	if (unlikely(vma->vm_flags & VM_NONLINEAR))
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index bb2a8ec..9518361 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -38,6 +38,9 @@ config PARISC
 config MMU
 	def_bool y
 
+config MMAP_TRACKING
+	def_bool y
+
 config STACK_GROWSUP
 	def_bool y
 
diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index 31ffa9b..7d8cbd1 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -36,12 +36,12 @@
 #include <linux/personality.h>
 #include <linux/random.h>
 
-/* we construct an artificial offset for the mapping based on the physical
- * address of the kernel mapping variable */
+/* the address_space struct holds a field i_mmap_lastmmap with the last mapping
+ * of this file for us */
 #define GET_LAST_MMAP(filp)		\
-	(filp ? ((unsigned long) filp->f_mapping) >> 8 : 0UL)
+	(filp ? filp->f_mapping->i_mmap_lastmmap : 0UL)
 #define SET_LAST_MMAP(filp, val)	\
-	 { /* nothing */ }
+	{ if (filp) filp->f_mapping->i_mmap_lastmmap = (val); }
 
 static int get_offset(unsigned int last_mmap)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
