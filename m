Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id E46C16B007E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:11:40 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 10/39] autonuma: core autonuma.h header
Date: Mon, 26 Mar 2012 19:45:57 +0200
Message-Id: <1332783986-24195-11-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

This is the generic autonuma.h header that defines the generic
AutoNUMA specific functions like autonuma_setup_new_exec,
autonuma_split_huge_page, numa_hinting_fault, etc...

As usual functions like numa_hinting_fault that only matter for builds
with CONFIG_AUTONUMA=y are defined unconditionally, but they are only
linked into the kernel if CONFIG_AUTONUMA=n. Their call sites are
optimized away at build time (or kernel won't link).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma.h |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/autonuma.h

diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
new file mode 100644
index 0000000..a963dcb
--- /dev/null
+++ b/include/linux/autonuma.h
@@ -0,0 +1,41 @@
+#ifndef _LINUX_AUTONUMA_H
+#define _LINUX_AUTONUMA_H
+
+#ifdef CONFIG_AUTONUMA
+
+#include <linux/autonuma_flags.h>
+
+extern void autonuma_enter(struct mm_struct *mm);
+extern void autonuma_exit(struct mm_struct *mm);
+extern void __autonuma_migrate_page_remove(struct page *page);
+extern void autonuma_migrate_split_huge_page(struct page *page,
+					     struct page *page_tail);
+extern void autonuma_setup_new_exec(struct task_struct *p);
+
+static inline void autonuma_migrate_page_remove(struct page *page)
+{
+	if (ACCESS_ONCE(page->autonuma_migrate_nid) >= 0)
+		__autonuma_migrate_page_remove(page);
+}
+
+#define autonuma_printk(format, args...) \
+	if (autonuma_debug()) printk(format, ##args)
+
+#else /* CONFIG_AUTONUMA */
+
+static inline void autonuma_enter(struct mm_struct *mm) {}
+static inline void autonuma_exit(struct mm_struct *mm) {}
+static inline void autonuma_migrate_page_remove(struct page *page) {}
+static inline void autonuma_migrate_split_huge_page(struct page *page,
+						    struct page *page_tail) {}
+static inline void autonuma_setup_new_exec(struct task_struct *p) {}
+
+#endif /* CONFIG_AUTONUMA */
+
+extern pte_t __pte_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
+			      unsigned long addr, pte_t pte, pte_t *ptep);
+extern void __pmd_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
+			     unsigned long addr, pmd_t *pmd);
+extern void numa_hinting_fault(struct page *page, int numpages);
+
+#endif /* _LINUX_AUTONUMA_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
