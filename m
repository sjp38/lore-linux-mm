Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EEEE6B000D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 06:40:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v9-v6so1187036pfn.6
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 03:40:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34-v6sor964975plz.138.2018.08.08.03.40.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 03:40:45 -0700 (PDT)
Date: Wed, 8 Aug 2018 19:40:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [4.18 rc7] BUG: sleeping function called from invalid context at
 mm/slab.h:421
Message-ID: <20180808104041.GA873@jagdpanzerIV>
References: <CABXGCsNAjrwat-Fv6GQXq8uSC6uj=ke87RJt42syrfFi0vQUmg@mail.gmail.com>
 <bd7f3ea4-d9a8-e437-9936-ee4513b47ac1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bd7f3ea4-d9a8-e437-9936-ee4513b47ac1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Jiri Slaby <jslaby@suse.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm@kvack.org, Petr Mladek <pmladek@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Peter Zijlstra <peterz@infradead.org>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On (08/08/18 11:01), Vlastimil Babka wrote:
> On 08/08/2018 05:50 AM, Mikhail Gavrilov wrote:
> > Hi guys.
> > I am catched new bug.
> > Can anyone look?
> 
> fbcon_startup() calls kzalloc(sizeof(struct fbcon_ops), GFP_KERNEL) so
> it tells slab it can sleep. The problem must be higher in the stack,
> CCing printk people.

Cc-ing fbcon/vt people. I'm not sure I know how exactly console
takeover is expected to work.

printk must be atomic, we can't sleep in console drivers [e.g. printk
from IRQs, etc.]

> > [226995.988988] BUG: sleeping function called from invalid context at
> > mm/slab.h:421
> > [226995.988988] in_atomic(): 1, irqs_disabled(): 1, pid: 22658, name: gsd-rfkill
> > [226995.988989] INFO: lockdep is turned off.
> > [226995.988989] irq event stamp: 0
> > [226995.988990] hardirqs last  enabled at (0): [<0000000000000000>]
> >        (null)
> > [226995.988991] hardirqs last disabled at (0): [<ffffffffa00b6b4a>]
> > copy_process.part.32+0x72a/0x1e60
> > [226995.988991] softirqs last  enabled at (0): [<ffffffffa00b6b4a>]
> > copy_process.part.32+0x72a/0x1e60
> > [226995.988992] softirqs last disabled at (0): [<0000000000000000>]
> >        (null)
> > [226995.988993] CPU: 6 PID: 22658 Comm: gsd-rfkill Tainted: G        W
> >         4.18.0-0.rc7.git1.1.fc29.x86_64 #1
> > [226995.988993] Hardware name: Gigabyte Technology Co., Ltd.
> > Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> > [226995.988994] Call Trace:
> > [226995.988994]  dump_stack+0x85/0xc0
> > [226995.988995]  ___might_sleep.cold.72+0xac/0xbc
> > [226995.988995]  kmem_cache_alloc_trace+0x202/0x2f0
> > [226995.988996]  ? fbcon_startup+0xae/0x300
> > [226995.988996]  fbcon_startup+0xae/0x300
> > [226995.988997]  do_take_over_console+0x6d/0x180
> > [226995.988997]  do_fbcon_takeover+0x58/0xb0
> > [226995.988997]  fbcon_output_notifier.cold.35+0x5/0x23
> > [226995.988998]  notifier_call_chain+0x39/0x90
> > [226995.988999]  vt_console_print+0x363/0x420
> > [226995.988999]  console_unlock+0x422/0x610
> > [226995.988999]  vprintk_emit+0x268/0x540
> > [226995.989000]  printk+0x58/0x6f
> > [226995.989000]  rfkill_fop_release.cold.16+0xc/0x11 [rfkill]
> > [226995.989001]  __fput+0xc7/0x250
> > [226995.989001]  task_work_run+0xa1/0xd0
> > [226995.989002]  exit_to_usermode_loop+0xd8/0xe0
> > [226995.989002]  do_syscall_64+0x1df/0x1f0
> > [226995.989003]  entry_SYSCALL_64_after_hwframe+0x49/0xbe

	-ss
