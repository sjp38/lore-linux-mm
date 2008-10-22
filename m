Message-ID: <48FEBAAA.5080604@suse.de>
Date: Wed, 22 Oct 2008 11:01:22 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
MIME-Version: 1.0
Subject: Re: [PATCH 20/32] netvm: INET reserves.
References: <20081002130504.927878499@chello.nl> <20081002131609.071928149@chello.nl>
In-Reply-To: <20081002131609.071928149@chello.nl>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Hi Peter,

>>> Peter Zijlstra <a.p.zijlstra@chello.nl> 10/02/08 7:06 PM >>>
> Add reserves for INET.

There's a typo in this patch that results in a Oops like the one below
when doing `sysctl -a'

<cut>
RIP: 0010:[<ffffffff804a0487>]  [<ffffffff804a0487>]
__mutex_lock_slowpath+0x34/0xc9

Call Trace:
 [<ffffffff804a044f>] mutex_lock+0x1a/0x1e
 [<ffffffff8044a82e>] proc_dointvec_route+0x38/0xad
 [<ffffffff80301fce>] proc_sys_call_handler+0x91/0xb8
 [<ffffffff802ba07e>] vfs_read+0xaa/0x153
 [<ffffffff802ba1e3>] sys_read+0x45/0x6e
 [<ffffffff8020c37a>] system_call_fastpath+0x16/0x1b
 [<00007fb25e415880>] 0x7fb25e415880

</cut>


Index: linux-2.6/net/ipv4/route.c
===================================================================
--- linux-2.6.orig/net/ipv4/route.c
+++ linux-2.6/net/ipv4/route.c

        /* Deprecated. Use gc_min_interval_ms */
@@ -3271,6 +3330,15 @@ int __init ip_rt_init(void)
    ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
    ip_rt_max_size = (rt_hash_mask + 1) * 16;

+#ifdef CONFIG_PROCFS

Should be CONFIG_PROC_FS

+    mutex_init(&ipv4_route_lock);
+#endif
+
+    mem_reserve_init(&ipv4_route_reserve, "IPv4 route cache",
+            &net_rx_reserve);
+    mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+            ipv4_dst_ops.kmem_cachep, ip_rt_max_size);
+
    devinet_init();
    ip_fib_init();


Thanks,

-- 
Suresh Jayaraman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
