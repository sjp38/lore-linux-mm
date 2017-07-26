Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 317256B02B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:07:54 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v11so6392812oif.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:07:54 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id u67si8668544oif.435.2017.07.26.06.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 06:07:52 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id q70so9163600oic.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:07:52 -0700 (PDT)
From: Wenwei Tao <wenwei.tww@gmail.com>
Subject: [RFC PATCH] mm: memcg: fix css double put in mem_cgroup_iter
Date: Wed, 26 Jul 2017 21:07:42 +0800
Message-Id: <20170726130742.5976-1-wenwei.tww@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: yuwang.yuwang@alibaba-inc.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wenwei Tao <wenwei.tww@alibaba-inc.com>

From: Wenwei Tao <wenwei.tww@alibaba-inc.com>

By removing the child cgroup while the parent cgroup is
under reclaim, we could trigger the following kernel panic
on kernel 3.10:
------------------------------------------------------------------------
kernel BUG at kernel/cgroup.c:893!
 invalid opcode: 0000 [#1] SMP
 CPU: 1 PID: 22477 Comm: kworker/1:1 Not tainted 3.10.107 #1
 Workqueue: cgroup_destroy css_dput_fn
 task: ffff8817959a5780 ti: ffff8817e8886000 task.ti: ffff8817e8886000
 RIP: 0010:[<ffffffff810cd6e0>]  [<ffffffff810cd6e0>]
cgroup_diput+0xc0/0xf0
 RSP: 0000:ffff8817e8887da0  EFLAGS: 00010246
 RAX: 0000000000000000 RBX: ffff8817a5dd5d40 RCX: dead000000000200
 RDX: 0000000000000000 RSI: ffff8817973a6910 RDI: ffff8817f54c2a00
 RBP: ffff8817e8887dc8 R08: ffff8817a5dd5dd0 R09: df9fb35794b01820
 R10: df9fb35794b01820 R11: 00007fa95b1efcda R12: ffff8817a5dd5d9c
 R13: ffff8817f38b3a40 R14: ffff8817973a6910 R15: ffff8817973a6910
 FS:  0000000000000000(0000) GS:ffff88181f220000(0000)
knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 00007fa6e6234000 CR3: 000000179f19d000 CR4: 00000000000407e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Stack:
  ffff8817a5dd5d40 ffff8817a5dd5d9c ffff8817f38b3a40 ffff8817973a6910
  0000000000000040 ffff8817e8887df8 ffffffff811b37c2 ffff8817fa23c000
  ffff8817f57dbb80 ffff88181f232ac0 ffff88181f237500 ffff8817e8887e10
 Call Trace:
  [<ffffffff811b37c2>] dput+0x1a2/0x2f0
  [<ffffffff810cbacc>] cgroup_dput.isra.21+0x1c/0x30
  [<ffffffff810cbafd>] css_dput_fn+0x1d/0x20
  [<ffffffff81078ebc>] process_one_work+0x17c/0x460
  [<ffffffff81079b66>] worker_thread+0x116/0x3b0
  [<ffffffff81079a50>] ? manage_workers.isra.25+0x290/0x290
  [<ffffffff81080330>] kthread+0xc0/0xd0
  [<ffffffff81080270>] ? insert_kthread_work+0x40/0x40
  [<ffffffff815b1e08>] ret_from_fork+0x58/0x90
  [<ffffffff81080270>] ? insert_kthread_work+0x40/0x40
 Code: 41 5e 41 5f 5d c3 0f 1f 44 00 00 48 8b 7f 78 48 8b 07 a8 01 74 15
48 81 c7 30 01 00 00 48 c7 c6 a0 a7 0c 81 e8 b2 83 02 00 eb c8 <0f> 0b
49 8b 4e 18 48 c7 c2 7e f1 7a 81 be 85 03 00 00 48 c7 c7
 RIP  [<ffffffff810cd6e0>] cgroup_diput+0xc0/0xf0
 RSP <ffff8817e8887da0>
 ---[ end trace 85eeea5212c44f51 ]---
------------------------------------------------------------------------

I think there is a css double put in mem_cgroup_iter. Under reclaim,
we call mem_cgroup_iter the first time with prev == NULL, and we get
last_visited memcg from per zone's reclaim_iter then call __mem_cgroup_iter_next
try to get next alive memcg, __mem_cgroup_iter_next could return NULL
if last_visited is already the last one so we put the last_visited's
memcg css and continue to the next while loop, this time we might not
do css_tryget(&last_visited->css) if the dead_count is changed, but
we still do css_put(&last_visited->css), we put it twice, this could
trigger the BUG_ON at kernel/cgroup.c:893.

Reported-by: Wang Yu <yuwang.yuwang@alibaba-inc.com>
Tested-by: Wang Yu <yuwang.yuwang@alibaba-inc.com>
Signed-off-by: Wenwei Tao <wenwei.tww@alibaba-inc.com>
---
 mm/memcontrol.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 437ae2c..3d7a046 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1230,8 +1230,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		memcg = __mem_cgroup_iter_next(root, last_visited);
 
 		if (reclaim) {
-			if (last_visited && last_visited != root)
+			if (last_visited && last_visited != root) {
 				css_put(&last_visited->css);
+				last_visited = NULL;
+			}
 
 			iter->last_visited = memcg;
 			smp_wmb();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
