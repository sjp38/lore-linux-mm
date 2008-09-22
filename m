Date: Mon, 22 Sep 2008 19:57:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/13] memcg: account fault-in swap under lock.
Message-Id: <20080922195741.b6a3e69d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

While page-cache's charge/uncharge is done under page_lock(), swap-cache
isn't. (anonymous page is charged when it's newly allocated.)

This patch moves do_swap_page()'s charge() call under lock.
This is good for avoiding unnecessary slow-path in charge().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memory.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

Index: mmotm-2.6.27-rc6+/mm/memory.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/memory.c
+++ mmotm-2.6.27-rc6+/mm/memory.c
@@ -2320,15 +2320,14 @@ static int do_swap_page(struct mm_struct
 		count_vm_event(PGMAJFAULT);
 	}
 
+	lock_page(page);
+	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+
 	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
-		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 		ret = VM_FAULT_OOM;
 		goto out;
 	}
-
 	mark_page_accessed(page);
-	lock_page(page);
-	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
 	/*
 	 * Back out if somebody else already faulted in this pte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
