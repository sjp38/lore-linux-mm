Received: from midway.verizon.net ([4.5.49.23])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2 HotFix 0.04
 (built Dec 24 2004)) with ESMTPA id <0IDH0052XBYK6U61@vms040.mailsrvcs.net> for
 linux-mm@kvack.org; Wed, 16 Mar 2005 22:47:09 -0600 (CST)
Date: Wed, 16 Mar 2005 20:47:08 -0800
From: "Randy.Dunlap" <randy.dunlap@verizon.net>
Subject: [PATCH/RFC] io_remap_pfn_range: convert io_remap_page_range callers
Message-id: <20050316204708.5adfeebc.randy.dunlap@verizon.net>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Follow-up to
http://marc.theaimsgroup.com/?l=linux-mm&m=111049473410099&w=2
(which has a minor correction, full patch available at:
http://developer.osdl.org/rddunlap/patches/ioremap_pfn_v6.patch)

Built on 9 arches with OSDL PLM.


io_remap_pfn_range() phase 2:
  convert all callers of io_remap_page_range() to io_remap_pfn_range();
  add io_remap_page_range() to feature-removal-schedule.txt;

 Documentation/feature-removal-schedule.txt |    9 +++++++++
 arch/sh/kernel/cpu/sh4/sq.c                |    2 +-
 drivers/video/acornfb.c                    |    2 +-
 drivers/video/au1100fb.c                   |    2 +-
 drivers/video/controlfb.c                  |    2 +-
 drivers/video/sa1100fb.c                   |    2 +-
 sound/core/pcm_native.c                    |    4 ++--
 7 files changed, 16 insertions(+), 7 deletions(-)

diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2611-bk10-remap1/arch/sh/kernel/cpu/sh4/sq.c linux-2611-bk10-remap2/arch/sh/kernel/cpu/sh4/sq.c
--- linux-2611-bk10-remap1/arch/sh/kernel/cpu/sh4/sq.c	2005-03-01 23:38:07.000000000 -0800
+++ linux-2611-bk10-remap2/arch/sh/kernel/cpu/sh4/sq.c	2005-03-16 09:46:10.000000000 -0800
@@ -379,7 +379,7 @@ static int sq_mmap(struct file *file, st
 
 	map = __sq_alloc_mapping(vma->vm_start, offset, size, "Userspace");
 
-	if (io_remap_page_range(vma, map->sq_addr, map->addr,
+	if (io_remap_pfn_range(vma, map->sq_addr, map->addr >> PAGE_SHIFT,
 				size, vma->vm_page_prot))
 		return -EAGAIN;
 
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2611-bk10-remap1/Documentation/feature-removal-schedule.txt linux-2611-bk10-remap2/Documentation/feature-removal-schedule.txt
--- linux-2611-bk10-remap1/Documentation/feature-removal-schedule.txt	2005-03-16 09:16:26.000000000 -0800
+++ linux-2611-bk10-remap2/Documentation/feature-removal-schedule.txt	2005-03-16 10:01:18.000000000 -0800
@@ -31,9 +31,18 @@ Why:	/proc/sys/cpu/* has been deprecated
 	Both interfaces are superseded by the cpufreq interface in
 	/sys/devices/system/cpu/cpu%n/cpufreq/.
 Who:	Dominik Brodowski <linux@brodo.de>
+---------------------------
 
 What:	ACPI S4bios support
 When:	May 2005
 Why:	Noone uses it, and it probably does not work, anyway. swsusp is
 	faster, more reliable, and people are actually using it.
 Who:	Pavel Machek <pavel@suse.cz>
+---------------------------
+
+What:	io_remap_page_range() (macro or function)
+When:	September 2005
+Why:	Replaced by io_remap_pfn_range() which allows more memory space
+	addressabilty (by using a pfn) and supports sparc & sparc64
+	iospace as part of the pfn.
+Who:	Randy Dunlap <rddunlap@osdl.org>
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2611-bk10-remap1/drivers/video/acornfb.c linux-2611-bk10-remap2/drivers/video/acornfb.c
--- linux-2611-bk10-remap1/drivers/video/acornfb.c	2005-03-01 23:38:26.000000000 -0800
+++ linux-2611-bk10-remap2/drivers/video/acornfb.c	2005-03-16 09:38:24.000000000 -0800
@@ -909,7 +909,7 @@ acornfb_mmap(struct fb_info *info, struc
 	 * some updates to the screen occasionally, but process switches
 	 * should cause the caches and buffers to be flushed often enough.
 	 */
-	if (io_remap_page_range(vma, vma->vm_start, off,
+	if (io_remap_pfn_range(vma, vma->vm_start, off >> PAGE_SHIFT,
 				vma->vm_end - vma->vm_start,
 				vma->vm_page_prot))
 		return -EAGAIN;
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2611-bk10-remap1/drivers/video/au1100fb.c linux-2611-bk10-remap2/drivers/video/au1100fb.c
--- linux-2611-bk10-remap1/drivers/video/au1100fb.c	2005-03-01 23:37:48.000000000 -0800
+++ linux-2611-bk10-remap2/drivers/video/au1100fb.c	2005-03-16 09:33:56.000000000 -0800
@@ -408,7 +408,7 @@ au1100fb_mmap(struct fb_info *_fb,
 	/* This is an IO map - tell maydump to skip this VMA */
 	vma->vm_flags |= VM_IO;
 
-	if (io_remap_page_range(vma, vma->vm_start, off,
+	if (io_remap_pfn_range(vma, vma->vm_start, off >> PAGE_SHIFT,
 				vma->vm_end - vma->vm_start,
 				vma->vm_page_prot)) {
 		return -EAGAIN;
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2611-bk10-remap1/drivers/video/controlfb.c linux-2611-bk10-remap2/drivers/video/controlfb.c
--- linux-2611-bk10-remap1/drivers/video/controlfb.c	2005-03-01 23:37:50.000000000 -0800
+++ linux-2611-bk10-remap2/drivers/video/controlfb.c	2005-03-16 09:37:11.000000000 -0800
@@ -315,7 +315,7 @@ static int controlfb_mmap(struct fb_info
        		return -EINVAL;
        off += start;
        vma->vm_pgoff = off >> PAGE_SHIFT;
-       if (io_remap_page_range(vma, vma->vm_start, off,
+       if (io_remap_pfn_range(vma, vma->vm_start, off >> PAGE_SHIFT,
            vma->vm_end - vma->vm_start, vma->vm_page_prot))
                return -EAGAIN;
 
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2611-bk10-remap1/drivers/video/sa1100fb.c linux-2611-bk10-remap2/drivers/video/sa1100fb.c
--- linux-2611-bk10-remap1/drivers/video/sa1100fb.c	2005-03-01 23:37:50.000000000 -0800
+++ linux-2611-bk10-remap2/drivers/video/sa1100fb.c	2005-03-16 09:37:53.000000000 -0800
@@ -836,7 +836,7 @@ static int sa1100fb_mmap(struct fb_info 
 	vma->vm_pgoff = off >> PAGE_SHIFT;
 	vma->vm_flags |= VM_IO;
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-	return io_remap_page_range(vma, vma->vm_start, off,
+	return io_remap_pfn_range(vma, vma->vm_start, off >> PAGE_SHIFT,
 				   vma->vm_end - vma->vm_start,
 				   vma->vm_page_prot);
 }
diff -Naurp -X /home/rddunlap/doc/dontdiff-osdl linux-2611-bk10-remap1/sound/core/pcm_native.c linux-2611-bk10-remap2/sound/core/pcm_native.c
--- linux-2611-bk10-remap1/sound/core/pcm_native.c	2005-03-16 09:17:08.000000000 -0800
+++ linux-2611-bk10-remap2/sound/core/pcm_native.c	2005-03-16 09:39:41.000000000 -0800
@@ -3097,8 +3097,8 @@ int snd_pcm_lib_mmap_iomem(snd_pcm_subst
 	area->vm_flags |= VM_IO;
 	size = area->vm_end - area->vm_start;
 	offset = area->vm_pgoff << PAGE_SHIFT;
-	if (io_remap_page_range(area, area->vm_start,
-				substream->runtime->dma_addr + offset,
+	if (io_remap_pfn_range(area, area->vm_start,
+				(substream->runtime->dma_addr + offset) >> PAGE_SHIFT,
 				size, area->vm_page_prot))
 		return -EAGAIN;
 	atomic_inc(&substream->runtime->mmap_count);


---
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
