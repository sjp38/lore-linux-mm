Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA02120
	for <linux-mm@kvack.org>; Tue, 1 Jun 1999 15:45:56 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906011945.MAA02908@google.engr.sgi.com>
Subject: [RFC] [PATCH] kanoj-mm6.0-2.2.9 get_unmapped_area needs to search more
Date: Tue, 1 Jun 1999 12:45:36 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

When MAP_FIXED is not specified, and the user provides a hint to mmap,
it seems to me that get_unmapped_area does not search the entire 
allocatable range. Whereas the code does search the range [addr ..
TASK_SIZE], it does not check whether an allocatable area exists in
the range [TASK_UNMAPPED_BASE .. addr]. I am not sure if Linux 
mmap claims to be 100% POSIX compliant, if it does, I do not think
this is the right POSIX behavior.

This patch adds in the code to search the range [TASK_UNMAPPED_BASE .. 
addr] when needed. 

As a side effect, the shm.c code also needs to change slightly (else
it can get into an infinite loop), since it assumes that 
get_unmapped_area does not search below the input hint.

Kanoj
kanoj@engr.sgi.com


--- /usr/tmp/p_rdiff_a00B-1/mmap.c	Tue Jun  1 12:31:24 1999
+++ mm/mmap.c	Tue Jun  1 12:00:23 1999
@@ -182,7 +182,8 @@
 	if ((len = PAGE_ALIGN(len)) == 0)
 		return addr;
 
-	if (len > TASK_SIZE || addr > TASK_SIZE-len)
+	if ((len > TASK_SIZE) || ((addr > TASK_SIZE-len) &&
+						(flags & MAP_FIXED)))
 		return -EINVAL;
 
 	/* offset overflow? */
@@ -352,10 +353,14 @@
 /* Get an address range which is currently unmapped.
  * For mmap() without MAP_FIXED and shmat() with addr=0.
  * Return value 0 means ENOMEM.
+ * Allocates an addr range over PAGE_ALIGN(TASK_UNMAPPED_BASE)
+ * unless caller hints otherwise. When a hint is provided,
+ * may need two passes to search the allocatable range.
  */
 unsigned long get_unmapped_area(unsigned long addr, unsigned long len)
 {
-	struct vm_area_struct * vmm;
+	struct vm_area_struct *vmm, *startvma;
+	int searchback = 0;
 
 	if (len > TASK_SIZE)
 		return 0;
@@ -362,15 +367,39 @@
 	if (!addr)
 		addr = TASK_UNMAPPED_BASE;
 	addr = PAGE_ALIGN(addr);
+	if (addr > PAGE_ALIGN(TASK_UNMAPPED_BASE))
+		searchback = 1;
 
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (startvma = vmm = find_vma(current->mm, addr); ;
+						vmm = vmm->vm_next) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (TASK_SIZE - len < addr)
-			return 0;
+			break;
 		if (!vmm || addr + len <= vmm->vm_start)
 			return addr;
 		addr = vmm->vm_end;
 	}
+	if (searchback == 0)
+		return(0);
+	addr = PAGE_ALIGN(TASK_UNMAPPED_BASE);
+	for (vmm = find_vma(current->mm, addr); vmm != startvma;
+						vmm = vmm->vm_next) {
+		if (TASK_SIZE - len < addr)
+			return(0);
+		if (addr + len <= vmm->vm_start)
+			return addr;
+		addr = vmm->vm_end;
+	}
+	if (startvma) {
+		if (TASK_SIZE - len < addr)
+			return(0);
+		if (addr + len <= startvma->vm_start)
+			return addr;
+	} else {
+		if (len <= (TASK_SIZE - addr))
+			return addr;
+	}
+	return(0);
 }
 
 #define vm_avl_empty	(struct vm_area_struct *) NULL
--- /usr/tmp/p_rdiff_a00GZ_/shm.c	Tue Jun  1 12:31:58 1999
+++ ipc/shm.c	Tue Jun  1 12:23:01 1999
@@ -437,14 +437,17 @@
 	}
 
 	if (!(addr = (ulong) shmaddr)) {
+		unsigned long addr0 = 0;
+
 		if (shmflg & SHM_REMAP)
 			goto out;
 		err = -ENOMEM;
-		addr = 0;
 	again:
 		if (!(addr = get_unmapped_area(addr, shp->u.shm_segsz)))
 			goto out;
 		if(addr & (SHMLBA - 1)) {
+			if (addr <= addr0) goto out;
+			addr0 = addr;
 			addr = (addr + (SHMLBA - 1)) & ~(SHMLBA - 1);
 			goto again;
 		}
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
