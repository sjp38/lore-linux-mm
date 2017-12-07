Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9DB6B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 02:20:58 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id s10so3401014oth.14
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 23:20:58 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a37si1712448oth.219.2017.12.06.23.20.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 23:20:56 -0800 (PST)
Message-Id: <201712070720.vB77KlBQ009754@www262.sakura.ne.jp>
Subject: Re: Multiple =?ISO-2022-JP?B?b29tX3JlYXBlciBCVUdzOiB1bm1hcF9wYWdlX3Jhbmdl?=
 =?ISO-2022-JP?B?IHJhY2luZyB3aXRoIGV4aXRfbW1hcA==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 07 Dec 2017 16:20:47 +0900
References: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com> <20171206090019.GE16386@dhcp22.suse.cz>
In-Reply-To: <20171206090019.GE16386@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Tue 05-12-17 23:48:21, David Rientjes wrote:
> [...]
> > I think this argues to do MMF_REAPING-style behavior at the beginning of 
> > exit_mmap() and avoid reaping all together once we have reached that 
> > point.  There are no more users of the mm and we are in the process of 
> > tearing it down, I'm not sure that the oom reaper should be in the 
> > business with trying to interfere with that.  Or are there actual bug 
> > reports where an oom victim gets wedged while in exit_mmap() prior to 
> > releasing its memory?
> 
> Something like that seem to work indeed. But we should better understand
> what is going on here before adding new oom reaper specific kludges. So
> let's focus on getting more information from your crashes first.

As of 968edbd93c0cbb40ab48aca972392d377713a0c3 on linux.git and using reproducer
shown below, I got use after free bug which crashes the OOM reaper.

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
			 MAP_ANONYMOUS | MAP_PRIVATE, EOF, 0);
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
		     MAP_ANONYMOUS | MAP_PRIVATE, EOF, 0);
	for (i = 0; i < NUMTHREADS; i++)
		if (clone(memory_eater, stack + (i + 1) * STACKSIZE,
			  /*CLONE_THREAD | CLONE_SIGHAND | */CLONE_VM | CLONE_FS |
			  CLONE_FILES, NULL) == -1)
			break;
	sleep(1);
	close(pipe_fd[1]);
	pause();
	return 0;
}
----------

----------
[  100.740891] Out of memory: Kill process 1297 (a.out) score 668 or sacrifice child
[  100.746289] Killed process 1297 (a.out) total-vm:16781904kB, anon-rss:2124172kB, file-rss:0kB, shmem-rss:0kB
[  113.130943] ==================================================================
[  113.136627] BUG: KASAN: use-after-free in __oom_reap_task_mm+0x1ce/0x2a0
[  113.141811] Read of size 8 at addr ffff880115144010 by task oom_reaper/17
[  113.147505] 
[  113.152112] CPU: 0 PID: 17 Comm: oom_reaper Not tainted 4.15.0-rc2+ #335
[  113.157491] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  113.164088] Call Trace:
[  113.168691]  dump_stack+0x7d/0xc0
[  113.173176]  print_address_description+0xc2/0x250
[  113.178114]  kasan_report+0x24a/0x360
[  113.182736]  ? __oom_reap_task_mm+0x1ce/0x2a0
[  113.187562]  __oom_reap_task_mm+0x1ce/0x2a0
[  113.192339]  ? rcu_read_unlock+0x60/0x60
[  113.196957]  ? find_held_lock+0xff/0x130
[  113.201536]  oom_reaper+0x108/0x240
[  113.205939]  ? wake_oom_reaper.part.16+0x60/0x60
[  113.210575]  ? pci_mmcfg_check_reserved+0xb0/0xb0
[  113.215063]  ? wait_woken+0x100/0x100
[  113.219332]  ? mark_held_locks+0x1b/0xb0
[  113.223478]  ? _raw_spin_unlock_irqrestore+0x2d/0x50
[  113.227797]  kthread+0x1c0/0x210
[  113.231499]  ? wake_oom_reaper.part.16+0x60/0x60
[  113.235449]  ? kthread_create_worker_on_cpu+0xc0/0xc0
[  113.239624]  ret_from_fork+0x24/0x30
[  113.244269] 
[  113.247570] Allocated by task 1296:
[  113.251019]  kasan_kmalloc+0xa0/0xd0
[  113.254414]  kmem_cache_alloc+0xf4/0x1e0
[  113.258214]  copy_process.part.42+0x29a3/0x30c0
[  113.261769]  _do_fork+0x16e/0x700
[  113.264792]  do_syscall_64+0xe4/0x390
[  113.267801]  return_from_SYSCALL_64+0x0/0x75
[  113.271002] 
[  113.273394] Freed by task 1377:
[  113.276211]  kasan_slab_free+0x71/0xc0
[  113.279093]  kmem_cache_free+0xaf/0x1e0
[  113.281974]  remove_vma+0x9d/0xb0
[  113.284734]  exit_mmap+0x179/0x250
[  113.287651]  mmput+0x7d/0x1b0
[  113.290456]  do_exit+0x408/0x1290
[  113.293268]  do_group_exit+0x84/0x140
[  113.296109]  get_signal+0x291/0x9b0
[  113.298915]  do_signal+0x8e/0xa70
[  113.301637]  exit_to_usermode_loop+0x71/0xb0
[  113.304632]  do_syscall_64+0x343/0x390
[  113.307349]  return_from_SYSCALL_64+0x0/0x75
[  113.310205] 
[  113.312388] The buggy address belongs to the object at ffff880115144008
[  113.312388]  which belongs to the cache vm_area_struct of size 200
[  113.319286] The buggy address is located 8 bytes inside of
[  113.319286]  200-byte region [ffff880115144008, ffff8801151440d0)
[  113.325766] The buggy address belongs to the page:
[  113.328735] page:0000000057390752 count:1 mapcount:0 mapping:          (null) index:0x0 compound_mapcount: 0
[  113.332958] flags: 0x2fffff80008100(slab|head)
[  113.335835] raw: 002fffff80008100 0000000000000000 0000000000000000 00000001000e000e
[  113.339567] raw: ffffea0002ec44a0 ffffea000422d7a0 ffff8801170f13c0 0000000000000000
[  113.343304] page dumped because: kasan: bad access detected
[  113.346506] 
[  113.348706] Memory state around the buggy address:
[  113.351974]  ffff880115143f00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  113.355815]  ffff880115143f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  113.359479] >ffff880115144000: fc fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[  113.363128]                          ^
[  113.365969]  ffff880115144080: fb fb fb fb fb fb fb fb fb fb fc fc fc fc fc fc
[  113.369672]  ffff880115144100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  113.373402] ==================================================================
[  113.377127] Disabling lock debugging due to kernel taint
[  113.380915] ------------[ cut here ]------------
[  113.383920] kernel BUG at mm/memory.c:1502!
[  113.386829] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
[  113.390214] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 coretemp ip6t_REJECT nf_reject_ipv6 xt_conntrack vmw_balloon pcspkr ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack sg iptable_mangle iptable_raw vmw_vmci shpchp i2c_piix4 ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod serio_raw pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi ahci scsi_transport_spi drm libahci mptscsih ata_piix e1000 i2c_core mptbase libata
[  113.416884] CPU: 0 PID: 17 Comm: oom_reaper Tainted: G    B            4.15.0-rc2+ #335
[  113.421312] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  113.426490] RIP: 0010:unmap_page_range+0xd8b/0xdb0
[  113.430267] RSP: 0018:ffff88011254fbc8 EFLAGS: 00010282
[  113.434113] RAX: 0000000000000000 RBX: 1ffff100224a9fa8 RCX: 00007f8e4c99e000
[  113.438504] RDX: ffff880115144cf8 RSI: 1ffff100224a9f94 RDI: ffff88011254fd60
[  113.442915] RBP: ffff88011082e340 R08: 0000000000000000 R09: 0000000000000000
[  113.447315] R10: ffffed0021d9cc00 R11: fffffbfff14eaeb4 R12: ffff880115144680
[  113.451730] R13: ffff88010bc745c0 R14: ffff88011082e3f0 R15: ffff880115144688
[  113.456150] FS:  0000000000000000(0000) GS:ffff880117600000(0000) knlGS:0000000000000000
[  113.460905] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  113.465052] CR2: 00007fca30eb0000 CR3: 000000011f214003 CR4: 00000000000606f0
[  113.469633] Call Trace:
[  113.473028]  ? release_pages+0x46a/0x580
[  113.476861]  ? __put_compound_page+0x60/0x60
[  113.480721]  ? lru_add_drain_cpu+0xa2/0x1a0
[  113.484569]  ? lru_add_drain+0xc/0x10
[  113.488257]  ? free_pages_and_swap_cache+0x93/0x100
[  113.492288]  ? vm_normal_page_pmd+0x160/0x160
[  113.496155]  ? tlb_flush_mmu_free+0x73/0x80
[  113.499954]  ? arch_tlb_finish_mmu+0x68/0xa0
[  113.503761]  __oom_reap_task_mm+0x1c6/0x2a0
[  113.507580]  ? rcu_read_unlock+0x60/0x60
[  113.511259]  ? find_held_lock+0xff/0x130
[  113.514925]  oom_reaper+0x108/0x240
[  113.518423]  ? wake_oom_reaper.part.16+0x60/0x60
[  113.522199]  ? pci_mmcfg_check_reserved+0xb0/0xb0
[  113.525933]  ? wait_woken+0x100/0x100
[  113.529393]  ? mark_held_locks+0x1b/0xb0
[  113.532923]  ? _raw_spin_unlock_irqrestore+0x2d/0x50
[  113.536738]  kthread+0x1c0/0x210
[  113.540043]  ? wake_oom_reaper.part.16+0x60/0x60
[  113.543673]  ? kthread_create_worker_on_cpu+0xc0/0xc0
[  113.547440]  ret_from_fork+0x24/0x30
[  113.550848] Code: 24 10 e8 29 75 01 00 e9 12 fd ff ff 48 8b bc 24 b0 00 00 00 e8 c7 74 01 00 e9 de f3 ff ff 48 89 cf e8 ba de ff ff e9 78 fc ff ff <0f> 0b 0f 0b 48 8b 7c 24 18 e8 47 75 01 00 e9 c2 fc ff ff e8 9d 
[  113.561566] RIP: unmap_page_range+0xd8b/0xdb0 RSP: ffff88011254fbc8
[  113.565852] ---[ end trace 80b64d1cae13d405 ]---

mmput+0x7d/0x1b0:
__mmput at kernel/fork.c:925
 (inlined by) mmput at kernel/fork.c:945

exit_mmap+0x179/0x250:
exit_mmap at mm/mmap.c:3046

remove_vma+0x9d/0xb0:
remove_vma at mm/mmap.c:178

kmem_cache_free+0xaf/0x1e0:
slab_free at mm/slub.c:2973
 (inlined by) kmem_cache_free at mm/slub.c:2990
----------

What we overlooked is the fact that "it is not always the process which
got ->signal->oom_mm set, it is any thread which called mmput() which
invoked __mmput() path". Therefore, below patch fixes oops in my case.
If some unrelated kernel thread was holding mm_users ref, it is possible
that we miss down_write()/up_write() synchronization.

----------
diff --git a/mm/mmap.c b/mm/mmap.c
index a4d5468..2dd813e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3020,7 +3020,7 @@ void exit_mmap(struct mm_struct *mm)
 	unmap_vmas(&tlb, vma, 0, -1);
 
 	set_bit(MMF_OOM_SKIP, &mm->flags);
-	if (unlikely(tsk_is_oom_victim(current))) {
+	if (1) {
 		/*
 		 * Wait for oom_reap_task() to stop working on this
 		 * mm. Because MMF_OOM_SKIP is already set before
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
