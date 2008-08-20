Date: Wed, 20 Aug 2008 20:00:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH -mm 0/7] memcg: lockless page_cgroup v1
Message-Id: <20080820200006.a152c14c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080820194108.e76b20b3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820194108.e76b20b3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Aug 2008 19:41:08 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 20 Aug 2008 18:53:06 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Hi, this is a patch set for lockless page_cgroup.
> > 
> > dropped patches related to mem+swap controller for easy review.
> > (I'm rewriting it, too.)
> > 
> > Changes from current -mm is.
> >   - page_cgroup->flags operations is set to be atomic.
> >   - lock_page_cgroup() is removed.
> >   - page->page_cgroup is changed from unsigned long to struct page_cgroup*
> >   - page_cgroup is freed by RCU.
> >   - For avoiding race, charge/uncharge against mm/memory.c::insert_page() is
> >     omitted. This is ususally used for mapping device's page. (I think...)
> > 
> > In my quick test, perfomance is improved a little. But the benefit of this
> > patch is to allow access page_cgroup without lock. I think this is good 
> > for Yamamoto's Dirty page tracking for memcg.
> > For I/O tracking people, I added a header file for allowing access to
> > page_cgroup from out of memcontrol.c
> > 
> > The base kernel is recent mmtom. Any comments are welcome.
> > This is still under test. I have to do long-run test before removing "RFC".
> > 
> Known problem: force_emtpy is broken...so rmdir will struck into nightmare.
> It's because of patch 2/7.
> will be fixed in the next version.
> 

This is a quick fix but I think I can find some better solution..
==
Because removal from LRU is delayed, mz->lru will never be empty until
someone kick drain. This patch rotate LRU while force_empty and makes
page_cgroup will be freed.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 mm/memcontrol.c |   40 +++++++++++++++++++++++++---------------
 1 file changed, 25 insertions(+), 15 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -893,34 +893,45 @@ static void mem_cgroup_force_empty_list(
 			    struct mem_cgroup_per_zone *mz,
 			    enum lru_list lru)
 {
-	struct page_cgroup *pc;
+	struct page_cgroup *pc, *tmp;
 	struct page *page;
 	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
+	int drain, rotate;
 
 	list = &mz->lists[lru];
 
 	spin_lock_irqsave(&mz->lru_lock, flags);
+	rotate = 0;
 	while (!list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
-		page = pc->page;
-		get_page(page);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-		/*
-		 * Check if this page is on LRU. !LRU page can be found
-		 * if it's under page migration.
-		 */
-		if (PageLRU(page)) {
-			__mem_cgroup_uncharge_common(page,
-					MEM_CGROUP_CHARGE_TYPE_FORCE);
-			put_page(page);
+		drain = PcgObsolete(pc);
+		if (drain) {
+			/* Skip this */
+			list_move(&pc->lru);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			rotate++;
+			if (rotate > MEMCG_LRU_THRESH/2)
+				mem_cgroup_all_force_drain();
+			cond_resched();
+		} else {
+			page = pc->page;
+			get_page(page);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			/*
+		 	* Check if this page is on LRU. !LRU page can be found
+		 	* if it's under page migration.
+		 	*/
+			if (PageLRU(page)) {
+				__mem_cgroup_uncharge_common(page,
+						MEM_CGROUP_CHARGE_TYPE_FORCE);
+			}
 			if (--count <= 0) {
 				count = FORCE_UNCHARGE_BATCH;
 				cond_resched();
 			}
-		} else
-			cond_resched();
+		}
 		spin_lock_irqsave(&mz->lru_lock, flags);
 	}
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
@@ -954,7 +965,6 @@ static int mem_cgroup_force_empty(struct
 			}
 	}
 	ret = 0;
-	mem_cgroup_all_force_drain();
 out:
 	css_put(&mem->css);
 	return ret;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
