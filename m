Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id E78226B0124
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 16:45:36 -0500 (EST)
Date: Fri, 17 Feb 2012 13:45:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/6] page cgroup diet v5
Message-Id: <20120217134535.020b7254.akpm@linux-foundation.org>
In-Reply-To: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

On Fri, 17 Feb 2012 18:24:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> This patch set is for removing 2 flags PCG_FILE_MAPPED and PCG_MOVE_LOCK on
> page_cgroup->flags. After this, page_cgroup has only 3bits of flags.
> And, this set introduces a new method to update page status accounting per memcg.
> With it, we don't have to add new flags onto page_cgroup if 'struct page' has
> information. This will be good for avoiding a new flag for page_cgroup.
> 
> Fixed pointed out parts.
>  - added more comments
>  - fixed texts
>  - removed redundant arguments.
> 

I tweaked a few things here.  Renamed "bool lock;" to "bool locked" in
several places.  Also the void-returning
mem_cgroup_begin_update_page_stat() was doing an explicit return which
is OK C but pointless and misleading.


Also, this has been bugging me for a while ;)

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/memcontrol.c: s/stealed/stolen/

A grammatical fix.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff -puN mm/memcontrol.c~a mm/memcontrol.c
--- a/mm/memcontrol.c~a
+++ a/mm/memcontrol.c
@@ -1299,8 +1299,8 @@ static void mem_cgroup_end_move(struct m
 /*
  * 2 routines for checking "mem" is under move_account() or not.
  *
- * mem_cgroup_stealed() - checking a cgroup is mc.from or not. This is used
- *			  for avoiding race in accounting. If true,
+ * mem_cgroup_stolen() -  checking whether a cgroup is mc.from or not. This
+ *			  is used for avoiding races in accounting.  If true,
  *			  pc->mem_cgroup may be overwritten.
  *
  * mem_cgroup_under_move() - checking a cgroup is mc.from or mc.to or
@@ -1308,7 +1308,7 @@ static void mem_cgroup_end_move(struct m
  *			  waiting at hith-memory prressure caused by "move".
  */
 
-static bool mem_cgroup_stealed(struct mem_cgroup *memcg)
+static bool mem_cgroup_stolen(struct mem_cgroup *memcg)
 {
 	VM_BUG_ON(!rcu_read_lock_held());
 	return atomic_read(&memcg->moving_account) > 0;
@@ -1356,7 +1356,7 @@ static bool mem_cgroup_wait_acct_move(st
  * Take this lock when
  * - a code tries to modify page's memcg while it's USED.
  * - a code tries to modify page state accounting in a memcg.
- * see mem_cgroup_stealed(), too.
+ * see mem_cgroup_stolen(), too.
  */
 static void move_lock_mem_cgroup(struct mem_cgroup *memcg,
 				  unsigned long *flags)
@@ -1899,9 +1899,9 @@ again:
 	 * If this memory cgroup is not under account moving, we don't
 	 * need to take move_lock_page_cgroup(). Because we already hold
 	 * rcu_read_lock(), any calls to move_account will be delayed until
-	 * rcu_read_unlock() if mem_cgroup_stealed() == true.
+	 * rcu_read_unlock() if mem_cgroup_stolen() == true.
 	 */
-	if (!mem_cgroup_stealed(memcg))
+	if (!mem_cgroup_stolen(memcg))
 		return;
 
 	move_lock_mem_cgroup(memcg, flags);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
