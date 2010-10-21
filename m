Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B49C5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 08:28:53 -0400 (EDT)
Received: from localhost.localdomain by digidescorp.com (Cipher TLSv1:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001457148.msg
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 07:28:43 -0500
From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH V3] nommu: add anonymous page memcg accounting
Date: Thu, 21 Oct 2010 07:28:08 -0500
Message-Id: <1287664088-4483-1-git-send-email-steve@digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: balbir@linux.vnet.ibm.com, dhowells@redhat.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, "Steven J. Magnani" <steve@digidescorp.com>
List-ID: <linux-mm.kvack.org>

Add the necessary calls to track VM anonymous page usage (only).

V3 changes:
* Use vma->vm_mm instead of current->mm when charging pages, for clarity
* Document that reclaim is not possible with only anonymous page accounting
  so the OOM-killer is invoked when a limit is exceeded
* Add TODO to implement file cache (reclaim) support or optimize away
  page_cgroup->lru

V2 changes:
* Added update of memory cgroup documentation
* Clarify use of 'file' to distinguish anonymous mappings

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
---
diff -uprN a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
--- a/Documentation/cgroups/memory.txt	2010-10-05 09:14:36.000000000 -0500
+++ b/Documentation/cgroups/memory.txt	2010-10-21 07:25:24.000000000 -0500
@@ -34,6 +34,7 @@ Current Status: linux-2.6.34-mmotm(devel
 
 Features:
  - accounting anonymous pages, file caches, swap caches usage and limiting them.
+   NOTE: On NOMMU systems, only anonymous pages are accounted.
  - private LRU and reclaim routine. (system's global LRU and private LRU
    work independently from each other)
  - optionally, memory+swap usage can be accounted and limited.
@@ -640,13 +641,41 @@ At reading, current status of OOM is sho
 	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
 
-11. TODO
+11. NOMMU Support
+
+Systems without a Memory Management Unit do not support virtual memory,
+swapping, page faults, or migration, and are therefore limited to operating
+entirely within the system's RAM. On such systems, maintaining an ability to
+allocate sufficiently large blocks of contiguous memory is usually a challenge.
+This makes the overhead involved in memory cgroup support more of a concern,
+particularly when the memory page size is small.
+
+Typically, embedded systems are comparatively simple and deterministic, and are
+required to remain stable over long periods. Invocation of the OOM-killer, were
+it to occur in an uncontrolled manner, would likely destabilize such systems.
+
+Even a well-designed system may be presented with external stimuli that could
+lead to OOM conditions. One example is a system that is required to check a
+user-supplied removable FAT filesystem. As there is no way to bound the size
+or coherence of the user's filesystem, the memory required to run dosfsck on
+it may exceed the system's capacity. Running dosfsck in a memory cgroup
+can preserve system stability even in the face of excessive memory demands.
+
+At the present time, only anonymous pages are included in NOMMU memory cgroup
+accounting. As anonymous pages are not reclaimable, when a memory cgroup
+exceeds its limit, reclaim will fail and the OOM-killer will be invoked.
+See the Reclaim section of this document.
+
+12. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
 3. Teach controller to account for shared-pages
 4. Start reclamation in the background when the limit is
    not yet hit but the usage is getting closer
+5. NOMMU: implement file cache accounting (which would support reclaim)
+   or optimize away page_cgroup->lru, which is just per-page overhead when
+   reclaim is not supported.
 
 Summary
 
diff -uprN a/mm/nommu.c b/mm/nommu.c
--- a/mm/nommu.c	2010-10-13 08:20:38.000000000 -0500
+++ b/mm/nommu.c	2010-10-20 07:34:11.000000000 -0500
@@ -524,8 +524,10 @@ static void delete_nommu_region(struct v
 /*
  * free a contiguous series of pages
  */
-static void free_page_series(unsigned long from, unsigned long to)
+static void free_page_series(unsigned long from, unsigned long to,
+			     const struct file *file)
 {
+	mem_cgroup_uncharge_start();
 	for (; from < to; from += PAGE_SIZE) {
 		struct page *page = virt_to_page(from);
 
@@ -534,8 +536,13 @@ static void free_page_series(unsigned lo
 		if (page_count(page) != 1)
 			kdebug("free page %p: refcount not one: %d",
 			       page, page_count(page));
+		/* Only anonymous pages are charged, currently */
+		if (!file)
+			mem_cgroup_uncharge_page(page);
+
 		put_page(page);
 	}
+	mem_cgroup_uncharge_end();
 }
 
 /*
@@ -563,7 +570,8 @@ static void __put_nommu_region(struct vm
 		 * from ramfs/tmpfs mustn't be released here */
 		if (region->vm_flags & VM_MAPPED_COPY) {
 			kdebug("free series");
-			free_page_series(region->vm_start, region->vm_top);
+			free_page_series(region->vm_start, region->vm_top,
+					 region->vm_file);
 		}
 		kmem_cache_free(vm_region_jar, region);
 	} else {
@@ -1117,9 +1125,27 @@ static int do_mmap_private(struct vm_are
 		set_page_refcounted(&pages[point]);
 
 	base = page_address(pages);
-	region->vm_flags = vma->vm_flags |= VM_MAPPED_COPY;
+
 	region->vm_start = (unsigned long) base;
 	region->vm_end   = region->vm_start + rlen;
+
+	/* Only anonymous pages are charged, currently */
+	if (!vma->vm_file) {
+		for (point = 0; point < total; point++) {
+			int charge_failed =
+				mem_cgroup_newpage_charge(&pages[point],
+							  vma->vm_mm,
+							  GFP_KERNEL);
+			if (charge_failed) {
+				free_page_series(region->vm_start,
+						 region->vm_end, NULL);
+				region->vm_start = region->vm_end = 0;
+				goto enomem;
+			}
+		}
+	}
+
+	region->vm_flags = vma->vm_flags |= VM_MAPPED_COPY;
 	region->vm_top   = region->vm_start + (total << PAGE_SHIFT);
 
 	vma->vm_start = region->vm_start;
@@ -1150,7 +1176,7 @@ static int do_mmap_private(struct vm_are
 	return 0;
 
 error_free:
-	free_page_series(region->vm_start, region->vm_end);
+	free_page_series(region->vm_start, region->vm_end, vma->vm_file);
 	region->vm_start = vma->vm_start = 0;
 	region->vm_end   = vma->vm_end = 0;
 	region->vm_top   = 0;
@@ -1213,16 +1239,15 @@ unsigned long do_mmap_pgoff(struct file 
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_flags = vm_flags;
 	vma->vm_pgoff = pgoff;
+	vma->vm_mm    = current->mm;
 
 	if (file) {
 		region->vm_file = file;
 		get_file(file);
 		vma->vm_file = file;
 		get_file(file);
-		if (vm_flags & VM_EXECUTABLE) {
+		if (vm_flags & VM_EXECUTABLE)
 			added_exe_file_vma(current->mm);
-			vma->vm_mm = current->mm;
-		}
 	}
 
 	down_write(&nommu_region_sem);
@@ -1555,7 +1580,7 @@ static int shrink_vma(struct mm_struct *
 	add_nommu_region(region);
 	up_write(&nommu_region_sem);
 
-	free_page_series(from, to);
+	free_page_series(from, to, vma->vm_file);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
