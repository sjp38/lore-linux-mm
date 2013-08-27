Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 2F1266B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 08:00:11 -0400 (EDT)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] memcg: check that kmem_cache has memcg_params before accessing it
Date: Tue, 27 Aug 2013 15:56:51 +0400
Message-Id: <1377604611-3442-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrey Vagin <avagin@openvz.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, stable@vger.kernel.org.#.3.8

If the system had a few memory groups and all of them were destroyed,
memcg_limited_groups_array_size has non-zero value, but all new caches
are created without memcg_params, because memcg_kmem_enabled() returns
false.

We try to enumirate child caches in a few places and all of them are
potentially dangerous.

For example my kernel is compiled with CONFIG_SLAB and it crashed when I
tryed to mount a NFS share after a few experiments with kmemcg.

[   92.563747] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[   92.564553] IP: [<ffffffff8118166a>] do_tune_cpucache+0x8a/0xd0
[   92.564553] PGD b942a067 PUD b999f067 PMD 0
[   92.564553] Oops: 0000 [#1] SMP
[   92.564553] Modules linked in: fscache(+) ip6table_filter ip6_tables iptable_filter ip_tables i2c_piix4 pcspkr virtio_net virtio_balloon i2c_core floppy
[   92.564553] CPU: 0 PID: 357 Comm: modprobe Not tainted 3.11.0-rc7+ #59
[   92.564553] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   92.564553] task: ffff8800b9f98240 ti: ffff8800ba32e000 task.ti: ffff8800ba32e000
[   92.564553] RIP: 0010:[<ffffffff8118166a>]  [<ffffffff8118166a>] do_tune_cpucache+0x8a/0xd0
[   92.564553] RSP: 0018:ffff8800ba32fb70  EFLAGS: 00010246
[   92.564553] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000006
[   92.564553] RDX: 0000000000000000 RSI: ffff8800b9f98910 RDI: 0000000000000246
[   92.564553] RBP: ffff8800ba32fba0 R08: 0000000000000002 R09: 0000000000000004
[   92.564553] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000010
[   92.564553] R13: 0000000000000008 R14: 00000000000000d0 R15: ffff8800375d0200
[   92.564553] FS:  00007f55f1378740(0000) GS:ffff8800bfa00000(0000) knlGS:0000000000000000
[   92.564553] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   92.564553] CR2: 00007f24feba57a0 CR3: 0000000037b51000 CR4: 00000000000006f0
[   92.564553] Stack:
[   92.564553]  0000002000000000 0000000000000020 ffff8800375d0200 0000000000000010
[   92.564553]  0000000000000080 0000000000000000 ffff8800ba32fbd0 ffffffff811816f9
[   92.564553]  000000d0ba32ffd8 ffff8800375d0200 ffff8800375d0200 0000000000000080
[   92.564553] Call Trace:
[   92.564553]  [<ffffffff811816f9>] enable_cpucache+0x49/0x100
[   92.564553]  [<ffffffff8162adc5>] setup_cpu_cache+0x215/0x280
[   92.564553]  [<ffffffff81181baa>] __kmem_cache_create+0x2fa/0x450
[   92.564553]  [<ffffffff81152274>] kmem_cache_create_memcg+0x214/0x350
[   92.564553]  [<ffffffffa005fe50>] ? __fscache_invalidate+0xe0/0xe0 [fscache]
[   92.564553]  [<ffffffff811523db>] kmem_cache_create+0x2b/0x30
[   92.564553]  [<ffffffffa007019b>] fscache_init+0x19b/0x230 [fscache]
[   92.564553]  [<ffffffffa0070000>] ? 0xffffffffa006ffff
[   92.564553]  [<ffffffff810002ca>] do_one_initcall+0xfa/0x1b0
[   92.564553]  [<ffffffff81042a03>] ? set_memory_nx+0x43/0x50
[   92.564553]  [<ffffffff810cadd1>] load_module+0x1c41/0x26d0
[   92.564553]  [<ffffffff810c7040>] ? store_uevent+0x40/0x40
[   92.564553]  [<ffffffff810cb9f6>] SyS_finit_module+0x86/0xb0
[   92.564553]  [<ffffffff81644659>] system_call_fastpath+0x16/0x1b
[   92.564553] Code: c6 b0 b6 81 81 48 c7 c7 c1 ba 9f 81 e8 af de 4a 00 44 8b 0d c1 54 6d 01 45 85 c9 7e 34 31 db 66 90 49 8b 87 e0 00 00 00 48 63 d3 <48> 8b 7c d0 08 48 85 ff 74 11 8b 75 d4 45 89 f0 44 89 e9 44 89
[   92.564553] RIP  [<ffffffff8118166a>] do_tune_cpucache+0x8a/0xd0
[   92.564553]  RSP <ffff8800ba32fb70>
[   92.564553] CR2: 0000000000000008
[   92.610992] ---[ end trace adf2b24549e1f11d ]---

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: stable@vger.kernel.org # 3.8
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 mm/slab.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab.h b/mm/slab.h
index 620ceed..a535033 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -162,6 +162,8 @@ static inline const char *cache_name(struct kmem_cache *s)
 
 static inline struct kmem_cache *cache_from_memcg(struct kmem_cache *s, int idx)
 {
+	if (!s->memcg_params)
+		return NULL;
 	return s->memcg_params->memcg_caches[idx];
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
