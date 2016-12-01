Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 800B56B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 08:22:10 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so56792538wms.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 05:22:10 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id x89si11999074wma.147.2016.12.01.05.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 05:22:09 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id a20so34268604wme.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 05:22:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: workingset: fix NULL ptr in count_shadow_nodes
Date: Thu,  1 Dec 2016 14:21:56 +0100
Message-Id: <20161201132156.21450-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, =?UTF-8?q?Marek=20Marczykowski-G=C3=B3recki?= <marmarek@mimuw.edu.pl>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

From: Michal Hocko <mhocko@suse.com>

0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
has made the workingset shadow nodes shrinker memcg aware. The
implementation is not correct though because memcg_kmem_enabled() might
become true while we are doing a global reclaim when the sc->memcg might
be NULL which is exactly what Marek has seen:

[   15.665196] BUG: unable to handle kernel NULL pointer dereference at 0000000000000400
[   15.665213] IP: [<ffffffff8122d520>] mem_cgroup_node_nr_lru_pages+0x20/0x40
[   15.665225] PGD 0
[   15.665230] Oops: 0000 [#1] SMP
[   15.665285] CPU: 0 PID: 60 Comm: kswapd0 Tainted: G           O   4.8.10-12.pvops.qubes.x86_64 #1
[   15.665292] task: ffff880011863b00 task.stack: ffff880011868000
[   15.665297] RIP: e030:[<ffffffff8122d520>]  [<ffffffff8122d520>] mem_cgroup_node_nr_lru_pages+0x20/0x40
[   15.665307] RSP: e02b:ffff88001186bc70  EFLAGS: 00010293
[   15.665311] RAX: 0000000000000000 RBX: ffff88001186bd20 RCX: 0000000000000002
[   15.665317] RDX: 000000000000000c RSI: 0000000000000000 RDI: 0000000000000000
[   15.665322] RBP: ffff88001186bc70 R08: 28f5c28f5c28f5c3 R09: 0000000000000000
[   15.665327] R10: 0000000000006c34 R11: 0000000000000333 R12: 00000000000001f6
[   15.665332] R13: ffffffff81c6f6a0 R14: 0000000000000000 R15: 0000000000000000
[   15.665343] FS:  0000000000000000(0000) GS:ffff880013c00000(0000) knlGS:ffff880013d00000
[   15.665351] CS:  e033 DS: 0000 ES: 0000 CR0: 0000000080050033
[   15.665358] CR2: 0000000000000400 CR3: 00000000122f2000 CR4: 0000000000042660
[   15.665366] Stack:
[   15.665371]  ffff88001186bc98 ffffffff811e0dda 00000000000002eb 0000000000000080
[   15.665384]  ffffffff81c6f6a0 ffff88001186bd70 ffffffff811c36d9 0000000000000000
[   15.665397]  ffff88001186bcb0 ffff88001186bcb0 ffff88001186bcc0 000000000000abc5
[   15.665410] Call Trace:
[   15.665419]  [<ffffffff811e0dda>] count_shadow_nodes+0x9a/0xa0
[   15.665428]  [<ffffffff811c36d9>] shrink_slab.part.42+0x119/0x3e0
[   15.666049]  [<ffffffff811c83ec>] shrink_node+0x22c/0x320
[   15.666049]  [<ffffffff811c928c>] kswapd+0x32c/0x700
[   15.666049]  [<ffffffff811c8f60>] ? mem_cgroup_shrink_node+0x180/0x180
[   15.666049]  [<ffffffff810c1b08>] kthread+0xd8/0xf0
[   15.666049]  [<ffffffff817a3abf>] ret_from_fork+0x1f/0x40
[   15.666049]  [<ffffffff810c1a30>] ? kthread_create_on_node+0x190/0x190
[   15.666049] Code: 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 3b 35 dd eb b1 00 55 48 89 e5 73 2c 89 d2 31 c9 31 c0 4c 63 ce 48 0f a3 ca 73 13 <4a> 8b b4 cf 00 04 00 00 41 89 c8 4a 03 84 c6 80 00 00 00 83 c1
[   15.666049] RIP  [<ffffffff8122d520>] mem_cgroup_node_nr_lru_pages+0x20/0x40
[   15.666049]  RSP <ffff88001186bc70>
[   15.666049] CR2: 0000000000000400
[   15.666049] ---[ end trace 100494b9edbdfc4d ]---

This patch fixes the issue by checking sc->memcg rather than memcg_kmem_enabled()
which is sufficient because shrink_slab makes sure that only memcg aware shrinkers
will get non-NULL memcgs and only if memcg_kmem_enabled is true.

Fixes: 0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
Reported-and-tested-by: Marek Marczykowski-GA3recki <marmarek@mimuw.edu.pl>
Cc: stable@vger.kernel.org # 4.6+
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/workingset.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 617475f529f4..fb1f9183d89a 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -348,7 +348,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
 	local_irq_enable();
 
-	if (memcg_kmem_enabled()) {
+	if (sc->memcg) {
 		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
 						     LRU_ALL_FILE);
 	} else {
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
