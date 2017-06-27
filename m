Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB016B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 02:46:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o3so8978856qto.15
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 23:46:00 -0700 (PDT)
Received: from mail-qt0-x231.google.com (mail-qt0-x231.google.com. [2607:f8b0:400d:c0d::231])
        by mx.google.com with ESMTPS id x24si2029823qtb.1.2017.06.26.23.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 23:45:59 -0700 (PDT)
Received: by mail-qt0-x231.google.com with SMTP id 32so17720630qtv.1
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 23:45:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <594d905d.geNp0UO7DULvNDPS%akpm@linux-foundation.org>
References: <594d905d.geNp0UO7DULvNDPS%akpm@linux-foundation.org>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Tue, 27 Jun 2017 14:45:57 +0800
Message-ID: <CAC=cRTNJe5Bo-1E+3oJEbWM8Yt5SyZOhnUiC9U5OK0GWrp1E0g@mail.gmail.com>
Subject: Re: mmotm 2017-06-23-15-03 uploaded
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz, Mark Brown <broonie@kernel.org>

On Sat, Jun 24, 2017 at 6:04 AM,  <akpm@linux-foundation.org> wrote:
> * mm-page_allocc-eliminate-unsigned-confusion-in-__rmqueue_fallback.patch

After git bisecting, find the above patch will cause the following bug
on i386 with memory eater + swap.

[   10.657876] BUG: unable to handle kernel paging request at 001fe2b8
[   10.658412] IP: set_pfnblock_flags_mask+0x50/0x80
[   10.658779] *pde = 00000000
[   10.658779]
[   10.659126] Oops: 0000 [#1] SMP
[   10.659372] CPU: 0 PID: 1403 Comm: usemem Not tainted 4.12.0-rc6-mm1+ #12
[   10.659888] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.10.2-1 04/01/2014
[   10.660522] task: f54a4c40 task.stack: f54ee000
[   10.660878] EIP: set_pfnblock_flags_mask+0x50/0x80
[   10.661246] EFLAGS: 00010006 CPU: 0
[   10.661517] EAX: 0007f8ae EBX: 00000000 ECX: 00000009 EDX: 00000200
[   10.661994] ESI: 001fe2b8 EDI: 00000e00 EBP: f54efd8c ESP: f54efd80
[   10.662473]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   10.662891] CR0: 80050033 CR2: 001fe2b8 CR3: 356a3000 CR4: 00000690
[   10.663378] Call Trace:
[   10.663577]  set_pageblock_migratetype+0x31/0x40
[   10.663933]  __rmqueue+0x367/0x560
[   10.664197]  get_page_from_freelist+0x5b7/0x8e0
[   10.664546]  __alloc_pages_nodemask+0x31a/0x1000
[   10.664913]  ? handle_mm_fault+0x1e8/0x840
[   10.665230]  handle_mm_fault+0x71d/0x840
[   10.665537]  __do_page_fault+0x175/0x400
[   10.665848]  ? vmalloc_sync_all+0x190/0x190
[   10.666173]  do_page_fault+0xb/0x10
[   10.666446]  common_exception+0x64/0x6a
[   10.666742] EIP: 0x8005e04c
[   10.666959] EFLAGS: 00010246 CPU: 0
[   10.667229] EAX: 07d47400 EBX: 80063000 ECX: bfc964d8 EDX: 67179000
[   10.667705] ESI: 07d47400 EDI: 07d47400 EBP: 00000000 ESP: bfc962cc
[   10.668180]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   10.668595]  ? vmalloc_sync_all+0x190/0x190
[   10.668922] Code: 8b 5b 28 25 00 fc ff ff 29 c1 89 c8 b9 1f 00 00
00 2b 4d 08 c1 e8 0a c1 e0 02 89 c6 c1 e8 05 83 e6 1f 29 f1 8d 34 83
d3 e7 d3 e2 <8b> 1e f7 d7 eb 0c 8d 76 00 8d bc 27 00 00 00 00 89 c3 89
d9 89
[   10.670369] EIP: set_pfnblock_flags_mask+0x50/0x80 SS:ESP: 0068:f54efd80
[   10.670881] CR2: 00000000001fe2b8
[   10.671140] ---[ end trace f51518af57e6b531 ]---

I think this comes from the signed and unsigned int comparison on
i386.  The gcc version is,

gcc (Debian 6.3.0-18) 6.3.0 20170516

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
