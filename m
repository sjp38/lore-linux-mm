Date: Wed, 14 May 2008 17:11:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH 5/6] memcg: optimize branch
Message-Id: <20080514171110.8cf4d4e1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Showing brach direction for obvious conditions.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6.26-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/memcontrol.c
+++ linux-2.6.26-rc2/mm/memcontrol.c
@@ -550,7 +550,7 @@ retry:
 	 * The page_cgroup exists and
 	 * the page has already been accounted.
 	 */
-	if (pc) {
+	if (unlikely(pc)) {
 		VM_BUG_ON(pc->page != page);
 		VM_BUG_ON(!pc->mem_cgroup);
 		unlock_page_cgroup(page);
@@ -559,7 +559,7 @@ retry:
 	unlock_page_cgroup(page);
 
 	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
-	if (pc == NULL)
+	if (unlikely(pc == NULL))
 		goto err;
 
 	/*
@@ -616,7 +616,7 @@ retry:
 		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 
 	lock_page_cgroup(page);
-	if (page_get_page_cgroup(page)) {
+	if (unlikely(page_get_page_cgroup(page))) {
 		unlock_page_cgroup(page);
 		/*
 		 * Another charge has been added to this page already.
@@ -689,7 +689,7 @@ void __mem_cgroup_uncharge_common(struct
 	 */
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	if (!pc)
+	if (unlikely(!pc))
 		goto unlock;
 
 	VM_BUG_ON(pc->page != page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
