Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0AD6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 10:06:41 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id kb1so41897039igb.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 07:06:41 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id z79si3134165ioi.42.2016.04.06.07.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 07:06:40 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH] x86 get_unmapped_area: Add PMD alignment for DAX PMD mmap
Date: Wed,  6 Apr 2016 07:58:09 -0600
Message-Id: <1459951089-14911-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, bp@suse.de, hpa@zytor.com, tglx@linutronix.de
Cc: dan.j.williams@intel.com, willy@linux.intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, x86@kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using PMD page
size.  This feature relies on both mmap virtual address and FS
block data (i.e. physical address) to be aligned by the PMD page
size.  Users can use mkfs options to specify FS to align block
allocations.  However, aligning mmap() address requires application
changes to mmap() calls, such as:

 -  /* let the kernel to assign a mmap addr */
 -  mptr = mmap(NULL, fsize, PROT_READ|PROT_WRITE, FLAGS, fd, 0);

 +  /* 1. obtain a PMD-aligned virtual address */
 +  ret = posix_memalign(&mptr, PMD_SIZE, fsize);
 +  if (!ret)
 +    free(mptr);  /* 2. release the virt addr */
 +
 +  /* 3. then pass the PMD-aligned virt addr to mmap() */
 +  mptr = mmap(mptr, fsize, PROT_READ|PROT_WRITE, FLAGS, fd, 0);

These changes add unnecessary dependency to DAX and PMD page size
into application code.  The kernel should assign a mmap address
appropriate for the operation.

Change arch_get_unmapped_area() and arch_get_unmapped_area_topdown()
to request PMD_SIZE alignment when the request is for a DAX file and
its mapping range is large enough for using a PMD page.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/sys_x86_64.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 10e0272..a294c66 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -157,6 +157,13 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		info.align_mask = get_align_mask();
 		info.align_offset += get_align_bits();
 	}
+	if (filp && IS_ENABLED(CONFIG_FS_DAX_PMD) && IS_DAX(file_inode(filp))) {
+		unsigned long off_end = info.align_offset + len;
+		unsigned long off_pmd = round_up(info.align_offset, PMD_SIZE);
+
+		if ((off_end > off_pmd) && ((off_end - off_pmd) >= PMD_SIZE))
+			info.align_mask |= (PMD_SIZE - 1);
+	}
 	return vm_unmapped_area(&info);
 }
 
@@ -200,6 +207,13 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		info.align_mask = get_align_mask();
 		info.align_offset += get_align_bits();
 	}
+	if (filp && IS_ENABLED(CONFIG_FS_DAX_PMD) && IS_DAX(file_inode(filp))) {
+		unsigned long off_end = info.align_offset + len;
+		unsigned long off_pmd = round_up(info.align_offset, PMD_SIZE);
+
+		if ((off_end > off_pmd) && ((off_end - off_pmd) >= PMD_SIZE))
+			info.align_mask |= (PMD_SIZE - 1);
+	}
 	addr = vm_unmapped_area(&info);
 	if (!(addr & ~PAGE_MASK))
 		return addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
