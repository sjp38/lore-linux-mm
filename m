Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C688B6B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 12:58:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x24so68323934pfa.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 09:58:36 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m9si7522340pan.86.2016.09.06.09.52.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 09:52:43 -0700 (PDT)
Subject: [PATCH 4/5] mm: fix cache mode of dax pmd mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 06 Sep 2016 09:49:41 -0700
Message-ID: <147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Toshi Kani <toshi.kani@hpe.com>, Matthew Wilcox <mawilcox@microsoft.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

track_pfn_insert() is marking dax mappings as uncacheable.

It is used to keep mappings attributes consistent across a remapped range.
However, since dax regions are never registered via track_pfn_remap(), the
caching mode lookup for dax pfns always returns _PAGE_CACHE_MODE_UC.  We do not
use track_pfn_insert() in the dax-pte path, and we always want to use the
pgprot of the vma itself, so drop this call.

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nilesh Choudhury <nilesh.choudhury@oracle.com>
Reported-by: Kai Zhang <kai.ka.zhang@oracle.com>
Reported-by: Toshi Kani <toshi.kani@hpe.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/huge_memory.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a6abd76baa72..338eff05c77a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -676,8 +676,6 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
-	if (track_pfn_insert(vma, &pgprot, pfn))
-		return VM_FAULT_SIGBUS;
 	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write);
 	return VM_FAULT_NOPAGE;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
