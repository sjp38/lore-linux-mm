Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 13B266B004D
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 13:01:58 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id c26so5873522qad.14
        for <linux-mm@kvack.org>; Sat, 17 Nov 2012 10:01:57 -0800 (PST)
Message-ID: <50A7D0FA.2080709@gmail.com>
Date: Sat, 17 Nov 2012 13:01:30 -0500
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 4/7] mm: introduce compaction and migration for ballooned
 pages
References: <cover.1352656285.git.aquini@redhat.com> <6602296b38c073a5c6faa13ddbc74ceb1eceb2dd.1352656285.git.aquini@redhat.com>
In-Reply-To: <6602296b38c073a5c6faa13ddbc74ceb1eceb2dd.1352656285.git.aquini@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>

Hi guys,

On 11/11/2012 02:01 PM, Rafael Aquini wrote:
> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
> 
> This patch introduces the helper functions as well as the necessary changes
> to teach compaction and migration bits how to cope with pages which are
> part of a guest memory balloon, in order to make them movable by memory
> compaction procedures.
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> ---

I'm getting the following while fuzzing using trinity inside a KVM tools guest,
on latest -next:

[ 1642.783728] BUG: unable to handle kernel NULL pointer dereference at 0000000000000194
[ 1642.785083] IP: [<ffffffff8122b354>] isolate_migratepages_range+0x344/0x7b0
[ 1642.786061] PGD 39e80067 PUD 39f6d067 PMD 0
[ 1642.786766] Oops: 0000 [#3] PREEMPT SMP DEBUG_PAGEALLOC
[ 1642.787587] CPU 0
[ 1642.787884] Pid: 8522, comm: trinity-child5 Tainted: G      D W    3.7.0-rc5-next-20121115-sasha-00013-g37271d3 #154
[ 1642.789483] RIP: 0010:[<ffffffff8122b354>]  [<ffffffff8122b354>] isolate_migratepages_range+0x344/0x7b0
[ 1642.790016] RSP: 0018:ffff880039d998d8  EFLAGS: 00010202
[ 1642.790016] RAX: 0000000000000054 RBX: ffffea0000fd5480 RCX: 00000000000001fa
[ 1642.790016] RDX: 0000000080490049 RSI: 0000000000000004 RDI: ffff880039d99a20
[ 1642.790016] RBP: ffff880039d99978 R08: 0000000000000001 R09: 0000000000000000
[ 1642.790016] R10: ffff88003bfcefc0 R11: 0000000000000001 R12: 000000000003f552
[ 1642.790016] R13: 0000000000000153 R14: 0000000000000000 R15: ffff88004ffd2000
[ 1642.790016] FS:  00007ff799de5700(0000) GS:ffff880013600000(0000) knlGS:0000000000000000
[ 1642.790016] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1642.790016] CR2: 0000000000000194 CR3: 00000000369ef000 CR4: 00000000000406f0
[ 1642.790016] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1642.790016] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1642.790016] Process trinity-child5 (pid: 8522, threadinfo ffff880039d98000, task ffff8800298e8000)
[ 1642.790016] Stack:
[ 1642.790016]  00000000000001fa ffff880039d99a78 ffff8800298e8000 ffff880039d99a30
[ 1642.790016]  0000000000000000 0000000000000000 0000000000000000 ffff880039d99fd8
[ 1642.790016]  ffff880039d99a20 ffffea0000fd0000 ffff880039d99a60 000000000003f600
[ 1642.790016] Call Trace:
[ 1642.790016]  [<ffffffff8122ae10>] ? isolate_freepages+0x1f0/0x1f0
[ 1642.790016]  [<ffffffff8122bc3e>] compact_zone+0x3ce/0x490
[ 1642.790016]  [<ffffffff81185afb>] ? __lock_acquired+0x3b/0x360
[ 1642.790016]  [<ffffffff8122bfee>] compact_zone_order+0xde/0x120
[ 1642.790016]  [<ffffffff819f4bb8>] ? do_raw_spin_unlock+0xc8/0xe0
[ 1642.790016]  [<ffffffff8122c0ee>] try_to_compact_pages+0xbe/0x110
[ 1642.790016]  [<ffffffff83b53b4d>] __alloc_pages_direct_compact+0xba/0x206
[ 1642.790016]  [<ffffffff8118f059>] ? on_each_cpu_mask+0xd9/0x110
[ 1642.790016]  [<ffffffff8120e3ef>] __alloc_pages_nodemask+0x92f/0xbc0
[ 1642.790016]  [<ffffffff8125284c>] alloc_pages_vma+0xfc/0x150
[ 1642.790016]  [<ffffffff812699c1>] do_huge_pmd_anonymous_page+0x191/0x2b0
[ 1642.790016]  [<ffffffff81137394>] ? __rcu_read_unlock+0x44/0xb0
[ 1642.790016]  [<ffffffff812339f9>] handle_mm_fault+0x1c9/0x350
[ 1642.790016]  [<ffffffff81234068>] __get_user_pages+0x418/0x5f0
[ 1642.790016]  [<ffffffff81235bdc>] ? do_mlock_pages+0x8c/0x160
[ 1642.790016]  [<ffffffff81235b43>] __mlock_vma_pages_range+0xb3/0xc0
[ 1642.790016]  [<ffffffff81235c39>] do_mlock_pages+0xe9/0x160
[ 1642.790016]  [<ffffffff812366e0>] sys_mlockall+0x160/0x1a0
[ 1642.790016]  [<ffffffff83c1abd8>] tracesys+0xe1/0xe6
[ 1642.790016] Code: a9 00 00 01 00 0f 85 6c 02 00 00 48 8b 43 08 a8 01 0f 85 60 02 00 00 8b 53 18 85 d2 0f 89 55 02 00 00 48 85 c0
0f 84 4c 02 00 00 <48> 8b 80 40 01 00 00 a9 00 00 00 20 0f 84 3a 02 00 00 45 84 f6
[ 1642.790016] RIP  [<ffffffff8122b354>] isolate_migratepages_range+0x344/0x7b0
[ 1642.790016]  RSP <ffff880039d998d8>
[ 1642.790016] CR2: 0000000000000194
[ 1643.398013] ---[ end trace 0ad6459aa62f5d72 ]---

My guess is that we see those because of a race during the check in
isolate_migratepages_range().


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
