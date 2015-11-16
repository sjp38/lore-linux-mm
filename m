Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 37C1D6B0255
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 12:37:18 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so93324639lbb.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 09:37:17 -0800 (PST)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id zt4si27148602lbc.117.2015.11.16.09.37.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 09:37:16 -0800 (PST)
Received: by lblw10 with SMTP id w10so9922523lbl.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 09:37:16 -0800 (PST)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH] mm: fix incorrect behavior when process virtual address space limit is exceeded
Date: Mon, 16 Nov 2015 18:36:19 +0100
Message-Id: <1447695379-14526-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, oleg@redhat.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

When a new virtual memory area is added to the process's virtual address
space and this vma causes the process's virtual address space limit
(RLIMIT_AS) to be exceeded then kernel behaves incorrectly. Incorrect
behavior is a result of a kernel bug. The kernel in most cases
unnecessarily scans the entire process's virtual address space trying to
find the overlapping vma with the virtual memory region being added.
The kernel incorrectly compares the MAP_FIXED flag with vm_flags variable
in mmap_region function. The vm_flags variable should not be compared
with MAP_FIXED flag. The MAP_FIXED flag has got the same numerical value
as VM_MAYREAD flag (0x10). As a result the following test
from mmap_region:

if (!(vm_flags & MAP_FIXED))
is in fact:
if (!(vm_flags & VM_MAYREAD))

The VM_MAYREAD flag is almost always set in vm_flags while MAP_FIXED
flag is not so common. The result of the above condition is somewhat
reverted.
This patch fixes this bug. It causes that the kernel tries to find the
overlapping vma only when the requested virtual memory region has got
the fixed starting virtual address (MAP_FIXED flag set).
For tile architecture Calling mmap_region with the MAP_FIXED flag only is
sufficient. However the MAP_ANONYMOUS and MAP_PRIVATE flags are passed for
the completeness of the solution.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
 arch/tile/mm/elf.c | 1 +
 include/linux/mm.h | 3 ++-
 mm/mmap.c          | 7 ++++---
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 6225cc9..dae4b33 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -142,6 +142,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	if (!retval) {
 		unsigned long addr = MEM_USER_INTRPT;
 		addr = mmap_region(NULL, addr, INTRPT_SIZE,
+				   MAP_FIXED|MAP_ANONYMOUS|MAP_PRIVATE,
 				   VM_READ|VM_EXEC|
 				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0);
 		if (addr > (unsigned long) -PAGE_SIZE)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad77..1ae21c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1911,7 +1911,8 @@ extern int install_special_mapping(struct mm_struct *mm,
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
-	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
+	unsigned long len, unsigned long flags,
+	vm_flags_t vm_flags, unsigned long pgoff);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a6..ad8b845 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1399,7 +1399,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff);
+	addr = mmap_region(file, addr, len, flags, vm_flags, pgoff);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1535,7 +1535,8 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 }
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
-		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff)
+		unsigned long len, unsigned long flags,
+		vm_flags_t vm_flags, unsigned long pgoff)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1551,7 +1552,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 * MAP_FIXED may remove pages of mappings that intersects with
 		 * requested mapping. Account for the pages it would unmap.
 		 */
-		if (!(vm_flags & MAP_FIXED))
+		if (!(flags & MAP_FIXED))
 			return -ENOMEM;
 
 		nr_pages = count_vma_pages_range(mm, addr, addr + len);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
