Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 721FF6B0010
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 13:32:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id c6-v6so3316210pls.15
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 10:32:11 -0700 (PDT)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id p64-v6si1781952pga.163.2018.10.24.10.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 10:32:10 -0700 (PDT)
From: <zhe.he@windriver.com>
Subject: [RFC] [PATCH] netfilter: Fix kmemleak false positive reports
Date: Thu, 25 Oct 2018 01:29:57 +0800
Message-ID: <1540402197-173015-1-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, catalin.marinas@arm.com, linux-mm@kvack.org, zhe.he@windriver.com

From: He Zhe <zhe.he@windriver.com>

unreferenced object 0xffff9643edb89900 (size 256):
  comm "sd-resolve", pid 220, jiffies 4295016710 (age 208.256s)
  hex dump (first 32 bytes):
    01 00 00 00 00 00 00 00 03 00 74 f3 ba b1 b6 b5  ..........t.....
    65 3e 00 00 00 00 00 00 90 f9 a0 ed 43 96 ff ff  e>..........C...
  backtrace:
    [<0000000070d5b185>] kmem_cache_alloc+0x146/0x200
    [<0000000007a27faa>] __nf_conntrack_alloc.isra.13+0x4d/0x170 [nf_conntrack]
    [<00000000ecc5b0ec>] init_conntrack+0x6a/0x2f0 [nf_conntrack]
    [<000000003d38809f>] nf_conntrack_in+0x2c5/0x360 [nf_conntrack]
    [<000000001fe154e3>] ipv4_conntrack_local+0x5d/0x70 [nf_conntrack_ipv4]
    [<0000000027adadb2>] nf_hook_slow+0x48/0xd0
    [<000000009893511f>] __ip_local_out+0xbd/0xf0
    [<00000000d68cbd2f>] ip_local_out+0x1c/0x50
    [<00000000995e2f37>] ip_send_skb+0x19/0x40
    [<000000003d95f220>] udp_send_skb.isra.5+0x157/0x360
    [<00000000ebc25968>] udp_sendmsg+0x9d8/0xc10
    [<000000003bef56ec>] inet_sendmsg+0x3e/0xf0
    [<000000008d23e405>] sock_sendmsg+0x1d/0x30
    [<000000008c297097>] ___sys_sendmsg+0x108/0x2b0
    [<00000000f15a806c>] __sys_sendmmsg+0xba/0x1c0
    [<00000000e195d2cf>] __x64_sys_sendmmsg+0x24/0x30

In __nf_conntrack_confirm, object ct can be referenced to by the stack variable
ct and the members of ct->tuplehash. kmemleak needs at least one of them to find
the ct object during scan.

When the ct object is moved from the unconfirmed hlist to the confirmed hlist.
kmemleak cannot see ct object if things happen in the following order and thus
give the above false positive report.
1) The ct object is removed from the unconfirmed hlist.
2) kmemleak scans data/bss sections(heap scan passes without heap reference).
3) The ct object is added to confirmed hlist and the variable ct is destroyed as
   the function returns.
4) kmemleak scans task stacks(stack scan passes without stack reference).

This patch marks ct object as not a leak.

Signed-off-by: He Zhe <zhe.he@windriver.com>
Cc: pablo@netfilter.org
Cc: kadlec@blackhole.kfki.hu
Cc: fw@strlen.de
Cc: davem@davemloft.net
Cc: catalin.marinas@arm.com
---
So far this is only observed in v4.18, not in v4.19. But the case seems apply    
to both.

 net/netfilter/nf_conntrack_core.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index a676d5f..067365d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -35,6 +35,7 @@
 #include <linux/mm.h>
 #include <linux/nsproxy.h>
 #include <linux/rculist_nulls.h>
+#include <linux/kmemleak.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
@@ -1282,6 +1283,8 @@ __nf_conntrack_alloc(struct net *net,
 	if (ct == NULL)
 		goto out;
 
+	kmemleak_not_leak(ct);
+
 	spin_lock_init(&ct->lock);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
-- 
2.7.4
