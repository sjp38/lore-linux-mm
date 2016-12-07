Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40BEA6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 10:29:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g186so98712643pgc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:29:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p5si24504404pgn.170.2016.12.07.07.29.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 07:29:27 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20161207081555.GB17136@dhcp22.suse.cz>
In-Reply-To: <20161207081555.GB17136@dhcp22.suse.cz>
Message-Id: <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
Date: Thu, 8 Dec 2016 00:29:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Tue 06-12-16 19:33:59, Tetsuo Handa wrote:
> > If the OOM killer is invoked when many threads are looping inside the
> > page allocator, it is possible that the OOM killer is preempted by other
> > threads.
> 
> Hmm, the only way I can see this would happen is when the task which
> actually manages to take the lock is not invoking the OOM killer for
> whatever reason. Is this what happens in your case? Are you able to
> trigger this reliably?

Regarding http://I-love.SAKURA.ne.jp/tmp/serial-20161206.txt.xz ,
somebody called oom_kill_process() and reached

  pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",

line but did not reach

  pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",

line within tolerable delay.

It is trivial to make the page allocator being spammed by uncontrolled
warn_alloc() like http://I-love.SAKURA.ne.jp/tmp/serial-20161207-2.txt.xz
and delayed by printk() using a stressor shown below. It seems to me that
most of CPU time is spent for pointless direct reclaim and printk().

----------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <poll.h>

int main(int argc, char *argv[])
{
        static char buffer[4096] = { };
        char *buf = NULL;
        unsigned long size;
        int i;
        for (i = 0; i < 1024; i++) {
                if (fork() == 0) {
                        int fd = open("/proc/self/oom_score_adj", O_WRONLY);
                        write(fd, "1000", 4);
                        close(fd);
                        sleep(1);
                        snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
                        //snprintf(buffer, sizeof(buffer), "/tmp/file");
                        fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
                        while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer)) {
                                poll(NULL, 0, 10);
                                fsync(fd);
                        }
                        _exit(0);
                }
        }
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        sleep(2);
        /* Will cause OOM due to overcommit */
        for (i = 0; i < size; i += 4096) {
                buf[i] = 0;
                if (i >= 1800 * 1048576) /* This VM has 2048MB RAM */
                        poll(NULL, 0, 10);
        }
        pause();
        return 0;
}
----------

> 
> > As a result, the OOM killer is unable to send SIGKILL to OOM
> > victims and/or wake up the OOM reaper by releasing oom_lock for minutes
> > because other threads consume a lot of CPU time for pointless direct
> > reclaim.
> > 
> > ----------
> > [ 2802.635229] Killed process 7267 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [ 2802.644296] oom_reaper: reaped process 7267 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [ 2802.650237] Out of memory: Kill process 7268 (a.out) score 999 or sacrifice child
> > [ 2803.653052] Killed process 7268 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [ 2804.426183] oom_reaper: reaped process 7268 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [ 2804.432524] Out of memory: Kill process 7269 (a.out) score 999 or sacrifice child
> > [ 2805.349380] a.out: page allocation stalls for 10047ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > [ 2805.349383] CPU: 2 PID: 7243 Comm: a.out Not tainted 4.9.0-rc8 #62
> > (...snipped...)
> > [ 3540.977499]           a.out  7269     22716.893359      5272   120
> > [ 3540.977499]         0.000000      1447.601063         0.000000
> > [ 3540.977499]  0 0
> > [ 3540.977500]  /autogroup-155
> > ----------
> > 
> > This patch adds extra sleeps which is effectively equivalent to
> > 
> >   if (mutex_lock_killable(&oom_lock) == 0)
> >     mutex_unlock(&oom_lock);
> > 
> > before retrying allocation at __alloc_pages_may_oom() so that the
> > OOM killer is not preempted by other threads waiting for the OOM
> > killer/reaper to reclaim memory. Since the OOM reaper grabs oom_lock
> > due to commit e2fe14564d3316d1 ("oom_reaper: close race with exiting
> > task"), waking up other threads before the OOM reaper is woken up by
> > directly waiting for oom_lock might not help so much.
> 
> So, why don't you simply s@mutex_trylock@mutex_lock_killable@ then?
> The trylock is simply an optimistic heuristic to retry while the memory
> is being freed. Making this part sync might help for the case you are
> seeing.

May I? Something like below? With patch below, the OOM killer can send
SIGKILL smoothly and printk() can report smoothly (the frequency of
"** XXX printk messages dropped **" messages is significantly reduced).

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c6d5f6..ee0105b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3075,7 +3075,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	 * Acquire the oom lock.  If that fails, somebody else is
 	 * making progress for us.
 	 */
-	if (!mutex_trylock(&oom_lock)) {
+	if (mutex_lock_killable(&oom_lock)) {
 		*did_some_progress = 1;
 		schedule_timeout_uninterruptible(1);
 		return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
