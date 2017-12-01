Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C27696B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:18:56 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f27so5242406ote.16
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:18:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si2205227oif.184.2017.12.01.07.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 07:18:55 -0800 (PST)
Date: Fri, 1 Dec 2017 23:18:51 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: KAISER: kexec triggers a warning
Message-ID: <20171201151851.GK2198@x1>
References: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, dave.hansen@linux.intel.com, hughd@google.com, luto@kernel.org

On 12/01/17 at 02:52pm, Juerg Haefliger wrote:
> Loading a kexec kernel using today's linux-tip master with KAISER=y
> triggers the following warning:

I also noticed this when trigger a crash to jump to kdump kernel, and
kdump kernel failed to bootup. I am trying to fix it on tip/WIP.x86/mm.
Maybe still need a little time.

> 
> [   18.054017] ------------[ cut here ]------------
> [   18.054024] WARNING: CPU: 0 PID: 1183 at
> ./arch/x86/include/asm/pgtable_64.h:258 native_set_p4d+0x5f/0x80
> [   18.054025] Modules linked in: nls_utf8 isofs ppdev nls_iso8859_1
> kvm_intel kvm irqbypass input_leds serio_raw i2c_piix4 parport_pc
> parport qemu_fw_cfg mac_hid 9p fscache ib_iser rdma_cm iw_cm ib_cm
> ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi
> 9pnet_virtio 9pnet ip_tables x_tables autofs4 btrfs zstd_decompress
> zstd_compress xxhash raid10 raid456 async_raid6_recov async_memcpy
> async_pq async_xor async_tx xor raid6_pq libcrc32c raid1 raid0 multipath
> linear cirrus ttm drm_kms_helper syscopyarea sysfillrect sysimgblt
> fb_sys_fops psmouse virtio_blk virtio_net drm floppy pata_acpi
> [   18.054047] CPU: 0 PID: 1183 Comm: kexec Not tainted 4.14.0-kaiser+ #2
> [   18.054047] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.10.2-1ubuntu1 04/01/2014
> [   18.054048] task: ffff8a53f9d0ab80 task.stack: ffffaba640890000
> [   18.054049] RIP: 0010:native_set_p4d+0x5f/0x80
> [   18.054050] RSP: 0018:ffffaba640893e20 EFLAGS: 00010246
> [   18.054051] RAX: 0000000038ac9063 RBX: 000000003ffda000 RCX:
> 000000003ffda000
> [   18.054051] RDX: ffff8a53fd1f6ff8 RSI: 0000000038ac9063 RDI:
> ffff8a53f71ba000
> [   18.054051] RBP: 000000003ffda000 R08: 000075abc0000000 R09:
> ffff8a53f8ac9000
> [   18.054052] R10: 0000000000000003 R11: 000000003ffda000 R12:
> ffff8a53f71ba000
> [   18.054052] R13: ffffaba640893e78 R14: 0000000000000000 R15:
> ffffff8000000000
> [   18.054053] FS:  00007f0e95188740(0000) GS:ffff8a53ffc00000(0000)
> knlGS:0000000000000000
> [   18.054054] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   18.054054] CR2: 00007f0e94bf0fa0 CR3: 000000003c452000 CR4:
> 00000000000006f0
> [   18.054056] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [   18.054056] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
> 0000000000000400
> [   18.054057] Call Trace:
> [   18.054065]  kernel_ident_mapping_init+0x147/0x190
> [   18.054069]  machine_kexec_prepare+0xc8/0x490
> [   18.054071]  ? trace_clock_x86_tsc+0x10/0x10
> [   18.054074]  do_kexec_load+0x1d7/0x2d0
> [   18.054079]  SyS_kexec_load+0x84/0xc0
> [   18.054083]  entry_SYSCALL_64_fastpath+0x1e/0x81
> [   18.054087] RIP: 0033:0x7f0e94c9c9f9
> [   18.054087] RSP: 002b:00007ffe0d1a83e8 EFLAGS: 00000246 ORIG_RAX:
> 00000000000000f6
> [   18.054088] RAX: ffffffffffffffda RBX: 000055a491d71240 RCX:
> 00007f0e94c9c9f9
> [   18.054089] RDX: 000055a492aaa570 RSI: 0000000000000003 RDI:
> 000000003ffd1730
> [   18.054089] RBP: 00007ffe0d1a8510 R08: 0000000000000008 R09:
> 0000000000000001
> [   18.054089] R10: 00000000003e0000 R11: 0000000000000246 R12:
> 0000000000000100
> [   18.054090] R13: 0000000000000040 R14: 0000000001b1d820 R15:
> 000000000007c7e0
> [   18.054090] Code: 37 c3 f6 07 04 74 1b 48 89 f8 25 ff 0f 00 00 48 3d
> ff 07 00 00 77 18 48 89 f8 80 cc 10 48 89 30 eb dc 83 3d 07 6d ff 00 02
> 75 d3 <0f> ff eb cf 0f ff eb cb 48 b8 00 00 00 00 00 00 00 80 48 09 c6
> [   18.054104] ---[ end trace f206deb161cf8af0 ]---
> 
> ...Juerg
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
