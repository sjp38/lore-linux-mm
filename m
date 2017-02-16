Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 968604405C6
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 02:14:01 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so14285804pfx.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 23:14:01 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id r80si6147608pfa.30.2017.02.15.23.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 23:14:00 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: swap_cluster_info lockdep splat
References: <20170216052218.GA13908@bbox>
Date: Thu, 16 Feb 2017 15:13:55 +0800
In-Reply-To: <20170216052218.GA13908@bbox> (Minchan Kim's message of "Thu, 16
	Feb 2017 14:22:18 +0900")
Message-ID: <874lzubob0.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> With changing from bit lock to spinlock of swap_cluster_info, my zram
> test failed with below message. It seems nested lock problem so need to
> play with lockdep.

Thanks a lot for your testing and report.  There is at least one nested
locking in cluster_list_add_tail(), and there are comments to describe
why it is safe.  I will try to reproduce this and fix it.

Best Regards,
Huang, Ying

> Thanks.
>
> =============================================
> [ INFO: possible recursive locking detected ]
> 4.10.0-rc8-next-20170214-zram #24 Not tainted
> ---------------------------------------------
> as/6557 is trying to acquire lock:
>  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811ddd03>] cluster_list_add_tail.part.31+0x33/0x70
>
> but task is already holding lock:
>  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811df2bb>] swapcache_free_entries+0x9b/0x330
>
> other info that might help us debug this:
>  Possible unsafe locking scenario:
>
>        CPU0
>        ----
>   lock(&(&((cluster_info + ci)->lock))->rlock);
>   lock(&(&((cluster_info + ci)->lock))->rlock);
>
>  *** DEADLOCK ***
>
>  May be due to missing lock nesting notation
>
> 3 locks held by as/6557:
>  #0:  (&(&cache->free_lock)->rlock){......}, at: [<ffffffff811c206b>] free_swap_slot+0x8b/0x110
>  #1:  (&(&p->lock)->rlock){+.+.-.}, at: [<ffffffff811df295>] swapcache_free_entries+0x75/0x330
>  #2:  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811df2bb>] swapcache_free_entries+0x9b/0x330
>
> stack backtrace:
> CPU: 3 PID: 6557 Comm: as Not tainted 4.10.0-rc8-next-20170214-zram #24
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> Call Trace:
>  dump_stack+0x85/0xc2
>  __lock_acquire+0x15ea/0x1640
>  lock_acquire+0x100/0x1f0
>  ? cluster_list_add_tail.part.31+0x33/0x70
>  _raw_spin_lock+0x38/0x50
>  ? cluster_list_add_tail.part.31+0x33/0x70
>  cluster_list_add_tail.part.31+0x33/0x70
>  swapcache_free_entries+0x2f9/0x330
>  free_swap_slot+0xf8/0x110
>  swapcache_free+0x36/0x40
>  delete_from_swap_cache+0x5f/0xa0
>  try_to_free_swap+0x6e/0xa0
>  free_pages_and_swap_cache+0x7d/0xb0
>  tlb_flush_mmu_free+0x36/0x60
>  tlb_finish_mmu+0x1c/0x50
>  exit_mmap+0xc7/0x150
>  mmput+0x51/0x110
>  do_exit+0x2b2/0xc30
>  ? trace_hardirqs_on_caller+0x129/0x1b0
>  do_group_exit+0x50/0xd0
>  SyS_exit_group+0x14/0x20
>  entry_SYSCALL_64_fastpath+0x23/0xc6
> RIP: 0033:0x2b9a2dbdf309
> RSP: 002b:00007ffe71887528 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00002b9a2dbdf309
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
> RBP: 00002b9a2ded8858 R08: 000000000000003c R09: 00000000000000e7
> R10: ffffffffffffff60 R11: 0000000000000246 R12: 00002b9a2ded8858
> R13: 00002b9a2dedde80 R14: 000000000255f770 R15: 0000000000000001

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
