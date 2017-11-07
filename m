Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8056B02C1
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 08:06:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 184so1528319pga.3
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 05:06:33 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1si1167940plz.262.2017.11.07.05.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 05:06:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86/mm: Do not allow non-MAP_FIXED mapping across DEFAULT_MAP_WINDOW border
Date: Tue,  7 Nov 2017 16:05:39 +0300
Message-Id: <20171107130539.52676-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
 arch/x86/kernel/sys_x86_64.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index a63fe77b3217..64b1a0d22247 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -198,11 +198,19 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	/* requesting a specific address */
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
+		if (TASK_SIZE - len < addr)
+			goto get_unmapped_area;
+
+		/* The mapping shouldn't cross DEFAULT_MAP_WINDOW border */
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
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
