Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42B106B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 05:29:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id h16so2421081wrf.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 02:29:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o34si1324198edc.146.2017.09.20.02.29.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 02:29:33 -0700 (PDT)
Date: Wed, 20 Sep 2017 11:29:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug regression in 4.13
Message-ID: <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
References: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Forshee <seth.forshee@canonical.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,
I am currently at a conference so I will most probably get to this next
week but I will try to ASAP.

On Tue 19-09-17 11:41:14, Seth Forshee wrote:
> Hi Michal,
> 
> I'm seeing oopses in various locations when hotplugging memory in an x86
> vm while running a 32-bit kernel. The config I'm using is attached. To
> reproduce I'm using kvm with the memory options "-m
> size=512M,slots=3,maxmem=2G". Then in the qemu monitor I run:
> 
>   object_add memory-backend-ram,id=mem1,size=512M
>   device_add pc-dimm,id=dimm1,memdev=mem1
> 
> Not long after that I'll see an oops, not always in the same location
> but most often in wp_page_copy, like this one:

This is rather surprising. How do you online the memory?

> [   24.673623] BUG: unable to handle kernel paging request at dffff000
> [   24.675569] IP: wp_page_copy+0xa8/0x660

could you resolve the IP into the source line?

> [   24.676792] *pdpt = 0000000004d6a001 *pde = 0000000004e6d067
> [   24.676797] *pte = 0000000000000000
> [   24.678522]
> [   24.680066] Oops: 0002 [#1] SMP
> [   24.681037] Modules linked in: ppdev nls_utf8 isofs kvm_intel kvm irqbypass input_leds joydev parport_pc serio_raw i2c_piix4 mac_hid parport qemu_fw_cfg iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi ip_tables x_tables autofs4 btrfs raid10 raid456 async_raid6_rec
> ov async_memcpy async_pq async_xor async_tx xor raid6_pq libcrc32c raid1 raid0 multipath linear cirrus ttm drm_kms_helper psmouse syscopyarea sysfillrect virtio_blk sysimgblt fb_sys_fops drm virtio_net pata_acpi floppy
> [   24.688918] CPU: 1 PID: 819 Comm: sshd Tainted: G        W       4.12.0+ #62
> [   24.690131] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
> [   24.691656] task: dbbbcc00 task.stack: dbbea000
> [   24.692484] EIP: wp_page_copy+0xa8/0x660
> [   24.693166] EFLAGS: 00210282 CPU: 1
> [   24.693769] EAX: dffff000 EBX: d2214000 ECX: dffff000 EDX: 0000003e
> [   24.694838] ESI: d2214000 EDI: dffff004 EBP: dbbebe9c ESP: dbbebe60
> [   24.695908]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [   24.696865] CR0: 80050033 CR2: dffff000 CR3: 1b985b80 CR4: 000006f0
> [   24.697945] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> [   24.699010] DR6: fffe0ff0 DR7: 00000400
> [   24.699670] Call Trace:
> [   24.700133]  do_wp_page+0x83/0x4f0
> [   24.700762]  ? kmap_atomic_prot+0x3c/0x100
> [   24.701421]  handle_mm_fault+0x95c/0xe50
> [   24.702053]  ? default_send_IPI_single+0x2c/0x30
> [   24.702788]  ? resched_curr+0x51/0xc0
> [   24.703382]  ? check_preempt_curr+0x75/0x80
> [   24.704081]  __do_page_fault+0x209/0x500
> [   24.704732]  ? kvm_async_pf_task_wake+0x100/0x100
> [   24.705491]  trace_do_page_fault+0x3f/0xe0
> [   24.706151]  ? kvm_async_pf_task_wake+0x100/0x100
> [   24.706902]  do_async_page_fault+0x55/0x70
> [   24.707571]  common_exception+0x6c/0x72
> [   24.708212] EIP: 0xb722676a
> [   24.708677] EFLAGS: 00210282 CPU: 1
> [   24.709235] EAX: bfe086e0 EBX: 01200011 ECX: 00000000 EDX: 00000000
> [   24.710222] ESI: 00000000 EDI: 00000426 EBP: bfe08728 ESP: bfe086e0
> [   24.711215]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
> [   24.712097] Code: 00 00 8b 4d e8 85 c9 0f 84 1e 05 00 00 8b 45 e8 e8 4e d1 ea ff 89 c3 8b 45 e0 89 de e8 42 d1 ea ff 8b 13 8d 78 04 89 c1 83 e7 fc <89> 10 8b 93 fc 0f 00 00 29 f9 29 ce 81 c1 00 10 00 00 c1 e9 02
> [   24.714927] EIP: wp_page_copy+0xa8/0x660 SS:ESP: 0068:dbbebe60
> [   24.715792] CR2: 00000000dffff000
> 
> I ran a bisect and landed on a commit of yours, f1dd2cd13c4b "mm,
> memory_hotplug: do not associate hotadded memory to zones until online",
> as the first commit with this issue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
