Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 47A0C6B0082
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 07:44:25 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/17] net: Do not coalesce skbs belonging to PFMEMALLOC sockets
Date: Wed, 20 Jun 2012 12:44:03 +0100
Message-Id: <1340192652-31658-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1340192652-31658-1-git-send-email-mgorman@suse.de>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

Commit [bad43ca8: net: introduce skb_try_coalesce()] introduced an
optimisation to coalesce skbs to reduce memory usage and cache line
misses. In the case where the socket is used for swapping this can result
in a warning like the following.

[  110.476565] nbd0: page allocation failure: order:0, mode:0x20
[  110.476568] Pid: 2714, comm: nbd0 Not tainted 3.5.0-rc2-swapnbd-v12r2-slab #3
[  110.476569] Call Trace:
[  110.476573]  [<ffffffff811042d3>] warn_alloc_failed+0xf3/0x160
[  110.476578]  [<ffffffff81107c92>] __alloc_pages_nodemask+0x6e2/0x930
[  110.476582]  [<ffffffff81107c92>] ?  __alloc_pages_nodemask+0x6e2/0x930
[  110.476588]  [<ffffffff81149f09>] kmem_getpages+0x59/0x1a0
[  110.476593]  [<ffffffff8114ae5b>] fallback_alloc+0x17b/0x260
[  110.476597]  [<ffffffff8114ac26>] ____cache_alloc_node+0x96/0x150
[  110.476602]  [<ffffffff8114a458>] kmem_cache_alloc_node+0x78/0x1b0
[  110.476607]  [<ffffffff8136c127>] __alloc_skb+0x57/0x1e0
[  110.476612]  [<ffffffff813b9f81>] sk_stream_alloc_skb+0x41/0x120
[  110.476617]  [<ffffffff813c8c72>] tcp_fragment+0x62/0x370
[  110.476622]  [<ffffffff813c8fb9>] tso_fragment+0x39/0x180
[  110.476628]  [<ffffffff813ca2a9>] tcp_write_xmit+0x1a9/0x3f0
[  110.476634]  [<ffffffff813ca556>] __tcp_push_pending_frames+0x26/0xd0
[  110.476639]  [<ffffffff813c61f5>] tcp_rcv_established+0x385/0x760
[  110.476644]  [<ffffffff813ce671>] tcp_v4_do_rcv+0x111/0x1f0
[  110.476648]  [<ffffffff81367259>] release_sock+0x99/0x140
[  110.476652]  [<ffffffff813ba82b> tcp_sendmsg+0x7cb/0xe80
[  110.476657]  [<ffffffff813df9b4>] inet_sendmsg+0x64/0xb0
[  110.476661]  [<ffffffff811f0a00>] ? security_socket_sendmsg+0x10/0x20
[  110.476666]  [<ffffffff81361dd8>] sock_sendmsg+0xf8/0x130
[  110.476672]  [<ffffffff8124ba4c>] ? cpumask_next_and+0x3c/0x50
[  110.476677]  [<ffffffff8107b053>] ? update_sd_lb_stats+0x123/0x620
[  110.476683]  [<ffffffff8105164f>] ? recalc_sigpending+0x1f/0x70
[  110.476688]  [<ffffffff81051e17>] ? __set_task_blocked+0x37/0x80
[  110.476693]  [<ffffffff81361e51>] kernel_sendmsg+0x41/0x60
[  110.476698]  [<ffffffffa048d417>] sock_xmit+0xb7/0x300 [nbd]
[  110.476703]  [<ffffffff8107bad7>] ? load_balance+0xd7/0x490
[  110.476710]  [<ffffffffa048d7ac>] nbd_send_req+0x14c/0x270 [nbd]
[  110.476716]  [<ffffffffa048e21e>] nbd_handle_req+0x9e/0x180 [nbd]
[  110.476721]  [<ffffffffa048e4f2>] nbd_thread+0xb2/0x150 [nbd]
[  110.476725]  [<ffffffff81062580>] ? wake_up_bit+0x40/0x40
[  110.476730]  [<ffffffffa048e440>] ? do_nbd_request+0x140/0x140 [nbd]
[  110.476733]  [<ffffffff81061d7e>] kthread+0x9e/0xb0
[  110.476739]  [<ffffffff81439d64>] kernel_thread_helper+0x4/0x10
[  110.476743]  [<ffffffff81061ce0>] ? flush_kthread_worker+0xc0/0xc0
[  110.476748]  [<ffffffff81439d60>] ? gs_change+0x13/0x13

There were two ways this could be addressed. The first would be to
teach __tcp_push_pending_frames() to use __GFP_MEMALLOC if the socket
has SOCK_MEMALLOC set. This potentially defers the time of allocation
to a point where we are applying greater pressure on PFMEMALLOC reserves
which is undesirable.  The second approach is to disable skb coalescing
for SOCK_MEMALLOC sockets and process them immediately. This patch takes
the second approach.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 net/core/skbuff.c    |    7 +++++++
 net/ipv4/tcp_input.c |    8 ++++++++
 2 files changed, 15 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d78671e..1d6ecc8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3370,6 +3370,13 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 
 	*fragstolen = false;
 
+	/*
+	 * Avoid coalescing of SOCK_MEMALLOC socks are we do not want to defer
+	 * RX/TX to a time when pfmemallo reserves are under greater pressure
+	 */
+	if (sk_memalloc_socks() && sock_flag(to->sk, SOCK_MEMALLOC))
+		return false;
+
 	if (skb_cloned(to))
 		return false;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b224eb8..448f130 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4553,6 +4553,14 @@ static bool tcp_try_coalesce(struct sock *sk,
 
 	*fragstolen = false;
 
+	/*
+	 * Do not attempt merging if the socket is used by the VM for swapping.
+	 * Attempts to defer can result in allocation failures during RX when
+	 * an attempt is made to push pending frames
+	 */
+	if (sk_memalloc_socks() && sock_flag(sk, SOCK_MEMALLOC))
+		return false;
+
 	if (tcp_hdr(from)->fin)
 		return false;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
