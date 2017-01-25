Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0C26B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:15:23 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so35848908wmr.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 02:15:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e144si21764738wme.6.2017.01.25.02.15.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 02:15:21 -0800 (PST)
Date: Wed, 25 Jan 2017 11:15:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170125101517.GG32377@dhcp22.suse.cz>
References: <20170118172944.GA17135@dhcp22.suse.cz>
 <20170119100755.rs6erdiz5u5by2pu@suse.de>
 <20170119112336.GN30786@dhcp22.suse.cz>
 <20170119131143.2ze5l5fwheoqdpne@suse.de>
 <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
 <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Christoph Hellwig <hch@lst.de>
Cc: mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

[Let's add Christoph]

The below insane^Wstress test should exercise the OOM killer behavior.

On Sat 21-01-17 16:42:42, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > And I think that there is a different problem if I tune a reproducer
> > like below (i.e. increased the buffer size to write()/fsync() from 4096).
> > 
> > ----------
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <string.h>
> > #include <unistd.h>
> > #include <sys/types.h>
> > #include <sys/stat.h>
> > #include <fcntl.h>
> > 
> > int main(int argc, char *argv[])
> > {
> > 	static char buffer[10485760] = { }; /* or 1048576 */
> > 	char *buf = NULL;
> > 	unsigned long size;
> > 	unsigned long i;
> > 	for (i = 0; i < 1024; i++) {
> > 		if (fork() == 0) {
> > 			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
> > 			write(fd, "1000", 4);
> > 			close(fd);
> > 			sleep(1);
> > 			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
> > 			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
> > 			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer))
> > 				fsync(fd);
> > 			_exit(0);
> > 		}
> > 	}
> > 	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
> > 		char *cp = realloc(buf, size);
> > 		if (!cp) {
> > 			size >>= 1;
> > 			break;
> > 		}
> > 		buf = cp;
> > 	}
> > 	sleep(2);
> > 	/* Will cause OOM due to overcommit */
> > 	for (i = 0; i < size; i += 4096)
> > 		buf[i] = 0;
> > 	pause();
> > 	return 0;
> > }
> > ----------
> > 
> > Above reproducer sometimes kills all OOM killable processes and the system
> > finally panics. I guess that somebody is abusing TIF_MEMDIE for needless
> > allocations to the level where GFP_ATOMIC allocations start failing.
[...] 
> And I got flood of traces shown below. It seems to be consuming memory reserves
> until the size passed to write() request is stored to the page cache even after
> OOM-killed.
> 
> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170121.txt.xz .
> ----------------------------------------
> [  202.306077] a.out(9789): TIF_MEMDIE allocation: order=0 mode=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
> [  202.309832] CPU: 0 PID: 9789 Comm: a.out Not tainted 4.10.0-rc4-next-20170120+ #492
> [  202.312323] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> [  202.315429] Call Trace:
> [  202.316902]  dump_stack+0x85/0xc9
> [  202.318810]  __alloc_pages_slowpath+0xa99/0xd7c
> [  202.320697]  ? node_dirty_ok+0xef/0x130
> [  202.322454]  __alloc_pages_nodemask+0x436/0x4d0
> [  202.324506]  alloc_pages_current+0x97/0x1b0
> [  202.326397]  __page_cache_alloc+0x15d/0x1a0          mm/filemap.c:728
> [  202.328209]  pagecache_get_page+0x5a/0x2b0           mm/filemap.c:1331
> [  202.329989]  grab_cache_page_write_begin+0x23/0x40   mm/filemap.c:2773
> [  202.331905]  iomap_write_begin+0x50/0xd0             fs/iomap.c:118
> [  202.333641]  iomap_write_actor+0xb5/0x1a0            fs/iomap.c:190
> [  202.335377]  ? iomap_write_end+0x80/0x80             fs/iomap.c:150
> [  202.337090]  iomap_apply+0xb3/0x130                  fs/iomap.c:79
> [  202.338721]  iomap_file_buffered_write+0x68/0xa0     fs/iomap.c:243
> [  202.340613]  ? iomap_write_end+0x80/0x80
> [  202.342471]  xfs_file_buffered_aio_write+0x132/0x390 [xfs]
> [  202.344501]  ? remove_wait_queue+0x59/0x60
> [  202.346261]  xfs_file_write_iter+0x90/0x130 [xfs]
> [  202.348082]  __vfs_write+0xe5/0x140
> [  202.349743]  vfs_write+0xc7/0x1f0
> [  202.351214]  ? syscall_trace_enter+0x1d0/0x380
> [  202.353155]  SyS_write+0x58/0xc0
> [  202.354628]  do_syscall_64+0x6c/0x200
> [  202.356100]  entry_SYSCALL64_slow_path+0x25/0x25
> ----------------------------------------
> 
> Do we need to allow access to memory reserves for this allocation?
> Or, should the caller check for SIGKILL rather than iterate the loop?

I think we are missing a check for fatal_signal_pending in
iomap_file_buffered_write. This means that an oom victim can consume the
full memory reserves. What do you think about the following? I haven't
tested this but it mimics generic_perform_write so I guess it should
work.
---
