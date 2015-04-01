Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9106B006C
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 16:10:48 -0400 (EDT)
Received: by lbbug6 with SMTP id ug6so44787049lbb.3
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 13:10:47 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id kx6si2431775lac.141.2015.04.01.13.10.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 13:10:46 -0700 (PDT)
Received: by lbdc10 with SMTP id c10so44614176lbd.2
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 13:10:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150401134132.GB17886@node.dhcp.inet.fi>
References: <551BBE1A.4040404@profihost.ag>
	<20150401113122.GA17153@node.dhcp.inet.fi>
	<551BDC4F.4010000@profihost.ag>
	<20150401134132.GB17886@node.dhcp.inet.fi>
Date: Wed, 1 Apr 2015 23:10:45 +0300
Message-ID: <CALYGNiP=1LqATiTe9cgdEhhGFDYe_U-iLG9DwX6isCFicOekLQ@mail.gmail.com>
Subject: Re: kernel 3.18.10: THP refcounting bug
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>

On Wed, Apr 1, 2015 at 4:41 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> On Wed, Apr 01, 2015 at 01:53:51PM +0200, Stefan Priebe - Profihost AG wrote:
>> Hi,
>>
>> while using 3.18.9 i got several times the following stack trace:
>>
>> kernel BUG at mm/filemap.c:203!
>> invalid opcode: 0000 [#1] SMP
>> Modules linked in: dm_mod netconsole usbhid sd_mod sg ata_generic
>> virtio_net virtio_scsi uhci_hcd ehci_hcd usbcore virtio_pci usb_common
>> virtio_ring ata_piix virtio floppy
>> CPU: 3 PID: 1 Comm: busybox Tainted: G    B          3.18.9 #1

As I see this isn't first oops -> kernel already tainted with 'B'
Bad-page-state.

Please look at first splash where is no 'B' flag.

>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> rel-1.7.5.1-0-g8936dbb-20141113_115728-nilsson.home.kraxel.org 04/01/2014
>> task: ffff880137b98000 ti: ffff880137b94000 task.ti: ffff880137b94000
>> RIP: 0010:[<ffffffff81134495>]  [<ffffffff81134495>]
>> __delete_from_page_cache+0x2b5/0x2c0
>> RSP: 0018:ffff880137b97be8  EFLAGS: 00010046
>> RAX: 0000000000000000 RBX: 0000000000000003 RCX: 00000000ffffffd0
>> RDX: 0000000000000030 RSI: 000000000000000a RDI: ffff88013f9696c0
>> RBP: ffff880137b97c38 R08: 0000000000000000 R09: ffffea0002e927c0
>> R10: ffff8800bba92da0 R11: ffff880137b97c00 R12: ffffea0002e92480
>> R13: ffff8800bba8c4c8 R14: 0000000000000000 R15: ffff8800bba8c4d0
>> FS:  00007f5a79e0b700(0000) GS:ffff880139060000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00000000023c3138 CR3: 00000000b84ba000 CR4: 00000000000006e0
>> Stack:
>>  000000000000000e ffff880137b97d48 ffff8800bba92da0 ffff8800bba92dc8
>>  ffff880137b97c68 ffffea0002e92480 ffff8800bba8c4c8 0000000000000000
>>  0000000000000000 0000000000000000 ffff880137b97c68 ffffffff81134604
>> Call Trace:
>>  [<ffffffff81134604>] delete_from_page_cache+0x44/0x70
>>  [<ffffffff811413cb>] truncate_inode_page+0x5b/0x90
>>  [<ffffffff811415a4>] truncate_inode_pages_range+0x1a4/0x6c0
>>  [<ffffffff81141b45>] truncate_inode_pages+0x15/0x20
>>  [<ffffffff81141c4c>] truncate_inode_pages_final+0x3c/0x50
>>  [<ffffffff811bb83c>] evict+0x16c/0x180
>>  [<ffffffff811bbed5>] iput+0x105/0x190
>>  [<ffffffff811b0c19>] do_unlinkat+0x189/0x2b0
>>  [<ffffffff811b1a46>] SyS_unlink+0x16/0x20
>>  [<ffffffff815f6592>] system_call_fastpath+0x12/0x17
>> Code: 66 0f 1f 44 00 00 48 8b 75 c0 4c 89 ff e8 e4 5d 1f 00 84 c0 0f 85
>> 5e fe ff ff e9 41 fe ff ff 0f 1f 80 00 00 00 00 e8 75 70 4b 00 <0f> 0b
>> 66 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 83 e2 fd 48
>> RIP  [<ffffffff81134495>] __delete_from_page_cache+0x2b5/0x2c0
>>  RSP <ffff880137b97be8>
>> ---[ end trace a4727cb71335dbd4 ]---
>>
>> Is this a known bug?
>
> +Hugh, Konstantin.
>
> Nothing I recognize. Looks somewhat like[1], but not really.
>
> Do you have a way to reproduce? What fs it was?
>
> [1] lkml.kernel.org/g/20140603042121.GA27177@redhat.com
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
