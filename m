Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 792266B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 11:20:39 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id u57so2473037wes.11
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 08:20:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m15si4435584wiv.81.2014.02.03.08.20.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 08:20:37 -0800 (PST)
Date: Mon, 3 Feb 2014 17:20:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Need help in bug in isolate_migratepages_range
Message-ID: <20140203162036.GJ2495@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1401312037340.6630@diagnostix.dwd.de>
 <20140203122052.GC2495@dhcp22.suse.cz>
 <alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Holger Kiehl <Holger.Kiehl@dwd.de>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon 03-02-14 14:29:22, Holger Kiehl wrote:
> I have attached it. Please, tell me if you do not get the attachment.

I hoped it would help me to get a closer compiled code to yours but I am
probably using too different gcc.
Anyway I've tried to check whether I can hook on something and it seems
that this is a race with thp merge/split or something like that.
 
[...]
> >>   Jan 31 13:07:43 asterix kernel: BUG: unable to handle kernel NULL pointer dereference at 000000000000001c
> >>   Jan 31 13:07:43 asterix kernel: IP: [<ffffffff810af0ac>] isolate_migratepages_range+0x32d/0x653
> >>   Jan 31 13:07:43 asterix kernel: PGD 7d3074067 PUD 7d3073067 PMD 0
> >>   Jan 31 13:07:43 asterix kernel: Oops: 0000 [#1] SMP
> >>   Jan 31 13:07:43 asterix kernel: Modules linked in: drbd lru_cache coretemp ipmi_devintf bonding nf_conntrack_ftp binfmt_misc usbhid i2c_i801 sg ehci_pci i2c_core ehci_hcd uhci_hcd i5000_edac i5k_amb ipmi_si ipmi_msghandler usbcore usb_common [last unloaded: microcode]
> >>   Jan 31 13:07:43 asterix kernel: CPU: 5 PID: 14164 Comm: java Not tainted 3.12.9 #1
> >>   Jan 31 13:07:43 asterix kernel: Hardware name: FUJITSU SIEMENS PRIMERGY RX300 S4             /D2519, BIOS 4.06  Rev. 1.04.2519             07/30/2008
> >>   Jan 31 13:07:43 asterix kernel: task: ffff8807d30b08c0 ti: ffff8807d30b2000 task.ti: ffff8807d30b2000
> >>   Jan 31 13:07:43 asterix kernel: RIP: 0010:[<ffffffff810af0ac>]  [<ffffffff810af0ac>] isolate_migratepages_range+0x32d/0x653
> >>   Jan 31 13:07:43 asterix kernel: RSP: 0000:ffff8807d30b3928  EFLAGS: 00010286
> >>   Jan 31 13:07:43 asterix kernel: RAX: 0000000000000000 RBX: 000000000020ec09 RCX: 0000000000000002
> >>   Jan 31 13:07:43 asterix kernel: RDX: 2c00000000008000 RSI: 0000000000000004 RDI: 000000000000006c
> >>   Jan 31 13:07:43 asterix kernel: RBP: ffff8807d30b39f8 R08: ffff88083fbde390 R09: 0000000000000001
> >>   Jan 31 13:07:43 asterix kernel: R10: 0000000000000000 R11: ffffea000733a000 R12: ffff8807d30b3a58
> >>   Jan 31 13:07:43 asterix kernel: R13: ffffea000733a1f8 R14: 0000000000000000 R15: ffff88083ffe1d80
> >>   Jan 31 13:07:43 asterix kernel: FS:  00007f9d9e72f910(0000) GS:ffff88083fd40000(0000) knlGS:0000000000000000
> >>   Jan 31 13:07:43 asterix kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >>   Jan 31 13:07:43 asterix kernel: CR2: 000000000000001c CR3: 00000007d3070000 CR4: 00000000000407e0
> >>   Jan 31 13:07:43 asterix kernel: Stack:
> >>   Jan 31 13:07:43 asterix kernel: 0000000000000009 ffff88083ffe16c0 ffffea00002e6af0 ffff8807d30b3998
> >>   Jan 31 13:07:43 asterix kernel: ffff8807d30b2010 00ff8807d30b08c0 ffff8807d30b08c0 000000000020f000
> >>   Jan 31 13:07:43 asterix kernel: 0000000000000000 000000000000083b 000000000000000a ffff8807d30b3a68
> >>   Jan 31 13:07:43 asterix kernel: Call Trace:
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810a161f>] ? lru_add_drain_cpu+0x25/0x97
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810af687>] compact_zone+0x2b5/0x319
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810da586>] ? put_super+0x20/0x2c
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810afa4d>] compact_zone_order+0xad/0xc4
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810afaf5>] try_to_compact_pages+0x91/0xe8
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff8109b92d>] ? page_alloc_cpu_notify+0x3e/0x3e
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff8109da34>] __alloc_pages_direct_compact+0xae/0x195
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff8109e45d>] __alloc_pages_nodemask+0x772/0x7b5
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810c85a3>] alloc_pages_vma+0xd6/0x101
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810d47e3>] do_huge_pmd_anonymous_page+0x199/0x2ee
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810b3884>] handle_mm_fault+0x1b7/0xceb
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff8105dedc>] ? __dequeue_entity+0x2e/0x33
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff8102d8c3>] __do_page_fault+0x3bd/0x3e4
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810bbe1a>] ? mprotect_fixup+0x1c9/0x1fb
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810aa0f0>] ? vm_mmap_pgoff+0x6d/0x8f
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff810795f5>] ? SyS_futex+0x103/0x13d
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff8102d8f3>] do_page_fault+0x9/0xb
> >>   Jan 31 13:07:43 asterix kernel: [<ffffffff813d3672>] page_fault+0x22/0x30
> >>   Jan 31 13:07:43 asterix kernel: Code: 00 41 f7 45 00 ff ff ff 01 0f 85 43 02 00 00 41 8b 45 18 85 c0 0f 89 37 02 00 00 49 8b 55 00 4c 89 e8 66 85 d2 79 04 49 8b 45 30 <8b> 40 1c 83 f8 01 0f 85 1b 02 00 00 49 8b 55 08 30 c0 48 85 d2
> >>   Jan 31 13:07:43 asterix kernel: RIP  [<ffffffff810af0ac>] isolate_migratepages_range+0x32d/0x653
> >>   Jan 31 13:07:43 asterix kernel: RSP <ffff8807d30b3928>
> >>   Jan 31 13:07:43 asterix kernel: CR2: 000000000000001c
> >>   Jan 31 13:07:43 asterix kernel: ---[ end trace fba75c5b0b9175ea ]---

This seems to match:
   17027:       49 8b 17                mov    (%r15),%rdx	# page->flags
   1702a:       4c 89 f8                mov    %r15,%rax
   1702d:       80 e6 80                and    $0x80,%dh	# PageTail test
   17030:       74 04                   je     17036 <isolate_migratepages_range+0x2bf>
   17032:       49 8b 47 30             mov    0x30(%r15),%rax	# page = page->first_page
   17036:       8b 40 1c                mov    0x1c(%rax),%eax	<<< page->_count
   17039:       ff c8                   dec    %eax

Which seems to be inlined compound_head. DH is 0x80 so this is a tail
page. This would suggest that tail page doesn't have firs_pages set up
properly and it contains NULL.

But maybe I've just matched the code incorrectly. Could you try to
disassemble your vmlinux a send the generated code, please?

Something like
objdump -d vmlinux > vmlinux.dis
and cut out isolate_migratepages_range function. Or simply upload your
vmlinux.dis somewhere so that we can download it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
