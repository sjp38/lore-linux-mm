Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1F4A46B00A4
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/33] autonuma: core autonuma.h header
Date: Thu,  4 Oct 2012 01:50:51 +0200
Message-Id: <1349308275-2174-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Header that defines the generic AutoNUMA specific functions.

All functions are defined unconditionally, but are only linked into
the kernel if CONFIG_AUTONUMA=y. When CONFIG_AUTONUMA=n, their call
sites are optimized away at build time (or the kernel wouldn't link).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/autonuma.h |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/autonuma.h

diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
new file mode 100644
index 0000000..02d4875
--- /dev/null
+++ b/include/linux/autonuma.h
@@ -0,0 +1,34 @@
+#ifndef _LINUX_AUTONUMA_H
+#define _LINUX_AUTONUMA_H
+
+#include <linux/autonuma_flags.h>
+
+#ifdef CONFIG_AUTONUMA
+
+extern void autonuma_enter(struct mm_struct *mm);
+extern void autonuma_exit(struct mm_struct *mm);
+extern void autonuma_migrate_split_huge_page(struct page *page,
+					     struct page *page_tail);
+extern void autonuma_setup_new_exec(struct task_struct *p);
+
+#define autonuma_printk(format, args...) \
+	if (autonuma_debug()) printk(format, ##args)
+
+#else /* CONFIG_AUTONUMA */
+
+static inline void autonuma_enter(struct mm_struct *mm) {}
+static inline void autonuma_exit(struct mm_struct *mm) {}
+static inline void autonuma_migrate_split_huge_page(struct page *page,
+						    struct page *page_tail) {}
+static inline void autonuma_setup_new_exec(struct task_struct *p) {}
+
+#endif /* CONFIG_AUTONUMA */
+
+extern int pte_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
+			  unsigned long addr, pte_t pte, pte_t *ptep,
+			  pmd_t *pmd);
+extern int pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
+			  pmd_t *pmd);
+extern bool numa_hinting_fault(struct page *page, int numpages);
+
+#endif /* _LINUX_AUTONUMA_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
