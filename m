Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC056B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:55:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b127so38237828lfe.10
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 11:55:34 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id s65si2300867lfi.167.2017.03.28.11.55.31
        for <linux-mm@kvack.org>;
        Tue, 28 Mar 2017 11:55:31 -0700 (PDT)
Date: Tue, 28 Mar 2017 20:55:22 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHv2 6/8] x86/dump_pagetables: Add support 5-level paging
Message-ID: <20170328185522.5akqgfh4niqi3ptf@pd.tnic>
References: <20170328093946.GA30567@gmail.com>
 <20170328104806.41711-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170328104806.41711-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 28, 2017 at 01:48:06PM +0300, Kirill A. Shutemov wrote:
> Simple extension to support one more page table level.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/mm/dump_pagetables.c | 59 +++++++++++++++++++++++++++++++++----------
>  1 file changed, 45 insertions(+), 14 deletions(-)

Hmm, so without this I get the splat below.

Can we do something about this bisection breakage? I mean, this is the
second explosion caused by 5level paging I trigger. Maybe we should
merge the whole thing into a single big patch when everything is applied
and tested, more or less, so that bisection is fine.

Or someone might have a better idea...

[    2.801262] BUG: unable to handle kernel paging request at ffffc753f000f000
[    2.803013] IP: ptdump_walk_pgd_level_core+0x236/0x3a0
[    2.804472] PGD 0 
[    2.804473] P4D 0 
[    2.805231] 
[    2.805231] Oops: 0000 [#1] PREEMPT SMP
[    2.805231] Modules linked in:
[    2.805231] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.11.0-rc4+ #1
[    2.805231] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[    2.805231] task: ffff88007c1c8040 task.stack: ffffc90000008000
[    2.805231] RIP: 0010:ptdump_walk_pgd_level_core+0x236/0x3a0
[    2.805231] RSP: 0018:ffffc9000000be48 EFLAGS: 00010256
[    2.805231] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
[    2.805231] RDX: ffff880000001000 RSI: ffff880000000000 RDI: ffffc9000000bed0
[    2.805231] RBP: ffffc9000000bef8 R08: 0000000000000000 R09: 000000000000017f
[    2.805231] R10: 000000000000001f R11: 0000000000000001 R12: ffffc9000000be90
[    2.805231] R13: 0000000000000000 R14: ffffc753f000f000 R15: 00000000ffffff00
[    2.805231] FS:  0000000000000000(0000) GS:ffff88007ed00000(0000) knlGS:0000000000000000
[    2.805231] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    2.805231] CR2: ffffc753f000f000 CR3: 0000000001c09000 CR4: 00000000000406e0
[    2.805231] Call Trace:
[    2.805231]  ? 0xffffffff81000000
[    2.805231]  ptdump_walk_pgd_level_checkwx+0x17/0x20
[    2.805231]  mark_rodata_ro+0xec/0x100
[    2.805231]  ? rest_init+0x90/0x90
[    2.805231]  kernel_init+0x2a/0x100
[    2.805231]  ret_from_fork+0x2e/0x40
[    2.805231] Code: 00 88 ff ff 48 8b 5d 88 4c 8d 34 10 48 ba 00 10 00 00 00 88 ff ff 48 01 d0 48 89 85 70 ff ff ff 48 89 d8 48 c1 f8 10 48 89 45 b0 <49> 8b 06 48 a9 9f ff ff ff 74 7c 48 89 c1 48 be ff 0f 00 00 00 
[    2.805231] RIP: ptdump_walk_pgd_level_core+0x236/0x3a0 RSP: ffffc9000000be48
[    2.805231] CR2: ffffc753f000f000
[    2.805231] ---[ end trace 3ec6e2c757df799d ]---
[    2.805231] Kernel panic - not syncing: Fatal exception
[    2.805231] Kernel Offset: disabled
[    2.805231] ---[ end Kernel panic - not syncing: Fatal exception

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
