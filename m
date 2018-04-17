Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 834906B0026
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:32 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i21so12544701qtp.10
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:34:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b4si5500795qkb.209.2018.04.17.07.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:34:31 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HEV03a107513
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:30 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hdjrh07r9-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:34:29 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:34:27 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 13/25] mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
Date: Tue, 17 Apr 2018 16:33:19 +0200
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523975611-15978-14-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

migrate_misplaced_page() is only called during the page fault handling so
it's better to pass the pointer to the struct vm_fault instead of the vma.

This way during the speculative page fault path the saved vma->vm_flags
could be used.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/migrate.h | 4 ++--
 mm/memory.c             | 2 +-
 mm/migrate.c            | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f2b4abbca55e..fd4c3ab7bd9c 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -126,14 +126,14 @@ static inline void __ClearPageMovable(struct page *page)
 #ifdef CONFIG_NUMA_BALANCING
 extern bool pmd_trans_migrating(pmd_t pmd);
 extern int migrate_misplaced_page(struct page *page,
-				  struct vm_area_struct *vma, int node);
+				  struct vm_fault *vmf, int node);
 #else
 static inline bool pmd_trans_migrating(pmd_t pmd)
 {
 	return false;
 }
 static inline int migrate_misplaced_page(struct page *page,
-					 struct vm_area_struct *vma, int node)
+					 struct vm_fault *vmf, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
diff --git a/mm/memory.c b/mm/memory.c
index 2fb9920e06a5..e28cbbae3f3d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3894,7 +3894,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	}
 
 	/* Migrate to the requested node */
-	migrated = migrate_misplaced_page(page, vma, target_nid);
+	migrated = migrate_misplaced_page(page, vmf, target_nid);
 	if (migrated) {
 		page_nid = target_nid;
 		flags |= TNF_MIGRATED;
diff --git a/mm/migrate.c b/mm/migrate.c
index 44d7007cfc1c..5d5cf9b5ac16 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1944,7 +1944,7 @@ bool pmd_trans_migrating(pmd_t pmd)
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
-int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
+int migrate_misplaced_page(struct page *page, struct vm_fault *vmf,
 			   int node)
 {
 	pg_data_t *pgdat = NODE_DATA(node);
@@ -1957,7 +1957,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	 * with execute permissions as they are probably shared libraries.
 	 */
 	if (page_mapcount(page) != 1 && page_is_file_cache(page) &&
-	    (vma->vm_flags & VM_EXEC))
+	    (vmf->vma_flags & VM_EXEC))
 		goto out;
 
 	/*
-- 
2.7.4
