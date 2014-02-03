Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id B192C6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 17:57:30 -0500 (EST)
Received: by mail-oa0-f52.google.com with SMTP id i4so9007225oah.11
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 14:57:30 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id tb9si10585370obc.56.2014.02.03.14.57.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 14:57:30 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 3 Feb 2014 15:57:29 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7D05E19D8051
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 15:57:26 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s13Mv3L94981066
	for <linux-mm@kvack.org>; Mon, 3 Feb 2014 23:57:03 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s13N0juZ003492
	for <linux-mm@kvack.org>; Mon, 3 Feb 2014 16:00:45 -0700
Date: Mon, 3 Feb 2014 14:57:25 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH] Fix lockdep false positive in add_full()
Message-ID: <20140203225725.GA4069@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, peterz@infradead.org

Hello!

The add_full() function currently has a lockdep_assert_held() requiring
that the kmem_cache_node structure's ->list_lock be held.  However,
this lock is not acquired by add_full()'s caller deactivate_slab()
in the full-node case unless debugging is enabled.  Because full nodes
are accessed only by debugging code, this state of affairs results in
lockdep false-positive splats like the following:

[   43.942868] WARNING: CPU: 0 PID: 698 at /home/paulmck/public_git/linux-rcu/mm/slub.c:1007 deactivate_slab+0x509/0x720()
[   43.943016] Modules linked in:
[   43.943016] CPU: 0 PID: 698 Comm: torture_onoff Not tainted 3.14.0-rc1+ #1
[   43.943016] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   43.943016]  00000000000003ef ffff88001e3f5ba8 ffffffff818952ec 0000000000000046
[   43.943016]  0000000000000000 ffff88001e3f5be8 ffffffff81049517 ffffea0000784e00
[   43.943016]  0000000000000000 ffffea00007a9000 0000000000000002 0000000000000000
[   43.943016] Call Trace:
[   43.943016]  [<ffffffff818952ec>] dump_stack+0x46/0x58
[   43.943016]  [<ffffffff81049517>] warn_slowpath_common+0x87/0xb0
[   43.943016]  [<ffffffff81049555>] warn_slowpath_null+0x15/0x20
[   43.943016]  [<ffffffff8116e679>] deactivate_slab+0x509/0x720
[   43.943016]  [<ffffffff8116eebb>] ? slab_cpuup_callback+0x3b/0x100
[   43.943016]  [<ffffffff8116ef52>] ? slab_cpuup_callback+0xd2/0x100
[   43.943016]  [<ffffffff8116ef24>] slab_cpuup_callback+0xa4/0x100
[   43.943016]  [<ffffffff818a4c14>] notifier_call_chain+0x54/0x110
[   43.943016]  [<ffffffff81075b79>] __raw_notifier_call_chain+0x9/0x10
[   43.943016]  [<ffffffff8104963b>] __cpu_notify+0x1b/0x30
[   43.943016]  [<ffffffff81049720>] cpu_notify_nofail+0x10/0x20
[   43.943016]  [<ffffffff8188cc5d>] _cpu_down+0x10d/0x2e0
[   43.943016]  [<ffffffff8188ce60>] cpu_down+0x30/0x50
[   43.943016]  [<ffffffff811205f3>] torture_onoff+0xd3/0x3c0
[   43.943016]  [<ffffffff81120520>] ? torture_onoff_stats+0x90/0x90
[   43.943016]  [<ffffffff810710df>] kthread+0xdf/0x100
[   43.943016]  [<ffffffff818a09cb>] ? _raw_spin_unlock_irq+0x2b/0x40
[   43.943016]  [<ffffffff81071000>] ? flush_kthread_worker+0x130/0x130
[   43.943016]  [<ffffffff818a983c>] ret_from_fork+0x7c/0xb0
[   43.943016]  [<ffffffff81071000>] ? flush_kthread_worker+0x130/0x130

This commit therefore does the lockdep check only if debuggging is
enabled, thus avoiding the false positives.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org
Cc: cl@linux-foundation.org
Cc: penberg@kernel.org
Cc: mpm@selenic.com

diff --git a/mm/slub.c b/mm/slub.c
index 7e3e0458bce4..6fff4d980b7c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1004,7 +1004,8 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 static void add_full(struct kmem_cache *s,
 	struct kmem_cache_node *n, struct page *page)
 {
-	lockdep_assert_held(&n->list_lock);
+	if (kmem_cache_debug(s))
+		lockdep_assert_held(&n->list_lock);
 
 	if (!(s->flags & SLAB_STORE_USER))
 		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
