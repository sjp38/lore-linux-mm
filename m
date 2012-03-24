Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 9EEC26B00F6
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 06:32:37 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so4264167bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 03:32:37 -0700 (PDT)
Date: Sat, 24 Mar 2012 14:31:27 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 10/10] oom: Make find_lock_task_mm() sparse-aware
Message-ID: <20120324103127.GJ29067@lizard>
References: <20120324102609.GA28356@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120324102609.GA28356@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

This is needed so that callers would not get 'context imbalance'
warnings from the sparse tool.

As a side effect, this patch fixes the following sparse warnings:

  CHECK   mm/oom_kill.c
  mm/oom_kill.c:201:28: warning: context imbalance in 'oom_badness' -
  unexpected unlock
  include/linux/rcupdate.h:249:30: warning: context imbalance in
  'dump_tasks' - unexpected unlock
  mm/oom_kill.c:453:9: warning: context imbalance in 'oom_kill_task' -
  unexpected unlock
  CHECK   mm/memcontrol.c
  ...
  mm/memcontrol.c:1130:17: warning: context imbalance in
  'task_in_mem_cgroup' - unexpected unlock

p.s. I know Peter Zijlstra detest the __cond_lock() stuff, but untill
     we have anything better in sparse, let's use it. This particular
     patch helped me to detect one bug that I myself made during
     task->mm fixup series. So, it is useful.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/oom.h |   12 +++++++++++-
 mm/oom_kill.c       |    2 +-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 552fba9..26cf628 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -21,6 +21,7 @@
 
 #ifdef __KERNEL__
 
+#include <linux/compiler.h>
 #include <linux/sched.h>
 #include <linux/types.h>
 #include <linux/nodemask.h>
@@ -65,7 +66,16 @@ static inline void oom_killer_enable(void)
 	oom_killer_disabled = false;
 }
 
-extern struct task_struct *find_lock_task_mm(struct task_struct *p);
+extern struct task_struct *__find_lock_task_mm(struct task_struct *p);
+
+static inline struct task_struct *find_lock_task_mm(struct task_struct *p)
+{
+	struct task_struct *ret;
+
+	ret = __find_lock_task_mm(p);
+	(void)__cond_lock(&ret->alloc_lock, ret);
+	return ret;
+}
 
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2958fd8..0ebb383 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -136,7 +136,7 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
  * pointer.  Return p, or any of its subthreads with a valid ->mm, with
  * task_lock() held.
  */
-struct task_struct *find_lock_task_mm(struct task_struct *p)
+struct task_struct *__find_lock_task_mm(struct task_struct *p)
 {
 	struct task_struct *t = p;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
