Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 106066B0519
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 06:46:57 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g13so12766678ioj.9
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 03:46:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l63si1248172ite.73.2017.08.01.03.46.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 03:46:52 -0700 (PDT)
Subject: Re: Possible race condition in oom-killer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170728130723.GP2274@dhcp22.suse.cz>
	<201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
	<20170728132952.GQ2274@dhcp22.suse.cz>
	<201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
	<20170728140706.GT2274@dhcp22.suse.cz>
In-Reply-To: <20170728140706.GT2274@dhcp22.suse.cz>
Message-Id: <201708011946.JFC04140.FFLFOSOMQHtOVJ@I-love.SAKURA.ne.jp>
Date: Tue, 1 Aug 2017 19:46:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> > >                                                                   Is
> > > something other than the LTP test affected to give this more priority?
> > > Do we have other usecases where something mlocks the whole memory?
> > 
> > This panic was caused by 50 threads sharing MMF_OOM_SKIP mm exceeding
> > number of OOM killable processes. Whether memory is locked or not isn't
> > important.
> 
> You are wrong here I believe. The whole problem is that the OOM victim
> is consuming basically all the memory (that is what the test case
> actually does IIRC) and that memory is mlocked. oom_reaper is much
> faster to evaluate the mm of the victim and bail out sooner than the
> exit path actually manages to tear down the address space. And so we
> have to find other oom victims until we simply kill everything and
> panic.

Again, whether memory is locked or not isn't important. I can easily
reproduce unnecessary OOM victim selection as a local unprivileged user
using below program.

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>
#include <sys/mman.h>

#define NUMTHREADS 128
#define MMAPSIZE 128 * 1048576
#define STACKSIZE 4096
static int pipe_fd[2] = { EOF, EOF };
static int memory_eater(void *unused)
{
	int fd = open("/dev/zero", O_RDONLY);
	char *buf = mmap(NULL, MMAPSIZE, PROT_WRITE | PROT_READ,
			 MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
	read(pipe_fd[0], buf, 1);
	read(fd, buf, MMAPSIZE);
	pause();
	return 0;
}
int main(int argc, char *argv[])
{
	int i;
	char *stack;
	if (fork() || fork() || setsid() == EOF || pipe(pipe_fd))
		_exit(0);
	stack = mmap(NULL, STACKSIZE * NUMTHREADS, PROT_WRITE | PROT_READ,
		     MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
	for (i = 0; i < NUMTHREADS; i++)
                if (clone(memory_eater, stack + (i + 1) * STACKSIZE,
			  CLONE_THREAD | CLONE_SIGHAND | CLONE_VM | CLONE_FS |
			  CLONE_FILES, NULL) == -1)
                        break;
	sleep(1);
	close(pipe_fd[1]);
	pause();
	return 0;
}
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170801-2.txt.xz :
----------
[  237.792768] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  237.795575] [  451]     0   451     9206      639      21       3        0             0 systemd-journal
[  237.798515] [  478]     0   478    11138      740      25       3        0         -1000 systemd-udevd
[  237.801430] [  488]     0   488    13856      100      26       3        0         -1000 auditd
[  237.804212] [  592]    81   592     6135      119      18       3        0          -900 dbus-daemon
[  237.807166] [  668]     0   668     1094       23       8       3        0             0 rngd
[  237.809927] [  671]    70   671     7029       75      19       4        0             0 avahi-daemon
[  237.812809] [  672]     0   672    53144      402      57       4        0             0 abrtd
[  237.815611] [  675]     0   675    26372      246      54       3        0         -1000 sshd
[  237.818358] [  679]     0   679    52573      341      54       3        0             0 abrt-watch-log
[  237.821274] [  680]     0   680     6050       79      17       3        0             0 systemd-logind
[  237.824279] [  683]     0   683     4831       82      16       3        0             0 irqbalance
[  237.827119] [  698]     0   698    56014      630      40       4        0             0 rsyslogd
[  237.829929] [  715]    70   715     6997       59      18       4        0             0 avahi-daemon
[  237.832799] [  832]     0   832    65453      228      44       3        0             0 vmtoolsd
[  237.835605] [  852]     0   852    57168      353      58       3        0             0 vmtoolsd
[  237.838409] [  909]     0   909    31558      155      20       3        0             0 crond
[  237.841160] [  986]     0   986    84330      393     114       4        0             0 nmbd
[  237.843878] [ 1041]     0  1041    23728      168      51       3        0             0 login
[  237.846623] [ 2019]     0  2019    22261      252      43       3        0             0 master
[  237.849307] [ 2034]     0  2034    27511       33      13       3        0             0 agetty
[  237.851977] [ 2100]    89  2100    22287      250      45       3        0             0 pickup
[  237.854607] [ 2101]    89  2101    22304      251      45       3        0             0 qmgr
[  237.857179] [ 2597]     0  2597   102073      568     150       3        0             0 smbd
[  237.859773] [ 3905]  1000  3905    28885      133      15       4        0             0 bash
[  237.862337] [ 3952]     0  3952    27511       32      10       3        0             0 agetty
[  237.864905] [ 4772]     0  4772   102073      568     140       3        0             0 cleanupd
[  237.867488] [ 4775]  1000  4775  4195473   860912    1814      19        0             0 a.out
[  237.869991] Out of memory: Kill process 4775 (a.out) score 924 or sacrifice child
[  240.940617] Killed process 4775 (a.out) total-vm:16781892kB, anon-rss:88kB, file-rss:0kB, shmem-rss:3443560kB
[  240.962810] oom_reaper: reaped process 4775 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.965513] oom_reaper: reaped process 4863 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.968192] oom_reaper: reaped process 4896 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.970789] oom_reaper: reaped process 4851 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.973352] oom_reaper: reaped process 4788 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.978376] oom_reaper: reaped process 4781 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.981007] oom_reaper: reaped process 4780 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.983527] oom_reaper: reaped process 4903 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.986038] oom_reaper: reaped process 4891 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.988697] oom_reaper: reaped process 4809 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  240.999681] oom_reaper: reaped process 4806 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  241.002165] oom_reaper: reaped process 4783 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  241.004591] oom_reaper: reaped process 4816 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  241.007022] oom_reaper: reaped process 4873 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3445880kB
[  241.009522] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null),  order=0, oom_score_adj=0
[  241.157201] a.out cpuset=/ mems_allowed=0
[  241.158983] CPU: 1 PID: 4805 Comm: a.out Not tainted 4.13.0-rc2-next-20170728 #649
(...snipped...)
[  357.797379] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  357.800119] [  478]     0   478    11138      740      25       3        0         -1000 systemd-udevd
[  357.803005] [  488]     0   488    13856      110      26       3        0         -1000 auditd
[  357.805800] [  592]    81   592     6135      119      18       3        0          -900 dbus-daemon
[  357.808710] [  668]     0   668     1094       23       8       3        0             0 rngd
[  357.811437] [  671]    70   671     7029       75      19       4        0             0 avahi-daemon
[  357.814308] [  675]     0   675    26372      246      54       3        0         -1000 sshd
[  357.817048] [  679]     0   679    52573      341      54       3        0             0 abrt-watch-log
[  357.819969] [  680]     0   680     6050       79      17       3        0             0 systemd-logind
[  357.822863] [  683]     0   683     4831       82      16       3        0             0 irqbalance
[  357.825699] [  715]    70   715     6997       59      18       4        0             0 avahi-daemon
[  357.828567] [  832]     0   832    65453      228      44       3        0             0 vmtoolsd
[  357.831373] [  909]     0   909    31558      155      20       3        0             0 crond
[  357.834160] [ 1041]     0  1041    23728      168      51       3        0             0 login
[  357.836882] [ 2019]     0  2019    22261      258      43       3        0             0 master
[  357.839597] [ 2034]     0  2034    27511       33      13       3        0             0 agetty
[  357.842472] [ 2100]    89  2100    22287      250      45       3        0             0 pickup
[  357.845358] [ 2101]    89  2101    22304      250      45       3        0             0 qmgr
[  357.848247] [ 3905]  1000  3905    28885      134      15       4        0             0 bash
[  357.851074] [ 3952]     0  3952    27511       32      10       3        0             0 agetty
[  357.853790] [ 5040]     0  5040     9207      365      20       3        0             0 systemd-journal
[  357.856619] [ 5459]     0  5459    58062      437      42       3        0             0 rsyslogd
[  357.859296] [ 5465]  1000  5465  4195473   862629    1767      19        0             0 a.out
[  357.861907] Out of memory: Kill process 5465 (a.out) score 926 or sacrifice child
[  358.789961] Killed process 5465 (a.out) total-vm:16781892kB, anon-rss:88kB, file-rss:0kB, shmem-rss:3450428kB
[  358.903547] oom_reaper: reaped process 5465 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.906409] oom_reaper: reaped process 5556 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.909182] oom_reaper: reaped process 5579 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.911930] oom_reaper: reaped process 5500 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.914625] oom_reaper: reaped process 5514 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.917425] oom_reaper: reaped process 5569 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.923629] oom_reaper: reaped process 5533 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.926289] oom_reaper: reaped process 5501 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.928867] oom_reaper: reaped process 5534 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
[  358.935580] oom_reaper: reaped process 5505 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3451792kB
(...snipped...)
[  359.863069] Out of memory: Kill process 5459 (rsyslogd) score 0 or sacrifice child
[  359.868030] Killed process 5459 (rsyslogd) total-vm:232248kB, anon-rss:648kB, file-rss:4kB, shmem-rss:1096kB
(...snipped...)
[  364.311536] Out of memory: Kill process 679 (abrt-watch-log) score 0 or sacrifice child
[  364.317978] Killed process 679 (abrt-watch-log) total-vm:210292kB, anon-rss:1360kB, file-rss:4kB, shmem-rss:0kB
(...snipped...)
[  364.490986] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  364.493818] [  478]     0   478    11138      740      25       3        0         -1000 systemd-udevd
[  364.496727] [  488]     0   488    13856      110      26       3        0         -1000 auditd
[  364.499669] [  592]    81   592     6135      119      18       3        0          -900 dbus-daemon
[  364.502571] [  668]     0   668     1094       23       8       3        0             0 rngd
[  364.505303] [  671]    70   671     7029       75      19       4        0             0 avahi-daemon
[  364.508067] [  675]     0   675    26372      246      54       3        0         -1000 sshd
[  364.510723] [  680]     0   680     6050       79      17       3        0             0 systemd-logind
[  364.513735] [  683]     0   683     4831       81      16       3        0             0 irqbalance
[  364.516457] [  715]    70   715     6997       59      18       4        0             0 avahi-daemon
[  364.519210] [  832]     0   832    65453      228      44       3        0             0 vmtoolsd
[  364.521919] [  909]     0   909    31558      155      20       3        0             0 crond
[  364.524817] [ 1041]     0  1041    23728      168      51       3        0             0 login
[  364.527471] [ 2019]     0  2019    22261      258      43       3        0             0 master
[  364.530118] [ 2034]     0  2034    27511       33      13       3        0             0 agetty
[  364.532933] [ 2100]    89  2100    22287      250      45       3        0             0 pickup
[  364.535522] [ 2101]    89  2101    22304      250      45       3        0             0 qmgr
[  364.538160] [ 3905]  1000  3905    28885      134      15       4        0             0 bash
[  364.540763] [ 3952]     0  3952    27511       32      10       3        0             0 agetty
[  364.543292] [ 5040]     0  5040     9207      364      20       3        0             0 systemd-journal
[  364.546028] [ 5484]  1000  5465  4195473   867043    1767      19        0             0 a.out
[  364.548515] Out of memory: Kill process 5040 (systemd-journal) score 0 or sacrifice child
[  364.551666] Killed process 5040 (systemd-journal) total-vm:36828kB, anon-rss:260kB, file-rss:0kB, shmem-rss:1196kB
----------

Usually OOM killable tasks up to number of available CPUs are killed by one OOM killer
invocation, but similar reproducer (CLONE_THREAD | CLONE_SIGHAND removed from above one)
had killed all OOM killable tasks and panic()ed (so far only once).
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170801.txt.xz :
----------
[ 1301.010587] Mem-Info:
[ 1301.021217] active_anon:3744 inactive_anon:872936 isolated_anon:0
[ 1301.021217]  active_file:59 inactive_file:22 isolated_file:37
[ 1301.021217]  unevictable:0 dirty:16 writeback:1 unstable:0
[ 1301.021217]  slab_reclaimable:0 slab_unreclaimable:17
[ 1301.021217]  mapped:853542 shmem:874817 pagetables:2039 bounce:0
[ 1301.021217]  free:21371 free_pcp:93 free_cma:0
[ 1301.030807] Node 0 active_anon:14976kB inactive_anon:3491956kB active_file:104kB inactive_file:100kB unevictable:0kB isolated(anon):0kB isolated(file):92kB mapped:3414188kB dirty:60kB writeback:4kB shmem:3499480kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1301.038255] Node 0 DMA free:14756kB min:288kB low:360kB high:432kB active_anon:0kB inactive_anon:1108kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1301.044649] lowmem_reserve[]: 0 2688 3624 3624
[ 1301.046306] Node 0 DMA32 free:53376kB min:49908kB low:62384kB high:74860kB active_anon:16kB inactive_anon:2682284kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:5328kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1301.053203] lowmem_reserve[]: 0 0 936 936
[ 1301.054748] Node 0 Normal free:16756kB min:17384kB low:21728kB high:26072kB active_anon:14960kB inactive_anon:808292kB active_file:20kB inactive_file:16kB unevictable:0kB writepending:64kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:4800kB pagetables:2836kB bounce:0kB free_pcp:392kB local_pcp:288kB free_cma:0kB
[ 1301.062749] lowmem_reserve[]: 0 0 0 0
[ 1301.065274] Node 0 DMA: 2*4kB (UM) 1*8kB (U) 1*16kB (U) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14752kB
[ 1301.070034] Node 0 DMA32: 9*4kB (UM) 7*8kB (UM) 7*16kB (UME) 6*32kB (UME) 4*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 1*1024kB (U) 1*2048kB (E) 12*4096kB (UM) = 53516kB
[ 1301.074902] Node 0 Normal: 85*4kB (UMEH) 56*8kB (UMEH) 38*16kB (UMEH) 14*32kB (UMEH) 9*64kB (UEH) 12*128kB (UMEH) 26*256kB (UMEH) 10*512kB (UME) 1*1024kB (H) 0*2048kB 0*4096kB = 16756kB
[ 1301.080143] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1301.082796] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1301.085387] 874919 total pagecache pages
[ 1301.086962] 0 pages in swap cache
[ 1301.088505] Swap cache stats: add 0, delete 0, find 0/0
[ 1301.090370] Free swap  = 0kB
[ 1301.091743] Total swap = 0kB
[ 1301.093140] 1048445 pages RAM
[ 1301.094677] 0 pages HighMem/MovableOnly
[ 1301.096600] 116531 pages reserved
[ 1301.098143] 0 pages hwpoisoned
[ 1301.099690] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 1301.103027] [  476]     0   476    10952      553      24       3        0         -1000 systemd-udevd
[ 1301.106142] [  486]     0   486    13856      110      26       3        0         -1000 auditd
[ 1301.108737] [  660]     0   660    26372      247      55       3        0         -1000 sshd
[ 1301.111466] [ 6535]     0  6535     9207      423      21       3        0             0 systemd-journal
[ 1301.114370] [ 6536]     0  6536     6050       78      16       3        0             0 systemd-logind
[ 1301.117136] [ 6537]     0  6537    27511       32      13       3        0             0 agetty
[ 1301.119727] [ 6538]    81  6538     6103       78      17       3        0          -900 dbus-daemon
[ 1301.122372] [ 6699]     0  6699    76537     1249      50       3        0             0 rsyslogd
[ 1301.125020] [ 6731]  1000  6731  4195473   848108    1790      19        0             0 a.out
[ 1301.127633] [ 6732]  1000  6732  4195473   848108    1790      19        0             0 a.out
[ 1301.130415] [ 6733]  1000  6733  4195473   848108    1790      19        0             0 a.out
(...snipped...)
[ 1301.386215] [ 6859]  1000  6859  4195473   848108    1790      19        0             0 a.out
[ 1301.388102] [ 6862]     0  6862    27511       32      10       3        0             0 agetty
[ 1301.390015] Out of memory: Kill process 6731 (a.out) score 910 or sacrifice child
[ 1301.392740] Killed process 6731 (a.out) total-vm:16781892kB, anon-rss:84kB, file-rss:0kB, shmem-rss:3392348kB
[ 1301.395605] oom_reaper: reaped process 6731 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3392400kB
[ 1301.397946] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null),  order=0, oom_score_adj=0
[ 1301.400456] a.out cpuset=/ mems_allowed=0
[ 1301.401574] CPU: 2 PID: 6855 Comm: a.out Not tainted 4.13.0-rc2-next-20170728 #649
[ 1301.403392] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1301.407439] Call Trace:
[ 1301.408321]  dump_stack+0x67/0x9e
[ 1301.409352]  dump_header+0x9d/0x3fa
[ 1301.410411]  ? trace_hardirqs_on+0xd/0x10
[ 1301.411589]  oom_kill_process+0x226/0x650
[ 1301.412776]  out_of_memory+0x136/0x560
[ 1301.413898]  ? out_of_memory+0x206/0x560
[ 1301.415062]  __alloc_pages_nodemask+0xdce/0xeb0
[ 1301.416373]  alloc_pages_vma+0x76/0x1a0
[ 1301.417531]  shmem_alloc_page+0x6e/0xa0
[ 1301.418700]  ? native_sched_clock+0x36/0xa0
[ 1301.419944]  shmem_alloc_and_acct_page+0x6d/0x1f0
[ 1301.421299]  shmem_getpage_gfp+0x1b6/0xde0
[ 1301.422536]  ? current_kernel_time64+0x80/0xa0
[ 1301.423844]  shmem_fault+0x91/0x1f0
[ 1301.424969]  ? __lock_acquire+0x506/0x1a90
[ 1301.426227]  __do_fault+0x19/0x120
[ 1301.427341]  __handle_mm_fault+0x873/0x1160
[ 1301.428639]  ? native_sched_clock+0x36/0xa0
[ 1301.429964]  handle_mm_fault+0x186/0x360
[ 1301.431223]  ? handle_mm_fault+0x44/0x360
[ 1301.432487]  __do_page_fault+0x1da/0x510
[ 1301.433730]  ? __lock_acquire+0x506/0x1a90
[ 1301.435032]  do_page_fault+0x21/0x70
[ 1301.436223]  page_fault+0x22/0x30
[ 1301.437366] RIP: 0010:__clear_user+0x3d/0x70
[ 1301.438696] RSP: 0000:ffff8801395ffd70 EFLAGS: 00010206
[ 1301.441909] RAX: 0000000000000000 RBX: 0000000000000200 RCX: 0000000000000200
[ 1301.443823] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f9bda247000
[ 1301.445863] RBP: ffff8801395ffd80 R08: 0000000000000001 R09: 0000000000000000
[ 1301.447812] R10: 0000000000000001 R11: 0000000000000001 R12: 00007f9bda247000
[ 1301.449757] R13: ffff8801395ffe30 R14: 0000000001992000 R15: 0000000000001000
[ 1301.451723]  clear_user+0x34/0x50
[ 1301.452935]  iov_iter_zero+0x88/0x380
[ 1301.454219]  read_iter_zero+0x38/0xb0
[ 1301.455511]  __vfs_read+0xe3/0x140
[ 1301.456752]  vfs_read+0x9c/0x150
[ 1301.457958]  SyS_read+0x53/0xc0
[ 1301.459151]  do_syscall_64+0x61/0x1d0
[ 1301.460451]  entry_SYSCALL64_slow_path+0x25/0x25
[ 1301.461940] RIP: 0033:0x7f9ec099dc30
[ 1301.463225] RSP: 002b:00007f9ec0e81fd8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[ 1301.465286] RAX: ffffffffffffffda RBX: 00007f9bd88b5000 RCX: 00007f9ec099dc30
[ 1301.467242] RDX: 0000000008000000 RSI: 00007f9bd88b5000 RDI: 0000000000000061
[ 1301.469187] RBP: 0000000000000061 R08: ffffffffffffffff R09: 0000000000000000
[ 1301.471111] R10: 0000000000000021 R11: 0000000000000246 R12: 00000000004007d7
[ 1301.473044] R13: 00007ffeb6830c90 R14: 0000000000000000 R15: 0000000000000000
[ 1301.475012] Mem-Info:
[ 1302.770130] active_anon:3723 inactive_anon:873018 isolated_anon:0
[ 1302.770130]  active_file:3 inactive_file:0 isolated_file:0
[ 1302.770130]  unevictable:0 dirty:1 writeback:1 unstable:0
[ 1302.770130]  slab_reclaimable:0 slab_unreclaimable:2
[ 1302.770130]  mapped:853537 shmem:874899 pagetables:2050 bounce:0
[ 1302.770130]  free:21373 free_pcp:35 free_cma:0
[ 1302.787545] Node 0 active_anon:14892kB inactive_anon:3492072kB active_file:8kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3414148kB dirty:4kB writeback:4kB shmem:3499596kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[ 1302.794036] Node 0 DMA free:14752kB min:288kB low:360kB high:432kB active_anon:0kB inactive_anon:1116kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1302.803259] lowmem_reserve[]: 0 2688 3624 3624
[ 1302.804839] Node 0 DMA32 free:53516kB min:49908kB low:62384kB high:74860kB active_anon:16kB inactive_anon:2682496kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:5352kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1302.817760] lowmem_reserve[]: 0 0 936 936
[ 1302.819371] Node 0 Normal free:17224kB min:17384kB low:21728kB high:26072kB active_anon:14876kB inactive_anon:808460kB active_file:108kB inactive_file:0kB unevictable:0kB writepending:8kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:4784kB pagetables:2844kB bounce:0kB free_pcp:140kB local_pcp:4kB free_cma:0kB
[ 1302.829597] lowmem_reserve[]: 0 0 0 0
[ 1302.831194] Node 0 DMA: 2*4kB (UM) 1*8kB (U) 1*16kB (U) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14752kB
[ 1302.835771] Node 0 DMA32: 9*4kB (UM) 7*8kB (UM) 7*16kB (UME) 6*32kB (UME) 4*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 1*1024kB (U) 1*2048kB (E) 12*4096kB (UM) = 53516kB
[ 1302.842805] Node 0 Normal: 138*4kB (UMEH) 62*8kB (UMEH) 49*16kB (UMEH) 15*32kB (UMEH) 9*64kB (UEH) 12*128kB (UMEH) 26*256kB (UMEH) 10*512kB (UME) 1*1024kB (H) 0*2048kB 0*4096kB = 17224kB
[ 1302.850292] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1302.853053] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1302.860191] 874902 total pagecache pages
[ 1302.862020] 0 pages in swap cache
[ 1302.863688] Swap cache stats: add 0, delete 0, find 0/0
[ 1302.865828] Free swap  = 0kB
[ 1302.867400] Total swap = 0kB
[ 1302.868968] 1048445 pages RAM
[ 1303.699719] 0 pages HighMem/MovableOnly
[ 1303.701531] 116531 pages reserved
[ 1303.703194] 0 pages hwpoisoned
[ 1303.704793] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 1303.707509] [  476]     0   476    10952      553      24       3        0         -1000 systemd-udevd
[ 1303.710392] [  486]     0   486    13856      110      26       3        0         -1000 auditd
[ 1303.713153] [  660]     0   660    26372      247      55       3        0         -1000 sshd
[ 1303.715875] [ 6535]     0  6535     9207      423      21       3        0             0 systemd-journal
[ 1303.719739] [ 6536]     0  6536     6050       78      16       3        0             0 systemd-logind
[ 1303.722604] [ 6537]     0  6537    27511       32      13       3        0             0 agetty
[ 1303.725318] [ 6538]    81  6538     6103       78      17       3        0          -900 dbus-daemon
[ 1303.728122] [ 6699]     0  6699    76537     1231      50       3        0             0 rsyslogd
[ 1303.730883] [ 6732]  1000  6732  4195473   848100    1790      19        0             0 a.out
[ 1303.733591] [ 6733]  1000  6733  4195473   848100    1790      19        0             0 a.out
[ 1303.736272] [ 6734]  1000  6734  4195473   848100    1790      19        0             0 a.out
(...snipped...)
[ 1303.996897] [ 6859]  1000  6859  4195473   848100    1790      19        0             0 a.out
[ 1303.998810] [ 6862]     0  6862    27511       32      10       3        0             0 agetty
[ 1304.000763] Out of memory: Kill process 6699 (rsyslogd) score 1 or sacrifice child
...(noisy "page allocation stalls" lines snipped)...
[ 1378.224508] kworker/u16:2 invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=2, oom_score_adj=0
[ 1378.224513] kworker/u16:2 cpuset=/ mems_allowed=0
[ 1378.224520] CPU: 3 PID: 6523 Comm: kworker/u16:2 Not tainted 4.13.0-rc2-next-20170728 #649
[ 1378.224521] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1378.224527] Workqueue: events_unbound call_usermodehelper_exec_work
[ 1378.224528] Call Trace:
[ 1378.224535]  dump_stack+0x67/0x9e
[ 1378.224539]  dump_header+0x9d/0x3fa
[ 1378.224545]  ? trace_hardirqs_on+0xd/0x10
[ 1378.224552]  oom_kill_process+0x226/0x650
[ 1378.224558]  out_of_memory+0x136/0x560
[ 1378.224560]  ? out_of_memory+0x206/0x560
[ 1378.224565]  __alloc_pages_nodemask+0xdce/0xeb0
[ 1378.224568]  ? copy_process.part.39+0x7eb/0x1e30
[ 1378.224585]  copy_process.part.39+0x13f/0x1e30
[ 1378.224587]  ? __lock_acquire+0x506/0x1a90
[ 1378.224590]  ? load_balance+0x1b0/0xaf0
[ 1378.224598]  ? umh_complete+0x30/0x30
[ 1378.224604]  _do_fork+0xea/0x5f0
[ 1378.224610]  ? native_sched_clock+0x36/0xa0
[ 1378.224619]  kernel_thread+0x24/0x30
[ 1378.224622]  call_usermodehelper_exec_work+0x35/0xc0
[ 1378.224625]  process_one_work+0x1d0/0x3e0
[ 1378.224626]  ? process_one_work+0x16a/0x3e0
[ 1378.224634]  worker_thread+0x48/0x3c0
[ 1378.224642]  kthread+0x10d/0x140
[ 1378.224643]  ? process_one_work+0x3e0/0x3e0
[ 1378.224646]  ? kthread_create_on_node+0x60/0x60
[ 1378.224651]  ret_from_fork+0x27/0x40
[ 1378.224662] Mem-Info:
[ 1378.224666] active_anon:3649 inactive_anon:873071 isolated_anon:0
[ 1378.224666]  active_file:34 inactive_file:373 isolated_file:0
[ 1378.224666]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1378.224666]  slab_reclaimable:0 slab_unreclaimable:0
[ 1378.224666]  mapped:852813 shmem:875026 pagetables:2050 bounce:0
[ 1378.224666]  free:21442 free_pcp:86 free_cma:0
[ 1378.224668] Node 0 active_anon:14596kB inactive_anon:3492284kB active_file:136kB inactive_file:1492kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3411252kB dirty:0kB writeback:0kB shmem:3500104kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1378.224669] Node 0 DMA free:14752kB min:288kB low:360kB high:432kB active_anon:0kB inactive_anon:1116kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.224672] lowmem_reserve[]: 0 2688 3624 3624
[ 1378.224677] Node 0 DMA32 free:53516kB min:49908kB low:62384kB high:74860kB active_anon:16kB inactive_anon:2682496kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:5352kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.224680] lowmem_reserve[]: 0 0 936 936
[ 1378.224684] Node 0 Normal free:17500kB min:17384kB low:21728kB high:26072kB active_anon:14776kB inactive_anon:808668kB active_file:0kB inactive_file:1940kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:2736kB pagetables:2844kB bounce:0kB free_pcp:344kB local_pcp:224kB free_cma:0kB
[ 1378.224687] lowmem_reserve[]: 0 0 0 0
[ 1378.224691] Node 0 DMA: 2*4kB (UM) 1*8kB (U) 1*16kB (U) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14752kB
[ 1378.224756] Node 0 DMA32: 9*4kB (UM) 7*8kB (UM) 7*16kB (UME) 6*32kB (UME) 4*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 1*1024kB (U) 1*2048kB (E) 12*4096kB (UM) = 53516kB
[ 1378.224783] Node 0 Normal: 107*4kB (UEH) 68*8kB (UEH) 50*16kB (UMEH) 61*32kB (UEH) 15*64kB (UEH) 12*128kB (UMEH) 19*256kB (UMEH) 10*512kB (UME) 1*1024kB (H) 0*2048kB 0*4096kB = 17228kB
[ 1378.224802] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1378.224803] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1378.224804] 875607 total pagecache pages
[ 1378.224807] 0 pages in swap cache
[ 1378.224808] Swap cache stats: add 0, delete 0, find 0/0
[ 1378.224809] Free swap  = 0kB
[ 1378.224809] Total swap = 0kB
[ 1378.224811] 1048445 pages RAM
[ 1378.224812] 0 pages HighMem/MovableOnly
[ 1378.224813] 116531 pages reserved
[ 1378.224814] 0 pages hwpoisoned
[ 1378.224814] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 1378.224824] [  476]     0   476    10952      553      24       3        0         -1000 systemd-udevd
[ 1378.224827] [  486]     0   486    13856      110      26       3        0         -1000 auditd
[ 1378.224830] [  660]     0   660    26372      247      55       3        0         -1000 sshd
[ 1378.224833] [ 6535]     0  6535     9207      422      21       3        0             0 systemd-journal
[ 1378.224836] [ 6536]     0  6536     6050       78      16       3        0             0 systemd-logind
[ 1378.224839] [ 6537]     0  6537    27511       32      13       3        0             0 agetty
[ 1378.224841] [ 6538]    81  6538     6103       78      17       3        0          -900 dbus-daemon
[ 1378.224930] [ 6855]  1000  6855  4195473   852376    1790      19        0             0 a.out
[ 1378.224935] [ 6862]     0  6862    27511       32      10       3        0             0 agetty
[ 1378.224937] Out of memory: Kill process 6535 (systemd-journal) score 0 or sacrifice child
[ 1378.225006] Killed process 6535 (systemd-journal) total-vm:36828kB, anon-rss:260kB, file-rss:0kB, shmem-rss:1428kB
[ 1378.232809] kworker/u16:2 invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=2, oom_score_adj=0
[ 1378.232814] kworker/u16:2 cpuset=/ mems_allowed=0
[ 1378.232821] CPU: 3 PID: 6523 Comm: kworker/u16:2 Not tainted 4.13.0-rc2-next-20170728 #649
[ 1378.232822] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1378.232827] Workqueue: events_unbound call_usermodehelper_exec_work
[ 1378.232829] Call Trace:
[ 1378.232835]  dump_stack+0x67/0x9e
[ 1378.232839]  dump_header+0x9d/0x3fa
[ 1378.232845]  ? trace_hardirqs_on+0xd/0x10
[ 1378.232852]  oom_kill_process+0x226/0x650
[ 1378.232859]  out_of_memory+0x136/0x560
[ 1378.232860]  ? out_of_memory+0x206/0x560
[ 1378.232866]  __alloc_pages_nodemask+0xdce/0xeb0
[ 1378.232869]  ? copy_process.part.39+0x7eb/0x1e30
[ 1378.232885]  copy_process.part.39+0x13f/0x1e30
[ 1378.232888]  ? __lock_acquire+0x506/0x1a90
[ 1378.232890]  ? load_balance+0x1b0/0xaf0
[ 1378.232898]  ? umh_complete+0x30/0x30
[ 1378.232904]  _do_fork+0xea/0x5f0
[ 1378.232910]  ? native_sched_clock+0x36/0xa0
[ 1378.232919]  kernel_thread+0x24/0x30
[ 1378.232922]  call_usermodehelper_exec_work+0x35/0xc0
[ 1378.232925]  process_one_work+0x1d0/0x3e0
[ 1378.232926]  ? process_one_work+0x16a/0x3e0
[ 1378.232934]  worker_thread+0x48/0x3c0
[ 1378.232943]  kthread+0x10d/0x140
[ 1378.232944]  ? process_one_work+0x3e0/0x3e0
[ 1378.232946]  ? kthread_create_on_node+0x60/0x60
[ 1378.232951]  ret_from_fork+0x27/0x40
[ 1378.232962] Mem-Info:
[ 1378.232965] active_anon:3723 inactive_anon:872923 isolated_anon:0
[ 1378.232965]  active_file:34 inactive_file:262 isolated_file:0
[ 1378.232965]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1378.232965]  slab_reclaimable:0 slab_unreclaimable:0
[ 1378.232965]  mapped:852480 shmem:875026 pagetables:2050 bounce:0
[ 1378.232965]  free:21442 free_pcp:442 free_cma:0
[ 1378.232968] Node 0 active_anon:14892kB inactive_anon:3491692kB active_file:136kB inactive_file:1048kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3409920kB dirty:0kB writeback:0kB shmem:3500104kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1378.232969] Node 0 DMA free:14752kB min:288kB low:360kB high:432kB active_anon:0kB inactive_anon:1116kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.232972] lowmem_reserve[]: 0 2688 3624 3624
[ 1378.232977] Node 0 DMA32 free:53516kB min:49908kB low:62384kB high:74860kB active_anon:16kB inactive_anon:2682496kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:5352kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.232980] lowmem_reserve[]: 0 0 936 936
[ 1378.232984] Node 0 Normal free:17500kB min:17384kB low:21728kB high:26072kB active_anon:14776kB inactive_anon:808164kB active_file:0kB inactive_file:1436kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:2736kB pagetables:2844kB bounce:0kB free_pcp:1768kB local_pcp:676kB free_cma:0kB
[ 1378.232987] lowmem_reserve[]: 0 0 0 0
[ 1378.232991] Node 0 DMA: 2*4kB (UM) 1*8kB (U) 1*16kB (U) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14752kB
[ 1378.233010] Node 0 DMA32: 9*4kB (UM) 7*8kB (UM) 7*16kB (UME) 6*32kB (UME) 4*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 1*1024kB (U) 1*2048kB (E) 12*4096kB (UM) = 53516kB
[ 1378.233028] Node 0 Normal: 76*4kB (UEH) 68*8kB (UEH) 53*16kB (UMEH) 61*32kB (UEH) 15*64kB (UEH) 12*128kB (UMEH) 19*256kB (UMEH) 10*512kB (UME) 1*1024kB (H) 0*2048kB 0*4096kB = 17152kB
[ 1378.233047] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1378.233048] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1378.233049] 875385 total pagecache pages
[ 1378.233052] 0 pages in swap cache
[ 1378.233053] Swap cache stats: add 0, delete 0, find 0/0
[ 1378.233054] Free swap  = 0kB
[ 1378.233055] Total swap = 0kB
[ 1378.233056] 1048445 pages RAM
[ 1378.233057] 0 pages HighMem/MovableOnly
[ 1378.233058] 116531 pages reserved
[ 1378.233058] 0 pages hwpoisoned
[ 1378.233059] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 1378.233068] [  476]     0   476    10952      553      24       3        0         -1000 systemd-udevd
[ 1378.233072] [  486]     0   486    13856      110      26       3        0         -1000 auditd
[ 1378.233075] [  660]     0   660    26372      247      55       3        0         -1000 sshd
[ 1378.233079] [ 6536]     0  6536     6050       78      16       3        0             0 systemd-logind
[ 1378.233082] [ 6537]     0  6537    27511       32      13       3        0             0 agetty
[ 1378.233085] [ 6538]    81  6538     6103       78      17       3        0          -900 dbus-daemon
[ 1378.233172] [ 6855]  1000  6855  4195473   852376    1790      19        0             0 a.out
[ 1378.233177] [ 6862]     0  6862    27511       32      10       3        0             0 agetty
[ 1378.233179] Out of memory: Kill process 6536 (systemd-logind) score 0 or sacrifice child
[ 1378.233276] Killed process 6536 (systemd-logind) total-vm:24200kB, anon-rss:308kB, file-rss:4kB, shmem-rss:0kB
[ 1378.236782] kworker/u16:1 invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=2, oom_score_adj=0
[ 1378.236786] kworker/u16:1 cpuset=/ mems_allowed=0
[ 1378.236792] CPU: 0 PID: 6520 Comm: kworker/u16:1 Not tainted 4.13.0-rc2-next-20170728 #649
[ 1378.236793] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1378.236797] Workqueue: events_unbound call_usermodehelper_exec_work
[ 1378.236798] Call Trace:
[ 1378.236803]  dump_stack+0x67/0x9e
[ 1378.236807]  dump_header+0x9d/0x3fa
[ 1378.236812]  ? trace_hardirqs_on+0xd/0x10
[ 1378.236819]  oom_kill_process+0x226/0x650
[ 1378.236825]  out_of_memory+0x136/0x560
[ 1378.236827]  ? out_of_memory+0x206/0x560
[ 1378.236832]  __alloc_pages_nodemask+0xdce/0xeb0
[ 1378.236834]  ? copy_process.part.39+0x7eb/0x1e30
[ 1378.236851]  copy_process.part.39+0x13f/0x1e30
[ 1378.236853]  ? __lock_acquire+0x506/0x1a90
[ 1378.236861]  ? umh_complete+0x30/0x30
[ 1378.236868]  _do_fork+0xea/0x5f0
[ 1378.236873]  ? native_sched_clock+0x36/0xa0
[ 1378.236882]  kernel_thread+0x24/0x30
[ 1378.236885]  call_usermodehelper_exec_work+0x35/0xc0
[ 1378.236888]  process_one_work+0x1d0/0x3e0
[ 1378.236889]  ? process_one_work+0x16a/0x3e0
[ 1378.236897]  worker_thread+0x48/0x3c0
[ 1378.236905]  kthread+0x10d/0x140
[ 1378.236906]  ? process_one_work+0x3e0/0x3e0
[ 1378.236909]  ? kthread_create_on_node+0x60/0x60
[ 1378.236913]  ret_from_fork+0x27/0x40
[ 1378.236924] Mem-Info:
[ 1378.236927] active_anon:3649 inactive_anon:872923 isolated_anon:0
[ 1378.236927]  active_file:34 inactive_file:55 isolated_file:0
[ 1378.236927]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1378.236927]  slab_reclaimable:0 slab_unreclaimable:0
[ 1378.236927]  mapped:852480 shmem:875026 pagetables:2050 bounce:0
[ 1378.236927]  free:21694 free_pcp:471 free_cma:0
[ 1378.236929] Node 0 active_anon:14596kB inactive_anon:3491692kB active_file:136kB inactive_file:220kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3409920kB dirty:0kB writeback:0kB shmem:3500104kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1378.236930] Node 0 DMA free:14752kB min:288kB low:360kB high:432kB active_anon:0kB inactive_anon:1116kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.236933] lowmem_reserve[]: 0 2688 3624 3624
[ 1378.236938] Node 0 DMA32 free:53516kB min:49908kB low:62384kB high:74860kB active_anon:16kB inactive_anon:2682496kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:5352kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.236941] lowmem_reserve[]: 0 0 936 936
[ 1378.236945] Node 0 Normal free:18508kB min:17384kB low:21728kB high:26072kB active_anon:14776kB inactive_anon:808164kB active_file:0kB inactive_file:384kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:2736kB pagetables:2844kB bounce:0kB free_pcp:1884kB local_pcp:716kB free_cma:0kB
[ 1378.236949] lowmem_reserve[]: 0 0 0 0
[ 1378.236953] Node 0 DMA: 2*4kB (UM) 1*8kB (U) 1*16kB (U) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14752kB
[ 1378.236972] Node 0 DMA32: 9*4kB (UM) 7*8kB (UM) 7*16kB (UME) 6*32kB (UME) 4*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 1*1024kB (U) 1*2048kB (E) 12*4096kB (UM) = 53516kB
[ 1378.236990] Node 0 Normal: 216*4kB (UMEH) 89*8kB (UMEH) 71*16kB (UMEH) 66*32kB (UMEH) 16*64kB (UMEH) 12*128kB (UMEH) 19*256kB (UMEH) 10*512kB (UME) 1*1024kB (H) 0*2048kB 0*4096kB = 18392kB
[ 1378.237008] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1378.237009] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1378.237010] 875163 total pagecache pages
[ 1378.237013] 0 pages in swap cache
[ 1378.237014] Swap cache stats: add 0, delete 0, find 0/0
[ 1378.237015] Free swap  = 0kB
[ 1378.237016] Total swap = 0kB
[ 1378.237017] 1048445 pages RAM
[ 1378.237018] 0 pages HighMem/MovableOnly
[ 1378.237018] 116531 pages reserved
[ 1378.237019] 0 pages hwpoisoned
[ 1378.237020] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 1378.237029] [  476]     0   476    10952      553      24       3        0         -1000 systemd-udevd
[ 1378.237031] [  486]     0   486    13856      110      26       3        0         -1000 auditd
[ 1378.237034] [  660]     0   660    26372      247      55       3        0         -1000 sshd
[ 1378.237039] [ 6537]     0  6537    27511       32      13       3        0             0 agetty
[ 1378.237041] [ 6538]    81  6538     6103       78      17       3        0          -900 dbus-daemon
[ 1378.237127] [ 6855]  1000  6855  4195473   852376    1790      19        0             0 a.out
[ 1378.237132] [ 6862]     0  6862    27511       32      10       3        0             0 agetty
[ 1378.237134] Out of memory: Kill process 6537 (agetty) score 0 or sacrifice child
[ 1378.237146] Killed process 6537 (agetty) total-vm:110044kB, anon-rss:124kB, file-rss:4kB, shmem-rss:0kB
[ 1378.247858] kworker/u16:2 invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=2, oom_score_adj=0
[ 1378.247864] kworker/u16:2 cpuset=/ mems_allowed=0
[ 1378.247871] CPU: 3 PID: 6523 Comm: kworker/u16:2 Not tainted 4.13.0-rc2-next-20170728 #649
[ 1378.247872] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1378.247879] Workqueue: events_unbound call_usermodehelper_exec_work
[ 1378.247881] Call Trace:
[ 1378.247888]  dump_stack+0x67/0x9e
[ 1378.247913]  dump_header+0x9d/0x3fa
[ 1378.247924]  ? trace_hardirqs_on+0xd/0x10
[ 1378.247931]  oom_kill_process+0x226/0x650
[ 1378.247938]  out_of_memory+0x136/0x560
[ 1378.247940]  ? out_of_memory+0x206/0x560
[ 1378.247945]  __alloc_pages_nodemask+0xdce/0xeb0
[ 1378.247948]  ? copy_process.part.39+0x7eb/0x1e30
[ 1378.247966]  copy_process.part.39+0x13f/0x1e30
[ 1378.247968]  ? __lock_acquire+0x506/0x1a90
[ 1378.247971]  ? load_balance+0x1b0/0xaf0
[ 1378.248035]  ? umh_complete+0x30/0x30
[ 1378.248054]  _do_fork+0xea/0x5f0
[ 1378.248060]  ? native_sched_clock+0x36/0xa0
[ 1378.248187]  kernel_thread+0x24/0x30
[ 1378.248191]  call_usermodehelper_exec_work+0x35/0xc0
[ 1378.248194]  process_one_work+0x1d0/0x3e0
[ 1378.248225]  ? process_one_work+0x16a/0x3e0
[ 1378.248234]  worker_thread+0x48/0x3c0
[ 1378.248265]  kthread+0x10d/0x140
[ 1378.248267]  ? process_one_work+0x3e0/0x3e0
[ 1378.248269]  ? kthread_create_on_node+0x60/0x60
[ 1378.248274]  ret_from_fork+0x27/0x40
[ 1378.248301] Mem-Info:
[ 1378.248304] active_anon:3649 inactive_anon:872923 isolated_anon:0
[ 1378.248304]  active_file:34 inactive_file:18 isolated_file:0
[ 1378.248304]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1378.248304]  slab_reclaimable:0 slab_unreclaimable:0
[ 1378.248304]  mapped:852443 shmem:875026 pagetables:2050 bounce:0
[ 1378.248304]  free:21820 free_pcp:444 free_cma:0
[ 1378.248307] Node 0 active_anon:14596kB inactive_anon:3491692kB active_file:136kB inactive_file:72kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3409772kB dirty:0kB writeback:0kB shmem:3500104kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1378.248308] Node 0 DMA free:14752kB min:288kB low:360kB high:432kB active_anon:0kB inactive_anon:1116kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.248312] lowmem_reserve[]: 0 2688 3624 3624
[ 1378.248316] Node 0 DMA32 free:53516kB min:49908kB low:62384kB high:74860kB active_anon:16kB inactive_anon:2682496kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:5352kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.248319] lowmem_reserve[]: 0 0 936 936
[ 1378.248324] Node 0 Normal free:19012kB min:17384kB low:21728kB high:26072kB active_anon:14776kB inactive_anon:808164kB active_file:0kB inactive_file:384kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:2736kB pagetables:2844kB bounce:0kB free_pcp:1776kB local_pcp:692kB free_cma:0kB
[ 1378.248326] lowmem_reserve[]: 0 0 0 0
[ 1378.248331] Node 0 DMA: 2*4kB (UM) 1*8kB (U) 1*16kB (U) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14752kB
[ 1378.248350] Node 0 DMA32: 9*4kB (UM) 7*8kB (UM) 7*16kB (UME) 6*32kB (UME) 4*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 1*1024kB (U) 1*2048kB (E) 12*4096kB (UM) = 53516kB
[ 1378.248368] Node 0 Normal: 285*4kB (UMEH) 92*8kB (UMEH) 77*16kB (UMEH) 69*32kB (UMEH) 18*64kB (UMEH) 12*128kB (UMEH) 19*256kB (UMEH) 10*512kB (UME) 1*1024kB (H) 0*2048kB 0*4096kB = 19012kB
[ 1378.248387] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1378.248388] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1378.248389] 875052 total pagecache pages
[ 1378.248392] 0 pages in swap cache
[ 1378.248393] Swap cache stats: add 0, delete 0, find 0/0
[ 1378.248394] Free swap  = 0kB
[ 1378.248395] Total swap = 0kB
[ 1378.248396] 1048445 pages RAM
[ 1378.248397] 0 pages HighMem/MovableOnly
[ 1378.248398] 116531 pages reserved
[ 1378.248399] 0 pages hwpoisoned
[ 1378.248400] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 1378.248412] [  476]     0   476    10952      553      24       3        0         -1000 systemd-udevd
[ 1378.248416] [  486]     0   486    13856      110      26       3        0         -1000 auditd
[ 1378.248419] [  660]     0   660    26372      247      55       3        0         -1000 sshd
[ 1378.248426] [ 6538]    81  6538     6103       78      17       3        0          -900 dbus-daemon
[ 1378.248527] [ 6855]  1000  6855  4195473   852376    1790      19        0             0 a.out
[ 1378.248533] [ 6862]     0  6862    27511       32      10       3        0             0 agetty
[ 1378.248535] Out of memory: Kill process 6862 (agetty) score 0 or sacrifice child
[ 1378.248566] Killed process 6862 (agetty) total-vm:110044kB, anon-rss:124kB, file-rss:4kB, shmem-rss:0kB
[ 1378.252379] kworker/u16:26 invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=2, oom_score_adj=0
[ 1378.252384] kworker/u16:26 cpuset=/ mems_allowed=0
[ 1378.252390] CPU: 0 PID: 353 Comm: kworker/u16:26 Not tainted 4.13.0-rc2-next-20170728 #649
[ 1378.252391] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1378.252396] Workqueue: events_unbound call_usermodehelper_exec_work
[ 1378.252397] Call Trace:
[ 1378.252402]  dump_stack+0x67/0x9e
[ 1378.252407]  dump_header+0x9d/0x3fa
[ 1378.252413]  ? trace_hardirqs_on+0xd/0x10
[ 1378.252420]  oom_kill_process+0x226/0x650
[ 1378.252426]  out_of_memory+0x136/0x560
[ 1378.252428]  ? out_of_memory+0x206/0x560
[ 1378.252433]  __alloc_pages_nodemask+0xdce/0xeb0
[ 1378.252436]  ? copy_process.part.39+0x7eb/0x1e30
[ 1378.252453]  copy_process.part.39+0x13f/0x1e30
[ 1378.252455]  ? __lock_acquire+0x506/0x1a90
[ 1378.252458]  ? load_balance+0x1b0/0xaf0
[ 1378.252465]  ? umh_complete+0x30/0x30
[ 1378.252472]  _do_fork+0xea/0x5f0
[ 1378.252477]  ? native_sched_clock+0x36/0xa0
[ 1378.252487]  kernel_thread+0x24/0x30
[ 1378.252490]  call_usermodehelper_exec_work+0x35/0xc0
[ 1378.252493]  process_one_work+0x1d0/0x3e0
[ 1378.252494]  ? process_one_work+0x16a/0x3e0
[ 1378.252502]  worker_thread+0x48/0x3c0
[ 1378.252510]  kthread+0x10d/0x140
[ 1378.252511]  ? process_one_work+0x3e0/0x3e0
[ 1378.252514]  ? kthread_create_on_node+0x60/0x60
[ 1378.252519]  ret_from_fork+0x27/0x40
[ 1378.252530] Mem-Info:
[ 1378.252533] active_anon:3649 inactive_anon:872923 isolated_anon:0
[ 1378.252533]  active_file:34 inactive_file:0 isolated_file:0
[ 1378.252533]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1378.252533]  slab_reclaimable:0 slab_unreclaimable:0
[ 1378.252533]  mapped:852443 shmem:875026 pagetables:2050 bounce:0
[ 1378.252533]  free:21820 free_pcp:501 free_cma:0
[ 1378.252535] Node 0 active_anon:14596kB inactive_anon:3491692kB active_file:136kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3409772kB dirty:0kB writeback:0kB shmem:3500104kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1378.252536] Node 0 DMA free:14752kB min:288kB low:360kB high:432kB active_anon:0kB inactive_anon:1116kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.252539] lowmem_reserve[]: 0 2688 3624 3624
[ 1378.252544] Node 0 DMA32 free:53516kB min:49908kB low:62384kB high:74860kB active_anon:16kB inactive_anon:2682496kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:5352kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1378.252547] lowmem_reserve[]: 0 0 936 936
[ 1378.252551] Node 0 Normal free:19012kB min:17384kB low:21728kB high:26072kB active_anon:14776kB inactive_anon:808164kB active_file:0kB inactive_file:384kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:2736kB pagetables:2844kB bounce:0kB free_pcp:2004kB local_pcp:668kB free_cma:0kB
[ 1378.252554] lowmem_reserve[]: 0 0 0 0
[ 1378.252559] Node 0 DMA: 2*4kB (UM) 1*8kB (U) 1*16kB (U) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14752kB
[ 1378.252578] Node 0 DMA32: 9*4kB (UM) 7*8kB (UM) 7*16kB (UME) 6*32kB (UME) 4*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 1*1024kB (U) 1*2048kB (E) 12*4096kB (UM) = 53516kB
[ 1378.252596] Node 0 Normal: 271*4kB (UMEH) 97*8kB (UMEH) 79*16kB (UMEH) 69*32kB (UMEH) 18*64kB (UMEH) 12*128kB (UMEH) 19*256kB (UMEH) 10*512kB (UME) 1*1024kB (H) 0*2048kB 0*4096kB = 19028kB
[ 1378.252614] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1378.252616] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1378.252617] 875015 total pagecache pages
[ 1378.252620] 0 pages in swap cache
[ 1378.252621] Swap cache stats: add 0, delete 0, find 0/0
[ 1378.252622] Free swap  = 0kB
[ 1378.252622] Total swap = 0kB
[ 1378.252624] 1048445 pages RAM
[ 1378.252625] 0 pages HighMem/MovableOnly
[ 1378.252626] 116531 pages reserved
[ 1378.252627] 0 pages hwpoisoned
[ 1378.252628] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 1378.252634] [  476]     0   476    10952      553      24       3        0         -1000 systemd-udevd
[ 1378.252638] [  486]     0   486    13856      110      26       3        0         -1000 auditd
[ 1378.252641] [  660]     0   660    26372      247      55       3        0         -1000 sshd
[ 1378.252646] [ 6538]    81  6538     6103       78      17       3        0          -900 dbus-daemon
[ 1378.252859] [ 6855]  1000  6855  4195473   852376    1790      19        0             0 a.out
[ 1378.252866] Out of memory: Kill process 6538 (dbus-daemon) score 0 or sacrifice child
[ 1378.252879] Killed process 6538 (dbus-daemon) total-vm:24412kB, anon-rss:312kB, file-rss:0kB, shmem-rss:0kB
[ 1379.068645] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1379.068647] 875105 total pagecache pages
[ 1379.068650] 0 pages in swap cache
[ 1379.068651] Swap cache stats: add 0, delete 0, find 0/0
[ 1379.068652] Free swap  = 0kB
[ 1379.068653] Total swap = 0kB
[ 1379.068655] 1048445 pages RAM
[ 1379.068656] 0 pages HighMem/MovableOnly
[ 1379.068656] 116531 pages reserved
[ 1379.068657] 0 pages hwpoisoned
[ 1379.101641] kworker/u16:29 invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=2, oom_score_adj=0
[ 1379.105795] kworker/u16:29 cpuset=/ mems_allowed=0
[ 1379.107976] CPU: 0 PID: 356 Comm: kworker/u16:29 Not tainted 4.13.0-rc2-next-20170728 #649
[ 1379.110761] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1379.114084] Workqueue: events_unbound call_usermodehelper_exec_work
[ 1379.116440] Call Trace:
[ 1379.117938]  dump_stack+0x67/0x9e
[ 1379.119603]  dump_header+0x9d/0x3fa
[ 1379.121301]  out_of_memory+0x470/0x560
[ 1379.122979]  ? out_of_memory+0x206/0x560
[ 1379.124689]  __alloc_pages_nodemask+0xdce/0xeb0
[ 1379.126519]  ? copy_process.part.39+0x7eb/0x1e30
[ 1379.128346]  copy_process.part.39+0x13f/0x1e30
[ 1379.130084]  ? __lock_acquire+0x506/0x1a90
[ 1379.131719]  ? umh_complete+0x30/0x30
[ 1379.133265]  _do_fork+0xea/0x5f0
[ 1379.134689]  ? native_sched_clock+0x36/0xa0
[ 1379.136239]  kernel_thread+0x24/0x30
[ 1379.137628]  call_usermodehelper_exec_work+0x35/0xc0
[ 1379.139364]  process_one_work+0x1d0/0x3e0
[ 1379.140857]  ? process_one_work+0x16a/0x3e0
[ 1379.142361]  worker_thread+0x48/0x3c0
[ 1379.143813]  kthread+0x10d/0x140
[ 1379.145138]  ? process_one_work+0x3e0/0x3e0
[ 1379.146657]  ? kthread_create_on_node+0x60/0x60
[ 1379.148252]  ret_from_fork+0x27/0x40
[ 1379.149659] Mem-Info:
[ 1379.151818] active_anon:3493 inactive_anon:872905 isolated_anon:0
[ 1379.151818]  active_file:44 inactive_file:82 isolated_file:0
[ 1379.151818]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1379.151818]  slab_reclaimable:0 slab_unreclaimable:0
[ 1379.151818]  mapped:532931 shmem:875026 pagetables:1923 bounce:0
[ 1379.151818]  free:21712 free_pcp:565 free_cma:0
[ 1379.163532] Node 0 active_anon:13972kB inactive_anon:3491620kB active_file:176kB inactive_file:204kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1943792kB dirty:0kB writeback:0kB shmem:3500104kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1379.171228] Node 0 DMA free:14752kB min:288kB low:360kB high:432kB active_anon:0kB inactive_anon:1116kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1379.178826] lowmem_reserve[]: 0 2688 3624 3624
[ 1379.180764] Node 0 DMA32 free:53516kB min:49908kB low:62384kB high:74860kB active_anon:16kB inactive_anon:2682496kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752884kB mlocked:0kB kernel_stack:0kB pagetables:5352kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1379.188610] lowmem_reserve[]: 0 0 936 936
[ 1379.191335] Node 0 Normal free:19124kB min:17384kB low:21728kB high:26072kB active_anon:13956kB inactive_anon:808008kB active_file:100kB inactive_file:516kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:2640kB pagetables:2336kB bounce:0kB free_pcp:2156kB local_pcp:540kB free_cma:0kB
[ 1379.200442] lowmem_reserve[]: 0 0 0 0
[ 1379.202105] Node 0 DMA: 2*4kB (UM) 1*8kB (U) 1*16kB (U) 2*32kB (UM) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14752kB
[ 1379.207076] Node 0 DMA32: 9*4kB (UM) 7*8kB (UM) 7*16kB (UME) 6*32kB (UME) 4*64kB (UME) 1*128kB (M) 2*256kB (ME) 0*512kB 1*1024kB (U) 1*2048kB (E) 12*4096kB (UM) = 53516kB
[ 1379.212387] Node 0 Normal: 72*4kB (UMEH) 108*8kB (UMEH) 97*16kB (UMEH) 83*32kB (UMEH) 21*64kB (UMEH) 12*128kB (UMEH) 19*256kB (UMEH) 10*512kB (UME) 1*1024kB (H) 0*2048kB 0*4096kB = 19248kB
[ 1379.217936] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1379.220795] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1379.223635] 875203 total pagecache pages
[ 1379.225549] 0 pages in swap cache
[ 1379.228278] Swap cache stats: add 0, delete 0, find 0/0
[ 1379.230716] Free swap  = 0kB
[ 1379.232374] Total swap = 0kB
[ 1379.233975] 1048445 pages RAM
[ 1379.235603] 0 pages HighMem/MovableOnly
[ 1379.237382] 116531 pages reserved
[ 1379.239170] 0 pages hwpoisoned
[ 1379.240891] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 1379.243705] [  476]     0   476    10952      553      24       3        0         -1000 systemd-udevd
[ 1379.246883] [  486]     0   486    13856      110      26       3        0         -1000 auditd
[ 1379.249890] [  660]     0   660    26372      247      55       3        0         -1000 sshd
[ 1379.253002] Kernel panic - not syncing: Out of memory and no killable processes...
[ 1379.253002] 
[ 1379.256943] CPU: 0 PID: 356 Comm: kworker/u16:29 Not tainted 4.13.0-rc2-next-20170728 #649
[ 1379.259739] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1379.263081] Workqueue: events_unbound call_usermodehelper_exec_work
[ 1379.265496] Call Trace:
[ 1379.267085]  dump_stack+0x67/0x9e
[ 1379.268897]  panic+0xe5/0x23f
[ 1379.270588]  out_of_memory+0x47e/0x560
[ 1379.272475]  ? out_of_memory+0x206/0x560
[ 1379.274397]  __alloc_pages_nodemask+0xdce/0xeb0
[ 1379.276422]  ? copy_process.part.39+0x7eb/0x1e30
[ 1379.278475]  copy_process.part.39+0x13f/0x1e30
[ 1379.280491]  ? __lock_acquire+0x506/0x1a90
[ 1379.282561]  ? umh_complete+0x30/0x30
[ 1379.284514]  _do_fork+0xea/0x5f0
[ 1379.286341]  ? native_sched_clock+0x36/0xa0
[ 1379.288370]  kernel_thread+0x24/0x30
----------

> 
> > If a multi-threaded process which consumes little memory was
> > selected as an OOM victim (and reaped by the OOM reaper and MMF_OOM_SKIP
> > was set immediately), it might be still possible to select next OOM victims
> > needlessly.
> 
> This would be true if the address space itself only contained a little
> amount of memory and the large part of the memory was in page tables or
> other resources which oom_reaper cannot work with. This is not a usual
> case though.

mlock()ing whole memory needs CAP_IPC_LOCK, but consuming whole memory as
MAP_SHARED does not need CAP_IPC_LOCK. And I think we can relax MMF_OOM_SKIP
test in task_will_free_mem() to ignore MMF_OOM_SKIP for once, for "mm, oom:
do not grant oom victims full memory reserves access" might be too large change
for older kernels which next version of LTS distributions would choose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
