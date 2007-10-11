Date: Thu, 11 Oct 2007 13:55:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][BUGFIX][for -mm] Misc fix for memory cgroup [1/5] -- fix
 refcnt check in mem_cgroup_charge
Message-Id: <20071011135549.01af574d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

The logic of uncharge is 
 - decrement refcnt -> lock page cgroup -> remove page cgroup.
But the logic of charging is
 - lock page cgroup -> increment refcnt -> return.

Then, one charge will be added to a page_cgroup under being removed.
This makes no big trouble (like panic) but one charge is lost.

This patch add a test at charging to verify page_cgroup's refcnt is
greater than 0. If not, unlock and retry.

Changelog v1->v2:
 * added cpu_relax() before retry.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/memcontrol.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

Index: devel-2.6.23-rc8-mm2/mm/memcontrol.c
===================================================================
--- devel-2.6.23-rc8-mm2.orig/mm/memcontrol.c
+++ devel-2.6.23-rc8-mm2/mm/memcontrol.c
@@ -271,14 +271,20 @@ int mem_cgroup_charge(struct page *page,
 	 * to see if the cgroup page already has a page_cgroup associated
 	 * with it
 	 */
+retry:
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
 	/*
 	 * The page_cgroup exists and the page has already been accounted
 	 */
 	if (pc) {
-		atomic_inc(&pc->ref_cnt);
-		goto done;
+		if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
+			/* this page is under being uncharged ? */
+			unlock_page_cgroup(page);
+			cpu_relax();
+			goto retry;
+		} else
+			goto done;
 	}
 
 	unlock_page_cgroup(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
