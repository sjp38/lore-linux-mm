Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D53336B0038
	for <linux-mm@kvack.org>; Sat, 21 Jan 2017 02:43:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z67so126159254pgb.0
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 23:43:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p128si9169834pfg.131.2017.01.20.23.43.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 23:43:01 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170118172944.GA17135@dhcp22.suse.cz>
	<20170119100755.rs6erdiz5u5by2pu@suse.de>
	<20170119112336.GN30786@dhcp22.suse.cz>
	<20170119131143.2ze5l5fwheoqdpne@suse.de>
	<201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
In-Reply-To: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
Message-Id: <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
Date: Sat, 21 Jan 2017 16:42:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, mhocko@kernel.org, viro@ZenIV.linux.org.uk
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> And I think that there is a different problem if I tune a reproducer
> like below (i.e. increased the buffer size to write()/fsync() from 4096).
> 
> ----------
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> 
> int main(int argc, char *argv[])
> {
> 	static char buffer[10485760] = { }; /* or 1048576 */
> 	char *buf = NULL;
> 	unsigned long size;
> 	unsigned long i;
> 	for (i = 0; i < 1024; i++) {
> 		if (fork() == 0) {
> 			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
> 			write(fd, "1000", 4);
> 			close(fd);
> 			sleep(1);
> 			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
> 			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
> 			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer))
> 				fsync(fd);
> 			_exit(0);
> 		}
> 	}
> 	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
> 		char *cp = realloc(buf, size);
> 		if (!cp) {
> 			size >>= 1;
> 			break;
> 		}
> 		buf = cp;
> 	}
> 	sleep(2);
> 	/* Will cause OOM due to overcommit */
> 	for (i = 0; i < size; i += 4096)
> 		buf[i] = 0;
> 	pause();
> 	return 0;
> }
> ----------
> 
> Above reproducer sometimes kills all OOM killable processes and the system
> finally panics. I guess that somebody is abusing TIF_MEMDIE for needless
> allocations to the level where GFP_ATOMIC allocations start failing.

I tracked who is abusing TIF_MEMDIE using below patch.

----------------------------------------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ea088e1..d9ac53d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3038,7 +3038,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
 
-	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
+	if (1 || (gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
 	    debug_guardpage_minorder() > 0)
 		return;
 
@@ -3573,6 +3573,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	int no_progress_loops = 0;
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
+	bool victim = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3656,8 +3657,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
-	if (gfp_pfmemalloc_allowed(gfp_mask))
+	if (gfp_pfmemalloc_allowed(gfp_mask)) {
 		alloc_flags = ALLOC_NO_WATERMARKS;
+		victim = test_thread_flag(TIF_MEMDIE);
+	}
 
 	/*
 	 * Reset the zonelist iterators if memory policies can be ignored.
@@ -3790,6 +3793,11 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	warn_alloc(gfp_mask, ac->nodemask,
 			"page allocation failure: order:%u", order);
 got_pg:
+	if (page && victim) {
+		pr_warn("%s(%u): TIF_MEMDIE allocation: order=%d mode=%#x(%pGg)\n",
+			current->comm, current->pid, order, gfp_mask, &gfp_mask);
+		dump_stack();
+	}
 	return page;
 }
 
----------------------------------------

And I got flood of traces shown below. It seems to be consuming memory reserves
until the size passed to write() request is stored to the page cache even after
OOM-killed.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170121.txt.xz .
----------------------------------------
[  202.306077] a.out(9789): TIF_MEMDIE allocation: order=0 mode=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
[  202.309832] CPU: 0 PID: 9789 Comm: a.out Not tainted 4.10.0-rc4-next-20170120+ #492
[  202.312323] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  202.315429] Call Trace:
[  202.316902]  dump_stack+0x85/0xc9
[  202.318810]  __alloc_pages_slowpath+0xa99/0xd7c
[  202.320697]  ? node_dirty_ok+0xef/0x130
[  202.322454]  __alloc_pages_nodemask+0x436/0x4d0
[  202.324506]  alloc_pages_current+0x97/0x1b0
[  202.326397]  __page_cache_alloc+0x15d/0x1a0          mm/filemap.c:728
[  202.328209]  pagecache_get_page+0x5a/0x2b0           mm/filemap.c:1331
[  202.329989]  grab_cache_page_write_begin+0x23/0x40   mm/filemap.c:2773
[  202.331905]  iomap_write_begin+0x50/0xd0             fs/iomap.c:118
[  202.333641]  iomap_write_actor+0xb5/0x1a0            fs/iomap.c:190
[  202.335377]  ? iomap_write_end+0x80/0x80             fs/iomap.c:150
[  202.337090]  iomap_apply+0xb3/0x130                  fs/iomap.c:79
[  202.338721]  iomap_file_buffered_write+0x68/0xa0     fs/iomap.c:243
[  202.340613]  ? iomap_write_end+0x80/0x80
[  202.342471]  xfs_file_buffered_aio_write+0x132/0x390 [xfs]
[  202.344501]  ? remove_wait_queue+0x59/0x60
[  202.346261]  xfs_file_write_iter+0x90/0x130 [xfs]
[  202.348082]  __vfs_write+0xe5/0x140
[  202.349743]  vfs_write+0xc7/0x1f0
[  202.351214]  ? syscall_trace_enter+0x1d0/0x380
[  202.353155]  SyS_write+0x58/0xc0
[  202.354628]  do_syscall_64+0x6c/0x200
[  202.356100]  entry_SYSCALL64_slow_path+0x25/0x25
----------------------------------------

Do we need to allow access to memory reserves for this allocation?
Or, should the caller check for SIGKILL rather than iterate the loop?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
