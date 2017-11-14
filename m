Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6D16B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 08:43:33 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v2so17915033pfa.10
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 05:43:33 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c15si17732177pfj.154.2017.11.14.05.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 05:43:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across DEFAULT_MAP_WINDOW border
Date: Tue, 14 Nov 2017 16:43:21 +0300
Message-Id: <20171114134322.40321-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

In case of 5-level paging, we don't put any mapping above 47-bit, unless
userspace explicitly asked for it.

Userspace can ask for allocation from full address space by specifying
hint address above 47-bit.

Nicholas noticed that current implementation violates this interface:
we can get vma partly in high addresses if we ask for a mapping at very
end of 47-bit address space.

Let's make sure that, when consider hint address for non-MAP_FIXED
mapping, start and end of resulting vma are on the same side of 47-bit
border.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Nicholas Piggin <npiggin@gmail.com>
---
 v2:
   - add a comment to explain behaviour;
   - cover hugetlb case too;
---
 arch/x86/kernel/sys_x86_64.c | 36 ++++++++++++++++++++++++++++++++++--
 arch/x86/mm/hugetlbpage.c    | 13 +++++++++++--
 2 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index a63fe77b3217..472de4a9f0a6 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -198,11 +198,43 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	/* requesting a specific address */
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
+		if (TASK_SIZE - len < addr)
+			goto get_unmapped_area;
+
+		/*
+		 * We don't want to put a mapping directly accross 47-bit
+		 * boundary. It helps to address following theoretical issue:
+		 *
+		 * We have an application that tries, for some reason, to
+		 * allocate memory with mmap(addr), without MAP_FIXED, where addr
+		 * is near the borderline of 47-bit address space and addr+len is
+		 * above the border.
+		 *
+		 * On 4-level paging machine this request would succeed, but the
+		 * address will always be within 47-bit VA -- cannot allocate by
+		 * hint address, ignore it.
+		 *
+		 * If the application cannot handle high address this might be an
+		 * issue on 5-level paging machine as such call would succeed
+		 * *and* allocate memory by the specified hint address. In this
+		 * case part of the mapping would be above the border line and
+		 * may lead to misbehaviour if the application cannot handle
+		 * addresses above 47-bit.
+		 *
+		 * Note, that mmap(addr, MAP_FIXED) would fail on 4-level
+		 * paging machine if addr+len is above 47-bit. It's reasonable
+		 * to expect that nobody would rely on such failure and it's
+		 * safe to allocate such mapping.
+		 */
+		if ((addr > DEFAULT_MAP_WINDOW) !=
+				(addr + len > DEFAULT_MAP_WINDOW))
+			goto get_unmapped_area;
+
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
-				(!vma || addr + len <= vm_start_gap(vma)))
+		if (!vma || addr + len <= vm_start_gap(vma))
 			return addr;
 	}
+get_unmapped_area:
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 8ae0000cbdb3..5cdcb3ee9748 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -166,11 +166,20 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 
 	if (addr) {
 		addr = ALIGN(addr, huge_page_size(h));
+		if (TASK_SIZE - len >= addr)
+			goto get_unmapped_area;
+
+		/* See a comment in arch_get_unmapped_area_topdown */
+		if ((addr > DEFAULT_MAP_WINDOW) !=
+				(addr + len > DEFAULT_MAP_WINDOW))
+			goto get_unmapped_area;
+
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
-		    (!vma || addr + len <= vm_start_gap(vma)))
+		if (!vma || addr + len <= vm_start_gap(vma))
 			return addr;
 	}
+
+get_unmapped_area:
 	if (mm->get_unmapped_area == arch_get_unmapped_area)
 		return hugetlb_get_unmapped_area_bottomup(file, addr, len,
 				pgoff, flags);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
