Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDC06B007D
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 06:23:25 -0500 (EST)
Received: by mail-vc0-f179.google.com with SMTP id lh14so7183032vcb.10
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 03:23:24 -0800 (PST)
Received: from mail-ve0-x232.google.com (mail-ve0-x232.google.com [2607:f8b0:400c:c01::232])
        by mx.google.com with ESMTPS id w1si6729806vet.49.2014.02.25.03.23.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 03:23:23 -0800 (PST)
Received: by mail-ve0-f178.google.com with SMTP id jy13so251792veb.9
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 03:23:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHTgTXWwLEjPxaS07DtW51WtFmpew6oZ0tOw1PAvniPnw44UUQ@mail.gmail.com>
References: <CAHTgTXWwLEjPxaS07DtW51WtFmpew6oZ0tOw1PAvniPnw44UUQ@mail.gmail.com>
Date: Tue, 25 Feb 2014 19:23:23 +0800
Message-ID: <CAA_GA1fgnqDUfGwh_jwP0ZOPa65P0FFo1T5hR33mboeprjqqug@mail.gmail.com>
Subject: Re: kernel BUG at mm/mlock.c:79! on 3.10
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinson Lee <vlee@twopensource.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org

On Tue, Feb 25, 2014 at 7:01 AM, Vinson Lee <vlee@twopensource.com> wrote:
> Hi.
>
> This kernel BUG was triggered while running trinity fuzzer on 3.10.
>

Seems like the same bug as Sasha reported.
Please take a look at:
https://lkml.org/lkml/2014/1/7/637
Or
http://www.spinics.net/lists/linux-mm/msg66972.html

> [413679.376565] ------------[ cut here ]------------
> [413679.395034] kernel BUG at mm/mlock.c:79!
> [413679.395611] invalid opcode: 0000 [#1] SMP
> [413679.396206] Modules linked in: l2tp_ppp l2tp_netlink l2tp_core
> af_key ipt_ULOG nfnetlink can_bcm can_raw scsi_transport_iscsi can
> pppoe pppox ppp_generic slhc rds ipv6 bonding dm_multipath video sbs
> sbshc hed acpi_pad acpi_ipmi acpi_i2c parport_pc lp parport tcp_diag
> inet_diag ipmi_si ipmi_devintf ipmi_msghandler dell_rbu iTCO_wdt
> iTCO_vendor_support dcdbas igb i2c_algo_bit ptp pps_core i2c_i801
> i2c_core microcode lpc_ich mfd_core i7core_edac ioatdma edac_core
> shpchp dca freq_table mperf
> [413679.436926] CPU: 0 PID: 34852 Comm: trinity-c0 Not tainted 3.10.28 #1
> [413679.455720] task: ffff88032d7cc5c0 ti: ffff88032bd70000 task.ti:
> ffff88032bd70000
> [413679.456775] RIP: 0010:[<ffffffff8110cd2d>]  [<ffffffff8110cd2d>]
> mlock_vma_page+0x14/0x70
> [413679.474912] RSP: 0000:ffff88032bd71d08  EFLAGS: 00010246
> [413679.475625] RAX: 080000000038002c RBX: ffffea000703e340 RCX:
> 000000000703e340
> [413679.476506] RDX: 80000001c0f8d027 RSI: 00000000f76e8000 RDI:
> ffffea000703e340
> [413679.494662] RBP: ffff88032bd71d10 R08: 0000000000000000 R09:
> ffffffff811130a7
> [413679.495571] R10: ffff88032a6a5f88 R11: 0000000000000911 R12:
> ffff88032a6a5f00
> [413679.496452] R13: ffffea000703e340 R14: ffffea000c5d3bc0 R15:
> 0000000000020000
> [413679.497323] FS:  00000000016c8840(0063) GS:ffff880332600000(0000)
> knlGS:0000000000000000
> [413679.515582] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> [413679.516332] CR2: 00000000ff80d330 CR3: 0000000300a8b000 CR4:
> 00000000000007f0
> [413679.517212] DR0: 0000000000000000 DR1: 00000000016cd000 DR2:
> 0000000000000000
> [413679.535236] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000600
> [413679.536262] Stack:
> [413679.536485]  ffff8803094bfc08 ffff88032bd71dc0 ffffffff81113136
> ffff88032a6a6270
> [413679.555195]  ffff88032d7cc5c0 ffffea000c12d4c0 ffff88032a6a5f70
> ffff880328849d70
> [413679.556294]  0000000000020000 0000000300000001 00000000f76e9000
> ffff880328849d60
> [413679.557254] Call Trace:
> [413679.557538]  [<ffffffff81113136>] try_to_unmap_file+0x319/0x4be
> [413679.575403]  [<ffffffff81113bd2>] try_to_unmap+0x3d/0x52
> [413679.575970]  [<ffffffff8112bf08>] migrate_pages+0x1e2/0x3ce
> [413679.576682]  [<ffffffff8112b0be>] ? pte_to_swp_entry+0x22/0x22
> [413679.594735]  [<ffffffff8112c5c2>] SyS_move_pages+0x36c/0x4d6
> [413679.595456]  [<ffffffff8112c2b2>] ? SyS_move_pages+0x5c/0x4d6
> [413679.596219]  [<ffffffff81099cd7>] compat_sys_move_pages+0x9c/0xab
> [413679.597032]  [<ffffffff814cbaa9>] ia32_do_call+0x13/0x13
> [413679.614814] Code: 13 48 8b 03 a9 00 00 10 00 74 09 65 48 ff 04 25
> a8 f5 1c 00 5b 5d c3 66 66 66 66 90 55 48 89 e5 53 48 89 fb 48 8b 07
> a8 01 75 02 <0f> 0b f0 0f ba 2f 15 19 c0 85 c0 75 4c 48 8b 3f ba 01 00
> 00 00
> [413679.617503] RIP  [<ffffffff8110cd2d>] mlock_vma_page+0x14/0x70
> [413679.635066]  RSP <ffff88032bd71d08>
> [413679.636094] ---[ end trace dd8b701ea9903fd6 ]---
>
> Cheers,
> Vinson
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
