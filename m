Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C7CEE6B00C4
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 21:59:08 -0500 (EST)
Date: Wed, 10 Mar 2010 11:50:46 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-Id: <20100310115046.425857f0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100309151334.f28d9930.akpm@linux-foundation.org>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
	<20100203193127.fe5efa17.akpm@linux-foundation.org>
	<20100204140942.0ef6d7b1.nishimura@mxp.nes.nec.co.jp>
	<20100204142736.2a8bec26.kamezawa.hiroyu@jp.fujitsu.com>
	<20100204071840.GC5574@linux-sh.org>
	<20100204164441.d012f6fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20100205093806.5699d406.nishimura@mxp.nes.nec.co.jp>
	<20100205011602.GA8416@linux-sh.org>
	<20100309151334.f28d9930.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010 15:13:34 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 5 Feb 2010 10:16:02 +0900
> Paul Mundt <lethal@linux-sh.org> wrote:
> 
> > On Fri, Feb 05, 2010 at 09:38:06AM +0900, Daisuke Nishimura wrote:
> > > On Thu, 4 Feb 2010 16:44:41 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > On Thu, 4 Feb 2010 16:18:40 +0900
> > > > Paul Mundt <lethal@linux-sh.org> wrote:
> > > > > CONFIG_SWAP itself is configurable even with CONFIG_MMU=y, so having
> > > > > stubbed out helpers for the CONFIG_SWAP=n case would give the compiler a
> > > > > chance to optimize things away in those cases, too. Embedded systems
> > > > > especially will often have MMU=y and BLOCK=n, resulting in SWAP being
> > > > > unset but swap cache encodings still defined.
> > > > > 
> > > > > How about just changing the is_swap_pte() definition to depend on SWAP
> > > > > instead?
> > > > > 
> > > > I think the new feature as "move task charge" itself depends on CONFIG_MMU
> > > > because it walks a process's page table. 
> > > > 
> > > > Then, how about this ? (sorry, I can't test this in valid way..)
> > > > 
> > > I agree to this direction of making "move charge" depend on CONFIG_MMU,
> > > although I can't test !CONFIG_MMU case either.
> > > 
> > I'll try to give it a test on nommu today and see how it goes.
> 
> The patch is still breaking the NOMMU build for me:
> 
> mm/memcontrol.c: In function `is_target_pte_for_mc':
> mm/memcontrol.c:3641: error: implicit declaration of function `is_swap_pte'
> 
This is a fix patch based on KAMEZAWA-san's.

This patch makes "move charge" feature depends on CONFIG_MMU. I think it would be
more appropriate to place this patch as a fix for
memcg-add-interface-to-move-charge-at-task-migration.patch, because of its nature,
so I prepared this patch as a fix for it. And all of the following patches can be
applied properly in my environment.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

"move charges at task migration" feature depends on page tables. So, it doesn't
work in !CONIFG_MMU environments.
This patch moves "task move" codes under CONIFG_MMU.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 Documentation/cgroups/memory.txt |    2 ++
 mm/memcontrol.c                  |   31 +++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index e726fb0..b8b6b12 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -420,6 +420,8 @@ NOTE2: It is recommended to set the soft limit always below the hard limit,
 
 Users can move charges associated with a task along with task migration, that
 is, uncharge task's pages from the old cgroup and charge them to the new cgroup.
+This feature is not supporetd in !CONFIG_MMU environmetns because of lack of
+page tables.
 
 8.1 Interface
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 59ffaf5..88a6880 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2886,6 +2886,7 @@ static u64 mem_cgroup_move_charge_read(struct cgroup *cgrp,
 	return mem_cgroup_from_cont(cgrp)->move_charge_at_immigrate;
 }
 
+#ifdef CONFIG_MMU
 static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 					struct cftype *cft, u64 val)
 {
@@ -2904,6 +2905,13 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 
 	return 0;
 }
+#else
+static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
+					struct cftype *cft, u64 val)
+{
+	return -ENOSYS;
+}
+#endif
 
 
 /* For read statistics */
@@ -3427,6 +3435,7 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 	return ret;
 }
 
+#ifdef CONFIG_MMU
 /* Handlers for move charge at task migration. */
 static int mem_cgroup_can_move_charge(void)
 {
@@ -3479,6 +3488,28 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 {
 	mem_cgroup_move_charge();
 }
+#else	/* !CONFIG_MMU */
+static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
+				struct cgroup *cgroup,
+				struct task_struct *p,
+				bool threadgroup)
+{
+	return 0;
+}
+static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
+				struct cgroup *cgroup,
+				struct task_struct *p,
+				bool threadgroup)
+{
+}
+static void mem_cgroup_move_task(struct cgroup_subsys *ss,
+				struct cgroup *cont,
+				struct cgroup *old_cont,
+				struct task_struct *p,
+				bool threadgroup)
+{
+}
+#endif
 
 struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
-- 
1.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
