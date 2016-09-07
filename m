Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53C516B025E
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 18:56:44 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so63244431pab.1
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 15:56:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v9si29063338pab.64.2016.09.07.15.29.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 15:29:18 -0700 (PDT)
Subject: [PATCH v2 2/2] mm: fix cache mode tracking in vm_insert_mixed()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 07 Sep 2016 15:26:19 -0700
Message-ID: <147328717909.35069.14256589123570653697.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147328716869.35069.16311932814998156819.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147328716869.35069.16311932814998156819.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, David Airlie <airlied@linux.ie>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, akpm@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>

vm_insert_mixed() unlike vm_insert_pfn_prot() and vmf_insert_pfn_pmd(),
fails to check the pgprot_t it uses for the mapping against the one
recorded in the memtype tracking tree.  Add the missing call to
track_pfn_insert() to preclude cases where incompatible aliased mappings
are established for a given physical address range.

Cc: David Airlie <airlied@linux.ie>
Cc: dri-devel@lists.freedesktop.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 83be99d9d8a1..8841fed328f9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1649,10 +1649,14 @@ EXPORT_SYMBOL(vm_insert_pfn_prot);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn)
 {
+	pgprot_t pgprot = vma->vm_page_prot;
+
 	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
+	if (track_pfn_insert(vma, &pgprot, pfn))
+		return -EINVAL;
 
 	/*
 	 * If we don't have pte special, then we have to use the pfn_valid()
@@ -1670,9 +1674,9 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		 * result in pfn_t_has_page() == false.
 		 */
 		page = pfn_to_page(pfn_t_to_pfn(pfn));
-		return insert_page(vma, addr, page, vma->vm_page_prot);
+		return insert_page(vma, addr, page, pgprot);
 	}
-	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
+	return insert_pfn(vma, addr, pfn, pgprot);
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
