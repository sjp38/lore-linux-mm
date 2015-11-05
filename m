Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8E55582F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 10:00:10 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so65620070pac.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 07:00:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id fd1si10745228pad.44.2015.11.05.07.00.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Nov 2015 07:00:08 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable() checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151022143349.GD30579@mtj.duckdns.org>
	<alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
	<20151022151414.GF30579@mtj.duckdns.org>
	<20151023042649.GB18907@mtj.duckdns.org>
	<20151102150137.GB3442@dhcp22.suse.cz>
In-Reply-To: <20151102150137.GB3442@dhcp22.suse.cz>
Message-Id: <201511052359.JBB24816.FHtFOJOSLOVMQF@I-love.SAKURA.ne.jp>
Date: Thu, 5 Nov 2015 23:59:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, htejun@gmail.com
Cc: cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Michal Hocko wrote:
> As already pointed out I really detest a short sleep and would prefer
> a way to tell WQ what we really need. vmstat is not the only user. OOM
> sysrq will need this special treatment as well. While the
> zone_reclaimable can be fixed in an easy patch
> (http://lkml.kernel.org/r/201510212126.JIF90648.HOOFJVFQLMStOF%40I-love.SAKURA.ne.jp)
> which is perfectly suited for the stable backport, OOM sysrq resp. any
> sysrq which runs from the WQ context should be as robust as possible and
> shouldn't rely on all the code running from WQ context to issue a sleep
> to get unstuck. So I definitely support something like this patch.

I still prefer a short sleep from a different perspective.

I tested above patch with below patch applied

----------------------------------------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0499ff..54bedd8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2992,6 +2992,53 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
 	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
 }
 
+static atomic_t stall_tasks;
+
+static int kmallocwd(void *unused)
+{
+	struct task_struct *g, *p;
+	unsigned int sigkill_pending;
+	unsigned int memdie_pending;
+	unsigned int stalling_tasks;
+
+ not_stalling: /* Healty case. */
+	schedule_timeout_interruptible(HZ);
+	if (likely(!atomic_read(&stall_tasks)))
+		goto not_stalling;
+ maybe_stalling: /* Maybe something is wrong. Let's check. */
+	/* Count stalling tasks, dying and victim tasks. */
+	sigkill_pending = 0;
+	memdie_pending = 0;
+	stalling_tasks = atomic_read(&stall_tasks);
+	preempt_disable();
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			memdie_pending++;
+		if (fatal_signal_pending(p))
+			sigkill_pending++;
+	}
+	rcu_read_unlock();
+	preempt_enable();
+	pr_warn("MemAlloc-Info: %u stalling task, %u dying task, %u victim task.\n",
+		stalling_tasks, sigkill_pending, memdie_pending);
+	show_workqueue_state();
+	schedule_timeout_interruptible(10 * HZ);
+	if (atomic_read(&stall_tasks))
+		goto maybe_stalling;
+	goto not_stalling;
+	return 0; /* To suppress "no return statement" compiler warning. */
+}
+
+static int __init start_kmallocwd(void)
+{
+	struct task_struct *task = kthread_run(kmallocwd, NULL,
+					       "kmallocwd");
+	BUG_ON(IS_ERR(task));
+	return 0;
+}
+late_initcall(start_kmallocwd);
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -3004,6 +3051,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	unsigned long start = jiffies;
+	bool stall_counted = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3095,6 +3144,11 @@ retry:
 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
+	if (!stall_counted && time_after(jiffies, start + 10 * HZ)) {
+		atomic_inc(&stall_tasks);
+		stall_counted = true;
+	}
+
 	/*
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
@@ -3188,6 +3242,8 @@ noretry:
 nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 got_pg:
+	if (stall_counted)
+		atomic_dec(&stall_tasks);
 	return page;
 }
 
----------------------------------------

using a crazy stressing program. (Not a TIF_MEMDIE stall.)

----------------------------------------
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <fcntl.h>

static void child(void)
{
	char *buf = NULL;
	unsigned long size = 0;
	const int fd = open("/dev/zero", O_RDONLY);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	read(fd, buf, size); /* Will cause OOM due to overcommit */
}

int main(int argc, char *argv[])
{
	if (argc > 1) {
		int i;
		char buffer[4096];
		for (i = 0; i < 1000; i++) {
			if (fork() == 0) {
				sleep(20);
				memset(buffer, 0, sizeof(buffer));
				_exit(0);
			}
		}
		child();
		return 0;
	}
	signal(SIGCLD, SIG_IGN);
	while (1) {
		switch (fork()) {
		case 0:
			execl("/proc/self/exe", argv[0], "1", NULL);;
			_exit(0);
		case -1:
			sleep(1);
		}
	}
	return 0;
}
----------------------------------------

Note the interval between invoking the OOM killer.
(Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20151105.txt.xz .)
----------------------------------------
[   74.260621] exe invoked oom-killer: gfp_mask=0x24280ca, order=0, oom_score_adj=0
[   75.069510] exe invoked oom-killer: gfp_mask=0x24200ca, order=0, oom_score_adj=0
[   79.062507] exe invoked oom-killer: gfp_mask=0x24280ca, order=0, oom_score_adj=0
[   80.464618] MemAlloc-Info: 459 stalling task, 0 dying task, 0 victim task.
[   90.482731] MemAlloc-Info: 699 stalling task, 0 dying task, 0 victim task.
[  100.503633] MemAlloc-Info: 3972 stalling task, 0 dying task, 0 victim task.
[  110.534937] MemAlloc-Info: 4097 stalling task, 0 dying task, 0 victim task.
[  120.535740] MemAlloc-Info: 4098 stalling task, 0 dying task, 0 victim task.
[  130.563961] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  140.593108] MemAlloc-Info: 4096 stalling task, 0 dying task, 0 victim task.
[  150.617960] MemAlloc-Info: 4096 stalling task, 0 dying task, 0 victim task.
[  160.639131] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  170.659915] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  172.597736] exe invoked oom-killer: gfp_mask=0x24280ca, order=0, oom_score_adj=0
[  180.680650] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  190.705534] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  200.724567] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  210.745397] MemAlloc-Info: 4065 stalling task, 0 dying task, 0 victim task.
[  220.769501] MemAlloc-Info: 4092 stalling task, 0 dying task, 0 victim task.
[  230.791530] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  240.816711] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  250.836724] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  260.860257] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  270.883573] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  280.910072] MemAlloc-Info: 4088 stalling task, 0 dying task, 0 victim task.
[  290.931988] MemAlloc-Info: 4092 stalling task, 0 dying task, 0 victim task.
[  300.955543] MemAlloc-Info: 4099 stalling task, 0 dying task, 0 victim task.
[  308.212307] exe invoked oom-killer: gfp_mask=0x24200ca, order=0, oom_score_adj=0
[  310.977057] MemAlloc-Info: 3988 stalling task, 0 dying task, 0 victim task.
[  320.999353] MemAlloc-Info: 4096 stalling task, 0 dying task, 0 victim task.
----------------------------------------

See? The memory allocation requests cannot constantly invoke the OOM-killer
because the sum of CPU cycles wasted for sleep-less retry loop is close to
mutually blocking other tasks when number of tasks doing memory allocation
requests exceeded number of available CPUs. We should be careful not to defer
invocation of the OOM-killer too much.

If a short sleep patch
( http://lkml.kernel.org/r/201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp )
is applied in addition to the above patches, the memory allocation requests
can constantly invoke the OOM-killer.

By using short sleep, some task might be able to do some useful computation
job which does not involve a __GFP_WAIT memory allocation.

We don't need to defer workqueue items which do not involve a __GFP_WAIT
memory allocation. By allowing workqueue items to be processed (by using
short sleep), some task might release memory when workqueue item is
processed.

Therefore, not only to keep vmstat counters up to date, but also for
avoid wasting CPU cycles, I prefer a short sleep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
