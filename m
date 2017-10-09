Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09CFF6B026F
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 06:08:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r202so23395997wmd.1
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 03:08:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 6si3665073edi.529.2017.10.09.03.08.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 03:08:51 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v99A8mxw110422
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 06:08:50 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dg5t8bnqu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 06:08:49 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 11:08:32 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 09/20] mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
Date: Mon,  9 Oct 2017 12:07:41 +0200
In-Reply-To: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507543672-25821-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

migrate_misplaced_page() is only called during the page fault handling so
it's better to pass the pointer to the struct vm_fault instead of the vma.

This way during the speculative page fault path the saved vma->vm_flags
could be used.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/migrate.h | 4 ++--
 mm/memory.c             | 2 +-
 mm/migrate.c            | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 643c7ae7d7b4..a815ed6838b3 100644
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
index d972ef4e3151..49b1dc9a2ed6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3861,7 +3861,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	}
 
 	/* Migrate to the requested node */
-	migrated = migrate_misplaced_page(page, vma, target_nid);
+	migrated = migrate_misplaced_page(page, vmf, target_nid);
 	if (migrated) {
 		page_nid = target_nid;
 		flags |= TNF_MIGRATED;
diff --git a/mm/migrate.c b/mm/migrate.c
index e603c123c0d1..386772582e1d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1939,7 +1939,7 @@ bool pmd_trans_migrating(pmd_t pmd)
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
-int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
+int migrate_misplaced_page(struct page *page, struct vm_fault *vmf,
 			   int node)
 {
 	pg_data_t *pgdat = NODE_DATA(node);
@@ -1952,7 +1952,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	 * with execute permissions as they are probably shared libraries.
 	 */
 	if (page_mapcount(page) != 1 && page_is_file_cache(page) &&
-	    (vma->vm_flags & VM_EXEC))
+	    (vmf->vma_flags & VM_EXEC))
 		goto out;
 
 	/*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
