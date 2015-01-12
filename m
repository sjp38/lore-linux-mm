Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id E1FEA6B006C
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 11:11:44 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id 19so9558509ykq.10
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 08:11:44 -0800 (PST)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id e68si735697yhe.175.2015.01.12.08.11.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 08:11:42 -0800 (PST)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 1/2] mm: provide a find_page vma operation
Date: Mon, 12 Jan 2015 15:53:12 +0000
Message-ID: <1421077993-7909-2-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1421077993-7909-1-git-send-email-david.vrabel@citrix.com>
References: <1421077993-7909-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org

The optional find_page VMA operation is used to lookup the pages
backing a VMA.  This is useful in cases where the normal mechanisms
for finding the page don't work.  This is only called if the PTE is
special.

One use case is a Xen PV guest mapping foreign pages into userspace.

In a Xen PV guest, the PTEs contain MFNs so get_user_pages() (for
example) must do an MFN to PFN (M2P) lookup before it can get the
page.  For foreign pages (those owned by another guest) the M2P lookup
returns the PFN as seen by the foreign guest (which would be
completely the wrong page for the local guest).

This cannot be fixed up improving the M2P lookup since one MFN may be
mapped onto two or more pages so getting the right page is impossible
given just the MFN.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 include/linux/mm.h |    3 +++
 mm/memory.c        |    2 ++
 2 files changed, 5 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80fc92a..1306643 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -290,6 +290,9 @@ struct vm_operations_struct {
 	/* called by sys_remap_file_pages() to populate non-linear mapping */
 	int (*remap_pages)(struct vm_area_struct *vma, unsigned long addr,
 			   unsigned long size, pgoff_t pgoff);
+
+	struct page * (*find_page)(struct vm_area_struct *vma,
+				   unsigned long addr);
 };
 
 struct mmu_gather;
diff --git a/mm/memory.c b/mm/memory.c
index c6565f0..f23a862 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -754,6 +754,8 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 	if (HAVE_PTE_SPECIAL) {
 		if (likely(!pte_special(pte)))
 			goto check_pfn;
+		if (vma->vm_ops && vma->vm_ops->find_page)
+			return vma->vm_ops->find_page(vma, addr);
 		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
 		if (!is_zero_pfn(pfn))
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
