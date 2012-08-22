Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CD1886B007B
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:09 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 14/36] autonuma: call autonuma_setup_new_exec()
Date: Wed, 22 Aug 2012 16:58:58 +0200
Message-Id: <1345647560-30387-15-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This resets all per-thread and per-process statistics across exec
syscalls or after kernel threads detach from the mm. The past
statistical NUMA information is unlikely to be relevant for the future
in these cases.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/exec.c        |    7 +++++++
 mm/mmu_context.c |    3 +++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 574cf4d..1d55077 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -55,6 +55,7 @@
 #include <linux/pipe_fs_i.h>
 #include <linux/oom.h>
 #include <linux/compat.h>
+#include <linux/autonuma.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -1172,6 +1173,12 @@ void setup_new_exec(struct linux_binprm * bprm)
 			
 	flush_signal_handlers(current, 0);
 	flush_old_files(current->files);
+
+	/*
+	 * Reset autonuma counters, as past NUMA information
+	 * is unlikely to be relevant for the future.
+	 */
+	autonuma_setup_new_exec(current);
 }
 EXPORT_SYMBOL(setup_new_exec);
 
diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index 3dcfaf4..e6fff1c 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -7,6 +7,7 @@
 #include <linux/mmu_context.h>
 #include <linux/export.h>
 #include <linux/sched.h>
+#include <linux/autonuma.h>
 
 #include <asm/mmu_context.h>
 
@@ -52,6 +53,8 @@ void unuse_mm(struct mm_struct *mm)
 {
 	struct task_struct *tsk = current;
 
+	autonuma_setup_new_exec(tsk);
+
 	task_lock(tsk);
 	sync_mm_rss(mm);
 	tsk->mm = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
