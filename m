Received: from deliverator.sgi.com (deliverator.sgi.com [204.94.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA00464
	for <linux-mm@kvack.org>; Tue, 1 Jun 1999 13:08:05 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906011707.KAA40746@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm5.0-2.2.9 Unify and enhance find_extend_vma
Date: Tue, 1 Jun 1999 10:07:50 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

find_extend_vma misses doing a couple of checks and updating 
some variables. It does not check total_vm against 
RLIMIT_AS.rlim_cur, and fails to update total_vm and locked_vm.
This is probably partly because of code duplication. Since all
versions of find_extend_vma are exactly similar, this patch
makes find_extend_vma a platform independent function, and 
properly invokes expand_stack to do the right checks and
updates. The new find_extend_vma also faults and locks in 
pages for locked vma's to go hand-in-hand with the update of
locked_vm in expand_stack.

Kanoj
kanoj@engr.sgi.com

--- /usr/tmp/p_rdiff_a00GNO/ptrace.c	Mon May 31 22:50:06 1999
+++ arch/alpha/kernel/ptrace.c	Mon May 31 18:27:12 1999
@@ -246,26 +246,6 @@
 	flush_tlb();
 }
 
-static struct vm_area_struct *
-find_extend_vma(struct task_struct * tsk, unsigned long addr)
-{
-	struct vm_area_struct * vma;
-
-	addr &= PAGE_MASK;
-	vma = find_vma(tsk->mm,addr);
-	if (!vma)
-		return NULL;
-	if (vma->vm_start <= addr)
-		return vma;
-	if (!(vma->vm_flags & VM_GROWSDOWN))
-		return NULL;
-	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
-		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
-	vma->vm_start = addr;
-	return vma;
-}
-
 /*
  * This routine checks the page boundaries, and that the offset is
  * within the task area. It then calls get_long() to read a long.
--- /usr/tmp/p_rdiff_a00FNA/ptrace.c	Mon May 31 22:50:12 1999
+++ arch/arm/kernel/ptrace.c	Mon May 31 18:27:32 1999
@@ -164,25 +164,6 @@
 	flush_tlb();
 }
 
-static struct vm_area_struct * find_extend_vma(struct task_struct * tsk, unsigned long addr)
-{
-	struct vm_area_struct * vma;
-
-	addr &= PAGE_MASK;
-	vma = find_vma(tsk->mm,addr);
-	if (!vma)
-		return NULL;
-	if (vma->vm_start <= addr)
-		return vma;
-	if (!(vma->vm_flags & VM_GROWSDOWN))
-		return NULL;
-	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
-		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
-	vma->vm_start = addr;
-	return vma;
-}
-
 /*
  * This routine checks the page boundaries, and that the offset is
  * within the task area. It then calls get_long() to read a long.
--- /usr/tmp/p_rdiff_a00GPZ/ptrace.c	Mon May 31 22:50:18 1999
+++ arch/i386/kernel/ptrace.c	Mon May 31 18:28:56 1999
@@ -172,25 +172,6 @@
 	flush_tlb();
 }
 
-static struct vm_area_struct * find_extend_vma(struct task_struct * tsk, unsigned long addr)
-{
-	struct vm_area_struct * vma;
-
-	addr &= PAGE_MASK;
-	vma = find_vma(tsk->mm,addr);
-	if (!vma)
-		return NULL;
-	if (vma->vm_start <= addr)
-		return vma;
-	if (!(vma->vm_flags & VM_GROWSDOWN))
-		return NULL;
-	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
-		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
-	vma->vm_start = addr;
-	return vma;
-}
-
 /*
  * This routine checks the page boundaries, and that the offset is
  * within the task area. It then calls get_long() to read a long.
--- /usr/tmp/p_rdiff_a00G4B/ptrace.c	Mon May 31 22:50:24 1999
+++ arch/m68k/kernel/ptrace.c	Mon May 31 18:27:50 1999
@@ -196,25 +196,6 @@
 	flush_tlb_all();
 }
 
-static struct vm_area_struct * find_extend_vma(struct task_struct * tsk, unsigned long addr)
-{
-	struct vm_area_struct * vma;
-
-	addr &= PAGE_MASK;
-	vma = find_vma(tsk->mm, addr);
-	if (!vma)
-		return NULL;
-	if (vma->vm_start <= addr)
-		return vma;
-	if (!(vma->vm_flags & VM_GROWSDOWN))
-		return NULL;
-	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
-		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
-	vma->vm_start = addr;
-	return vma;
-}
-
 /*
  * This routine checks the page boundaries, and that the offset is
  * within the task area. It then calls get_long() to read a long.
--- /usr/tmp/p_rdiff_a00BKC/ptrace.c	Mon May 31 22:50:30 1999
+++ arch/mips/kernel/ptrace.c	Mon May 31 18:27:59 1999
@@ -143,25 +143,6 @@
 	flush_tlb_page(vma, addr);
 }
 
-static struct vm_area_struct * find_extend_vma(struct task_struct * tsk, unsigned long addr)
-{
-	struct vm_area_struct * vma;
-
-	addr &= PAGE_MASK;
-	vma = find_vma(tsk->mm, addr);
-	if (!vma)
-		return NULL;
-	if (vma->vm_start <= addr)
-		return vma;
-	if (!(vma->vm_flags & VM_GROWSDOWN))
-		return NULL;
-	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
-		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
-	vma->vm_start = addr;
-	return vma;
-}
-
 /*
  * This routine checks the page boundaries, and that the offset is
  * within the task area. It then calls get_long() to read a long.
--- /usr/tmp/p_rdiff_a00GX7/ptrace.c	Mon May 31 22:50:36 1999
+++ arch/ppc/kernel/ptrace.c	Mon May 31 18:28:08 1999
@@ -190,25 +190,6 @@
 	flush_tlb_all();
 }
 
-static struct vm_area_struct * find_extend_vma(struct task_struct * tsk, unsigned long addr)
-{
-	struct vm_area_struct * vma;
-
-	addr &= PAGE_MASK;
-	vma = find_vma(tsk->mm,addr);
-	if (!vma)
-		return NULL;
-	if (vma->vm_start <= addr)
-		return vma;
-	if (!(vma->vm_flags & VM_GROWSDOWN))
-		return NULL;
-	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
-		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
-	vma->vm_start = addr;
-	return vma;
-}
-
 /*
  * This routine checks the page boundaries, and that the offset is
  * within the task area. It then calls get_long() to read a long.
--- /usr/tmp/p_rdiff_a00GXw/ptrace.c	Mon May 31 22:50:42 1999
+++ arch/sparc/kernel/ptrace.c	Mon May 31 18:28:30 1999
@@ -134,26 +134,6 @@
 	flush_tlb_page(vma, addr);
 }
 
-static struct vm_area_struct * find_extend_vma(struct task_struct * tsk,
-					       unsigned long addr)
-{
-	struct vm_area_struct * vma;
-
-	addr &= PAGE_MASK;
-	vma = find_vma(tsk->mm,addr);
-	if (!vma)
-		return NULL;
-	if (vma->vm_start <= addr)
-		return vma;
-	if (!(vma->vm_flags & VM_GROWSDOWN))
-		return NULL;
-	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
-		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
-	vma->vm_start = addr;
-	return vma;
-}
-
 /*
  * This routine checks the page boundaries, and that the offset is
  * within the task area. It then calls get_long() to read a long.
--- /usr/tmp/p_rdiff_a00EtZ/ptrace.c	Mon May 31 22:50:49 1999
+++ arch/sparc64/kernel/ptrace.c	Mon May 31 18:28:38 1999
@@ -204,26 +204,6 @@
 	flush_tlb_page(vma, addr);
 }
 
-static struct vm_area_struct * find_extend_vma(struct task_struct * tsk,
-					       unsigned long addr)
-{
-	struct vm_area_struct * vma;
-
-	addr &= PAGE_MASK;
-	vma = find_vma(tsk->mm,addr);
-	if (!vma)
-		return NULL;
-	if (vma->vm_start <= addr)
-		return vma;
-	if (!(vma->vm_flags & VM_GROWSDOWN))
-		return NULL;
-	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
-		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
-	vma->vm_start = addr;
-	return vma;
-}
-
 /*
  * This routine checks the page boundaries, and that the offset is
  * within the task area. It then calls get_long() to read a long.
--- /usr/tmp/p_rdiff_a007MM/mm.h	Mon May 31 22:50:55 1999
+++ include/linux/mm.h	Mon May 31 18:32:44 1999
@@ -382,6 +382,8 @@
 	return vma;
 }
 
+extern struct vm_area_struct *find_extend_vma(struct task_struct *tsk, unsigned long addr);
+
 #define buffer_under_min()	((buffermem >> PAGE_SHIFT) * 100 < \
 				buffer_mem.min_percent * num_physpages)
 #define pgcache_under_min()	(page_cache_size * 100 < \
--- /usr/tmp/p_rdiff_a00CuV/mmap.c	Mon May 31 23:54:15 1999
+++ mm/mmap.c	Mon May 31 23:46:29 1999
@@ -467,6 +467,28 @@
 	return NULL;
 }
 
+struct vm_area_struct * find_extend_vma(struct task_struct * tsk, unsigned long addr)
+{
+	struct vm_area_struct * vma;
+	unsigned long start;
+
+	addr &= PAGE_MASK;
+	vma = find_vma(tsk->mm,addr);
+	if (!vma)
+		return NULL;
+	if (vma->vm_start <= addr)
+		return vma;
+	if (!(vma->vm_flags & VM_GROWSDOWN))
+		return NULL;
+	start = vma->vm_start;
+	if (expand_stack(vma, addr))
+		return NULL;
+	if (vma->vm_flags & VM_LOCKED) {
+		make_pages_present(addr, start);
+	}
+	return vma;
+}
+
 /* Normal function to fix up a mapping
  * This function is the default for when an area has no specific
  * function.  This may be used as part of a more specific routine.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
