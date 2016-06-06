Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C74076B007E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 13:50:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s139so160552617oie.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 10:50:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e138si13617355ite.59.2016.06.06.10.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 10:50:03 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 4/6] mm/hugetlb: add userfaultfd hugetlb hook
Date: Mon,  6 Jun 2016 10:45:29 -0700
Message-Id: <1465235131-6112-5-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
References: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

When processing a hugetlb fault for no page present, check the vma to
determine if faults are to be handled via userfaultfd.  If so, drop the
hugetlb_fault_mutex and call handle_userfault().

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4943d8b..a2814e7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -32,6 +32,7 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/node.h>
+#include <linux/userfaultfd_k.h>
 #include "internal.h"
 
 int hugepages_treat_as_movable;
@@ -3569,6 +3570,27 @@ retry:
 		size = i_size_read(mapping->host) >> huge_page_shift(h);
 		if (idx >= size)
 			goto out;
+
+		/*
+		 * Check for page in userfault range
+		 */
+		if (userfaultfd_missing(vma)) {
+			u32 hash;
+
+			/*
+			 * hugetlb_fault_mutex must be dropped before
+			 * handling userfault.  Reacquire after handling
+			 * fault to make calling code simpler.
+			 */
+			hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping,
+							idx, address);
+			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			ret = handle_userfault(vma, address, flags,
+						VM_UFFD_MISSING);
+			mutex_lock(&hugetlb_fault_mutex_table[hash]);
+			goto out;
+		}
+
 		page = alloc_huge_page(vma, address, 0);
 		if (IS_ERR(page)) {
 			ret = PTR_ERR(page);
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
