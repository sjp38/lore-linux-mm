Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7797544044D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 09:22:36 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id mw1so60089206igb.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:22:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k20si20388990ioe.26.2016.02.04.06.22.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 06:22:35 -0800 (PST)
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454505240-23446-4-git-send-email-mhocko@kernel.org>
Message-Id: <201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
Date: Thu, 4 Feb 2016 23:22:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> When oom_reaper manages to unmap all the eligible vmas there shouldn't
> be much of the freable memory held by the oom victim left anymore so it
> makes sense to clear the TIF_MEMDIE flag for the victim and allow the
> OOM killer to select another task.

Just a confirmation. Is it safe to clear TIF_MEMDIE without reaching do_exit()
with regard to freezing_slow_path()? Since clearing TIF_MEMDIE from the OOM
reaper confuses

    wait_event(oom_victims_wait, !atomic_read(&oom_victims));

in oom_killer_disable(), I'm worrying that the freezing operation continues
before the OOM victim which escaped the __refrigerator() actually releases
memory. Does this cause consistency problem?

> +	/*
> +	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> +	 * reasonably reclaimable memory anymore. OOM killer can continue
> +	 * by selecting other victim if unmapping hasn't led to any
> +	 * improvements. This also means that selecting this task doesn't
> +	 * make any sense.
> +	 */
> +	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
> +	exit_oom_victim(tsk);

I noticed that updating only one thread group's oom_score_adj disables
further wake_oom_reaper() calls due to rough-grained can_oom_reap check at

  p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN

in oom_kill_process(). I think we need to either update all thread groups'
oom_score_adj using the reaped mm equally or use more fine-grained can_oom_reap
check which ignores OOM_SCORE_ADJ_MIN if all threads in that thread group are
dying or exiting.

----------
#define _GNU_SOURCE
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int writer(void *unused)
{
	static char buffer[4096];
	int fd = open("/tmp/file", O_WRONLY | O_CREAT | O_APPEND, 0600);
	while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
	return 0;
}

int main(int argc, char *argv[])
{
	unsigned long size;
	char *buf = NULL;
	unsigned long i;
	if (fork() == 0) {
		int fd = open("/proc/self/oom_score_adj", O_WRONLY);
		write(fd, "1000", 4);
		close(fd);
		for (i = 0; i < 2; i++) {
			char *stack = malloc(4096);
			if (stack)
				clone(writer, stack + 4096, CLONE_VM, NULL);
		}
		writer(NULL);
		while (1)
			pause();
	}
	sleep(1);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sleep(5);
	/* Will cause OOM due to overcommit */
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	pause();
	return 0;
}
----------

----------
[  177.722853] a.out invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0, oom_score_adj=0
[  177.724956] a.out cpuset=/ mems_allowed=0
[  177.725735] CPU: 3 PID: 3962 Comm: a.out Not tainted 4.5.0-rc2-next-20160204 #291
(...snipped...)
[  177.802889] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
(...snipped...)
[  177.872248] [ 3941]  1000  3941    28880      124      14       3        0             0 bash
[  177.874279] [ 3962]  1000  3962   541717   395780     784       6        0             0 a.out
[  177.876274] [ 3963]  1000  3963     1078       21       7       3        0          1000 a.out
[  177.878261] [ 3964]  1000  3964     1078       21       7       3        0          1000 a.out
[  177.880194] [ 3965]  1000  3965     1078       21       7       3        0          1000 a.out
[  177.882262] Out of memory: Kill process 3963 (a.out) score 998 or sacrifice child
[  177.884129] Killed process 3963 (a.out) total-vm:4312kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  177.887100] oom_reaper: reaped process :3963 (a.out) anon-rss:0kB, file-rss:0kB, shmem-rss:0lB
[  179.638399] crond invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), order=0, oom_score_adj=0
[  179.647708] crond cpuset=/ mems_allowed=0
[  179.652996] CPU: 3 PID: 742 Comm: crond Not tainted 4.5.0-rc2-next-20160204 #291
(...snipped...)
[  179.771311] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
(...snipped...)
[  179.836221] [ 3941]  1000  3941    28880      124      14       3        0             0 bash
[  179.838278] [ 3962]  1000  3962   541717   396308     785       6        0             0 a.out
[  179.840328] [ 3963]  1000  3963     1078        0       7       3        0         -1000 a.out
[  179.842443] [ 3965]  1000  3965     1078        0       7       3        0          1000 a.out
[  179.844557] Out of memory: Kill process 3965 (a.out) score 998 or sacrifice child
[  179.846404] Killed process 3965 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
