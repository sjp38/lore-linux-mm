Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 0CF026B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:18:41 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 15/39] autonuma: autonuma_enter/exit
Date: Mon, 26 Mar 2012 19:46:02 +0200
Message-Id: <1332783986-24195-16-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

The first gear in the whole AutoNUMA algorithm is knuma_scand. If
knuma_scand doesn't run AutoNUMA is a full bypass. If knuma_scand is
stopped, soon all other AutoNUMA gears will settle down too.

knuma_scand is the daemon that sets the pmd_numa and pte_numa and
allows the NUMA hinting page faults to start and then all other
actions follows as a reaction to that.

knuma_scand scans a list of "mm" and this is where we register and
unregister the "mm" into AutoNUMA for knuma_scand to scan them.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/fork.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index b9372a0..ba3b339 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -67,6 +67,7 @@
 #include <linux/oom.h>
 #include <linux/khugepaged.h>
 #include <linux/signalfd.h>
+#include <linux/autonuma.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -505,6 +506,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		mmu_notifier_mm_init(mm);
+		autonuma_enter(mm);
 		return mm;
 	}
 
@@ -572,6 +574,7 @@ void mmput(struct mm_struct *mm)
 		exit_aio(mm);
 		ksm_exit(mm);
 		khugepaged_exit(mm); /* must run before exit_mmap */
+		autonuma_exit(mm); /* must run before exit_mmap */
 		exit_mmap(mm);
 		set_mm_exe_file(mm, NULL);
 		if (!list_empty(&mm->mmlist)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
