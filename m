Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D1F3C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 08:51:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B62021019
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 08:51:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B62021019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68ECF8E000F; Wed,  2 Jan 2019 03:51:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63F748E0002; Wed,  2 Jan 2019 03:51:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52E748E000F; Wed,  2 Jan 2019 03:51:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 209EC8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 03:51:06 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id 123so35501401itv.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 00:51:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=WB0LvXswhy7tE7XnbY0bhz8Q5r5rtXi7F75d7q5Dp+o=;
        b=o4hy3EYP5qaCQFrxbyr/3uwfKwK5d4DrxVBT8SbDkp9X9PbFu3rQnNg7MYPeilA0i/
         Aen0miWM+z9T4G8Ml97tUa9KNgsENvE2FxcoYCjG9mlIiRE5dcSYeWrycTuXQGcDTawP
         tKPRdlZcqthTRc2zhG5W6z00o9NjA8XhseGiu/WkmZNzUE6Wqi82S9QYmJO/bjZbubt1
         yRHyopLZbG8yLcUopb4mvRqKcGYAJXF2CuIg+s5j8H2TLJ/MzpIObnGCe0kCz6bcFnKn
         /f6sRZMFWvgijJsYQdBCVEaPxZ+bEWAuwFnAQX1qJO6XckaYr2uRyIGT5k1H+kww3XKv
         aGHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3d3ssxakbaag067sittmzixxql.owwotm20mzkwv1mv1.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3d3ssXAkbAAg067sittmzixxql.owwotm20mzkwv1mv1.kwu@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukfUBAmVLCv9wroueCwaBNDmKt+vJPI5z+Fu9xm7kSb3GBcXjEWL
	qXwJwVAnTR7ncGVUvXnIU06YJ6novnJLwVvDZ5mGWtfZwSFSmQfXhPpK7ooZBdagAaSyyB9yw5B
	3Ke0AMRba8upElIKbB2AWx4EBzcxj7A6nWA0uvANg7xqFOdz3cBosTL9R0uNqeBONKRGc/NkmT5
	PEleJE6mjyv2vbN+V9fF3FthYP0DHABGqO6d2DHfJ1kRaPqQb1mgL/PyBj0WUiJoN5caDVEWDM5
	YptpTidZ/FshxXdEqZjHE6In5q4bFpMhtr6Cgink1YVBF4UqtXTQuCk9jI40LMT3/AUCoXaIXTQ
	3jm7bnHbxKjxIMnDPLHjpnTAWwagzoyq7VLC2u9spzeZueVA+8xbb3BtvGwHSxIGi9IFVLMAqA=
	=
X-Received: by 2002:a6b:440e:: with SMTP id r14mr32723934ioa.78.1546419065756;
        Wed, 02 Jan 2019 00:51:05 -0800 (PST)
X-Received: by 2002:a6b:440e:: with SMTP id r14mr32723893ioa.78.1546419063958;
        Wed, 02 Jan 2019 00:51:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546419063; cv=none;
        d=google.com; s=arc-20160816;
        b=oD8Ut9eRqHBj3xSmebA4w9gr0TBcIgZzPPjopq/mmzQoPI8FXA5UmVQHmLZK3ZUoOu
         0JPhJ7wRazoZ4ncu9SaJizyLhCLXdCHPibJxsEdengGei/wxy0RC5aHQlAns8eFkZO99
         bdApNpsic0FYh1Q58GQh+A1qhmboUZ+etaDo8KzxRkujbiuPMprwlJH7hNWCJ3YDns69
         MBPoNtHxomevOSZqlgbmpdrZ1ygYIi7yphpG+6lGPdWq6ApIGHVHCaOfTow0cIiZW06L
         nPRC7Jb7jcdweMmRIuscs7E17TikK5/FC3SpWR48+TfrDqX96DKQfxmcd1/GAOfl/lTl
         b+IQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=WB0LvXswhy7tE7XnbY0bhz8Q5r5rtXi7F75d7q5Dp+o=;
        b=XzySsouTnUJM1C9+hoGxHqkjLAgqo6e2mF+v1RT9jICtj0lz/bruzremxCeHbGz+Ph
         hQidKvGmYXVxuz1OxrEltkO6fUzZTHF+aqq8nryme0UiIrXjDA338roC8vV6vtWnpvLK
         23cNMJYnBSKe6/90Dr5v2Iw/13pjCBqfi7re4znCX0ajnd6e0CSYcYID4UG+IaBExufo
         i5Ndc7BY6GNrPOTBY2YxB++3+xMbmurbIifGO5+GJXFSKUoD+UgcOnqdIhAgr47NKJw8
         XeUFqb4ooCARb372i0qOGMqght5DRoZr57RlZ3l92Zc2c2b1mUy7jhfodFums+T7T3gb
         3yYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3d3ssxakbaag067sittmzixxql.owwotm20mzkwv1mv1.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3d3ssXAkbAAg067sittmzixxql.owwotm20mzkwv1mv1.kwu@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v17sor6853134ion.74.2019.01.02.00.51.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 00:51:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3d3ssxakbaag067sittmzixxql.owwotm20mzkwv1mv1.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3d3ssxakbaag067sittmzixxql.owwotm20mzkwv1mv1.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3d3ssXAkbAAg067sittmzixxql.owwotm20mzkwv1mv1.kwu@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN4YYLfNAvUq4ExthDdqIYinm63Q8iSweb3xbRDnp2CzxasxkTw8QYcS0U8X6RGWPY0GpyPMbg2BjWOa0/zZ49vYs+YFbJ3G
MIME-Version: 1.0
X-Received: by 2002:a5e:d50b:: with SMTP id e11mr6877103iom.25.1546419063648;
 Wed, 02 Jan 2019 00:51:03 -0800 (PST)
Date: Wed, 02 Jan 2019 00:51:03 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000f67ca2057e75bec3@google.com>
Subject: possible deadlock in __wake_up_common_lock
From: syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>
To: aarcange@redhat.com, akpm@linux-foundation.org, 
	kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, 
	rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, 
	xieyisheng1@huawei.com, zhongjiang@huawei.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102085103.SNmrwcJR_XKyRIzfpvnALdY37KsXAr7Z--DpTGpR58Q@z>

Hello,

syzbot found the following crash on:

HEAD commit:    f346b0becb1b Merge branch 'akpm' (patches from Andrew)
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1510cefd400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c255c77ba370fe7c
dashboard link: https://syzkaller.appspot.com/bug?extid=93d94a001cfbce9e60e1
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
userspace arch: i386

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com


======================================================
WARNING: possible circular locking dependency detected
4.20.0+ #297 Not tainted
------------------------------------------------------
syz-executor0/8529 is trying to acquire lock:
000000005e7fb829 (&pgdat->kswapd_wait){....}, at:  
__wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120

but task is already holding lock:
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: spin_lock  
include/linux/spinlock.h:329 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_bulk  
mm/page_alloc.c:2548 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: __rmqueue_pcplist  
mm/page_alloc.c:3021 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_pcplist  
mm/page_alloc.c:3050 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue  
mm/page_alloc.c:3072 [inline]
000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at:  
get_page_from_freelist+0x1bae/0x52a0 mm/page_alloc.c:3491

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #4 (&(&zone->lock)->rlock){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
        rmqueue mm/page_alloc.c:3082 [inline]
        get_page_from_freelist+0x9eb/0x52a0 mm/page_alloc.c:3491
        __alloc_pages_nodemask+0x4f3/0xde0 mm/page_alloc.c:4529
        __alloc_pages include/linux/gfp.h:473 [inline]
        alloc_page_interleave+0x25/0x1c0 mm/mempolicy.c:1988
        alloc_pages_current+0x1bf/0x210 mm/mempolicy.c:2104
        alloc_pages include/linux/gfp.h:509 [inline]
        depot_save_stack+0x3f1/0x470 lib/stackdepot.c:260
        save_stack+0xa9/0xd0 mm/kasan/common.c:79
        set_track mm/kasan/common.c:85 [inline]
        kasan_kmalloc+0xcb/0xd0 mm/kasan/common.c:482
        kasan_slab_alloc+0x12/0x20 mm/kasan/common.c:397
        kmem_cache_alloc+0x130/0x730 mm/slab.c:3541
        kmem_cache_zalloc include/linux/slab.h:731 [inline]
        fill_pool lib/debugobjects.c:134 [inline]
        __debug_object_init+0xbb8/0x1290 lib/debugobjects.c:379
        debug_object_init lib/debugobjects.c:431 [inline]
        debug_object_activate+0x323/0x600 lib/debugobjects.c:512
        debug_timer_activate kernel/time/timer.c:708 [inline]
        debug_activate kernel/time/timer.c:763 [inline]
        __mod_timer kernel/time/timer.c:1040 [inline]
        mod_timer kernel/time/timer.c:1101 [inline]
        add_timer+0x50e/0x1490 kernel/time/timer.c:1137
        __queue_delayed_work+0x249/0x380 kernel/workqueue.c:1533
        queue_delayed_work_on+0x1a2/0x1f0 kernel/workqueue.c:1558
        queue_delayed_work include/linux/workqueue.h:527 [inline]
        schedule_delayed_work include/linux/workqueue.h:628 [inline]
        start_dirtytime_writeback+0x4e/0x53 fs/fs-writeback.c:2043
        do_one_initcall+0x145/0x957 init/main.c:889
        do_initcall_level init/main.c:957 [inline]
        do_initcalls init/main.c:965 [inline]
        do_basic_setup init/main.c:983 [inline]
        kernel_init_freeable+0x4c1/0x5af init/main.c:1136
        kernel_init+0x11/0x1ae init/main.c:1056
        ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352

-> #3 (&base->lock){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
        lock_timer_base+0xbb/0x2b0 kernel/time/timer.c:937
        __mod_timer kernel/time/timer.c:1009 [inline]
        mod_timer kernel/time/timer.c:1101 [inline]
        add_timer+0x895/0x1490 kernel/time/timer.c:1137
        __queue_delayed_work+0x249/0x380 kernel/workqueue.c:1533
        queue_delayed_work_on+0x1a2/0x1f0 kernel/workqueue.c:1558
        queue_delayed_work include/linux/workqueue.h:527 [inline]
        schedule_delayed_work include/linux/workqueue.h:628 [inline]
        psi_group_change kernel/sched/psi.c:485 [inline]
        psi_task_change+0x3f1/0x5f0 kernel/sched/psi.c:534
        psi_enqueue kernel/sched/stats.h:82 [inline]
        enqueue_task kernel/sched/core.c:727 [inline]
        activate_task+0x21a/0x430 kernel/sched/core.c:751
        wake_up_new_task+0x527/0xd20 kernel/sched/core.c:2423
        _do_fork+0x33b/0x11d0 kernel/fork.c:2247
        kernel_thread+0x34/0x40 kernel/fork.c:2281
        rest_init+0x28/0x372 init/main.c:409
        arch_call_rest_init+0xe/0x1b
        start_kernel+0x873/0x8ae init/main.c:741
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:470
        x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:451
        secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243

-> #2 (&rq->lock){-.-.}:
        __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
        _raw_spin_lock+0x2d/0x40 kernel/locking/spinlock.c:144
        rq_lock kernel/sched/sched.h:1149 [inline]
        task_fork_fair+0xb0/0x6d0 kernel/sched/fair.c:10083
        sched_fork+0x443/0xba0 kernel/sched/core.c:2359
        copy_process+0x25b9/0x8790 kernel/fork.c:1893
        _do_fork+0x1cb/0x11d0 kernel/fork.c:2222
        kernel_thread+0x34/0x40 kernel/fork.c:2281
        rest_init+0x28/0x372 init/main.c:409
        arch_call_rest_init+0xe/0x1b
        start_kernel+0x873/0x8ae init/main.c:741
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:470
        x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:451
        secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243

-> #1 (&p->pi_lock){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
        try_to_wake_up+0xdc/0x1460 kernel/sched/core.c:1965
        default_wake_function+0x30/0x50 kernel/sched/core.c:3710
        autoremove_wake_function+0x80/0x370 kernel/sched/wait.c:375
        __wake_up_common+0x1d7/0x7d0 kernel/sched/wait.c:92
        __wake_up_common_lock+0x1c2/0x330 kernel/sched/wait.c:121
        __wake_up+0xe/0x10 kernel/sched/wait.c:145
        wakeup_kswapd+0x5f0/0x930 mm/vmscan.c:3982
        wake_all_kswapds+0x150/0x300 mm/page_alloc.c:3975
        __alloc_pages_slowpath+0x1ff1/0x2db0 mm/page_alloc.c:4246
        __alloc_pages_nodemask+0xa89/0xde0 mm/page_alloc.c:4549
        alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
        alloc_pages include/linux/gfp.h:509 [inline]
        __get_free_pages+0xc/0x40 mm/page_alloc.c:4573
        pte_alloc_one_kernel+0x15/0x20 arch/x86/mm/pgtable.c:28
        __pte_alloc_kernel+0x23/0x220 mm/memory.c:439
        vmap_pte_range mm/vmalloc.c:144 [inline]
        vmap_pmd_range mm/vmalloc.c:171 [inline]
        vmap_pud_range mm/vmalloc.c:188 [inline]
        vmap_p4d_range mm/vmalloc.c:205 [inline]
        vmap_page_range_noflush+0x878/0xa80 mm/vmalloc.c:230
        vmap_page_range mm/vmalloc.c:243 [inline]
        vm_map_ram+0x46c/0xf60 mm/vmalloc.c:1181
        ion_heap_clear_pages+0x2a/0x70  
drivers/staging/android/ion/ion_heap.c:100
        ion_heap_sglist_zero+0x24f/0x2d0  
drivers/staging/android/ion/ion_heap.c:121
        ion_heap_buffer_zero+0xf8/0x150  
drivers/staging/android/ion/ion_heap.c:143
        ion_system_heap_free+0x227/0x290  
drivers/staging/android/ion/ion_system_heap.c:163
        ion_buffer_destroy+0x15c/0x1c0 drivers/staging/android/ion/ion.c:119
        _ion_heap_freelist_drain+0x43e/0x6a0  
drivers/staging/android/ion/ion_heap.c:199
        ion_heap_freelist_drain+0x1f/0x30  
drivers/staging/android/ion/ion_heap.c:209
        ion_buffer_create drivers/staging/android/ion/ion.c:86 [inline]
        ion_alloc+0x487/0xa60 drivers/staging/android/ion/ion.c:409
        ion_ioctl+0x216/0x41e drivers/staging/android/ion/ion-ioctl.c:76
        __do_compat_sys_ioctl fs/compat_ioctl.c:1052 [inline]
        __se_compat_sys_ioctl fs/compat_ioctl.c:998 [inline]
        __ia32_compat_sys_ioctl+0x20e/0x630 fs/compat_ioctl.c:998
        do_syscall_32_irqs_on arch/x86/entry/common.c:326 [inline]
        do_fast_syscall_32+0x34d/0xfb2 arch/x86/entry/common.c:397
        entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139

-> #0 (&pgdat->kswapd_wait){....}:
        lock_acquire+0x1ed/0x520 kernel/locking/lockdep.c:3841
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
        __wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120
        __wake_up+0xe/0x10 kernel/sched/wait.c:145
        wakeup_kswapd+0x5f0/0x930 mm/vmscan.c:3982
        steal_suitable_fallback+0x538/0x830 mm/page_alloc.c:2217
        __rmqueue_fallback mm/page_alloc.c:2502 [inline]
        __rmqueue mm/page_alloc.c:2528 [inline]
        rmqueue_bulk mm/page_alloc.c:2550 [inline]
        __rmqueue_pcplist mm/page_alloc.c:3021 [inline]
        rmqueue_pcplist mm/page_alloc.c:3050 [inline]
        rmqueue mm/page_alloc.c:3072 [inline]
        get_page_from_freelist+0x318c/0x52a0 mm/page_alloc.c:3491
        __alloc_pages_nodemask+0x4f3/0xde0 mm/page_alloc.c:4529
        alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
        alloc_pages include/linux/gfp.h:509 [inline]
        __get_free_pages+0xc/0x40 mm/page_alloc.c:4573
        tlb_next_batch mm/mmu_gather.c:29 [inline]
        __tlb_remove_page_size+0x2e5/0x500 mm/mmu_gather.c:133
        __tlb_remove_page include/asm-generic/tlb.h:187 [inline]
        zap_pte_range mm/memory.c:1093 [inline]
        zap_pmd_range mm/memory.c:1192 [inline]
        zap_pud_range mm/memory.c:1221 [inline]
        zap_p4d_range mm/memory.c:1242 [inline]
        unmap_page_range+0xf88/0x25b0 mm/memory.c:1263
        unmap_single_vma+0x19b/0x310 mm/memory.c:1308
        unmap_vmas+0x221/0x390 mm/memory.c:1339
        exit_mmap+0x2be/0x590 mm/mmap.c:3140
        __mmput kernel/fork.c:1051 [inline]
        mmput+0x247/0x610 kernel/fork.c:1072
        exit_mm kernel/exit.c:545 [inline]
        do_exit+0xdeb/0x2620 kernel/exit.c:854
        do_group_exit+0x177/0x440 kernel/exit.c:970
        get_signal+0x8b0/0x1980 kernel/signal.c:2517
        do_signal+0x9c/0x21c0 arch/x86/kernel/signal.c:816
        exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
        prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
        syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
        do_syscall_32_irqs_on arch/x86/entry/common.c:341 [inline]
        do_fast_syscall_32+0xcd5/0xfb2 arch/x86/entry/common.c:397
        entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139

other info that might help us debug this:

Chain exists of:
   &pgdat->kswapd_wait --> &base->lock --> &(&zone->lock)->rlock

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&(&zone->lock)->rlock);
                                lock(&base->lock);
                                lock(&(&zone->lock)->rlock);
   lock(&pgdat->kswapd_wait);

  *** DEADLOCK ***

2 locks held by syz-executor0/8529:
  #0: 000000001be7b4ca (&(ptlock_ptr(page))->rlock#2){+.+.}, at: spin_lock  
include/linux/spinlock.h:329 [inline]
  #0: 000000001be7b4ca (&(ptlock_ptr(page))->rlock#2){+.+.}, at:  
zap_pte_range mm/memory.c:1051 [inline]
  #0: 000000001be7b4ca (&(ptlock_ptr(page))->rlock#2){+.+.}, at:  
zap_pmd_range mm/memory.c:1192 [inline]
  #0: 000000001be7b4ca (&(ptlock_ptr(page))->rlock#2){+.+.}, at:  
zap_pud_range mm/memory.c:1221 [inline]
  #0: 000000001be7b4ca (&(ptlock_ptr(page))->rlock#2){+.+.}, at:  
zap_p4d_range mm/memory.c:1242 [inline]
  #0: 000000001be7b4ca (&(ptlock_ptr(page))->rlock#2){+.+.}, at:  
unmap_page_range+0x98e/0x25b0 mm/memory.c:1263
  #1: 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: spin_lock  
include/linux/spinlock.h:329 [inline]
  #1: 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_bulk  
mm/page_alloc.c:2548 [inline]
  #1: 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: __rmqueue_pcplist  
mm/page_alloc.c:3021 [inline]
  #1: 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_pcplist  
mm/page_alloc.c:3050 [inline]
  #1: 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue  
mm/page_alloc.c:3072 [inline]
  #1: 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at:  
get_page_from_freelist+0x1bae/0x52a0 mm/page_alloc.c:3491

stack backtrace:
CPU: 0 PID: 8529 Comm: syz-executor0 Not tainted 4.20.0+ #297
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
  print_circular_bug.isra.34.cold.56+0x1bd/0x27d  
kernel/locking/lockdep.c:1224
  check_prev_add kernel/locking/lockdep.c:1866 [inline]
  check_prevs_add kernel/locking/lockdep.c:1979 [inline]
  validate_chain kernel/locking/lockdep.c:2350 [inline]
  __lock_acquire+0x3360/0x4c20 kernel/locking/lockdep.c:3338
  lock_acquire+0x1ed/0x520 kernel/locking/lockdep.c:3841
  __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
  _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
  __wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120
  __wake_up+0xe/0x10 kernel/sched/wait.c:145
  wakeup_kswapd+0x5f0/0x930 mm/vmscan.c:3982
  steal_suitable_fallback+0x538/0x830 mm/page_alloc.c:2217
  __rmqueue_fallback mm/page_alloc.c:2502 [inline]
  __rmqueue mm/page_alloc.c:2528 [inline]
  rmqueue_bulk mm/page_alloc.c:2550 [inline]
  __rmqueue_pcplist mm/page_alloc.c:3021 [inline]
  rmqueue_pcplist mm/page_alloc.c:3050 [inline]
  rmqueue mm/page_alloc.c:3072 [inline]
  get_page_from_freelist+0x318c/0x52a0 mm/page_alloc.c:3491
  __alloc_pages_nodemask+0x4f3/0xde0 mm/page_alloc.c:4529
  alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
  alloc_pages include/linux/gfp.h:509 [inline]
  __get_free_pages+0xc/0x40 mm/page_alloc.c:4573
  tlb_next_batch mm/mmu_gather.c:29 [inline]
  __tlb_remove_page_size+0x2e5/0x500 mm/mmu_gather.c:133
  __tlb_remove_page include/asm-generic/tlb.h:187 [inline]
  zap_pte_range mm/memory.c:1093 [inline]
  zap_pmd_range mm/memory.c:1192 [inline]
  zap_pud_range mm/memory.c:1221 [inline]
  zap_p4d_range mm/memory.c:1242 [inline]
  unmap_page_range+0xf88/0x25b0 mm/memory.c:1263
  unmap_single_vma+0x19b/0x310 mm/memory.c:1308
  unmap_vmas+0x221/0x390 mm/memory.c:1339
  exit_mmap+0x2be/0x590 mm/mmap.c:3140
  __mmput kernel/fork.c:1051 [inline]
  mmput+0x247/0x610 kernel/fork.c:1072
  exit_mm kernel/exit.c:545 [inline]
  do_exit+0xdeb/0x2620 kernel/exit.c:854
  do_group_exit+0x177/0x440 kernel/exit.c:970
  get_signal+0x8b0/0x1980 kernel/signal.c:2517
  do_signal+0x9c/0x21c0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_32_irqs_on arch/x86/entry/common.c:341 [inline]
  do_fast_syscall_32+0xcd5/0xfb2 arch/x86/entry/common.c:397
  entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139
RIP: 0023:0xf7fe3849
Code: Bad RIP value.
RSP: 002b:00000000f5f9d0cc EFLAGS: 00000296 ORIG_RAX: 0000000000000036
RAX: 0000000000000000 RBX: 0000000000000005 RCX: 00000000c0184900
RDX: 0000000020000080 RSI: 0000000000000000 RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
syz-executor0 (8529) used greatest stack depth: 10424 bytes left
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (00000000c253515f): kobject_uevent_env
kobject: 'loop2' (00000000c253515f): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (00000000c253515f): kobject_uevent_env
kobject: 'loop2' (00000000c253515f): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
audit: type=1326 audit(1546069676.863:33): auid=4294967295 uid=0 gid=0  
ses=4294967295 subj==unconfined pid=8664 comm="syz-executor1"  
exe="/root/syz-executor1" sig=31 arch=40000003 syscall=265 compat=1  
ip=0xf7f82849 code=0x0
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (00000000c253515f): kobject_uevent_env
kobject: 'loop2' (00000000c253515f): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (00000000c253515f): kobject_uevent_env
kobject: 'loop2' (00000000c253515f): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop2' (00000000c253515f): kobject_uevent_env
kobject: 'loop2' (00000000c253515f): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop2' (00000000c253515f): kobject_uevent_env
kobject: 'loop2' (00000000c253515f): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (00000000c7588ca8): kobject_uevent_env
kobject: 'loop5' (00000000c7588ca8): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop2' (00000000c253515f): kobject_uevent_env
kobject: 'loop2' (00000000c253515f): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop4' (00000000ebe25695): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000ebe25695): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop0' (000000002925f66c): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop0' (000000002925f66c): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): kobject_uevent_env
kobject: 'loop3' (0000000061a5b8df): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000eddbbf94): kobject_uevent_env
kobject: 'kvm' (00000000eddbbf94): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (0000000003dfbc9f): kobject_uevent_env
kobject: 'loop1' (0000000003dfbc9f): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (00000000c253515f): kobject_uevent_env
kobject: 'loop2' (00000000c253515f): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
WARNING: CPU: 0 PID: 8908 at net/bridge/netfilter/ebtables.c:2086  
ebt_size_mwt net/bridge/netfilter/ebtables.c:2086 [inline]
WARNING: CPU: 0 PID: 8908 at net/bridge/netfilter/ebtables.c:2086  
size_entry_mwt net/bridge/netfilter/ebtables.c:2167 [inline]
WARNING: CPU: 0 PID: 8908 at net/bridge/netfilter/ebtables.c:2086  
compat_copy_entries+0x1088/0x1500 net/bridge/netfilter/ebtables.c:2206


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.

