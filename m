Date: Tue, 24 Jun 2008 14:51:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: end migration fix (was  [bad page] memcg: another
 bad page at page migration (2.6.26-rc5-mm3 + patch collection))
Message-Id: <20080624145127.539eb5ff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080623145341.0a365c67.nishimura@mxp.nes.nec.co.jp>
References: <20080623145341.0a365c67.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Nishimura-san. thank you for all your help. 

I think this one is......hopefully.

==

In general, mem_cgroup's charge on ANON page is removed when page_remove_rmap()
is called.

At migration, the newpage is remapped again by remove_migration_ptes(). But
pte may be already changed (by task exits).
It is charged at page allocation but have no chance to be uncharged in that
case because it is never added to rmap.

Handle that corner case in mem_cgroup_end_migration().


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 mm/memcontrol.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

Index: test2-2.6.26-rc5-mm3/mm/memcontrol.c
===================================================================
--- test2-2.6.26-rc5-mm3.orig/mm/memcontrol.c
+++ test2-2.6.26-rc5-mm3/mm/memcontrol.c
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
