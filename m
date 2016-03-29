Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id ED0056B025E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 21:13:13 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id u110so687529qge.3
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 18:13:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h81si3038083qhc.41.2016.03.28.18.13.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 18:13:13 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 1/2] mm/hugetlbfs: Attempt PUD_SIZE mapping alignment if PMD sharing enabled
Date: Mon, 28 Mar 2016 18:12:49 -0700
Message-Id: <1459213970-17957-2-git-send-email-mike.kravetz@oracle.com>
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
 fs/hugetlbfs/inode.c | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 540ddc9..22b2e38 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -175,6 +175,17 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	struct vm_area_struct *vma;
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
 
 	if (len & ~huge_page_mask(h))
 		return -EINVAL;
@@ -199,9 +210,23 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	info.length = len;
 	info.low_limit = TASK_UNMAPPED_BASE;
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
 #endif
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
