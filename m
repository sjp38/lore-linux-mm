Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 000166B0119
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 14:57:20 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi5so4123101wib.11
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 11:57:20 -0700 (PDT)
Received: from mail-ee0-x229.google.com (mail-ee0-x229.google.com [2a00:1450:4013:c00::229])
        by mx.google.com with ESMTPS id p8si23267715eew.156.2014.03.18.11.57.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 11:57:19 -0700 (PDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so5793721eei.0
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 11:57:19 -0700 (PDT)
Date: Tue, 18 Mar 2014 21:53:30 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: kswapd using __this_cpu_add() in preemptible code
Message-ID: <20140318185329.GB430@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello gentlemen,

Commit 589a606f9539663f162e4a110d117527833b58a4 ("percpu: add preemption
checks to __this_cpu ops") added preempt check to used in __count_vm_events()
__this_cpu ops, causing the following kswapd warning:

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
 [<ffffffff810e3951>] super_cache_scan+0xe3/0x143
 [<ffffffff810b1301>] shrink_slab_node+0x103/0x16f
 [<ffffffff810b19fd>] shrink_slab+0x75/0xe4
 [<ffffffff810b3f3d>] balance_pgdat+0x2fa/0x47f
 [<ffffffff810b4395>] kswapd+0x2d3/0x2fd
 [<ffffffff81068049>] ? __wake_up_sync+0xd/0xd
 [<ffffffff810b40c2>] ? balance_pgdat+0x47f/0x47f
 [<ffffffff81051e75>] kthread+0xd6/0xde
 [<ffffffff81051d9f>] ? kthread_create_on_node+0x162/0x162
 [<ffffffff813be5bc>] ret_from_fork+0x7c/0xb0
 [<ffffffff81051d9f>] ? kthread_create_on_node+0x162/0x162


list_lru_walk_node() seems to be the only place where __count_vm_events()
called with preemption enabled. remaining __count_vm_events() and
__count_vm_event() calls are done with preemption disabled (unless I
overlooked something).


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
