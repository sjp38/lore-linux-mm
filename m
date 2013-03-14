Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 34F3A6B0089
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:31 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 21/30] x86-64, mm: proper alignment mappings with hugepages
Date: Thu, 14 Mar 2013 19:50:26 +0200
Message-Id: <1363283435-7666-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Make arch_get_unmapped_area() return unmapped area aligned to HPAGE_MASK
if the file mapping can have huge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/sys_x86_64.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index dbded5a..4e20cd5 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -15,6 +15,7 @@
 #include <linux/random.h>
 #include <linux/uaccess.h>
 #include <linux/elf.h>
+#include <linux/pagemap.h>
 
 #include <asm/ia32.h>
 #include <asm/syscalls.h>
@@ -135,7 +136,11 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.length = len;
 	info.low_limit = begin;
 	info.high_limit = end;
-	info.align_mask = filp ? get_align_mask() : 0;
+	if (filp)
+		info.align_mask = mapping_can_have_hugepages(filp->f_mapping) ?
+			PAGE_MASK & ~HPAGE_MASK : get_align_mask();
+	else
+		info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	return vm_unmapped_area(&info);
 }
@@ -174,7 +179,11 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
 	info.high_limit = mm->mmap_base;
-	info.align_mask = filp ? get_align_mask() : 0;
+	if (filp)
+		info.align_mask = mapping_can_have_hugepages(filp->f_mapping) ?
+			PAGE_MASK & ~HPAGE_MASK : get_align_mask();
+	else
+		info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	addr = vm_unmapped_area(&info);
 	if (!(addr & ~PAGE_MASK))
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
