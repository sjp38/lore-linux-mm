Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 88D2D6B0083
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 02:48:11 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o147m8FO011673
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Feb 2010 16:48:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F97545DE50
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 16:48:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E44B45DE4F
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 16:48:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E7D301DB803F
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 16:48:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 90BDE1DB8038
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 16:48:04 +0900 (JST)
Date: Thu, 4 Feb 2010 16:44:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-Id: <20100204164441.d012f6fa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100204071840.GC5574@linux-sh.org>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
	<20100203193127.fe5efa17.akpm@linux-foundation.org>
	<20100204140942.0ef6d7b1.nishimura@mxp.nes.nec.co.jp>
	<20100204142736.2a8bec26.kamezawa.hiroyu@jp.fujitsu.com>
	<20100204071840.GC5574@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010 16:18:40 +0900
Paul Mundt <lethal@linux-sh.org> wrote:

> On Thu, Feb 04, 2010 at 02:27:36PM +0900, KAMEZAWA Hiroyuki wrote:

> > I think memcg should depends on CONIFG_MMU.
> > 
> > How do you think ?
> > 
> Unless there's a real technical reason to make it depend on CONFIG_MMU,
> that's just papering over the problem, and means that some nommu person
> will have to come back and fix it properly at a later point in time.
> 
I have no strong opinion this. It's ok to support as much as possible.
My concern is that there is no !MMU architecture developper around memcg. So,
error report will be delayed.


> CONFIG_SWAP itself is configurable even with CONFIG_MMU=y, so having
> stubbed out helpers for the CONFIG_SWAP=n case would give the compiler a
> chance to optimize things away in those cases, too. Embedded systems
> especially will often have MMU=y and BLOCK=n, resulting in SWAP being
> unset but swap cache encodings still defined.
> 
> How about just changing the is_swap_pte() definition to depend on SWAP
> instead?
> 
I think the new feature as "move task charge" itself depends on CONFIG_MMU
because it walks a process's page table. 

Then, how about this ? (sorry, I can't test this in valid way..)

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, "move charges at task move" feature depends on page tables. So,
it doesn't work in !CONIFG_MMU enviroments.
This patch moves "task move" codes under CONIFG_MMU.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |    2 ++
 mm/memcontrol.c                  |   39 ++++++++++++++++++++++++++++++++++++---
 2 files changed, 38 insertions(+), 3 deletions(-)

Index: mmotm-2.6.33-Feb3/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.33-Feb3.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.33-Feb3/Documentation/cgroups/memory.txt
@@ -420,6 +420,8 @@ NOTE2: It is recommended to set the soft
 
 Users can move charges associated with a task along with task migration, that
 is, uncharge task's pages from the old cgroup and charge them to the new cgroup.
+This feature is not supporetd in !CONFIG_MMU environmetns because of lack of
+page tables.
 
 8.1 Interface
 
Index: mmotm-2.6.33-Feb3/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb3.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb3/mm/memcontrol.c
@@ -20,7 +20,6 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  */
-
 #include <linux/res_counter.h>
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
@@ -2281,6 +2280,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 	rcu_read_unlock();
 }
 
+#ifdef CONFIG_MMU /* this is used for task_move */
 /**
  * mem_cgroup_move_swap_account - move swap charge and swap_cgroup's record.
  * @entry: swap entry to be moved
@@ -2332,6 +2332,7 @@ static int mem_cgroup_move_swap_account(
 	}
 	return -EINVAL;
 }
+#endif
 #else
 static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 		struct mem_cgroup *from, struct mem_cgroup *to, bool need_fixup)
@@ -3027,6 +3028,7 @@ static u64 mem_cgroup_move_charge_read(s
 	return mem_cgroup_from_cont(cgrp)->move_charge_at_immigrate;
 }
 
+#ifdef CONIFG_MMU
 static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 					struct cftype *cft, u64 val)
 {
@@ -3045,7 +3047,13 @@ static int mem_cgroup_move_charge_write(
 
 	return 0;
 }
-
+#else
+static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
+				struct cftype *cft, u64 val)
+{
+	return -EINVAL;
+}
+#endif
 
 /* For read statistics */
 enum {
@@ -3846,6 +3854,7 @@ static int mem_cgroup_populate(struct cg
 	return ret;
 }
 
+#ifdef CONFIG_MMU
 /* Handlers for move charge at task migration. */
 #define PRECHARGE_COUNT_AT_ONCE	256
 static int mem_cgroup_do_precharge(unsigned long count)
@@ -3901,7 +3910,6 @@ one_by_one:
 	}
 	return ret;
 }
-
 /**
  * is_target_pte_for_mc - check a pte whether it is valid for move charge
  * @vma: the vma the pte to be checked belongs
@@ -4243,6 +4251,31 @@ static void mem_cgroup_move_charge(struc
 	}
 	up_read(&mm->mmap_sem);
 }
+#else
+
+static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
+	struct cgroup *cgroup,
+	struct task_struct *p,
+	bool threadgroup)
+{
+	return 0;
+}
+
+static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
+		struct cgroup *cgroup,
+		struct task_struct *p,
+		bool threadgroup)
+{
+}
+
+static void mem_cgroup_move_charge(struct mm_struct *mm)
+{
+}
+
+static void mem_cgroup_clear_mc(void)
+{
+}
+#endif
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
