Date: Mon, 29 Sep 2008 19:21:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/4] memcg: account swap cache under lock
Message-Id: <20080929192123.5ce60c24.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

While page-cache's charge/uncharge is done under page_lock(), swap-cache
isn't. (anonymous page is charged when it's newly allocated.)

This patch moves do_swap_page()'s charge() call under lock.
I don't see any bad problem *now* but this fix will be good for future
for avoiding unneccesary racy state.


Changelog: (v5) -> (v6)
 - mark_page_accessed() is moved before lock_page().
 - fixed missing unlock_page()
(no changes in previous version)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memory.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/memory.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memory.c
+++ mmotm-2.6.27-rc7+/mm/memory.c
@@ -2326,16 +2326,17 @@ static int do_swap_page(struct mm_struct
 		count_vm_event(PGMAJFAULT);
 	}
 
+	mark_page_accessed(page);
+
+	lock_page(page);
+	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+
 	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
-		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 		ret = VM_FAULT_OOM;
+		unlock_page(page);
 		goto out;
 	}
 
-	mark_page_accessed(page);
-	lock_page(page);
-	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
-
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
