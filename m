Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 74DB98E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:59:00 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id j3so201876itf.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:59:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r203sor1623763ita.23.2019.01.17.01.58.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 01:58:59 -0800 (PST)
MIME-Version: 1.0
References: <000000000000cdc61b057f9e360e@google.com> <e4cb6380-b462-857e-3219-319fdbfa6f81@suse.cz>
In-Reply-To: <e4cb6380-b462-857e-3219-319fdbfa6f81@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 17 Jan 2019 10:58:47 +0100
Message-ID: <CACT4Y+ZG1LLb_7ZyhijWJxLbrbBuP_h2++RWUfnZ65Dj9=MNkw@mail.gmail.com>
Subject: Re: kernel BUG at mm/page_alloc.c:LINE!
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+80dd4798c16c634daf15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On Thu, Jan 17, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 1/17/19 3:33 AM, syzbot wrote:
> > Hello> syzbot found the following crash on:
> >
> > HEAD commit:    b808822a75a3 Add linux-next specific files for 20190111
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=16a471d8c00000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=c052ead0aed5001b
> > dashboard link: https://syzkaller.appspot.com/bug?extid=80dd4798c16c634daf15
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> >
> > Unfortunately, I don't have any reproducer for this crash yet.
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+80dd4798c16c634daf15@syzkaller.appspotmail.com
> >
> > ------------[ cut here ]------------
> > kernel BUG at mm/page_alloc.c:3112!
>
> Why does the mail subject say LINE, anyway?

The title is what syzbot uses as bug identity and for deduplication purposes.
We have to remove some moving parts, like lines/addresses/etc, so that
it does not create a new bug whenever the line changes:
https://github.com/google/syzkaller/blob/43689bcfed82ecb780bd0e54543609fe3c080623/pkg/report/report.go#L166-L168


> > invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> > CPU: 0 PID: 1043 Comm: kcompactd0 Not tainted 5.0.0-rc1-next-20190111 #10
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > RIP: 0010:__isolate_free_page+0x4a8/0x680 mm/page_alloc.c:3112
>
> That's BUG_ON(!PageBuddy(page)); in __isolate_free_page().
>
> > Code: 4c 39 e3 77 c0 0f b6 8d 74 ff ff ff b8 01 00 00 00 48 d3 e0 e9 11 fd
> > ff ff 48 c7 c6 a0 63 52 88 4c 89 e7 e8 6a 14 10 00 0f 0b <0f> 0b 48 c7 c6
> > c0 64 52 88 4c 89 e7 e8 57 14 10 00 0f 0b 48 89 cf
> > RSP: 0000:ffff8880a78e6f58 EFLAGS: 00010007
> > RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88812fffc7e0
> > RDX: 1ffff11025fff8fc RSI: 0000000000000007 RDI: ffff88812fffc7b0
> > RBP: ffff8880a78e7018 R08: ffff8880a78ce000 R09: ffffed1014f1cdf2
> > R10: ffffed1014f1cdf1 R11: 0000000000000003 R12: ffff88812fffc7b0
> > R13: 1ffff11014f1cdf2 R14: ffff88812fffc7b0 R15: ffff8880a78e6ff0
> > FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000000438ca0 CR3: 0000000009871000 CR4: 00000000001426f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> > Call Trace:
> >   fast_isolate_freepages mm/compaction.c:1356 [inline]
>
> Mel's new code... but might be just a victim of e.g. bad struct page
> initialization?
>
> >   isolate_freepages mm/compaction.c:1429 [inline]
> >   compaction_alloc+0xd05/0x2970 mm/compaction.c:1541
> >   unmap_and_move mm/migrate.c:1177 [inline]
> >   migrate_pages+0x48e/0x2cc0 mm/migrate.c:1417
> >   compact_zone+0x2207/0x3e90 mm/compaction.c:2173
> >   kcompactd_do_work+0x6de/0x1200 mm/compaction.c:2564
> >   kcompactd+0x251/0x970 mm/compaction.c:2657
> >   kthread+0x357/0x430 kernel/kthread.c:247
> >   ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
> > Modules linked in:
> >
> > ======================================================
> > WARNING: possible circular locking dependency detected
> > 5.0.0-rc1-next-20190111 #10 Not tainted
> > ------------------------------------------------------
>
> Dunno about that, but doesn't seem to be the root cause anyway.
>
> > -> #0 (console_owner){-.-.}:
> >         lock_acquire+0x1db/0x570 kernel/locking/lockdep.c:3860
> >         console_lock_spinning_enable kernel/printk/printk.c:1647 [inline]
> >         console_unlock+0x516/0x1040 kernel/printk/printk.c:2452
> >         vprintk_emit+0x370/0x960 kernel/printk/printk.c:1978
> >         vprintk_default+0x28/0x30 kernel/printk/printk.c:2005
> >         vprintk_func+0x7e/0x189 kernel/printk/printk_safe.c:398
> >         printk+0xba/0xed kernel/printk/printk.c:2038
> >         report_bug.cold+0x11/0x5e lib/bug.c:191
> >         fixup_bug arch/x86/kernel/traps.c:178 [inline]
> >         fixup_bug arch/x86/kernel/traps.c:173 [inline]
> >         do_error_trap+0x11b/0x200 arch/x86/kernel/traps.c:271
> >         do_invalid_op+0x37/0x50 arch/x86/kernel/traps.c:290
> >         invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:973
> >         __ClearPageBuddy include/linux/page-flags.h:706 [inline]
>
> So that's VM_BUG_ON_PAGE(!Page##uname(page), page); in
> __ClearPage##uname, so another problem with !PageBuddy.
>
> >         rmv_page_order mm/page_alloc.c:744 [inline]
> >         rmv_page_order mm/page_alloc.c:742 [inline]
> >         __isolate_free_page+0x4a8/0x680 mm/page_alloc.c:3134
>
> But this is later in the function than the first BUG_ON, so something
> has raced with us?
>
> Also two kcompactd crashes with slightly different stacktraces, that
> would have to be a NUMA system with multiple kcompactd's?
>
> >         fast_isolate_freepages mm/compaction.c:1356 [inline]
> >         isolate_freepages mm/compaction.c:1429 [inline]
> >         compaction_alloc+0xd05/0x2970 mm/compaction.c:1541
> >         unmap_and_move mm/migrate.c:1177 [inline]
> >         migrate_pages+0x48e/0x2cc0 mm/migrate.c:1417
> >         compact_zone+0x2207/0x3e90 mm/compaction.c:2173
> >         kcompactd_do_work+0x6de/0x1200 mm/compaction.c:2564
> >         kcompactd+0x251/0x970 mm/compaction.c:2657
> >         kthread+0x357/0x430 kernel/kthread.c:247
> >         ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/e4cb6380-b462-857e-3219-319fdbfa6f81%40suse.cz.
> For more options, visit https://groups.google.com/d/optout.
