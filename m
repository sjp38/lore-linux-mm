Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 26CE96B0037
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 08:48:13 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id y10so4221630wgg.20
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 05:48:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8si6830559wix.16.2014.02.10.05.48.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 05:48:11 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: change oom_info_lock to mutex
Date: Mon, 10 Feb 2014 14:48:02 +0100
Message-Id: <1392040082-14303-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Kirill has reported the following:
[    2.386563] Task in /test killed as a result of limit of /test
[    2.387326] memory: usage 10240kB, limit 10240kB, failcnt 51
[    2.388098] memory+swap: usage 10240kB, limit 10240kB, failcnt 0
[    2.388861] kmem: usage 0kB, limit 18014398509481983kB, failcnt 0
[    2.389640] Memory cgroup stats for /test:
[    2.390178] BUG: sleeping function called from invalid context at /home/space/kas/git/public/linux/kernel/cpu.c:68
[    2.391516] in_atomic(): 1, irqs_disabled(): 0, pid: 66, name: memcg_test
[    2.392416] 2 locks held by memcg_test/66:
[    2.392945]  #0:  (memcg_oom_lock#2){+.+...}, at: [<ffffffff81131014>] pagefault_out_of_memory+0x14/0x90
[    2.394233]  #1:  (oom_info_lock){+.+...}, at: [<ffffffff81197b2a>] mem_cgroup_print_oom_info+0x2a/0x390
[    2.395496] CPU: 2 PID: 66 Comm: memcg_test Not tainted 3.14.0-rc1-dirty #745
[    2.396536] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Bochs 01/01/2011
[    2.397540]  ffffffff81a3cc90 ffff88081d26dba0 ffffffff81776ea3 0000000000000000
[    2.398541]  ffff88081d26dbc8 ffffffff8108418a 0000000000000000 ffff88081d15c000
[    2.399533]  0000000000000000 ffff88081d26dbd8 ffffffff8104f6bc ffff88081d26dc10
[    2.400588] Call Trace:
[    2.400908]  [<ffffffff81776ea3>] dump_stack+0x4d/0x66
[    2.401578]  [<ffffffff8108418a>] __might_sleep+0x16a/0x210
[    2.402295]  [<ffffffff8104f6bc>] get_online_cpus+0x1c/0x60
[    2.403005]  [<ffffffff8118fb67>] mem_cgroup_read_stat+0x27/0xb0
[    2.403769]  [<ffffffff81197d60>] mem_cgroup_print_oom_info+0x260/0x390
[    2.404653]  [<ffffffff8177314e>] dump_header+0x88/0x251
[    2.405342]  [<ffffffff810a3bfd>] ? trace_hardirqs_on+0xd/0x10
[    2.406098]  [<ffffffff81130618>] oom_kill_process+0x258/0x3d0
[    2.406833]  [<ffffffff81198746>] mem_cgroup_oom_synchronize+0x656/0x6c0
[    2.407674]  [<ffffffff811973a0>] ? mem_cgroup_charge_common+0xd0/0xd0
[    2.408553]  [<ffffffff81131014>] pagefault_out_of_memory+0x14/0x90
[    2.409354]  [<ffffffff817712f7>] mm_fault_error+0x91/0x189
[    2.410069]  [<ffffffff81783eae>] __do_page_fault+0x48e/0x580
[    2.410791]  [<ffffffff8108f656>] ? local_clock+0x16/0x30
[    2.411467]  [<ffffffff810a3bfd>] ? trace_hardirqs_on+0xd/0x10
[    2.412248]  [<ffffffff8177f6fc>] ? _raw_spin_unlock_irq+0x2c/0x40
[    2.413039]  [<ffffffff8108312b>] ? finish_task_switch+0x7b/0x100
[    2.413821]  [<ffffffff813b954a>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[    2.414652]  [<ffffffff81783fae>] do_page_fault+0xe/0x10
[    2.415330]  [<ffffffff81780552>] page_fault+0x22/0x30

which complains that mem_cgroup_read_stat cannot be called from an
atomic context but mem_cgroup_print_oom_info takes a spinlock.
Change oom_info_lock to a mutex.

This has been introduced by 947b3dd1a84b (memcg, oom: lock
mem_cgroup_print_oom_info).

Reported-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 19d5d4274e22..55e6731ebcd5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1687,7 +1687,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	 * protects memcg_name and makes sure that parallel ooms do not
 	 * interleave
 	 */
-	static DEFINE_SPINLOCK(oom_info_lock);
+	static DEFINE_MUTEX(oom_info_lock);
 	struct cgroup *task_cgrp;
 	struct cgroup *mem_cgrp;
 	static char memcg_name[PATH_MAX];
@@ -1698,7 +1698,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	if (!p)
 		return;
 
-	spin_lock(&oom_info_lock);
+	mutex_lock(&oom_info_lock);
 	rcu_read_lock();
 
 	mem_cgrp = memcg->css.cgroup;
@@ -1767,7 +1767,7 @@ done:
 
 		pr_cont("\n");
 	}
-	spin_unlock(&oom_info_lock);
+	mutex_unlock(&oom_info_lock);
 }
 
 /*
-- 
1.9.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
