Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 1CE636B00E9
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 03:10:06 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id eh20so13289908obb.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 00:10:05 -0700 (PDT)
Date: Mon, 23 Apr 2012 00:08:49 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 4/9] sh: Use clear_tasks_mm_cpumask()
Message-ID: <20120423070849.GD30752@lizard>
References: <20120423070641.GA27702@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120423070641.GA27702@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linaro-kernel@lists.linaro.org, patches@linaro.org, linux-mm@kvack.org

Checking for process->mm is not enough because process' main
thread may exit or detach its mm via use_mm(), but other threads
may still have a valid mm.

To fix this we would need to use find_lock_task_mm(), which would
walk up all threads and returns an appropriate task (with task
lock held).

clear_tasks_mm_cpumask() has the issue fixed, so let's use it.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 arch/sh/kernel/smp.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/sh/kernel/smp.c b/arch/sh/kernel/smp.c
index eaebdf6..4664f76 100644
--- a/arch/sh/kernel/smp.c
+++ b/arch/sh/kernel/smp.c
@@ -123,7 +123,6 @@ void native_play_dead(void)
 int __cpu_disable(void)
 {
 	unsigned int cpu = smp_processor_id();
-	struct task_struct *p;
 	int ret;
 
 	ret = mp_ops->cpu_disable(cpu);
@@ -153,11 +152,7 @@ int __cpu_disable(void)
 	flush_cache_all();
 	local_flush_tlb_all();
 
-	read_lock(&tasklist_lock);
-	for_each_process(p)
-		if (p->mm)
-			cpumask_clear_cpu(cpu, mm_cpumask(p->mm));
-	read_unlock(&tasklist_lock);
+	clear_tasks_mm_cpumask(cpu);
 
 	return 0;
 }
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
