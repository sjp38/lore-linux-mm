Date: Wed, 14 Nov 2007 17:41:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][ for -mm] memory controller enhancements for NUMA [1/10]
 record nid/zid on page_cgroup
Message-Id: <20071114174131.cf7c4aa6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071114173950.92857eaa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071114173950.92857eaa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

This patch adds nid/zoneid value to page cgroup.
This helps per-zone accounting for memory cgroup and reclaim routine.

Signed-off-by: KAMEZAWA Hiroyuki <kmaezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6.24-rc2-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/mm/memcontrol.c
+++ linux-2.6.24-rc2-mm1/mm/memcontrol.c
@@ -131,6 +131,8 @@ struct page_cgroup {
 	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
 					/* mapped and cached states     */
 	int	 flags;
+	short	nid;
+	short	zid;
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
@@ -216,6 +218,10 @@ void page_assign_page_cgroup(struct page
 		VM_BUG_ON(!page_cgroup_locked(page));
 	locked = (page->page_cgroup & PAGE_CGROUP_LOCK);
 	page->page_cgroup = ((unsigned long)pc | locked);
+	if (pc) {
+		pc->nid = page_to_nid(page);
+		pc->zid = page_zonenum(page);
+	}
 }
 
 struct page_cgroup *page_get_page_cgroup(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
