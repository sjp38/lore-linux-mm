Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE49F6B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 11:03:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k57so2150124wrk.6
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:03:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j133si2986499wma.78.2017.06.02.08.03.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 08:03:36 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v52EwfeS076274
	for <linux-mm@kvack.org>; Fri, 2 Jun 2017 11:03:35 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2att69bb58-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Jun 2017 11:03:34 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 2 Jun 2017 16:03:32 +0100
From: "Mike Rapoport" <rppt@linux.vnet.ibm.com>
Subject: [PATCH] mm: make PR_SET_THP_DISABLE immediately active
Date: Fri,  2 Jun 2017 18:03:22 +0300
Message-Id: <1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux API <linux-api@vger.kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

From: Michal Hocko <mhocko@suse.com>

PR_SET_THP_DISABLE has a rather subtle semantic. It doesn't affect any
existing mapping because it only updated mm->def_flags which is a template
for new mappings. The mappings created after prctl(PR_SET_THP_DISABLE) have
VM_NOHUGEPAGE flag set.  This can be quite surprising for all those
applications which do not do prctl(); fork() & exec() and want to control
their own THP behavior.

Another usecase when the immediate semantic of the prctl might be useful is
a combination of pre- and post-copy migration of containers with CRIU.  In
this case CRIU populates a part of a memory region with data that was saved
during the pre-copy stage. Afterwards, the region is registered with
userfaultfd and CRIU expects to get page faults for the parts of the region
that were not yet populated. However, khugepaged collapses the pages and
the expected page faults do not occur.

In more general case, the prctl(PR_SET_THP_DISABLE) could be used as a
temporary mechanism for enabling/disabling THP process wide.

Implementation wise, a new MMF_DISABLE_THP flag is added. This flag is
tested when decision whether to use huge pages is taken either during page
fault of at the time of THP collapse.

It should be noted, that the new implementation makes PR_SET_THP_DISABLE
master override to any per-VMA setting, which was not the case previously.

Fixes: a0715cc22601 ("mm, thp: add VM_INIT_DEF_MASK and PRCTL_THP_DISABLE")
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/huge_mm.h        | 1 +
 include/linux/khugepaged.h     | 3 ++-
 include/linux/sched/coredump.h | 5 ++++-
 kernel/sys.c                   | 6 +++---
 mm/khugepaged.c                | 3 ++-
 mm/shmem.c                     | 8 +++++---
 6 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a3762d4..9da053c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -92,6 +92,7 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 	   (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
 	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
 	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
+	 !test_bit(MMF_DISABLE_THP, &(__vma)->vm_mm->flags) &&		\
 	 !is_vma_temporary_stack(__vma))
 #define transparent_hugepage_use_zero_page()				\
 	(transparent_hugepage_flags &					\
diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index 5d9a400..f0d7335 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -48,7 +48,8 @@ static inline int khugepaged_enter(struct vm_area_struct *vma,
 	if (!test_bit(MMF_VM_HUGEPAGE, &vma->vm_mm->flags))
 		if ((khugepaged_always() ||
 		     (khugepaged_req_madv() && (vm_flags & VM_HUGEPAGE))) &&
-		    !(vm_flags & VM_NOHUGEPAGE))
+		    !(vm_flags & VM_NOHUGEPAGE) &&
+		    !test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
 			if (__khugepaged_enter(vma->vm_mm))
 				return -ENOMEM;
 	return 0;
diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index 69eedce..98ae0d0 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -68,7 +68,10 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
 #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
 #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
+#define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
+#define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
 
-#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
+#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
+				 MMF_DISABLE_THP_MASK)
 
 #endif /* _LINUX_SCHED_COREDUMP_H */
diff --git a/kernel/sys.c b/kernel/sys.c
index 8a94b4e..e48f063 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2266,7 +2266,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_THP_DISABLE:
 		if (arg2 || arg3 || arg4 || arg5)
 			return -EINVAL;
-		error = !!(me->mm->def_flags & VM_NOHUGEPAGE);
+		error = !!test_bit(MMF_DISABLE_THP, &me->mm->flags);
 		break;
 	case PR_SET_THP_DISABLE:
 		if (arg3 || arg4 || arg5)
@@ -2274,9 +2274,9 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		if (down_write_killable(&me->mm->mmap_sem))
 			return -EINTR;
 		if (arg2)
-			me->mm->def_flags |= VM_NOHUGEPAGE;
+			set_bit(MMF_DISABLE_THP, &me->mm->flags);
 		else
-			me->mm->def_flags &= ~VM_NOHUGEPAGE;
+			clear_bit(MMF_DISABLE_THP, &me->mm->flags);
 		up_write(&me->mm->mmap_sem);
 		break;
 	case PR_MPX_ENABLE_MANAGEMENT:
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 32c66e7..b444b9b 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -824,7 +824,8 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
 static bool hugepage_vma_check(struct vm_area_struct *vma)
 {
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
-	    (vma->vm_flags & VM_NOHUGEPAGE))
+	    (vma->vm_flags & VM_NOHUGEPAGE) ||
+	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
 		return false;
 	if (shmem_file(vma->vm_file)) {
 		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba..33b908b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1977,10 +1977,12 @@ static int shmem_fault(struct vm_fault *vmf)
 	}
 
 	sgp = SGP_CACHE;
-	if (vma->vm_flags & VM_HUGEPAGE)
-		sgp = SGP_HUGE;
-	else if (vma->vm_flags & VM_NOHUGEPAGE)
+
+	if ((vma->vm_flags & VM_NOHUGEPAGE) ||
+	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
 		sgp = SGP_NOHUGE;
+	else if (vma->vm_flags & VM_HUGEPAGE)
+		sgp = SGP_HUGE;
 
 	error = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, sgp,
 				  gfp, vma, vmf, &ret);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
