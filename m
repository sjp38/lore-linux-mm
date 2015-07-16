Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id E7102280309
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 18:28:06 -0400 (EDT)
Received: by qgy5 with SMTP id 5so39691990qgy.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 15:28:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b24si11412565qkh.67.2015.07.16.15.28.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 15:28:06 -0700 (PDT)
Date: Fri, 17 Jul 2015 00:26:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/1] mm, mpx: add "vm_flags_t vm_flags" arg to
	do_mmap_pgoff()
Message-ID: <20150716222621.GB21791@redhat.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com> <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com> <20150713165323.GA7906@redhat.com> <55A3EFE9.7080101@linux.intel.com> <20150716110503.9A4F5196@black.fi.intel.com> <55A7D38C.7070907@linux.intel.com> <20150716160927.GA27037@node.dhcp.inet.fi> <20150716222603.GA21791@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716222603.GA21791@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

Add the additional "vm_flags_t vm_flags" argument to do_mmap_pgoff(),
rename it to do_mmap(), and re-introduce do_mmap_pgoff() as a simple
wrapper on top of do_mmap(). Perhaps we should update the callers of
do_mmap_pgoff() and kill it later.

This way mpx_mmap() can simply call do_mmap(vm_flags => VM_MPX) and
do not play with vm internals.

After this change mmap_region() has a single user outside of mmap.c,
arch/tile/mm/elf.c:arch_setup_additional_pages(). It would be nice
to change arch/tile/ and unexport mmap_region().

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 arch/x86/mm/mpx.c  |   51 +++++++--------------------------------------------
 include/linux/mm.h |   12 ++++++++++--
 mm/mmap.c          |   10 ++++------
 mm/nommu.c         |   15 ++++++++-------
 4 files changed, 29 insertions(+), 59 deletions(-)

diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 4d1c11c..fdbd3e0 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -24,58 +24,21 @@
  */
 static unsigned long mpx_mmap(unsigned long len)
 {
-	unsigned long ret;
-	unsigned long addr, pgoff;
 	struct mm_struct *mm = current->mm;
-	vm_flags_t vm_flags;
-	struct vm_area_struct *vma;
+	unsigned long addr, populate;
 
 	/* Only bounds table and bounds directory can be allocated here */
 	if (len != MPX_BD_SIZE_BYTES && len != MPX_BT_SIZE_BYTES)
 		return -EINVAL;
 
 	down_write(&mm->mmap_sem);
-
-	/* Too many mappings? */
-	if (mm->map_count > sysctl_max_map_count) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	/* Obtain the address to map to. we verify (or select) it and ensure
-	 * that it represents a valid section of the address space.
-	 */
-	addr = get_unmapped_area(NULL, 0, len, 0, MAP_ANONYMOUS | MAP_PRIVATE);
-	if (addr & ~PAGE_MASK) {
-		ret = addr;
-		goto out;
-	}
-
-	vm_flags = VM_READ | VM_WRITE | VM_MPX |
-			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
-
-	/* Set pgoff according to addr for anon_vma */
-	pgoff = addr >> PAGE_SHIFT;
-
-	ret = mmap_region(NULL, addr, len, vm_flags, pgoff);
-	if (IS_ERR_VALUE(ret))
-		goto out;
-
-	vma = find_vma(mm, ret);
-	if (!vma) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	if (vm_flags & VM_LOCKED) {
-		up_write(&mm->mmap_sem);
-		mm_populate(ret, len);
-		return ret;
-	}
-
-out:
+	addr = do_mmap(NULL, 0, len, PROT_READ | PROT_WRITE,
+			MAP_ANONYMOUS | MAP_PRIVATE, VM_MPX, 0, &populate);
 	up_write(&mm->mmap_sem);
-	return ret;
+	if (populate)
+		mm_populate(addr, populate);
+
+	return addr;
 }
 
 enum reg_type {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0207ffa..1f0a56e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1849,11 +1849,19 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
-extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
-	unsigned long pgoff, unsigned long *populate);
+	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
+static inline unsigned long
+do_mmap_pgoff(struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot, unsigned long flags,
+	unsigned long pgoff, unsigned long *populate)
+{
+	return do_mmap(file, addr, len, prot, flags, 0, pgoff, populate);
+}
+
 #ifdef CONFIG_MMU
 extern int __mm_populate(unsigned long addr, unsigned long len,
 			 int ignore_errors);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2185cd9..2f36ebc 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1247,14 +1247,12 @@ static inline int mlock_future_check(struct mm_struct *mm,
 /*
  * The caller must hold down_write(&current->mm->mmap_sem).
  */
-
-unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+unsigned long do_mmap(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
-			unsigned long flags, unsigned long pgoff,
-			unsigned long *populate)
+			unsigned long flags, vm_flags_t vm_flags,
+			unsigned long pgoff, unsigned long *populate)
 {
 	struct mm_struct *mm = current->mm;
-	vm_flags_t vm_flags;
 
 	*populate = 0;
 
@@ -1298,7 +1296,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	 * to. we assume access permissions have been handled by the open
 	 * of the memory object, so we don't do any here.
 	 */
-	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
+	vm_flags |= calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
 	if (flags & MAP_LOCKED)
diff --git a/mm/nommu.c b/mm/nommu.c
index e544508..e3026fd 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1271,13 +1271,14 @@ enomem:
 /*
  * handle mapping creation for uClinux
  */
-unsigned long do_mmap_pgoff(struct file *file,
-			    unsigned long addr,
-			    unsigned long len,
-			    unsigned long prot,
-			    unsigned long flags,
-			    unsigned long pgoff,
-			    unsigned long *populate)
+unsigned long do_mmap(struct file *file,
+			unsigned long addr,
+			unsigned long len,
+			unsigned long prot,
+			unsigned long flags,
+			vm_flags_t vm_flags,
+			unsigned long pgoff,
+			unsigned long *populate)
 {
 	struct vm_area_struct *vma;
 	struct vm_region *region;
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
