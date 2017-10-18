Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8EAD6B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:54:27 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g125so4297803oib.13
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:54:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e64si3236339oia.360.2017.10.18.03.54.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 03:54:25 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
	<20170915143732.GA8397@cmpxchg.org>
	<201709161312.CAJ73470.FSOHFMVJLFQOOt@I-love.SAKURA.ne.jp>
	<201710112014.CCJ78649.tOMFSHOFVLOJFQ@I-love.SAKURA.ne.jp>
In-Reply-To: <201710112014.CCJ78649.tOMFSHOFVLOJFQ@I-love.SAKURA.ne.jp>
Message-Id: <201710181954.FHH51594.MtFOFLOQFSOHVJ@I-love.SAKURA.ne.jp>
Date: Wed, 18 Oct 2017 19:54:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, yuwang668899@gmail.com, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com

Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Johannes Weiner wrote:
> > > On Fri, Sep 15, 2017 at 05:58:49PM +0800, wang Yu wrote:
> > > > From: "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>
> > > > 
> > > > I found a softlockup when running some stress testcase in 4.9.x,
> > > > but i think the mainline have the same problem.
> > > > 
> > > > call trace:
> > > > [365724.502896] NMI watchdog: BUG: soft lockup - CPU#31 stuck for 22s!
> > > > [jbd2/sda3-8:1164]
> > > 
> > > We've started seeing the same thing on 4.11. Tons and tons of
> > > allocation stall warnings followed by the soft lock-ups.
> > 
> > Forgot to comment. Since you are able to reproduce the problem (aren't you?),
> > please try setting 1 to /proc/sys/kernel/softlockup_all_cpu_backtrace so that
> > we can know what other CPUs are doing. It does not need to patch kernels.
> > 
> Johannes, were you able to reproduce the problem? I'd like to continue
> warn_alloc() serialization patch if you can confirm that uncontrolled
> flooding of allocation stall warning can lead to soft lockups.
> 

I hit soft lockup when I was examining why fork() is failing when virtio_balloon
driver has a lot of pages to free and VIRTIO_BALLOON_F_DEFLATE_ON_OOM is
negotiated using a debug patch (part of the patch is shown below).

----------------------------------------
diff --git a/kernel/fork.c b/kernel/fork.c
index 07cc743..e806695 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1985,6 +1985,7 @@ static __latent_entropy struct task_struct *copy_process(
 	put_task_stack(p);
 	free_task(p);
 fork_out:
+	WARN_ON(1);
 	return ERR_PTR(retval);
 }
 
diff --git a/mm/util.c b/mm/util.c
index 34e57fae..ce458de 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -675,6 +675,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 error:
 	vm_unacct_memory(pages);
 
+	WARN_ON(1);
 	return -ENOMEM;
 }
 
----------------------------------------

It turned out that the cause of failing fork() was failing __vm_enough_memory()
because /proc/sys/vm/overcommit_memory was set to 0. Although virtio_balloon
driver was ready to release pages if asked via virtballoon_oom_notify() from
out_of_memory(), __vm_enough_memory() was not able to take such pages into
account. As a result, operations which need to use fork() (e.g. login via ssh)
and operations which calls vm_enough_memory() (e.g. mmap()) were failing without
calling out_of_memory().

But what I want to say here is that we should serialize warn_alloc() for reporting
allocation stalls because the essence is the same for warn_alloc() and WARN_ON(1)
above. Although warn_alloc() uses ratelimiting, both cases allow unbounded number
of threads to call printk() concurrently under memory pressure.

Since offloading printk() to the kernel thread is not yet available, and writing
to printk() buffer faster than the kernel thread can write to consoles (even if
it became possible) results in loss of messages, we should try to avoid appending
to printk() buffer when printk() is called from the same location in order to
reduce possibility of hitting soft lockup and getting unreadably-jumbled messages.
It is ridiculous to keep depending on not yet available printk() offloading.
printk() does want careful coordination from users in order to deliver important
messages reliably. Calling printk() uncontrolledly is not offered for free.

Complete log is http://I-love.SAKURA.ne.jp/tmp/20171018-softlockup.log.xz .
----------------------------------------
[   63.721863] ------------[ cut here ]------------
[   63.722467] WARNING: CPU: 1 PID: 852 at mm/util.c:678 __vm_enough_memory+0x11f/0x130
[   63.723100] Modules linked in: netconsole ip_set nfnetlink snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hwdep crct10dif_pclmul crc32_pclmul snd_hda_core snd_seq ghash_clmulni_intel snd_seq_device ppdev snd_pcm aesni_intel crypto_simd cryptd glue_helper snd_timer snd joydev sg virtio_balloon pcspkr parport_pc soundcore i2c_piix4 parport xfs libcrc32c sr_mod cdrom ata_generic pata_acpi qxl drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm virtio_blk drm virtio_net virtio_console ata_piix crc32c_intel serio_raw libata virtio_pci i2c_core virtio_ring virtio floppy
[   63.726200] CPU: 1 PID: 852 Comm: sshd Tainted: G        W       4.14.0-rc5+ #303
[   63.726831] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   63.727498] task: ffff8e8cf07b8000 task.stack: ffff9ad48179c000
[   63.728282] RIP: 0010:__vm_enough_memory+0x11f/0x130
[   63.728964] RSP: 0018:ffff9ad48179fd58 EFLAGS: 00010257
[   63.729621] RAX: 000000000001fc2c RBX: fffffffffffffffc RCX: 00000000000007ca
[   63.730281] RDX: fffffffffffff836 RSI: fffffffffffffffc RDI: ffffffff914a4fc0
[   63.730924] RBP: ffff9ad48179fd70 R08: ffffffff9152f530 R09: ffff9ad48179fcfc
[   63.731582] R10: 0000000000000020 R11: ffff8e8cf61142a8 R12: 0000000000000001
[   63.732250] R13: ffff8e8cd6b47800 R14: ffff8e8cf6ebdc80 R15: 0000000000000004
[   63.732903] FS:  00007feb5d71f8c0(0000) GS:ffff8e8cffc80000(0000) knlGS:0000000000000000
[   63.733579] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   63.734258] CR2: 00007feb5aaf38c0 CR3: 0000000230ab9000 CR4: 00000000001406e0
[   63.734936] Call Trace:
[   63.735623]  security_vm_enough_memory_mm+0x53/0x60
[   63.736310]  copy_process.part.34+0xd7d/0x1d60
[   63.736976]  _do_fork+0xed/0x390
[   63.737653]  SyS_clone+0x19/0x20
[   63.738359]  do_syscall_64+0x67/0x1b0
[   63.739030]  entry_SYSCALL64_slow_path+0x25/0x25
[   63.739726] RIP: 0033:0x7feb5ab39291
[   63.740390] RSP: 002b:00007fff7ff715c0 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
(... 1000+ mostly "WARNING: CPU: 2 PID: 417 at mm/util.c:678 __vm_enough_memory+0x11f/0x130" lines snipped...)
[   88.005016] watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [sshd:852]
[   88.005017] Modules linked in: netconsole ip_set nfnetlink snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hwdep crct10dif_pclmul crc32_pclmul snd_hda_core snd_seq ghash_clmulni_intel snd_seq_device ppdev snd_pcm aesni_intel crypto_simd cryptd glue_helper snd_timer snd joydev sg virtio_balloon pcspkr parport_pc soundcore i2c_piix4 parport xfs libcrc32c sr_mod cdrom ata_generic pata_acpi qxl drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm virtio_blk drm virtio_net virtio_console ata_piix crc32c_intel serio_raw libata virtio_pci i2c_core virtio_ring virtio floppy
[   88.005036] CPU: 1 PID: 852 Comm: sshd Tainted: G        W       4.14.0-rc5+ #303
[   88.005036] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   88.005037] task: ffff8e8cf07b8000 task.stack: ffff9ad48179c000
[   88.005041] RIP: 0010:console_unlock+0x24e/0x4c0
[   88.005042] RSP: 0018:ffff9ad48179f810 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff10
[   88.005043] RAX: 0000000000000001 RBX: 0000000000000051 RCX: ffff8e8cee406000
[   88.005043] RDX: 0000000000000051 RSI: 0000000000000087 RDI: 0000000000000246
[   88.005044] RBP: ffff9ad48179f850 R08: 0000000001080020 R09: 00007174c0000000
[   88.005044] R10: 0000000000000c06 R11: 000000000000000c R12: 0000000000000400
[   88.005045] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000051
[   88.005050] FS:  00007feb5d71f8c0(0000) GS:ffff8e8cffc80000(0000) knlGS:0000000000000000
[   88.005050] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   88.005051] CR2: 00007feb5aaf38c0 CR3: 0000000230ab9000 CR4: 00000000001406e0
[   88.005054] Call Trace:
[   88.005058]  vprintk_emit+0x2f5/0x3a0
[   88.005061]  ? entry_SYSCALL64_slow_path+0x25/0x25
[   88.005061]  vprintk_default+0x29/0x50
[   88.005063]  vprintk_func+0x27/0x60
[   88.005064]  printk+0x58/0x6f
[   88.005065]  ? entry_SYSCALL64_slow_path+0x25/0x25
[   88.005067]  __show_regs+0x7a/0x2d0
[   88.005068]  ? printk+0x58/0x6f
[   88.005069]  ? entry_SYSCALL64_slow_path+0x25/0x25
[   88.005070]  ? entry_SYSCALL64_slow_path+0x25/0x25
[   88.005071]  show_trace_log_lvl+0x2bf/0x410
[   88.005073]  show_regs+0x9f/0x1a0
[   88.005076]  ? __vm_enough_memory+0x11f/0x130
[   88.005077]  __warn+0x9b/0xeb
[   88.005078]  ? __vm_enough_memory+0x11f/0x130
[   88.005080]  report_bug+0x87/0x100
[   88.005081]  fixup_bug+0x2c/0x50
[   88.005083]  do_trap+0x12e/0x180
[   88.005084]  do_error_trap+0x89/0x110
[   88.005085]  ? __vm_enough_memory+0x11f/0x130
[   88.005087]  ? avc_has_perm_noaudit+0xca/0x140
[   88.005089]  do_invalid_op+0x20/0x30
[   88.005090]  invalid_op+0x18/0x20
[   88.005091] RIP: 0010:__vm_enough_memory+0x11f/0x130
[   88.005091] RSP: 0018:ffff9ad48179fd58 EFLAGS: 00010257
[   88.005092] RAX: 000000000001fc2c RBX: fffffffffffffffc RCX: 00000000000007ca
[   88.005092] RDX: fffffffffffff836 RSI: fffffffffffffffc RDI: ffffffff914a4fc0
[   88.005093] RBP: ffff9ad48179fd70 R08: ffffffff9152f530 R09: ffff9ad48179fcfc
[   88.005093] R10: 0000000000000020 R11: ffff8e8cf61142a8 R12: 0000000000000001
[   88.005094] R13: ffff8e8cd6b47800 R14: ffff8e8cf6ebdc80 R15: 0000000000000004
[   88.005096]  ? __vm_enough_memory+0x11f/0x130
[   88.005098]  security_vm_enough_memory_mm+0x53/0x60
[   88.005100]  copy_process.part.34+0xd7d/0x1d60
[   88.005102]  _do_fork+0xed/0x390
[   88.005104]  SyS_clone+0x19/0x20
[   88.005106]  do_syscall_64+0x67/0x1b0
[   88.005107]  entry_SYSCALL64_slow_path+0x25/0x25
[   88.005108] RIP: 0033:0x7feb5ab39291
[   88.005108] RSP: 002b:00007fff7ff715c0 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
[   88.005109] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007feb5ab39291
[   88.005109] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
[   88.005110] RBP: 00007fff7ff71600 R08: 00007feb5d71f8c0 R09: 0000000000000354
[   88.005110] R10: 00007feb5d71fb90 R11: 0000000000000246 R12: 00007fff7ff715c0
[   88.005111] R13: 0000000000000000 R14: 0000000000000000 R15: 000055e03ff11e08
[   88.005111] Code: a8 40 0f 84 ad 01 00 00 4c 89 f7 44 89 ea 48 c7 c6 c0 a3 2d 91 ff d1 4d 8b 76 50 4d 85 f6 75 a6 e8 88 17 00 00 48 8b 7d d0 57 9d <0f> 1f 44 00 00 8b 55 c8 85 d2 0f 84 26 fe ff ff e8 fd 29 68 00
[   88.161470] virtio_balloon virtio3: Released 256 pages. Remains 1977163 pages.
[   88.277947] virtio_balloon virtio3: Released 256 pages. Remains 1976907 pages.
[   88.279782] virtio_balloon virtio3: Released 256 pages. Remains 1976651 pages.
[   90.526651] virtio_balloon virtio3: Released 256 pages. Remains 1976395 pages.
[   91.714541] virtio_balloon virtio3: Released 256 pages. Remains 1976139 pages.
[   92.900111] virtio_balloon virtio3: Released 256 pages. Remains 1975883 pages.
[   93.379880] virtio_balloon virtio3: Released 256 pages. Remains 1975627 pages.
[   93.408485] virtio_balloon virtio3: Released 256 pages. Remains 1975371 pages.
[   94.567452] virtio_balloon virtio3: Released 256 pages. Remains 1975115 pages.
[   95.194615] virtio_balloon virtio3: Released 256 pages. Remains 1974859 pages.
[   95.458030] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007feb5ab39291
[   95.458453] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
[   95.458873] RBP: 00007fff7ff71600 R08: 00007feb5d71f8c0 R09: 0000000000000354
[   95.459307] R10: 00007feb5d71fb90 R11: 0000000000000246 R12: 00007fff7ff715c0
[   95.459732] R13: 0000000000000000 R14: 0000000000000000 R15: 000055e03ff11e08
[   95.460172] Code: 0d 9f 41 0d 01 31 d2 48 85 c9 48 0f 49 d1 48 39 d0 7f a5 8b 15 23 c5 b2 00 48 f7 db 48 c7 c7 c0 4f 4a 91 48 89 de e8 d1 06 1e 00 <0f> ff b8 f4 ff ff ff eb 86 0f 1f 84 00 00 00 00 00 0f 1f 44 00
[   95.461110] ---[ end trace 7b4eb70d4e6de603 ]---
[   95.461622] ------------[ cut here ]------------
[   95.462147] WARNING: CPU: 2 PID: 852 at kernel/fork.c:1988 copy_process.part.34+0x5ce/0x1d60
[   95.462675] Modules linked in: netconsole ip_set nfnetlink snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hwdep crct10dif_pclmul crc32_pclmul snd_hda_core snd_seq ghash_clmulni_intel snd_seq_device ppdev snd_pcm aesni_intel crypto_simd cryptd glue_helper snd_timer snd joydev sg virtio_balloon pcspkr parport_pc soundcore i2c_piix4 parport xfs libcrc32c sr_mod cdrom ata_generic pata_acpi qxl drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm virtio_blk drm virtio_net virtio_console ata_piix crc32c_intel serio_raw libata virtio_pci i2c_core virtio_ring virtio floppy
[   95.465775] CPU: 2 PID: 852 Comm: sshd Tainted: G        W    L  4.14.0-rc5+ #303
[   95.466404] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[   95.467015] task: ffff8e8cf07b8000 task.stack: ffff9ad48179c000
[   95.467705] RIP: 0010:copy_process.part.34+0x5ce/0x1d60
[   95.468314] RSP: 0000:ffff9ad48179fda8 EFLAGS: 00010202
[   95.468902] RAX: 0000000000000001 RBX: ffff8e8cf07bae80 RCX: 0000000180050004
[   95.469520] RDX: 0000000180050005 RSI: fffff98608c1ee00 RDI: 0000000044040000
[   95.470139] RBP: ffff9ad48179fe90 R08: ffff8e8cf07bae80 R09: 0000000180050004
[   95.470724] R10: 0000000000000001 R11: ffff8e8cf07bae80 R12: fffffffffffffff4
[   95.471348] R13: 0000000000000000 R14: ffff8e8cf6ebdc80 R15: 0000000000000000
[   95.471964] FS:  00007feb5d71f8c0(0000) GS:ffff8e8cffd00000(0000) knlGS:0000000000000000
[   95.472607] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   95.473246] CR2: 00007f7d9da40690 CR3: 0000000230ab9000 CR4: 00000000001406e0
[   95.473870] Call Trace:
[   95.474593]  _do_fork+0xed/0x390
[   95.475267]  SyS_clone+0x19/0x20
[   95.475901]  do_syscall_64+0x67/0x1b0
[   95.476554]  entry_SYSCALL64_slow_path+0x25/0x25
[   95.477241] RIP: 0033:0x7feb5ab39291
[   95.477857] RSP: 002b:00007fff7ff715c0 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
[   95.478534] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007feb5ab39291
[   95.479187] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
[   95.479785] RBP: 00007fff7ff71600 R08: 00007feb5d71f8c0 R09: 0000000000000354
[   95.480391] R10: 00007feb5d71fb90 R11: 0000000000000246 R12: 00007fff7ff715c0
[   95.480988] R13: 0000000000000000 R14: 0000000000000000 R15: 000055e03ff11e08
[   95.481610] Code: 48 8b 80 80 00 00 00 f0 ff 48 04 48 89 df e8 ba 58 02 00 48 89 df 48 c7 43 08 80 00 00 00 e8 3a f3 ff ff 48 89 df e8 52 f1 ff ff <0f> ff 4c 89 e3 e9 ba fa ff ff 4c 63 e0 eb d9 65 48 8b 05 63 5b
[   95.482925] ---[ end trace 7b4eb70d4e6de604 ]---
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
