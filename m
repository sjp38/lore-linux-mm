Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 269666B00DB
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 14:21:44 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id lx4so735974iec.26
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 11:21:44 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id ms5si24836598icc.120.2014.02.25.11.21.40
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 11:21:41 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 2/3] mm, thp: Add VM_INIT_DEF_MASK and PRCTL_THP_DISABLE
Date: Tue, 25 Feb 2014 13:21:01 -0600
Message-Id: <890608e8ec2968cf6b115411a62f76503ee10331.1392009760.git.athorlton@sgi.com>
In-Reply-To: <cover.1392009759.git.athorlton@sgi.com>
References: <cover.1392009759.git.athorlton@sgi.com>
In-Reply-To: <cover.1392009759.git.athorlton@sgi.com>
References: <cover.1392009759.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Jiang Liu <liuj97@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Daeseok Youn <daeseok.youn@gmail.com>, Kent Overstreet <koverstreet@google.com>, Dario Faggioli <raistlin@linux.it>, John Stultz <johnstul@us.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

This patch adds a VM_INIT_DEF_MASK, to allow us to set the default flags
for VMs.  It also adds a prctl control which alllows us to set the THP
disable bit in mm->def_flags so that VMs will pick up the setting as
they are created.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Daeseok Youn <daeseok.youn@gmail.com>
Cc: Kent Overstreet <koverstreet@google.com>
Cc: Dario Faggioli <raistlin@linux.it>
Cc: John Stultz <johnstul@us.ibm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org

---
 include/linux/mm.h         |  3 +++
 include/uapi/linux/prctl.h |  3 +++
 kernel/fork.c              | 11 ++++++++---
 kernel/sys.c               | 15 +++++++++++++++
 4 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f28f46e..0314e4c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -177,6 +177,9 @@ extern unsigned int kobjsize(const void *objp);
  */
 #define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_PFNMAP)
 
+/* This mask defines which mm->def_flags a process can inherit its parent */
+#define VM_INIT_DEF_MASK	VM_NOHUGEPAGE
+
 /*
  * mapping from the currently active vm_flags protection bits (the
  * low four bits) to a page protection mask..
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index 289760f..58afc04 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -149,4 +149,7 @@
 
 #define PR_GET_TID_ADDRESS	40
 
+#define PR_SET_THP_DISABLE	41
+#define PR_GET_THP_DISABLE	42
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index a17621c..9fc0a30 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -529,8 +529,6 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
-	mm->flags = (current->mm) ?
-		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	atomic_long_set(&mm->nr_ptes, 0);
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
@@ -539,8 +537,15 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm_init_owner(mm, p);
 	clear_tlb_flush_pending(mm);
 
-	if (likely(!mm_alloc_pgd(mm))) {
+	if (current->mm) {
+		mm->flags = current->mm->flags & MMF_INIT_MASK;
+		mm->def_flags = current->mm->def_flags & VM_INIT_DEF_MASK;
+	} else {
+		mm->flags = default_dump_filter;
 		mm->def_flags = 0;
+	}
+
+	if (likely(!mm_alloc_pgd(mm))) {
 		mmu_notifier_mm_init(mm);
 		return mm;
 	}
diff --git a/kernel/sys.c b/kernel/sys.c
index c0a58be..aa8d3a0 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1996,6 +1996,21 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		if (arg2 || arg3 || arg4 || arg5)
 			return -EINVAL;
 		return current->no_new_privs ? 1 : 0;
+	case PR_GET_THP_DISABLE:
+		if (arg2 || arg3 || arg4 || arg5)
+			return -EINVAL;
+		error = !!(me->mm->def_flags & VM_NOHUGEPAGE);
+		break;
+	case PR_SET_THP_DISABLE:
+		if (arg3 || arg4 || arg5)
+			return -EINVAL;
+		down_write(&me->mm->mmap_sem);
+		if (arg2)
+			me->mm->def_flags |= VM_NOHUGEPAGE;
+		else
+			me->mm->def_flags &= ~VM_NOHUGEPAGE;
+		up_write(&me->mm->mmap_sem);
+		break;
 	default:
 		error = -EINVAL;
 		break;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
