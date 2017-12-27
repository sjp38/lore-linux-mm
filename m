Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 230496B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 15:50:21 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id z3so22190103pln.6
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 12:50:21 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id o1si24927641plk.131.2017.12.27.12.50.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Dec 2017 12:50:19 -0800 (PST)
Message-ID: <1514407817.4169.4.camel@HansenPartnership.com>
Subject: Re: Hang with v4.15-rc trying to swap back in
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 27 Dec 2017 12:50:17 -0800
In-Reply-To: <1514398340.3986.10.camel@HansenPartnership.com>
References: <1514398340.3986.10.camel@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Reverting these three patches fixes the problem:

commit aa8d22a11da933dbf880b4933b58931f4aefe91c
Author: Minchan Kim <minchan@kernel.org>
Date:A A A Wed Nov 15 17:33:11 2017 -0800

A A A A mm: swap: SWP_SYNCHRONOUS_IO: skip swapcache only if swapped page
has no other reference

commit 0bcac06f27d7528591c27ac2b093ccd71c5d0168
Author: Minchan Kim <minchan@kernel.org>
Date:A A A Wed Nov 15 17:33:07 2017 -0800

A A A A mm, swap: skip swapcache for swapin of synchronous device

Also need to revert:

commit e9a6effa500526e2a19d5ad042cb758b55b1ef93
Author: Huang Ying <huang.ying.caritas@gmail.com>
Date:A A A Wed Nov 15 17:33:15 2017 -0800

A A A A mm, swap: fix false error message in __swp_swapcount()

(The latter is simply because it used a function that is eliminated by
one of the other reversions). A They came into the merge window via the
-mm tree as part of a 4 part series:

Subject:	[PATCH v2 0/4] skip swapcache for super fast device
Message-Id:	<1505886205-9671-1-git-send-email-minchan@kernel.org
>

James

On Wed, 2017-12-27 at 10:12 -0800, James Bottomley wrote:
> I think I've seen this a lot shutting down systems, but never manged
> to trace it before. A Now I can reproduce it starting kvm on a 4GB
> system with 3GB of memory and booting up a linux OS. A What eventually
> happens (after logging into the virtual system) is that kvm itself
> hangs, although the stuck process is one of the kworkers in D wait
> hung on this stack trace:
> 
> [<0>] io_schedule+0x12/0x40
> [<0>] __lock_page_or_retry+0x2b8/0x300
> [<0>] do_swap_page+0x1b9/0x910
> [<0>] __handle_mm_fault+0x7ee/0xe20
> [<0>] handle_mm_fault+0xce/0x1e0
> [<0>] __get_user_pages+0x104/0x6c0
> [<0>] get_user_pages_remote+0x84/0x1f0
> [<0>] async_pf_execute+0x67/0x1a0 [kvm]
> [<0>] process_one_work+0x13c/0x370
> [<0>] worker_thread+0x44/0x3e0
> [<0>] kthread+0xf5/0x130
> [<0>] ret_from_fork+0x1f/0x30
> [<0>] 0xffffffffffffffff
> 
> The async_pf_execute() is a kvm async callback, failure to execute it
> appears to be causing the kvm hang.
> 
> Next to go is kswapd
> 
> [<0>] io_schedule+0x12/0x40
> [<0>] __lock_page+0xec/0x120
> [<0>] deferred_split_scan+0x21b/0x2a0
> [<0>] shrink_slab+0x24a/0x460
> [<0>] shrink_node+0x2e6/0x2f0
> [<0>] kswapd+0x2ad/0x730
> [<0>] kthread+0xf5/0x130
> [<0>] ret_from_fork+0x1f/0x30
> [<0>] 0xffffffffffffffff
> 
> And finally systemd-logind hangs making it very difficult to get into
> the system (and impossible to shut it down)
> 
> [<0>] call_rwsem_down_write_failed+0x13/0x20
> [<0>] register_shrinker+0x45/0xa0
> [<0>] sget_userns+0x44d/0x480
> [<0>] mount_nodev+0x2a/0xa0
> [<0>] mount_fs+0x34/0x150
> [<0>] vfs_kern_mount+0x62/0x120
> [<0>] do_mount+0x1d7/0xbf0
> [<0>] SyS_mount+0x7e/0xd0
> [<0>] do_syscall_64+0x5b/0x100
> [<0>] entry_SYSCALL64_slow_path+0x25/0x25
> [<0>] 0xffffffffffffffff
> 
> I've seen this with -rc1 and -rc5, so I think it's some problem with
> merge window code.
> 
> James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
