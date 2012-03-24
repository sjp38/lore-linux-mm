Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 85A656B0044
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 12:44:22 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so4417103bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 09:44:20 -0700 (PDT)
Date: Sat, 24 Mar 2012 20:43:16 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH v2.1 01/10] cpu: Introduce clear_tasks_mm_cpumask() helper
Message-ID: <20120324164316.GB3640@lizard>
References: <20120324102609.GA28356@lizard>
 <20120324102751.GA29067@lizard>
 <1332593021.16159.27.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1332593021.16159.27.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

Many architctures clear tasks' mm_cpumask like this:

	read_lock(&tasklist_lock);
	for_each_process(p) {
		if (p->mm)
			cpumask_clear_cpu(cpu, mm_cpumask(p->mm));
	}
	read_unlock(&tasklist_lock);

The code above has several problems, such as:

1. Working with task->mm w/o getting mm or grabing the task lock is
   dangerous as ->mm might disappear (exit_mm() assigns NULL under
   task_lock(), so tasklist lock is not enough).

2. Checking for process->mm is not enough because process' main
   thread may exit or detach its mm via use_mm(), but other threads
   may still have a valid mm.

This patch implements a small helper function that does things
correctly, i.e.:

1. We take the task's lock while whe handle its mm (we can't use
   get_task_mm()/mmput() pair as mmput() might sleep);

2. To catch exited main thread case, we use find_lock_task_mm(),
   which walks up all threads and returns an appropriate task
   (with task lock held).

Also, Per Peter Zijlstra's idea, now we don't grab tasklist_lock in
the new helper, instead we take the rcu read lock. We can do this
because the function is called after the cpu is taken down and marked
offline, so no new tasks will get this cpu set in their mm mask.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---

On Sat, Mar 24, 2012 at 01:43:41PM +0100, Peter Zijlstra wrote:
> On Sat, 2012-03-24 at 14:27 +0400, Anton Vorontsov wrote:
> > +       read_unlock(&tasklist_lock);
> > +} 
> 
> Why bother with the tasklist_lock at all anymore, afaict you could use
> rcu_read_lock() here. This all is called after the cpu is taken down and
> marked offline, so its not like new tasks will ever get this cpu set in
> their mm mask.

I guess you're right. Well, this would make the code a bit fragile,
but a comment might help.

How about this version?

 include/linux/cpu.h |    1 +
 kernel/cpu.c        |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 1f65875..941e865 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -171,6 +171,7 @@ extern void put_online_cpus(void);
 #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
 #define register_hotcpu_notifier(nb)	register_cpu_notifier(nb)
 #define unregister_hotcpu_notifier(nb)	unregister_cpu_notifier(nb)
+void clear_tasks_mm_cpumask(int cpu);
 int cpu_down(unsigned int cpu);
 
 #ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 2060c6e..ecdf499 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -10,6 +10,8 @@
 #include <linux/sched.h>
 #include <linux/unistd.h>
 #include <linux/cpu.h>
+#include <linux/oom.h>
+#include <linux/rcupdate.h>
 #include <linux/export.h>
 #include <linux/kthread.h>
 #include <linux/stop_machine.h>
@@ -171,6 +173,30 @@ void __ref unregister_cpu_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL(unregister_cpu_notifier);
 
+void clear_tasks_mm_cpumask(int cpu)
+{
+	struct task_struct *p;
+
+	/*
+	 * This function is called after the cpu is taken down and marked
+	 * offline, so its not like new tasks will ever get this cpu set in
+	 * their mm mask. -- Peter Zijlstra
+	 * Thus, we may use rcu_read_lock() here, instead of grabbing
+	 * full-fledged tasklist_lock.
+	 */
+	rcu_read_lock();
+	for_each_process(p) {
+		struct task_struct *t;
+
+		t = find_lock_task_mm(p);
+		if (!t)
+			continue;
+		cpumask_clear_cpu(cpu, mm_cpumask(t->mm));
+		task_unlock(t);
+	}
+	rcu_read_unlock();
+}
+
 static inline void check_for_tasks(int cpu)
 {
 	struct task_struct *p;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
