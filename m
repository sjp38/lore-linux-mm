Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 024A36B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 02:44:02 -0400 (EDT)
Received: by igcpe7 with SMTP id pe7so74456073igc.0
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 23:44:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h13si7121588igt.39.2015.10.11.23.43.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 11 Oct 2015 23:44:00 -0700 (PDT)
Subject: Re: Can't we use timeout based OOM warning/killing?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
	<201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
In-Reply-To: <201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
Message-Id: <201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
Date: Mon, 12 Oct 2015 15:43:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Tetsuo Handa wrote:
> So, zapping the first OOM victim's mm might fail by chance.

I retested with a slightly different version.

---------- Reproducer start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <sys/mman.h>

static int writer(void *unused)
{
	const int fd = open("/proc/self/exe", O_RDONLY);
	while (1) {
		void *ptr = mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, fd, 0);
		munmap(ptr, 4096);
	}
	return 0;
}

int main(int argc, char *argv[])
{
	char buffer[128] = { };
	const pid_t pid = fork();
	if (pid == 0) { /* down_write(&mm->mmap_sem) requester which is chosen as an OOM victim. */
		int i;
		for (i = 0; i < 9; i++)
			clone(writer, malloc(1024) + 1024, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
		writer(NULL);
	}
	snprintf(buffer, sizeof(buffer) - 1, "/proc/%u/stat", pid);
	if (fork() == 0) { /* down_read(&mm->mmap_sem) requester. */
		const int fd = open(buffer, O_RDONLY);
		while (pread(fd, buffer, sizeof(buffer), 0) > 0);
		_exit(0);
	} else { /* A dummy process for invoking the OOM killer. */
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
		return 0;
	}
}
---------- Reproducer end ----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20151012.txt.xz .

Uptime between 101 and 300 is a silent hang up (i.e. no OOM killer messages,
no SIGKILL pending tasks, no TIF_MEMDIE tasks) which I solved using SysRq-f
at uptime = 289. I don't know the reason of this silent hang up, but the
memory unzapping kernel thread will not help because there is no OOM victim.

----------
[  101.438951] MemAlloc-Info: 10 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  111.817922] MemAlloc-Info: 12 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  122.281828] MemAlloc-Info: 13 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  132.793724] MemAlloc-Info: 14 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  143.336154] MemAlloc-Info: 16 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  289.343187] sysrq: SysRq : Manual OOM execution
(...snipped...)
[  292.065650] MemAlloc-Info: 16 stalling task, 0 dying task, 0 victim task.
(...snipped...)
[  302.590736] kworker/3:2 invoked oom-killer: gfp_mask=0x24000c0, order=-1, oom_score_adj=0
(...snipped...)
[  302.690047] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
----------

Uptime between 379 and 605 is a mmap_sem livelock after the OOM killer was
invoked.

----------
[  380.039897] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  380.042500] [  467]     0   467    14047     1815      28       3        0             0 systemd-journal
[  380.045055] [  482]     0   482    10413      259      23       3        0         -1000 systemd-udevd
[  380.047637] [  504]     0   504    12795      119      25       3        0         -1000 auditd
[  380.050127] [ 1244]     0  1244    82428     4257      81       3        0             0 firewalld
[  380.052536] [ 1247]    70  1247     6988       61      21       3        0             0 avahi-daemon
[  380.055028] [ 1250]     0  1250    54104     1372      42       4        0             0 rsyslogd
[  380.057505] [ 1251]     0  1251   137547     2620      91       3        0             0 tuned
[  380.059996] [ 1255]     0  1255     4823       77      15       3        0             0 irqbalance
[  380.062552] [ 1256]     0  1256     1095       37       8       3        0             0 rngd
[  380.065020] [ 1259]     0  1259    53626      441      60       3        0             0 abrtd
[  380.067383] [ 1260]     0  1260    53001      341      58       5        0             0 abrt-watch-log
[  380.069965] [ 1265]     0  1265     8673       83      21       3        0             0 systemd-logind
[  380.072554] [ 1266]    81  1266     6663      117      18       3        0          -900 dbus-daemon
[  380.075122] [ 1272]     0  1272    31577      154      21       3        0             0 crond
[  380.077544] [ 1314]    70  1314     6988       57      19       3        0             0 avahi-daemon
[  380.080013] [ 1427]     0  1427    46741      225      44       3        0             0 vmtoolsd
[  380.082478] [ 1969]     0  1969    25942     3100      48       3        0             0 dhclient
[  380.084969] [ 1990]   999  1990   128626     1929      50       4        0             0 polkitd
[  380.087516] [ 2073]     0  2073    20629      214      45       3        0         -1000 sshd
[  380.090065] [ 2201]     0  2201     7320       68      21       3        0             0 xinetd
[  380.092465] [ 3215]     0  3215    22773      257      44       3        0             0 master
[  380.094879] [ 3217]    89  3217    22816      249      45       3        0             0 qmgr
[  380.097304] [ 3249]     0  3249    75245      315      97       3        0             0 nmbd
[  380.099666] [ 3259]     0  3259    92963      486     131       5        0             0 smbd
[  380.101956] [ 3282]     0  3282    27503       30      12       3        0             0 agetty
[  380.104277] [ 3283]     0  3283    21788      154      49       3        0             0 login
[  380.106574] [ 3286]     0  3286    92963      486     126       5        0             0 smbd
[  380.108835] [ 3296]  1000  3296    28864      117      13       3        0             0 bash
[  380.111073] [ 3374]    89  3374    22799      249      46       3        0             0 pickup
[  380.113298] [ 3378]    89  3378    22836      252      45       3        0             0 cleanup
[  380.115555] [ 3385]    89  3385    22800      248      44       3        0             0 trivial-rewrite
[  380.117811] [ 3392]     0  3392    22825      265      48       3        0             0 local
[  380.119995] [ 3393]     0  3393    30828       59      17       3        0             0 anacron
[  380.122183] [ 3417]  1000  3417   541715   397587     787       6        0             0 a.out
[  380.124315] [ 3418]  1000  3418     1081       24       8       3        0             0 a.out
[  380.126410] [ 3419]  1000  3419     1042       21       7       3        0             0 a.out
[  380.128535] Out of memory: Kill process 3417 (a.out) score 890 or sacrifice child
[  380.130392] Killed process 3418 (a.out) total-vm:4324kB, anon-rss:96kB, file-rss:0kB
[  392.704028] MemAlloc-Info: 7 stalling task, 10 dying task, 1 victim task.
(...snipped...)
[  601.129977] a.out           R  running task        0  3417   3296 0x00000080
[  601.131899]  ffff8800774dba10 ffffffff8112b174 0000000000000100 0000000000000000
[  601.134026]  0000000000000000 0000000000000000 00000000a23cb49d 0000000000000000
[  601.136076]  ffff880077603200 00000000024280ca 0000000000000000 ffff880077603200
[  601.138090] Call Trace:
[  601.139145]  [<ffffffff8112b174>] ? try_to_free_pages+0x94/0xc0
[  601.140831]  [<ffffffff8111a8c4>] ? out_of_memory+0x2f4/0x460
[  601.142489]  [<ffffffff8111fa63>] ? __alloc_pages_nodemask+0x613/0xc30
[  601.144328]  [<ffffffff81161c40>] ? alloc_pages_vma+0xb0/0x200
[  601.145994]  [<ffffffff81143056>] ? handle_mm_fault+0xfa6/0x1370
[  601.147677]  [<ffffffff8162f557>] ? native_iret+0x7/0x7
[  601.149258]  [<ffffffff81058217>] ? __do_page_fault+0x177/0x400
[  601.150966]  [<ffffffff810584d0>] ? do_page_fault+0x30/0x80
[  601.152625]  [<ffffffff81630518>] ? page_fault+0x28/0x30
[  601.154159]  [<ffffffff813230c0>] ? __clear_user+0x20/0x50
[  601.155723]  [<ffffffff81327a68>] ? iov_iter_zero+0x68/0x250
[  601.157329]  [<ffffffff813fc6c8>] ? read_iter_zero+0x38/0xa0
[  601.158923]  [<ffffffff81187f04>] ? __vfs_read+0xc4/0xf0
[  601.160453]  [<ffffffff8118868a>] ? vfs_read+0x7a/0x120
[  601.161961]  [<ffffffff811893a0>] ? SyS_read+0x50/0xc0
[  601.163513]  [<ffffffff8162e9ee>] ? entry_SYSCALL_64_fastpath+0x12/0x71
[  601.165254] a.out           D ffff8800777b7e08     0  3418   3417 0x00100084
[  601.167118]  ffff8800777b7e08 ffff880077606400 ffff8800777b8000 ffff880036032e00
[  601.169137]  ffff880036032de8 ffffffff00000000 ffffffff00000001 ffff8800777b7e20
[  601.171159]  ffffffff8162a570 ffff880077606400 ffff8800777b7ea8 ffffffff8162d8eb
[  601.173183] Call Trace:
[  601.174193]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.175661]  [<ffffffff8162d8eb>] rwsem_down_write_failed+0x1fb/0x350
[  601.177388]  [<ffffffff81322f64>] ? call_rwsem_down_read_failed+0x14/0x30
[  601.179194]  [<ffffffff81322f93>] call_rwsem_down_write_failed+0x13/0x20
[  601.180971]  [<ffffffff8162d05f>] ? down_write+0x1f/0x30
[  601.182509]  [<ffffffff81147abe>] vm_munmap+0x2e/0x60
[  601.183992]  [<ffffffff811489fd>] SyS_munmap+0x1d/0x30
[  601.185485]  [<ffffffff8162e9ee>] entry_SYSCALL_64_fastpath+0x12/0x71
[  601.187224] a.out           D ffff88007c60fdf0     0  3420   3417 0x00000084
[  601.189130]  ffff88007c60fdf0 ffff880078e15780 ffff88007c610000 ffff880036032de8
[  601.191158]  ffff880036032e00 ffff88007c60ff58 ffff880078e15780 ffff88007c60fe08
[  601.193180]  ffffffff8162a570 ffff880078e15780 ffff88007c60fe68 ffffffff8162d698
[  601.195217] Call Trace:
[  601.196226]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.197683]  [<ffffffff8162d698>] rwsem_down_read_failed+0xf8/0x150
[  601.199407]  [<ffffffff81322f64>] call_rwsem_down_read_failed+0x14/0x30
[  601.201192]  [<ffffffff8162d032>] ? down_read+0x12/0x20
[  601.202711]  [<ffffffff810583f7>] __do_page_fault+0x357/0x400
[  601.204328]  [<ffffffff810584d0>] do_page_fault+0x30/0x80
[  601.205874]  [<ffffffff81630518>] page_fault+0x28/0x30
[  601.207376] a.out           D ffff88007c24fdf0     0  3421   3417 0x00000084
[  601.209286]  ffff88007c24fdf0 ffff880078e13200 ffff88007c250000 ffff880036032de8
[  601.211316]  ffff880036032e00 ffff88007c24ff58 ffff880078e13200 ffff88007c24fe08
[  601.213335]  ffffffff8162a570 ffff880078e13200 ffff88007c24fe68 ffffffff8162d698
[  601.215356] Call Trace:
[  601.216377]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.217831]  [<ffffffff8162d698>] rwsem_down_read_failed+0xf8/0x150
[  601.219529]  [<ffffffff81322f64>] call_rwsem_down_read_failed+0x14/0x30
[  601.221296]  [<ffffffff8162d032>] ? down_read+0x12/0x20
[  601.222802]  [<ffffffff810583f7>] __do_page_fault+0x357/0x400
[  601.224403]  [<ffffffff810584d0>] do_page_fault+0x30/0x80
[  601.225958]  [<ffffffff81630518>] page_fault+0x28/0x30
[  601.227453] a.out           D ffff88007823bdf0     0  3422   3417 0x00000084
[  601.229348]  ffff88007823bdf0 ffff880078e10000 ffff88007823c000 ffff880036032de8
[  601.231395]  ffff880036032e00 ffff88007823bf58 ffff880078e10000 ffff88007823be08
[  601.233427]  ffffffff8162a570 ffff880078e10000 ffff88007823be68 ffffffff8162d698
[  601.235472] Call Trace:
[  601.236504]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.237989]  [<ffffffff8162d698>] rwsem_down_read_failed+0xf8/0x150
[  601.239720]  [<ffffffff81322f64>] call_rwsem_down_read_failed+0x14/0x30
[  601.241583]  [<ffffffff8162d032>] ? down_read+0x12/0x20
[  601.243144]  [<ffffffff810583f7>] __do_page_fault+0x357/0x400
[  601.244777]  [<ffffffff810584d0>] do_page_fault+0x30/0x80
[  601.246307]  [<ffffffff81630518>] page_fault+0x28/0x30
[  601.247823] a.out           D ffff88007c483df0     0  3423   3417 0x00000084
[  601.249719]  ffff88007c483df0 ffff880078e13e80 ffff88007c484000 ffff880036032de8
[  601.251765]  ffff880036032e00 ffff88007c483f58 ffff880078e13e80 ffff88007c483e08
[  601.253808]  ffffffff8162a570 ffff880078e13e80 ffff88007c483e68 ffffffff8162d698
[  601.255831] Call Trace:
[  601.256850]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.258286]  [<ffffffff8162d698>] rwsem_down_read_failed+0xf8/0x150
[  601.260005]  [<ffffffff81322f64>] call_rwsem_down_read_failed+0x14/0x30
[  601.261803]  [<ffffffff8162d032>] ? down_read+0x12/0x20
[  601.263329]  [<ffffffff810583f7>] __do_page_fault+0x357/0x400
[  601.264936]  [<ffffffff810584d0>] do_page_fault+0x30/0x80
[  601.266504]  [<ffffffff81630518>] page_fault+0x28/0x30
[  601.268019] a.out           D ffff880035893e08     0  3424   3417 0x00000084
[  601.269940]  ffff880035893e08 ffff880078e17080 ffff880035894000 ffff880036032e00
[  601.271945]  ffff880036032de8 ffffffff00000000 ffffffff00000001 ffff880035893e20
[  601.273954]  ffffffff8162a570 ffff880078e17080 ffff880035893ea8 ffffffff8162d8eb
[  601.276000] Call Trace:
[  601.277007]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.278497]  [<ffffffff8162d8eb>] rwsem_down_write_failed+0x1fb/0x350
[  601.280240]  [<ffffffff81322f64>] ? call_rwsem_down_read_failed+0x14/0x30
[  601.282058]  [<ffffffff81322f93>] call_rwsem_down_write_failed+0x13/0x20
[  601.283872]  [<ffffffff8162d05f>] ? down_write+0x1f/0x30
[  601.285403]  [<ffffffff81147abe>] vm_munmap+0x2e/0x60
[  601.286924]  [<ffffffff811489fd>] SyS_munmap+0x1d/0x30
[  601.288435]  [<ffffffff8162e9ee>] entry_SYSCALL_64_fastpath+0x12/0x71
[  601.290184] a.out           D ffff8800353b7df0     0  3425   3417 0x00000084
[  601.292108]  ffff8800353b7df0 ffff880078e10c80 ffff8800353b8000 ffff880036032de8
[  601.294165]  ffff880036032e00 ffff8800353b7f58 ffff880078e10c80 ffff8800353b7e08
[  601.296206]  ffffffff8162a570 ffff880078e10c80 ffff8800353b7e68 ffffffff8162d698
[  601.298267] Call Trace:
[  601.299300]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.300755]  [<ffffffff8162d698>] rwsem_down_read_failed+0xf8/0x150
[  601.302437]  [<ffffffff81322f64>] call_rwsem_down_read_failed+0x14/0x30
[  601.304221]  [<ffffffff8162d032>] ? down_read+0x12/0x20
[  601.305764]  [<ffffffff810583f7>] __do_page_fault+0x357/0x400
[  601.307389]  [<ffffffff810584d0>] do_page_fault+0x30/0x80
[  601.308968]  [<ffffffff81630518>] page_fault+0x28/0x30
[  601.310488] a.out           D ffff88007cf87df0     0  3426   3417 0x00000084
[  601.312380]  ffff88007cf87df0 ffff880078e16400 ffff88007cf88000 ffff880036032de8
[  601.314414]  ffff880036032e00 ffff88007cf87f58 ffff880078e16400 ffff88007cf87e08
[  601.316443]  ffffffff8162a570 ffff880078e16400 ffff88007cf87e68 ffffffff8162d698
[  601.318490] Call Trace:
[  601.319536]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.321036]  [<ffffffff8162d698>] rwsem_down_read_failed+0xf8/0x150
[  601.322763]  [<ffffffff81322f64>] call_rwsem_down_read_failed+0x14/0x30
[  601.324504]  [<ffffffff8162d032>] ? down_read+0x12/0x20
[  601.326071]  [<ffffffff810583f7>] __do_page_fault+0x357/0x400
[  601.327715]  [<ffffffff810584d0>] do_page_fault+0x30/0x80
[  601.329287]  [<ffffffff81630518>] page_fault+0x28/0x30
[  601.330761] a.out           D ffff8800792dfdf0     0  3427   3417 0x00000084
[  601.332705]  ffff8800792dfdf0 ffff880078e12580 ffff8800792e0000 ffff880036032de8
[  601.334699]  ffff880036032e00 ffff8800792dff58 ffff880078e12580 ffff8800792dfe08
[  601.336750]  ffffffff8162a570 ffff880078e12580 ffff8800792dfe68 ffffffff8162d698
[  601.338794] Call Trace:
[  601.339781]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.341280]  [<ffffffff8162d698>] rwsem_down_read_failed+0xf8/0x150
[  601.343009]  [<ffffffff81322f64>] call_rwsem_down_read_failed+0x14/0x30
[  601.344813]  [<ffffffff8162d032>] ? down_read+0x12/0x20
[  601.346361]  [<ffffffff810583f7>] __do_page_fault+0x357/0x400
[  601.347990]  [<ffffffff810584d0>] do_page_fault+0x30/0x80
[  601.349521]  [<ffffffff81630518>] page_fault+0x28/0x30
[  601.351044] a.out           D ffff88007743faa8     0  3428   3417 0x00000084
[  601.352942]  ffff88007743faa8 ffff88007bda6400 ffff880077440000 ffff88007743fae0
[  601.354990]  ffff88007fccdfc0 00000001000484e5 0000000000000000 ffff88007743fac0
[  601.357024]  ffffffff8162a570 ffff88007fccdfc0 ffff88007743fb40 ffffffff8162dbed
[  601.359075] Call Trace:
[  601.360096]  [<ffffffff8162a570>] schedule+0x30/0x80
[  601.361540]  [<ffffffff8162dbed>] schedule_timeout+0x11d/0x1c0
[  601.363190]  [<ffffffff810c7e00>] ? cascade+0x90/0x90
[  601.364697]  [<ffffffff8162dce9>] schedule_timeout_uninterruptible+0x19/0x20
[  601.366574]  [<ffffffff8111fc9d>] __alloc_pages_nodemask+0x84d/0xc30
[  601.368332]  [<ffffffff811609a7>] alloc_pages_current+0x87/0x110
[  601.370002]  [<ffffffff811166cf>] __page_cache_alloc+0xaf/0xc0
[  601.371606]  [<ffffffff81119225>] filemap_fault+0x1e5/0x420
[  601.373203]  [<ffffffff81244f39>] xfs_filemap_fault+0x39/0x60
[  601.374798]  [<ffffffff8113d5e7>] __do_fault+0x47/0xd0
[  601.376315]  [<ffffffff81142ec5>] handle_mm_fault+0xe15/0x1370
[  601.377938]  [<ffffffff81322f64>] ? call_rwsem_down_read_failed+0x14/0x30
[  601.379707]  [<ffffffff81058217>] __do_page_fault+0x177/0x400
[  601.381320]  [<ffffffff810584d0>] do_page_fault+0x30/0x80
[  601.382831]  [<ffffffff81630518>] page_fault+0x28/0x30
[  601.384337] a.out           R  running task        0  3419   3417 0x00000080
[  601.386257]  00000000f80745e8 ffff880034ab4400 ffff8800776d3f18 ffff8800776d3f18
[  601.388287]  0000000000000080 0000000000000000 ffff8800776d3ec8 ffffffff81187e72
[  601.390341]  ffff880034ab4400 ffff880034ab4410 0000000000020000 0000000000000000
[  601.392366] Call Trace:
[  601.393388]  [<ffffffff81187e72>] ? __vfs_read+0x32/0xf0
[  601.394952]  [<ffffffff81290aa9>] ? security_file_permission+0xa9/0xc0
[  601.396745]  [<ffffffff8118858d>] ? rw_verify_area+0x4d/0xd0
[  601.398359]  [<ffffffff8118868a>] ? vfs_read+0x7a/0x120
[  601.399897]  [<ffffffff81189560>] ? SyS_pread64+0x90/0xb0
[  601.401429]  [<ffffffff8162e9ee>] ? entry_SYSCALL_64_fastpath+0x12/0x71
----------

I think that I noticed three problems from this reproducer.

(1) While the likeliness of hitting mmap_sem livelock would depend on how
    frequently down_read(&mm->mmap_sem) tasks and down_write(&mm->mmap_sem)
    tasks contend on the OOM victim's mm, we can hit mmap_sem livelock with
    even only one down_read(&mm->mmap_sem) task. On systems where processes
    are monitored using /proc/pid/ interface, we can by chance hit this
    mmap_sem livelock.

(2) The OOM killer tries to kill child process of the memory hog. But the
    child process is not always consuming a lot of memory. The memory
    unzapping kernel thread might not be able to reclaim enough memory
    unless we choose subsequent OOM victims when the first OOM victim task
    got mmap_sem livelock.

(3) I don't know the reason but I can observe that (when there are many
    tasks which got SIGKILL by the OOM killer) many of dying tasks participate
    in a memory allocation competition via page_fault() which cannot make
    forward progress because dying tasks without TIF_MEMDIE are not allowed
    to access the memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
