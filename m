Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46C856B02AD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:12 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o68so24650223qkf.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o64si1924840qki.173.2016.11.02.12.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:11 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 16/33] userfaultfd: hugetlbfs: add userfaultfd hugetlb hook
Date: Wed,  2 Nov 2016 20:33:48 +0100
Message-Id: <1478115245-32090-17-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Kravetz <mike.kravetz@oracle.com>

When processing a hugetlb fault for no page present, check the vma to
determine if faults are to be handled via userfaultfd.  If so, drop the
hugetlb_fault_mutex and call handle_userfault().

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/hugetlb.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index baf7fd4..7247f8c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -32,6 +32,7 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/node.h>
+#include <linux/userfaultfd_k.h>
 #include "internal.h"
 
 int hugepages_treat_as_movable;
@@ -3589,6 +3590,38 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		size = i_size_read(mapping->host) >> huge_page_shift(h);
 		if (idx >= size)
 			goto out;
+
+		/*
+		 * Check for page in userfault range
+		 */
+		if (userfaultfd_missing(vma)) {
+			u32 hash;
+			struct fault_env fe = {
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
+			ret = handle_userfault(&fe, VM_UFFD_MISSING);
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
