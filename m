Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 812C76B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 16:13:25 -0400 (EDT)
Received: by pddn5 with SMTP id n5so65583954pdd.2
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 13:13:25 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id fu7si4357880pdb.48.2015.04.01.13.13.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Apr 2015 13:13:23 -0700 (PDT)
Message-ID: <551C515C.5050807@oracle.com>
Date: Wed, 01 Apr 2015 16:13:16 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: kernel 3.18.10: THP refcounting bug
References: <551BBE1A.4040404@profihost.ag> <20150401113122.GA17153@node.dhcp.inet.fi> <551BDB8F.4070707@profihost.ag> <551C12CC.3000803@oracle.com> <551C39EE.90504@profihost.ag>
In-Reply-To: <551C39EE.90504@profihost.ag>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe <s.priebe@profihost.ag>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>

linux-mm@ was incorrect in the original mail so this ended up getting around
just between us.

Below is Stefan's response to my question about the 'B' taint flag.

On 04/01/2015 02:33 PM, Stefan Priebe wrote:
> 
> Am 01.04.2015 um 17:46 schrieb Sasha Levin:
>> On 04/01/2015 07:50 AM, Stefan Priebe - Profihost AG wrote:
>>> Hi,
>>>
>>> while using 3.18.9 i got several times the following stack trace:
>>>
>>> kernel BUG at mm/filemap.c:203!
>>> invalid opcode: 0000 [#1] SMP
>>> Modules linked in: dm_mod netconsole usbhid sd_mod sg ata_generic
>>> virtio_net virtio_scsi uhci_hcd ehci_hcd usbcore virtio_pci usb_common
>>> virtio_ring ata_piix virtio floppy
>>> CPU: 3 PID: 1 Comm: busybox Tainted: G    B          3.18.9 #1
>>
>> Looking at the taint flags, was there anything else before this that
>> could set the 'B' flag?
> 
> oh i'm sorry you're correct before that one i see (happens on shutdown):
> 
> BUG: Bad page map in process udevd  pte:ba4a2025 pmd:ba275067
> page:ffffea0002e92880 count:1 mapcount:-1 mapping:ffff8800bba8c4c8 index:0x10
> flags: 0x1fffff8000007c(referenced|uptodate|dirty|lru|active)
> page dumped because: bad pte
> addr:0000000000410000 vm_flags:00000875 anon_vma:          (null) mapping:ffff8800bba8c4c8 index:10
> vma->vm_ops->fault: filemap_fault+0x0/0x480
> vma->vm_file->f_op->mmap: generic_file_mmap+0x0/0x60
> CPU: 7 PID: 105 Comm: udevd Not tainted 3.18.9+14-ph #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5.1-0-g8936dbb-20141113_115728-nilsson.home.kraxel.org 04/01/201
> 4
>  ffff880136ca58c0 ffff8800b9c8bc58 ffffffff815f0732 00000000072b072b
>  0000000000410000 ffff8800b9c8bca8 ffffffff8115b5b6 00000000ba4a2025
>  0000000000000010 ffff8800b9c8bca8 0000000000424000 ffff8800ba275080
> Call Trace:
>  [<ffffffff815f0732>] dump_stack+0x46/0x58
>  [<ffffffff8115b5b6>] print_bad_pte+0x196/0x240
>  [<ffffffff8115d3c9>] unmap_single_vma+0x729/0x7f0
>  [<ffffffff8115d801>] unmap_vmas+0x51/0xa0
>  [<ffffffff811666c5>] exit_mmap+0xc5/0x170
>  [<ffffffff810713c5>] mmput+0x55/0x100
>  [<ffffffff8107631d>] do_exit+0x25d/0xa30
>  [<ffffffff8116552f>] ? do_munmap+0x30f/0x3b0
>  [<ffffffff81076b7f>] do_group_exit+0x3f/0xa0
>  [<ffffffff81076bf7>] SyS_exit_group+0x17/0x20
>  [<ffffffff815f6592>] system_call_fastpath+0x12/0x17
> Disabling lock debugging due to kernel taint
> BUG: Bad page state in process udevd  pfn:ba4a2
> page:ffffea0002e92880 count:0 mapcount:-1 mapping:ffff8800bba8c4c8 index:0x10
> flags: 0x1fffff8000001c(referenced|uptodate|dirty)
> page dumped because: non-NULL mapping
> Modules linked in: dm_mod netconsole usbhid sd_mod sg ata_generic virtio_net virtio_scsi uhci_hcd ehci_hcd usbcore virtio_pci usb_co
> mmon virtio_ring ata_piix virtio floppy
> CPU: 7 PID: 105 Comm: udevd Tainted: G    B          3.18.9+14-ph #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5.1-0-g8936dbb-20141113_115728-nilsson.home.kraxel.org 04/01/201
> 4
>  ffffffff81805618 ffff8800b9c8bba8 ffffffff815f0732 0000000007700770
>  ffffea0002e92880 ffff8800b9c8bbd8 ffffffff815eb801 0000000000000000
>  ffffea0002e92880 0000000000000000 000fffff80000000 ffff8800b9c8bc28
> Call Trace:
>  [<ffffffff815f0732>] dump_stack+0x46/0x58
>  [<ffffffff815eb801>] bad_page+0xf7/0x115
>  [<ffffffff81137c22>] free_pages_prepare+0x152/0x180
>  [<ffffffff8113a130>] free_hot_cold_page+0x40/0x160
>  [<ffffffff8113a29e>] free_hot_cold_page_list+0x4e/0xa0
>  [<ffffffff8113fcd3>] release_pages+0x1f3/0x280
>  [<ffffffff8117142d>] free_pages_and_swap_cache+0x8d/0xa0
>  [<ffffffff8115b6c4>] tlb_flush_mmu_free+0x34/0x60
>  [<ffffffff8115bbe4>] tlb_flush_mmu+0x24/0x30
>  [<ffffffff8115bc04>] tlb_finish_mmu+0x14/0x40
>  [<ffffffff811666f4>] exit_mmap+0xf4/0x170
>  [<ffffffff810713c5>] mmput+0x55/0x100
>  [<ffffffff8107631d>] do_exit+0x25d/0xa30
>  [<ffffffff8116552f>] ? do_munmap+0x30f/0x3b0
>  [<ffffffff81076b7f>] do_group_exit+0x3f/0xa0
>  [<ffffffff81076bf7>] SyS_exit_group+0x17/0x20
>  [<ffffffff815f6592>] system_call_fastpath+0x12/0x17
> ------------[ cut here ]------------
> 
> 
> Stefan
> 
>>
>>
>> Thanks,
>> Sasha
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
