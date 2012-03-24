Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id DF6926B00F0
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 06:31:43 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so4264167bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 03:31:43 -0700 (PDT)
Date: Sat, 24 Mar 2012 14:30:30 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 07/10] um: Should hold tasklist_lock while traversing
 processes
Message-ID: <20120324103030.GG29067@lizard>
References: <20120324102609.GA28356@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120324102609.GA28356@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

Traversing the tasks requires holding tasklist_lock, otherwise it
is unsafe.

p.s. However, I'm not sure that calling os_kill_ptraced_process()
in the atomic context is correct. It seem to work, but please
take a closer look.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 arch/um/kernel/reboot.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/um/kernel/reboot.c b/arch/um/kernel/reboot.c
index 4d93dff..66d754c 100644
--- a/arch/um/kernel/reboot.c
+++ b/arch/um/kernel/reboot.c
@@ -4,6 +4,7 @@
  */
 
 #include "linux/sched.h"
+#include "linux/spinlock.h"
 #include "linux/slab.h"
 #include "kern_util.h"
 #include "os.h"
@@ -22,6 +23,7 @@ static void kill_off_processes(void)
 		struct task_struct *p;
 		int pid;
 
+		read_lock(&tasklist_lock);
 		for_each_process(p) {
 			if (p->mm == NULL)
 				continue;
@@ -29,6 +31,7 @@ static void kill_off_processes(void)
 			pid = p->mm->context.id.u.pid;
 			os_kill_ptraced_process(pid, 1);
 		}
+		read_unlock(&tasklist_lock);
 	}
 }
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
