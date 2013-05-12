Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 146BA6B0071
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:39 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 27/39] x86-64, mm: proper alignment mappings with hugepages
Date: Sun, 12 May 2013 04:23:24 +0300
Message-Id: <1368321816-17719-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Make arch_get_unmapped_area() return unmapped area aligned to HPAGE_MASK
if the file mapping can have huge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/sys_x86_64.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index dbded5a..d97ab40 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -15,6 +15,7 @@
 #include <linux/random.h>
 #include <linux/uaccess.h>
 #include <linux/elf.h>
+#include <linux/pagemap.h>
 
 #include <asm/ia32.h>
 #include <asm/syscalls.h>
@@ -34,6 +35,13 @@ static unsigned long get_align_mask(void)
 	return va_align.mask;
 }
 
+static inline unsigned long mapping_align_mask(struct address_space *mapping)
+{
+	if (mapping_can_have_hugepages(mapping))
+		return PAGE_MASK & ~HPAGE_MASK;
+	return get_align_mask();
+}
+
 unsigned long align_vdso_addr(unsigned long addr)
 {
 	unsigned long align_mask = get_align_mask();
@@ -135,7 +143,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.length = len;
 	info.low_limit = begin;
 	info.high_limit = end;
-	info.align_mask = filp ? get_align_mask() : 0;
+	info.align_mask = filp ? mapping_align_mask(filp->f_mapping) : 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	return vm_unmapped_area(&info);
 }
@@ -174,7 +182,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
 	info.high_limit = mm->mmap_base;
-	info.align_mask = filp ? get_align_mask() : 0;
+	info.align_mask = filp ? mapping_align_mask(filp->f_mapping) : 0;
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
