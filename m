Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B83F86B02AD
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:50:03 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b123so21221917itb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:50:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u193si2945717itc.59.2016.12.16.06.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 20/42] userfaultfd: hugetlbfs: add userfaultfd hugetlb hook
Date: Fri, 16 Dec 2016 15:47:59 +0100
Message-Id: <20161216144821.5183-21-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Kravetz <mike.kravetz@oracle.com>

When processing a hugetlb fault for no page present, check the vma to
determine if faults are to be handled via userfaultfd.  If so, drop the
hugetlb_fault_mutex and call handle_userfault().

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/hugetlb.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9ea7588..621ea74 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -32,6 +32,7 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/node.h>
+#include <linux/userfaultfd_k.h>
 #include "internal.h"
 
 int hugepages_treat_as_movable;
@@ -3661,6 +3662,38 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		size = i_size_read(mapping->host) >> huge_page_shift(h);
 		if (idx >= size)
 			goto out;
+
+		/*
+		 * Check for page in userfault range
+		 */
+		if (userfaultfd_missing(vma)) {
+			u32 hash;
+			struct vm_fault vmf = {
+				.vma = vma,
+				.address = address,
+				.flags = flags,
+				/*
+				 * Hard to debug if it ends up being
+				 * used by a callee that assumes
+				 * something about the other
+				 * uninitialized fields... same as in
+				 * memory.c
+				 */
+			};
+
+			/*
+			 * hugetlb_fault_mutex must be dropped before
+			 * handling userfault.  Reacquire after handling
+			 * fault to make calling code simpler.
+			 */
+			hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping,
+							idx, address);
+			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			ret = handle_userfault(&vmf, VM_UFFD_MISSING);
+			mutex_lock(&hugetlb_fault_mutex_table[hash]);
+			goto out;
+		}
+
 		page = alloc_huge_page(vma, address, 0);
 		if (IS_ERR(page)) {
 			ret = PTR_ERR(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
