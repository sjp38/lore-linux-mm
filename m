Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id BC03C6B00F4
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 06:32:19 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so4264167bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 03:32:19 -0700 (PDT)
Date: Sat, 24 Mar 2012 14:31:10 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 09/10] um: Properly check all process' threads for a live mm
Message-ID: <20120324103110.GI29067@lizard>
References: <20120324102609.GA28356@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120324102609.GA28356@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

kill_off_processes() might miss a valid process, this is because
checking for process->mm is not enough. Process' main thread may
exit or detach its mm via use_mm(), but other threads may still
have a valid mm.

To catch this we use find_lock_task_mm(), which walks up all
threads and returns an appropriate task (with task lock held).

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 arch/um/kernel/reboot.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/um/kernel/reboot.c b/arch/um/kernel/reboot.c
index 1411f4e..3d15243 100644
--- a/arch/um/kernel/reboot.c
+++ b/arch/um/kernel/reboot.c
@@ -6,6 +6,7 @@
 #include "linux/sched.h"
 #include "linux/spinlock.h"
 #include "linux/slab.h"
+#include "linux/oom.h"
 #include "kern_util.h"
 #include "os.h"
 #include "skas.h"
@@ -25,13 +26,13 @@ static void kill_off_processes(void)
 
 		read_lock(&tasklist_lock);
 		for_each_process(p) {
-			task_lock(p);
-			if (!p->mm) {
-				task_unlock(p);
+			struct task_struct *t;
+
+			t = find_lock_task_mm(p);
+			if (!t)
 				continue;
-			}
-			pid = p->mm->context.id.u.pid;
-			task_unlock(p);
+			pid = t->mm->context.id.u.pid;
+			task_unlock(t);
 			os_kill_ptraced_process(pid, 1);
 		}
 		read_unlock(&tasklist_lock);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
