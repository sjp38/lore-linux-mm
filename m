Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 522C66B0072
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 20:28:33 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so682642pad.26
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 17:28:32 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/8] mm: use vm_unmapped_area() on frv architecture
Date: Tue,  8 Jan 2013 17:28:10 -0800
Message-Id: <1357694895-520-4-git-send-email-walken@google.com>
In-Reply-To: <1357694895-520-1-git-send-email-walken@google.com>
References: <1357694895-520-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

Update the frv arch_get_unmapped_area function to make use of
vm_unmapped_area() instead of implementing a brute force search.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/frv/mm/elf-fdpic.c |   49 ++++++++++++++++------------------------------
 1 files changed, 17 insertions(+), 32 deletions(-)

diff --git a/arch/frv/mm/elf-fdpic.c b/arch/frv/mm/elf-fdpic.c
index 385fd30b142f..836f14707a62 100644
--- a/arch/frv/mm/elf-fdpic.c
+++ b/arch/frv/mm/elf-fdpic.c
@@ -60,7 +60,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 				     unsigned long pgoff, unsigned long flags)
 {
 	struct vm_area_struct *vma;
-	unsigned long limit;
+	struct vm_unmapped_area_info info;
 
 	if (len > TASK_SIZE)
 		return -ENOMEM;
@@ -79,39 +79,24 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 	}
 
 	/* search between the bottom of user VM and the stack grow area */
-	addr = PAGE_SIZE;
-	limit = (current->mm->start_stack - 0x00200000);
-	if (addr + len <= limit) {
-		limit -= len;
-
-		if (addr <= limit) {
-			vma = find_vma(current->mm, PAGE_SIZE);
-			for (; vma; vma = vma->vm_next) {
-				if (addr > limit)
-					break;
-				if (addr + len <= vma->vm_start)
-					goto success;
-				addr = vma->vm_end;
-			}
-		}
-	}
+	info.flags = 0;
+	info.length = len;
+	info.low_limit = PAGE_SIZE;
+	info.high_limit = (current->mm->start_stack - 0x00200000);
+	info.align_mask = 0;
+	info.align_offset = 0;
+	addr = vm_unmapped_area(&info);
+	if (!(addr & ~PAGE_MASK))
+		goto success;
+	VM_BUG_ON(addr != -ENOMEM);
 
 	/* search from just above the WorkRAM area to the top of memory */
-	addr = PAGE_ALIGN(0x80000000);
-	limit = TASK_SIZE - len;
-	if (addr <= limit) {
-		vma = find_vma(current->mm, addr);
-		for (; vma; vma = vma->vm_next) {
-			if (addr > limit)
-				break;
-			if (addr + len <= vma->vm_start)
-				goto success;
-			addr = vma->vm_end;
-		}
-
-		if (!vma && addr <= limit)
-			goto success;
-	}
+	info.low_limit = PAGE_ALIGN(0x80000000);
+	info.high_limit = TASK_SIZE;
+	addr = vm_unmapped_area(&info);
+	if (!(addr & ~PAGE_MASK))
+		goto success;
+	VM_BUG_ON(addr != -ENOMEM);
 
 #if 0
 	printk("[area] l=%lx (ENOMEM) f='%s'\n",
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
