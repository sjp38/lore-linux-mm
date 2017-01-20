Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE7C6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 08:27:42 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d134so97327102pfd.0
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:27:42 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t22si6856147pfl.148.2017.01.20.05.27.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 05:27:40 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170118170010.agpd4njpv5log3xe@suse.de>
	<20170118172944.GA17135@dhcp22.suse.cz>
	<20170119100755.rs6erdiz5u5by2pu@suse.de>
	<20170119112336.GN30786@dhcp22.suse.cz>
	<20170119131143.2ze5l5fwheoqdpne@suse.de>
In-Reply-To: <20170119131143.2ze5l5fwheoqdpne@suse.de>
Message-Id: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
Date: Fri, 20 Jan 2017 22:27:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Mel Gorman wrote:
> On Thu, Jan 19, 2017 at 12:23:36PM +0100, Michal Hocko wrote:
> > So what do you think about the following? Tetsuo, would you be willing
> > to run this patch through your torture testing please?
> 
> I'm fine with treating this as a starting point.

OK. So I tried to test this patch but I failed at preparation step.
There are too many pending mm patches and I'm not sure which patch on
which linux-next snapshot I should try. Also as another question,
too_many_isolated() loop exists in both mm/vmscan.c and mm/compaction.c
but why this patch does not touch the loop in mm/compaction.c part?
Is there a guarantee that the problem can be avoided by tweaking only
too_many_isolated() part?

Anyway I tried linux-next-20170119 snapshot in order to confirm that
my reproducer can still reproduce the problem before trying this patch.
But I was not able to reproduce the problem today, for mm part is
changing rapidly and existing reproducers need tuning.

And I think that there is a different problem if I tune a reproducer
like below (i.e. increased the buffer size to write()/fsync() from 4096).

----------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	static char buffer[10485760] = { }; /* or 1048576 */
	char *buf = NULL;
	unsigned long size;
	unsigned long i;
	for (i = 0; i < 1024; i++) {
		if (fork() == 0) {
			int fd = open("/proc/self/oom_score_adj", O_WRONLY);
			write(fd, "1000", 4);
			close(fd);
			sleep(1);
			snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
			fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
			while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer))
				fsync(fd);
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
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	pause();
	return 0;
}
----------

Above reproducer sometimes kills all OOM killable processes and the system
finally panics. I guess that somebody is abusing TIF_MEMDIE for needless
allocations to the level where GFP_ATOMIC allocations start failing.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170120.txt.xz .
----------
[  184.482761] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, order=0, oom_score_adj=0
(...snipped...)
[  184.482955] Node 0 active_anon:1418748kB inactive_anon:13548kB active_file:11448kB inactive_file:26044kB unevictable:0kB isolated(anon):0kB isolated(file):132kB mapped:13744kB dirty:25872kB writeback:376kB shmem:0kB shmem_thp: 0kB sh\
mem_pmdmapped: 258048kB anon_thp: 14184kB writeback_tmp:0kB unstable:0kB pages_scanned:95127 all_unreclaimable? yes
[  184.482956] Node 0 DMA free:7660kB min:380kB low:472kB high:564kB active_anon:8176kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:40\
kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  184.482959] lowmem_reserve[]: 0 1823 1823 1823
[  184.482963] Node 0 DMA32 free:44636kB min:44672kB low:55840kB high:67008kB active_anon:1410572kB inactive_anon:13548kB active_file:11448kB inactive_file:26044kB unevictable:0kB writepending:26248kB present:2080640kB managed:1866768kB\
 mlocked:0kB slab_reclaimable:85544kB slab_unreclaimable:128876kB kernel_stack:20496kB pagetables:40712kB bounce:0kB free_pcp:1136kB local_pcp:656kB free_cma:0kB
[  184.482966] lowmem_reserve[]: 0 0 0 0
[  184.482970] Node 0 DMA: 9*4kB (UE) 5*8kB (E) 2*16kB (ME) 0*32kB 2*64kB (U) 2*128kB (UE) 2*256kB (UE) 1*512kB (E) 2*1024kB (UE) 2*2048kB (ME) 0*4096kB = 7660kB
[  184.482994] Node 0 DMA32: 3845*4kB (UME) 1809*8kB (UME) 600*16kB (UME) 134*32kB (UME) 14*64kB (UME) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44636kB
(...snipped...)
[  187.477371] Node 0 active_anon:1415648kB inactive_anon:13548kB active_file:11452kB inactive_file:79120kB unevictable:0kB isolated(anon):0kB isolated(file):5220kB mapped:13748kB dirty:83484kB writeback:376kB shmem:0kB shmem_thp: 0kB s\
hmem_pmdmapped: 258048kB anon_thp: 14184kB writeback_tmp:0kB unstable:0kB pages_scanned:16058 all_unreclaimable? no
[  187.477372] Node 0 DMA free:0kB min:380kB low:472kB high:564kB active_anon:8176kB inactive_anon:0kB active_file:0kB inactive_file:6976kB unevictable:0kB writepending:7492kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable\
:172kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:64kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  187.477375] lowmem_reserve[]: 0 1823 1823 1823
[  187.477378] Node 0 DMA32 free:0kB min:44672kB low:55840kB high:67008kB active_anon:1407472kB inactive_anon:13548kB active_file:11452kB inactive_file:71928kB unevictable:0kB writepending:76368kB present:2080640kB managed:1866768kB mlo\
cked:0kB slab_reclaimable:85580kB slab_unreclaimable:128824kB kernel_stack:20496kB pagetables:39460kB bounce:0kB free_pcp:52kB local_pcp:0kB free_cma:0kB
[  187.477381] lowmem_reserve[]: 0 0 0 0
[  187.477385] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[  187.477394] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
(...snipped...)
[  318.524868] Node 0 active_anon:7064kB inactive_anon:12088kB active_file:13272kB inactive_file:1520272kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:10276kB dirty:1520264kB writeback:44kB shmem:0kB shmem_thp: 0kB sh\
mem_pmdmapped: 0kB anon_thp: 14184kB writeback_tmp:0kB unstable:0kB pages_scanned:3542854 all_unreclaimable? yes
[  318.524869] Node 0 DMA free:0kB min:380kB low:472kB high:564kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:14752kB unevictable:0kB writepending:14808kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:\
1096kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  318.524872] lowmem_reserve[]: 0 1823 1823 1823
[  318.524876] Node 0 DMA32 free:0kB min:44672kB low:55840kB high:67008kB active_anon:7064kB inactive_anon:12088kB active_file:13272kB inactive_file:1505460kB unevictable:0kB writepending:1505500kB present:2080640kB managed:1866768kB ml\
ocked:0kB slab_reclaimable:147588kB slab_unreclaimable:99652kB kernel_stack:16512kB pagetables:2016kB bounce:0kB free_pcp:788kB local_pcp:512kB free_cma:0kB
[  318.524879] lowmem_reserve[]: 0 0 0 0
[  318.524882] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[  318.524893] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[  318.524903] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  318.524904] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  318.524905] 386967 total pagecache pages
[  318.524908] 0 pages in swap cache
[  318.524909] Swap cache stats: add 0, delete 0, find 0/0
[  318.524909] Free swap  = 0kB
[  318.524910] Total swap = 0kB
[  318.524912] 524157 pages RAM
[  318.524912] 0 pages HighMem/MovableOnly
[  318.524913] 53489 pages reserved
[  318.524914] 0 pages cma reserved
[  318.524914] 0 pages hwpoisoned
[  318.524916] Kernel panic - not syncing: Out of memory and no killable processes...
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
