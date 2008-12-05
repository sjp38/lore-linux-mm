Date: Fri, 5 Dec 2008 21:24:50 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH -mmotm 3/4] memcg: avoid dead lock caused by race
 between oom and cpuset_attach
Message-Id: <20081205212450.574f498c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

mpol_rebind_mm(), which can be called from cpuset_attach(), does down_write(mm->mmap_sem).
This means down_write(mm->mmap_sem) can be called under cgroup_mutex.

OTOH, page fault path does down_read(mm->mmap_sem) and calls mem_cgroup_try_charge_xxx(), 
which may eventually calls mem_cgroup_out_of_memory(). And mem_cgroup_out_of_memory()
calls cgroup_lock().
This means cgroup_lock() can be called under down_read(mm->mmap_sem).

If those two paths race, dead lock can happen.

This patch avoid this dead lock by:
  - remove cgroup_lock() from mem_cgroup_out_of_memory().
  - define new mutex (memcg_tasklist) and serialize mem_cgroup_move_task()
    (->attach handler of memory cgroup) and mem_cgroup_out_of_memory. 

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    5 +++++
 mm/oom_kill.c   |    2 --
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9c5856b..ab04725 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -51,6 +51,7 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
 #define do_swap_account		(0)
 #endif
 
+static DEFINE_MUTEX(memcg_tasklist);	/* can be hold under cgroup_mutex */
 
 /*
  * Statistics for memory cgroup.
@@ -796,7 +797,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 		if (!nr_retries--) {
 			if (oom) {
+				mutex_lock(&memcg_tasklist);
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
+				mutex_unlock(&memcg_tasklist);
 				mem_over_limit->last_oom_jiffies = jiffies;
 			}
 			goto nomem;
@@ -2172,10 +2175,12 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *old_cont,
 				struct task_struct *p)
 {
+	mutex_lock(&memcg_tasklist);
 	/*
 	 * FIXME: It's better to move charges of this process from old
 	 * memcg to new memcg. But it's just on TODO-List now.
 	 */
+	mutex_unlock(&memcg_tasklist);
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index fd150e3..40ba050 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -429,7 +429,6 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	unsigned long points = 0;
 	struct task_struct *p;
 
-	cgroup_lock();
 	read_lock(&tasklist_lock);
 retry:
 	p = select_bad_process(&points, mem);
@@ -444,7 +443,6 @@ retry:
 		goto retry;
 out:
 	read_unlock(&tasklist_lock);
-	cgroup_unlock();
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
