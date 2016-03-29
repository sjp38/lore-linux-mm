Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id CFFD96B025F
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 21:13:14 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id u190so1077201pfb.3
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 18:13:14 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o63si19116086pfi.141.2016.03.28.18.13.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 18:13:13 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 2/2] x86/hugetlb: Attempt PUD_SIZE mapping alignment if PMD sharing enabled
Date: Mon, 28 Mar 2016 18:12:50 -0700
Message-Id: <1459213970-17957-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
References: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org
Cc: Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

When creating a hugetlb mapping, attempt PUD_SIZE alignment if the
following conditions are met:
- Address passed to mmap or shmat is NULL
- The mapping is flaged as shared
- The mapping is at least PUD_SIZE in length
If a PUD_SIZE aligned mapping can not be created, then fall back to a
huge page size mapping.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/x86/mm/hugetlbpage.c | 64 ++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 61 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 42982b2..4f53af5 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -78,14 +78,39 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 {
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
+	bool pud_size_align = false;
+	unsigned long ret_addr;
+
+	/*
+	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
+	 * sharing.  Only attempt alignment if no address was passed in,
+	 * flags indicate sharing and size is big enough.
+	 */
+	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
+	    !addr && flags & MAP_SHARED && len >= PUD_SIZE)
+		pud_size_align = true;
 
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = current->mm->mmap_legacy_base;
 	info.high_limit = TASK_SIZE;
-	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
+	if (pud_size_align)
+		info.align_mask = PAGE_MASK & (PUD_SIZE - 1);
+	else
+		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
-	return vm_unmapped_area(&info);
+	ret_addr = vm_unmapped_area(&info);
+
+	/*
+	 * If failed with PUD_SIZE alignment, try again with huge page
+	 * size alignment.
+	 */
+	if ((ret_addr & ~PAGE_MASK) && pud_size_align) {
+		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
+		ret_addr = vm_unmapped_area(&info);
+	}
+
+	return ret_addr;
 }
 
 static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
@@ -95,16 +120,38 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
 	unsigned long addr;
+	bool pud_size_align = false;
+
+	/*
+	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
+	 * sharing.  Only attempt alignment if no address was passed in,
+	 * flags indicate sharing and size is big enough.
+	 */
+	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
+	    !addr0 && flags & MAP_SHARED && len >= PUD_SIZE)
+		pud_size_align = true;
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
 	info.high_limit = current->mm->mmap_base;
-	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
+	if (pud_size_align)
+		info.align_mask = PAGE_MASK & (PUD_SIZE - 1);
+	else
+		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	addr = vm_unmapped_area(&info);
 
 	/*
+	 * If failed with PUD_SIZE alignment, try again with huge page
+	 * size alignment.
+	 */
+	if ((addr & ~PAGE_MASK) && pud_size_align) {
+		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
+		addr = vm_unmapped_area(&info);
+	}
+
+	/*
 	 * A failed mmap() very likely causes application failure,
 	 * so fall back to the bottom-up function here. This scenario
 	 * can happen with large stack limits and large mmap()
@@ -115,7 +162,18 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
 		info.high_limit = TASK_SIZE;
+		if (pud_size_align)
+			info.align_mask = PAGE_MASK & (PUD_SIZE - 1);
 		addr = vm_unmapped_area(&info);
+
+		/*
+		 * If failed again with PUD_SIZE alignment, finally try with
+		 * huge page size alignment.
+		 */
+		if (addr & ~PAGE_MASK) {
+			info.align_mask = PAGE_MASK & ~huge_page_mask(h);
+			addr = vm_unmapped_area(&info);
+		}
 	}
 
 	return addr;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
