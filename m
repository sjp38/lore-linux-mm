Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BBA036B0062
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 18:41:50 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so94451pde.29
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 15:41:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id td10si23572603pac.222.2014.04.22.15.41.49
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 15:41:49 -0700 (PDT)
Message-ID: <5356F028.4060409@intel.com>
Date: Tue, 22 Apr 2014 15:41:44 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Dirty/Access bits vs. page content
References: <1398032742.19682.11.camel@pasglop>	<CA+55aFz1sK+PF96LYYZY7OB7PBpxZu-uNLWLvPiRz-tJsBqX3w@mail.gmail.com>	<1398054064.19682.32.camel@pasglop>	<1398057630.19682.38.camel@pasglop>	<CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com>	<53558507.9050703@zytor.com>	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>	<53559F48.8040808@intel.com>	<CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>	<20140422075459.GD11182@twins.programming.kicks-ass.net>	<CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>	<5356E33F.3000908@intel.com> <CA+55aFxcPzHZ28CSyzq4sLakDLXVWgzQzk_D0SqU0qq5kW9cAg@mail.gmail.com>
In-Reply-To: <CA+55aFxcPzHZ28CSyzq4sLakDLXVWgzQzk_D0SqU0qq5kW9cAg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On 04/22/2014 03:08 PM, Linus Torvalds wrote:
> On Tue, Apr 22, 2014 at 2:46 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>>
>> I just triggered it a second time.  It only happens with my debugging
>> config[1] *and* those two fix patches.  It doesn't happen on the vanilla
>> kernel with lost dirty bit.
> 
> Ok. So looking at it some more, I'm becoming more and more convinced
> that we do need to make that set_page_dirty() call in
> free_pages_and_swap_cache() be a set_page_dirty_lock() instead.
> 
> Does that make things work for you?

Nope, didn't appear to do anything different.

> [  160.607904] EXT4-fs (loop0): mounted filesystem with ordered data mode. Opts: (null)
> [  173.093239] ------------[ cut here ]------------
> [  173.097884] kernel BUG at /home/davehans/linux.git/fs/ext4/inode.c:2377!
> [  173.104695] invalid opcode: 0000 [#1] SMP 
> [  173.108849] CPU: 65 PID: 4286 Comm: racewrite_threa Not tainted 3.15.0-rc2+ #392
> [  173.116383] Hardware name: FUJITSU-SV PRIMEQUEST 1800E2/SB, BIOS PRIMEQUEST 1000 Series BIOS Version 1.24 09/14/2011
> [  173.127174] task: ffff887ff1909140 ti: ffff887ff2048000 task.ti: ffff887ff2048000
> [  173.134799] RIP: 0010:[<ffffffff81204810>]  [<ffffffff81204810>] mpage_prepare_extent_to_map+0x320/0x330
> [  173.144432] RSP: 0018:ffff887ff2049c68  EFLAGS: 00010246
> [  173.149819] RAX: 0000000000000041 RBX: ffff887ff2049dc8 RCX: ffff88bff2e52b48
> [  173.157080] RDX: 6bfffc000002003d RSI: 0000000000000167 RDI: ffffffff819c1ce8
> [  173.164341] RBP: ffff887ff2049d48 R08: ffffea037fbdb980 R09: 0000000000000001
> [  173.171603] R10: 0000000000000000 R11: 0000000000000220 R12: 7fffffffffffffff
> [  173.178864] R13: 0000000000000041 R14: ffff887ff2049ca8 R15: ffff887ff2049ca8
> [  173.186125] FS:  00007fe361e37700(0000) GS:ffff88dfffaa0000(0000) knlGS:0000000000000000
> [  173.194381] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  173.200214] CR2: 00007fe3aa70a000 CR3: 0000005fefdd9000 CR4: 00000000000007e0
> [  173.207475] Stack:
> [  173.209506]  ffffea037fbdb980 ffff887ff2049ca8 ffff88bff2e52b48 0000000000000000
> [  173.217017]  0000000000000000 0000000000000001 0000000000000000 ffffea037fbdb980
> [  173.224527]  0000000000000003 0000000000000286 ffff887ff1909140 ffff883ff2730800
> [  173.232038] Call Trace:
> [  173.234527]  [<ffffffff81233fcc>] ? __ext4_journal_start_sb+0x7c/0x120
> [  173.241159]  [<ffffffff8120af6b>] ? ext4_writepages+0x44b/0xce0
> [  173.247166]  [<ffffffff8120afa4>] ext4_writepages+0x484/0xce0
> [  173.253001]  [<ffffffff81123933>] do_writepages+0x23/0x40
> [  173.258479]  [<ffffffff811165f9>] __filemap_fdatawrite_range+0x59/0x60
> [  173.265112]  [<ffffffff8111b3f5>] SyS_fadvise64_64+0x265/0x270
> [  173.271031]  [<ffffffff8111b40e>] SyS_fadvise64+0xe/0x10
> [  173.276429]  [<ffffffff816d8a29>] system_call_fastpath+0x16/0x1b
> [  173.282513] Code: ff e9 6d ff ff ff 48 8d bd 48 ff ff ff e8 b9 20 f2 ff e9 31 ff ff ff 48 8b 4b 08 8b 49 20 85 c9 0f 85 ee fd ff ff 31 c0 eb b3 90 <0f> 0b 0f 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 
> [  173.301685] RIP  [<ffffffff81204810>] mpage_prepare_extent_to_map+0x320/0x330
> [  173.308933]  RSP <ffff887ff2049c68>
> [  173.312576] ---[ end trace b53fdf1d352b727a ]---


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
