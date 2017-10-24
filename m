Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 345C96B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 07:23:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 14so21489974oii.2
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 04:23:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t67si14302oit.449.2017.10.24.04.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 04:23:53 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize out_of_memory() and allocation stall messages.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1508410262-4797-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171019114424.4db2hohyyogpjq5f@dhcp22.suse.cz>
	<201710201920.FCE43223.FQMVJOtOOSFFLH@I-love.SAKURA.ne.jp>
In-Reply-To: <201710201920.FCE43223.FQMVJOtOOSFFLH@I-love.SAKURA.ne.jp>
Message-Id: <201710242023.GHE48971.SQHtFFLFVJOMOO@I-love.SAKURA.ne.jp>
Date: Tue, 24 Oct 2017 20:23:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com, hannes@cmpxchg.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, yuwang.yuwang@alibaba-inc.com

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Hell no! I've tried to be patient with you but it seems that is just
> > pointless waste of time. Such an approach is absolutely not acceptable.
> > You are adding an additional lock dependency into the picture. Say that
> > there is somebody stuck in warn_alloc path and cannot make a further
> > progress because printk got stuck. Now you are blocking oom_kill_process
> > as well. So the cure might be even worse than the problem.
> 
> Sigh... printk() can't get stuck unless somebody continues appending to
> printk() buffer. Otherwise, printk() cannot be used from arbitrary context.
> 
> You had better stop calling printk() with oom_lock held if you consider that
> printk() can get stuck.
> 

For explaining how stupid the printk() versus oom_lock dependency is, here is a
patch for reproducing soft lockup caused by uncontrolled warn_alloc().

Below patch is for 6cff0a118f23b98c ("Merge tag 'platform-drivers-x86-v4.14-3' of
git://git.infradead.org/linux-platform-drivers-x86"), which intentionally try to
let the thread holding oom_lock to get stuck at printk(). This patch does not change
functionality. This patch changes only frequency/timing for emulating worst situation.

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..4c43f83 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3207,7 +3207,7 @@ static void warn_alloc_show_mem(gfp_t gfp_mask, nodemask_t *nodemask)
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 	static DEFINE_RATELIMIT_STATE(show_mem_rs, HZ, 1);
 
-	if (should_suppress_show_mem() || !__ratelimit(&show_mem_rs))
+	if (should_suppress_show_mem())
 		return;
 
 	/*
@@ -3232,7 +3232,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
 
-	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
+	if ((gfp_mask & __GFP_NOWARN))
 		return;
 
 	pr_warn("%s: ", current->comm);
@@ -4002,7 +4002,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto nopage;
 
 	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
+	if (__mutex_owner(&oom_lock)) {
 		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
----------

Enable softlockup_panic so that we can know where the thread got stuck.

----------
echo 9 > /proc/sys/kernel/printk
echo 1 > /proc/sys/kernel/sysrq
echo 1 > /proc/sys/kernel/softlockup_panic
----------

Memory stressor is shown below. All processes run on CPU 0.

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <signal.h>
#include <sys/prctl.h>
#include <sys/mman.h>

int main(int argc, char *argv[])
{
	struct sched_param sp = { 0 };
	cpu_set_t cpu = { { 1 } };
	static int pipe_fd[2] = { EOF, EOF };
	char *buf = NULL;
	unsigned long size = 0;
	unsigned int i;
	int fd;
	pipe(pipe_fd);
	signal(SIGCLD, SIG_IGN);
	if (fork() == 0) {
		prctl(PR_SET_NAME, (unsigned long) "first-victim", 0, 0, 0);
		while (1)
			pause();
	}
	close(pipe_fd[1]);
	sched_setaffinity(0, sizeof(cpu), &cpu);
	prctl(PR_SET_NAME, (unsigned long) "normal-priority", 0, 0, 0);
	for (i = 0; i < 1024; i++)
		if (fork() == 0) {
			char c;
			/* Wait until the first-victim is OOM-killed. */
			read(pipe_fd[0], &c, 1);
			/* Try to consume as much CPU time as possible. */
			while(1) {
				void *ptr = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, EOF, 0);
				munmap(ptr, 4096);
			}
			_exit(0);
		}
	close(pipe_fd[0]);
	fd = open("/dev/zero", O_RDONLY);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sched_setscheduler(0, SCHED_IDLE, &sp);
	prctl(PR_SET_NAME, (unsigned long) "idle-priority", 0, 0, 0);
	while (size) {
		int ret = read(fd, buf, size); /* Will cause OOM due to overcommit */
		if (ret <= 0)
			break;
		buf += ret;
		size -= ret;
	}
	kill(-1, SIGKILL);
	return 0; /* Not reached. */
}
----------

Below is a crash dump obtained using qemu-kvm hosted on 3.10.0-693.2.2.el7.x86_64 kernel.

----------
      KERNEL: linux/vmlinux             
    DUMPFILE: /tmp/dump2  [PARTIAL DUMP]
        CPUS: 4 [OFFLINE: 3]
        DATE: Tue Oct 24 16:01:19 2017
      UPTIME: 00:01:08
LOAD AVERAGE: 3.88, 0.92, 0.30
       TASKS: 1151
    NODENAME: localhost.localdomain
     RELEASE: 4.14.0-rc6+
     VERSION: #308 SMP Tue Oct 24 14:53:38 JST 2017
     MACHINE: x86_64  (3192 Mhz)
      MEMORY: 8 GB
       PANIC: "Kernel panic - not syncing: softlockup: hung tasks"
         PID: 1046
     COMMAND: "idle-priority"
        TASK: ffff88022c390000  [THREAD_INFO: ffff88022c390000]
         CPU: 0
       STATE: TASK_RUNNING (PANIC)

crash> ps -l
[68006009038] [IN]  PID: 20     TASK: ffff88018ee62e80  CPU: 2   COMMAND: "watchdog/2"
[68005972514] [UN]  PID: 66     TASK: ffff88023019c5c0  CPU: 3   COMMAND: "kworker/3:1"
[68005818859] [UN]  PID: 293    TASK: ffff88022fdfc5c0  CPU: 1   COMMAND: "kworker/1:3"
[68005793814] [UN]  PID: 986    TASK: ffff880230209740  CPU: 2   COMMAND: "master"
[68005528566] [UN]  PID: 217    TASK: ffff88023023ae80  CPU: 1   COMMAND: "kworker/1:2"
[68005444464] [UN]  PID: 416    TASK: ffff88022fd85d00  CPU: 2   COMMAND: "systemd-journal"
[68005442636] [UN]  PID: 891    TASK: ffff880230239740  CPU: 2   COMMAND: "kworker/2:4"
[68005362065] [UN]  PID: 577    TASK: ffff88022fde0000  CPU: 3   COMMAND: "in:imjournal"
[68005026323] [UN]  PID: 928    TASK: ffff8802311a0000  CPU: 1   COMMAND: "tuned"
[68005017104] [IN]  PID: 14     TASK: ffff88018ee39740  CPU: 1   COMMAND: "watchdog/1"
[68005015266] [UN]  PID: 589    TASK: ffff88023675ae80  CPU: 2   COMMAND: "crond"
[68005013129] [UN]  PID: 605    TASK: ffff88022fdf9740  CPU: 3   COMMAND: "gmain"
[68003013386] [UN]  PID: 8      TASK: ffff88018ee0ae80  CPU: 3   COMMAND: "rcu_sched"
[67038667541] [??]  PID: 888    TASK: ffff880230241740  CPU: 2   COMMAND: "kworker/2:3"
[64007020859] [IN]  PID: 26     TASK: ffff88018ee8c5c0  CPU: 3   COMMAND: "watchdog/3"
[61920020596] [IN]  PID: 40     TASK: ffff88023fd7ae80  CPU: 2   COMMAND: "khugepaged"
[59540010881] [IN]  PID: 16     TASK: ffff88018ee3c5c0  CPU: 1   COMMAND: "ksoftirqd/1"
[57812010332] [IN]  PID: 22     TASK: ffff88018ee65d00  CPU: 2   COMMAND: "ksoftirqd/2"
[44001013858] [UN]  PID: 348    TASK: ffff88023023c5c0  CPU: 1   COMMAND: "kworker/1:1H"
[42992018575] [IN]  PID: 57     TASK: ffff880230105d00  CPU: 1   COMMAND: "kswapd0"
[42976019430] [UN]  PID: 565    TASK: ffff88022fde2e80  CPU: 3   COMMAND: "kworker/3:1H"
[42838016448] [IN]  PID: 347    TASK: ffff88023023dd00  CPU: 3   COMMAND: "xfsaild/vda1"
[42786314423] [UN]  PID: 75     TASK: ffff8802301eae80  CPU: 1   COMMAND: "kworker/u8:1"
[42785491218] [UN]  PID: 315    TASK: ffff88022f20c5c0  CPU: 2   COMMAND: "kworker/2:1H"
[42784618771] [UN]  PID: 5      TASK: ffff88018edadd00  CPU: 1   COMMAND: "kworker/u8:0"
[42783021941] [UN]  PID: 574    TASK: ffff88023675c5c0  CPU: 3   COMMAND: "irqbalance"
[40738480039] [RU]  PID: 1046   TASK: ffff88022c390000  CPU: 0   COMMAND: "idle-priority"
[40738478908] [RU]  PID: 205    TASK: ffff88022fde5d00  CPU: 0   COMMAND: "kworker/0:3"
[40005008096] [RU]  PID: 11     TASK: ffff88018ee10000  CPU: 0   COMMAND: "watchdog/0"
[37392925636] [IN]  PID: 2063   TASK: ffff88022cb48000  CPU: 0   COMMAND: "normal-priority"
[37392903473] [IN]  PID: 2066   TASK: ffff88022cb4c5c0  CPU: 0   COMMAND: "normal-priority"
[37392880968] [IN]  PID: 2068   TASK: ffff88022cbb8000  CPU: 0   COMMAND: "normal-priority"
(304 '[IN]  CPU: 0   COMMAND: "normal-priority"' lines snipped.)
[37381076875] [IN]  PID: 1699   TASK: ffff8802339c1740  CPU: 0   COMMAND: "normal-priority"
[37381052728] [IN]  PID: 1620   TASK: ffff88023478ae80  CPU: 0   COMMAND: "normal-priority"
[37381026465] [IN]  PID: 1514   TASK: ffff880235361740  CPU: 0   COMMAND: "normal-priority"
[37381008004] [RU]  PID: 7      TASK: ffff88018ee09740  CPU: 0   COMMAND: "ksoftirqd/0"
[37380971366] [IN]  PID: 1738   TASK: ffff880231900000  CPU: 0   COMMAND: "normal-priority"
[37380947911] [IN]  PID: 1684   TASK: ffff880233899740  CPU: 0   COMMAND: "normal-priority"
[37380924449] [IN]  PID: 1597   TASK: ffff8802345a5d00  CPU: 0   COMMAND: "normal-priority"
(708 '[IN]  CPU: 0   COMMAND: "normal-priority"' lines snipped.)
[37361136670] [IN]  PID: 1239   TASK: ffff880233601740  CPU: 0   COMMAND: "normal-priority"
[37361111718] [IN]  PID: 1238   TASK: ffff880233600000  CPU: 0   COMMAND: "normal-priority"
[37361069614] [IN]  PID: 1237   TASK: ffff88023559dd00  CPU: 0   COMMAND: "normal-priority"
[37344152029] [IN]  PID: 1047   TASK: ffff880230250000  CPU: 3   COMMAND: "first-victim"
[37344142207] [IN]  PID: 27     TASK: ffff88018ee8dd00  CPU: 3   COMMAND: "migration/3"
[37342945775] [IN]  PID: 1027   TASK: ffff8802302545c0  CPU: 2   COMMAND: "bash"
[34669929199] [IN]  PID: 1018   TASK: ffff88022c391740  CPU: 3   COMMAND: "login"
[34669576733] [IN]  PID: 579    TASK: ffff88022fde45c0  CPU: 3   COMMAND: "rs:main Q:Reg"
[34669018457] [IN]  PID: 500    TASK: ffff880236ee5d00  CPU: 1   COMMAND: "auditd"
[34668995398] [IN]  PID: 56     TASK: ffff8802301045c0  CPU: 1   COMMAND: "kauditd"
[34668846904] [UN]  PID: 300    TASK: ffff88018ef645c0  CPU: 3   COMMAND: "kworker/3:2"
[34668281096] [IN]  PID: 1      TASK: ffff88018eda8000  CPU: 2   COMMAND: "systemd"
[34668234545] [IN]  PID: 572    TASK: ffff880233555d00  CPU: 1   COMMAND: "systemd-logind"
[34668221621] [IN]  PID: 573    TASK: ffff88023675dd00  CPU: 1   COMMAND: "polkitd"
[34668157306] [IN]  PID: 587    TASK: ffff8802367c8000  CPU: 1   COMMAND: "gdbus"
[34668030779] [IN]  PID: 575    TASK: ffff880236759740  CPU: 0   COMMAND: "dbus-daemon"
[34667468724] [IN]  PID: 597    TASK: ffff88018eeb45c0  CPU: 1   COMMAND: "NetworkManager"
[34667366672] [IN]  PID: 608    TASK: ffff88022c3945c0  CPU: 3   COMMAND: "gdbus"
[34659025190] [IN]  PID: 28     TASK: ffff88018eeb0000  CPU: 3   COMMAND: "ksoftirqd/3"
[32316161544] [UN]  PID: 934    TASK: ffff88023020c5c0  CPU: 0   COMMAND: "kworker/0:1H"
[31711078811] [UN]  PID: 34     TASK: ffff88018eed9740  CPU: 0   COMMAND: "kworker/0:1"
[31124096990] [UN]  PID: 23     TASK: ffff88018ee88000  CPU: 2   COMMAND: "kworker/2:0"
[ 7006653998] [IN]  PID: 15     TASK: ffff88018ee3ae80  CPU: 1   COMMAND: "migration/1"
[ 6940208222] [IN]  PID: 504    TASK: ffff880230242e80  CPU: 2   COMMAND: "auditd"
[ 5704370038] [IN]  PID: 439    TASK: ffff8802302445c0  CPU: 3   COMMAND: "systemd-udevd"
[ 3411620247] [IN]  PID: 665    TASK: ffff88022fdc5d00  CPU: 0   COMMAND: "dhclient"
[ 2960244550] [IN]  PID: 10     TASK: ffff88018ee0dd00  CPU: 0   COMMAND: "migration/0"
[ 2954991612] [IN]  PID: 988    TASK: ffff880233552e80  CPU: 0   COMMAND: "qmgr"
[ 2951385676] [IN]  PID: 987    TASK: ffff880233550000  CPU: 1   COMMAND: "pickup"
[ 2797722377] [UN]  PID: 4      TASK: ffff88018edac5c0  CPU: 0   COMMAND: "kworker/0:0H"
[ 2797696572] [IN]  PID: 2      TASK: ffff88018eda9740  CPU: 2   COMMAND: "kthreadd"
[ 2789250032] [IN]  PID: 930    TASK: ffff8802367c45c0  CPU: 1   COMMAND: "tuned"
[ 2786019436] [IN]  PID: 927    TASK: ffff8802311a45c0  CPU: 2   COMMAND: "tuned"
[ 2785978972] [IN]  PID: 846    TASK: ffff88023020ae80  CPU: 1   COMMAND: "tuned"
[ 2781228329] [IN]  PID: 925    TASK: ffff8802311a1740  CPU: 0   COMMAND: "gmain"
[ 2693216592] [UN]  PID: 158    TASK: ffff880230252e80  CPU: 2   COMMAND: "kworker/2:2"
[ 2693215466] [UN]  PID: 59     TASK: ffff880230189740  CPU: 2   COMMAND: "kworker/2:1"
[ 2688297935] [IN]  PID: 848    TASK: ffff880230208000  CPU: 0   COMMAND: "sshd"
[ 2681010287] [UN]  PID: 53     TASK: ffff880230100000  CPU: 1   COMMAND: "kworker/1:1"
[ 2676065949] [IN]  PID: 21     TASK: ffff88018ee645c0  CPU: 2   COMMAND: "migration/2"
[ 2375572292] [UN]  PID: 663    TASK: ffff8802367c5d00  CPU: 1   COMMAND: "kworker/1:4"
[ 2375558842] [UN]  PID: 17     TASK: ffff88018ee3dd00  CPU: 1   COMMAND: "kworker/1:0"
[ 1897490458] [IN]  PID: 593    TASK: ffff88022fd81740  CPU: 3   COMMAND: "polkitd"
[ 1897116851] [IN]  PID: 591    TASK: ffff8802367cae80  CPU: 1   COMMAND: "JS Sour~ Thread"
[ 1895094186] [IN]  PID: 32     TASK: ffff88018eeb5d00  CPU: 1   COMMAND: "kdevtmpfs"
[ 1884903018] [IN]  PID: 588    TASK: ffff8802367cc5c0  CPU: 1   COMMAND: "JS GC Helper"
[ 1881538545] [IN]  PID: 585    TASK: ffff8802367cdd00  CPU: 1   COMMAND: "gmain"
[ 1872987774] [IN]  PID: 583    TASK: ffff88022fde1740  CPU: 1   COMMAND: "dbus-daemon"
[ 1840792454] [IN]  PID: 303    TASK: ffff88023019dd00  CPU: 2   COMMAND: "scsi_eh_0"
[ 1836228666] [IN]  PID: 569    TASK: ffff8802335545c0  CPU: 3   COMMAND: "rsyslogd"
[ 1820454811] [UN]  PID: 30     TASK: ffff88018eeb2e80  CPU: 3   COMMAND: "kworker/3:0H"
[ 1652310426] [UN]  PID: 311    TASK: ffff88022f209740  CPU: 3   COMMAND: "kworker/u8:3"
[ 1638991783] [UN]  PID: 111    TASK: ffff8802301b45c0  CPU: 0   COMMAND: "kworker/0:2"
[ 1252067459] [UN]  PID: 18     TASK: ffff88018ee60000  CPU: 1   COMMAND: "kworker/1:0H"
[ 1248932602] [UN]  PID: 346    TASK: ffff880230238000  CPU: 3   COMMAND: "xfs-eofblocks/v"
[ 1248911038] [UN]  PID: 345    TASK: ffff8802301c1740  CPU: 2   COMMAND: "xfs-log/vda1"
[ 1248897201] [UN]  PID: 344    TASK: ffff8802301c5d00  CPU: 1   COMMAND: "xfs-reclaim/vda"
[ 1248867714] [UN]  PID: 343    TASK: ffff8802301c45c0  CPU: 0   COMMAND: "xfs-cil/vda1"
[ 1248853541] [UN]  PID: 342    TASK: ffff8802301c2e80  CPU: 1   COMMAND: "xfs-conv/vda1"
[ 1248824175] [UN]  PID: 341    TASK: ffff8802301c0000  CPU: 0   COMMAND: "xfs-data/vda1"
[ 1248798070] [UN]  PID: 340    TASK: ffff88018ef61740  CPU: 2   COMMAND: "xfs-buf/vda1"
[ 1248455451] [UN]  PID: 339    TASK: ffff88018ef60000  CPU: 3   COMMAND: "xfs_mru_cache"
[ 1248405777] [UN]  PID: 338    TASK: ffff88018ef62e80  CPU: 3   COMMAND: "xfsalloc"
[  974516821] [UN]  PID: 323    TASK: ffff88018ef65d00  CPU: 1   COMMAND: "ttm_swap"
[  967022556] [IN]  PID: 305    TASK: ffff88023018ae80  CPU: 2   COMMAND: "scsi_eh_1"
[  843549456] [UN]  PID: 24     TASK: ffff88018ee89740  CPU: 2   COMMAND: "kworker/2:0H"
[  816011833] [UN]  PID: 307    TASK: ffff880230188000  CPU: 2   COMMAND: "kworker/u8:2"
[  804534162] [UN]  PID: 306    TASK: ffff88023018c5c0  CPU: 2   COMMAND: "scsi_tmf_1"
[  803964224] [UN]  PID: 304    TASK: ffff88023018dd00  CPU: 1   COMMAND: "scsi_tmf_0"
[  800968743] [UN]  PID: 29     TASK: ffff88018eeb1740  CPU: 3   COMMAND: "kworker/3:0"
[  800361745] [UN]  PID: 302    TASK: ffff880230198000  CPU: 2   COMMAND: "ata_sff"
[  728153882] [UN]  PID: 3      TASK: ffff88018edaae80  CPU: 0   COMMAND: "kworker/0:0"
[  630499518] [IN]  PID: 25     TASK: ffff88018ee8ae80  CPU: 3   COMMAND: "cpuhp/3"
[  630455067] [IN]  PID: 19     TASK: ffff88018ee61740  CPU: 2   COMMAND: "cpuhp/2"
[  630429505] [UN]  PID: 112    TASK: ffff8802301b2e80  CPU: 3   COMMAND: "ipv6_addrconf"
[  630416623] [IN]  PID: 13     TASK: ffff88018ee38000  CPU: 1   COMMAND: "cpuhp/1"
[  630374181] [IN]  PID: 12     TASK: ffff88018ee15d00  CPU: 0   COMMAND: "cpuhp/0"
[  616646337] [UN]  PID: 110    TASK: ffff8802301b1740  CPU: 2   COMMAND: "kaluad"
[  616609183] [UN]  PID: 109    TASK: ffff880230102e80  CPU: 3   COMMAND: "kmpath_rdacd"
[  594524204] [UN]  PID: 108    TASK: ffff880230101740  CPU: 1   COMMAND: "acpi_thermal_pm"
[  594182764] [UN]  PID: 107    TASK: ffff880230255d00  CPU: 0   COMMAND: "kthrotld"
[  134270773] [UN]  PID: 47     TASK: ffff88023fc4dd00  CPU: 1   COMMAND: "watchdogd"
[  134081248] [UN]  PID: 45     TASK: ffff88023fc4ae80  CPU: 3   COMMAND: "edac-poller"
[  134081248] [UN]  PID: 46     TASK: ffff88023fc4c5c0  CPU: 1   COMMAND: "devfreq_wq"
[  133661695] [UN]  PID: 44     TASK: ffff88023fc49740  CPU: 2   COMMAND: "md"
[   20366125] [IN]  PID: 35     TASK: ffff88018eedae80  CPU: 2   COMMAND: "khungtaskd"
[   20366125] [IN]  PID: 36     TASK: ffff88018eedc5c0  CPU: 1   COMMAND: "oom_reaper"
[   20366125] [UN]  PID: 37     TASK: ffff88018eeddd00  CPU: 1   COMMAND: "writeback"
[   20366125] [IN]  PID: 38     TASK: ffff88023fd78000  CPU: 2   COMMAND: "kcompactd0"
[   20366125] [IN]  PID: 39     TASK: ffff88023fd79740  CPU: 3   COMMAND: "ksmd"
[   20366125] [UN]  PID: 41     TASK: ffff88023fd7c5c0  CPU: 2   COMMAND: "crypto"
[   20366125] [UN]  PID: 42     TASK: ffff88023fd7dd00  CPU: 1   COMMAND: "kintegrityd"
[   20366125] [UN]  PID: 43     TASK: ffff88023fc48000  CPU: 3   COMMAND: "kblockd"
[   18537224] [UN]  PID: 33     TASK: ffff88018eed8000  CPU: 1   COMMAND: "netns"
[    4808153] [UN]  PID: 9      TASK: ffff88018ee0c5c0  CPU: 0   COMMAND: "rcu_bh"
[    4785179] [UN]  PID: 6      TASK: ffff88018ee08000  CPU: 0   COMMAND: "mm_percpu_wq"
[          0] [RU]  PID: 0      TASK: ffffffff81c10480  CPU: 0   COMMAND: "swapper/0"
[          0] [RU]  PID: 0      TASK: ffff88018ee11740  CPU: 1   COMMAND: "swapper/1"
[          0] [RU]  PID: 0      TASK: ffff88018ee12e80  CPU: 2   COMMAND: "swapper/2"
[          0] [RU]  PID: 0      TASK: ffff88018ee145c0  CPU: 3   COMMAND: "swapper/3"
crash> log
[   68.005884] Normal free:42276kB min:42468kB low:53084kB high:63700kB active_anon:4878580kB inactive_anon:8348kB active_file:20kB inactive_file:48kB unevictable:0kB writepending:8kB present:5242880kB managed:5110028kB mlocked:0kB kernel_stack:18400kB pagetables:42248kB bounce:0kB free_pcp:1700kB local_pcp:732kB free_cma:0kB
[   68.005884] 75 
[   68.005884] lowmem_reserve[]:
[   68.005884] 0b 
[   68.005885]  0
[   68.005885] f3 
[   68.005886]  0
[   68.005886] 90 
[   68.005886]  0
[   68.005887] 41 
[   68.005887]  0
[   68.005887]  0
[   68.005888] (U) 
[   68.005888] Node 0 
[   68.005889] 1*256kB 
[   68.005889] DMA: 
[   68.005889] (U) 
[   68.005890] 1*4kB 
[   68.005890] 0*512kB 
[   68.005891] (U) 
[   68.005891] 1*1024kB 
[   68.005891] 1*8kB 
[   68.005892] (U) 
[   68.005892] (U) 
[   68.005892] 1*2048kB 
[   68.005893] 1*16kB 
[   68.005893] (M) 
[   68.005893] (U) 
[   68.005894] 3*4096kB 
[   68.005894] 0*32kB 
[   68.005894] (M) 
[   68.005895] 2*64kB 
[   68.005895] = 15900kB
[   68.005895] (U) 
[   68.005895] Node 0 
[   68.005896] 1*128kB 
[   68.005896] DMA32: 
[   68.005897] (U) 
[   68.005897] 4*4kB 
[   68.005897] 1*256kB 
[   68.005898] (UM) 
[   68.005898] (U) 
[   68.005898] 3*8kB 
[   68.005899] 0*512kB 
[   68.005899] (UM) 
[   68.005899] 1*1024kB 
[   68.005900] 3*16kB 
[   68.005900] (U) 
[   68.005900] (U) 
[   68.005901] 1*2048kB 
[   68.005901] 4*32kB 
[   68.005901] (M) 
[   68.005901] (UM) 
[   68.005902] 3*4096kB 
[   68.005902] 2*64kB 
[   68.005902] (M) 
[   68.005903] (U) 
[   68.005903] = 15900kB
[   68.005903] 0*128kB 
[   68.005904] Node 0 
[   68.005904] 0*256kB 
[   68.005904] DMA32: 
[   68.005905] 5*512kB 
[   68.005905] 4*4kB 
[   68.005905] (M) 
[   68.005906] (UM) 
[   68.005906] 5*1024kB 
[   68.005906] 3*8kB 
[   68.005907] (UM) 
[   68.005907] (UM) 
[   68.005907] 2*2048kB 
[   68.005908] 3*16kB 
[   68.005908] (UM) 
[   68.005908] (U) 
[   68.005909] 8*4096kB 
[   68.005909] 4*32kB 
[   68.005909] (M) 
[   68.005910] (UM) 
[   68.005910] = 44888kB
[   68.005910] 2*64kB 
[   68.005911] Node 0 
[   68.005911] (U) 
[   68.005911] Normal: 
[   68.005912] 0*128kB 
[   68.005912] 702*4kB 
[   68.005912] 0*256kB 
[   68.005913] (UME) 
[   68.005913] 5*512kB 
[   68.005913] 411*8kB 
[   68.005914] (M) 
[   68.005914] (UME) 
[   68.005914] 5*1024kB 
[   68.005915] 186*16kB 
[   68.005915] (UM) 
[   68.005915] (UE) 
[   68.005916] 2*2048kB 
[   68.005916] 58*32kB 
[   68.005916] (UM) 
[   68.005917] (UME) 
[   68.005917] 8*4096kB 
[   68.005917] 70*64kB 
[   68.005918] (M) 
[   68.005918] (UME) 
[   68.005918] = 44888kB
[   68.005919] 65*128kB 
[   68.005919] Node 0 
[   68.005919] (UME) 
[   68.005919] Normal: 
[   68.005920] 22*256kB 
[   68.005920] 702*4kB 
[   68.005921] (UM) 
[   68.005921] (UME) 
[   68.005921] 10*512kB 
[   68.005922] 411*8kB 
[   68.005922] (M) 
[   68.005922] (UME) 
[   68.005923] 7*1024kB 
[   68.005923] 186*16kB 
[   68.005923] (UM) 
[   68.005924] (UE) 
[   68.005924] 0*2048kB 
[   68.005924] 58*32kB 
[   68.005925] 0*4096kB 
[   68.005925] (UME) 
[   68.005925] = 41648kB
[   68.005926] 70*64kB 
[   68.005926] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   68.005927] (UME) 
[   68.005927] 2205 total pagecache pages
[   68.005927] 65*128kB 
[   68.005928] 0 pages in swap cache
[   68.005928] (UME) 
[   68.005928] Swap cache stats: add 0, delete 0, find 0/0
[   68.005929] 22*256kB 
[   68.005929] Free swap  = 0kB
[   68.005929] (UM) 
[   68.005930] Total swap = 0kB
[   68.005930] 10*512kB 
[   68.005930] 2097045 pages RAM
[   68.005930] (M) 
[   68.005931] 0 pages HighMem/MovableOnly
[   68.005931] 7*1024kB 
[   68.005931] 53742 pages reserved
[   68.005932] (UM) 
[   68.005932] 0 pages cma reserved
[   68.005932] 0*2048kB 
[   68.005933] 0 pages hwpoisoned
[   68.005933] 0*4096kB = 41648kB
[   68.005934] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   68.005934] 2205 total pagecache pages
[   68.005935] 0 pages in swap cache
[   68.005935] Swap cache stats: add 0, delete 0, find 0/0
[   68.005935] Free swap  = 0kB
[   68.005936] Total swap = 0kB
[   68.005936] 2097045 pages RAM
[   68.005936] 0 pages HighMem/MovableOnly
[   68.005936] 53742 pages reserved
[   68.005937] 0 pages cma reserved
[   68.005937] 0 pages hwpoisoned
[   68.006581] Kernel panic - not syncing: softlockup: hung tasks
[   68.006582] CPU: 0 PID: 1046 Comm: idle-priority Tainted: G             L  4.14.0-rc6+ #308
[   68.006582] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   68.006582] Call Trace:
[   68.006583]  <IRQ>
[   68.006585]  dump_stack+0x63/0x87
[   68.006586]  panic+0xeb/0x245
[   68.006588]  watchdog_timer_fn+0x212/0x220
[   68.006589]  ? watchdog+0x30/0x30
[   68.006591]  __hrtimer_run_queues+0xe5/0x230
[   68.006593]  hrtimer_interrupt+0xa8/0x1a0
[   68.006595]  smp_apic_timer_interrupt+0x5f/0x130
[   68.006596]  apic_timer_interrupt+0x9d/0xb0
[   68.006596]  </IRQ>
[   68.006597] RIP: 0010:console_unlock+0x24e/0x4c0
[   68.006598] RSP: 0018:ffffc900016b76d8 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff10
[   68.006598] RAX: 0000000000000001 RBX: 0000000000000025 RCX: ffff88022f302000
[   68.006599] RDX: 0000000000000025 RSI: 0000000000000087 RDI: 0000000000000246
[   68.006599] RBP: ffffc900016b7718 R08: 0000000001080020 R09: 0000000080000000
[   68.006600] R10: 0000000000000e06 R11: 000000000000000c R12: 0000000000000400
[   68.006600] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000025
[   68.006602]  vprintk_emit+0x2f5/0x3a0
[   68.006603]  vprintk_default+0x29/0x50
[   68.006604]  vprintk_func+0x27/0x60
[   68.006605]  printk+0x58/0x6f
[   68.006606]  show_mem+0x1e/0xf0
[   68.006607]  dump_header+0xc0/0x234
[   68.006608]  oom_kill_process+0x21c/0x430
[   68.006609]  out_of_memory+0x114/0x4a0
[   68.006610]  __alloc_pages_slowpath+0x83c/0xb88
[   68.006612]  __alloc_pages_nodemask+0x26a/0x290
[   68.006613]  alloc_pages_vma+0x7f/0x180
[   68.006614]  __handle_mm_fault+0xcb0/0x1290
[   68.006616]  handle_mm_fault+0xcc/0x1e0
[   68.006617]  __do_page_fault+0x24a/0x4d0
[   68.006619]  do_page_fault+0x38/0x130
[   68.006620]  do_async_page_fault+0x22/0xd0
[   68.006621]  async_page_fault+0x22/0x30
[   68.006622] RIP: 0010:__clear_user+0x25/0x50
[   68.006622] RSP: 0018:ffffc900016b7d80 EFLAGS: 00010202
[   68.006623] RAX: 0000000000000000 RBX: ffffc900016b7e68 RCX: 0000000000000002
[   68.006623] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f40739ac000
[   68.006624] RBP: ffffc900016b7d80 R08: 0000000000100000 R09: 0000000000000000
[   68.006624] R10: 0000000000000198 R11: 0000000000000345 R12: 0000000000001000
[   68.006625] R13: ffffc900016b7e30 R14: 000000005c46a000 R15: 0000000000001000
[   68.006626]  clear_user+0x2b/0x40
[   68.006628]  iov_iter_zero+0x88/0x390
[   68.006630]  read_iter_zero+0x3d/0xa0
[   68.006631]  __vfs_read+0xec/0x160
[   68.006632]  vfs_read+0x8c/0x130
[   68.006632]  SyS_read+0x55/0xc0
[   68.006634]  do_syscall_64+0x67/0x1b0
[   68.006635]  entry_SYSCALL64_slow_path+0x25/0x25
[   68.006636] RIP: 0033:0x7f429743a7e0
[   68.006636] RSP: 002b:00007ffd32b02bf8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[   68.006637] RAX: ffffffffffffffda RBX: 0000000080003000 RCX: 00007f429743a7e0
[   68.006637] RDX: 0000000080003000 RSI: 00007f4017541010 RDI: 0000000000000003
[   68.006637] RBP: 00007f4017541010 R08: 0000000000000000 R09: 0000000000021000
[   68.006638] R10: 00007ffd32b02910 R11: 0000000000000246 R12: 00007f3e97544010
[   68.006638] R13: 0000000000000005 R14: 0000000000000003 R15: 0000000000000000
[   68.006749] Kernel Offset: disabled
[   78.017432] ---[ end Kernel panic - not syncing: softlockup: hung tasks
----------

While warn_alloc() messages are completely unreadable, what we should note are that

 (a) out_of_memory() => oom_kill_process() => dump_header() => show_mem() => printk()
     got stuck at console_unlock() despite this is schedulable context.

----------
2180:   for (;;) {
2181:           struct printk_log *msg;
2182:           size_t ext_len = 0;
2183:           size_t len;
2184:
2185:           printk_safe_enter_irqsave(flags);
2186:           raw_spin_lock(&logbuf_lock);
(...snipped...)
2228:           console_idx = log_next(console_idx);
2229:           console_seq++;
2230:           raw_spin_unlock(&logbuf_lock);
2231:
2232:           stop_critical_timings();        /* don't trace print latency */
2233:           call_console_drivers(ext_text, ext_len, text, len);
2234:           start_critical_timings();
2235:           printk_safe_exit_irqrestore(flags); // console_unlock+0x24e/0x4c0 is here.
2236:
2237:           if (do_cond_resched)
2238:                   cond_resched();
2239:   }
----------

 (b) Last run timestamps of all threads which are on CPU 0, including the "watchdog/0"
     watchdog thread, are no longer updated once the "idle-priority" thread started
     printk() flooding inside console_unlock(). I don't know why no longer updated,
     but is async_page_fault() somehow relevant?
     I don't know why "ksoftirqd/0" is in [RU], but due to use of netconsole for
     capturing kernel messages?

Anyway, depending on configuration/environment/stress, it is possible to trigger OOM
lockup caused by printk() versus oom_lock dependency. Thus, I do really want to prevent
other threads from appending to printk() buffer when some thread is printk()ing memory
related messages. And mutex_trylock(&oom_printk_lock) can do it more reliably than
__mutex_owner(&oom_lock) == NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
