Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECCB6B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 11:39:50 -0500 (EST)
Received: by lbbkw15 with SMTP id kw15so65216352lbb.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 08:39:49 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id i187si203879lfd.209.2015.11.20.08.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 08:39:48 -0800 (PST)
Received: by lffu14 with SMTP id u14so6698927lff.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 08:39:48 -0800 (PST)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH v2 1/2] mm: fix incorrect behavior when process virtual address space limit is exceeded
Date: Fri, 20 Nov 2015 17:38:53 +0100
Message-Id: <1448037533-4662-1-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <20151118162939.GA1842@home.local>
References: <20151118162939.GA1842@home.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, oleg@redhat.com, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

The following flag comparison in mmap_region makes no sense:

if (!(vm_flags & MAP_FIXED))
    return -ENOMEM;

The condition is false even if MAP_FIXED is not set what causes the
unnecessary find_vma call. MAP_FIXED has the same value as VM_MAYREAD.
The vm_flags must not be compared with MAP_FIXED. The vm_flags may only
be compared with VM_* flags. The mmap executes slightly longer when
MAP_FIXED is not set and RLIMIT_AS is exceeded.

Fix the issue by introducing a new parameter to mmap_region which forwards
the mmap flags and now the MAP_FIXED can be checked properly.
Tile and its arch_setup_additional_pages as the user of
mmap_region has to be specific about its mmap flags now.

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
index 00bad77..f1a203f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1911,7 +1911,8 @@ extern int install_special_mapping(struct mm_struct *mm,
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
-	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
+	unsigned long len, unsigned long mmap_flags,
+	vm_flags_t vm_flags, unsigned long pgoff);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a6..8f3427f 100644
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
+		unsigned long len, unsigned long mmap_flags,
+		vm_flags_t vm_flags, unsigned long pgoff)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -1551,7 +1552,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 * MAP_FIXED may remove pages of mappings that intersects with
 		 * requested mapping. Account for the pages it would unmap.
 		 */
-		if (!(vm_flags & MAP_FIXED))
+		if (!(mmap_flags & MAP_FIXED))
 			return -ENOMEM;
 
 		nr_pages = count_vma_pages_range(mm, addr, addr + len);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
