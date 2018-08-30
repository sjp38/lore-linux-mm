Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A54B76B52FF
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:06:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x85-v6so5336933pfe.13
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:06:15 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j5-v6si5045598pgg.293.2018.08.30.13.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 13:06:14 -0700 (PDT)
Subject: [PATCH] mm: fix BUG_ON() in vmf_insert_pfn_pud() from VM_MIXEDMAP
 removal
From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 30 Aug 2018 13:06:13 -0700
Message-ID: <153565957352.35524.1005746906902065126.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, dan.j.williams@intel.com, vishal.l.verma@intel.com, jack@suse.com

It looks like I missed the PUD path when doing VM_MIXEDMAP removal.
This can be triggered by:
1. Boot with memmap=4G!8G
2. build ndctl with destructive flag on
3. make TESTS=device-dax check

[  +0.000675] kernel BUG at mm/huge_memory.c:824!

Applying the same change that was applied to vmf_insert_pfn_pmd() in the
original patch.

Fixes: e1fb4a08649 ("dax: remove VM_MIXEDMAP for fsdax and device dax")

Reported-by: Vishal Verma <vishal.l.verma@intel.com>
Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 mm/huge_memory.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c3bc7e9c9a2a..533f9b00147d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -821,11 +821,11 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	 * but we need to be consistent with PTEs and architectures that
 	 * can't support a 'special' bit.
 	 */
-	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) &&
+			!pfn_t_devmap(pfn));
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON(!pfn_t_devmap(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
