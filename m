Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 473AB6B0006
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 16:55:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g15-v6so6740509pfh.10
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 13:55:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f71-v6si3859461pfc.316.2018.06.08.13.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 13:55:11 -0700 (PDT)
Date: Fri, 8 Jun 2018 13:55:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 199999] New: memremap attempted on mixed range  lockup.
Message-Id: <20180608135510.48d7d50cbb0cef7b9194816f@linux-foundation.org>
In-Reply-To: <bug-199999-27@https.bugzilla.kernel.org/>
References: <bug-199999-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, me@hussam.eu.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 08 Jun 2018 16:25:31 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=199999
> 
>             Bug ID: 199999
>            Summary: memremap attempted on mixed range  lockup.
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.14.48
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: me@hussam.eu.org
>         Regression: No

That WARN_ON in memremap() (soon perhaps devm_memremap_pages()) is
triggering on /dev/mem.

> hello. I was poking around and for no real reason, I did cat /dev/mem and
> strings /dev/mem.
> Then I saw the following warning in dmesg. I saved it and rebooted immediately.
> 
> Jun 08 19:07:25 hades kernel: memremap attempted on mixed range
> 0x000000000009c000 size: 0x1000
> Jun 08 19:07:25 hades kernel: ------------[ cut here ]------------
> Jun 08 19:07:25 hades kernel: WARNING: CPU: 0 PID: 11810 at
> kernel/memremap.c:98 memremap+0x104/0x170
> Jun 08 19:07:25 hades kernel: Modules linked in: button isofs udf crc_itu_t
> loop nls_iso8859_1 nls_cp437 vfat fat uas usb_storage fuse bsd_comp
> ipt_MASQUERADE nf_nat_masquerade_ipv4 act_police sch_ingress cls_u32 sch_sfq
> iptable_nat nf_c>
> Jun 08 19:07:25 hades kernel:  thermal snd_pcm snd_timer snd video soundcore
> shpchp mei_me mei fan i2c_i801 acpi_pad sch_fq_codel nvidia_uvm(PO) nvidia(PO)
> ipmi_devintf ipmi_msghandler nbd crypto_user ip_tables x_tables ext4
> crc32c_gener>
> Jun 08 19:07:25 hades kernel: CPU: 0 PID: 11810 Comm: strings Tainted: P       
>    O    4.14.48-1-lts #1
> Jun 08 19:07:25 hades kernel: Hardware name: LENOVO 90DA00D7AD/SKYBAY, BIOS
> FYKT58A 06/02/2016
> Jun 08 19:07:25 hades kernel: task: ffff9393c0be3b00 task.stack:
> ffffb41287a3c000
> Jun 08 19:07:25 hades kernel: RIP: 0010:memremap+0x104/0x170
> Jun 08 19:07:25 hades kernel: RSP: 0018:ffffb41287a3fdc8 EFLAGS: 00010282
> Jun 08 19:07:25 hades kernel: RAX: 0000000000000041 RBX: 0000000000000000 RCX:
> 0000000000000000
> Jun 08 19:07:25 hades kernel: RDX: 0000000000000000 RSI: ffff9396bec165d8 RDI:
> ffff9396bec165d8
> Jun 08 19:07:25 hades kernel: RBP: 0000000000000001 R08: 0000000000000412 R09:
> 0000000000000004
> Jun 08 19:07:25 hades kernel: R10: 0000000000000000 R11: 0000000000000001 R12:
> 0000000000001000
> Jun 08 19:07:25 hades kernel: R13: 000055630d83b020 R14: ffff9396a5ec3000 R15:
> 0000000000000000
> Jun 08 19:07:25 hades kernel: FS:  00007fa2611ddb80(0000)
> GS:ffff9396bec00000(0000) knlGS:0000000000000000
> Jun 08 19:07:25 hades kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> Jun 08 19:07:25 hades kernel: CR2: 000055630d83c028 CR3: 00000001d5388006 CR4:
> 00000000003606f0
> Jun 08 19:07:25 hades kernel: Call Trace:
> Jun 08 19:07:25 hades kernel:  xlate_dev_mem_ptr+0x25/0x40
> Jun 08 19:07:25 hades kernel:  read_mem+0x89/0x1a0
> Jun 08 19:07:25 hades kernel:  __vfs_read+0x36/0x170
> Jun 08 19:07:25 hades kernel:  ? __fsnotify_parent+0x91/0x120
> Jun 08 19:07:25 hades kernel:  vfs_read+0x89/0x130
> Jun 08 19:07:25 hades kernel:  SyS_read+0x52/0xc0
> Jun 08 19:07:25 hades kernel:  do_syscall_64+0x67/0x120
> Jun 08 19:07:25 hades kernel:  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> Jun 08 19:07:25 hades kernel: RIP: 0033:0x7fa2609fd4a1
> Jun 08 19:07:25 hades kernel: RSP: 002b:00007ffef180bb58 EFLAGS: 00000246
> ORIG_RAX: 0000000000000000
> Jun 08 19:07:25 hades kernel: RAX: ffffffffffffffda RBX: 000055630d818470 RCX:
> 00007fa2609fd4a1
> Jun 08 19:07:25 hades kernel: RDX: 0000000000001000 RSI: 000055630d83b020 RDI:
> 0000000000000003
> Jun 08 19:07:25 hades kernel: RBP: 0000000000000d68 R08: 0000000000000000 R09:
> 0000000000000004
> Jun 08 19:07:25 hades kernel: R10: 0000000000000000 R11: 0000000000000246 R12:
> 00007fa260c94720
> Jun 08 19:07:25 hades kernel: R13: 00007fa260c95260 R14: 00007ffef180bc14 R15:
> 00007ffef180bc08
> Jun 08 19:07:25 hades kernel: Code: 48 83 c4 08 5b 5d 41 5c c3 80 3d 18 de f5
> 00 00 75 b7 4c 89 e2 48 89 e6 48 c7 c7 e8 db df 90 c6 05 02 de f5 00 01 e8 07
> fa f4 ff <0f> 0b eb 9a 4c 89 e6 48 89 df e8 0d f8 ed ff 48 85 c0 74 99 48 
> Jun 08 19:07:25 hades kernel: ---[ end trace 5bdcf881c57b4daa ]---
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
