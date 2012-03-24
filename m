Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id BE0806B00E7
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 06:29:39 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so4263417bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 03:29:39 -0700 (PDT)
Date: Sat, 24 Mar 2012 14:28:31 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 03/10] powerpc: Use clear_tasks_mm_cpumask()
Message-ID: <20120324102831.GC29067@lizard>
References: <20120324102609.GA28356@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120324102609.GA28356@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

Current CPU hotplug code has some task->mm handling issues:

1. Working with task->mm w/o getting mm or grabing the task lock is
   dangerous as ->mm might disappear (exit_mm() assigns NULL under
   task_lock(), so tasklist lock is not enough).

   We can't use get_task_mm()/mmput() pair as mmput() might sleep,
   so we must take the task lock while handle its mm.

2. Checking for process->mm is not enough because process' main
   thread may exit or detach its mm via use_mm(), but other threads
   may still have a valid mm.

   To fix this we would need to use find_lock_task_mm(), which would
   walk up all threads and returns an appropriate task (with task
   lock held).

clear_tasks_mm_cpumask() has all the issues fixed, so let's use it.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 arch/powerpc/mm/mmu_context_nohash.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_nohash.c b/arch/powerpc/mm/mmu_context_nohash.c
index 5b63bd3..e779642 100644
--- a/arch/powerpc/mm/mmu_context_nohash.c
+++ b/arch/powerpc/mm/mmu_context_nohash.c
@@ -333,9 +333,7 @@ static int __cpuinit mmu_context_cpu_notify(struct notifier_block *self,
 					    unsigned long action, void *hcpu)
 {
 	unsigned int cpu = (unsigned int)(long)hcpu;
-#ifdef CONFIG_HOTPLUG_CPU
-	struct task_struct *p;
-#endif
+
 	/* We don't touch CPU 0 map, it's allocated at aboot and kept
 	 * around forever
 	 */
@@ -358,12 +356,7 @@ static int __cpuinit mmu_context_cpu_notify(struct notifier_block *self,
 		stale_map[cpu] = NULL;
 
 		/* We also clear the cpu_vm_mask bits of CPUs going away */
-		read_lock(&tasklist_lock);
-		for_each_process(p) {
-			if (p->mm)
-				cpumask_clear_cpu(cpu, mm_cpumask(p->mm));
-		}
-		read_unlock(&tasklist_lock);
+		clear_tasks_mm_cpumask(cpu);
 	break;
 #endif /* CONFIG_HOTPLUG_CPU */
 	}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
