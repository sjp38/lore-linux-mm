Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9338B6B007B
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 13:07:16 -0500 (EST)
Received: by wesw62 with SMTP id w62so48059369wes.9
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 10:07:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id us7si8201030wjc.151.2015.03.04.10.07.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 10:07:15 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: make CONFIG_MEMCG depend on CONFIG_MMU
Date: Wed,  4 Mar 2015 19:07:08 +0100
Message-Id: <1425492428-27562-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chen Gang <762976180@qq.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

CONFIG_MEMCG might be currently enabled also for !MMU architectures
which was probably an omission because Balbir had this on the TODO
list section (https://lkml.org/lkml/2008/3/16/59)
"
Only when CONFIG_MMU is enabled, is the virtual address space control
enabled. Should we do this for nommu cases as well? My suspicion is
that we don't have to.
"
I do not see any traces for !MMU requests after then. The code compiles
with !MMU but I haven't heard about anybody using it in the real life
so it is not clear to me whether it works and it is usable at all
considering how !MMU configuration is restricted.

Let's make CONFIG_MEMCG depend on CONFIG_MMU to make our support
explicit and also to get rid of few ifdefs in the code base.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
Hi Andrew,
this came out as a result from
http://marc.info/?l=linux-mm&m=142533566331935 which tries to fix a
compilation warning when CONFIG_MMU=y && CONFIG_MEMCG.  I think it
makes more sense to get rid of CONFIG_MMU ifdefs and make MEMCG depend
on MMU. I am convinced that MEMCG is basically unusable with !MMU and
it should have depended on MMU since very beginning. Let's do it now.
We can always revert should there be a reasonable usecase later. That
would require some additional changes, though (e.g. anon pages should be
accounted and who knows what else).

 Documentation/cgroups/memory.txt |  2 --
 init/Kconfig                     |  1 +
 mm/memcontrol.c                  | 24 ------------------------
 3 files changed, 1 insertion(+), 26 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index a22df3ad35ff..9111540657d6 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -667,8 +667,6 @@ NOTE2: It is recommended to set the soft limit always below the hard limit,
 
 Users can move charges associated with a task along with task migration, that
 is, uncharge task's pages from the old cgroup and charge them to the new cgroup.
-This feature is not supported in !CONFIG_MMU environments because of lack of
-page tables.
 
 8.1 Interface
 
diff --git a/init/Kconfig b/init/Kconfig
index 9afb971497f4..b16f77fbd050 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -979,6 +979,7 @@ config MEMCG
 	bool "Memory Resource Controller for Control Groups"
 	select PAGE_COUNTER
 	select EVENTFD
+	depends on MMU
 	help
 	  Provides a memory resource controller that manages both anonymous
 	  memory and page cache. (See Documentation/cgroups/memory.txt)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0c86945bcc9a..1c4bb9c6227e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3467,7 +3467,6 @@ static u64 mem_cgroup_move_charge_read(struct cgroup_subsys_state *css,
 	return mem_cgroup_from_css(css)->move_charge_at_immigrate;
 }
 
-#ifdef CONFIG_MMU
 static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
 					struct cftype *cft, u64 val)
 {
@@ -3485,13 +3484,6 @@ static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
 	memcg->move_charge_at_immigrate = val;
 	return 0;
 }
-#else
-static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
-					struct cftype *cft, u64 val)
-{
-	return -ENOSYS;
-}
-#endif
 
 #ifdef CONFIG_NUMA
 static int memcg_numa_stat_show(struct seq_file *m, void *v)
@@ -4676,7 +4668,6 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 }
 
-#ifdef CONFIG_MMU
 /* Handlers for move charge at task migration. */
 static int mem_cgroup_do_precharge(unsigned long count)
 {
@@ -5209,21 +5200,6 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 	if (mc.to)
 		mem_cgroup_clear_mc();
 }
-#else	/* !CONFIG_MMU */
-static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
-				 struct cgroup_taskset *tset)
-{
-	return 0;
-}
-static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
-				     struct cgroup_taskset *tset)
-{
-}
-static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
-				 struct cgroup_taskset *tset)
-{
-}
-#endif
 
 /*
  * Cgroup retains root cgroups across [un]mount cycles making it necessary
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
