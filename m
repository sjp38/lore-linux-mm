Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C8CC46B003C
	for <linux-mm@kvack.org>; Wed, 22 May 2013 04:11:37 -0400 (EDT)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] memcg: don't initialize kmem-cache destroying work for root caches
Date: Wed, 22 May 2013 12:09:19 +0400
Message-Id: <1369210159-18735-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrey Vagin <avagin@openvz.org>, stable@vger.kernel.org.#.3.9, Konstantin Khlebnikov <khlebnikov@openvz.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

struct memcg_cache_params has a union. Different parts of this union are
used for root and non-root caches. A part with destroying work is used only
for non-root caches.

[  115.096202] BUG: unable to handle kernel paging request at 0000000fffffffe0
[  115.096785] IP: [<ffffffff8116b641>] kmem_cache_alloc+0x41/0x1f0
[  115.097024] PGD 7ace1067 PUD 0
[  115.097024] Oops: 0000 [#4] SMP
[  115.097024] Modules linked in: netlink_diag af_packet_diag udp_diag tcp_diag inet_diag unix_diag ip6table_filter ip6_tables i2c_piix4 virtio_net virtio_balloon microcode i2c_core pcspkr floppy
[  115.097024] CPU: 0 PID: 1929 Comm: lt-vzctl Tainted: G      D      3.10.0-rc1+ #2
[  115.097024] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  115.097024] task: ffff88007b5aaee0 ti: ffff88007bf0c000 task.ti: ffff88007bf0c000
[  115.097024] RIP: 0010<ffffffff8116b641>]  [<ffffffff8116b641>] kmem_cache_alloc+0x41/0x1f0
[  115.097024] RSP: 0018:ffff88007bf0de68  EFLAGS: 00010202
[  115.097024] RAX: 0000000fffffffe0 RBX: 00007fff4014f200 RCX: 0000000000000300
[  115.097024] RDX: 0000000000000005 RSI: 00000000000000d0 RDI: ffff88007d001300
[  115.097024] RBP: ffff88007bf0dea8 R08: 00007f849c3141b7 R09: ffffffff8118e100
[  115.097024] R10: 0000000000000001 R11: 0000000000000246 R12: 00000000000000d0
[  115.097024] R13: 0000000fffffffe0 R14: ffff88007d001300 R15: 0000000000001000
[  115.097024] FS:  00007f849cbb8b40(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[  115.097024] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  115.097024] CR2: 0000000fffffffe0 CR3: 000000007bc38000 CR4: 00000000000006f0
[  115.097024] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  115.097024] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  115.097024] Stack:
[  115.097024]  ffffffff8118e100 ffffffff81149ea1 0000000000000008 00007fff4014f200
[  115.097024]  00007fff4014f200 0000000000000000 0000000000000000 0000000000001000
[  115.097024]  ffff88007bf0dee8 ffffffff8118e100 ffff880037598e00 00007fff4014f200
[  115.097024] Call Trace:
[  115.097024]  [<ffffffff8118e100>] ? getname_flags.part.34+0x30/0x140
[  115.097024]  [<ffffffff81149ea1>] ? vma_rb_erase+0x121/0x210
[  115.097024]  [<ffffffff8118e100>] getname_flags.part.34+0x30/0x140
[  115.097024]  [<ffffffff8118e248>] getname+0x38/0x60
[  115.097024]  [<ffffffff81181d55>] do_sys_open+0xc5/0x1e0
[  115.097024]  [<ffffffff81181e92>] SyS_open+0x22/0x30
[  115.097024]  [<ffffffff8161cb82>] system_call_fastpath+0x16/0x1b
[  115.097024] Code: f4 53 48 83 ec 18 8b 05 8e 53 b7 00 4c 8b 4d 08 21 f0 a8 10 74 0d 4c 89 4d c0 e8 1b 76 4a 00 4c 8b 4d c0 e9 92 00 00 00 4d 89 f5 <4d> 8b 45 00 65 4c 03 04 25 48 cd 00 00 49 8b 50 08 4d 8b 38 49
[  115.097024] RIP  [<ffffffff8116b641>] kmem_cache_alloc+0x41/0x1f0
[  115.097024]  RSP <ffff88007bf0de68>
[  115.097024] CR2: 0000000fffffffe0
[  115.121352] ---[ end trace 16bb8e8408b97d0e ]---

Cc: stable@vger.kernel.org # 3.9
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 mm/memcontrol.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cb1c9de..764b9e4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3141,8 +3141,6 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 			return -ENOMEM;
 		}
 
-		INIT_WORK(&s->memcg_params->destroy,
-				kmem_cache_destroy_work_func);
 		s->memcg_params->is_root_cache = true;
 
 		/*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
