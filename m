Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id DBE896B0036
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 13:24:07 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id k19so20431519igc.5
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 10:24:07 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.179.29])
        by mx.google.com with ESMTP id vf15si16251524igb.63.2014.01.31.10.23.58
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 10:23:58 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 2/3] Add VM_INIT_DEF_MASK and PRCTL_THP_DISABLE
Date: Fri, 31 Jan 2014 12:23:45 -0600
Message-Id: <1391192628-113858-5-git-send-email-athorlton@sgi.com>
In-Reply-To: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
References: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Jiang Liu <liuj97@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Robin Holt <holt@sgi.com>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, liguang <lig.fnst@cn.fujitsu.com>, linux-mm@kvack.org

This patch adds a VM_INIT_DEF_MASK, to allow us to set the default flags
for VMs.  It also adds a prctl control which alllows us to set the THP
disable bit in mm->def_flags so that VMs will pick up the setting as
they are created.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Robin Holt <holt@sgi.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Kees Cook <keescook@chromium.org>
Cc: liguang <lig.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---
 include/linux/mm.h         |  2 ++
 include/uapi/linux/prctl.h |  3 +++
 kernel/fork.c              | 11 ++++++++---
 kernel/sys.c               | 17 +++++++++++++++++
 4 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f28f46e..c0a94ad 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -177,6 +177,8 @@ extern unsigned int kobjsize(const void *objp);
  */
 #define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_PFNMAP)
 
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
index c0a58be..d59524a 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1996,6 +1996,23 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		if (arg2 || arg3 || arg4 || arg5)
 			return -EINVAL;
 		return current->no_new_privs ? 1 : 0;
+	case PR_GET_THP_DISABLE:
+		if (arg2 || arg3 || arg4 || arg5)
+			return -EINVAL;
+	case PR_SET_THP_DISABLE:
+		if (arg3 || arg4 || arg5)
+			return -EINVAL;
+		down_write(&me->mm->mmap_sem);
+		if (option == PR_SET_THP_DISABLE) {
+			if (arg2)
+				me->mm->def_flags |= VM_NOHUGEPAGE;
+			else
+				me->mm->def_flags &= ~VM_NOHUGEPAGE;
+		} else {
+			error = !!(me->mm->def_flags & VM_NOHUGEPAGE);
+		}
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
