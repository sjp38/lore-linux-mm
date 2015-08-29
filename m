Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A7DFF6B0038
	for <linux-mm@kvack.org>; Sat, 29 Aug 2015 07:15:15 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so88483910pac.2
        for <linux-mm@kvack.org>; Sat, 29 Aug 2015 04:15:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id dh6si14729649pdb.30.2015.08.29.04.15.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 29 Aug 2015 04:15:14 -0700 (PDT)
Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201508292014.ICI39552.tQJOFFOVMSOFHL@I-love.SAKURA.ne.jp>
Date: Sat, 29 Aug 2015 20:14:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Reposting a patch at http://marc.info/?l=linux-mm&m=143256441501204 :

---------- fool-sysrq-f.c start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
	const int fd = open("/tmp/file", O_WRONLY | O_CREAT | O_APPEND, 0600);
	while (write(fd, "", 1) == 1);
	return 0;
}

static int memory_consumer(void *unused)
{
	const int fd = open("/dev/zero", O_RDONLY);
	unsigned long size;
	char *buf = NULL;
	sleep(3);
	unlink("/tmp/file");
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	read(fd, buf, size); /* Will cause OOM due to overcommit */
	return 0;
}

int main(int argc, char *argv[])
{
	int i;
	for (i = 0; i < 1000; i++)
		clone(file_writer, malloc(4 * 1024) + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL);
	clone(memory_consumer, malloc(4 * 1024) + 4 * 1024, CLONE_SIGHAND | CLONE_VM, NULL);
	pause();
	return 0;
}
---------- fool-sysrq-f.c end ----------

You can see that the "sharing same memory" lines are reduced.

---------- console log start ----------
[   70.947578] fool-sysrq-f invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[   70.949288] fool-sysrq-f cpuset=/ mems_allowed=0
[   70.950521] CPU: 3 PID: 5803 Comm: fool-sysrq-f Tainted: G        W       4.2.0-rc8-next-20150828+ #87
(...snipped...)
[   72.997636] [ 5802]  1000  5802   542739   390721     774       6        0             0 fool-sysrq-f
[   72.999494] [ 5803]  1000  5803   542739   390721     774       6        0             0 fool-sysrq-f
[   73.001334] Out of memory: Kill process 4802 (fool-sysrq-f) score 874 or sacrifice child
[   73.003061] Killed process 4802 (fool-sysrq-f) total-vm:2170956kB, anon-rss:1562884kB, file-rss:0kB
[   73.004929] Kill process 4803 (fool-sysrq-f) sharing same memory
(...snipped...)
[   74.244404] Kill process 5801 (fool-sysrq-f) sharing same memory
[   74.245666] Kill process 5802 (fool-sysrq-f) sharing same memory
[   74.246943] Kill process 5803 (fool-sysrq-f) sharing same memory
[   74.250564] kworker/3:2 invoked oom-killer: gfp_mask=0x2000d0, order=0, oom_score_adj=0
[   74.252211] kworker/3:2 cpuset=/ mems_allowed=0
(...snipped...)
[   75.321323] [ 5801]  1000  5801   542739   390808     774       6        0             0 fool-sysrq-f
[   75.321324] [ 5802]  1000  5802   542739   390808     774       6        0             0 fool-sysrq-f
[   75.321326] Out of memory: Kill process 4803 (fool-sysrq-f) score 874 or sacrifice child
[   75.321327] Killed process 4803 (fool-sysrq-f) total-vm:2170956kB, anon-rss:1563232kB, file-rss:0kB
[   94.887669] sysrq: SysRq : Manual OOM execution
[   94.889230] kworker/2:0 invoked oom-killer: gfp_mask=0xd0, order=-1, oom_score_adj=0
[   94.890933] kworker/2:0 cpuset=/ mems_allowed=0
(...snipped...)
[   96.913896] [ 5801]  1000  5801   542739   390808     774       6        0             0 fool-sysrq-f
[   96.915737] [ 5802]  1000  5802   542739   390808     774       6        0             0 fool-sysrq-f
[   96.917568] Out of memory: Kill process 4803 (fool-sysrq-f) score 874 or sacrifice child
[   96.919224] Killed process 4803 (fool-sysrq-f) total-vm:2170956kB, anon-rss:1563232kB, file-rss:0kB
[  108.279680] sysrq: SysRq : Manual OOM execution
[  108.283249] kworker/2:0 invoked oom-killer: gfp_mask=0xd0, order=-1, oom_score_adj=0
[  108.284892] kworker/2:0 cpuset=/ mems_allowed=0
(...snipped...)
[  110.311167] [ 5801]  1000  5801   542739   390808     774       6        0             0 fool-sysrq-f
[  110.313006] [ 5802]  1000  5802   542739   390808     774       6        0             0 fool-sysrq-f
[  110.314847] Out of memory: Kill process 4803 (fool-sysrq-f) score 874 or sacrifice child
[  110.316494] Killed process 4803 (fool-sysrq-f) total-vm:2170956kB, anon-rss:1563232kB, file-rss:0kB
[  128.055355] sysrq: SysRq : Manual OOM execution
[  128.056931] kworker/2:0 invoked oom-killer: gfp_mask=0xd0, order=-1, oom_score_adj=0
[  128.058587] kworker/2:0 cpuset=/ mems_allowed=0
(...snipped...)
[  194.871314] sysrq: SysRq : Manual OOM execution
[  194.873328] kworker/2:0 invoked oom-killer: gfp_mask=0xd0, order=-1, oom_score_adj=0
[  194.875491] kworker/2:0 cpuset=/ mems_allowed=0
(...snipped...)
[  196.939486] [ 5801]  1000  5801   542739   390808     774       6        0             0 fool-sysrq-f
[  196.941329] [ 5802]  1000  5802   542739   390808     774       6        0             0 fool-sysrq-f
[  196.943291] Out of memory: Kill process 4803 (fool-sysrq-f) score 874 or sacrifice child
[  196.944922] Killed process 4803 (fool-sysrq-f) total-vm:2170956kB, anon-rss:1563232kB, file-rss:0kB
[  204.274562] sysrq: SysRq : Resetting
[  204.275513] ACPI MEMORY or I/O RESET_REG.
---------- console log end ----------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150829.txt.xz .



By the way, quoting from http://marc.info/?l=linux-mm&m=144014507122830 :
> As Tetsuo has shown, such a load can be
> generated from the userspace without root privileges so it is much
> easier to make the system _completely_ unusable with this patch. Not that
> having an OOM deadlock would be great but you still have emergency tools
> like sysrq triggered OOM killer to attempt to sort the situation out.

We still have emergency tools like sysrq triggered OOM killer but we can't
assume it works. Allowing small !__GFP_FS allocations to fail would make it
work for several cases, but not all cases...


----------------------------------------
>From 540e1ba8db5e7044134d838a256f28080cdba0f0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 29 Aug 2015 19:24:06 +0900
Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.

If the mm struct which an OOM victim is using is shared by e.g. 1000
other thread groups, the kernel would emit the

  "Kill process %d (%s) sharing same memory\n"

line for 1000 times.

Currently, OOM killer by SysRq-f can get stuck (i.e. SysRq-f is unable
to kill a different task due to choosing the same OOM victim forever)
if there is already an OOM victim. The user who presses SysRq-f need to
check the

  "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n"

line in order to judge whether SysRq-f got stuck or not, but the 1000
"Kill process" lines sweeps the "Killed process" line out of console
screen, making it impossible to judge whether OOM killer by SysRq-f got
stuck or not.

Fixing the stuck problem is outside of this patch's scope. This patch
reduces the "Kill process" lines by printing that line only if SIGKILL
is not pending.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ecc0bc..4816fb7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -576,6 +576,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		    !(p->flags & PF_KTHREAD)) {
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
+			if (fatal_signal_pending(p))
+				continue;
 
 			task_lock(p);	/* Protect ->comm from prctl() */
 			pr_err("Kill process %d (%s) sharing same memory\n",
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
