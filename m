Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 92253900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 14:11:16 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p6VIBC39017073
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 11:11:14 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by kpbe14.cbf.corp.google.com with ESMTP id p6VIBARW005987
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 11:11:10 -0700
Received: by pzd13 with SMTP id 13so8892512pzd.25
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 11:11:10 -0700 (PDT)
Date: Sun, 31 Jul 2011 11:11:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <CA+55aFw9V-VM5TBwqdKiP0E_g8urth+08nX-_inZ8N1_gFQF4w@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1107302301450.13155@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <CA+55aFzut1tF6CLAPJUUh2H_7M4wcDpp2+Zb85Lqvofe+3v_jQ@mail.gmail.com> <CA+55aFw9V-VM5TBwqdKiP0E_g8urth+08nX-_inZ8N1_gFQF4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 30 Jul 2011, Linus Torvalds wrote:

> Oh, and another thing worth checking: did somebody actually check the
> timings for:
> 
>  - *just* the alignment change?
> 
>    IOW, maybe some of the netperf improvement isn't from the lockless
> path, but exactly from 'struct page' always being in a single
> cacheline?
> 

Without the lockless slowpath and only the struct page alignment, the 
performance improved only 0.18% compared to vanilla 3.0-rc5, which 
slub/lockless is based on.  I've only benchmarked this in Pekka's slab 
tree, I haven't looked at your tree since it was merged.

>  - check performance with cmpxchg16b *without* the alignment.
> 
>    Sometimes especially intel is so good at unaligned accesses that
> you wouldn't see an issue. Now, locked ops are usually special (and
> crossing cachelines with a locked op is dubious at best), so there may
> actually be correctness issues involved too, but it would be
> interesting to hear if anybody actually just tried it.
> 

If the alignment is removed and struct page is restructured back to what 
it was plus the additions required for the lockless slowpath with 
cmpxchg16b then it becomes not so happy on my testing cluster:

[    0.000000] general protection fault: 0000 [#1] SMP 
[    0.000000] CPU 0 
[    0.000000] Modules linked in:
[    0.000000] 
[    0.000000] Pid: 0, comm: swapper Not tainted 3.0.0-slub_noalign #1
[    0.000000] RIP: 0010:[<ffffffff81198f84>]  [<ffffffff81198f84>] get_partial_node+0xa4/0x1a0
[    0.000000] RSP: 0000:ffffffff81801d78  EFLAGS: 00010002
[    0.000000] RAX: ffff88047f801040 RBX: 0000000000000000 RCX: 0000000180400040
[    0.000000] RDX: 0000000100400001 RSI: ffff88047f801040 RDI: ffffea000fbe4048
[    0.000000] RBP: ffffffff81801de8 R08: ffff88047fc132c0 R09: ffffffff8119e69c
[    0.000000] R10: 0000000000001800 R11: 0000000000001000 R12: ffffea000fbe4038
[    0.000000] R13: ffff88047f800100 R14: ffff88047f801000 R15: ffff88047f801010
[    0.000000] FS:  0000000000000000(0000) GS:ffff88047fc00000(0000) knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.000000] CR2: 0000000000000000 CR3: 0000000001803000 CR4: 00000000000006b0
[    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    0.000000] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    0.000000] Process swapper (pid: 0, threadinfo ffffffff81800000, task ffffffff8180b020)
[    0.000000] Stack:
[    0.000000]  ffff88107ffd8e00 0000000000000000 ffff88047ffda1d8 0000000180400040
[    0.000000]  ffff00066c0a0100 ffffffff8108a1f9 ffffffff81801dc8 ffffffff815a543c
[    0.000000]  0000000000000000 ffffffff8180b020 0000000000000000 ffff88047f800100
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff8108a1f9>] ? __might_sleep+0x9/0xf0
[    0.000000]  [<ffffffff815a543c>] ? mutex_lock+0x2c/0x60
[    0.000000]  [<ffffffff8119df35>] kmem_cache_alloc_node+0x135/0x560
[    0.000000]  [<ffffffff8119e69c>] ? kmem_cache_open+0x33c/0x580
[    0.000000]  [<ffffffff81199cf6>] ? calculate_sizes+0x16/0x3f0
[    0.000000]  [<ffffffff8119e69c>] kmem_cache_open+0x33c/0x580
[    0.000000]  [<ffffffff81194df6>] ? alloc_pages_current+0x96/0x130
[    0.000000]  [<ffffffff818c6c25>] kmem_cache_init+0xbb/0x462
[    0.000000]  [<ffffffff818a3ce7>] start_kernel+0x1be/0x39e
[    0.000000]  [<ffffffff818a3520>] x86_64_start_kernel+0x203/0x20a
[    0.000000] Code: 10 48 89 55 a8 41 0f b7 44 24 1a 80 4d ab 80 66 25 ff 7f 66 89 45 a8 48 8b 4d a8 9c 58 41 f6 45 0b 40 0f 84 7f 00 00 00 48 89 f0 <f0> 48 0f c7 0f 0f 94 c0 84 c0 0f 84 86 00 00 00 49 8b 54 24 20 
[    0.000000] RIP  [<ffffffff81198f84>] get_partial_node+0xa4/0x1a0
[    0.000000]  RSP <ffffffff81801d78>
[    0.000000] ---[ end trace 4eaa2a86a8e2da22 ]---
[    0.000000] Kernel panic - not syncing: Fatal exception
[    0.000000] Pid: 0, comm: swapper Not tainted 3.0.0-slub_noalign #1
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff815a33fb>] panic+0x91/0x198
[    0.000000]  [<ffffffff81052b87>] die+0x247/0x260
[    0.000000]  [<ffffffff815a7952>] do_general_protection+0x162/0x170
[    0.000000]  [<ffffffff815a716f>] general_protection+0x1f/0x30
[    0.000000]  [<ffffffff8119e69c>] ? kmem_cache_open+0x33c/0x580
[    0.000000]  [<ffffffff81198f84>] ? get_partial_node+0xa4/0x1a0
[    0.000000]  [<ffffffff8108a1f9>] ? __might_sleep+0x9/0xf0
[    0.000000]  [<ffffffff815a543c>] ? mutex_lock+0x2c/0x60
[    0.000000]  [<ffffffff8119df35>] kmem_cache_alloc_node+0x135/0x560
[    0.000000]  [<ffffffff8119e69c>] ? kmem_cache_open+0x33c/0x580
[    0.000000]  [<ffffffff81199cf6>] ? calculate_sizes+0x16/0x3f0
[    0.000000]  [<ffffffff8119e69c>] kmem_cache_open+0x33c/0x580
[    0.000000]  [<ffffffff81194df6>] ? alloc_pages_current+0x96/0x130
[    0.000000]  [<ffffffff818c6c25>] kmem_cache_init+0xbb/0x462
[    0.000000]  [<ffffffff818a3ce7>] start_kernel+0x1be/0x39e
[    0.000000]  [<ffffffff818a3520>] x86_64_start_kernel+0x203/0x20a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
