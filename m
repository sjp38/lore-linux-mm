Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id C054D28029E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 23:24:43 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id hr10so38800214pac.2
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 20:24:43 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k6si13538804pgc.183.2016.11.11.20.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 20:24:42 -0800 (PST)
Subject: [PATCH] mm: disable numa migration faults for dax vmas
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 11 Nov 2016 20:21:41 -0800
Message-ID: <147892450132.22062.16875659431109209179.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Mark dax vmas as not migratable to exclude them from task_numa_work().
This is especially relevant for device-dax which wants to ensure
predictable access latency and not incur periodic faults.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Reported-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mempolicy.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5e5b2969d931..d72c691afaa6 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -7,6 +7,7 @@
 
 
 #include <linux/mmzone.h>
+#include <linux/dax.h>
 #include <linux/slab.h>
 #include <linux/rbtree.h>
 #include <linux/spinlock.h>
@@ -177,6 +178,9 @@ static inline bool vma_migratable(struct vm_area_struct *vma)
 	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 		return false;
 
+	if (vma_is_dax(vma))
+		return false;
+
 #ifndef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
 	if (vma->vm_flags & VM_HUGETLB)
 		return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
