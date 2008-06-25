Date: Wed, 25 Jun 2008 19:10:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [-mm][PATCH 9/10]  memcg: fix mem_cgroup_end_migration() race
In-Reply-To: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080625190914.D867.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

=
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In general, mem_cgroup's charge on ANON page is removed when page_remove_rmap()
is called.

At migration, the newpage is remapped again by remove_migration_ptes(). But
pte may be already changed (by task exits).
It is charged at page allocation but have no chance to be uncharged in that
case because it is never added to rmap.

Handle that corner case in mem_cgroup_end_migration().


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/memcontrol.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -747,10 +747,22 @@ int mem_cgroup_prepare_migration(struct 
 /* remove redundant charge if migration failed*/
 void mem_cgroup_end_migration(struct page *newpage)
 {
-	/* At success, page->mapping is not NULL and nothing to do. */
+	/*
+	 * At success, page->mapping is not NULL.
+	 * special rollback care is necessary when
+	 * 1. at migration failure. (newpage->mapping is cleared in this case)
+	 * 2. the newpage was moved but not remapped again because the task
+	 *    exits and the newpage is obsolete. In this case, the new page
+	 *    may be a swapcache. So, we just call mem_cgroup_uncharge_page()
+	 *    always for avoiding mess. The  page_cgroup will be removed if
+	 *    unnecessary. File cache pages is still on radix-tree. Don't
+	 *    care it.
+	 */
 	if (!newpage->mapping)
 		__mem_cgroup_uncharge_common(newpage,
 					 MEM_CGROUP_CHARGE_TYPE_FORCE);
+	else if (PageAnon(newpage))
+		mem_cgroup_uncharge_page(newpage);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
