Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id A74A86B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 12:55:06 -0400 (EDT)
Received: by qget71 with SMTP id t71so159055927qge.2
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 09:55:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p25si20829477qkh.85.2015.07.13.09.55.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 09:55:05 -0700 (PDT)
Date: Mon, 13 Jul 2015 18:53:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/5] x86, mpx: do not set ->vm_ops on mpx VMAs
Message-ID: <20150713165323.GA7906@redhat.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com> <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

On 07/13, Kirill A. Shutemov wrote:
>
> We don't really need ->vm_ops here: MPX VMA can be detected with VM_MPX
> flag. And vma_merge() will not merge MPX VMA with non-MPX VMA, because
> ->vm_flags won't match.

Agreed.

I am wondering if something like the patch below (on top of yours) makes
sense... Not sure, but mpx_mmap() doesn't look nice too, and with this
change we can unexport mmap_region().

Oleg.


 arch/x86/mm/mpx.c  |   51 +++++++--------------------------------------------
 include/linux/mm.h |    3 +++
 mm/mmap.c          |   16 +++++++++++-----
 3 files changed, 21 insertions(+), 49 deletions(-)


diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 4d1c11c..da8b713 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -24,58 +24,21 @@
  */
 static unsigned long mpx_mmap(unsigned long len)
 {
-	unsigned long ret;
-	unsigned long addr, pgoff;
+	unsigned long addr, populate;
 	struct mm_struct *mm = current->mm;
-	vm_flags_t vm_flags;
-	struct vm_area_struct *vma;
 
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
+	addr = __do_mmap_pgoff(NULL, 0, len, PROT_READ | PROT_WRITE,
+			MAP_ANONYMOUS | MAP_PRIVATE, 0, &populate, VM_MPX);
 	up_write(&mm->mmap_sem);
-	return ret;
+	if (populate)
+		mm_populate(addr, populate);
+
+	return addr;
 }
 
 enum reg_type {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0207ffa..910d475 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1849,6 +1849,9 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
+extern unsigned long __do_mmap_pgoff(struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot, unsigned long flags,
+	unsigned long pgoff, unsigned long *populate, vm_flags_t vm_flags);
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	unsigned long pgoff, unsigned long *populate);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2185cd9..88bc961 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1247,14 +1247,12 @@ static inline int mlock_future_check(struct mm_struct *mm,
 /*
  * The caller must hold down_write(&current->mm->mmap_sem).
  */
-
-unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+unsigned long __do_mmap_pgoff(struct file *file, unsigned long addr,
 			unsigned long len, unsigned long prot,
 			unsigned long flags, unsigned long pgoff,
-			unsigned long *populate)
+			unsigned long *populate, vm_flags_t vm_flags)
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
@@ -1396,6 +1394,14 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	return addr;
 }
 
+unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
+			unsigned long len, unsigned long prot,
+			unsigned long flags, unsigned long pgoff,
+			unsigned long *populate)
+{
+	return __do_mmap_pgoff(file, addr, len, prot, flags, pgoff, populate, 0);
+}
+
 SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 		unsigned long, prot, unsigned long, flags,
 		unsigned long, fd, unsigned long, pgoff)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
