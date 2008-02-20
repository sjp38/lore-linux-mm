Date: Wed, 20 Feb 2008 15:27:53 +0900 (JST)
Message-Id: <20080220.152753.98212356.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

> On Tue, 19 Feb 2008, KAMEZAWA Hiroyuki wrote:
> > I'd like to start from RFC.
> > 
> > In following code
> > ==
> >   lock_page_cgroup(page);
> >   pc = page_get_page_cgroup(page);
> >   unlock_page_cgroup(page);
> > 
> >   access 'pc' later..
> > == (See, page_cgroup_move_lists())
> > 
> > There is a race because 'pc' is not a stable value without lock_page_cgroup().
> > (mem_cgroup_uncharge can free this 'pc').
> > 
> > For example, page_cgroup_move_lists() access pc without lock.
> > There is a small race window, between page_cgroup_move_lists()
> > and mem_cgroup_uncharge(). At uncharge, page_cgroup struct is immedieately
> > freed but move_list can access it after taking lru_lock.
> > (*) mem_cgroup_uncharge_page() can be called without zone->lru lock.
> > 
> > This is not good manner.
> > .....
> > There is no quick fix (maybe). Moreover, I hear some people around me said
> > current memcontrol.c codes are very complicated.
> > I agree ;( ..it's caued by my work.
> > 
> > I'd like to fix problems in clean way.
> > (Note: current -rc2 codes works well under heavy pressure. but there
> >  is possibility of race, I think.)
> 
> Yes, yes, indeed, I've been working away on this too.
> 
> Ever since the VM_BUG_ON(page_get_page_cgroup(page)) went into
> free_hot_cold_page (at my own prompting), I've been hitting it
> just very occasionally in my kernel build testing.  Was unable
> to reproduce it over the New Year, but a week or two ago found
> one machine and config on which it is relatively reproducible,
> pretty sure to happen within 12 hours.
> 
> And on Saturday evening at last identified the cause, exactly
> where you have: that unsafety in mem_cgroup_move_lists - which
> has the nice property of putting pages from the lru on to SLUB's
> freelist!
> 
> Unlike the unsafeties of force_empty, this is liable to hit anyone
> running with MEM_CONT compiled in, they don't have to be consciously
> using mem_cgroups at all.

As for force_empty, though this may not be the main topic here,
mem_cgroup_force_empty_list() can be implemented simpler.
It is possible to make the function just call mem_cgroup_uncharge_page()
instead of releasing page_cgroups by itself. The tips is to call get_page()
before invoking mem_cgroup_uncharge_page() so the page won't be released
during this function.

Kamezawa-san, you may want look into the attached patch.
I think you will be free from the weired complexity here.

This code can be optimized but it will be enough since this function
isn't critical.

Thanks.


Signed-off-by: Hirokazu Takahashi <taka@vallinux.co.jp>

--- mm/memcontrol.c.ORG	2008-02-12 18:44:45.000000000 +0900
+++ mm/memcontrol.c 2008-02-20 14:23:38.000000000 +0900
@@ -837,7 +837,7 @@ mem_cgroup_force_empty_list(struct mem_c
 {
 	struct page_cgroup *pc;
 	struct page *page;
-	int count;
+	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
 
@@ -846,30 +846,21 @@ mem_cgroup_force_empty_list(struct mem_c
 	else
 		list = &mz->inactive_list;
 
-	if (list_empty(list))
-		return;
-retry:
-	count = FORCE_UNCHARGE_BATCH;
 	spin_lock_irqsave(&mz->lru_lock, flags);
-
-	while (--count && !list_empty(list)) {
+	while (!list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		page = pc->page;
-		/* Avoid race with charge */
-		atomic_set(&pc->ref_cnt, 0);
-		if (clear_page_cgroup(page, pc) == pc) {
-			css_put(&mem->css);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			__mem_cgroup_remove_list(pc);
-			kfree(pc);
-		} else 	/* being uncharged ? ...do relax */
-			break;
+		get_page(page);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+		mem_cgroup_uncharge_page(page);
+		put_page(page);
+		if (--count <= 0) {
+			count = FORCE_UNCHARGE_BATCH;
+			cond_resched();
+		}
+		spin_lock_irqsave(&mz->lru_lock, flags);
 	}
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	if (!list_empty(list)) {
-		cond_resched();
-		goto retry;
-	}
 	return;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
