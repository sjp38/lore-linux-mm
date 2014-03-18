Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 86F5A6B011C
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 17:22:19 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so7941101pad.29
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 14:22:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id m9si13332225pab.44.2014.03.18.14.22.18
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 14:22:18 -0700 (PDT)
Date: Tue, 18 Mar 2014 14:22:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kswapd using __this_cpu_add() in preemptible code
Message-Id: <20140318142216.317bf986d10a564881791100@linux-foundation.org>
In-Reply-To: <20140318185329.GB430@swordfish>
References: <20140318185329.GB430@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>

On Tue, 18 Mar 2014 21:53:30 +0300 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> Hello gentlemen,
> 
> Commit 589a606f9539663f162e4a110d117527833b58a4 ("percpu: add preemption
> checks to __this_cpu ops") added preempt check to used in __count_vm_events()
> __this_cpu ops, causing the following kswapd warning:
> 
>  BUG: using __this_cpu_add() in preemptible [00000000] code: kswapd0/56
>  caller is __this_cpu_preempt_check+0x2b/0x2d
>  Call Trace:
>  [<ffffffff813b8d4d>] dump_stack+0x4e/0x7a
>  [<ffffffff8121366f>] check_preemption_disabled+0xce/0xdd
>  [<ffffffff812136bb>] __this_cpu_preempt_check+0x2b/0x2d
>  [<ffffffff810f622e>] inode_lru_isolate+0xed/0x197
>  [<ffffffff810be43c>] list_lru_walk_node+0x7b/0x14c
>  [<ffffffff810f6141>] ? iput+0x131/0x131
>  [<ffffffff810f681f>] prune_icache_sb+0x35/0x4c
>  [<ffffffff810e3951>] super_cache_scan+0xe3/0x143
>  [<ffffffff810b1301>] shrink_slab_node+0x103/0x16f
>  [<ffffffff810b19fd>] shrink_slab+0x75/0xe4
>  [<ffffffff810b3f3d>] balance_pgdat+0x2fa/0x47f
>  [<ffffffff810b4395>] kswapd+0x2d3/0x2fd
>  [<ffffffff81068049>] ? __wake_up_sync+0xd/0xd
>  [<ffffffff810b40c2>] ? balance_pgdat+0x47f/0x47f
>  [<ffffffff81051e75>] kthread+0xd6/0xde
>  [<ffffffff81051d9f>] ? kthread_create_on_node+0x162/0x162
>  [<ffffffff813be5bc>] ret_from_fork+0x7c/0xb0
>  [<ffffffff81051d9f>] ? kthread_create_on_node+0x162/0x162
> 
> 
> list_lru_walk_node() seems to be the only place where __count_vm_events()
> called with preemption enabled. remaining __count_vm_events() and
> __count_vm_event() calls are done with preemption disabled (unless I
> overlooked something).

Christoph caught one.  How does this look?



From: Andrew Morton <akpm@linux-foundation.org>
Subject: fs/inode.c:inode_lru_isolate(): use atomic count_vm_events()

"percpu: add preemption checks to __this_cpu ops" added preempt check to
used in __count_vm_events() __this_cpu ops, causing the following kswapd
warning:

 BUG: using __this_cpu_add() in preemptible [00000000] code: kswapd0/56
 caller is __this_cpu_preempt_check+0x2b/0x2d
 Call Trace:
 [<ffffffff813b8d4d>] dump_stack+0x4e/0x7a
 [<ffffffff8121366f>] check_preemption_disabled+0xce/0xdd
 [<ffffffff812136bb>] __this_cpu_preempt_check+0x2b/0x2d
 [<ffffffff810f622e>] inode_lru_isolate+0xed/0x197
 [<ffffffff810be43c>] list_lru_walk_node+0x7b/0x14c
 [<ffffffff810f6141>] ? iput+0x131/0x131
 [<ffffffff810f681f>] prune_icache_sb+0x35/0x4c

Switch from __count_vm_events() to the preempt-safe count_vm_events().

Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/inode.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN fs/inode.c~fs-inodec-inode_lru_isolate-use-atomic-count_vm_events fs/inode.c
--- a/fs/inode.c~fs-inodec-inode_lru_isolate-use-atomic-count_vm_events
+++ a/fs/inode.c
@@ -722,9 +722,9 @@ inode_lru_isolate(struct list_head *item
 			unsigned long reap;
 			reap = invalidate_mapping_pages(&inode->i_data, 0, -1);
 			if (current_is_kswapd())
-				__count_vm_events(KSWAPD_INODESTEAL, reap);
+				count_vm_events(KSWAPD_INODESTEAL, reap);
 			else
-				__count_vm_events(PGINODESTEAL, reap);
+				count_vm_events(PGINODESTEAL, reap);
 			if (current->reclaim_state)
 				current->reclaim_state->reclaimed_slab += reap;
 		}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
