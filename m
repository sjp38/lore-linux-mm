Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id B00196B0033
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 10:31:31 -0400 (EDT)
Received: by mail-bk0-f49.google.com with SMTP id mz10so821926bkb.22
        for <linux-mm@kvack.org>; Fri, 28 Jun 2013 07:31:30 -0700 (PDT)
Date: Fri, 28 Jun 2013 18:31:26 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130628143124.GA6552@localhost.localdomain>
References: <20130618024623.GP29338@dastard>
 <20130618063104.GB20528@localhost.localdomain>
 <20130618082414.GC13677@dhcp22.suse.cz>
 <20130618104443.GH13677@dhcp22.suse.cz>
 <20130618135025.GK13677@dhcp22.suse.cz>
 <20130625022754.GP29376@dastard>
 <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
 <20130628083943.GA32747@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628083943.GA32747@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 10:39:43AM +0200, Michal Hocko wrote:
> I have just triggered this one.
> 
> [37955.364062] RIP: 0010:[<ffffffff81127e5b>]  [<ffffffff81127e5b>] list_lru_walk_node+0xab/0x140
> [37955.364062] RSP: 0000:ffff8800374af7b8  EFLAGS: 00010286
> [37955.364062] RAX: 0000000000000106 RBX: ffff88002ead7838 RCX: ffff8800374af830
Note ebx

> [37955.364062] RDX: 0000000000000107 RSI: ffff88001d250dc0 RDI: ffff88002ead77d0
> [37955.364062] RBP: ffff8800374af818 R08: 0000000000000000 R09: ffff88001ffeafc0
> [37955.364062] R10: 0000000000000002 R11: 0000000000000000 R12: ffff88001d250dc0
> [37955.364062] R13: 00000000000000a0 R14: 000000572ead7838 R15: ffff88001d250dc8
Note r14


> [37955.364062] Process as (pid: 3351, threadinfo ffff8800374ae000, task ffff880036d665c0)
> [37955.364062] Stack:
> [37955.364062]  ffff88001da3e700 ffff8800374af830 ffff8800374af838 ffffffff811846d0
> [37955.364062]  0000000000000000 ffff88001ce75c48 01ff8800374af838 ffff8800374af838
> [37955.364062]  0000000000000000 ffff88001ce75800 ffff8800374afa08 0000000000001014
> [37955.364062] Call Trace:
> [37955.364062]  [<ffffffff811846d0>] ? insert_inode_locked+0x160/0x160
> [37955.364062]  [<ffffffff8118496c>] prune_icache_sb+0x3c/0x60
> [37955.364062]  [<ffffffff8116dcbe>] super_cache_scan+0x12e/0x1b0
> [37955.364062]  [<ffffffff8111354a>] shrink_slab_node+0x13a/0x250
> [37955.364062]  [<ffffffff8111671b>] shrink_slab+0xab/0x120
> [37955.364062]  [<ffffffff81117944>] do_try_to_free_pages+0x264/0x360
> [37955.364062]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
> [37955.364062]  [<ffffffff81001974>] ? __switch_to+0x1b4/0x550
> [37955.364062]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
> [37955.364062]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
> [37955.364062]  [<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
> [37955.364062]  [<ffffffff81129ebb>] do_anonymous_page+0x16b/0x350
> [37955.364062]  [<ffffffff8112f9c5>] handle_pte_fault+0x235/0x240
> [37955.364062]  [<ffffffff8107b8b0>] ? set_next_entity+0xb0/0xd0
> [37955.364062]  [<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
> [37955.364062]  [<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
> [37955.364062]  [<ffffffff8116a8a8>] ? fsnotify_access+0x68/0x80
> [37955.364062]  [<ffffffff8116b0b8>] ? vfs_read+0xd8/0x130
> [37955.364062]  [<ffffffff8157ebe9>] do_page_fault+0x9/0x10ffff88002ead7838
> [37955.364062]  [<ffffffff8157b348>] page_fault+0x28/0x30
> [37955.364062] Code: 44 24 18 0f 84 87 00 00 00 49 83 7c 24 18 00 78 7b 49 83 c5 01 48 8b 4d a8 48 8b 11 48 8d 42 ff 48 85 d2 48 89 01 74 78 4d 39 f7 <49> 8b 06 4c 89 f3 74 6d 49 89 c6 eb a6 0f 1f 84 00 00 00 00 00 
> [37955.364062] RIP  [<ffffffff81127e5b>] list_lru_walk_node+0xab/0x140
> 
> ffffffff81127e0e:       48 8b 55 b0             mov    -0x50(%rbp),%rdx
> ffffffff81127e12:       4c 89 e6                mov    %r12,%rsi
> ffffffff81127e15:       48 89 df                mov    %rbx,%rdi
> ffffffff81127e18:       ff 55 b8                callq  *-0x48(%rbp)		# isolate(item, &nlru->lock, cb_arg)
> ffffffff81127e1b:       83 f8 01                cmp    $0x1,%eax
> ffffffff81127e1e:       74 78                   je     ffffffff81127e98 <list_lru_walk_node+0xe8>
> ffffffff81127e20:       73 4e                   jae    ffffffff81127e70 <list_lru_walk_node+0xc0>
> [...]
One interesting thing I have noted here, is that r14 is basically the lower half of rbx, with
the upper part borked.

Because we are talking about a single word, this does not seem the usual update-half-of-double-word
without locking issue.

>From your excerpt, it is not totally clear what r14 is. But by looking at rdi which
is 0xffff88002ead77d0 and very probable nlru->lock due to the calling convention,
that would indicate that this is nlru->list in case you have spinlock debugging enabled.

So yes, someone destroyed our next pointer, and amazingly only half of it.

Still, the only time we ever release this lock is when isolate returns LRU_RETRY. Maybe the
way we restart is wrong? (although I can't see how)

An iput() happens outside the lock in that case, but it seems safe : if that ends up manipulating
the lru it will do so through our accessors.

I will have to think a bit more... Any other strange thing happening before it ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
