Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B4C4B6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:23:40 -0400 (EDT)
Received: by wgen6 with SMTP id n6so23946111wge.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 09:23:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x7si8259815wja.200.2015.04.23.09.23.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 09:23:39 -0700 (PDT)
Date: Thu, 23 Apr 2015 18:23:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150423162311.GB19709@redhat.com>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
 <20150418220803.GB7972@pd.tnic>
 <20150422131219.GD6897@pd.tnic>
 <20150422183309.GA4351@node.dhcp.inet.fi>
 <CA+55aFx5NXDUsyd2qjQ+Uu3mt9Fw4HrsonzREs9V0PhHwWmGPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx5NXDUsyd2qjQ+Uu3mt9Fw4HrsonzREs9V0PhHwWmGPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Wed, Apr 22, 2015 at 12:26:55PM -0700, Linus Torvalds wrote:
> On Wed, Apr 22, 2015 at 11:33 AM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> >
> > Could you try patch below instead? This can give a clue what's going on.
> 
> Just FYI, I've done the revert in my tree.
> 
> Trying to figure out what is going on despite that is obviously a good
> idea, but I'm hoping that my merge window is winding down, so I am
> trying to make sure it's all "good to go"..

Sounds safer to defer it, agreed.

Unfortunately I also can only reproduce it only on a workstation where
it wasn't very handy to debug it as it'd disrupt my workflow and it
isn't equipped with reliable logging either (and the KMS mode didn't
switch to console to show me the oops either). It just got it logged
once in syslog before freezing.

The problem has to be that there's some get_page/put_page activity
before and after a PageAnon transition and it looks like a tail page
got mapped by hand in userland by some driver using 4k ptes which
isn't normal but apparently safe before the patch was applied. Before
the patch, the tail page accounting would be symmetric regardless of
the PageAnon transition.

page:ffffea0010226040 count:0 mapcount:1 mapping:          (null) index:0x0
flags: 0x8000000000008010(dirty|tail)
page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
------------[ cut here ]------------
kernel BUG at mm/swap.c:134!
invalid opcode: 0000 [#1] SMP
Modules linked in: tun usbhid x86_pkg_temp_thermal kvm_intel kvm snd_hda_codec_realtek snd_hd
d_hda_intel xhci_pci ehci_hcd snd_hda_controller xhci_hcd snd_hda_codec snd_hda_core snd_pcm
d psmouse cdrom pcspkr usb_common [last unloaded: microcode]
CPU: 1 PID: 4175 Comm: knotify4 Not tainted 4.0.0+ #18
Hardware name:                  /DH61BE, BIOS BEH6110H.86A.0120.2013.1112.1412 11/12/2013
task: ffff88040ca231e0 ti: ffff8800bd088000 task.ti: ffff8800bd088000
RIP: 0010:[<ffffffff81148baa>]  [<ffffffff81148baa>] put_compound_page+0x31a/0x320
RSP: 0018:ffff8800bd08bc48  EFLAGS: 00010246
RAX: 000000000000003d RBX: ffffea0010226040 RCX: 0000000000000006
RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffff88041f24d310
RBP: ffffea0010226000 R08: 0000000000000400 R09: ffffffff81ccaf54
R10: 00000000000002f3 R11: 00000000000002f2 R12: ffff8800bd08be20
R13: ffff8800bd08be70 R14: 00007ff3d9772000 R15: 0000000000000000
FS:  00007ff3d2693700(0000) GS:ffff88041f240000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f877f137000 CR3: 00000003dd5b4000 CR4: 00000000000407e0
Stack:
ffff8800bd08bd0a ffffea0010226040 ffff8800bd08be38 ffffffff81148dd2
0000000000000002 00000000bd08be20 ffff8800bd08bc78 ffff8800bd08bc78
ffffea00102261c0 ffff8800bd08be20 ffff8800bd08bdf8 ffff8800bd08be20
Call Trace:
[<ffffffff81148dd2>] ? release_pages+0x222/0x260
[<ffffffff81160d80>] ? tlb_flush_mmu_free+0x30/0x50
[<ffffffff81162a00>] ? unmap_single_vma+0x580/0x810
[<ffffffff811634c1>] ? unmap_vmas+0x41/0x90
[<ffffffff81168125>] ? unmap_region+0x85/0xf0
[<ffffffff8116a17d>] ? do_munmap+0x21d/0x390
[<ffffffff8116a32a>] ? vm_munmap+0x3a/0x60
[<ffffffff8116b2ac>] ? SyS_munmap+0x1c/0x30
[<ffffffff8176d897>] ? system_call_fastpath+0x12/0x6a
Code: 81 48 89 ef e8 08 6d 01 00 0f 0b 48 c7 c6 f0 e9 9c 81 48 89 ef e8 f7 6c 01 00 0f 0b 48
e8 e6 6c 01 00 <0f> 0b 0f 1f 40 00 41 57 41 56 41 55 41 54 55 53 48 83 ec 28 85
RIP  [<ffffffff81148baa>] put_compound_page+0x31a/0x320
RSP <ffff8800bd08bc48>
---[ end trace 81df9d42bd21b1f5 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
