Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 08EF86B0011
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 20:30:06 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so3751658pab.19
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 17:30:06 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 5/8] mm: use vm_unmapped_area() in hugetlbfs on ia64 architecture
Date: Wed, 23 Jan 2013 17:29:48 -0800
Message-Id: <1358990991-21316-6-git-send-email-walken@google.com>
In-Reply-To: <1358990991-21316-1-git-send-email-walken@google.com>
References: <1358990991-21316-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

Update the ia64 hugetlb_get_unmapped_area function to make use of
vm_unmapped_area() instead of implementing a brute force search.

Signed-off-by: Michel Lespinasse <walken@google.com>
Acked-by: Rik van Riel <riel@redhat.com>

---
 arch/ia64/mm/hugetlbpage.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 5ca674b74737..76069c18ee42 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -148,7 +148,7 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
-	struct vm_area_struct *vmm;
+	struct vm_unmapped_area_info info;
 
 	if (len > RGN_MAP_LIMIT)
 		return -ENOMEM;
@@ -165,16 +165,14 @@ unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr, u
 	/* This code assumes that RGN_HPAGE != 0. */
 	if ((REGION_NUMBER(addr) != RGN_HPAGE) || (addr & (HPAGE_SIZE - 1)))
 		addr = HPAGE_REGION_BASE;
-	else
-		addr = ALIGN(addr, HPAGE_SIZE);
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
-		/* At this point:  (!vmm || addr < vmm->vm_end). */
-		if (REGION_OFFSET(addr) + len > RGN_MAP_LIMIT)
-			return -ENOMEM;
-		if (!vmm || (addr + len) <= vmm->vm_start)
-			return addr;
-		addr = ALIGN(vmm->vm_end, HPAGE_SIZE);
-	}
+
+	info.flags = 0;
+	info.length = len;
+	info.low_limit = addr;
+	info.high_limit = HPAGE_REGION_BASE + RGN_MAP_LIMIT;
+	info.align_mask = PAGE_MASK & (HPAGE_SIZE - 1);
+	info.align_offset = 0;
+	return vm_unmapped_area(&info);
 }
 
 static int __init hugetlb_setup_sz(char *str)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
