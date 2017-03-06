Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 095306B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 14:21:55 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g138so73752315itb.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 11:21:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q93sor8114762ioi.40.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 11:21:54 -0800 (PST)
From: Tahsin Erdogan <tahsin@google.com>
Subject: [PATCH v2] mm: do not call mem_cgroup_free() from within mem_cgroup_alloc()
Date: Mon,  6 Mar 2017 11:21:22 -0800
Message-Id: <20170306192122.24262-1-tahsin@google.com>
In-Reply-To: <20170306135947.GF27953@dhcp22.suse.cz>
References: <20170306135947.GF27953@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tahsin Erdogan <tahsin@google.com>

mem_cgroup_free() indirectly calls wb_domain_exit() which is not
prepared to deal with a struct wb_domain object that hasn't executed
wb_domain_init(). For instance, the following warning message is
printed by lockdep if alloc_percpu() fails in mem_cgroup_alloc():

  INFO: trying to register non-static key.
  the code is fine but needs lockdep annotation.
  turning off the locking correctness validator.
  CPU: 1 PID: 1950 Comm: mkdir Not tainted 4.10.0+ #151
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
  Call Trace:
   dump_stack+0x67/0x99
   register_lock_class+0x36d/0x540
   __lock_acquire+0x7f/0x1a30
   ? irq_work_queue+0x73/0x90
   ? wake_up_klogd+0x36/0x40
   ? console_unlock+0x45d/0x540
   ? vprintk_emit+0x211/0x2e0
   lock_acquire+0xcc/0x200
   ? try_to_del_timer_sync+0x60/0x60
   del_timer_sync+0x3c/0xc0
   ? try_to_del_timer_sync+0x60/0x60
   wb_domain_exit+0x14/0x20
   mem_cgroup_free+0x14/0x40
   mem_cgroup_css_alloc+0x3f9/0x620
   cgroup_apply_control_enable+0x190/0x390
   cgroup_mkdir+0x290/0x3d0
   kernfs_iop_mkdir+0x58/0x80
   vfs_mkdir+0x10e/0x1a0
   SyS_mkdirat+0xa8/0xd0
   SyS_mkdir+0x14/0x20
   entry_SYSCALL_64_fastpath+0x18/0xad

Add __mem_cgroup_free() which skips wb_domain_exit(). This is
used by both mem_cgroup_free() and mem_cgroup_alloc() clean up.

Fixes: 0b8f73e104285 ("mm: memcontrol: clean up alloc, online, offline, free functions")
Signed-off-by: Tahsin Erdogan <tahsin@google.com>
---
v2:
  Added __mem_cgroup_free()

 mm/memcontrol.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c52ec893e241..e7d900c5f2d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4135,17 +4135,22 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	kfree(memcg->nodeinfo[node]);
 }
 
-static void mem_cgroup_free(struct mem_cgroup *memcg)
+static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
 
-	memcg_wb_domain_exit(memcg);
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->stat);
 	kfree(memcg);
 }
 
+static void mem_cgroup_free(struct mem_cgroup *memcg)
+{
+	memcg_wb_domain_exit(memcg);
+	__mem_cgroup_free(memcg);
+}
+
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
 	struct mem_cgroup *memcg;
@@ -4196,7 +4201,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 fail:
 	if (memcg->id.id > 0)
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
-	mem_cgroup_free(memcg);
+	__mem_cgroup_free(memcg);
 	return NULL;
 }
 
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
