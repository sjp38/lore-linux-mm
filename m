Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 70C706B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:55:33 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id e14so5758117iej.12
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 11:55:33 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id mn8si13429560icc.48.2014.01.10.11.55.31
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 11:55:32 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
Date: Fri, 10 Jan 2014 13:55:18 -0600
Message-Id: <1389383718-46031-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

This patch adds an mm flag (MMF_THP_DISABLE) to disable transparent
hugepages using prctl.  It is based on my original patch to add a
per-task_struct flag to disable THP:

v1 - https://lkml.org/lkml/2013/8/2/671
v2 - https://lkml.org/lkml/2013/8/2/703

After looking at alternate methods of modifying how THPs are handed out,
it sounds like people might be more in favor of this type of approach,
so I'm re-introducing the patch.

It seemed that everyone was in favor of moving this control over to the
mm_struct, if it is to be implemented.  That's the only major change
here, aside from the added ability to both set and clear the flag from
prctl.

The main motivation behind this patch is to provide a way to disable THP
for jobs where the code cannot be modified and using a malloc hook with
madvise is not an option (i.e. statically allocated data).  This patch
allows us to do just that, without affecting other jobs running on the
system.

Here are some results showing the improvement that my test case gets
when the MMF_THP_DISABLE flag is clear vs. set:

MMF_THP_DISABLE clear:

# perf stat -a -r 3 ./prctl_wrapper_mm 0 ./thp_pthread -C 0 -m 0 -c 512 -b 256g

 Performance counter stats for './prctl_wrapper_mm 0 ./thp_pthread -C 0 -m 0 -c 512 -b 256g' (3 runs):

  267694862.049279 task-clock                #  641.100 CPUs utilized            ( +-  0.23% ) [100.00%]
           908,846 context-switches          #    0.000 M/sec                    ( +-  0.23% ) [100.00%]
               874 CPU-migrations            #    0.000 M/sec                    ( +-  4.01% ) [100.00%]
           131,966 page-faults               #    0.000 M/sec                    ( +-  2.75% )
351,127,909,744,906 cycles                    #    1.312 GHz                      ( +-  0.27% ) [100.00%]
523,537,415,562,692 stalled-cycles-frontend   #  149.10% frontend cycles idle     ( +-  0.26% ) [100.00%]
392,400,753,609,156 stalled-cycles-backend    #  111.75% backend  cycles idle     ( +-  0.29% ) [100.00%]
147,467,956,557,895 instructions              #    0.42  insns per cycle
                                             #    3.55  stalled cycles per insn  ( +-  0.09% ) [100.00%]
26,922,737,309,021 branches                  #  100.572 M/sec                    ( +-  0.24% ) [100.00%]
     1,308,714,545 branch-misses             #    0.00% of all branches          ( +-  0.18% )

     417.555688399 seconds time elapsed                                          ( +-  0.23% )


MMF_THP_DISABLE set:

# perf stat -a -r 3 ./prctl_wrapper_mm 1 ./thp_pthread -C 0 -m 0 -c 512 -b 256g

 Performance counter stats for './prctl_wrapper_mm 1 ./thp_pthread -C 0 -m 0 -c 512 -b 256g' (3 runs):

  141674994.160138 task-clock                #  642.107 CPUs utilized            ( +-  0.23% ) [100.00%]
         1,190,415 context-switches          #    0.000 M/sec                    ( +- 42.87% ) [100.00%]
               688 CPU-migrations            #    0.000 M/sec                    ( +-  2.47% ) [100.00%]
        62,394,646 page-faults               #    0.000 M/sec                    ( +-  0.00% )
156,748,225,096,919 cycles                    #    1.106 GHz                      ( +-  0.20% ) [100.00%]
211,440,354,290,433 stalled-cycles-frontend   #  134.89% frontend cycles idle     ( +-  0.40% ) [100.00%]
114,304,536,881,102 stalled-cycles-backend    #   72.92% backend  cycles idle     ( +-  0.88% ) [100.00%]
179,939,084,230,732 instructions              #    1.15  insns per cycle
                                             #    1.18  stalled cycles per insn  ( +-  0.26% ) [100.00%]
26,659,099,949,509 branches                  #  188.171 M/sec                    ( +-  0.72% ) [100.00%]
       762,772,361 branch-misses             #    0.00% of all branches          ( +-  0.97% )

     220.640905073 seconds time elapsed                                          ( +-  0.23% )

As you can see, this particular test gets about a 2x performance boost
when THP is turned off.  Here's a link to the test, along with the
wrapper that I used:

http://oss.sgi.com/projects/memtests/thp_pthread_mmprctl.tar.gz

There are still a few things that might need tweaked here, but I wanted
to get the patch out there to get a discussion started.  Two things I
noted from the old patch discussion that will likely need to be
addressed are:

* Patch doesn't currently account for get_user_pages or khugepaged
  allocations.  Easy enough to fix, but it's not there yet.
* Current behavior is to have fork()/exec()'d processes inherit the
  flag.  Andrew Morton pointed out some possible issues with this, so we
  may need to rethink this behavior.
  - If parent process has THP disabled, and forks off a child, the child
    will also have THP disabled.  This may not be the desired behavior.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org

---
 include/linux/huge_mm.h    |  6 ++++--
 include/linux/sched.h      |  8 ++++++++
 include/uapi/linux/prctl.h |  4 ++++
 kernel/fork.c              |  1 +
 kernel/sys.c               | 45 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 91672e2..475f59f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_HUGE_MM_H
 #define _LINUX_HUGE_MM_H
 
+#include <linux/sched.h>
+
 extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 				      struct vm_area_struct *vma,
 				      unsigned long address, pmd_t *pmd,
@@ -74,7 +76,8 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 	   (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
 	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
 	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
-	 !is_vma_temporary_stack(__vma))
+	 !is_vma_temporary_stack(__vma) &&				\
+	 !test_bit(MMF_THP_DISABLE, &(__vma)->vm_mm->flags))
 #define transparent_hugepage_defrag(__vma)				\
 	((transparent_hugepage_flags &					\
 	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)) ||			\
@@ -227,7 +230,6 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
 {
 	return 0;
 }
-
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 53f97eb..70623e1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -373,7 +373,15 @@ extern int get_dumpable(struct mm_struct *mm);
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define MMF_THP_DISABLE		21	/* disable THP for this mm */
+#define MMF_THP_DISABLE_MASK	(1 << MMF_THP_DISABLE)
+
+#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK | MMF_THP_DISABLE_MASK)
+#else
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
+#endif
+
 
 struct sighand_struct {
 	atomic_t		count;
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index 289760f..a8b6ba5 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -149,4 +149,8 @@
 
 #define PR_GET_TID_ADDRESS	40
 
+#define PR_SET_THP_DISABLE	41
+#define PR_CLEAR_THP_DISABLE	42
+#define PR_GET_THP_DISABLE	43
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 5721f0e..3337e85 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -818,6 +818,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
+
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 
diff --git a/kernel/sys.c b/kernel/sys.c
index c723113..4864aaf 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1835,6 +1835,42 @@ static int prctl_get_tid_address(struct task_struct *me, int __user **tid_addr)
 }
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static int prctl_set_thp_disable(struct task_struct *me)
+{
+	set_bit(MMF_THP_DISABLE, &me->mm->flags);
+	return 0;
+}
+
+static int prctl_clear_thp_disable(struct task_struct *me)
+{
+	clear_bit(MMF_THP_DISABLE, &me->mm->flags);
+	return 0;
+}
+
+static int prctl_get_thp_disable(struct task_struct *me,
+				  int __user *thp_disabled)
+{
+	return put_user(test_bit(MMF_THP_DISABLE, &me->mm->flags), thp_disabled);
+}
+#else
+static int prctl_set_thp_disable(struct task_struct *me)
+{
+	return -EINVAL;
+}
+
+static int prctl_clear_thp_disable(struct task_struct *me)
+{
+	return -EINVAL;
+}
+
+static int prctl_get_thp_disable(struct task_struct *me,
+				  int __user *thp_disabled)
+{
+	return -EINVAL;
+}
+#endif
+
 SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -1998,6 +2034,15 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		if (arg2 || arg3 || arg4 || arg5)
 			return -EINVAL;
 		return current->no_new_privs ? 1 : 0;
+	case PR_SET_THP_DISABLE:
+		error = prctl_set_thp_disable(me);
+		break;
+	case PR_CLEAR_THP_DISABLE:
+		error = prctl_clear_thp_disable(me);
+		break;
+	case PR_GET_THP_DISABLE:
+		error = prctl_get_thp_disable(me, (int __user *) arg2);
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
