Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 1E1976B0133
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 03:09:01 -0400 (EDT)
Message-ID: <505187D4.7070404@cn.fujitsu.com>
Date: Thu, 13 Sep 2012 15:14:28 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memory cgroup: update root memory cgroup when node is onlined
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: Jiang Liu <liuj97@gmail.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, paul.gortmaker@windriver.com

root_mem_cgroup->info.nodeinfo is initialized when the system boots.
But NODE_DATA(nid) is null if the node is not onlined, so
root_mem_cgroup->info.nodeinfo[nid]->zoneinfo[zone].lruvec.zone contains
an invalid pointer. If we use numactl to bind a program to the node
after onlining the node and its memory, it will cause the kernel
panicked:

[   63.413436] BUG: unable to handle kernel NULL pointer dereference at 0000000000000f60
[   63.414161] IP: [<ffffffff811870b9>] __mod_zone_page_state+0x9/0x60
[   63.414161] PGD 0 
[   63.414161] Oops: 0000 [#1] SMP 
[   63.414161] Modules linked in: acpi_memhotplug binfmt_misc dm_mirror dm_region_hash dm_log dm_mod ppdev sg microcode pcspkr virtio_console virtio_balloon snd_intel8x0 snd_ac9
7_codec ac97_bus snd_seq snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc e1000 i2c_piix4 i2c_core floppy parport_pc parport sr_mod cdrom virtio_blk pata_acpi ata_g
eneric ata_piix libata scsi_mod
[   63.414161] CPU 2 
[   63.414161] Pid: 1219, comm: numactl Not tainted 3.6.0-rc5+ #180 Bochs Bochs
...
[   63.414161] Process numactl (pid: 1219, threadinfo ffff880039abc000, task ffff8800383c4ce0)
[   63.414161] Stack:
[   63.414161]  ffff880039abdaf8 ffffffff8117390f ffff880039abdaf8 000000008167c601
[   63.414161]  ffffffff81174162 ffff88003a480f00 0000000000000001 ffff8800395e0000
[   63.414161]  ffff88003dbd0e80 0000000000000282 ffff880039abdb48 ffffffff81174181
[   63.414161] Call Trace:
[   63.414161]  [<ffffffff8117390f>] __pagevec_lru_add_fn+0xdf/0x140
[   63.414161]  [<ffffffff81174162>] ? pagevec_lru_move_fn+0x92/0x100
[   63.414161]  [<ffffffff81174181>] pagevec_lru_move_fn+0xb1/0x100
[   63.414161]  [<ffffffff81173830>] ? lru_add_page_tail+0x1b0/0x1b0
[   63.414161]  [<ffffffff811dff71>] ? exec_mmap+0x121/0x230
[   63.414161]  [<ffffffff811741ec>] __pagevec_lru_add+0x1c/0x30
[   63.414161]  [<ffffffff81174383>] lru_add_drain_cpu+0xa3/0x130
[   63.414161]  [<ffffffff8117443f>] lru_add_drain+0x2f/0x40
[   63.414161]  [<ffffffff81196da9>] exit_mmap+0x69/0x160
[   63.414161]  [<ffffffff810db115>] ? lock_release_holdtime+0x35/0x1a0
[   63.414161]  [<ffffffff81069c37>] mmput+0x77/0x100
[   63.414161]  [<ffffffff811dffc0>] exec_mmap+0x170/0x230
[   63.414161]  [<ffffffff811e0152>] flush_old_exec+0xd2/0x140
[   63.414161]  [<ffffffff812343ea>] load_elf_binary+0x32a/0xe70
[   63.414161]  [<ffffffff810d700d>] ? trace_hardirqs_off+0xd/0x10
[   63.414161]  [<ffffffff810b231f>] ? local_clock+0x6f/0x80
[   63.414161]  [<ffffffff810db115>] ? lock_release_holdtime+0x35/0x1a0
[   63.414161]  [<ffffffff810dd813>] ? __lock_release+0x133/0x1a0
[   63.414161]  [<ffffffff811e22e7>] ? search_binary_handler+0x1a7/0x4a0
[   63.414161]  [<ffffffff811e22f3>] search_binary_handler+0x1b3/0x4a0
[   63.414161]  [<ffffffff811e2194>] ? search_binary_handler+0x54/0x4a0
[   63.414161]  [<ffffffff812340c0>] ? set_brk+0xe0/0xe0
[   63.414161]  [<ffffffff811e284f>] do_execve_common+0x26f/0x320
[   63.414161]  [<ffffffff811bde33>] ? kmem_cache_alloc+0x113/0x220
[   63.414161]  [<ffffffff811e298a>] do_execve+0x3a/0x40
[   63.414161]  [<ffffffff8102061a>] sys_execve+0x4a/0x80
[   63.414161]  [<ffffffff81686c6c>] stub_execve+0x6c/0xc0
[   63.414161] Code: ff 03 00 00 48 c1 e7 0b 48 c1 e2 07 48 29 d7 48 03 3c c5 c0 27 d2 81 e8 a6 fe ff ff c9 c3 0f 1f 40 00 55 48 89 e5 0f 1f 44 00 00 <48> 8b 4f 60 89 f6 48 8d 44 31 40 65 44 8a 40 02 45 0f be c0 41 

The reason is that we don't update root_mem_cgroup->info.nodeinfo[nid]->zoneinfo[zone].lruvec.zone
when onlining the node, and we try to access it.

Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Reported-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |   14 ++++++++++++++
 mm/memory_hotplug.c        |    2 ++
 3 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8d9489f..87d8b77 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -182,6 +182,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						unsigned long *total_scanned);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
+
+void update_root_mem_cgroup(int nid);
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
@@ -374,6 +377,10 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
 				struct page *newpage)
 {
 }
+
+static inline void update_root_mem_cgroup(int nid)
+{
+}
 #endif /* CONFIG_MEMCG */
 
 #if !defined(CONFIG_MEMCG) || !defined(CONFIG_DEBUG_VM)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 795e525..c997a46 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3427,6 +3427,20 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	__mem_cgroup_commit_charge(memcg, newpage, 1, type, true);
 }
 
+/* NODE_DATA(nid) is changed */
+void update_root_mem_cgroup(int nid)
+{
+	struct mem_cgroup_per_node *pn;
+	struct mem_cgroup_per_zone *mz;
+	int zone;
+
+	pn = root_mem_cgroup->info.nodeinfo[nid];
+	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+		mz = &pn->zoneinfo[zone];
+		lruvec_init(&mz->lruvec, &NODE_DATA(nid)->node_zones[zone]);
+	}
+}
+
 #ifdef CONFIG_DEBUG_VM
 static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
 {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3ad25f9..bf03b02 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -555,6 +555,8 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 
 	/* we can use NODE_DATA(nid) from here */
 
+	update_root_mem_cgroup(nid);
+
 	/* init node's zones as empty zones, we don't have any present pages.*/
 	free_area_init_node(nid, zones_size, start_pfn, zholes_size);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
