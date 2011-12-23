Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id CC8B46B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 00:42:45 -0500 (EST)
Received: by vcge1 with SMTP id e1so8150729vcg.14
        for <linux-mm@kvack.org>; Thu, 22 Dec 2011 21:42:44 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 23 Dec 2011 11:12:44 +0530
Message-ID: <CAB4K4y4o82LzpwEQiemFYs390PCKUOKrg=nLro75xLGr8ak+ng@mail.gmail.com>
Subject: squashfs hangs after task is OOM killed
From: Ajeet Yadav <ajeet.yadav.77@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Phillip Lougher <phillip@squashfs.org.uk>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>

Kernel: 2.6.35.14
I am running many task in background, each task allocate 40MB of
memory, in chunk of 4096 bytes.
The program and its shared libraries are in squashfs file system.
As we run this program we expect OOM condition many times during run,
and therefore task are killed, and created.
We reach a point where in the program wished to read library from
squashfs file system, but since all system memory is exhausted
It hangs, in squashfs_cache_get() function at
wait_event(cache->wait_queue, cache->unused) indefinitely, for a task
that is oom killed.

-----------------------------------------------------------------------------------------------------------------------------------------
#!/bin/bash
while [ 1 ]
do
        idx=0
        while [ "$idx" != "250" ]
        do
                ./malloc &
                idx=$((idx+1))
        done
        sleep 60

        killall -9 malloc
done
--------------------------------------------------------------------------------------------------------------------------------------
test program (gcc main.c -o malloc)
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define NUM_PAGES 10241

#define R_DATA 0x08
#define ZW_DATA 0x04
#define UW_DATA 0x02
#define CW_DATA 0x01

int main()
{
	char *table[NUM_PAGES] = {0};
	int i, i_max;
	int fh;
	int flag = 0x0;
	ssize_t ret;
	
	fh = open("z.tgz", O_RDONLY, 0666);
	if (!fh) {
		printf("Compressed file z.tgz not present in current directory \n");
		return -1;
	}

	for (i = 0, i_max = NUM_PAGES; i < NUM_PAGES; ++i) {
		table[i] = malloc(4096);
		if (!table[i]) {
			i_max = i;
			break;
		}
		memset(table[i], 0, 4096);
	}

	while (1) {
		++flag;

		//zero data
		for(i = 0; (flag & R_DATA) && (i < i_max); ++i) {
			memcpy(table[i_max - 1 - i], table[i], 4096);
		}

		//zero data
		for(i = 0; (flag & ZW_DATA) && (i < i_max); ++i) {
			memset(table[i], 0, 4096);
		}

		//uncompressable data
		for(i = 0; (flag & UW_DATA) && (i < i_max); ++i) {
			ret = pread(fh, table[i], 4096, i * 4096);
			if (ret != 4096)
				lseek(fh, 0, SEEK_SET);
		}
		lseek(fh, 0, SEEK_SET);

		//compressable data
		for(i = 0; (flag & CW_DATA) && (i < i_max); ++i) {
			memset(table[i], 1, 4096);
		}
		sleep (1);
	}
	close(fh);
}
-------------------------------------------------------------------------------------------------------------------------
[   90.264000] Out of memory: kill process 176 (ramswap.sh) score 2389
or a child
[   90.272000] Killed process 192 (malloc) vsz:19376kB,
anon-rss:13452kB, file-rss:0kB
[   90.280000] ##### send signal from KERNEL, SIG : 9, malloc,
PID:192, force_sig_info
[   90.288000] Backtrace(CPU 1):
[   90.292000] [<c0040780>] (dump_backtrace+0x0/0x11c) from
[<c03bd17c>] (dump_stack+0x20/0x24)
[   90.300000]  r6:00000001 r5:00000009 r4:e8fb88e0 r3:00000002
[   90.304000] [<c03bd15c>] (dump_stack+0x0/0x24) from [<c0086fe8>]
(force_sig_info+0x48/0x120)
[   90.312000] [<c0086fa0>] (force_sig_info+0x0/0x120) from
[<c00870e0>] (force_sig+0x20/0x24)
[   90.320000] [<c00870c0>] (force_sig+0x0/0x24) from [<c0111978>]
(oom_kill_task+0xc4/0xe4)
[   90.328000] [<c01118b4>] (oom_kill_task+0x0/0xe4) from [<c0111b90>]
(T.357+0xa8/0xf4)
[   90.336000]  r4:e8fba380
[   90.340000] [<c0111ae8>] (T.357+0x0/0xf4) from [<c0111d44>]
(__out_of_memory+0x168/0x190)
[   90.348000]  r7:00000955 r6:e7c5a000 r5:000200da r4:00000000
[   90.352000] [<c0111bdc>] (__out_of_memory+0x0/0x190) from
[<c0111e34>] (out_of_memory+0xc8/0x124)
[   90.364000] [<c0111d6c>] (out_of_memory+0x0/0x124) from
[<c0115a80>] (__alloc_pages_nodemask+0x4a0/0x614)
[   90.372000]  r6:c0520ec0 r5:00000000 r4:000200da
[   90.376000] [<c01155e0>] (__alloc_pages_nodemask+0x0/0x614) from
[<c0128378>] (handle_mm_fault+0x2a8/0x900)
[   90.388000] [<c01280d0>] (handle_mm_fault+0x0/0x900) from
[<c03c37e8>] (do_page_fault+0x19c/0x368)
[   90.396000] [<c03c364c>] (do_page_fault+0x0/0x368) from
[<c00385ac>] (do_DataAbort+0x44/0xa8)
[   90.404000] [<c0038568>] (do_DataAbort+0x0/0xa8) from [<c03c19d0>]
(ret_from_exception+0x0/0x10)
[   90.412000] Exception stack(0xe7c5bfb0 to 0xe7c5bff8)
[   90.416000] bfa0:                                     00001009
000139b9 010e2648 00000000
[   90.424000] bfc0: 010e1640 00001008 000149c0 4016124c 00001018
010e1648 00000004 40147fb8
[   90.432000] bfe0: 00001009 bed67800 400a57a0 400a3474 60000010
ffffffff 411d9021
[   90.440000]  r7:4016124c r6:000149c0 r5:00001008 r4:ffffffff
[  240.592000] INFO: task ramswap.sh:175 blocked for more than 120 seconds.
[  240.596000] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  240.604000] ramswap.sh      [1] D [e8fbea80] c03bdca8     0   175
0x00000000     46    191     176              (user thread)
[  240.616000] Backtrace(CPU 1):
[  240.620000] [<c03bd7ac>] (schedule+0x0/0x5fc) from [<c0194db8>]
(squashfs_cache_get+0x120/0x38c)
[  240.628000] [<c0194c98>] (squashfs_cache_get+0x0/0x38c) from
[<c0195050>] (squashfs_get_datablock+0x2c/0x34)
[  240.636000] [<c0195024>] (squashfs_get_datablock+0x0/0x34) from
[<c0195f78>] (squashfs_readpage+0x5c0/0x954)
[  240.648000] [<c01959b8>] (squashfs_readpage+0x0/0x954) from
[<c0117bdc>] (__do_page_cache_readahead+0x234/0x290)
[  240.656000] [<c01179a8>] (__do_page_cache_readahead+0x0/0x290) from
[<c0117c6c>] (ra_submit+0x34/0x3c)
[  240.668000] [<c0117c38>] (ra_submit+0x0/0x3c) from [<c010f488>]
(filemap_fault+0x1ec/0x418)
[  240.676000] [<c010f29c>] (filemap_fault+0x0/0x418) from
[<c0126e58>] (__do_fault+0x60/0x490)
[  240.684000] [<c0126df8>] (__do_fault+0x0/0x490) from [<c0128524>]
(handle_mm_fault+0x454/0x900)
[  240.692000] [<c01280d0>] (handle_mm_fault+0x0/0x900) from
[<c03c37e8>] (do_page_fault+0x19c/0x368)
[  240.700000] [<c03c364c>] (do_page_fault+0x0/0x368) from
[<c0038504>] (do_PrefetchAbort+0x44/0xa8)
[  240.708000] [<c00384c0>] (do_PrefetchAbort+0x0/0xa8) from
[<c03c19d0>] (ret_from_exception+0x0/0x10)
[  240.720000] Exception stack(0xe8765fb0 to 0xe8765ff8)
[  240.724000] 5fa0:                                     000000be
be83500c 00000000 00000000
[  240.732000] 5fc0: 0017491c 00000000 be83500c 00000072 ffffffff
00000000 ffffffff 00000000
[  240.740000] 5fe0: 0016c99c be834fb8 00033b74 000b78b0 60000010
ffffffff 00000000
[  240.748000]  r7:00000072 r6:be83500c r5:00000000 r4:ffffffff
[  240.752000] -------------------------------------------------------------------------------------
[  240.760000] 1 lock held by ramswap.sh/175:
[  240.764000]  #0:  (&mm->mmap_sem){......}, at: [<c03c3748>]
do_page_fault+0xfc/0x368
[  240.772000] INFO: task malloc:191 blocked for more than 120 seconds.
[  240.780000] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  240.788000] malloc          [0] D [e871d8c0] c03bdca8     0   191
0x00000000    175            193              (user thread)
[  240.800000] Backtrace(CPU 1):
[  240.800000] [<c03bd7ac>] (schedule+0x0/0x5fc) from [<c0194db8>]
(squashfs_cache_get+0x120/0x38c)
[  240.812000] [<c0194c98>] (squashfs_cache_get+0x0/0x38c) from
[<c0195050>] (squashfs_get_datablock+0x2c/0x34)
[  240.820000] [<c0195024>] (squashfs_get_datablock+0x0/0x34) from
[<c0195f78>] (squashfs_readpage+0x5c0/0x954)
[  240.832000] [<c01959b8>] (squashfs_readpage+0x0/0x954) from
[<c0117bdc>] (__do_page_cache_readahead+0x234/0x290)
[  240.840000] [<c01179a8>] (__do_page_cache_readahead+0x0/0x290) from
[<c0117c6c>] (ra_submit+0x34/0x3c)
[  240.848000] [<c0117c38>] (ra_submit+0x0/0x3c) from [<c010f488>]
(filemap_fault+0x1ec/0x418)
[  240.856000] [<c010f29c>] (filemap_fault+0x0/0x418) from
[<c0126e58>] (__do_fault+0x60/0x490)
[  240.868000] [<c0126df8>] (__do_fault+0x0/0x490) from [<c0128524>]
(handle_mm_fault+0x454/0x900)
[  240.876000] [<c01280d0>] (handle_mm_fault+0x0/0x900) from
[<c03c37e8>] (do_page_fault+0x19c/0x368)
[  240.884000] [<c03c364c>] (do_page_fault+0x0/0x368) from
[<c0038504>] (do_PrefetchAbort+0x44/0xa8)
[  240.892000] [<c00384c0>] (do_PrefetchAbort+0x0/0xa8) from
[<c03c19d0>] (ret_from_exception+0x0/0x10)
[  240.900000] Exception stack(0xe8fc1fb0 to 0xe8fc1ff8)
[  240.908000] 1fa0:                                     00021000
40160000 00000001 400a775c
[  240.916000] 1fc0: 00e82350 00001008 00000cb0 4016124c 00001018
40148f10 00021000 40147fb8
[  240.924000] 1fe0: 00000fff be7f67f8 400a7764 400f5ebc 20000010
ffffffff 00000000
[  240.932000]  r7:4016124c r6:00000cb0 r5:00001008 r4:ffffffff
[  240.936000] -------------------------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
