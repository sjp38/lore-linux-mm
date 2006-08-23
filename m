Date: Wed, 23 Aug 2006 20:40:19 +0900
From: Akinobu Mita <mita@miraclelinux.com>
Subject: [RFC PATCH] prevent from killing OOM disabled task in do_page_fault()
Message-ID: <20060823114019.GB7834@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The process protected from oom-killer may be killed when do_page_fault()
runs out of memory. This patch skips those processes as well as init task.

I couldn't touch several architectures (arm cris frv parisc sparc sparc64).
Because there is no survival path in that case for now.

Signed-off-by: Akinobu Mita <mita@miraclelinux.com>

 arch/alpha/mm/fault.c   |    2 +-
 arch/arm26/mm/fault.c   |    2 +-
 arch/i386/mm/fault.c    |    2 +-
 arch/ia64/mm/fault.c    |    2 +-
 arch/m32r/mm/fault.c    |    2 +-
 arch/m68k/mm/fault.c    |    2 +-
 arch/mips/mm/fault.c    |    2 +-
 arch/powerpc/mm/fault.c |    2 +-
 arch/ppc/mm/fault.c     |    2 +-
 arch/s390/mm/fault.c    |    2 +-
 arch/sh/mm/fault.c      |    2 +-
 arch/sh64/mm/fault.c    |    2 +-
 arch/x86_64/mm/fault.c  |    2 +-
 arch/xtensa/mm/fault.c  |    2 +-
 14 files changed, 14 insertions(+), 14 deletions(-)

Index: work-failmalloc/arch/alpha/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/alpha/mm/fault.c
+++ work-failmalloc/arch/alpha/mm/fault.c
@@ -193,7 +193,7 @@ do_page_fault(unsigned long address, uns
 	/* We ran out of memory, or some other thing happened to us that
 	   made us unable to handle the page fault gracefully.  */
  out_of_memory:
-	if (current->pid == 1) {
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/arm26/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/arm26/mm/fault.c
+++ work-failmalloc/arch/arm26/mm/fault.c
@@ -185,7 +185,7 @@ survive:
 	}
 
 	fault = -3; /* out of memory */
-	if (tsk->pid != 1)
+	if (tsk->pid != 1 && tsk->oomkilladj != OOM_DISABLE)
 		goto out;
 
 	/*
Index: work-failmalloc/arch/i386/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/i386/mm/fault.c
+++ work-failmalloc/arch/i386/mm/fault.c
@@ -598,7 +598,7 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (tsk->pid == 1) {
+	if (tsk->pid == 1 || tsk->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/ia64/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/ia64/mm/fault.c
+++ work-failmalloc/arch/ia64/mm/fault.c
@@ -278,7 +278,7 @@ ia64_do_page_fault (unsigned long addres
 
   out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (current->pid == 1) {
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/m32r/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/m32r/mm/fault.c
+++ work-failmalloc/arch/m32r/mm/fault.c
@@ -299,7 +299,7 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (tsk->pid == 1) {
+	if (tsk->pid == 1 || tsk->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/m68k/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/m68k/mm/fault.c
+++ work-failmalloc/arch/m68k/mm/fault.c
@@ -181,7 +181,7 @@ good_area:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (current->pid == 1) {
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/mips/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/mips/mm/fault.c
+++ work-failmalloc/arch/mips/mm/fault.c
@@ -171,7 +171,7 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (tsk->pid == 1) {
+	if (tsk->pid == 1 || tsk->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/powerpc/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/powerpc/mm/fault.c
+++ work-failmalloc/arch/powerpc/mm/fault.c
@@ -386,7 +386,7 @@ bad_area_nosemaphore:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (current->pid == 1) {
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/ppc/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/ppc/mm/fault.c
+++ work-failmalloc/arch/ppc/mm/fault.c
@@ -291,7 +291,7 @@ bad_area:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (current->pid == 1) {
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/s390/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/s390/mm/fault.c
+++ work-failmalloc/arch/s390/mm/fault.c
@@ -315,7 +315,7 @@ no_context:
 */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (tsk->pid == 1) {
+	if (tsk->pid == 1 || tsk->oomkilladj == OOM_DISABLE) {
 		yield();
 		goto survive;
 	}
Index: work-failmalloc/arch/sh/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/sh/mm/fault.c
+++ work-failmalloc/arch/sh/mm/fault.c
@@ -160,7 +160,7 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (current->pid == 1) {
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/sh64/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/sh64/mm/fault.c
+++ work-failmalloc/arch/sh64/mm/fault.c
@@ -326,7 +326,7 @@ out_of_memory:
 	}
 	printk("fault:Out of memory\n");
 	up_read(&mm->mmap_sem);
-	if (current->pid == 1) {
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;
Index: work-failmalloc/arch/x86_64/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/x86_64/mm/fault.c
+++ work-failmalloc/arch/x86_64/mm/fault.c
@@ -586,7 +586,7 @@ no_context:
  */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (current->pid == 1) { 
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		goto again;
 	}
Index: work-failmalloc/arch/xtensa/mm/fault.c
===================================================================
--- work-failmalloc.orig/arch/xtensa/mm/fault.c
+++ work-failmalloc/arch/xtensa/mm/fault.c
@@ -144,7 +144,7 @@ bad_area:
 	 */
 out_of_memory:
 	up_read(&mm->mmap_sem);
-	if (current->pid == 1) {
+	if (current->pid == 1 || current->oomkilladj == OOM_DISABLE) {
 		yield();
 		down_read(&mm->mmap_sem);
 		goto survive;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
