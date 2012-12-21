Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id CCFBA6B0085
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:50:22 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id w4so1793925dam.32
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:50:22 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 7/9] mm: remove flags argument to mmap_region
Date: Thu, 20 Dec 2012 16:49:55 -0800
Message-Id: <1356050997-2688-8-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

After the MAP_POPULATE handling has been moved to mmap_region() call sites,
the only remaining use of the flags argument is to pass the MAP_NORESERVE
flag. This can be just as easily handled by do_mmap_pgoff(), so do that
and remove the mmap_region() flags parameter.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/tile/mm/elf.c |    1 -
 include/linux/mm.h |    3 +--
 mm/fremap.c        |    3 +--
 mm/mmap.c          |   33 ++++++++++++++++-----------------
 4 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 3cfa98bf9125..743c951c61b0 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -130,7 +130,6 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	if (!retval) {
 		unsigned long addr = MEM_USER_INTRPT;
 		addr = mmap_region(NULL, addr, INTRPT_SIZE,
-				   MAP_FIXED|MAP_ANONYMOUS|MAP_PRIVATE,
 				   VM_READ|VM_EXEC|
 				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0);
 		if (addr > (unsigned long) -PAGE_SIZE)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fea461cd9027..3b2912f6e91a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1442,8 +1442,7 @@ extern int install_special_mapping(struct mm_struct *mm,
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
-	unsigned long len, unsigned long flags,
-	vm_flags_t vm_flags, unsigned long pgoff);
+	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	unsigned long pgoff, bool *populate);
diff --git a/mm/fremap.c b/mm/fremap.c
index b42e32171530..503a72387087 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -204,9 +204,8 @@ get_write_lock:
 			unsigned long addr;
 			struct file *file = get_file(vma->vm_file);
 
-			flags = (flags & MAP_NONBLOCK) | MAP_POPULATE;
 			addr = mmap_region(file, start, size,
-					flags, vma->vm_flags, pgoff);
+					vma->vm_flags, pgoff);
 			fput(file);
 			if (IS_ERR_VALUE(addr)) {
 				err = addr;
diff --git a/mm/mmap.c b/mm/mmap.c
index 4c8d39e64e80..b0a341e5685f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1138,7 +1138,21 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		}
 	}
 
-	addr = mmap_region(file, addr, len, flags, vm_flags, pgoff);
+	/*
+	 * Set 'VM_NORESERVE' if we should not account for the
+	 * memory use of this mapping.
+	 */
+	if ((flags & MAP_NORESERVE)) {
+		/* We honor MAP_NORESERVE if allowed to overcommit */
+		if (sysctl_overcommit_memory != OVERCOMMIT_NEVER)
+			vm_flags |= VM_NORESERVE;
+
+		/* hugetlb applies strict overcommit unless MAP_NORESERVE */
+		if (file && is_file_hugepages(file))
+			vm_flags |= VM_NORESERVE;
+	}
+
+	addr = mmap_region(file, addr, len, vm_flags, pgoff);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1257,8 +1271,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 }
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
-			  unsigned long len, unsigned long flags,
-			  vm_flags_t vm_flags, unsigned long pgoff)
+		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1282,20 +1295,6 @@ munmap_back:
 		return -ENOMEM;
 
 	/*
-	 * Set 'VM_NORESERVE' if we should not account for the
-	 * memory use of this mapping.
-	 */
-	if ((flags & MAP_NORESERVE)) {
-		/* We honor MAP_NORESERVE if allowed to overcommit */
-		if (sysctl_overcommit_memory != OVERCOMMIT_NEVER)
-			vm_flags |= VM_NORESERVE;
-
-		/* hugetlb applies strict overcommit unless MAP_NORESERVE */
-		if (file && is_file_hugepages(file))
-			vm_flags |= VM_NORESERVE;
-	}
-
-	/*
 	 * Private writable mapping: check memory availability
 	 */
 	if (accountable_mapping(file, vm_flags)) {
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
