Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id C66F38E0001
	for <linux-mm@kvack.org>; Tue, 25 Dec 2018 16:48:26 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id m10so1557731lfk.6
        for <linux-mm@kvack.org>; Tue, 25 Dec 2018 13:48:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13-v6sor20719897ljj.25.2018.12.25.13.48.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Dec 2018 13:48:24 -0800 (PST)
Date: Wed, 26 Dec 2018 00:48:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Invalid opcode in khugepaged
Message-ID: <20181225214820.milma7qbohhhbzk2@kshutemo-mobl1>
References: <2aa66a9c-b8dc-b630-11e6-234dbce68b5b@gmail.com>
 <1644239b-560b-1c0b-2333-cfb65106949f@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1644239b-560b-1c0b-2333-cfb65106949f@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Heiner Kallweit <hkallweit1@gmail.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Jerome Glisse <jglisse@redhat.com>

On Mon, Dec 24, 2018 at 10:30:26AM -0800, Mike Kravetz wrote:
> Adding people more familiar with this code and changes that went into 4.20.
> 
> On 12/24/18 3:02 AM, Heiner Kallweit wrote:
> > I just got the following error. It's for the first time that I see it.
> > It happened whilst machine was idle, nothing special running.
> > 
> > See also second error below. Not sure whether both errors may be related.
> > 
> > [17932.571487] invalid opcode: 0000 [#1] SMP
> > [17932.571518] CPU: 2 PID: 203 Comm: khugepaged Not tainted 4.20.0-rc7-next-20181221+ #2
> > [17932.571550] Hardware name: NA ZBOX-CI327NANO-GS-01/ZBOX-CI327NANO-GS-01, BIOS 5.12 04/26/2018
> > [17932.571614] RIP: 0010:khugepaged+0x2a2/0x2280
> > [17932.571640] Code: c0 48 8b 4d d0 65 48 33 0c 25 28 00 00 00 0f 85 22 1e 00 00 48 8d 65 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8 30 43 ec ff e9 1e <fe> ff ff 48 8d 45 a0 48 8b 15 88 cc cc 00 49 c7 c4 90 f5 aa 85 48
> > [17932.571721] RSP: 0018:ffffab4b801f7dc0 EFLAGS: 00010286
> > [17932.571751] RAX: 0000000000000000 RBX: 0000000000002710 RCX: 0000000000000000
> > [17932.571786] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff94c23a8c2a80
> > [17932.571820] RBP: ffffab4b801f7f9a R08: 0000000000000000 R09: 0000000000000000
> > [17932.571855] R10: 0000000000000000 R11: 0000000000000000 R12: ffffab4b801f7e20
> > [17932.571890] R13: ffffffff86862720 R14: 0000000000000000 R15: 00000000000000d0
> > [17932.571928] FS:  0000000000000000(0000) GS:ffff94c23bb00000(0000) knlGS:0000000000000000
> > [17932.571967] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [17932.571997] CR2: 00007f20c458f012 CR3: 0000000171213000 CR4: 00000000003406e0
> > [17932.572034] Call Trace:
> > [17932.572061]  ? wait_woken+0xa0/0xa0
> > [17932.572088]  ? kthread+0x126/0x140
> > [17932.572111]  ? __collapse_huge_page_swapin+0x540/0x540
> > [17932.572141]  ? kthread_create_on_node+0x60/0x60
> > [17932.572172]  ? ret_from_fork+0x3a/0x50
> > [17932.572197] Modules linked in: snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic vfat fat x86_pkg_temp_thermal realtek snd_hda_intel i2c_i801 i915 snd_hda_codec r8169 snd_hda_core intel_gtt i2c_algo_bit snd_pcm libphy drm_kms_helper snd_timer syscopyarea sysfillrect sysimgblt fb_sys_fops snd mei_me drm mei usb_storage crypto_user efivarfs ipv6 serio_raw atkbd libps2 xhci_pci xhci_hcd usbcore usb_common i8042 serio ext4 crc32c_intel mbcache jbd2 ahci libahci libata

All code
========
   0:	c0 48 8b 4d          	rorb   $0x4d,-0x75(%rax)
   4:	d0 65 48             	shlb   0x48(%rbp)
   7:	33 0c 25 28 00 00 00 	xor    0x28,%ecx
   e:	0f 85 22 1e 00 00    	jne    0x1e36
  14:	48 8d 65 d8          	lea    -0x28(%rbp),%rsp
  18:	5b                   	pop    %rbx
  19:	41 5c                	pop    %r12
  1b:	41 5d                	pop    %r13
  1d:	41 5e                	pop    %r14
  1f:	41 5f                	pop    %r15
  21:	5d                   	pop    %rbp
  22:*	c3                   	retq   		<-- trapping instruction
  23:	e8 30 43 ec ff       	callq  0xffffffffffec4358
  28:	e9 1e fe ff ff       	jmpq   0xfffffffffffffe4b
  2d:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  31:	48 8b 15 88 cc cc 00 	mov    0xcccc88(%rip),%rdx        # 0xccccc0
  38:	49 c7 c4 90 f5 aa 85 	mov    $0xffffffff85aaf590,%r12
  3f:	48                   	rex.W

Code starting with the faulting instruction
===========================================
   0:	fe                   	(bad)  
   1:	ff                   	(bad)  
   2:	ff 48 8d             	decl   -0x73(%rax)
   5:	45 a0 48 8b 15 88 cc 	rex.RB movabs 0x4900cccc88158b48,%al
   c:	cc 00 49 
   f:	c7 c4 90 f5 aa 85    	mov    $0x85aaf590,%esp
  15:	48                   	rex.W


It looks like somebody jumped into the middle of the instruction. I have no idea
why and how. Maybe stack corruption?

-- 
 Kirill A. Shutemov
