Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1414A6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 06:11:38 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so101684737pab.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 03:11:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o129si21791672pfo.19.2016.02.16.03.11.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 03:11:36 -0800 (PST)
Subject: Re: [PATCH 5/5] mm, oom_reaper: implement OOM victims queuing
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160204145357.GE14425@dhcp22.suse.cz>
	<201602061454.GDG43774.LSHtOOMFOFVJQF@I-love.SAKURA.ne.jp>
	<20160206083757.GB25220@dhcp22.suse.cz>
	<201602070033.GFC13307.MOJQtFHOFOVLFS@I-love.SAKURA.ne.jp>
	<20160215201535.GB9223@dhcp22.suse.cz>
In-Reply-To: <20160215201535.GB9223@dhcp22.suse.cz>
Message-Id: <201602162011.ECG52697.VOLJFtOQHFMSFO@I-love.SAKURA.ne.jp>
Date: Tue, 16 Feb 2016 20:11:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Unless we are under global OOM then this doesn't matter much because the
> allocation request should succeed at some point in time and memcg
> charges are bypassed for tasks with pending fatal signals. So we can
> make a forward progress.

Hmm, then I wonder how memcg OOM livelock occurs. Anyway, OK for now.

But current OOM reaper forgot a protection for list item "double add" bug.
Precisely speaking, this is not a OOM reaper's bug.

----------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

static int file_writer(void)
{
	static char buffer[4096] = { }; 
	const int fd = open("/tmp/file", O_WRONLY | O_CREAT | O_APPEND, 0600);
	while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
	return 0;
}

static int memory_consumer(void)
{
	const int fd = open("/dev/zero", O_RDONLY);
	unsigned long size;
	char *buf = NULL;
	sleep(1);
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
	for (i = 0; i < 1024; i++)
		if (fork() == 0) {
			file_writer();
			_exit(0);
		}
	memory_consumer();
	while (1)
		pause();
}
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160216.txt.xz .
----------
[  140.758667] a.out invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0, oom_score_adj=0
[  140.760706] a.out cpuset=/ mems_allowed=0
(...snipped...)
[  140.860676] Out of memory (oom_kill_allocating_task): Kill process 10595 (a.out) score 0 or sacrifice child
[  140.864883] Killed process 10596 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  140.868483] oom_reaper: reaped process 10596 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0lB
(...snipped...)
** 3 printk messages dropped ** [  206.416481] Out of memory (oom_kill_allocating_task): Kill process 10595 (a.out) score 0 or sacrifice child
** 2 printk messages dropped ** [  206.418908] Killed process 10600 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
** 2 printk messages dropped ** [  206.421956] Out of memory (oom_kill_allocating_task): Kill process 10595 (a.out) score 0 or sacrifice child
** 2 printk messages dropped ** [  206.424293] INFO: rcu_sched self-detected stall on CPU
** 3 printk messages dropped ** [  206.424300] oom_reaper      R  running task        0    33      2 0x00000008
[  206.424302]  ffff88007cd35900 000000000b04b66b ffff88007fcc3dd0 ffffffff8109db68
** 1 printk messages dropped ** [  206.424304]  ffffffff810a0bc4 0000000000000003 ffff88007fcc3e18 ffffffff8113e092
** 4 printk messages dropped ** [  206.424316]  [<ffffffff8113e092>] rcu_dump_cpu_stacks+0x73/0x94
** 3 printk messages dropped ** [  206.424322]  [<ffffffff810e2d44>] update_process_times+0x34/0x60
** 2 printk messages dropped ** [  206.424327]  [<ffffffff810f2a50>] ? tick_sched_handle.isra.20+0x40/0x40
** 4 printk messages dropped ** [  206.424334]  [<ffffffff81049598>] smp_apic_timer_interrupt+0x38/0x50
** 3 printk messages dropped ** [  206.424342]  [<ffffffff810d0f9a>] vprintk_default+0x1a/0x20
** 2 printk messages dropped ** [  206.424346]  [<ffffffff81708291>] ? _raw_spin_unlock_irqrestore+0x31/0x60
** 5 printk messages dropped ** [  206.424355]  [<ffffffff81090950>] ? kthread_create_on_node+0x230/0x230
** 2 printk messages dropped ** [  206.431196] Out of memory (oom_kill_allocating_task): Kill process 10595 (a.out) score 0 or sacrifice child
** 3 printk messages dropped ** [  206.434491] Out of memory (oom_kill_allocating_task): Kill process 10595 (a.out) score 0 or sacrifice child
** 1 printk messages dropped ** [  206.436152] Out of memory (oom_kill_allocating_task): Kill process 10595 (a.out) score 0 or sacrifice child
** 3 printk messages dropped ** [  206.439359] Out of memory (oom_kill_allocating_task): Kill process 10595 (a.out) score 0 or sacrifice child
(...snipped...)
[  312.387913] general protection fault: 0000 [#1] SMP 
[  312.387943] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_security iptable_raw iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel glue_helper lrw gf128mul ablk_helper cryptd ppdev vmw_balloon pcspkr sg parport_pc shpchp parport i2c_piix4 vmw_vmci ip_tables sd_mod ata_generic pata_acpi crc32c_intel serio_raw mptspi scsi_transport_spi mptscsih vmwgfx mptbase drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ahci ttm libahci drm ata_piix e1000 libata i2c_core
[  312.387945] CPU: 0 PID: 33 Comm: oom_reaper Not tainted 4.5.0-rc4-next-20160216 #305
[  312.387946] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  312.387947] task: ffff88007cd35900 ti: ffff88007cdf0000 task.ti: ffff88007cdf0000
[  312.387953] RIP: 0010:[<ffffffff8114425c>]  [<ffffffff8114425c>] oom_reaper+0x9c/0x1e0
[  312.387954] RSP: 0018:ffff88007cdf3e00  EFLAGS: 00010287
[  312.387954] RAX: dead000000000200 RBX: ffff8800621bac80 RCX: 0000000000000001
[  312.387955] RDX: dead000000000100 RSI: 0000000000000000 RDI: ffffffff81c4cac0
[  312.387955] RBP: ffff88007cdf3e60 R08: 0000000000000001 R09: 0000000000000000
[  312.387956] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88007cd35900
[  312.387956] R13: 0000000000000001 R14: ffff88007cdf3e20 R15: ffff8800621bbe50
[  312.387957] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[  312.387958] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  312.387958] CR2: 00007f6d8eaa5000 CR3: 000000006361e000 CR4: 00000000001406f0
[  312.387988] Stack:
[  312.387990]  ffff88007cd35900 ffffffff00000000 ffff88007cd35900 ffffffff810b6100
[  312.387991]  ffff88007cdf3e20 ffff88007cdf3e20 000000000b04b66b ffff88007cd9f340
[  312.387992]  0000000000000000 ffffffff811441c0 ffffffff81c4e300 0000000000000000
[  312.387992] Call Trace:
[  312.387998]  [<ffffffff810b6100>] ? wait_woken+0x90/0x90
[  312.388003]  [<ffffffff811441c0>] ? __oom_reap_task+0x220/0x220
[  312.388005]  [<ffffffff81090a49>] kthread+0xf9/0x110
[  312.388011]  [<ffffffff81708c32>] ret_from_fork+0x22/0x50
[  312.388012]  [<ffffffff81090950>] ? kthread_create_on_node+0x230/0x230
[  312.388025] Code: cb c4 81 0f 84 a0 00 00 00 4c 8b 3d bf 88 b0 00 48 c7 c7 c0 ca c4 81 41 bd 01 00 00 00 49 8b 47 08 49 8b 17 49 8d 9f 30 ee ff ff <48> 89 42 08 48 89 10 48 b8 00 01 00 00 00 00 ad de 49 89 07 66 
[  312.388027] RIP  [<ffffffff8114425c>] oom_reaper+0x9c/0x1e0
[  312.388028]  RSP <ffff88007cdf3e00>
[  312.388029] ---[ end trace ea62d9784868759a ]---
[  312.388031] BUG: sleeping function called from invalid context at include/linux/sched.h:2819
[  312.388032] in_atomic(): 1, irqs_disabled(): 0, pid: 33, name: oom_reaper
[  312.388033] INFO: lockdep is turned off.
[  312.388034] CPU: 0 PID: 33 Comm: oom_reaper Tainted: G      D         4.5.0-rc4-next-20160216 #305
[  312.388035] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  312.388036]  0000000000000286 000000000b04b66b ffff88007cdf3be0 ffffffff8139e83d
[  312.388037]  ffff88007cd35900 ffffffff819b931a ffff88007cdf3c08 ffffffff810961eb
[  312.388038]  ffffffff819b931a 0000000000000b03 0000000000000000 ffff88007cdf3c30
[  312.388038] Call Trace:
[  312.388043]  [<ffffffff8139e83d>] dump_stack+0x85/0xc8
[  312.388046]  [<ffffffff810961eb>] ___might_sleep+0x14b/0x240
[  312.388047]  [<ffffffff81096324>] __might_sleep+0x44/0x80
[  312.388050]  [<ffffffff8107f7ee>] exit_signals+0x2e/0x150
[  312.388051]  [<ffffffff81091fa1>] ? blocking_notifier_call_chain+0x11/0x20
[  312.388054]  [<ffffffff81072e32>] do_exit+0xc2/0xb50
[  312.388057]  [<ffffffff8101893c>] oops_end+0x9c/0xd0
[  312.388058]  [<ffffffff81018ba6>] die+0x46/0x60
[  312.388059]  [<ffffffff8101602b>] do_general_protection+0xdb/0x1b0
[  312.388061]  [<ffffffff8170a4f8>] general_protection+0x28/0x30
[  312.388064]  [<ffffffff8114425c>] ? oom_reaper+0x9c/0x1e0
[  312.388066]  [<ffffffff810b6100>] ? wait_woken+0x90/0x90
[  312.388067]  [<ffffffff811441c0>] ? __oom_reap_task+0x220/0x220
[  312.388068]  [<ffffffff81090a49>] kthread+0xf9/0x110
[  312.388071]  [<ffffffff81708c32>] ret_from_fork+0x22/0x50
[  312.388072]  [<ffffffff81090950>] ? kthread_create_on_node+0x230/0x230
[  312.388075] note: oom_reaper[33] exited with preempt_count 1
----------

For oom_kill_allocating_task = 1 case (despite the name, it still tries to kill
children first), the OOM killer does not wait for OOM victim to clear TIF_MEMDIE
because select_bad_process() is not called. Therefore, if an OOM victim fails to
terminate because the OOM reaper failed to reap enough memory, the kernel is
flooded with OOM killer messages trying to kill that stuck victim (with OOM
reaper lockup due to list corruption).

Adding an OOM victim which was already added to oom_reaper_list is wrong.
What should we do here?

(Choice 1) Make sure that TIF_MEMDIE thread is not chosen as an OOM victim.
           This will avoid list corruption, but choosing other !TIF_MEMDIE
           threads sharing the TIF_MEMDIE thread's mm and adding them to
           oom_reaper_list does not make sense.

(Choice 2) Make sure that any process which includes a TIF_MEMDIE thread is
           not chosen as an OOM victim. But choosing other processes without
           TIF_MEMDIE thread sharing the TIF_MEMDIE thread's mm and adding
           them to oom_reaper_list does not make sense. A mm should be added
           to oom_reaper_list up to only once.

(Choice 3) Make sure that any process which uses a mm which was added to
           oom_reaper_list is not chosen as an OOM victim. This would mean
           replacing test_tsk_thread_flag(task, TIF_MEMDIE) with
           (mm = task->mm, mm && test_bit(MMF_OOM_VICTIM, &mm->flags))
           in OOM killer and replacing test_thread_flag(TIF_MEMDIE) with
           (current->mm && test_bit(MMF_OOM_VICTIM, &current->mm->flags) &&
            (fatal_signal_pending(current) || (current->flags & PF_EXITING)))
           in ALLOC_NO_WATERMARKS check.

(Choice 4) Call select_bad_process() for oom_kill_allocating_task = 1 case.

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7653055..5e3e2f2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -880,15 +880,6 @@ bool out_of_memory(struct oom_control *oc)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint, NULL);
 
-	if (sysctl_oom_kill_allocating_task && current->mm &&
-	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
-	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-		get_task_struct(current);
-		oom_kill_process(oc, current, 0, totalpages, NULL,
-				 "Out of memory (oom_kill_allocating_task)");
-		return true;
-	}
-
 	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p && !is_sysrq_oom(oc)) {
@@ -896,8 +887,16 @@ bool out_of_memory(struct oom_control *oc)
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (p && p != (void *)-1UL) {
-		oom_kill_process(oc, p, points, totalpages, NULL,
-				 "Out of memory");
+		if (sysctl_oom_kill_allocating_task && current->mm &&
+		    !oom_unkillable_task(current, NULL, oc->nodemask) &&
+		    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+			put_task_struct(p);
+			get_task_struct(current);
+			oom_kill_process(oc, current, 0, totalpages, NULL,
+					 "Out of memory (oom_kill_allocating_task)");
+		} else
+			oom_kill_process(oc, p, points, totalpages, NULL,
+					 "Out of memory");
 		/*
 		 * Give the killed process a good chance to exit before trying
 		 * to allocate memory again.
----------

(Choice 5) Any other ideas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
