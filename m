Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 66E596B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:45:15 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so105222462pad.1
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 21:45:15 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id o3si34821131pap.210.2015.09.20.21.45.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 21:45:14 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so105348099pac.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 21:45:14 -0700 (PDT)
Date: Mon, 21 Sep 2015 13:46:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [linux-next] khugepaged inconsistent lock state
Message-ID: <20150921044600.GA863@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi,

4.3.0-rc1-next-20150918

[18344.236625] =================================
[18344.236628] [ INFO: inconsistent lock state ]
[18344.236633] 4.3.0-rc1-next-20150918-dbg-00014-ge5128d0-dirty #361 Not tainted
[18344.236636] ---------------------------------
[18344.236640] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
[18344.236645] khugepaged/32 [HC0[0]:SC0[0]:HE1:SE1] takes:
[18344.236648]  (&anon_vma->rwsem){++++?.}, at: [<ffffffff81134403>] khugepaged+0x8b0/0x1987
[18344.236662] {IN-RECLAIM_FS-W} state was registered at:
[18344.236666]   [<ffffffff8107d747>] __lock_acquire+0x8e2/0x1183
[18344.236673]   [<ffffffff8107e7ac>] lock_acquire+0x10b/0x1a6
[18344.236678]   [<ffffffff8150a367>] down_write+0x3b/0x6a
[18344.236686]   [<ffffffff811360d8>] split_huge_page_to_list+0x5b/0x61f
[18344.236689]   [<ffffffff811224b3>] add_to_swap+0x37/0x78
[18344.236691]   [<ffffffff810fd650>] shrink_page_list+0x4c2/0xb9a
[18344.236694]   [<ffffffff810fe47c>] shrink_inactive_list+0x371/0x5d9
[18344.236696]   [<ffffffff810fee2f>] shrink_lruvec+0x410/0x5ae
[18344.236698]   [<ffffffff810ff024>] shrink_zone+0x57/0x140
[18344.236700]   [<ffffffff810ffc79>] kswapd+0x6a5/0x91b
[18344.236702]   [<ffffffff81059588>] kthread+0x107/0x10f
[18344.236706]   [<ffffffff8150c7bf>] ret_from_fork+0x3f/0x70
[18344.236708] irq event stamp: 6517947
[18344.236709] hardirqs last  enabled at (6517947): [<ffffffff810f2d0c>] get_page_from_freelist+0x362/0x59e
[18344.236713] hardirqs last disabled at (6517946): [<ffffffff8150ba41>] _raw_spin_lock_irqsave+0x18/0x51
[18344.236715] softirqs last  enabled at (6507072): [<ffffffff81041cb0>] __do_softirq+0x2df/0x3f5
[18344.236719] softirqs last disabled at (6507055): [<ffffffff81041fb5>] irq_exit+0x40/0x94
[18344.236722] 
               other info that might help us debug this:
[18344.236723]  Possible unsafe locking scenario:

[18344.236724]        CPU0
[18344.236725]        ----
[18344.236726]   lock(&anon_vma->rwsem);
[18344.236728]   <Interrupt>
[18344.236729]     lock(&anon_vma->rwsem);
[18344.236731] 
                *** DEADLOCK ***

[18344.236733] 2 locks held by khugepaged/32:
[18344.236733]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81134122>] khugepaged+0x5cf/0x1987
[18344.236738]  #1:  (&anon_vma->rwsem){++++?.}, at: [<ffffffff81134403>] khugepaged+0x8b0/0x1987
[18344.236741] 
               stack backtrace:
[18344.236744] CPU: 3 PID: 32 Comm: khugepaged Not tainted 4.3.0-rc1-next-20150918-dbg-00014-ge5128d0-dirty #361
[18344.236747]  0000000000000000 ffff880132827a00 ffffffff81230867 ffffffff8237ba90
[18344.236750]  ffff880132827a38 ffffffff810ea9b9 000000000000000a ffff8801333b52e0
[18344.236753]  ffff8801333b4c00 ffffffff8107b3ce 000000000000000a ffff880132827a78
[18344.236755] Call Trace:
[18344.236758]  [<ffffffff81230867>] dump_stack+0x4e/0x79
[18344.236761]  [<ffffffff810ea9b9>] print_usage_bug.part.24+0x259/0x268
[18344.236763]  [<ffffffff8107b3ce>] ? print_shortest_lock_dependencies+0x180/0x180
[18344.236765]  [<ffffffff8107c7fc>] mark_lock+0x381/0x567
[18344.236766]  [<ffffffff8107ca40>] mark_held_locks+0x5e/0x74
[18344.236768]  [<ffffffff8107ee9f>] lockdep_trace_alloc+0xb0/0xb3
[18344.236771]  [<ffffffff810f30cc>] __alloc_pages_nodemask+0x99/0x856
[18344.236772]  [<ffffffff810ebaf9>] ? find_get_entry+0x14b/0x17a
[18344.236774]  [<ffffffff810ebb16>] ? find_get_entry+0x168/0x17a
[18344.236777]  [<ffffffff811226d9>] __read_swap_cache_async+0x7b/0x1aa
[18344.236778]  [<ffffffff8112281d>] read_swap_cache_async+0x15/0x2d
[18344.236780]  [<ffffffff8112294f>] swapin_readahead+0x11a/0x16a
[18344.236783]  [<ffffffff81112791>] do_swap_page+0xa7/0x36b
[18344.236784]  [<ffffffff81112791>] ? do_swap_page+0xa7/0x36b
[18344.236787]  [<ffffffff8113444c>] khugepaged+0x8f9/0x1987
[18344.236790]  [<ffffffff810772f3>] ? wait_woken+0x88/0x88
[18344.236792]  [<ffffffff81133b53>] ? maybe_pmd_mkwrite+0x1a/0x1a
[18344.236794]  [<ffffffff81059588>] kthread+0x107/0x10f
[18344.236797]  [<ffffffff81059481>] ? kthread_create_on_node+0x1ea/0x1ea
[18344.236799]  [<ffffffff8150c7bf>] ret_from_fork+0x3f/0x70
[18344.236801]  [<ffffffff81059481>] ? kthread_create_on_node+0x1ea/0x1ea


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
