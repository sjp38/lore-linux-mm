Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9506B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:34:07 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j32so153208858iod.15
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:34:07 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o2si3145819ioe.228.2017.07.26.09.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 09:34:06 -0700 (PDT)
Date: Wed, 26 Jul 2017 09:33:50 -0700
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] swap: fix oops during block io poll in swapin path
Message-ID: <20170726163349.GA51657@MacBook-Pro.dhcp.thefacebook.com>
References: <1501064703-5888-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1501064703-5888-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org
Cc: Tim Chen <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>, Jens Axboe <axboe@fb.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, Jul 26, 2017 at 07:25:03PM +0900, Tetsuo Handa wrote:
> When a thread is OOM-killed during swap_readpage() operation, an oops
> occurs because end_swap_bio_read() is calling wake_up_process() based on
> an assumption that the thread which called swap_readpage() is still alive.
> 
> ----------
> [  167.408563] Out of memory: Kill process 525 (polkitd) score 0 or sacrifice child
> [  167.410592] Killed process 525 (polkitd) total-vm:528128kB, anon-rss:0kB, file-rss:4kB, shmem-rss:0kB
> [  167.415666] oom_reaper: reaped process 525 (polkitd), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  167.460471] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
> [  167.462303] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev pcspkr vmw_balloon sg shpchp vmw_vmci parport_pc parport i2c_piix4 ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi vmwgfx ahci libahci drm_kms_helper ata_piix syscopyarea sysfillrect sysimgblt fb_sys_fops mptspi scsi_transport_spi ttm e1000 mptscsih drm mptbase i2c_core libata serio_raw
> [  167.476975] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.13.0-rc2-next-20170725 #129
> [  167.479002] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  167.481523] task: ffffffffb7c16500 task.stack: ffffffffb7c00000
> [  167.483240] RIP: 0010:__lock_acquire+0x151/0x12f0
> [  167.484808] RSP: 0018:ffffa01f39e03c50 EFLAGS: 00010002
> [  167.486659] RAX: 6b6b6b6b6b6b6b6b RBX: 0000000000000000 RCX: 0000000000000000
> [  167.488996] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffa01f350d0bb8
> [  167.491392] RBP: ffffa01f39e03d10 R08: ffffffffb709fefb R09: 0000000000000001
> [  167.493375] R10: 0000000000000000 R11: ffffffffb7c16500 R12: 0000000000000001
> [  167.495316] R13: 0000000000000000 R14: 0000000000000000 R15: ffffa01f350d0bb8
> [  167.497253] FS:  0000000000000000(0000) GS:ffffa01f39e00000(0000) knlGS:0000000000000000
> [  167.499384] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  167.501090] CR2: 00007f5ab0e3a9d0 CR3: 000000012dee5000 CR4: 00000000001606f0
> [  167.503124] Call Trace:
> [  167.504271]  <IRQ>
> [  167.505331]  ? free_debug_processing+0x25d/0x3b0
> [  167.506807]  ? __slab_free+0x9f/0x280
> [  167.508075]  ? __slab_free+0x9f/0x280
> [  167.509339]  lock_acquire+0x59/0x80
> [  167.510582]  ? lock_acquire+0x59/0x80
> [  167.511872]  ? try_to_wake_up+0x3b/0x410
> [  167.513133]  _raw_spin_lock_irqsave+0x3b/0x4f
> [  167.514449]  ? try_to_wake_up+0x3b/0x410
> [  167.515693]  try_to_wake_up+0x3b/0x410
> [  167.516857]  ? mempool_free_slab+0x12/0x20
> [  167.518068]  ? mempool_free+0x26/0x80
> [  167.519291]  wake_up_process+0x10/0x20
> [  167.520763]  end_swap_bio_read+0x6f/0xf0
> [  167.522229]  bio_endio+0x92/0xb0
> [  167.523324]  blk_update_request+0x88/0x270
> [  167.524642]  scsi_end_request+0x32/0x1c0
> [  167.525864]  scsi_io_completion+0x209/0x680
> [  167.527040]  scsi_finish_command+0xd4/0x120
> [  167.528210]  scsi_softirq_done+0x120/0x140
> [  167.529369]  __blk_mq_complete_request_remote+0xe/0x10
> [  167.530809]  flush_smp_call_function_queue+0x51/0x120
> [  167.532109]  generic_smp_call_function_single_interrupt+0xe/0x20
> [  167.533597]  smp_trace_call_function_single_interrupt+0x22/0x30
> [  167.535049]  smp_call_function_single_interrupt+0x9/0x10
> [  167.536391]  call_function_single_interrupt+0xa7/0xb0
> [  167.537821]  </IRQ>
> [  167.538670] RIP: 0010:native_safe_halt+0x6/0x10
> [  167.539895] RSP: 0018:ffffffffb7c03df8 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff04
> [  167.541602] RAX: ffffffffb7c16500 RBX: ffffffffb7c16500 RCX: 0000000000000000
> [  167.543201] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffb7c16500
> [  167.544894] RBP: ffffffffb7c03df8 R08: 0000000000000001 R09: 0000000000000000
> [  167.546497] R10: 0000000000000000 R11: 0000000000000000 R12: ffffffffb7e4fa20
> [  167.548023] R13: ffffffffb7c16500 R14: 0000000000000000 R15: 0000000000000000
> [  167.549561]  ? trace_hardirqs_on+0xd/0x10
> [  167.550593]  default_idle+0xe/0x20
> [  167.551521]  arch_cpu_idle+0xa/0x10
> [  167.552496]  default_idle_call+0x1e/0x30
> [  167.553783]  do_idle+0x187/0x200
> [  167.554875]  cpu_startup_entry+0x6e/0x70
> [  167.556023]  rest_init+0xd0/0xe0
> [  167.556921]  start_kernel+0x456/0x477
> [  167.557875]  ? early_idt_handler_array+0x120/0x120
> [  167.559018]  x86_64_start_reservations+0x24/0x26
> [  167.560104]  x86_64_start_kernel+0xf7/0x11a
> [  167.561131]  secondary_startup_64+0xa5/0xa5
> [  167.562169] Code: c3 49 81 3f 20 9e 0b b8 41 bc 00 00 00 00 44 0f 45 e2 83 fe 01 0f 87 62 ff ff ff 89 f0 49 8b 44 c7 08 48 85 c0 0f 84 52 ff ff ff <f0> ff 80 98 01 00 00 8b 3d 5a 49 c4 01 45 8b b3 18 0c 00 00 85
> [  167.565895] RIP: __lock_acquire+0x151/0x12f0 RSP: ffffa01f39e03c50
> [  167.567280] ---[ end trace 6c441db499169b1e ]---
> [  167.568400] Kernel panic - not syncing: Fatal exception in interrupt
> [  167.569907] Kernel Offset: 0x36000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> [  167.572108] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
> ----------
> 
> Fix it by holding a reference to the thread.

Ok, so the task is killed in the page fault retry time check, thanks!

Reviewed-by: Shaohua Li <shli@fb.com>

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Fixes: 23955622ff8d231b ("swap: add block io poll in swapin path")
> ---
>  mm/page_io.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index b6c4ac38..844c18c 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -22,6 +22,7 @@
>  #include <linux/frontswap.h>
>  #include <linux/blkdev.h>
>  #include <linux/uio.h>
> +#include <linux/sched/task.h>
>  #include <asm/pgtable.h>
>  
>  static struct bio *get_swap_bio(gfp_t gfp_flags,
> @@ -136,6 +137,7 @@ static void end_swap_bio_read(struct bio *bio)
>  	WRITE_ONCE(bio->bi_private, NULL);
>  	bio_put(bio);
>  	wake_up_process(waiter);
> +	put_task_struct(waiter);
>  }
>  
>  int generic_swapfile_activate(struct swap_info_struct *sis,
> @@ -378,6 +380,7 @@ int swap_readpage(struct page *page, bool do_poll)
>  		goto out;
>  	}
>  	bdev = bio->bi_bdev;
> +	get_task_struct(current);
>  	bio->bi_private = current;
>  	bio_set_op_attrs(bio, REQ_OP_READ, 0);
>  	count_vm_event(PSWPIN);
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
