Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9972C6B0038
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 10:47:42 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f73so3045208yha.0
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:47:42 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id o44si5467593yhb.1.2015.01.19.07.47.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 07:47:41 -0800 (PST)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 1/2] mm: provide a find_special_page vma operation
Date: Mon, 19 Jan 2015 15:47:22 +0000
Message-ID: <1421682443-20509-2-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1421682443-20509-1-git-send-email-david.vrabel@citrix.com>
References: <1421682443-20509-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org

The optional find_special_page VMA operation is used to lookup the
pages backing a VMA.  This is useful in cases where the normal
mechanisms for finding the page don't work.  This is only called if
the PTE is special.

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
 include/linux/mm.h |    8 ++++++++
 mm/memory.c        |    2 ++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80fc92a..9269af7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -290,6 +290,14 @@ struct vm_operations_struct {
 	/* called by sys_remap_file_pages() to populate non-linear mapping */
 	int (*remap_pages)(struct vm_area_struct *vma, unsigned long addr,
 			   unsigned long size, pgoff_t pgoff);
+
+	/*
+	 * Called by vm_normal_page() for special PTEs to find the
+	 * page for @addr.  This is useful if the default behavior
+	 * (using pte_page()) would not find the correct page.
+	 */
+	struct page *(*find_special_page)(struct vm_area_struct *vma,
+					  unsigned long addr);
 };
 
 struct mmu_gather;
diff --git a/mm/memory.c b/mm/memory.c
index 54f3a9b..dc2e01a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -754,6 +754,8 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 	if (HAVE_PTE_SPECIAL) {
 		if (likely(!pte_special(pte)))
 			goto check_pfn;
+		if (vma->vm_ops && vma->vm_ops->find_special_page)
+			return vma->vm_ops->find_special_page(vma, addr);
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
