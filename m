Date: Mon, 25 Feb 2008 23:51:27 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 15/15] memcg: fix oops on NULL lru list
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252350360.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While testing force_empty, during an exit_mmap, __mem_cgroup_remove_list
called from mem_cgroup_uncharge_page oopsed on a NULL pointer in the lru
list.  I couldn't see what racing tasks on other cpus were doing, but
surmise that another must have been in mem_cgroup_charge_common on the
same page, between its unlock_page_cgroup and spin_lock_irqsave near
done (thanks to that kzalloc which I'd almost changed to a kmalloc).

Normally such a race cannot happen, the ref_cnt prevents it, the final
uncharge cannot race with the initial charge.  But force_empty buggers
the ref_cnt, that's what it's all about; and thereafter forced pages
are vulnerable to races such as this (just think of a shared page
also mapped into an mm of another mem_cgroup than that just emptied).
And remain vulnerable until they're freed indefinitely later.

This patch just fixes the oops by moving the unlock_page_cgroups down
below adding to and removing from the list (only possible given the
previous patch); and while we're at it, we might as well make it an
invariant that page->page_cgroup is always set while pc is on lru.

But this behaviour of force_empty seems highly unsatisfactory to me:
why have a ref_cnt if we always have to cope with it being violated
(as in the earlier page migration patch).  We may prefer force_empty
to move pages to an orphan mem_cgroup (could be the root, but better
not), from which other cgroups could recover them; we might need to
reverse the locking again; but no time now for such concerns.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

--- memcg14/mm/memcontrol.c	2008-02-25 14:06:28.000000000 +0000
+++ memcg15/mm/memcontrol.c	2008-02-25 14:06:33.000000000 +0000
@@ -623,13 +623,13 @@ retry:
 		goto retry;
 	}
 	page_assign_page_cgroup(page, pc);
-	unlock_page_cgroup(page);
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
+	unlock_page_cgroup(page);
 done:
 	return 0;
 out:
@@ -677,14 +677,14 @@ void mem_cgroup_uncharge_page(struct pag
 	VM_BUG_ON(pc->ref_cnt <= 0);
 
 	if (--(pc->ref_cnt) == 0) {
-		page_assign_page_cgroup(page, NULL);
-		unlock_page_cgroup(page);
-
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
 		__mem_cgroup_remove_list(pc);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 
+		page_assign_page_cgroup(page, NULL);
+		unlock_page_cgroup(page);
+
 		mem = pc->mem_cgroup;
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
@@ -736,23 +736,24 @@ void mem_cgroup_page_migration(struct pa
 		return;
 	}
 
-	page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
-
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_remove_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
+	page_assign_page_cgroup(page, NULL);
+	unlock_page_cgroup(page);
+
 	pc->page = newpage;
 	lock_page_cgroup(newpage);
 	page_assign_page_cgroup(newpage, pc);
-	unlock_page_cgroup(newpage);
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+	unlock_page_cgroup(newpage);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
